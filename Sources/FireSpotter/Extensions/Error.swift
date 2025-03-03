//
//  File.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/2/25.
//

import Foundation

extension Error {
	public var firebaseDescription: String {
		localizedDescription
//		let userInfo = (self as NSError).userInfo
//		print(userInfo.keys)
//		print(self)
//		guard let info = userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any] else { return localizedDescription }
//		print(info)
//		
//		return "firebase error"
	}
}
