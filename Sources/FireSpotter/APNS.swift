//
//  APNSManager.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/15/25.
//

import UserNotifications
import FirebaseMessaging
import Suite

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
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
        } catch {
            print("Failed to get notification authorization: \(error)")
        }
		#if os(iOS)
			await UIApplication.shared.registerForRemoteNotifications()
        #else
            await NSApp.registerForRemoteNotifications()
            print("Registered: \(await NSApp.isRegisteredForRemoteNotifications)")
		#endif
	}
}

extension APNSManager: UNUserNotificationCenterDelegate {
	@MainActor public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
		
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
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		 Task { await AuthorizedUser.instance.didReceiveFCMToken(fcmToken) }
    }
}
