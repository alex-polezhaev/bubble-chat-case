import SwiftUI

struct FastCommentSheet: View {
    @EnvironmentObject var homeSettings: HomeSettings
    @EnvironmentObject var chatModel: ChatViewModel
    @EnvironmentObject var stackModel: StackViewModel

    @State private var text: String = ""
    @FocusState private var isFocused: Bool // Controls the focus state

    @ObservedObject private var keyboardResponder = KeyboardResponder()

    var body: some View {
        VStack {
            Divider()
                .frame(height: 0.5)
                .padding(.horizontal, 2)
                .opacity(0.5)

            CommentInfoPanel()

            Divider()
                .frame(height: 0.5)
                .padding(.horizontal, 2)
                .opacity(0.5)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(stackModel.comments, id: \.id) { comment in
                            CommentMessage(comment: comment)
                                .transition(.customScaleTransition)
                                .id(comment.id) // Bind an ID to each element
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let lastComment = stackModel.comments.last {
                            proxy.scrollTo(lastComment.id, anchor: .top)
                        }
                    }
                }
                .onChange(of: stackModel.comments) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let lastComment = stackModel.comments.last {
                            proxy.scrollTo(lastComment.id, anchor: .top)
                        }
                    }
                }
                .onChange(of: keyboardResponder.isKeyboardVisible) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let lastComment = stackModel.comments.last {
                            withAnimation {
                                proxy.scrollTo(lastComment.id, anchor: .top)
                            }
                        }
                    }
                }
            }

            HStack {
                ZStack(alignment: .leading) {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 25,
                        bottomLeadingRadius: 25,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 15
                    )
                    .fill(.gray.opacity(0.1))
                    .frame(height: 40)
                    TextField("Write a comment", text: self.$text)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .padding(.leading)
                        .focused($isFocused) // Bind to the focus state
                }
                .padding(.top, 2)
                Button("send", action: sendComment)
            }
        }
        .padding(10)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isFocused = true // Set focus on appear
            }
        }
    }

    private func sendComment() {
        guard text.count > 0 else {
            homeSettings.showAlert(title: "Enter a comment", message: "")
            return
        }

        Task {
            do {
                try await SendCommentUseCase(text: text,
                                             post: stackModel.currentPost,
                                             replyToId: nil,
                                             replyEntityType: nil,
                                             chat: chatModel.chat).execute()

                DispatchQueue.main.async {
                    self.text = ""
                }
            } catch {
                homeSettings.showAlert(title: "Send error", message: "\(error)")
            }
        }
    }
}
