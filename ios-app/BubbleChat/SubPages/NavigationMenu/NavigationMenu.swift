//
//  NavigationMenu.swift
//  BubblePages
//
//  Created by polezhaev_aleksandr on 01.07.2024.
//

import Foundation
import Lottie
import SwiftUI

struct NavigationMenu: View {
    @EnvironmentObject var homeSettings: HomeSettings

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.white)
                .frame(width: 165, height: 55)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.20), radius: 40, y: 8)

            HStack(spacing: 22) {
                // PROFILE BUTTON
                Button(action: {
                    changeTabWithDelay(to: .profile)
                }, label: {
                    if homeSettings.selectedTab == .profile {
                        LottieView(animation: .named("account-icon"))
                            .playing(loopMode: .playOnce)
                            .frame(width: 28, height: 28)
                    } else {
                        Image("account-inactive-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                })

                // CHAT BUTTON
                Button(action: {
                    changeTabWithDelay(to: .home)
                }, label: {
                    if homeSettings.selectedTab == .home {
                        LottieView(animation: .named("chat-icon"))
                            .playing(loopMode: .playOnce)
                            .frame(width: 28, height: 28)

                    } else {
                        Image("chat-inactive-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                })

                // CAMERA BUTTON
                Button(action: {
                    changeTabWithDelay(to: .camera)
                }, label: {
                    if homeSettings.selectedTab == .camera {
                        LottieView(animation: .named("camera-icon"))
                            .playing(loopMode: .playOnce)
                            .frame(width: 28, height: 28)
                    } else {
                        Image("camera-inactive-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                })
            }
        }
    }

    // Function to switch tabs with a delay
    private func changeTabWithDelay(to tab: Tab) {
        DispatchQueue.main.async {
            withAnimation(nil) {
                homeSettings.selectedTab = tab
            }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}
