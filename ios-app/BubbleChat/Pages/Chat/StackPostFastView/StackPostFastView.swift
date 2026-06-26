import Lottie
import SwiftUI

struct StackPostFastView: View {
    @EnvironmentObject var homeSettings: HomeSettings

    @StateObject var viewModel: StackViewModel
    @EnvironmentObject var chatModel: ChatViewModel

    init(posts: [Post]) {
        _viewModel = StateObject(wrappedValue: StackViewModel(posts: posts))
    }

    var body: some View {
//        NavigationLink(
//            destination: StackPostBigView()
//                .environmentObject(viewModel)
//                .navigationBarBackButtonHidden(),
//            label: { postFastView })
//            .buttonStyle(.plain)
        postFastView
    }
}

extension StackPostFastView {
    var postFastView: some View {
        VStack(spacing: 0) {
            HStack {
                if self.viewModel.isMine { Spacer() }

                VStack(spacing: 16) {
                    if viewModel.currentPost.postType != .topic {
                        StackMediaView()
                            .environmentObject(self.viewModel)
                    }

                    VStack {
                        if viewModel.currentPost.title != "" || viewModel.currentPost.description != "" {
                            PostTextData(title: self.viewModel.currentPost.title,
                                         description: self.viewModel.currentPost.description)
                        }

                        //                    PostReplyPlate(isMine: isMine)
                        if self.viewModel.indexAmount > 1 {
                            UIKitPageControl(numberOfPages: self.viewModel.indexAmount,
                                             currentPage: self.$viewModel.currentIndex)
                        }

                    }.padding(.horizontal)

                    PostComments()
                        .environmentObject(self.viewModel)
                }
                .background(PostBackground(postType: self.viewModel.currentPost.postType, isMine: self.viewModel.isMine))
                .frame(width: WIDTH * 0.75)
                .padding(10)

                if !self.viewModel.isMine { Spacer() }
            }
            HStack {
                if self.viewModel.isMine { Spacer() }
                switch viewModel.currentPost.status {
                case .sending:
                    LottieView(animation: .named("sending-spinner"))
                        .playing(loopMode: .loop)
                        .frame(width: 14, height: 14)
                case .uploading:
                    LottieView(animation: .named("sending-spinner"))
                        .playing(loopMode: .loop)
                        .frame(width: 14, height: 14)
                case .failed:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                default:
                    Text(viewModel.currentPost.status.rawValue)
                }

                Text(viewModel.currentPost.createdAt, style: .time)
                if !self.viewModel.isMine { Spacer() }
            }
            .padding(.horizontal)
            .opacity(0.8)
            .font(.system(size: 12, weight: .regular, design: .rounded))
        }
        .onAppear {
            makeRead()
        }
        .onChange(of: viewModel.currentPost) {
            makeRead()
        }
    }

    func makeRead() {
        guard !UserManager.shared.checkIfMyMember(memberId: viewModel.currentPost.memberId),
              viewModel.currentPost.status == .delivered
        else {
            return
        }

        Task {
            try await UpdateStatusUseCase(post: viewModel.currentPost,
                                          comment: nil,
                                          layer: nil,
                                          reaction: nil,
                                          deliveryStatus: .read,
                                          chat: chatModel.chat).execute()
        }
    }
}

import SwiftUI

extension View {
    func scalable(onTrigger: Binding<Bool>, scaleFactor: CGFloat = 1.05, duration: Double = 0.1) -> some View {
        scaleEffect(onTrigger.wrappedValue ? scaleFactor : 1.0)
            .animation(.easeInOut(duration: duration), value: onTrigger.wrappedValue)
            .onChange(of: onTrigger.wrappedValue) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        onTrigger.wrappedValue = false
                    }
                }
            }
    }
}
