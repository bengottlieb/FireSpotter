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
	
	public enum CollectionKind: String { case users }
	
	let db = Firestore.firestore()
	
	public subscript<Element: FirebaseCollectionElement>(kind: FirebaseCollectionKind<Element>) -> SpotCollection<Element> {
		let col = db.collection(kind.name)
		return SpotCollection(col, kind: Element.self)
	}
	
//	public subscript<Element: Codable & Identifiable>(collection: CollectionKind) -> SpotCollection<Element> {
//		let col = db.collection(collection.rawValue)
//		return SpotCollection(col, kind: Element.self)
//	}
}

public extension FirestoreManager {
	var users: SpotCollection<SpotUser> { self[FirebaseUsersCollectionKind]}
}
