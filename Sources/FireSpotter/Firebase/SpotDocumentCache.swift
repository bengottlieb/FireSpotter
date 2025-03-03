//
//  File.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/2/25.
//

import Foundation

@FireSpotterActor class SpotDocumentCache<Record: SpotRecord> {
	var cache: [String: SpotDocument<Record>] = [:]
	
	nonisolated init() { }
	
	subscript(id: String) -> SpotDocument<Record>? {
		get {
			cache[id]
		} set {
			cache[id] = newValue
		}
	}
	
	func store(_ document: SpotDocument<Record>, for id: String) {
		self[id] = document
	}
}
