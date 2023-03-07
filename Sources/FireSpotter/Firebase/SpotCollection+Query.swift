//
//  SpotCollection+Query.swift
//  
//
//  Created by Ben Gottlieb on 3/6/23.
//

import Suite
import FirebaseFirestore
import FirebaseFirestoreSwift

public extension SpotCollection {
	func documents(where field: String, isEqualTo target: Any) async throws -> [SpotDocument<Element>] {
		
		let results = try await base.whereField(field, isEqualTo: target).getDocuments().documents
		
		
		return try results.map { try document(from: $0.data() ) }
	}
	
	func documents(where field: String, startsWith target: String) async throws -> [SpotDocument<Element>] {
		
		let results = try await base
			.whereField(field, isGreaterThanOrEqualTo: target)
			.whereField(field, isLessThan: target + "~")
			.getDocuments().documents
		
		
		return try results.map { try document(from: $0.data() ) }
	}
}
