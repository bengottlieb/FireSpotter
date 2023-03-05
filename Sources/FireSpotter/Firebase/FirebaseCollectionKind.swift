//
//  FirebaseCollectionKind.swift
//  PGRGuide
//
//  Created by Ben Gottlieb on 3/5/23.
//

import Foundation

public typealias FirebaseCollectionElement = Codable & Identifiable & Equatable

public struct FirebaseCollectionKind<Content: FirebaseCollectionElement> {
	public let name: String
	public let contentType: Content.Type
	
	public init(_ name: String, contents: Content.Type) {
		self.name = name
		self.contentType = contents
	}
	
}

public let FirebaseUsersCollectionKind = FirebaseCollectionKind("users", contents: SpotUser.self)
