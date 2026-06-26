//
//  HomeView.swift
//  BubblePages
//
//  Created by polezhaev_aleksandr on 28.06.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var homeSettings: HomeSettings
    @EnvironmentObject var appSettings: AppSettings

    @ObservedObject var grpcManager = GRPCManager.shared

    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    var body: some View {
        ZStack {
            if !viewModel.chats.isEmpty {
                ScrollView {
                    HStack(alignment: .top) {
                        HomeColumnView(chats: viewModel.leftColumn)
                        HomeColumnView(chats: viewModel.rightColumn)
                    }
                    .padding(.horizontal)
                    .padding(.top, 120)
                }

            } else {
                NoChats()
            }
            VStack {
//                Button("contacts") {
//                    ContactManager.shared.startUpdating()
//                }
//                Button("debug") {
//                    appSettings.debugShow = true
//                }
//
//                Button("delete contacts") {
//                    Task {
//                        try AppDatabase.shared.dbPool.write { db in
//                            try Contact.deleteAll(db)
//                        }
//                    }
//                }
//
//                Button("send requests") {
//                    Task {
//                        QueueRequestManager().sendPendingRequests()
//                    }
//                }
//
//
//                Button("Start") {
//                    Task {
//                        ServerToClientProvider.shared.startStream()
//                    }
//                }
//                Button("Clean") {
//                    Task {
//                        try? GRPCManager.shared.shutdown()
//                    }
//                }
//
//                Button("Print") {
//                    Task {
//                        print(GRPCManager.shared.connection.connectivity.state)
//                    }
//                }
//
            }

            HeaderTemplate(leftElement: LeftHomeHeaderElement(),
                           centerElement: CenterHomeHeaderElement(),
                           rightElement: RightHomeHeaderElement())
        }
        .sheet(isPresented: $homeSettings.showFiendList) {
            FriendListView()
                .presentationDragIndicator(.visible)
        }
        .environmentObject(viewModel)
    }
}

struct GrpcState: View {
    @ObservedObject var grpcManager = GRPCManager.shared

    var body: some View {
        HStack(spacing: 4) {
            if grpcManager.connectionState == .transientFailure {
                Text("Url error")
            } else {
                Circle()
                    .fill(grpcManager.isSTCActive ? .green : .red)
                    .frame(width: 6)
                Circle()
                    .fill(grpcManager.isCTSActive ? .green : .red)
                    .frame(width: 6)
                Circle()
                    .fill(grpcManager.isCWUAActive ? .green : .red)
                    .frame(width: 6)
            }
        }.frame(height: 6)
    }
}
