//
//  ObjectCache.swift
//  PGRGuide
//
//  Created by Ben Gottlieb on 7/7/23.
//

import Foundation
import Combine

actor ObjectCache<Element: AnyObject> {
	var cache: [String: Element] = [:]
	
	func record(forKey key: String) -> Element? {
		cache[key]
	}
	
	func set(_ record: Element, forKey key: String) {
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
	
	nonisolated let inMemoryCache = CurrentValueSubject<[String: Element], Never>([:])
}
