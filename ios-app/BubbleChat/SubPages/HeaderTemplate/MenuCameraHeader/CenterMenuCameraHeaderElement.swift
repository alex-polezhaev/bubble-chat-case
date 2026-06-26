//
//  CenterMenuCameraHeaderElement.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import Kingfisher
import SwiftUI

struct CenterMenuCameraHeaderElement: View {
    @Binding var selectedChat: Chat?
    @Binding var showSelectSheet: Bool

    @EnvironmentObject var activityModel: CameraMenuViewModel

    var body: some View {
        Button {
            showSelectSheet = true
        } label: {
            HStack {
                if let chat = selectedChat {
                    KFImage(URL(string: HOST + (activityModel.picture ?? "")))
                        .resizable()
                        .placeholder {
                            ZStack {
                                Circle()
                                    .fill(.black.opacity(0.1))
                                Text(activityModel.title ?? "")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.black.opacity(0.5))
                            }
                        }
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 36, height: 36)
                        .padding(.horizontal, 6)
                        .foregroundStyle(.black)

                    Text(activityModel.title ?? "")
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .foregroundStyle(.black)

                    Button {
                        selectedChat = nil
                    } label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }.padding(.trailing)
                } else {
                    HStack {
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text("Choose friend")
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                    }.padding(.horizontal)
                }
            }
            .background(
                Capsule().fill(.white).frame(height: 48)
            )
        }
    }
}
