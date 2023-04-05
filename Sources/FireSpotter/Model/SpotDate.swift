//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/21/23.
//

import Suite

public struct SpotDate: Codable, Equatable, Hashable, Sendable {
	enum CodingKeys: String, CodingKey { case dayString = "day", timeString = "time" }
	var dayString: String
	public var timeString: String?
	
	public var date: Date {
		get {
			guard let date = DateFormatter.dmyDecoder.date(from: dayString) else {
				return .now
			}
			
			if let time = timeString, let timeInfo = Date.Time(string: time) {
				return date.bySetting(time: timeInfo)
			}
			
			return date.noon
		}
		
		set {
			dayString = DateFormatter.dmyDecoder.string(from: newValue.noon)
			if timeString != nil {
				timeString = String(format: "%02d:%02d", newValue.hour, newValue.minute)
			}
		}
	}
	
	public var time: Date.Time? {
		get {
			guard let timeString else { return nil }
			return .init(string: timeString)
		}
		set {
			if let newValue {
				timeString = String(format: "%02d:%02d", newValue.hour, newValue.minute)
			} else {
				timeString = nil
			}
		}
	}
	
	public func formatted(date dateStyle: Date.FormatStyle.DateStyle = .long, time timeStyle: Date.FormatStyle.TimeStyle = .shortened) -> String {
		if !hasTime {
			return dateStyle == .omitted ? "" : date.formatted(date: dateStyle, time: .omitted)
		}
		return date.formatted(date: dateStyle, time: timeStyle)
	}
	
	public var hasTime: Bool { timeString != nil }
	public var noon: SpotDate {
		SpotDate(date.noon)
	}
	
	public static var now: SpotDate {
		SpotDate(Date.now)
	}
	
	public func withTime(_ src: Date? = nil) -> SpotDate {
		var newDate = self
		newDate.time = (src ?? .now).time
		return newDate
	}
	
	public var dateOnly: Date {
		get { date.noon }
		set { self.dayString = DateFormatter.dmyDecoder.string(from: newValue) }
	}
	
	public init(_ date: Date, includingTime: Bool = true) {
		dayString = DateFormatter.dmyDecoder.string(from: date.noon)
		if includingTime {
			timeString = date.time.stringValue
		} else {
			timeString = nil
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
