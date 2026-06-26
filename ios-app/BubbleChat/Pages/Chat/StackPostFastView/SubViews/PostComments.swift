import SwiftUI

struct PostComments: View {
    @EnvironmentObject var stackModel: StackViewModel

    @State var showCommentsSheet: Bool = false

    var body: some View {
        VStack {
            if stackModel.comments.count > 0 {
                Divider()
                    .frame(height: 0.5)
                    .padding(.horizontal, 2)
                    .opacity(0.5)

                CommentInfoPanel()

                Divider()
                    .frame(height: 0.5)
                    .padding(.horizontal, 2)
                    .opacity(0.5)

                VStack {
                    ForEach(stackModel.comments.suffix(3), id: \.self) { comment in
                        CommentMessage(comment: comment)
                    }
                }
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
            }

            Button {
                showCommentsSheet = true
            } label: {
                ZStack(alignment: .leading) {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 25,
                        bottomLeadingRadius: 25,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 15
                    )
                    .fill(.gray.opacity(0.1))
                    .frame(height: 40)
                    Text("Write a comment")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .padding(.leading)
                        .foregroundStyle(.lightGrayText)

                }.padding(.top, 2)
                    .padding(.horizontal)
            }
        }
        .padding(.bottom)
        .sheet(isPresented: $showCommentsSheet) {
            FastCommentSheet()
                .presentationDragIndicator(.visible)
        }
    }
}
