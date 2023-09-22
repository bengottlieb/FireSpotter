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

extension AuthorizedUser {
	var autoICloudEmailSuffix: String { "@auto.icloud.com" }
	
	public func signInWithICloud() async throws {
		let userID = try await CKContainer.userRecordID
		let defaultPassword = "ERTYHNBSD M<FOP)S(*&(^*%$RFGHVJBNMSD<MF:KLOIP"
		let email = userID + autoICloudEmailSuffix
		
		do {
			try await signIn(email: email, password: defaultPassword, logErrors: false)
		} catch {
			if (error as NSError).domain == "FIRAuthErrorDomain", (error as NSError).code == 17999 {
				try await register(email: email, password: defaultPassword)
				return
			}
			print(error)
			throw error
		}
	}

	public func signOut() async {
		user = SpotUser.emptyUser
		fbUser = nil
		do {
			try Auth.auth().signOut()
		} catch {
			print("Failed to sign out of Firebase: \(error)")
		}
		userDefaults.removeObject(forKey: userDefaultsKey)
		objectWillChange.sendOnMain()
		Notifications.didSignOut.notify()
	}
	
	public func signIn(credential cred: ASAuthorizationAppleIDCredential?, nonce: String) async throws {
		guard let appleIDToken = cred?.identityToken else { throw AuthorizationError.noIdentityToken }
		guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { throw AuthorizationError.badIdentityToken }

		let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
		let _: Void = try await withCheckedThrowingContinuation { continuation in
			Auth.auth().signIn(with: credential) { (authResult, error) in
				if let error {
					continuation.resume(throwing: error)
				} else if let user = authResult?.user {
					self.store(user: user) {
						self.user.record.firstName = cred?.fullName?.givenName
						self.user.record.lastName = cred?.fullName?.familyName
						self.user.record.emailAddress = cred?.email
						self.user.record.addToken(token: self.apnsToken, deviceID: self.deviceID)
						self.user.save()
						Task {
							await FirestoreManager.instance.recordManager?.didSignIn()
							Notifications.didSignIn.notify()
							continuation.resume()
						}
					}
				} else {
					continuation.resume(throwing: AuthorizationError.unknown)
				}
			}
		}
	}
	
	public func register(email: String, password: String, logErrors: Bool = true) async throws {
		let _: Void = try await withCheckedThrowingContinuation { continuation in
			Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
				if let error {
					if logErrors { print("*** Registration error: \(error)") }
					continuation.resume(throwing: error)
				} else if let user = authResult?.user {
					self.store(user: user) {
						self.user.record.emailAddress = email
						self.user.record.addToken(token: self.apnsToken, deviceID: self.deviceID)
						self.user.save()
						continuation.resume()
					}
				} else {
					continuation.resume(throwing: AuthorizationError.unknown)
				}
			}
		}
	}
	
	public func signIn(email: String, password: String, logErrors: Bool = true) async throws {
		let _: Void = try await withCheckedThrowingContinuation { continuation in
			Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
				if let error {
					if logErrors { print("*** Sign In error: \(error) \n\n\((error as NSError).userInfo)") }
					continuation.resume(throwing: error)
				} else if let user = authResult?.user {
					self.store(user: user) {
						self.user.record.emailAddress = email
						self.user.record.addToken(token: self.apnsToken, deviceID: self.deviceID)
						self.user.save()
						continuation.resume()
					}
				} else {
					continuation.resume(throwing: AuthorizationError.unknown)
				}
			}
		}
		
	}

}
