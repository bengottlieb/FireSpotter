//
//  SpotCollection+Fetch.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/5/25.
//

import Foundation
import FirebaseFirestore

public extension SpotCollection {
	subscript(create recordID: String, andSave: Bool = true) -> SpotDocument<RecordType> {
		get async {
			if let existing = await self[recordID] { return existing }
			do {
				return try await insert(RecordType(id: recordID), andSave: andSave)
			} catch {
				print("Failed to insert record: \(error)")
				return .init(RecordType(id: recordID), collection: self)
			}
		}
	}
	
	subscript(recordID: String) -> SpotDocument<RecordType>? {
		get async {
			if let cached = cache[recordID] { return cached }
			do {
				guard let json = try await base.document(recordID).getDocument().data() else { return nil }
				let record = try RecordType.loadJSON(dictionary: json.convertingFirebaseTimestampsToDates())
				
				let doc = SpotDocument(record, collection: self)
				doc.json = json
				await doc.record.awakeFromFetch(in: doc)
				cache.store(doc)
				return doc
			} catch {
				FireSpotterLogger.error("Failed to get \(RecordType.self) \"\(recordID)\"")
				return nil
			}
		}
	}
	
	
	subscript(recordIDs: [String]) -> [SpotDocument<RecordType>] {
		get async {
			var results: [SpotDocument<RecordType>] = []
			
			for id in recordIDs {
				if let doc = await self[id] { results.append(doc) }
			}
			
			return results
		}
	}
}
