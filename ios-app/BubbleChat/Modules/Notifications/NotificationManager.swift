//
//  NotificationManager.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.10.2024.
//

import Foundation
import UIKit
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private init() {}

    func requestPushNotificationPermissions() {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
//                    print("Push notification permission granted")
                }
            } else {
                if let error = error {
                    print("Failed to request push notification permission: \(error.localizedDescription)")
                } else {
                    print("Push notification permission denied by user")
                }
            }
        }
    }
}
