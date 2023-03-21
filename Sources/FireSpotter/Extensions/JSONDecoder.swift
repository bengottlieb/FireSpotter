//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/21/23.
//

import Foundation

public extension JSONDecoder {
	static let firebaseDecoder: JSONDecoder = {
		let decoder = JSONDecoder()
		return decoder
	}()
}
