//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 3/18/23.
//

import Foundation

extension SpotUser {
	@discardableResult mutating func addToken(token: String?, deviceID: String?) -> Bool {
		guard let token, let deviceID else { return false }
		var tokens = apnsTokens ?? []
		let info = APNSDeviceInfo(token: token, deviceID: deviceID)
		
		if tokens.contains(info) { return false }
		if let index = tokens.firstIndex(where: { $0.deviceID == deviceID }) {
			tokens[index].token = token
			apnsTokens = tokens
			return true
		}
		
		if let index = tokens.firstIndex(where: { $0.token == token }) {
			tokens[index].deviceID = deviceID
			apnsTokens = tokens
			return true
		}
		
		self.apnsTokens = tokens + [info]
		return true
	}
	
	struct APNSDeviceInfo: Codable, Equatable, Sendable, Hashable {
		var token: String
		var deviceID: String
	}

}
