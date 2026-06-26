//
//  Constants.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 03.09.2024.
//

import Alamofire
import KeychainAccess
import SwiftUI

// Production backend (public). REST base URL and gRPC host/port.
var HOST: String = "https://your-domain.example" + "/api"
var GRPC_HOST: String = "your-domain.example"
var GRPC_PORT: Int = 443

// Development gRPC endpoint. Replace with your own dev tunnel when running against a local backend.
var DEV_GRPC_HOST: String = "your-dev-tunnel.example"
var DEV_GRPC_PORT: Int = 0

var WIDTH: CGFloat = UIScreen.main.bounds.width
var HEIGHT: CGFloat = UIScreen.main.bounds.height

func getBearerHeader() -> HTTPHeaders {
    let keychain = Keychain(service: "com.Bubble-Chat")
    var headers: HTTPHeaders = [:]

    do {
        if let accessToken = try keychain.get("accessToken") {
            headers = [
                "Authorization": "Bearer \(accessToken)",
            ]
        } else {
            print("No token found")
            logout("No token found")
        }
    } catch {
        print("Failed to retrieve token: \(error)")
        logout("no keychain token")
    }

    return headers
}

func getBearerToken() -> String {
    let keychain = Keychain(service: "com.Bubble-Chat")

    if let accessToken = try? keychain.get("accessToken") {
        return "Bearer \(accessToken)"
    } else {
        print("No token found")
        logout("no keychain token")
    }

    return ""
}

func getAccessToken() -> String {
    let keychain = Keychain(service: "com.Bubble-Chat")

    if let accessToken = try? keychain.get("accessToken") {
        return accessToken
    } else {
        print("No token found")
        logout("no keychain token")
    }

    return ""
}

func logout(_: String) {
    // Logout hook. Clears the local session; wire up token removal and state reset as needed.
    Task {
        // await DataManager.shared.deleteData()
    }
}
