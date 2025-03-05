//
//  DeferredDocumentView.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/5/25.
//

import SwiftUI

public struct DeferredDocumentView<Record: SpotRecord, Content: View>: View {
	var deferredDocument: SpotCollection<Record>.DeferredDocument
	@ViewBuilder var buildContent: (SpotDocument<Record>) -> Content
	
	public init(_ doc: SpotCollection<Record>.DeferredDocument, @ViewBuilder content: @escaping (SpotDocument<Record>) -> Content) {
		self.deferredDocument = doc
		self.buildContent = content
	}
	
	public var body: some View {
		if let doc = deferredDocument.document {
			buildContent(doc)
		}
	}
}
