//
//  SpotRecord.swift
//  
//
//  Created by Ben Gottlieb on 3/5/23.
//

import Foundation

enum SpotRecordError: Error { case noRecordID }

public protocol SpotRecord: Codable, Identifiable, Equatable, Sendable, Hashable where ID == String {
	var id: String { get set }
	static var minimalRecord: Self { get }
	
	@MainActor static func newRecord(withID id: String) -> Self
	
	func awakeFromFetch(in document: SpotDocument<Self>) async
}

extension SpotRecord {
	public static var sampleDocument: SpotDocument<Self> {
		SpotDocument(.minimalRecord, collection: nil)
	}

}
