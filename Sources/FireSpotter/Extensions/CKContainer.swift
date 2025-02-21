//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 9/22/23.
//

import Foundation
import CloudKit

public extension CKContainer {
	var userRecordID: String {
		get async throws {
			let record = try await userRecordID()
			return record.recordName
		}
	}
	
	static func container(forID id: String? = nil) -> CKContainer {
		guard let id else { return CKContainer.default() }
		
		return CKContainer(identifier: id)
	}
	
	static var userRecordID: String {
		get async throws {
			try await CKContainer.default().userRecordID
		}
	}
}
