//
//  File.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/2/25.
//

import Foundation

class SpotDocumentCache<Record: SpotRecord> {
	var cache: [String: SpotDocument<Record>] = [:]
	
	subscript(id: String) -> SpotDocument<Record>? {
		get {
			cache[id]
		} set {
			cache[id] = newValue
		}
	}
}
