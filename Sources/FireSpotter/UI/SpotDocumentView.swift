//
//  SpotDocumentView.swift
//  
//
//  Created by Ben Gottlieb on 3/13/23.
//

import SwiftUI


public struct SpotDocumentView<Subject: SpotRecord, Content: View>: View {
	@ObservedObject var document: SpotDocument<Subject>
	@ViewBuilder var content: (Binding<Subject>) -> Content
	
	public init(document: SpotDocument<Subject>, @ViewBuilder content: @escaping (Binding<Subject>) -> Content) {
		self.document = document
		self.content = content
	}
	
	public var body: some View {
		content(document.recordBinding)
	}
}
