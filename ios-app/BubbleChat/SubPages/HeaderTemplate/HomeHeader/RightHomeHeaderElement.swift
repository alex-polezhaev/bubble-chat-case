//
//  RightHomeHeaderElement.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import SwiftUI

struct RightHomeHeaderElement: View {
    @EnvironmentObject var homeSettings: HomeSettings

    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        Button(action: {
            homeSettings.showFiendList.toggle()
        }) {
            ZStack {
                Circle().fill(.white)
                Image(systemName: "person.badge.plus")
                    .fontWeight(.bold)
                    .font(.system(size: 18))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)

            }.frame(width: 48, height: 48)
        }
    }
}
