//
//  CredentialsScreen.RegisterUserView.swift
//  ArtesisMVP
//
//  Created by Ben Gottlieb on 3/2/23.
//

import SwiftUI
import Suite

extension CredentialsScreen {
	@MainActor struct RegisterUserView: View {
		@Binding var isCommunicating: Bool
		@Binding var email: String
		@Binding var password: String
		let showSignInWithApple: Bool

		@State private var displayedError: Error?
		
		@EnvironmentObject var authorizedUser: AuthorizedUser

		var validCredentials: Bool {
			email.isValidEmail && password.count >= 6
		}
		
		func createUser() {
			isCommunicating = true
			
			Task {
				do {
					try await authorizedUser.register(email: email, password: password)
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
				
				Button("Create Account") {
					createUser()
				}
				.keyboardShortcut("\n", localization: .automatic)
				.buttonStyle(FullWidthButtonStyle())
				.disabled(!validCredentials || isCommunicating)
				.frame(height: 50)
				
				if showSignInWithApple {
					SignInWithAppleView(displayedError: $displayedError, label: .signUp)
				}
			}
			.padding()
		}
	}
}

struct CredentialsScreen_RegisterUserView_Previews: PreviewProvider {
    static var previews: some View {
		 CredentialsScreen.RegisterUserView(isCommunicating: .constant(false), email: .constant(""), password: .constant(""), showSignInWithApple: false)
    }
}