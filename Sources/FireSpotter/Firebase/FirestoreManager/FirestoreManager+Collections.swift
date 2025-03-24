//
//  FirestoreManager+Collections.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/4/25.
//

import Foundation

public extension FirestoreManager {
	fileprivate static var collections: [String: Box] = [:]
	
	static func collection(for path: String) -> GenericSpotCollection? {
		collections[path]?.collection
	}
	
    @FireSpotterActor static func collection<T>(for path: String, monitorChanges: Bool = false, query: SpotCollectionQueryBuilder? = nil) -> SpotCollection<T> {
		if let boxed = collections[path]?.collection, let existing: SpotCollection<T> = boxed as? SpotCollection<T> {
            return existing
        }
		
        let new: SpotCollection<T> = SpotCollection(path, recordType: T.self, monitorChanges: monitorChanges || query != nil, query: query)
		collections[path] = Box(new)
		return new
	}
	

	@FireSpotterActor static func loadedCollection<T>(for path: String) async -> SpotCollection<T> {
		if let boxed = collections[path]?.collection, let existing: SpotCollection<T> = boxed as? SpotCollection<T> { return existing }
		
		let new: SpotCollection<T> = await SpotCollection(path, recordType: T.self)
		collections[path] = Box(new)
		return new
	}
}

fileprivate class Box {
	weak var collection: GenericSpotCollection?
	
	init(_ collection: GenericSpotCollection) {
		self.collection = collection
	}
}

