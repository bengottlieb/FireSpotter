//
//  RTDatabaseManager.swift
//
//
//  Created by Ben Gottlieb on 10/1/23.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

public class RTDatabaseManager: ObservableObject {
	public static let instance = RTDatabaseManager()
	
	lazy var db = Database.database()
	
	
}
