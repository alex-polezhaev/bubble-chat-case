import SwiftUI

struct CommentReplyPlate: View {
    var width: CGFloat
    var isMine: Bool

    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isMine ? .white : .pink)
                    .frame(width: 3)
                Image("avatar")
                    .resizable()
                    .scaledToFit()
                    .clipShape(BubbleShape())

                VStack(alignment: .leading) {
                    Text("Dad")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("Bubble 43 seconds")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                }
                .lineLimit(1)
                .foregroundStyle(isMine ? .white : .black)

            }.padding(.vertical, 6)
                .padding(.horizontal, 6)
        }
        .frame(minWidth: width, alignment: .leading)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isMine ? .white.opacity(0.5) : .white)
        )
    }
}
