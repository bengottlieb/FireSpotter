//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 3/6/23.
//

import SwiftUI

public struct SpotRecordView<Record: SpotRecord, Content: View>: View {
	let collection: SpotCollection<Record>
	let id: String
	let content: (Record?) -> Content

	@State private var doc: SpotDocument<Record>?
	
	public init(id: String, in collection: SpotCollection<Record>, content: @escaping (Record?) -> Content) {
		self.collection = collection
		self.id = id
		self.content = content
	}
	
	public var body: some View {
		content(doc?.subject)
			.task { await doc = collection[id] }
	}
}

