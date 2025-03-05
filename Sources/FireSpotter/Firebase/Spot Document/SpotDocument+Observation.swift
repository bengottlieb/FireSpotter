//
//  SpotDocument+Observation.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/3/25.
//

import Foundation
import FirebaseFirestore

extension SpotDocument {
	@FireSpotterActor func startObserving() {
		guard listener == nil else { return }
		listener = collection.base?.document(id).addSnapshotListener { documentSnapshot, error in
			self.loadSnapshot(documentSnapshot)
		}
	}
	
	func stopObserving() {
		listener?.remove()
		listener = nil
	}
}
