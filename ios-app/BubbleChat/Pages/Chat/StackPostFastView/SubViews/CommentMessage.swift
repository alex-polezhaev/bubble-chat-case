import Lottie
import SwiftUI

struct CommentMessage: View {
    @EnvironmentObject var chatModel: ChatViewModel

    var text: String
    var rectangle: UnevenRoundedRectangle
    var isMine: Bool

    var bodyColor: Color
    var textColor: Color

    @State var replyPlateWidth: CGFloat = 0

    var comment: Comment

    init(comment: Comment) {
        let isMine = UserManager.shared.checkIfMyMember(memberId: comment.memberId)
        let bottomLeadingRadius: CGFloat = isMine ? 10 : 0
        let bottomTrailingRadius: CGFloat = isMine ? 0 : 10

        bodyColor = isMine ? .pink : .gray.opacity(0.1)

        rectangle = UnevenRoundedRectangle(
            topLeadingRadius: 10,
            bottomLeadingRadius: bottomLeadingRadius,
            bottomTrailingRadius: bottomTrailingRadius,
            topTrailingRadius: 10
        )

        text = comment.text
        self.isMine = isMine
        textColor = isMine ? .white : .black
        self.comment = comment
    }

    var body: some View {
        HStack {
            if isMine { Spacer().frame(width: 20) }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 0) {
//                CommentReplyPlate(width: replyPlateWidth, isMine: isMine)
//                    .padding(.bottom, 6)

                Text(text)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    replyPlateWidth = geometry.size.width
                                }
                        }
                    )

                HStack {
                    switch comment.status {
                    case .sending:
                        LottieView(animation: .named("sending-spinner-white"))
                            .playing(loopMode: .loop)
                            .frame(width: 14, height: 14)

                    case .failed:
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)

                    default:
                        Text(comment.status.rawValue)
                    }

                    Text(comment.createdAt, style: .time)
                }
                .frame(height: 6)
                .padding(.top, 3)
                .opacity(0.8)
                .font(.system(size: 10, weight: .regular, design: .rounded))
            }
            .foregroundStyle(textColor)
            .padding(7)
            .padding(.horizontal, 6)
            .background(
                rectangle
                    .fill(bodyColor)
                    .overlay {
                        rectangle
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
                            .padding(1)
                    }
            )

            if !isMine { Spacer().frame(width: 20) }
        }
        .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
        .onAppear {
            makeRead()
        }
    }

    func makeRead() {
        guard !UserManager.shared.checkIfMyMember(memberId: comment.memberId),
              comment.status == .delivered
        else {
            return
        }

        Task {
            try await UpdateStatusUseCase(post: nil,
                                          comment: comment,
                                          layer: nil,
                                          reaction: nil,
                                          deliveryStatus: .read,
                                          chat: chatModel.chat).execute()
        }
    }
}
