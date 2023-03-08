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

public class SpotDocument<Subject: SpotRecord>: ObservableObject, Identifiable where Subject.ID == String {
	@Published public var subject: Subject
	@Published public var json: [String: Any]
	public var id: String {
		get { subject.id }
		set {
			subject.id = newValue
			json["id"] = newValue
		}
	}
	
	let collection: SpotCollection<Subject>
	public var path: String { collection.path + "/" + subject.id }
	
	public func childCollection<Element: SpotRecord>(at name: String, of elem: Element.Type) -> SpotCollection<Element> {
		FirestoreManager.instance.collection(at: path + "/" + name, of: elem)
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
	
	@MainActor public func update() async -> Bool {
		do {
			guard let raw = try await collection.base.document(id).getDocument().data() else { return false }
			
			if !raw.isEqual(to: json) {
				subject = try Subject.loadJSON(dictionary: raw)
				json = raw
				return true
			}
		} catch {
			print("Failed to update \(self): \(error)")
		}
		return false
	}
	
	var jsonPayload: [String: Any] {
		var base = json
		let raw = (try? subject.asJSON()) ?? [:]
		
		for (key, value) in raw {
			base[key] = value
		}
		return base
	}
	
	init(_ subject: Subject, collection: SpotCollection<Subject>, json: [String: Any]? = nil) {
		self.subject = subject
		self.collection = collection
		self.json = json ?? (try? subject.asJSON()) ?? [:]
	}
	
	public func save() {
		Task { await self.saveAsync() }
	}
	
	public func saveAsync() async {
		await report { try await self.collection.save(self) }
	}
}
