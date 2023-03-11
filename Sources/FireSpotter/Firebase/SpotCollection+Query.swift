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
	
	func listen() -> SpotCollection<Element> {
		if isListening { return self }

		base.addSnapshotListener { querySnapshot, error in
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
							current.loadChanges(data)
						} else if let current = self.allCache?.first(where: { $0.id == id }) {
							current.loadChanges(data)
						} else if self.allCache != nil, let element = try? Element.loadJSON(dictionary: data) {
							let new = SpotDocument(element, collection: self, json: data)
							self.allCache?.append(new)
						}

					case .removed:
						if let index = self.allCache?.firstIndex(where: { $0.id == id }) {
							self.allCache?.remove(at: index)
						}
						self.cache.removeValue(forKey: id)
					}
				}
				self.objectWillChange.send()
			}
		}
		
		isListening = true
		return self
	}
	
	@MainActor var all: [SpotDocument<Element>] {
		get async {
			do {
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
