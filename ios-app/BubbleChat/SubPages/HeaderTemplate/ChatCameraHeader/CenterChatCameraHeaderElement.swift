//
//  CenterChatCameraHeaderElement.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import Kingfisher
import SwiftUI

struct CenterChatCameraHeaderElement: View {
    @EnvironmentObject var activityModel: ChatActivityViewModel

    var body: some View {
        HStack {
            ContactHeaderPlate(title: activityModel.title ?? "no titile", avatar: activityModel.picture, status: activityModel.userStatus)
        }
        .background(
            Capsule().fill(.white).frame(height: 48)
        )
    }
}
