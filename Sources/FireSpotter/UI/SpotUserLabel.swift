//
//  SwiftUIView.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/3/25.
//

import SwiftUI

public struct SpotUserLabel: View {
	let id: String
	
	public init(id: String) {
		self.id = id
	}
	public var body: some View {
		UserView(id: id) { user in
			Text(user?.record.fullName ?? "Unknown")
		}
	}
}
