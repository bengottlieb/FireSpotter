//
//  File.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/3/25.
//

import SwiftUI

public struct UserView<Content: View>: View {
	let id: String?
	@ViewBuilder var content: (SpotUserDocument?) -> Content
	@State var user: SpotUserDocument?
	
	public init(id: String?, @ViewBuilder content: @escaping (SpotUserDocument?) -> Content) {
		self.id = id
		self.content = content
	}
	
	public var body: some View {
		content(user)
			.task {
				if let id {
					user = await FirestoreManager.users[id]
				}
			}
	}
}
