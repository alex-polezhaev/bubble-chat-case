//
//  ConfiguratorView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 16.10.2024.
//

import SwiftUI

struct ConfiguratorView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var appSettings: AppSettings
    @StateObject var loopSendReq = InfiniteLoopManager()

    init() {
        GRPCManager.shared.initialize()
        do {
            try UserManager.shared.observeMyData()
        } catch {
            fatalError("Could not load user for User Manager: \(error)")
        }

        NotificationManager.shared.requestPushNotificationPermissions()
    }

    var body: some View {
        EntryPointView()
            .sheet(isPresented: $appSettings.debugShow) {
                ModelListView()
            }
            .onChange(of: scenePhase) {
                switch scenePhase {
                case .active:
                    print("App is active")
//                        ContactWithUserActivityProvider.shared.startStream()
                // Perform actions when the app becomes active
                case .inactive:
                    print("App is inactive")
                // Perform actions when the app becomes inactive
                case .background:
                    print("App is in background")
//                        ClientToServerProvider.shared.clean()
//                        ServerToClientProvider.shared.clean()
//                        ContactWithUserActivityProvider.shared.clean()
                // Perform actions when the app moves to the background
                @unknown default:
                    print("Unknown scene phase")
                }
            }
            .onAppear {
                allActivitySetOffline()
            }
    }

    func allActivitySetOffline() {
        Task {
            try AppDatabase.shared.dbPool.write { db in
                // Fetch all activities
                let activities = try UserActivity.fetchAll(db)

                for var activity in activities {
                    activity.status = .offline // Change the status
                    try activity.save(db) // Save the changes
                }
            }
        }
    }
}

import Combine
import Foundation

class InfiniteLoopManager: ObservableObject {
    private var cancellable: AnyCancellable?

    init() {
        startInfiniteLoop()
    }

    private func startInfiniteLoop() {
        cancellable = Timer
            .publish(every: 5.0, on: .main, in: .common) // 2-second interval
            .autoconnect()
            .sink { [weak self] _ in
                self?.performTask()
            }
    }

    private func performTask() {
        Task(priority: .userInitiated) {
            QueueRequestManager().sendPendingRequests()
        }
    }

    deinit {
        cancellable?.cancel() // Cancel the subscription when the object is deallocated
    }
}
