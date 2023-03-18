//
//  FireSpotterAppDelegate.swift
//  
//
//  Created by Ben Gottlieb on 3/18/23.
//

#if os(iOS)

import UIKit

open class FireSpotterAppDelegate: NSObject, UIApplicationDelegate {
	open func application(_ application: UIApplication,
						  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		application.registerForRemoteNotifications()
		return true
	}
	
	open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		AuthorizedUser.instance.apnsToken = deviceToken.hexString
	}
	
	open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Failed to register for remove notifications: \(error)")
	}
}

#endif
