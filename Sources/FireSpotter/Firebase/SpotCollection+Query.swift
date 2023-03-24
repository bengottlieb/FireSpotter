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
	var syncAll: [SpotDocument<Element>] {
		allCache ?? []
	}
	
	func stopListening() {
		guard let listener else { return }
		
		listener.remove()
		self.listener = nil
	}
	
	@discardableResult func listen() -> SpotCollection<Element> {
		if isListening { return self }

		listener = base.addSnapshotListener { querySnapshot, error in
			Task { @MainActor in
				guard let changes = querySnapshot?.documentChanges else {
					print("No changes")
					return
				}
				
				print("Received \(changes.count) changes")
				for change in changes {
					let id = change.document.documentID
					switch change.type {
					case .added, .modified:
						let data = change.document.data()
						if let current = self.cache[id] {
							await current.loadChanges(data)
						} else if let current = self.allCache?.first(where: { $0.id == id }) {
							await current.loadChanges(data)
						} else if self.allCache != nil, let element = try? Element.loadJSON(dictionary: data, using: .firebaseDecoder) {
							let new = SpotDocument(element, collection: self, json: data)
							self.allCache?.append(new)
						}

					case .removed:
						if let index = self.allCache?.firstIndex(where: { $0.id == id }) {
							if let manager = FirestoreManager.instance.recordManager, let obj = self.allCache?[index], await !manager.shouldDelete(object: obj.subject) { return }
							self.allCache?.remove(at: index)
						} else if let manager = FirestoreManager.instance.recordManager, let obj = self.cache[id], await !manager.shouldDelete(object: obj.subject) {
							return
						}

						self.cache.removeValue(forKey: id)
					}
				}
				self.objectWillChange.send()
			}
		}
		
		return self
	}
	
	@MainActor @discardableResult func fetchAll() async -> [SpotDocument<Element>] {
		await all
	}
	
	@MainActor var all: [SpotDocument<Element>] {
		get async {
			do {
				if let all = allCache { return all }
				let results = try await base.getDocuments().documents
				allCache = try results.map { try document(from: $0.data() ) }
				objectWillChange.send()
				print("Fetched \(results.count) / \(allCache?.count ?? 0) for \(path)")
				return allCache ?? []
			} catch {
				print("Failed to fetch documents: \(error)")
				return []
			}
		}
	}
	
	func documents(where field: String, isEqualTo target: Any) async throws -> [SpotDocument<Element>] {
		
		let results = try await base.whereField(field, isEqualTo: target).getDocuments().documents
		
		
		return try results.map { try document(from: $0.data() ) }
	}
	
	func documents(where field: String, startsWith target: String) async throws -> [SpotDocument<Element>] {
		
		let results = try await base
			.whereField(field, isGreaterThanOrEqualTo: target)
			.whereField(field, isLessThan: target + "~")
			.getDocuments().documents
		
		
		return try results.map { try document(from: $0.data() ) }
	}
}
