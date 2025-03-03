//
//  AuthorizedUser.UI.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/2/25.
//

import Foundation

extension AuthorizedUser {
	@Observable @MainActor public class UI {
		public static let instance = AuthorizedUser.UI()
		
		public var isSignedIn = false
		
		func setIsSignedIn(_ signedIn: Bool) {
			self.isSignedIn = signedIn
		}
	}
}
