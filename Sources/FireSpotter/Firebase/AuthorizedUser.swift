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

@MainActor public class AuthorizedUser: ObservableObject {
	public static let instance = AuthorizedUser()
	
	enum AuthorizationError: Error { case unknown, noIdentityToken, badIdentityToken }
	public struct Notifications {
		public static let didSignIn = Notification.Name("AuthorizedUser.didSignIn")
		public static let didSignOut = Notification.Name("AuthorizedUser.didSignOut")
	}
	
	static nonisolated let currentUserIDSubject: CurrentValueSubject<String, Never> = .init("")
	
	public static nonisolated var currentUserID: String {// { Auth.auth().currentUser?.uid ?? "" }
		get { currentUserIDSubject.value }
		set { currentUserIDSubject.value = newValue }
	}
	
	private var userCancellable: AnyCancellable?
	public var fbUser: User? { didSet { updateFBUser() }}
	public var userDefaults = UserDefaults.standard
	public nonisolated var currentUserID: String? { Self.currentUserID }
	public var apnsToken: String? { didSet { didUpdateDeviceInfo() }}
	public var deviceID = Gestalt.deviceID { didSet { didUpdateDeviceInfo() }}
	
	public var user: SpotUserDocument = SpotUserDocument(SpotUserRecord.minimalRecord, collection: FirestoreManager.users)
	var rawUserJSON: [String: Any] = [:]
	
	let userDefaultsKey = "firespotter_stored_user"
	public func setup() { }
	
	func updateFBUser() {
		guard let fbUser else { return }
		
		Self.currentUserID = fbUser.uid
	}
	
	init() {
		fbUser = Auth.auth().currentUser
		if let json = userDefaults.data(forKey: userDefaultsKey)?.jsonDictionary, !json.isEmpty, let user = try? SpotUserRecord.loadJSON(dictionary: json, using: .firebaseDecoder) {
			self.user.record = user
			Self.currentUserID = user.id
			
			Task { @MainActor in
				try? await fetchUser()
				if self.isSignedIn {
					Task {
						await FirestoreManager.instance.recordManager?.didSignIn()
						Notifications.didSignIn.notify()
					}
					
				}
				objectWillChange.send()
			}
		} else {
			asyncReport { try await self.fetchUser() }
		}
	}
	
	public func save() {
		asyncReport { try await self.saveUser() }
		saveUserDefaults()
	}
	
	func didUpdateDeviceInfo() {
		if isSignedIn {
			addToken(token: apnsToken, deviceID: deviceID)
		}
	}
	
	func saveUserDefaults() {
		try? userDefaults.set(self.user.json.jsonData, forKey: userDefaultsKey)
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
	
	func store(user fbUser: User, completion: @escaping () -> Void) {
		self.fbUser = fbUser
		if !isSignedIn { user = .init(.init(id: fbUser.uid), collection: FirestoreManager.users) }
		save()
		
		Task { @MainActor in
			await FirestoreManager.instance.recordManager?.didSignIn()
			self.objectWillChange.send()
			completion()
			Notifications.didSignIn.notify()
		}
	}
}
