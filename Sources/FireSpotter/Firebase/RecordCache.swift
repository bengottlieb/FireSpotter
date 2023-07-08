//
//  SpotCollection.RecordCache.swift
//  PGRGuide
//
//  Created by Ben Gottlieb on 7/7/23.
//

import Foundation
import Combine

actor RecordCache<Element: SpotRecord> {
	var cache: [String: SpotDocument<Element>] = [:]
	
	func record(forKey key: String) -> SpotDocument<Element>? {
		cache[key]
	}
	
	func set(_ record: SpotDocument<Element>, forKey key: String) {
		cache[key] = record
		inMemoryCache.send(cache)
	}
	
	func removeRecord(forKey key: String) {
		cache.removeValue(forKey: key)
		inMemoryCache.send(cache)
	}
	
	func clear() {
		cache = [:]
		inMemoryCache.send(cache)
	}
	
	nonisolated let inMemoryCache = CurrentValueSubject<[String: SpotDocument<Element>], Never>([:])
}
