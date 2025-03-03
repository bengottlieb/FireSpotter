//
//  File.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/2/25.
//

import Foundation
import FirebaseAuth

extension AuthorizedUser {
	func setupUserRecord(_ user: User) async {
		let spotUser = await FirestoreManager.instance.users[create: user.uid]
		
//		if spotUser["createdAt"] == nil {
//			spotUser["createdAt"] = Date.now
//		}
		self.user = spotUser
		do {
			try await spotUser.save()
		} catch {
			FireSpotterLogger.error("Failed to save user: \(error, privacy: .public)")
		}
	}
}
