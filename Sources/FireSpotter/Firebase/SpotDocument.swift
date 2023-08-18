//
//  FBDocument.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Journalist
import Suite

public class SpotDocument<Record: SpotRecord>: Equatable, ObservableObject, Identifiable, Hashable {	
	public typealias ID = String
	public var record: Record { willSet { objectWillChange.sendOnMain() }}
	public var json: [String: Any] { willSet { objectWillChange.sendOnMain() }}
	public var cachedValues: [String: Any] = [:]
	public var id: ID {
		get { record.id }
		set {
			record.id = newValue
			json["id"] = newValue
		}
	}
	
	public var recordBinding: Binding<Record> {
		Binding(
			get: { self.record },
			set: { new in self.record = new }
		)
	}
	
	public static func ==(lhs: SpotDocument, rhs: SpotDocument) -> Bool {
		lhs.record.id == rhs.record.id
	}
	
	public let collection: SpotCollection<Record>!
	public var path: String { collection.path + "/" + record.id }
	var isSaved = true
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(record)
	}
	
	public func childCollection<Element: SpotRecord>(at name: String, kind: FirebaseCollectionKind<Element>) -> SpotCollection<Element> {
		let collection = FirestoreManager.instance.collection(at: path + "/" + name, of: kind, parent: self)
		return collection
	}
	
	public subscript(key: String) -> Any? {
		get { json[key] }
		set { json[key] = newValue }
	}
	
	func merge(_ newJSON: JSONDictionary) {
		json.merge(newJSON) { value1, value2 in
			value2
		}
	}
	
	func awakeFromFetch() async {
		await record.awakeFromFetch(in: self)
	}
	
	@MainActor public func update() async -> Bool {
		do {
			guard !id.isEmpty, let raw = try await collection.base.document(id).getDocument().data() else { return false }
			
			if !raw.isEqual(to: json) {
				record = try Record.loadJSON(dictionary: raw, using: .firebaseDecoder)
				json = raw
				await awakeFromFetch()
				return true
			}
		} catch {
			print("Failed to update \(self): \(error)")
		}
		return false
	}
	
	var jsonPayload: [String: Any] {
		var base = json
		let raw = (try? record.asJSON()) ?? [:]
		
		for (key, value) in raw {
			base[key] = value
		}
		return base
	}
	
	init(_ subject: Record, collection: SpotCollection<Record>?, json: [String: Any]? = nil, isSaved: Bool = true) {
		assert(Gestalt.isInPreview || collection != nil, "Cannot use a nil collection for a SpotDocument<\(Record.self)>")
		self.record = subject
		self.collection = collection
		self.json = json ?? (try? subject.asJSON()) ?? [:]
		self.isSaved = isSaved
	}
	
	public func save() {
		Task { await self.saveAsync() }
	}
	
	public func saveAsync() async {
		await report { try await self.collection.save(self) }
	}
	
	public func delete() async {
		do {
			try await collection.remove(self)
		} catch {
			print("Failed to delete \(self)")
		}
	}
	
	public func loadChanges(_ json: [String: Any]) async {
		if let manager = FirestoreManager.instance.recordManager, await !manager.shouldChange(object: record, with: json) { return }
		
		do {
			record = try Record.loadJSON(dictionary: json, using: .firebaseDecoder)
		} catch {
			print("Failed to re-constitute the subject: \(error)")
		}
		
		self.json = json
	}
}

extension SpotDocument: Comparable where Record: Comparable {
	public static func <(lhs: SpotDocument, rhs: SpotDocument) -> Bool {
		lhs.record < rhs.record
	}
}
