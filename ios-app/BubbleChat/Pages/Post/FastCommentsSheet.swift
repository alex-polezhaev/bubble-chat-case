//
//  FastCommentsSheet.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 05.12.2024.
//

import SwiftUI

#Preview(body: {
    TestA()
})

struct TestA: View {
    @State var isPresented: Bool = true
    var body: some View {
        VStack {
            Color.blue.opacity(0.1)
        }
        .sheet(isPresented: $isPresented) {
            FastCommentsSheet()
                .presentationDragIndicator(.visible)
        }
    }
}

struct FastCommentsSheet: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                SheetChatTitle()
                Spacer()
                CloseSheetButton()
            }
            .padding(.horizontal)
            .padding(.top)

            ScrollView {
                LazyVStack {
//                    CommentMessage(isMine: true, text: "hello Nigga!")
//                    CommentMessage(isMine: false, text: "ji")
//                    CommentMessage(isMine: false, text: "good!")
//                    CommentMessage(isMine: true, text: "job!")
//                    CommentMessage(isMine: true, text: "hello Nigga!")
//                    CommentMessage(isMine: false, text: "ji")
//                    CommentMessage(isMine: false, text: "good!")
//                    CommentMessage(isMine: true, text: "job!")
//                    CommentMessage(isMine: true, text: "hello Nigga!")
//                    CommentMessage(isMine: false, text: "ji")
//                    CommentMessage(isMine: false, text: "good!")
//                    CommentMessage(isMine: true, text: "job!")
//                    CommentMessage(isMine: true, text: "hello Nigga!")
//                    CommentMessage(isMine: false, text: "ji")
//                    CommentMessage(isMine: false, text: "good!")
//                    CommentMessage(isMine: true, text: "job!")
//                    CommentMessage(isMine: true, text: "hello Nigga!")
//                    CommentMessage(isMine: false, text: "ji")
//                    CommentMessage(isMine: false, text: "good!")
//                    CommentMessage(isMine: true, text: "job!")
                }.padding(.horizontal)
            }.defaultScrollAnchor(.bottom)

//            FastCommentField(stackModel: stackModel, chatItem: <#ChatItem#>)
//                .padding(.horizontal)
//                .padding(.bottom)

        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
