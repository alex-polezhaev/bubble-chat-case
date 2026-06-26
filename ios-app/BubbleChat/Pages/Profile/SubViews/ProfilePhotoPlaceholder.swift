//
//  ProfilePhotoPlaceholder.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 10.10.2024.
//

import SwiftUI

struct ProfilePhotoPlaceholder: View {
    var string: String

    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.1))
            Text(getAvatarString(from: string))
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .foregroundStyle(.black.opacity(0.5))
        }
    }
}
