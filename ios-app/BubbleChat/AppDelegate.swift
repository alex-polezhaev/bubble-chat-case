//
//  AppDelegate.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.09.2024.
//

import Alamofire
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialization can happen here, but without requesting notifications
        print("AppDelegate didFinishLaunchingWithOptions called")
        clearNotifications()
        return true
    }

    func applicationWillTerminate(_: UIApplication) {
        try? GRPCManager.shared.shutdown()
    }

    // Get the token for push notifications
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
//        print("Push Token: \(token)")

        // Send the token to the server (implement your own method)
        sendTokenToServer(deviceToken: token)
    }

    // Token retrieval error
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    private func clearNotifications() {
        // Set the badge value to 0 using the new method
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Failed to reset badge count: \(error.localizedDescription)")
            } else {
                print("Badge count reset to 0")
            }
        }

        // Remove all notifications from Notification Center
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
