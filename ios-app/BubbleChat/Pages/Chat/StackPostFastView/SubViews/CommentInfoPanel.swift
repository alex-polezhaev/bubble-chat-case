import Kingfisher
import SwiftUI

struct CommentInfoPanel: View {
    @EnvironmentObject var stackModel: StackViewModel

    var body: some View {
        HStack {
            Text("\(stackModel.comments.count) comments")
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer()

            HStack(spacing: 0) {
                ForEach(0 ..< min(stackModel.commentsAvatars.count, 3), id: \.self) { index in
                    KFImage(URL(string: HOST + stackModel.commentsAvatars[index]))
                        .placeholder { _ in
                            ProgressView()
                        }
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                        .clipShape(.circle)
                        .offset(x: -12 * CGFloat(index))
                }
            }

            if stackModel.commentsAvatars.count > 3 {
                Text("+ \(stackModel.commentsAvatars.count - 3)")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
            }
        }
        .padding(.horizontal)
    }
}
