//
//  APNSDeviceInfo.swift
//  
//
//  Created by Ben Gottlieb on 9/22/23.
//

import Foundation

public struct APNSDeviceInfo: Codable, Equatable, Sendable, Hashable {
	public var token: String
	public var deviceID: String
}
