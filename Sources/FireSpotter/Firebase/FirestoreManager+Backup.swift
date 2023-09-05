//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 9/5/23.
//

import Foundation

public class FirestoreBackup {
	let baseURL: URL
	
	init(url: URL) {
		baseURL = url
	}
	
	func url(for collectionPath: String) -> URL {
		baseURL.appendingPathComponent(collectionPath.replacingOccurrences(of: "/", with: "_")).appendingPathExtension("txt")
	}
}

extension FirestoreManager {
	
	public func startBackup(at url: URL, work: @escaping (FirestoreBackup) async throws -> Void) async throws {
		try? FileManager.default.removeItem(at: url)
		try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		let backup = FirestoreBackup(url: url)
		try await work(backup)
	}
	
	public func restoreBackup(at url: URL, work: @escaping (FirestoreBackup) async throws -> Void) async throws {
		if !FileManager.default.directoryExists(at: url) { return }
		let backup = FirestoreBackup(url: url)

		try await work(backup)
	}
	
	public func backup(collections names: [String], to url: URL) async throws {
		try await startBackup(at: url) { [unowned self] backup in
			for name in names {
				guard let collection = cache[name] else { continue }
				
				try await collection.backup(to: backup)
			}
		}
	}
}
