//
//  SpotRecord.swift
//  
//
//  Created by Ben Gottlieb on 3/5/23.
//

import Foundation

enum SpotRecordError: Error { case noRecordID }

public protocol SpotRecord: Codable, Identifiable, Equatable, Sendable, CustomStringConvertible, Hashable where ID == String {
	var id: String { get set }
	init(id: String)
		
	func awakeFromFetch(in document: SpotDocument<Self>) async
}

public protocol CreatableRecord: SpotRecord {
	@MainActor static func newRecord(withID id: String) -> Self
}

public extension SpotRecord {
	static var empty: Self {
		Self.init(id: .EMPTY_ID)
	}

	var isEmpty: Bool { id == .EMPTY_ID }
}
