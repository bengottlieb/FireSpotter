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
	
	public enum CollectionKind: String { case users }
	
	let db = Firestore.firestore()
	var kinds: [String: FirebaseCollectionInfo] = ["meta": try! .init(firebaseMetaCollectionKind)]
	
	init() {
		Task {
			try await register(kind: firebaseUserCollectionKind)
		}
	}
	
	func register<Element>(kind: FirebaseCollectionKind<Element>) async throws {
		kinds[kind.name] = try .init(kind)
		
		if checkSchemas, !kind.isMeta {
			let existing = await meta[kind.name, .init(id: kind.name)]
			if let diffs = await existing.modelDifferences(json: try Element.minimalRecord.asJSON()) {
				fatalError("Data type changed: \(Element.self), diffs: \(diffs.description)")
			}
		}
	}
	
	public subscript<Element: SpotRecord>(kind: FirebaseCollectionKind<Element>) -> SpotCollection<Element> {
		let col = db.collection(kind.name)
		return SpotCollection(col, kind: Element.self)
	}
	
//	public subscript<Element: Codable & Identifiable>(collection: CollectionKind) -> SpotCollection<Element> {
//		let col = db.collection(collection.rawValue)
//		return SpotCollection(col, kind: Element.self)
//	}
}

public extension FirestoreManager {
	var users: SpotCollection<SpotUser> { self[firebaseUserCollectionKind]}
	var meta: SpotCollection<SpotMeta> { self[firebaseMetaCollectionKind]}
}
