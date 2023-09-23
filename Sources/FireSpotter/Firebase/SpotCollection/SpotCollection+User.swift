//
//  SpotCollection+User.swift
//
//
//  Created by Ben Gottlieb on 9/22/23.
//

import Foundation

public extension SpotCollection where RecordType: SpotUser {
	var currentUser: SpotDocument<RecordType> {
		get async {
			let user = await self[await AuthorizedUser.instance.currentUserID!]
			return user!
		}
	}
}
