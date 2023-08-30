//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 8/29/23.
//

import Foundation

extension SpotCollection {
	@MainActor public func remove(_ doc: SpotDocument<RecordType>) async throws {
		try await remove(doc.record)
	}
	
	@MainActor public func remove(_ element: RecordType) async throws {
		try await base.document(element.id).delete()
		uncache(element)
		objectWillChange.send()
	}
	
	@MainActor public func clearAll() async throws {
		let docs = try await base.getDocuments().documents
		
		for doc in docs {
			try await doc.reference.delete()
		}
		
		objectWillChange.send()
	}
}
