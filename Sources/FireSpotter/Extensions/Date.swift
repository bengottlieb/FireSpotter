//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/13/23.
//

import Foundation

extension Date {
	public func dateID(prefix: String) -> String {
		let string = DateFormatter.idFormatter.string(from: self)
		return prefix + "-" + string
	}
}


extension DateFormatter {
	static let idFormatter: DateFormatter = {
		let formatter = DateFormatter(format: "dd-MM-yyyy")
		formatter.timeZone = .current
		return formatter
	}()
}
