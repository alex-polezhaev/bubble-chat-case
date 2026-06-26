import SwiftUI

struct PostReplyPlate: View {
    var isMine: Bool

    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.pink)
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
                .foregroundStyle(isMine ? .pink : .black)
            }.padding(.vertical, 6)
                .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 45)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isMine ? .pink.opacity(0.1) : .gray.opacity(0.1))
        )
    }
}
