//
//  RecordManager.swift
//  
//
//  Created by Ben Gottlieb on 3/11/23.
//

import Suite

public protocol SpotRecordManager: AnyObject {
	func didSignIn() async
	func shouldChange(object: any SpotRecord, with json: JSONDictionary) async -> Bool
	func shouldDelete(object: any SpotRecord) async -> Bool
}
