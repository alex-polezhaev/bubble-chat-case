////
////  BubblePage.swift
////  BubbleChat
////
////  Created by polezhaev_aleksandr on 12.09.2024.
////
//
// import BottomSheet
// import Foundation
// import SwiftUI
//
// struct StackPostFullView: View {
//    @ObservedObject private var keyboardResponder = KeyboardResponder()
//    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.4)
//
//    @EnvironmentObject var chatModel: ChatViewModel
//    @EnvironmentObject var stackModel: StackViewModel
//    @EnvironmentObject var activityModel: ChatActivityViewModel
//
//    var body: some View {
//        ZStack(alignment: .top) {
//            HeaderTemplate(leftElement: LeftChatHeaderElement(), centerElement: CenterChatHeaderElement(title: activityModel.title, avatar: activityModel.picture), rightElement: Spacer())
//
//            VStack {
//                Spacer().frame(height: 120)
//
//                if bottomSheetPosition != .relative(1) {
//                    ZStack {
//                        BubblePlayerOrPreviewView(size: .large, controlable: true)
//                    }
//                    .aspectRatio(contentMode: .fit)
//                    .clipShape(RoundedRectangle(cornerRadius: bottomSheetPosition == .relative(0.4) ? 80 : 25))
//                    .frame(width: WIDTH * (bottomSheetPosition == .relative(0.4) ? 0.8 : 0.22))
//                    .animation(.linear(duration: 0.1), value: bottomSheetPosition)
//                    .onTapGesture {
//                        if bottomSheetPosition == .relative(0.8) {
//                            bottomSheetPosition = .relative(0.4)
//                        }
//                    }
//                }
//
//                if bottomSheetPosition == .relative(0.4) {
////                    HFastActions(dialogueBubble: dialogueBubble, bottomSheetPosition: $bottomSheetPosition)
////                        .buttonStyle(.plain)
////                        .padding()
//                }
//            }
//        }
//        .background(Color.background)
//        .ignoresSafeArea()
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .onChange(of: keyboardResponder.isKeyboardVisible) { _, newValue in
//            if newValue == true {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    bottomSheetPosition = .relative(1)
//                }
//            } else {
//                bottomSheetPosition = .relative(0.8)
//            }
//        }
//        .onAppear {
//            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
//        }
//        .bottomSheet(bottomSheetPosition: $bottomSheetPosition,
//                     switchablePositions: [.relative(0.4), .relative(0.8)],
//                     headerContent: { CommentsHeader(bottomSheetPosition: $bottomSheetPosition, chatItem: chatItem, postItem: postItem) },
//                     mainContent: { CommentsBody(bottomSheetPosition: $bottomSheetPosition, chatItem: chatItem, postItem: postItem) })
//        .customBackground(
//            Color.white
//                .cornerRadius(40)
//                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.15), radius: 30, y: 8)
//        )
//        .showDragIndicator()
//    }
// }
