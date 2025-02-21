//
//  FirebaseCollectionKind.swift
//
//  Created by Ben Gottlieb on 3/5/23.
//

import Suite

@globalActor public actor FirestoreActor : GlobalActor {
	public static let shared = FirestoreActor()
}


struct FirebaseCollectionInfo: Sendable {
	let name: String
	let minimal: [String: Sendable]
	
	init<Element>(_ kind: FirebaseCollectionKind<Element>) throws {
		name = kind.name
		minimal = try kind.contentType.minimalRecord.asJSON()
	}
}

public struct FirebaseCollectionKind<Content: SpotRecord>: Sendable {
	public let name: String
	public let contentType: Content.Type
	
	public init(_ name: String, contents: Content.Type) {
		self.name = name
		self.contentType = contents
	}
	
}

extension FirebaseCollectionKind {
	var isMeta: Bool { name == "meta" }
}

public let firebaseMetaCollectionKind = FirebaseCollectionKind("meta", contents: SpotMeta.self)
public let firebaseUserCollectionKind = FirebaseCollectionKind("users", contents: SpotUserRecord.self)
