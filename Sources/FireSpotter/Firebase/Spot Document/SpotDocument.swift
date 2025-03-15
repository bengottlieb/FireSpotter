//
//  FBDocument.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Foundation
import FirebaseFirestore
import Journalist
import Suite

@dynamicMemberLookup
public final class SpotDocument<Record: SpotRecord>: ObservableObject, Identifiable, Hashable {
	typealias RecordCollection = SpotCollection<Record>
	public typealias ID = String
	public var record: Record { willSet { objectWillChange.sendOnMain() }}
	public var json: [String: Any] { willSet { objectWillChange.sendOnMain() }}
	public var snapshot: Record?
	var listener: ListenerRegistration?
	var isDirty = false
	
	public var cachedValues: [String: Any] = [:]
	public var id: ID {
		get { record.id }
		set {
			record.id = newValue
			self["id"] = newValue
		}
	}
	
	deinit {
		stopObserving()
	}
	
	public subscript<T>(dynamicMember keyPath: WritableKeyPath<Record, T>) -> T {
		get { record[keyPath: keyPath] }
		set {
			if isEqual(record[keyPath: keyPath], newValue) { return }
			record[keyPath: keyPath] = newValue
			isDirty = true
		}
	}
	
	public subscript<T>(dynamicMember keyPath: KeyPath<Record, T>) -> T {
		get { record[keyPath: keyPath] }
	}
	
	public subscript(key: String) -> Any? {
		get { json[key] }
		set {
			if let newValue, let oldValue = json[key], isEqual(oldValue, newValue) { return }
			if newValue == nil, json[key] == nil { return }
			json[key] = newValue
			isDirty = true
		}
	}
	
	func loadRecord(_ record: Record) {
		if record == self.record { return }
		self.record = record
		isDirty = true
		objectWillChange.sendOnMain()
	}

	func loadSnapshot(_ doc: DocumentSnapshot?) {
		if let json = doc?.data() {
			self.loadJSON(json)
		}
	}
	
	func loadJSON(_ newJSON: [String: Any]) {
		if let record = try? Record.loadJSON(dictionary: newJSON.convertingFirebaseTimestampsToDates()), record != self.record {
			self.record = record
			isDirty = true
		}
		for (key, value) in newJSON {
			self[key] = value
		}
		
		self.objectWillChange.sendOnMain()
	}
	
	public static var empty: SpotDocument<Record> {
		.init(Record.empty, collection: .init(empty: Record.self))
	}
	
	init(_ record: Record, collection: RecordCollection) {
		self.record = record
		self.collection = collection
		self.json = try! record.asJSON()
	}
	
	public let collection: SpotCollection<Record>!
	public var path: String { collection.path + "/" + record.id }
	var isSaved = true
	
	public func hash(into hasher: inout Hasher) {
        hasher.combine(record.id)
        hasher.combine(String(describing: Record.self))
	}
//	
//	public func childCollection<Element: SpotRecord>(at name: String, kind: FirebaseCollectionKind<Element>) -> SpotCollection<Element> {
//		let collection = FirestoreManager.instance.collection(at: path + "/" + name, of: kind, parent: self)
//		return collection
//	}
//	
//
//	func merge(_ newJSON: JSONDictionary) {
//		json.merge(newJSON) { value1, value2 in
//			value2
//		}
//	}
//	
//	func awakeFromFetch() async {
//		await record.awakeFromFetch(in: self)
//	}
//	
//	public var isTrackingChanges: Bool { snapshot != nil }
//	
//	public func startTrackingChanges() {
//		snapshot = record
//	}
//	
//	public func revertChanges() {
//		guard let snapshot else {
//			FireSpotterLogger.warning("Trying to revert changes, but no snapshot is present. Call `startTrackingChanges()` before editing begins")
//			return
//		}
//		
//		record = snapshot
//	}
//	
//	public func stopTrackingChanges() {
//		snapshot = nil
//	}
//	
//	public var hasChanges: Bool {
//		guard let snapshot else {
//			FireSpotterLogger.info("Checking for changes, but no snapshot is present. Call `startTrackingChanges()` before editing begins")
//			return true
//		}
//		
//		return snapshot != record
//	}
//	
//	@MainActor public func update() async -> Bool {
//		do {
//			guard !id.isEmpty, let raw = try await collection.base.document(id).getDocument().data() else { return false }
//			
//			if !raw.isEqual(to: json) {
//				record = try Record.loadJSON(dictionary: raw, using: .firebaseDecoder)
//				json = raw
//				await awakeFromFetch()
//				return true
//			}
//		} catch {
//			FireSpotterLogger.error("Failed to update \(self, privacy: .public): \(error, privacy: .public)")
//		}
//		return false
//	}
//	
	var jsonPayload: [String: Any] {
		var base = json
		let raw = (try? record.asJSON()) ?? [:]
		
		for (key, value) in raw {
			base[key] = value
		}
		return base
	}
//	
//	public init(_ subject: Record, collection: SpotCollection<Record>?, json: [String: Any]? = nil, isSaved: Bool = true) {
//		assert(Gestalt.isInPreview || collection != nil, "Cannot use a nil collection for a SpotDocument<\(Record.self)>")
//		self.record = subject
//		self.collection = collection
//		self.json = json ?? (try? subject.asJSON()) ?? [:]
//		self.isSaved = isSaved
//	}
//	
//	public func save() throws {
//		if id.isEmpty { throw SpotRecordError.noRecordID }
//		Task { try await self.saveAsync() }
//	}
//	
	public func save() async throws {
		if !isDirty { return }
		if id.isEmpty { throw SpotRecordError.noRecordID }
		if snapshot != nil { snapshot = record }
		await report {
			try await self.collection.save(self)
			self.isDirty = false
		}
	}
    
    public func reportedSave() {
        Task {
            do {
                try await save()
            } catch {
                print("Failed to save \(self): \(error)")
            }
        }
    }
//
//	public func delete() async {
//		do {
//			try await collection.remove(self)
//		} catch {
//			FireSpotterLogger.error("Failed to delete \(self, privacy: .public)")
//		}
//	}
//	
//	public func loadChanges(_ json: [String: Any]) async {
//		if let manager = FirestoreManager.instance.recordManager, await !manager.shouldChange(object: record, with: json) { return }
//		
//		do {
//			record = try Record.loadJSON(dictionary: json, using: .firebaseDecoder)
//		} catch {
//			FireSpotterLogger.error("Failed to re-constitute the subject: \(error, privacy: .public)")
//		}
//		
//		self.json = json
//	}
}


extension SpotDocument: Comparable where Record: Comparable {
	public static func <(lhs: SpotDocument, rhs: SpotDocument) -> Bool {
		lhs.record < rhs.record
	}
}

extension SpotDocument: Equatable where Record: Equatable {
	public static func ==(lhs: SpotDocument, rhs: SpotDocument) -> Bool {
		lhs.record == rhs.record
	}
}

extension SpotDocument: CustomStringConvertible where Record: CustomStringConvertible {
	public var description: String { record.description }
}

//extension SpotDocument {
//	public static var sample: Self {
//		self.init(Record.init(), collection: nil)
//	}
//}
