//
//  FirestoreManager.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

public class FirestoreManager {
	public static let instance = FirestoreManager()
	public var checkSchemas = true
	
	public var recordManager: SpotRecordManager?
	
	public var cache: [String: CollectionWrapper] = [:]
	let db = Firestore.firestore()
	var kinds: [String: FirebaseCollectionInfo] = ["meta": try! .init(firebaseMetaCollectionKind)]
	
	init() {
		if ProcessInfo.bool(for: "offline") { goOffline() }
	}
	
	public func configure(reduceLogging: Bool = true) {
		if reduceLogging { FirebaseConfiguration.shared.setLoggerLevel(.min) }
		FirebaseApp.configure()
	}
	
	func goOffline() {
		db.disableNetwork()
	}
	
	public var latestBuildNumber: Int? {
		get async {
			if let info = await Self.meta["info"] {
				return info.json["latest_build"] as? Int
			}
			return nil
		}
	}
	
	func register<Element>(kind: FirebaseCollectionKind<Element>) async throws {
		kinds[kind.name] = try .init(kind)
		
		if checkSchemas, !kind.isMeta {
			let existing = await Self.meta[kind.name, .init(id: kind.name)]
			if let diffs = await existing.modelDifferences(json: try Element.minimalRecord.asJSON()) {
				fatalError("Data type changed: \(Element.self), diffs: \(diffs.description)")
			}
		}
	}
	
	public func collection<Element: SpotRecord>(at path: String, of kind: FirebaseCollectionKind<Element>) -> SpotCollection<Element> {
		
		if let cached = cache[path] as? SpotCollection<Element> { return cached }
		
		let col = SpotCollection(db.collection(path), kind: kind, parent: nil)
		cache[path] = col
		return col
	}
	
	public func collection<Element: SpotRecord, Parent: SpotRecord>(at path: String, of kind: FirebaseCollectionKind<Element>, parent: SpotDocument<Parent>) -> SpotCollection<Element> {
		
		if let cached = cache[path] as? SpotCollection<Element> { return cached }
		
		let col = SpotCollection(db.collection(path), kind: kind, parent: parent)
		cache[path] = col
		return col
	}
	
	public subscript<Element: SpotRecord>(kind: FirebaseCollectionKind<Element>) -> SpotCollection<Element> {

		if let cached = cache[kind.name] as? SpotCollection<Element> { return cached }

		let col = SpotCollection(db.collection(kind.name), kind: kind.self)
		cache[kind.name] = col
		return col
	}
	
	public func moveCollection(at oldPath: String, to newPath: String) throws {
		guard let collection = cache[oldPath] else { return }
		
		try collection.changePath(to: newPath)
		cache.removeValue(forKey: oldPath)
		cache[newPath] = collection
	}
}

public extension FirestoreManager {
	@MainActor static var meta: SpotCollection<SpotMeta> = FirestoreManager.instance[firebaseMetaCollectionKind]
}

struct AnySpotCollection {
	var boxed: Any
	
	func collection<Element: SpotRecord>() -> SpotCollection<Element>? {
		boxed as? SpotCollection<Element>
	}
}
