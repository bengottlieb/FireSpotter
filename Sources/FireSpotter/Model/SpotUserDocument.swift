//
//  File.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/16/25.
//

import Suite

public extension SpotUserDocument {
    var canSendAPNSTo: Bool {
        record.pushTokens.count > 0
    }
    
    var apnsTokens: [String] {
        record.pushTokens.compactMap {
            $0.kind == .apns ? $0.token : nil
        }
    }
    
    func addPushToken(_ token: String?, kind: PushTokenInfo.Kind) async {
		guard let token, let deviceID = await Gestalt.deviceID else { return }
		
        if let index = record.pushTokens.firstIndex(where: { $0.kind == kind && $0.deviceID == deviceID}) {
			if record.pushTokens[index].token == token { return }
			record.pushTokens.remove(at: index)
		}
		
        record.pushTokens.append(.init(kind: kind, deviceID: deviceID, token: token))
		do {
			try await save()
		} catch {
			print("Failed to save updated push token: \(error)")
		}
	}
}
