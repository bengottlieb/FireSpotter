//
//  FBDocument.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Journalist

public class SpotDocument<Subject: SpotRecord>: ObservableObject where Subject.ID == String {
	@Published var subject: Subject
	let collection: SpotCollection<Subject>
	
	init(_ subject: Subject, collection: SpotCollection<Subject>) {
		self.subject = subject
		self.collection = collection
	}
	
	public func save() {
		Task { await report { try await self.collection.save(self.subject) } }
	}
}
