//
//  LeftMenuCameraHeaderElement.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import SwiftUI

struct LeftMenuCameraHeaderElement: View {
    @EnvironmentObject var homeSettings: HomeSettings

    var body: some View {
        Button(action: {
            homeSettings.selectedTab = .home
        }) {
            ZStack {
                Circle().fill(.white)
                Image(systemName: "chevron.left")
                    .fontWeight(.bold)
                    .font(.system(size: 11))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)

            }.frame(width: 48, height: 48)
        }
    }
}
