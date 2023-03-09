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
	var path: String { base.path }
	var allCache: [SpotDocument<Element>]?
	
	init(_ collection: CollectionReference, kind: Element.Type) {
		print("Creating collection at \(collection.path) for \(String(describing: Element.self))")
		base = collection
	}
	
	@MainActor public func remove(_ doc: SpotDocument<Element>) async throws {
		try await remove(doc.subject)
	}
	
	@MainActor public func remove(_ element: Element) async throws {
		objectWillChange.send()
		try await base.document(element.id).delete()
		if let index = allCache?.firstIndex(where: { $0.id == element.id }) {
			allCache?.remove(at: index)
		}
		cache.removeValue(forKey: element.id)
	}
	
	@discardableResult public func append(_ element: Element) throws -> SpotDocument<Element> {
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
	
	public func document(from element: Element, json: JSONDictionary) -> SpotDocument<Element> {
		if let cached = cache[element.id] {
			cached.subject = element
			cached.json = json
			return cached
		}
		
		let new = SpotDocument(element, collection: self, json: json)
		cache[element.id] = new
		return new
	}
	
	func save(_ doc: SpotDocument<Element>) async throws {
		try await base.document(doc.id).setData(doc.jsonPayload)
	}
	
	public var isEmpty: Bool {
		get async throws {
			try await base.limit(to: 1).count.query.getDocuments().count == 0
		}
	}
	
	@MainActor public func new(withID id: String) -> SpotDocument<Element> {
		objectWillChange.send()
		let new = try! document(from: Element.newRecord(withID: id).asJSON())
		allCache?.append(new)
		return new
	}

	func document(from json: JSONDictionary) throws -> SpotDocument<Element> {
		let element = try Element.loadJSON(dictionary: json)
		
		if let cached = cache[element.id] {
			cached.subject = element
			cached.merge(json)
			return cached
		}
		
		let new = SpotDocument(element, collection: self, json: json)
		cache[new.id] = new
		return new
	}

	public subscript(id: String, default: Element) -> SpotDocument<Element> {
		get async {
			if let current = await self[id] { return current }
			let new = SpotDocument(`default`, collection: self)
			new.id = id
			cache[id] = new
			return new
		}
	}
	
	public subscript(id: String) -> SpotDocument<Element>? {
		get async {
			do {
				let raw = try await base.document(id).getDocument()
				guard let data = raw.data() else { return nil }
				return try document(from: data)
			} catch {
				print("Failed to get document: \(error)")
				return nil
			}
		}
	}
}
