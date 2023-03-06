//
//  SpotCollection.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Suite
import FirebaseFirestore
import FirebaseFirestoreSwift

public class SpotCollection<Element: SpotRecord>: ObservableObject where Element.ID == String {
	public let base: CollectionReference
	
	var cache: [String: SpotDocument<Element>] = [:]
	
	init(_ collection: CollectionReference, kind: Element.Type) {
		base = collection
	}
	
	@discardableResult func append(_ element: Element) throws -> SpotDocument<Element> {
		let doc = base.document(element.id)
		try doc.setData(from: element)
		
		return SpotDocument(element, collection: self)
	}
	
	@discardableResult func save(_ element: Element, json: [String: Any]? = nil) async throws -> SpotDocument<Element> {
		if let cached = cache[element.id] {
			cached.subject = element
			try await save(cached)
			return cached
		}
		
		let doc = SpotDocument(element, collection: self)
		cache[element.id] = doc
		try await save(doc)
		return doc
	}
	
	func save(_ doc: SpotDocument<Element>) async throws {
		try await base.document(doc.id).setData(doc.jsonPayload)
	}
	
	public var isEmpty: Bool {
		get async throws {
			try await base.limit(to: 1).count.query.getDocuments().count == 0
		}
	}
	
	@MainActor public func new() -> SpotDocument<Element> {
		let new = SpotDocument(Element.newRecord(), collection: self)
		cache[new.id] = new
		return new
	}


	subscript(id: String, default: Element) -> SpotDocument<Element> {
		get async {
			if let current = await self[id] { return current }
			let new = SpotDocument(`default`, collection: self)
			new.id = id
			cache[id] = new
			return new
		}
	}
	
	subscript(id: String) -> SpotDocument<Element>? {
		get async {
			do {
				let raw = try await base.document(id).getDocument()
				
				guard let json = raw.data() else {
					return nil
				}
				let doc = try Element.loadJSON(dictionary: json)

				return SpotDocument(doc, collection: self, json: json)
			} catch {
				print("Failed to get document: \(error)")
				return nil
			}
		}
	}
}
