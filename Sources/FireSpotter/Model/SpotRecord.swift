//
//  SpotRecord.swift
//  
//
//  Created by Ben Gottlieb on 3/5/23.
//

import Foundation

public protocol SpotRecord: Codable, Identifiable, Equatable, Sendable where ID == String {
	var id: String { get set }
	static var minimalRecord: Self { get }

	@MainActor static func newRecord(withID id: String) -> Self
}
