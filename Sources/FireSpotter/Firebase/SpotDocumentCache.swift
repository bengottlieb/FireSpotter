//
//  File.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/2/25.
//

import Foundation

@FireSpotterActor class SpotDocumentCache<Record: SpotRecord> {
	var cache: [String: SpotDocument<Record>] = [:]
	let parent: SpotCollection<Record>
	
	nonisolated init(parent: SpotCollection<Record>) {
		self.parent = parent
	}
	
	subscript(id: String) -> SpotDocument<Record>? {
		get {
			cache[id]
		} set {
			cache[id] = newValue
		}
	}
	
	var count: Int { cache.count }
	
	func remove(_ record: Record) {
		cache.removeValue(forKey: record.id)
	}
	
	func remove(_ recordID: String) {
		cache.removeValue(forKey: recordID)
	}
	
	@discardableResult func store(_ record: Record) -> SpotDocument<Record> {
		if let current = self[record.id] {
			current.loadRecord(record)
			return current
		} else {
			let doc = SpotDocument(record, collection: parent)
			cache[record.id] = doc
			return doc
		}
	}
	
	func store(_ document: SpotDocument<Record>) {
		self[document.id] = document
	}
}
