//
//  DeferredDocumentView.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/5/25.
//

import SwiftUI

public struct DeferredDocumentView<Record: SpotRecord, Content: View>: View {
	let fetch: () async -> SpotDocument<Record>?
	@State private var document: SpotDocument<Record>?
	@ViewBuilder var builder: (SpotDocument<Record>) -> Content
	
	public init(collection: @escaping () async -> SpotCollection<Record>, record: Record, @ViewBuilder builder: @escaping (SpotDocument<Record>) -> Content) {
		self.fetch = {
			await collection().document(record)
		}
		self.builder = builder
	}
	
	public init(fetch: @escaping () async -> SpotDocument<Record>, record: Record, @ViewBuilder builder: @escaping (SpotDocument<Record>) -> Content) {
		self.fetch = fetch
		self.builder = builder
	}
	
	public var body: some View {
		Group {
			if let document {
				builder(document)
			}
		}
		.task {
			document = await fetch()
		}
	}
}
