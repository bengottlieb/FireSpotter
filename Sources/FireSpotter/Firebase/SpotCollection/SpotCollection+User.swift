//
//  SpotCollection+User.swift
//
//
//  Created by Ben Gottlieb on 9/22/23.
//

import Foundation

public extension SpotCollection where RecordType: SpotUser {
	@MainActor func setupCurrentUser() async throws -> SpotDocument<RecordType>? {
		guard AuthorizedUser.instance.isSignedIn, let id = AuthorizedUser.instance.currentUserID else { return nil }
		if let user = await currentUser { return user }
		
		let newUser = new(withID: id, addNow: true)
		try await newUser.saveAsync()
		return newUser
	}

	var currentUser: SpotDocument<RecordType>? {
		get async {
			guard let id = await AuthorizedUser.instance.currentUserID else { return nil }
			let user = await self[id]
			return user
		}
	}
}
