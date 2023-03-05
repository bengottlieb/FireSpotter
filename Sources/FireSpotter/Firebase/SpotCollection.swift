//
//  SpotCollection.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Suite
import FirebaseFirestore
import FirebaseFirestoreSwift

public class SpotCollection<Element: FirebaseCollectionElement>: ObservableObject where Element.ID == String {
	public let base: CollectionReference
	
	init(_ collection: CollectionReference, kind: Element.Type) {
		base = collection
	}
	
	@discardableResult func append(_ element: Element) throws -> SpotDocument<Element> {
		let doc = base.document(element.id)
		try doc.setData(from: element)
		
		return SpotDocument(element, collection: self)
	}
	
	@discardableResult func save(_ element: Element) async throws -> SpotDocument<Element> {
		guard let raw = try? await base.document(element.id).getDocument(as: Element.self) else {
			return try append(element)
		}
		
		if raw != element {
			try base.document(element.id).setData(from: element)
		}
		
		return SpotDocument(element, collection: self)
	}
	
	
	subscript(id: String) -> SpotDocument<Element>? {
		get async {
			do {
				let raw = try await base.document(id).getDocument()
				
				guard let json = raw.data() else { return nil }
				let doc = try Element.loadJSON(dictionary: json)

				return SpotDocument(doc, collection: self)
			} catch {
				print("Failed to get document: \(error)")
				return nil
			}
		}
	}
}
