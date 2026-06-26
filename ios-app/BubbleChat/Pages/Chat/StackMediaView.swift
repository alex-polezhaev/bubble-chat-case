import GRDB
import Lottie
import SwiftUI

struct StackMediaView: View {
    @EnvironmentObject var stackModel: StackViewModel

    @State var scaleTrigger: Bool = false

    var body: some View {
        ZStack {
            ForEach(self.stackModel.posts, id: \.id) { post in
                if let media = try? post.media {
                    PostMediaView(media: media, type: .video_controlable)
                        .opacity(self.stackModel.currentPost.mediaId == post.mediaId ? 1 : 0)
                        .allowsHitTesting(self.stackModel.currentPost.mediaId == post.mediaId)
                        .scalable(onTrigger: self.$scaleTrigger)
                        .onChange(of: self.stackModel.currentPost) {
                            if self.stackModel.currentPost == post {
                                self.scaleTrigger = true
                            }
                        }
                }
            }

            //            VStack {
            //                Text(stackModel.currentPostItem.video?.id.uuidString ?? "no video 1")
            //                Text(stackModel.secondPostItem?.video?.id.uuidString ?? "no video 2")
            //                Text(stackModel.thirdPostItem?.video?.id.uuidString ?? "no video 3")
            //            }

            //            Image("mock-1")
            //                .resizable()
            //                .scaledToFit()
            //                .clipShape(BubbleShape())
            //                .frame(width: 250)
            //                .rotationEffect(.degrees(-5))
            //                .offset(x: -8, y: -8)
            //
            //            Image("mock-2")
            //                .resizable()
            //                .scaledToFit()
            //                .clipShape(BubbleShape())
            //                .frame(width: 250)
            //                .rotationEffect(.degrees(5))
            //                .offset(x: 8, y: 8)
            //
        }
        .padding(.vertical, 25)
    }
}

struct PostMediaView: View {
    @EnvironmentObject var stackModel: StackViewModel
    @StateObject var viewModel: PostMediaViewModel
    @EnvironmentObject var chatModel: ChatViewModel

    init(media: Media, type: MediaViewRepresentType) {
        _viewModel = StateObject(wrappedValue: PostMediaViewModel(media: media, type: type))
    }

    var body: some View {
        VStack {
            if !self.viewModel.isLoading, let playerModel = viewModel.playerModel {
                ZStack {
                    PlayerVideoLayer()
                    if self.viewModel.mediaRepresentType == .video_controlable {
                        PlayerControlLayer()
                            .padding(20)
                    }
                }
                .environmentObject(playerModel)
                .overlay {
                    BubbleShape()
                        .trim(from: 0, to: 0.8)
                        .stroke(.ultraThinMaterial.blendMode(.lighten), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .padding(6)
                        .rotationEffect(.init(degrees: 90))
                }

            } else {
                ProgressView()
            }
        }
        .clipShape(BubbleShape())
        .frame(width: WIDTH * 0.65, height: WIDTH * 0.65)
        .shadow(color: .black.opacity(0.2), radius: 12, x: 4, y: 0)
        .onChange(of: stackModel.currentPost) {
            if self.stackModel.currentPost.mediaId != self.viewModel.media.id {
                DispatchQueue.main.async {
                    self.viewModel.playerModel?.pause()
                }
            }
            if self.stackModel.currentPost.mediaId == self.viewModel.media.id {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.stackModel.currentPost.mediaId == self.viewModel.media.id {
                        self.viewModel.playerModel?.play()
                    }
                }
            }
        }
        .onChange(of: viewModel.playerModel?.progress) { _, newValue in
            if let newValue, newValue > 0.95 {
                stackModel.nextPost()
            }
        }
        .onAppear {
            viewModel.loadPlayerModel()
        }
    }
}

@MainActor
class PostMediaViewModel: ObservableObject {
    let mediaRepresentType: MediaViewRepresentType
    @Published var isLoading: Bool = true

    @Published var playerModel: PlayerViewModel?

    @Published var isError: Bool = false

    let media: Media

    init(media: Media, type: MediaViewRepresentType) {
        self.media = media
        mediaRepresentType = type
    }

    func loadPlayerModel() {
        if let localUrl = CacheManager.shared.fileUrl(filename: media.id.uuidString + ".mp4", category: "videos") {
            playerModel = PlayerViewModel(videoUrl: localUrl)
            isLoading = false
            return
        }

        guard let mediaServerId = media.serverId else {
            isError = true
            isLoading = false
            return
        }

        Task(priority: .userInitiated) {
            guard let localUrl = try? await WebRequestManager().downloadAndCacheVideo(mediaServerId: mediaServerId, mediaClientId: media.id) else {
                await MainActor.run {
                    self.isError = true
                }
                return
            }
            DispatchQueue.main.async {
                self.playerModel = PlayerViewModel(videoUrl: localUrl)
                self.isLoading = false
            }
        }
    }
}

enum MediaViewRepresentType {
    case video_controlable
    case video_noncontrolable
    case video_noncontrolable_progress
}
