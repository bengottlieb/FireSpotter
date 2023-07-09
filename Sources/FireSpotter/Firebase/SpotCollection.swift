//
//  SpotCollection.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Suite
import FirebaseFirestore
import FirebaseFirestoreSwift

public protocol CollectionWrapper: AnyObject {
	var path: String { get }
	func changePath(to newPath: String) throws
}

public class SpotCollection<RecordType: SpotRecord>: ObservableObject, CollectionWrapper where RecordType.ID == String {
	public var base: CollectionReference
	
	var cache = ObjectCache<SpotDocument<RecordType>>()
	public var path: String { base.path }
	public var allCache: [SpotDocument<RecordType>]?
	public var cachedCount: Int { allCache?.count ?? 0 }
	var isListening: Bool { listener != nil }
	var listener: ListenerRegistration?
	var kind: FirebaseCollectionKind<RecordType>
	private var parentDocument: Any?
	
	
	init(_ collection: CollectionReference, kind: FirebaseCollectionKind<RecordType>, parent: Any? = nil) {
		print("Creating collection at \(collection.path) for \(String(describing: RecordType.self))")
		base = collection
		self.kind = kind
		self.parentDocument = parent
	}
	
	@MainActor public func remove(_ doc: SpotDocument<RecordType>) async throws {
		try await remove(doc.record)
	}
	
	public func parent<DocSubject: SpotRecord>() -> SpotDocument<DocSubject>? {
		parentDocument as? SpotDocument<DocSubject>
	}
	
	@MainActor public func remove(_ element: RecordType) async throws {
		try await base.document(element.id).delete()
		uncache(element)
		objectWillChange.send()
	}
	
	@MainActor public func move(_ doc: SpotDocument<RecordType>, toID id: String) async throws {
		if doc.id == id { return }
		try await remove(doc.record)
		doc.id = id
		try await save(doc)
		await cache.set(doc, forKey: id)
		allCache?.append(doc)
		objectWillChange.sendOnMain()
	}
	
	@MainActor public func isCached(_ element: RecordType) -> Bool {
		allCache?.contains(where: { $0.id == element.id }) == true
	}
	
	@MainActor public func uncache(_ element: RecordType) {
		if let index = allCache?.firstIndex(where: { $0.id == element.id }) {
			allCache?.remove(at: index)
		}
		Task { await cache.removeRecord(forKey: element.id) }
	}
	
	@discardableResult public func append(_ element: RecordType) throws -> SpotDocument<RecordType> {
		let doc = base.document(element.id)
		try doc.setData(element.asJSON().convertingDatesToFirebaseTimestamps(using: RecordType.self as? DateKeyProvider.Type))
		
		return SpotDocument(element, collection: self)
	}
	
	@discardableResult func save(_ element: RecordType, json: [String: Any]? = nil) async throws -> SpotDocument<RecordType> {
		if let cached = await cache.record(forKey: element.id) {
			cached.record = element
			try await save(cached)
			return cached
		}
		
		let doc = SpotDocument(element, collection: self)
		await cache.set(doc, forKey: element.id)
		try await save(doc)
		return doc
	}
	
	public func document(from element: RecordType, json: JSONDictionary) -> SpotDocument<RecordType> {
		if let cached = cache.inMemoryCache.value[element.id] {
			cached.record = element
			cached.json = json
			return cached
		}
		
		let new = SpotDocument(element, collection: self, json: json)
		Task { await cache.set(new, forKey: element.id) }
		return new
	}
	
	func save(_ doc: SpotDocument<RecordType>) async throws {
		try await base.document(doc.id).setData(doc.jsonPayload.convertingDatesToFirebaseTimestamps(using: RecordType.self as? DateKeyProvider.Type))
		objectWillChange.sendOnMain()
	}
	
	public var isEmpty: Bool {
		get async throws {
			try await base.limit(to: 1).count.query.getDocuments().count == 0
		}
	}
	
	public func changePath(to newPath: String) throws {
		if newPath == base.path { return }
		let isListening = self.isListening
		
		print("Changing collection: \(base.path) -> \(newPath)")
		stopListening()
		Task { await cache.clear() }
		allCache = []
		base = FirestoreManager.instance.db.collection(newPath)
		
		if isListening { listen() }
	}
	
	@MainActor public func new(withID id: String = .id(for: RecordType.self), addNow: Bool = true) -> SpotDocument<RecordType> {
		DispatchQueue.main.async { self.objectWillChange.send() }
		
		if addNow {
			let new = try! document(from: RecordType.newRecord(withID: id).asJSON())
			allCache?.append(new)
			return new
		}
		
		let record = RecordType.newRecord(withID: id)
		return SpotDocument(record, collection: self, isSaved: false)
	}
	
	func document(from json: JSONDictionary) throws -> SpotDocument<RecordType> {
		let element = try RecordType.loadJSON(dictionary: json.convertingFirebaseTimestampsToDates(), using: .firebaseDecoder)
		
		if let cached = cache.inMemoryCache.value[element.id] {
			cached.record = element
			cached.merge(json)
			return cached
		}
		
		let new = SpotDocument(element, collection: self, json: json)
		Task { await cache.set(new, forKey: new.id) }
		return new
	}
	
	public subscript(id: String, default: RecordType) -> SpotDocument<RecordType> {
		get async {
			assert(id.isNotEmpty, "Cannot create an element wiith an empty ID")
			if let current = await self[id] { return current }
			let new = SpotDocument(`default`, collection: self)
			new.id = id
			await cache.set(new, forKey: id)
			return new
		}
	}
	
	public subscript(id: String?) -> SpotDocument<RecordType>? {
		get async {
			do {
				guard let id, !id.isEmpty else { return nil }
				let raw = try await base.document(id).getDocument()
				guard let data = raw.data() else { return nil }
				let doc = try document(from: data)
				await doc.awakeFromFetch()
				return doc
			} catch {
				print("Failed to get \(RecordType.self): \(error)")
				return nil
			}
		}
	}
	
	public subscript(sync id: String?) -> SpotDocument<RecordType>? {
		get {
			allCache?.first { $0.id == id }
			
		}
	}
}
