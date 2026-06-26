//
//  verifyCode.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 03.10.2024.
//

import Alamofire
import Foundation
import KeychainAccess
import SwiftUI

// Function to verify the code
func verifyCode(viewModel: AuthViewModel, appSettings: AppSettings) {
    // Check for an empty code
    guard viewModel.code.count == 4 else {
        viewModel.errorCode = true
        viewModel.errorMsg = "Verification code is required"
        return
    }

    // Set the loading state
    viewModel.loading = true
    viewModel.errorCode = false

    guard let user = viewModel.currentUser else {
        viewModel.loading = false
        viewModel.errorMsg = "Invalid user"
        return
    }

    let parameters: [String: String] = [
        "clientCode": viewModel.code,
        "userId": user.id.uuidString,
    ]

    // Perform the request via Alamofire
    AF.request("\(HOST)/auth/verify_code", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
        .validate(statusCode: 200 ..< 300)
        .responseDecodable(of: PrivateUser.self) { response in
            // Stop loading
            viewModel.loading = false

            switch response.result {
            case let .success(verifyCodeResponse):
                do {
                    try AppDatabase.shared.dbPool.write { db in
                        let currentUser = User(serverId: verifyCodeResponse.id,
                                               firstName: verifyCodeResponse.firstName,
                                               lastName: verifyCodeResponse.lastName,
                                               avatar: verifyCodeResponse.avatar,
                                               phone: verifyCodeResponse.phone)

                        try currentUser.insert(db)
                    }
                } catch {
                    print(error)
                    return
                }

                let keychain = Keychain(service: "com.Bubble-Chat")
                do {
                    try keychain.set(verifyCodeResponse.accessToken, key: "accessToken")
                    print("Token saved successfully!")
                } catch {
                    viewModel.errorCode = true
                    viewModel.errorMsg = "Failed to save token: \(error)"
                    print("Error saving token: \(error)")
                    return
                }

                print(verifyCodeResponse)
                UserDefaults.standard.set(verifyCodeResponse.id.uuidString, forKey: "id")

                print("User data saved successfully!")

                appSettings.isAuth = true
                UserDefaults.standard.set(true, forKey: "isAuth")
                UserDefaults.standard.synchronize()

            case let .failure(error):
                // Handle the request error
                viewModel.errorCode = true
                viewModel.errorMsg = error.localizedDescription
                print("Failed to verify code: \(error)")
            }
        }
}
