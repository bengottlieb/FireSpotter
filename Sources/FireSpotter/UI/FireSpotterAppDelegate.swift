//
//  FireSpotterAppDelegate.swift
//  
//
//  Created by Ben Gottlieb on 3/18/23.
//

#if os(iOS)

import UIKit

@MainActor open class FireSpotterAppDelegate: NSObject, UIApplicationDelegate {
	public override init() {
		super.init()
	}
	open func application(_ application: UIApplication,
								 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		
		FirestoreManager.configure(reduceLogging: false)
		AuthorizedUser.instance.setup()
		
		application.registerForRemoteNotifications()
		return true
	}
	
	open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
		APNSManager.instance.didReceive(deviceToken: deviceToken)
	}
	
	open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		FireSpotterLogger.warning("Failed to register for remote notifications: \(error, privacy: .public)")
	}
	
	open func application(_ application: UIApplication,
								 didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
		
		APNSManager.instance.appDidReceiveMessage(userInfo)
		return .newData
	}
}

#endif


#if os(macOS)
import Cocoa

open class FireSpotterAppDelegate: NSObject, NSApplicationDelegate {
	public func applicationDidFinishLaunching(_ notification: Notification) {
		FirestoreManager.configure(reduceLogging: false)
		AuthorizedUser.instance.setup()
		NSApp.registerForRemoteNotifications()
	}
	
	public func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		APNSManager.instance.didReceive(deviceToken: deviceToken)
		Task { await AuthorizedUser.instance.didReceiveAPNSToken(deviceToken) }
	}
	
	public func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
		FireSpotterLogger.warning("Failed to register for remove notifications: \(error, privacy: .public)")
	}
	
	public func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        print("Application did receive remote notification: \(userInfo)")
		APNSManager.instance.appDidReceiveMessage(userInfo)
	}
}
#endif
