//
//  CreatePostSheet.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 05.12.2024.
//

import SwiftUI
import SwiftUIIntrospect

struct CreatePostSheet: View {
    @EnvironmentObject var chatModel: ChatViewModel
    @EnvironmentObject var activityModel: ChatActivityViewModel
    @Environment(\.dismiss) var dismiss

    @State var title: String = ""
    @State var description: String = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                HStack {
                    ContactHeaderPlate(title: activityModel.title ?? "no title", avatar: activityModel.picture, status: activityModel.userStatus)
                    Spacer()
                    CloseSheetButton()
                }

                MultilineTextField(text: $title, textSize: 24, textWeight: .bold)
                    .frame(height: 60)
                    .padding(.vertical, 24)

                MultilineTextField(text: $description, textSize: 16, textWeight: .regular)

            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()

            HStack {
                Spacer()
                Button {
                    sendPost()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .padding(12)
                        .foregroundStyle(.white)
                        .background(.pink)
                        .clipShape(.circle)
                }

            }.padding()
                .background(
                    Rectangle()
                        .fill(.white)
                        .frame(height: 40)
                )
        }
    }

    func sendPost() {
        Task {
            try await SendPostUseCase(videoUrl: nil,
                                      chat: chatModel.chat,
                                      title: title,
                                      description: description,
                                      replyToId: nil,
                                      replyEntityType: nil,
                                      postType: .topic)
                .execute {
                    Task { @MainActor in
                        dismiss()
                    }
                }
        }
    }
}

struct CloseSheetButton: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(.gray)
                .padding(8)
                .background(.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

struct SheetChatTitle: View {
    var body: some View {
        HStack {
            Image("avatar")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text("Emily Johnson")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text("Offline")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
        }
    }
}

struct MultilineTextField: View {
    @Binding var text: String
    var placeholder: String = "Enter text here..."

    var textSize: CGFloat
    var textWeight: Font.Weight

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.system(size: textSize, weight: textWeight))

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
        }
        .fontDesign(.rounded)
    }
}
