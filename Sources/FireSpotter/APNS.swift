//
//  APNSManager.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/15/25.
//

import Foundation
import UserNotifications
import SwiftUI
import FirebaseMessaging

public class APNSManager: NSObject {
	public static let instance = APNSManager()
	
	public func didReceive(deviceToken: Data) {
		Messaging.messaging().apnsToken = deviceToken
	}
	
	public func appDidReceiveMessage(_ info: [AnyHashable: Any]) {
		Messaging.messaging().appDidReceiveMessage(info)
	}
	
	public func setup() async throws {
		UNUserNotificationCenter.current().delegate = self
		Messaging.messaging().delegate = self

		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)

		#if os(iOS)
			await UIApplication.shared.registerForRemoteNotifications()
		#endif
	}
}

extension APNSManager: UNUserNotificationCenterDelegate {
	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
		
		let userInfo = notification.request.content.userInfo
		Messaging.messaging().appDidReceiveMessage(userInfo)
		
		return [.banner, .sound, .badge]
	}
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {

		let userInfo = response.notification.request.content.userInfo

		Messaging.messaging().appDidReceiveMessage(userInfo)
	}
}

extension APNSManager: MessagingDelegate {
	
}
