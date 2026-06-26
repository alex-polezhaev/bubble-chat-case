//
//  CenterChatHeaderElement.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import SwiftUI

struct CenterChatHeaderElement: View {
    var title: String?
    var avatar: String?
    var status: UserStatus?

    var body: some View {
        HStack {
            ContactHeaderPlate(title: title ?? "", avatar: avatar, status: status)
        }
        .background(Capsule().fill(.white).frame(height: 48))
    }
}
