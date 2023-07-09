//
//  SpotDate.swift
//  
//
//  Created by Ben Gottlieb on 3/21/23.
//

import Suite

public struct SpotDate: Codable, Equatable, Hashable, Sendable, Comparable {
	enum CodingKeys: String, CodingKey { case dayString = "day", timeString = "time" }
	var dayString: String { didSet { cachedDate = computedDate }}
	public var timeString: String? { didSet { cachedDate = computedDate }}
	public var cachedDate: Date?
	
	public static var today: SpotDate { SpotDate(.now) }
	public var date: Date {
		get {
			if let cachedDate { return cachedDate }
			return computedDate
		}
		
		set {
			dayString = DateFormatter.dmyDecoder.string(from: newValue.noon)
			if timeString != nil {
				timeString = String(format: "%02d:%02d", newValue.hour, newValue.minute)
			}
			cachedDate = newValue
		}
	}
	
	public static func <(lhs: SpotDate, rhs: SpotDate) -> Bool {
		lhs.date < rhs.date
	}
	
	public func byAdding(timeInterval: TimeInterval) -> SpotDate {
		.init(date.addingTimeInterval(timeInterval))
	}
	
	public var day: Date.Day {
		get { Date.Day(dmy: dayString) ?? date.day }
		set { dayString = newValue.dmyString }
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
			cachedDate = computedDate
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
	
	public init(_ day: Date.Day, _ time: Date.Time?) {
		dayString = day.dmyString
		timeString = time?.hourMinuteString
	}
	
	public init(_ date: Date, includingTime: Bool = true) {
		dayString = DateFormatter.dmyDecoder.string(from: date.noon)
		if includingTime {
			timeString = date.time.stringValue
		} else {
			timeString = nil
		}
		cachedDate = date
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		dayString = try container.decode(String.self, forKey: .dayString)
		timeString = try container.decodeIfPresent(String.self, forKey: .timeString)
		cachedDate = computedDate
	}
	
	public static var timezone = TimeZone(abbreviation: "MDT")
	
	public var computedDate: Date {
		guard let date = DateFormatter.dmyDecoder.date(from: dayString) else {
			return .now
		}
		
		if let time = timeString {
			if let timeInfo = Date.Time(string: time) {
				return date.bySetting(time: timeInfo)
			}
		}
		
		return date.noon
	}
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
