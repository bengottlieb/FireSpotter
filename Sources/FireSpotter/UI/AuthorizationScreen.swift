//
//  AuthorizationScreen.swift
//  ArtesisMVP
//
//  Created by Ben Gottlieb on 3/2/23.
//

import SwiftUI

public struct AuthorizationScreen: View {
	let showSignInWithApple: Bool
	@State private var isRegistering = false
	@State private var isCommunicating = false
	@State private var email = CommandLine.string(for: "preloadedEmail") ?? ""
	@State private var password = CommandLine.string(for: "preloadedPassword") ?? ""
	@EnvironmentObject var authorizedUser: AuthorizedUser

	public init(showSignInWithApple: Bool = false) {
		self.showSignInWithApple = showSignInWithApple
	}
	
	public var body: some View {
		VStack {
			Text("Credentials")
				.font(.title)
			
			Picker("Action", selection: $isRegistering) {
				Text("Create Account").tag(true)
				Text("Sign In").tag(false)
			}
			.pickerStyle(.segmented)
			
			if isRegistering {
				RegisterUserView(isCommunicating: $isCommunicating, email: $email, password: $password, showSignInWithApple: showSignInWithApple)
			} else {
				LoginUserView(isCommunicating: $isCommunicating, email: $email, password: $password, showSignInWithApple: showSignInWithApple)
			}
		}
		.padding(.horizontal)
	}
}

struct AuthorizationScreen_Previews: PreviewProvider {
	static var previews: some View {
		AuthorizationScreen()
	}
}
