//
//  AuthorizedUser.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import FirebaseCore
import FirebaseAuth
import AuthenticationServices
import Suite

@MainActor public class AuthorizedUser: ObservableObject {
	public static let instance = AuthorizedUser()
	
	enum AuthorizationError: Error { case unknown, noIdentityToken, badIdentityToken }
	
	public var user: SpotDocument<SpotUser>?
	public var fbUser: User?
	public var userDefaults = UserDefaults.standard
	
	let userDefaultsKey = "firespotter_stored_user"
	
	init() {
		fbUser = Auth.auth().currentUser
		if let data = userDefaults.data(forKey: userDefaultsKey), let user = try? SpotUser.loadJSON(data: data) {
			self.user = SpotDocument(user, collection: FirestoreManager.instance.users)
		}
	}
	
	public var isSignedIn: Bool {
		get { user != nil }
		set {
			if isSignedIn, !newValue {
				Task { await signOut() }
			}
		}
	}
	
	func createUser() async {
		guard let fb = fbUser else { return }
		let user = SpotUser(id: fb.uid)
		
		self.user = try? await FirestoreManager.instance.users.save(user)
		try? userDefaults.set(self.user?.subject.asJSONData(), forKey: userDefaultsKey)
	}
	
	public func signOut() async {
		user = nil
		fbUser = nil
		userDefaults.removeObject(forKey: userDefaultsKey)
		objectWillChange.send()
	}
	
	func store(user: User, completion: @escaping () -> Void) {
		self.fbUser = user
		Task {
			await self.createUser()
			self.objectWillChange.send()
			completion()
		}
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
						self.user?.subject.firstName = cred?.fullName?.givenName
						self.user?.subject.lastName = cred?.fullName?.familyName
						self.user?.subject.emailAddress = cred?.email
						self.user?.save()
						continuation.resume()
					}
				} else {
					continuation.resume(throwing: AuthorizationError.unknown)
				}
			}
		}
	}
	
	public func register(email: String, password: String) async throws {
		let _: Void = try await withCheckedThrowingContinuation { continuation in
			Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
				if let error {
					print("*** Registration error: \(error)")
					continuation.resume(throwing: error)
				} else if let user = authResult?.user {
					self.store(user: user) {
						self.user?.subject.emailAddress = email
						self.user?.save()
						continuation.resume()
					}
				} else {
					continuation.resume(throwing: AuthorizationError.unknown)
				}
			}
		}
	}
	
	public func signIn(email: String, password: String) async throws {
		let _: Void = try await withCheckedThrowingContinuation { continuation in
			Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
				if let error {
					print("*** Sign In error: \(error)")
					continuation.resume(throwing: error)
				} else if let user = authResult?.user {
					self.store(user: user) {
						self.user?.subject.emailAddress = email
						self.user?.save()
						continuation.resume()
					}
				} else {
					continuation.resume(throwing: AuthorizationError.unknown)
				}
			}
		}
		
	}
}
