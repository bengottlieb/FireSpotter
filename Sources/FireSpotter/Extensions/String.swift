//
//  String.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Suite

extension String {
	public static func id(prefix: String) -> String {
		let id = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
		return prefix + "-" + id
	}

	public static func id(for record: any SpotRecord.Type) -> String {
		.id(prefix: String(describing: record))
	}
	
	static func randomNonce(length: Int = 32) -> String {
		precondition(length > 0)
		let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
		var result = ""
		var remainingLength = length
		
		while remainingLength > 0 {
			let randoms: [UInt8] = (0 ..< 16).map { _ in
				var random: UInt8 = 0
				let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
				if errorCode != errSecSuccess {
					fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
				}
				return random
			}
			
			randoms.forEach { random in
				if remainingLength == 0 { return }
				
				if random < charset.count {
					result.append(charset[Int(random)])
					remainingLength -= 1
				}
			}
		}
		
		return result
	}
	
}

