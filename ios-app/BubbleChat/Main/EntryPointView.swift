//
//  EntryPointView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 01.09.2024.
//

import SwiftUI

struct EntryPointView: View {
    @StateObject private var homeSettings = HomeSettings() // Create the tab state object

    var body: some View {
        NavigationStack(path: $homeSettings.navigationPath) {
            ZStack(alignment: .bottom) {
                TabView(selection: self.$homeSettings.selectedTab) {
                    VStack {
                        ProfileView()
                    }
                    .tag(Tab.profile)
                    .ignoresSafeArea(.all)

                    VStack {
                        HomeView()
                    }
                    .tag(Tab.home)
                    .ignoresSafeArea(.all)

                    VStack {
                        MenuCameraView()
                    }
                    .tag(Tab.camera)
                    .ignoresSafeArea(.all)
                }

                NavigationMenu()
                    .offset(y: -40)

            }.frame(width: WIDTH, height: HEIGHT)
                .ignoresSafeArea(.all)
                .background(Color.background)
                .navigationDestination(for: Chat.self) { chat in
                    ChatView(chat: chat, activityModel: nil)
                        .navigationBarBackButtonHidden()
                }

        }.animation(.linear, value: homeSettings.selectedTab)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .environmentObject(homeSettings)
            .alert(isPresented: $homeSettings.alertIsPresented) {
                Alert(
                    title: Text(self.homeSettings.alertTitle),
                    message: Text(self.homeSettings.alertMessage),
                    primaryButton: .default(Text(self.homeSettings.alertButtonTitle)) {
                        self.homeSettings.okAction?() // Execute the OK action
                        self.homeSettings.clearAlert()
                    },
                    secondaryButton: .cancel(Text(self.homeSettings.alertCancelButtonTitle)) {
                        self.homeSettings.cancelAction?() // Execute the Cancel action
                        self.homeSettings.clearAlert()
                    }
                )
            }
    }
}

class HomeSettings: ObservableObject {
    @Published var selectedTab: Tab = .home // Home is the default initial tab
    @Published var navigationPath = NavigationPath() // Stores the navigation path

    @Published var showCameraPage = false
    @Published var showCreatePostSheet = false
    @Published var showFiendList = false

    @Published var alertIsPresented: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var alertButtonTitle: String = "OK"
    @Published var alertCancelButtonTitle: String = "Cancel"
    @Published var okAction: (() -> Void)?
    @Published var cancelAction: (() -> Void)?

    func showAlert(title: String, message: String, okAction: (() -> Void)? = nil) {
        alertIsPresented = true
        alertTitle = title
        alertMessage = message
        self.okAction = okAction
        cancelAction = nil
    }

    func showConfirmationAlert(
        title: String,
        message: String,
        okAction: (() -> Void)? = nil,
        cancelAction: (() -> Void)? = nil
    ) {
        alertIsPresented = true
        alertTitle = title
        alertMessage = message
        self.okAction = okAction
        self.cancelAction = cancelAction
    }

    func clearAlert() {
        alertIsPresented = false
        alertTitle = ""
        alertMessage = ""
        alertButtonTitle = "OK"
        alertCancelButtonTitle = "Cancel"
        okAction = nil
        cancelAction = nil
    }
}

// Enum for tabs
enum Tab: Hashable {
    case profile
    case home
    case camera
}
