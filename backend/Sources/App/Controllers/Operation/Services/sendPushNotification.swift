//
//  sendPushNotification.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 01.10.2024.
//

import APNS
import Vapor

struct PushNotification {
    let title: String
    let message: String
}

func sendPushNotification(to user: User, payload: PushNotification, app: Application) async {
    let notification = APNSwiftPayload(
        alert: .init(
            title: payload.title,
            body: payload.message
        ),
        sound: .normal("default")
    )

    guard let token = user.deviceToken else {
        app.logger.error("Error: user \(user.firstName) \(user.lastName) has no deviceToken.")
        return
    }

    // Asynchronous notification sending
    do {
        try await app.apns.send(notification, to: token).get()
        app.logger.info("Push notification successfully sent to user \(user.firstName) \(user.lastName)")
    } catch {
        app.logger.error("Failed to send push notification to user \(user.firstName) \(user.lastName): \(error)")
    }
}
