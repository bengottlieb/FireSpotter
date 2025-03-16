//
//  PushTokenInfo.swift
//  
//
//  Created by Ben Gottlieb on 9/22/23.
//

import Foundation

public struct PushTokenInfo: Codable, Equatable, Sendable, Hashable {
	public var deviceID: String
	public var token: String
}
