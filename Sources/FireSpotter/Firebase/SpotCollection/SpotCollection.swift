//
//  SpotCollection.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Suite
import FirebaseFirestore
import FirebaseFirestoreSwift
import os.log

public protocol GenericSpotCollection: AnyObject { }

@FireSpotterActor public class SpotCollection<RecordType: SpotRecord>: ObservableObject, GenericSpotCollection {
	internal var base: CollectionReference!
	var listenerRegistration: ListenerRegistration?
	var isInitialLoadComplete = false
	var initialLoadContinuation: CheckedContinuation<Void, Never>?
	nonisolated public let path: String
	lazy var cache: SpotDocumentCache<RecordType> = SpotDocumentCache<RecordType>(parent: self)

	enum CollectionError: Error { case recordAlreadyExists }
	
	nonisolated init(empty: any SpotRecord.Type) { path = "" }
	
	convenience init(_ path: String, recordType: any SpotRecord.Type, monitorChanges: Bool = false) {
		let collection = Firestore.firestore().collection(path)
		self.init(collection, recordType: recordType, monitorChanges: monitorChanges)
	}
	
	convenience init(_ path: String, recordType: any SpotRecord.Type) async {
		let collection = Firestore.firestore().collection(path)
		self.init(collection, recordType: recordType, monitorChanges: false)
		let _: Void = await withCheckedContinuation { continuation in
			listenForChanges(continuation: continuation)
		}
	}
	
	init(_ collection: CollectionReference, recordType: any SpotRecord.Type, monitorChanges: Bool = false) {
		base = collection
		path = collection.path
		if monitorChanges { listenForChanges() }
	}
	
	func listenForChanges(continuation: CheckedContinuation<Void, Never>? = nil) {
		if let continuation { initialLoadContinuation = continuation }
		listenerRegistration = base.addSnapshotListener { snapshot, error in
			Task { @FireSpotterActor  in
				for change in snapshot?.documentChanges ?? [] {
					do {
						let record = try change.document.data(as: RecordType.self)
						
						switch change.type {
						case .added:
							self.cache.store(record)
						case .removed:
							self.cache.remove(record)
						case .modified:
							self.cache.store(record)
						}
					} catch {
						print("Failed to parse record: \(error)")
					}
				}
				self.isInitialLoadComplete = true
				self.initialLoadContinuation?.resume()
				self.initialLoadContinuation = nil
			}
		}
	}
	
	public subscript(create recordID: String, andSave: Bool = true) -> SpotDocument<RecordType> {
		get async {
			if let existing = await self[recordID] { return existing }
			do {
				return try await insert(RecordType(id: recordID), andSave: andSave)
			} catch {
				print("Failed to insert record: \(error)")
				return .init(RecordType(id: recordID), collection: self)
			}
		}
	}
	
	public subscript(recordID: String) -> SpotDocument<RecordType>? {
		get async {
			if let cached = cache[recordID] { return cached }
			do {
				guard let json = try await base.document(recordID).getDocument().data() else { return nil }
				let record = try RecordType.loadJSON(dictionary: json.convertingFirebaseTimestampsToDates())
				
				let doc = SpotDocument(record, collection: self)
				doc.json = json
				await doc.record.awakeFromFetch(in: doc)
				cache.store(doc)
				return doc
			} catch {
				FireSpotterLogger.error("Failed to get \(RecordType.self) \"\(recordID)\"")
				return nil
			}
		}
	}

	@discardableResult
	public func insert(_ record: RecordType, andSave: Bool = true) async throws -> SpotDocument<RecordType> {
		if let existing = await self[record.id] {
			existing.loadRecord(record)
			return existing
		}
		let doc = SpotDocument(record, collection: self)
		try await insert(doc, andSave: andSave)
		return doc
	}

	public func insert(_ document: SpotDocument<RecordType>, andSave: Bool = true) async throws {
		if let _ = await self[document.id] {
			return
		}
		print("Inserting \(String(describing: RecordType.self)), id: \(document.id)w")
		await document.record.awakeFromFetch(in: document)
		cache.store(document)
		if andSave { document.isDirty = true }
		try await document.save()
	}
	
