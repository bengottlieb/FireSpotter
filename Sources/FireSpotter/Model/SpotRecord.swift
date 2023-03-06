//
//  SpotRecord.swift
//  
//
//  Created by Ben Gottlieb on 3/5/23.
//

import Foundation

public protocol SpotRecord: Codable, Identifiable, Equatable {
	static var minimalRecord: Self { get }

	static func newRecord() -> Self
}
