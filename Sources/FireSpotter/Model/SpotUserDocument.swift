//
//  File.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/16/25.
//

import Suite

extension SpotUserDocument {
	func addPushToken(_ token: String?) async {
		guard let token, let deviceID = await Gestalt.deviceID else { return }
		
		if let index = record.pushTokens.firstIndex(where: { $0.deviceID == deviceID}) {
			if record.pushTokens[index].token == token { return }
			record.pushTokens.remove(at: index)
		}
		
		record.pushTokens.append(.init(deviceID: deviceID, token: token))
		do {
			try await save()
		} catch {
			print("Failed to save updated push token: \(error)")
		}
	}
}
