//
//  SpotCollection+Query.swift
//  
//
//  Created by Ben Gottlieb on 3/6/23.
//

import Suite
import FirebaseFirestore
import FirebaseFirestoreSwift

public extension SpotCollection {
	var syncAll: [SpotDocument<RecordType>] {
		allCache ?? []
	}
	
	func stopListening() {
		guard let listener else { return }
		
		listenCount -= 1
		if listenCount == 0 {
			listener.remove()
			self.listener = nil
		}
	}
	
	@discardableResult func listen() -> SpotCollection<RecordType> {
		listenCount += 1
		if isListening { return self }

		listener = base.addSnapshotListener { [weak self] querySnapshot, error in
			guard let self else { return }
			
			Task { @MainActor in
				guard let changes = querySnapshot?.documentChanges else {
					FireSpotterLogger.debug("Saving a record with no changes \(querySnapshot, privacy: .public)")
					return
				}
				
				for change in changes {
					let id = change.document.documentID
					switch change.type {
					case .added, .modified:
						let data = change.document.data().convertingFirebaseTimestampsToDates()
						if let current = self.cache.inMemoryCache.value[id] {
							await current.loadChanges(data)
						} else if let current = self.allCache?.first(where: { $0.id == id }) {
							await current.loadChanges(data)
						} else if self.allCache != nil, let element = try? RecordType.loadJSON(dictionary: data, using: .firebaseDecoder) {
							let new = SpotDocument(element, collection: self, json: data)
							self.cache(new)
						}

					case .removed:
						if let index = self.allCache?.firstIndex(where: { $0.id == id }) {
							if let manager = FirestoreManager.instance.recordManager, let obj = self.allCache?[index], await !manager.shouldDelete(object: obj.record) { return }
							self.allCache?.removeAll { $0.id == id }
							Task { await self.cache.removeRecord(forKey: id) }

						} else if let manager = FirestoreManager.instance.recordManager, let obj = self.cache.inMemoryCache.value[id], await !manager.shouldDelete(object: obj.record) {
							return
						}

						Task { await self.cache.removeRecord(forKey: id) }
					}
				}
				self.objectWillChange.send()
			}
		}
		
		return self
	}
	
	
	@discardableResult @MainActor func fetchAll() async throws -> [SpotDocument<RecordType>] {
		try await all
	}
	
	@MainActor var all: [SpotDocument<RecordType>] {
		get async throws {
			if let all = allCache { return all }
			let results = try await base.getDocuments().documents
			FireSpotterLogger.info("Fetched \(results.count, privacy: .public) \(String(describing: RecordType.self), privacy: .public)")
			allCache = try results.map {
				do {
					return try document(from: $0.data() )
				} catch {
					FireSpotterLogger.error("Error decoding \(RecordType.self, privacy: .public): \(error, privacy: .public)")
					throw error
				}
			}
			for doc in allCache! { await doc.awakeFromFetch() }
			objectWillChange.send()
			return allCache ?? []
		}
	}
	
	@MainActor func documents(where field: String, isEqualTo target: Any) async throws -> [SpotDocument<RecordType>] {
		
		let results = try await base.whereField(field, isEqualTo: target).getDocuments().documents
		
		
		return try results.map { try document(from: $0.data() ) }
	}
	
	@MainActor func documents(where field: String, startsWith target: String) async throws -> [SpotDocument<RecordType>] {
		
		let results = try await base
			.whereField(field, isGreaterThanOrEqualTo: target)
			.whereField(field, isLessThan: target + "~")
			.getDocuments().documents
		
		
		return try results.map { try document(from: $0.data() ) }
	}
}
