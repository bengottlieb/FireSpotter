//
//  SpotCollection.DeferredDocument.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/5/25.
//

import SwiftUI

public extension SpotCollection {
	nonisolated subscript(deferred id: String) -> DeferredDocument {
		DeferredDocument {
			await self[id]
		}
	}
	
	@MainActor @Observable class DeferredDocument {
		var document: SpotDocument<RecordType>?
		
		nonisolated init(builder: @escaping () async -> SpotDocument<RecordType>?) {
			Task { @MainActor in
				document = await builder()
			}
		}
	}
}
