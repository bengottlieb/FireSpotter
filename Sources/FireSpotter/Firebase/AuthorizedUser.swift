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
	public struct Notifications {
		public static let didSignIn = Notification.Name("AuthorizedUser.didSignIn")
		public static let didSignOut = Notification.Name("AuthorizedUser.didSignOut")
	}
	
	public var user: SpotDocument<SpotUser> = SpotUser.emptyUser { didSet {
		setupUserCancellable()
	}}
	private var userCancellable: AnyCancellable?
	public var fbUser: User?
	public var userDefaults = UserDefaults.standard
	public var currentUserID: String? { fbUser?.uid }
	public var apnsToken: String? { didSet { didUpdateDeviceInfo() }}
	public var deviceID = Gestalt.deviceID { didSet { didUpdateDeviceInfo() }}
	
	var rawUserJSON: [String: Any] = [:]
	
	let userDefaultsKey = "firespotter_stored_user"
	
	init() {
		fbUser = Auth.auth().currentUser
		if let json = userDefaults.data(forKey: userDefaultsKey)?.jsonDictionary, let user = try? SpotUser.loadJSON(dictionary: json) {
			let newUser = FirestoreManager.instance.users.document(from: user, json: json)
			self.user = newUser
			Task { @MainActor in
				if await newUser.update() {
					saveUserDefaults()
					objectWillChange.send()
				}
				self.setupUserCancellable()
				if self.isSignedIn { Notifications.didSignIn.notify() }
			}
		}
		
	}
	
	func setupUserCancellable() {
		userCancellable = user.objectWillChange
			.receive(on: RunLoop.main)
			.sink {
				self.objectWillChange.send()
			}
	}
	
	public func save() {
		user.save()
		saveUserDefaults()
	}
	
	public subscript(key: String) -> Any? {
		get { user[key] }
		set {
			user[key] = newValue
			saveUserDefaults()
		}
	}
	
	func didUpdateDeviceInfo() {
		if isSignedIn, user.subject.addToken(token: apnsToken, deviceID: deviceID) {
			user.save()
		}
	}
	
	func saveUserDefaults() {
		try? userDefaults.set(self.user.jsonPayload.jsonData, forKey: userDefaultsKey)
		userDefaults.synchronize()
	}
	
	public var isSignedIn: Bool {
		get { !user.id.isEmpty }
		set {
			if isSignedIn, !newValue {
				Task { await signOut() }
			}
		}
	}
	
	public static var sample: AuthorizedUser {
		AuthorizedUser()
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
		objectWillChange.send()
		Notifications.didSignOut.notify()
	}
	
	func store(user fbUser: User, completion: @escaping () -> Void) {
		self.fbUser = fbUser
		let users = FirestoreManager.instance.users
		Task { @MainActor in 
			self.user = await users[fbUser.uid] ?? SpotDocument(SpotUser.newRecord(withID: fbUser.uid), collection: users)
			saveUserDefaults()

			self.objectWillChange.send()
			completion()
			Notifications.didSignIn.notify()
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
						self.user.subject.firstName = cred?.fullName?.givenName
						self.user.subject.lastName = cred?.fullName?.familyName
						self.user.subject.emailAddress = cred?.email
						self.user.subject.addToken(token: self.apnsToken, deviceID: self.deviceID)
						self.user.save()
						Notifications.didSignIn.notify()
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
						self.user.subject.emailAddress = email
						self.user.subject.addToken(token: self.apnsToken, deviceID: self.deviceID)
						self.user.save()
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
					print("*** Sign In error: \(error) \n\n\((error as NSError).userInfo)")
					continuation.resume(throwing: error)
				} else if let user = authResult?.user {
					self.store(user: user) {
						self.user.subject.emailAddress = email
						self.user.subject.addToken(token: self.apnsToken, deviceID: self.deviceID)
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
