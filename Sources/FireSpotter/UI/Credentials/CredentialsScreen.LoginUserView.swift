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
				
				Button("Sign In") {
					signIn()
				}
				.keyboardShortcut("\n", localization: .automatic)
				.frame(height: 50)
				.buttonStyle(FullWidthButtonStyle())
				.disabled(!validCredentials || isCommunicating)

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
		CredentialsScreen.LoginUserView(isCommunicating: .constant(false), email: .constant(""), password: .constant(""), showSignInWithApple: false)
	}
}
