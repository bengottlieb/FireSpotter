//
//  SpotUser.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Foundation

public struct SpotUser: SpotRecord {
	public var id = String.id(for: SpotUser.self)
	public var firstName: String?
	public var lastName: String?
	public var emailAddress: String?
	
	
	public static var minimalRecord = SpotUser(id: "")
	public static var emptyUser = SpotDocument(SpotUser(id: ""), collection: FirestoreManager.instance.users)
	
	@MainActor public static func newRecord() -> Self { fatalError("SpotUser.newRecord() should never be called") }
}
