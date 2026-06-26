//
//  ContactBadgePhotoPlaceholder.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 10.10.2024.
//

import SwiftUI

struct ContactBadgePhotoPlaceholder: View {
    var contact: Contact

    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.1))
            Text(getAvatarString(from: contact.givenName + contact.familyName))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.black.opacity(0.5))
        }
        .frame(width: 48)
    }
}
