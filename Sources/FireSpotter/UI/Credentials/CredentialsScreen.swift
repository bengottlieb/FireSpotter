//
//  CredentialsScreen.swift
//  ArtesisMVP
//
//  Created by Ben Gottlieb on 3/2/23.
//

import SwiftUI

public struct CredentialsScreen: View {
	let showSignInWithApple: Bool
	@State private var isRegistering = false
	@State private var isCommunicating = false
	@State private var email = CommandLine.string(for: "preloadedEmail") ?? ""
	@State private var password = CommandLine.string(for: "preloadedPassword") ?? ""
	@EnvironmentObject var authorizedUser: AuthorizedUser
	let allowAccountCreation: Bool
	
	public init(showSignInWithApple: Bool = false, allowAccountCreation: Bool = true) {
		self.showSignInWithApple = showSignInWithApple
		self.allowAccountCreation = allowAccountCreation
		if !allowAccountCreation { isRegistering = false }
	}
	
	public var body: some View {
		VStack {
			Text("Credentials")
				.font(.title)
			
			if allowAccountCreation {
				Picker("Action", selection: $isRegistering) {
					Text("Create Account").tag(true)
					Text("Sign In").tag(false)
				}
				.pickerStyle(.segmented)
			}
			
			if isRegistering {
				RegisterUserView(isCommunicating: $isCommunicating, email: $email, password: $password, showSignInWithApple: showSignInWithApple)
			} else {
				LoginUserView(isCommunicating: $isCommunicating, email: $email, password: $password, showSignInWithApple: showSignInWithApple)
			}
		}
		.padding(.horizontal)
		.frame(maxWidth: 400)
	}
}

struct CredentialsScreen_Previews: PreviewProvider {
	static var previews: some View {
		CredentialsScreen()
	}
}
