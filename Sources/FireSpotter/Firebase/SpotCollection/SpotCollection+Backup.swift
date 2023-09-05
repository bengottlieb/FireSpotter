//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 9/5/23.
//

import Foundation

extension SpotCollection {
	func backedupData() async throws -> Data {
		let all = try await self.fetchAll()
		let records = all.map { $0.record }
		let data = try JSONEncoder().encode(records)
		return data
	}
	
	public func backup(to backup: FirestoreBackup) async throws {
		let data = try await backedupData()
		let url = backup.url(for: path)
		try? FileManager.default.removeItem(at: url)
		try data.write(to: url)
	}
	
	public func restoreBackup(from backup: FirestoreBackup) async throws {
		
	}
}
