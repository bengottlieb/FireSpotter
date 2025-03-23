//
//  AuthorizedUser.UI.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/2/25.
//

import SwiftUI

public struct SpotUserDocumentKey: EnvironmentKey {
	public static var defaultValue: SpotUserDocument = .empty
}

extension EnvironmentValues {
	public var spotUserDocument: SpotUserDocument {
		  get { self[SpotUserDocumentKey.self] }
		  set { self[SpotUserDocumentKey.self] = newValue }
	 }
}


extension AuthorizedUser {
	@Observable @MainActor public class UI {
		public static let instance = AuthorizedUser.UI()
		
		public var isSignedIn: Bool { user != nil }
		public var user: SpotUserDocument?
        public var isSetup = false
        public var apns: String?
		public var userID: String { user?.id ?? .EMPTY_ID }
		
        func setAPNSToken(_ token: String?) {
            self.apns = token
        }
        
		func setUser(_ spotUser: SpotUserDocument?) {
			isSetup = true
			if spotUser === self.user { return }
			user?.stopObserving()
			Task { @FireSpotterActor in spotUser?.startObserving() }
			self.user = spotUser
		}
	}
}
