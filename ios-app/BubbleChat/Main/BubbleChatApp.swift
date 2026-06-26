//
//  BubbleChatApp.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 01.09.2024.
//

import SwiftUI

@main
struct BubbleChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            if appSettings.isAuth {
                ConfiguratorView()
            } else {
                AuthView()
            }
        }
        .environmentObject(appSettings)
    }
}

class AppSettings: ObservableObject {
    @Published var isAuth: Bool
    @Published var debugShow: Bool = false

    init() {
        isAuth = UserDefaults.standard.bool(forKey: "isAuth")
    }
}
