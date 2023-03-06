//
//  FirebaseCollectionKind.swift
//  PGRGuide
//
//  Created by Ben Gottlieb on 3/5/23.
//

import Suite

struct FirebaseCollectionInfo {
	let name: String
	let minimal: [String: Any]
	
	init<Element>(_ kind: FirebaseCollectionKind<Element>) throws {
		name = kind.name
		minimal = try kind.contentType.minimalRecord.asJSON()
	}
}

public struct FirebaseCollectionKind<Content: SpotRecord> {
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

public let firebaseUserCollectionKind = FirebaseCollectionKind("users", contents: SpotUser.self)
public let firebaseMetaCollectionKind = FirebaseCollectionKind("meta", contents: SpotMeta.self)
