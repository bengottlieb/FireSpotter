//
//  CredentialsScreen.LoginUserView.swift
//  ArtesisMVP
//
//  Created by Ben Gottlieb on 3/2/23.
//

import SwiftUI
import Suite

extension CredentialsScreen {
	@MainActor struct LoginUserView: View {
		@Binding var isCommunicating: Bool
		@Binding var email: String
		@Binding var password: String
		let showSignInWithApple: Bool
		let skipSignIn: (() -> Void)?
		
		@State private var displayedError: Error?
		@EnvironmentObject var authorizedUser: AuthorizedUser
		
		var validCredentials: Bool {
			email.isValidEmail && password.count >= 6
		}
		
		func signIn() {
			isCommunicating = true
			
			Task {
				do {
					try await authorizedUser.signIn(email: email, password: password)
				} catch {
					displayedError = error
				}
				isCommunicating = false
			}
		}
		
		var body: some View {
			VStack {
				TextField("Email", text: $email)
					.addTextContentType(.emailAddress)

				
				TextField("Password", text: $password)
					.addTextContentType(.password)

				if let displayedError {
					Text(displayedError.localizedDescription)
						.foregroundColor(.red)
						.multilineTextAlignment(.center)
				}
				
				Spacer()
				
				HStack {
					Button("Sign In") { signIn() }
						.buttonStyle(FullWidthButtonStyle())
						.keyboardShortcut("\n", localization: .automatic)
						.disabled(!validCredentials || isCommunicating)
						
					if let skipSignIn {
						Button("Skip") { skipSignIn() }
							.buttonStyle(FullWidthButtonStyle(borderOnly: true, borderWidth: 2))
							.keyboardShortcut("\n", localization: .automatic)
							.disabled(isCommunicating)
					}
				}
				.frame(height: 50)

				if showSignInWithApple {
					SignInWithAppleView(displayedError: $displayedError, label: .signIn)
				}
			}
			.padding()
		}
	}
}

struct CredentialsScreen_LoginUserView_Previews: PreviewProvider {
	static var previews: some View {
		CredentialsScreen.LoginUserView(isCommunicating: .constant(false), email: .constant(""), password: .constant(""), showSignInWithApple: false) { }
	}
}

