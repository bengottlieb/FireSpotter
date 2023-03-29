//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/21/23.
//

import Suite

public struct SpotDate: Codable, Equatable, Hashable, Sendable {
	var day: String
	public var time: String?
	
	public var date: Date {
		get {
			guard let date = DateFormatter.dmyDecoder.date(from: day) else {
				return .now
			}
			
			if let time, let timeInfo = Date.Time(string: time) {
				return date.bySetting(time: timeInfo)
			}
			
			return date.noon
		}
		
		set {
			day = DateFormatter.dmyDecoder.string(from: newValue.noon)
			if time != nil {
				time = String(format: "%02d:%02d", newValue.hour, newValue.minute)
			}
		}
	}
	
	public func formatted(date dateStyle: Date.FormatStyle.DateStyle = .long, time timeStye: Date.FormatStyle.TimeStyle = .shortened) -> String {
		if !hasTime {
			return dateStyle == .omitted ? "" : date.formatted(date: dateStyle, time: .omitted)
		}
		return date.formatted(date: dateStyle, time: timeStye)
	}
	
	public var hasTime: Bool { time != nil }
	public var noon: SpotDate {
		SpotDate(date.noon)
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
