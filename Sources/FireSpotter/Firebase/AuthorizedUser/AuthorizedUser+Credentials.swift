//
//  AuthorizedUser+Credentials.swift
//  
//
//  Created by Ben Gottlieb on 9/22/23.
//

import FirebaseCore
import FirebaseAuth
import AuthenticationServices
import Suite
import CloudKit
import Journalist

extension AuthorizedUser {
	func store(userInfo: SpotUserRecord) {
		self.user?.record = userInfo
//		addToken(token: self.apnsToken, deviceID: self.deviceID)
//		asyncReport { try await self.saveUser() }
		saveUserDefaults()
	}
}

extension AuthorizedUser.UI {
	var authorizedUser: AuthorizedUser { AuthorizedUser.instance }
	var autoICloudEmailSuffix: String { "@auto.icloud.com" }
	
	public func signOut() async {
		user = nil
		await AuthorizedUser.instance.handleAuthStateChanged(for: nil)
		do {
			try Auth.auth().signOut()
		} catch {
			FireSpotterLogger.error("Failed to sign out of Firebase: \(error, privacy: .public)")
		}
		//userDefaults.removeObject(forKey: userDefaultsKey)
	}
	
	public func signInWithICloud(containerID: String? = nil) async throws {
		let userID: String
		
		if let preloadedCloudkitID = ProcessInfo.string(for: "preloadedCloudKit") {
			userID = preloadedCloudkitID
		} else {
			let container = CKContainer.container(forID: containerID)
			userID = try await container.userRecordID
		}
		let defaultPassword = "ERTYHNBSD M<FOP)S(*&(^*%$RFGHVJBNMSD<MF:KLOIP"
		let email = userID + autoICloudEmailSuffix
		
		do {
			try await signIn(email: email, password: defaultPassword, logErrors: false)
		} catch {
			if (error as NSError).domain == "FIRAuthErrorDomain", (error as NSError).code == 17999 {
				try await register(email: email, password: defaultPassword)
				return
			}
			FireSpotterLogger.error("Failed to sign in with iCloud: \(error, privacy: .public)")
			throw error
		}
	}

	public func signIn(credential cred: ASAuthorizationAppleIDCredential?, nonce: String) async throws {
		guard let appleIDToken = cred?.identityToken else { throw AuthorizedUser.AuthorizationError.noIdentityToken }
		guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { throw AuthorizedUser.AuthorizationError.badIdentityToken }

		let credential: AuthCredential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: cred?.fullName)

		let fbUser = try await Auth.auth().signIn(with: credential).user
		try await storeEmail(cred?.email, in: fbUser)
	}
	
	public func register(email: String, password: String, logErrors: Bool = true) async throws {
		do {
			let fbUser = try await Auth.auth().createUser(withEmail: email, password: password).user
			try await storeEmail(email, in: fbUser)
		} catch {
			if logErrors { FireSpotterLogger.error("*** Registration error: \(error, privacy: .public)") }
			throw error
		}
	}
	
	public func signIn(email: String, password: String, logErrors: Bool = true) async throws {
		do {
			let fbUser = try await Auth.auth().signIn(withEmail: email, password: password).user
			try await storeEmail(email, in: fbUser)
		} catch {
			if logErrors { FireSpotterLogger.warning("*** Sign In error: \(error, privacy: .public) \n\n\((error as NSError).userInfo, privacy: .public)") }
			throw error
		}
	}
	
	func storeEmail(_ email: String?, in fbUser: User) async throws {
		guard let email else { return }
		let user = await FirestoreManager.instance.users[create: fbUser.uid]
		user.record.emailAddress = email
		try await user.save()
	}

}
