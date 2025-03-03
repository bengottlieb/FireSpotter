//
//  CredentialsView.swift
//
//  Created by Ben Gottlieb on 3/4/23.
//

import SwiftUI
import AuthenticationServices

@MainActor struct SignInWithAppleView: View {
	@Binding var displayedError: Error?
	let label: SignInWithAppleButton.Label
	
	@Environment(AuthorizedUser.UI.self) private var authorizedUserUI
	@State private var nonce = ""
	
	var body: some View {
		SignInWithAppleButton(label) { request in
			self.nonce = String.randomNonce()
			request.requestedScopes = [.fullName, .email]
			request.nonce = nonce.sha256
		} onCompletion: { result in
			switch result {
			case .success(let auth):
				Task {
					do {
						try await authorizedUserUI.signIn(credential: auth.credential as? ASAuthorizationAppleIDCredential, nonce: nonce)
					} catch {
						displayedError = error
					}
				}
			case .failure(let error):
				displayedError = error
			}
		}
		.signInWithAppleButtonStyle(.black)
		.frame(height: 50)
		.cornerRadius(8)
	}
}
