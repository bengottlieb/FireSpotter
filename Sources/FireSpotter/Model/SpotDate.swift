//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/21/23.
//

import Suite

public struct SpotDate: Codable, Equatable, Hashable, Sendable {
	let day: String
	let time: String?
	
	public var date: Date? {
		guard let date = DateFormatter.dmyDecoder.date(from: day)  else {
			return nil
		}
		
		if let time, let timeInfo = Date.Time(string: time) {
			return date.bySetting(time: timeInfo)
		}
		
		return date.noon
	}
	
	public var hasTime: Bool { time != nil }
	public var noon: SpotDate? {
		guard let noon = date?.noon else { return nil }
		return SpotDate(noon)
	}
	
	public static var now: SpotDate {
		SpotDate(Date.now)
	}
	
	public init(_ date: Date, includingTime: Bool = true) {
		day = DateFormatter.dmyDecoder.string(from: date.noon)
		if includingTime {
			time = date.time.stringValue
		} else {
			time = nil
		}
	}
	
	public static var timezone = TimeZone(abbreviation: "MDT")
}


extension DateFormatter {
	static let dmyDecoder: DateFormatter = {
		let formatter = DateFormatter(format: "dd-MM-yyyy")
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = SpotDate.timezone
		
		return formatter
	}()
}
