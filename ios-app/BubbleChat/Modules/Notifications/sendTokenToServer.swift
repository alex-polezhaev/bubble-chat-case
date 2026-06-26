//
//  sendTokenToServer.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import Alamofire
import Foundation

func sendTokenToServer(deviceToken: String) {
    let defaults = UserDefaults.standard

    let isDeviceTokenSent = defaults.bool(forKey: "isDeviceTokenSent")

    if isDeviceTokenSent { return }

    // Request body
    let parameters: [String: Any] = [
        "deviceToken": deviceToken,
    ]

    // Perform the POST request
    AF.request("\(HOST)/users/deviceToken", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getBearerHeader())
        .validate(statusCode: 200 ... 200)
        .response { response in
            switch response.result {
            case let .success(serverResponse):
                print("Device token successfully sent to server: \(String(describing: serverResponse))")
                defaults.set(true, forKey: "isDeviceTokenSent")
            case let .failure(error):
                print("Failed to send device token: \(error)")
            }
        }
}
