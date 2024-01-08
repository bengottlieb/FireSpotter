//
//  AuthorizedUser.swift
//  
//
//  Created by Ben Gottlieb on 9/22/23.
//

import Foundation
import FirebaseFirestore
import Journalist

extension AuthorizedUser {
	enum AuthUserError: Error { case notSignedIn, userNotFound }
	
	func fetchUser() async throws {
		guard isSignedIn, let id = currentUserID else { return }
		let userPath = "users/\(id)"
		
		if let json = (try? await Firestore.firestore().document(userPath).getDocument().data()) {
			self.user = .init(try .loadJSON(dictionary: json), collection: FirestoreManager.users)
		}
		saveUserDefaults()
	}
	
	func saveUser() async throws {
		guard let id = currentUserID else { throw AuthUserError.userNotFound }
		let userPath = "users/\(id)"
		
		var json = (try? await Firestore.firestore().document(userPath).getDocument().data()) ?? [:]
		
		
		for (key, value) in user.json {
			json[key] = value
		}
		
		try await Firestore.firestore().document(userPath).setData(json)
	}
	

}

extension AuthorizedUser {
	@discardableResult func addToken(token: String?, deviceID: String?) -> Bool {
		guard let token, let deviceID else { return false }
		var tokens = user.record.apnsTokens ?? []
		let info = APNSDeviceInfo(token: token, deviceID: deviceID)
		
		if tokens.contains(info) { return false }
		if let index = tokens.firstIndex(where: { $0.deviceID == deviceID }) {
			tokens[index].token = token
			user.record.apnsTokens = tokens
		} else if let index = tokens.firstIndex(where: { $0.token == token }) {
			tokens[index].deviceID = deviceID
			user.record.apnsTokens = tokens
		} else {
			user.record.apnsTokens = tokens + [info]
		}
		asyncReport { try await self.saveUser() }

		return true
	}
}
