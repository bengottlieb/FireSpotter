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
import Journalist
import Combine

public actor AuthorizedUser {
	nonisolated public static let instance = AuthorizedUser()
	
	enum AuthorizationError: Error { case unknown, noIdentityToken, badIdentityToken }
	public struct Notifications {
		public static let didSignIn = Notification.Name("AuthorizedUser.didSignIn")
		public static let didSignOut = Notification.Name("AuthorizedUser.didSignOut")
	}
	
	static nonisolated let currentUserIDSubject: CurrentValueSubject<String?, Never> = .init(nil)
	
	public static nonisolated var firebaseUserID: String? { Auth.auth().currentUser?.uid }
	public static nonisolated var currentUserID: String? {
		get { currentUserIDSubject.value }
		set { currentUserIDSubject.value = newValue }
	}
	
	private var userCancellable: AnyCancellable?
	public var fbUser: User? { didSet { updateFBUser() }}
	public var userDefaults = UserDefaults.standard
	public nonisolated var currentUserID: String? { Self.currentUserID }
	public var apnsToken: String? { didSet { Task { await didUpdateDeviceInfo() } }}
	
	public var user: SpotUserDocument?
	var rawUserJSON: [String: Any] = [:]
	
	let userDefaultsKey = "firespotter_stored_user"
	nonisolated public func setup() { }
	
	func updateFBUser() {
		guard let fbUser else { return }
		
		Self.currentUserID = fbUser.uid
	}
	
	func handleAuthStateChanged(for newUser: User?) async {
		fbUser = newUser
		if let newUser {
			await setupUserRecord(newUser)
			Notifications.didSignIn.notify(user)
		} else {
			user = nil
			Notifications.didSignOut.notify()
		}
		await UI.instance.setUser(user)
	}
	
	init() {
		Auth.auth().addStateDidChangeListener { auth, user in
			Task { await self.handleAuthStateChanged(for: user) }
		}
//		fbUser = Auth.auth().currentUser
//		if fbUser != nil {
//			Task { @MainActor in UI.instance.isSignedIn = true }
//		}
//		if let json = userDefaults.data(forKey: userDefaultsKey)?.jsonDictionary, !json.isEmpty, let user = try? SpotUserRecord.loadJSON(dictionary: json, using: .firebaseDecoder) {
//			self.user.record = user
//			Self.currentUserID = user.id
//			
//			Task { @MainActor in
//				try? await fetchUser()
//				if self.isSignedIn {
//					Task {
//						await FirestoreManager.instance.recordManager?.didSignIn()
//						Notifications.didSignIn.notify()
//					}
//					
//				}
//				objectWillChange.send()
//			}
//		} else {
//			asyncReport { try await self.fetchUser() }
//		}
	}
	
	public func save() {
//		asyncReport { try await self.saveUser() }
		saveUserDefaults()
	}
	
	func didUpdateDeviceInfo() async {
//		let deviceID = await Gestalt.deviceID
//		if isSignedIn {
//			addToken(token: apnsToken, deviceID: deviceID)
//		}
	}
	
	func saveUserDefaults() {
//		try? userDefaults.set(self.user.json.jsonData, forKey: userDefaultsKey)
		userDefaults.synchronize()
	}
		
	public static var sample: AuthorizedUser {
		AuthorizedUser()
	}
}