	public var all: [SpotDocument<RecordType>] {
		get async {
			Array(cache.cache.values)
		}
	}
//
//	var cache = ObjectCache<SpotDocument<RecordType>>()
//
//	public var cachedDocuments: [SpotDocument<RecordType>] { allCache ?? [] }
//	public var allCache: [SpotDocument<RecordType>]?
//	public var cachedCount: Int { cachedDocuments.count }
//	var isListening: Bool { listener != nil }
//	var listenCount = 0
//	var listener: ListenerRegistration?
//	var kind: FirebaseCollectionKind<RecordType>
//	private var parentDocument: Any?
//	
//	
//	init(_ collection: CollectionReference, kind: FirebaseCollectionKind<RecordType>, parent: Any? = nil) {
//		//print("Creating collection at \(collection.path) for \(String(describing: RecordType.self))")
//		base = collection
//		self.kind = kind
//		self.parentDocument = parent
//	}
//	
//	deinit {
//		stopListening()
//	}
//	
//	public func parent<DocSubject: SpotRecord>() -> SpotDocument<DocSubject>? {
//		parentDocument as? SpotDocument<DocSubject>
//	}
//	
//	@MainActor public func move(_ doc: SpotDocument<RecordType>, toID id: String) async throws {
//		if doc.id == id { return }
//		try await remove(doc.record)
//		doc.id = id
//		try await save(doc)
//		cache(doc)
//		objectWillChange.sendOnMain()
//	}
//	
//	@MainActor public func isCached(_ id: String) -> Bool {
//		allCache?.contains(where: { $0.id == id }) == true
//	}
//	
//	
//	@MainActor public func isCached(_ element: RecordType) -> Bool {
//		allCache?.contains(where: { $0.id == element.id }) == true
//	}
//	
//	@MainActor public func uncache(_ element: RecordType) {
//		allCache?.removeAll { $0.id == element.id }
//		Task { await cache.removeRecord(forKey: element.id) }
//	}
//	
//	@MainActor func cache(_ document: SpotDocument<RecordType>) {
//		if allCache == nil { allCache = [] }
//		if allCache?.contains(document) == true {
//			FireSpotterLogger.warning("duplicate record?: \("", privacy: .public)")
//			return
//		}
//		allCache?.append(document)
//		Task { await cache.set(document, forKey: document.id) }
//	}
//	
//	@MainActor @discardableResult public func append(_ element: RecordType, andSave: Bool = true) throws -> SpotDocument<RecordType> {
//		let doc = base.document(element.id)
//		try doc.setData(element.asJSON().convertingDatesToFirebaseTimestamps(using: RecordType.self as? DateKeyProvider.Type))
//		
//		let newDoc = SpotDocument(element, collection: self)
//		cache(newDoc)
//		return newDoc
//	}
//	
	@discardableResult public func save(_ record: RecordType, json: [String: Any]? = nil) async throws -> SpotDocument<RecordType> {
		
		let cached = await self[create: record.id]
		cached.record = record
		try await save(cached)
		return cached
	}
	
	func save(_ doc: SpotDocument<RecordType>) async throws {
		if doc.id.isEmpty {
			FireSpotterLogger.warning("Trying to save an empty document: \(doc, privacy: .public)")
			return
		}
		let data = doc.jsonPayload.convertingDatesToFirebaseTimestamps(using: RecordType.self as? DateKeyProvider.Type)
		let ref = base.document(doc.id)
		try await ref.setData(data)
		objectWillChange.sendOnMain()
	}

//
//	@MainActor public func document(from element: RecordType, json: JSONDictionary) -> SpotDocument<RecordType> {
//		if let cached = cached(id: element.id) {
//			cached.record = element
//			cached.json = json
//			return cached
//		}
//		
//		let new = SpotDocument(element, collection: self, json: json)
//		cache(new)
//		return new
//	}
//	
//
//	public var isEmpty: Bool {
//		get async throws {
//			try await base.limit(to: 1).count.query.getDocuments().count == 0
//		}
//	}
//	
//	public func changePath(to newPath: String) throws {
//		if newPath == base.path { return }
//		let isListening = self.isListening
//		
//		FireSpotterLogger.info("Changing collection: \(self.base.path, privacy: .public) -> \(newPath, privacy: .public)")
//		stopListening()
//		Task { await cache.clear() }
//		allCache = []
//		base = FirestoreManager.instance.db.collection(newPath)
//		
//		if isListening { listen() }
//	}
//	
//	@MainActor @discardableResult public func add(record: RecordType) async -> SpotDocument<RecordType> {
//		if let existing = await self[record.id] {
//			existing.record = record
//			return existing
//		}
//		
//		let new = SpotDocument(record, collection: self)
//		cache(new)
//		objectWillChange.sendOnMain()
//		return new
//	}
//	
//	@MainActor public func new(withID id: String = .id(for: RecordType.self), addNow: Bool = true) -> SpotDocument<RecordType> {
//		DispatchQueue.main.async { self.objectWillChange.send() }
//		
//		if addNow {
//			let new = try! document(from: RecordType.newRecord(withID: id).asJSON())
//			return new
//		}
//		
//		let record = RecordType.newRecord(withID: id)
//		let doc = SpotDocument(record, collection: self, isSaved: false)
//		cache(doc)
//		return doc
//	}
//	
//	func cached(id: String) -> SpotDocument<RecordType>? {
//		if let cached = cache.inMemoryCache.value[id] { return cached }
//		
//		if let cached = allCache?.first(where: { $0.id == id }) { return cached }
//		return nil
//	}
//	
//	@MainActor func document(from json: JSONDictionary) throws -> SpotDocument<RecordType> {
//		let element = try RecordType.loadJSON(dictionary: json.convertingFirebaseTimestampsToDates(), using: .firebaseDecoder)
//		
//		if let cached = cached(id: element.id) {
//			cached.record = element
//			cached.merge(json)
//			return cached
//		}
//		
//		let new = SpotDocument(element, collection: self, json: json)
//		cache(new)
//		return new
//	}
//	
//	public subscript(id: String, default: RecordType) -> SpotDocument<RecordType> {
//		get async {
//			assert(id.isNotEmpty, "Cannot create an element with an empty ID")
//			if let current = await self[id] { return current }
//			let new = SpotDocument(`default`, collection: self)
//			new.id = id
//			await cache(new)
//			return new
//		}
//	}
//	
//	@MainActor public subscript(id: String?) -> SpotDocument<RecordType>? {
//		get async {
//			do {
//				guard let id, !id.isEmpty else { return nil }
//				if let existing = allCache?.first(where: { $0.id == id }) { return existing }
//				let raw = try await base.document(id).getDocument()
//				guard let data = raw.data() else { return nil }
//				let doc = try document(from: data)
//				await doc.awakeFromFetch()
//				return doc
//			} catch {
//			//	print("Failed to get \(RecordType.self): \(error)")
//				return nil
//			}
//		}
//	}
//	
//	public subscript(sync id: String?) -> SpotDocument<RecordType>? {
//		get {
//			allCache?.first { $0.id == id }
//			
//		}
//	}
}
