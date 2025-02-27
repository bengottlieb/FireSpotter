//
//  CredentialsScreen.swift
//  ArtesisMVP
//
//  Created by Ben Gottlieb on 3/2/23.
//

import SwiftUI

public struct CredentialsScreen<Content: View>: View {
	let showSignInWithApple: Bool
	@State private var isRegistering = false
	@State private var isCommunicating = false
	@State private var email = ProcessInfo.string(for: "preloadedEmail") ?? ""
	@State private var password = ProcessInfo.string(for: "preloadedPassword") ?? ""
	@EnvironmentObject var authorizedUser: AuthorizedUser
	@Environment(\.dismiss) var dismiss
	let allowAccountCreation: Bool
	let allowDontSignIn: Bool
	@ViewBuilder var content: () -> Content
	
	public init(showSignInWithApple: Bool = false, allowAccountCreation: Bool = true, allowDontSignIn: Bool = false, @ViewBuilder content: @escaping () -> Content) {
		self.showSignInWithApple = showSignInWithApple
		self.allowAccountCreation = allowAccountCreation
		self.allowDontSignIn = allowDontSignIn
		self.content = content
		if !allowAccountCreation { isRegistering = false }
	}
	
	func skip() {
		dismiss()
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
				RegisterUserView(isCommunicating: $isCommunicating, email: $email, password: $password, showSignInWithApple: showSignInWithApple, skipSignIn: allowDontSignIn ? { skip() } : nil, content: content)
			} else {
				LoginUserView(isCommunicating: $isCommunicating, email: $email, password: $password, showSignInWithApple: showSignInWithApple, skipSignIn: allowDontSignIn ? { skip() } : nil, content: content)
			}
		}
		.padding(.horizontal)
		.frame(maxWidth: 400)
	}
}

struct CredentialsScreen_Previews: PreviewProvider {
	static var previews: some View {
		CredentialsScreen() { EmptyView() }
	}
}
