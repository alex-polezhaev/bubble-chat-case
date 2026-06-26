//
//  LeftHomeHeaderElement.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import SwiftUI

struct LeftHomeHeaderElement: View {
    @EnvironmentObject var homeSettings: HomeSettings

    var body: some View {
        Button(action: {
            homeSettings.showAlert(title: "Under development", message: "Deleting and marking list items as read")
        }) {
            ZStack {
                Capsule().fill(.white)
                Text("Edit")
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
            }.frame(width: 65, height: 48)
        }
    }
}
