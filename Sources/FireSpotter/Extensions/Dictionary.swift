//
//  Dictionary.swift
//
//
//  Created by Ben Gottlieb on 7/8/23.
//

import Foundation
import FirebaseFirestore

public protocol DateKeyProvider {
	static func isDateKey(_ key: String) -> Bool
}

struct DefaultDateKeyProvider: DateKeyProvider {
	static func isDateKey(_ key: String) -> Bool {
		let lower = key.lowercased()
		
		return lower.contains("date") || lower.contains("timestamp")
	}
}

extension [String: Any] {
	func convertingFirebaseTimestampsToDates() -> [String: Any] {
		var copy = self

		for (key, value) in copy {
			if let dict = value as? [String: Any] {
				copy[key] = dict.convertingFirebaseTimestampsToDates()
			} else if let timestamp = value as? Timestamp {
				copy[key] = TimeInterval(timestamp.seconds) - 978307200
			}
		}
		
		return copy
	}
	
	func convertingDatesToFirebaseTimestamps(using: DateKeyProvider.Type?) -> [String: Any] {
		let provider = using ?? DefaultDateKeyProvider.self
		var copy = self
		
		for (key, value) in copy {
			if let dict = value as? [String: Any] {
				copy[key] = dict.convertingDatesToFirebaseTimestamps(using: provider)
			} else if let seconds = value as? TimeInterval, provider.isDateKey(key) {
				copy[key] = Timestamp(seconds: Int64(seconds + 978307200), nanoseconds: 0)
			}
		}

		return copy
	}
}
