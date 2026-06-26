//
//  ContactHeaderPlate.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.10.2024.
//

import Kingfisher
import SwiftUI

struct ContactHeaderPlate: View {
    var title: String
    var avatar: String?
    var status: UserStatus?

    var body: some View {
        HStack {
            KFImage(URL(string: HOST + (avatar ?? "")))
                .resizable()
                .placeholder {
                    ZStack {
                        Circle()
                            .fill(.black.opacity(0.1))
                        Text(title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                }
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: 36, height: 36)
                .padding(.horizontal, 6)
                .foregroundStyle(.black)

            VStack {
                Text(title)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
                if let status {
                    Text(status.rawValue)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .font(.system(size: 12))
                        .foregroundStyle(status == .online ? .pink : .black)
                }
                GrpcState()
            }
        }.padding(.trailing)
    }
}
