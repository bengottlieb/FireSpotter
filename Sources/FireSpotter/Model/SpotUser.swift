//
//  SpotUser.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Foundation

public struct SpotUser: SpotRecord {
	public var id: String = UUID().uuidString
	public var firstName: String?
	public var lastName: String?
	public var emailAddress: String?
	
	
	public static var minimalRecord = SpotUser(id: "")
}
