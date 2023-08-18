//
//  Environment.swift
//
//
//  Created by Ben Gottlieb on 8/18/23.
//

import SwiftUI

public struct RemoteDataLoadedKey: EnvironmentKey {
	public static var defaultValue = false
}

public extension EnvironmentValues {
	var remoteDataLoaded: Bool {
		get { self[RemoteDataLoadedKey.self] }
		set { self[RemoteDataLoadedKey.self] = newValue }
	}
}
