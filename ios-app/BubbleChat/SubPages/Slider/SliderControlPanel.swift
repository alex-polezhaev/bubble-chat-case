import SwiftUI

struct SliderControlPanel: View {
    @State private var offset: CGFloat = 0
    @State private var viewWidth: CGFloat = 200
    @State private var viewHeight: CGFloat = 60
    @State private var unlockThreshold: CGFloat = 1000
    @State private var padding: CGFloat = 4

    var slideTitle: String
    var replyDescription: String?
    var replyImage: String?

    var onSlide: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.pink)
                .scaleEffect(offset / CGFloat(8))
            Capsule()
                .fill(.white)

            HStack(spacing: 0) {
                Image(systemName: replyDescription != nil ? "arrowshape.turn.up.left.fill" : "video.fill")
                    .font(.title3)
                    .foregroundColor(.pink)
                    .frame(width: viewHeight, height: viewHeight)
                    .background(Color.pink.opacity(0.1))
                    .clipShape(Circle())
                    .padding(.leading, padding)
                    .offset(x: offset)
                    .gesture(slideGesture)

                HStack {
                    if let replyImage = replyImage {
                        Image(replyImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(BubbleShape())
                    }

                    VStack(alignment: .leading) {
                        Text(slideTitle)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.pink)
                        if let replyDescription = replyDescription {
                            Text("Bubble 43 seconds")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.black)
                                .lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .opacity(CGFloat(1) - offset / CGFloat(25))
            }

            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            viewWidth = geometry.size.width
                            viewHeight = geometry.size.height
                            unlockThreshold = viewWidth - (viewHeight + padding * 2)
                        }
                }
            )
        }
    }

    private var slideGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                // Use only gesture.translation.width
                let newOffset = max(0, min(gesture.translation.width, unlockThreshold))
                offset = newOffset
            }
            .onEnded { _ in
                if offset >= unlockThreshold - 20 {
                    // If the threshold is reached
                    withAnimation {
                        offset = 0
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        onSlide?()
                    }
                } else {
                    // Return to the initial position
                    withAnimation {
                        offset = 0
                    }
                }
            }
    }
}
