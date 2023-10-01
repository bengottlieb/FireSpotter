//
//  RTDatabaseManager.swift
//
//
//  Created by Ben Gottlieb on 10/1/23.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import Suite

public class RTDatabaseManager: ObservableObject {
	public static let instance = RTDatabaseManager()
	
	lazy var db = Database.database().reference()
	
	enum RTDatabaseManagerError: Error { case unexpectedFormat }
	
	public func get<Result: Codable>(_ path: String) async throws -> Result {
		let snapshot = try await db.child(path).getData()
		guard let json = snapshot.value else { throw RTDatabaseManagerError.unexpectedFormat }
		let data = try JSONSerialization.data(withJSONObject: json)
		
		return try Result.loadJSON(data: data)
	}
}
