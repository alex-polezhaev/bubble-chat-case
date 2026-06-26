////
////  CommentsBody.swift
////  Home
////
////  Created by polezhaev_aleksandr on 13.10.2024.
////
//
// import BottomSheet
// import SwiftUI
//
// struct CommentsBody: View {
//    @Binding var bottomSheetPosition: BottomSheetPosition
//
//    var chatItem: ChatItem
//    var postItem: PostItem
//
//    var body: some View {
//        ScrollViewReader { scrollViewProxy in
//            VStack {
//                ScrollView {
//                    VStack {
//                        Spacer().frame(height: 30)
//
//                        ForEach(postItem.comments.reversed(), id: \.self) { comment in
////                            SmallComment(comment: comment)
//                            Text("good")
//                                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .identity)) // Animate only on insertion
//                        }
//                        .animation(.snappy, value: postItem.comments) // Animate only on insertion
//
//                    }.frame(maxHeight: .infinity)
//                        .scaleEffect(y: -1)
//                        .padding(.horizontal)
//                        .onAppear {
//                            // Scroll to the last element after it appears
//                            withAnimation {
//                                scrollViewProxy.scrollTo(postItem.comments.first, anchor: .top) // 16 — number of elements in the list
//                            }
//                        }
//                        .onChange(of: bottomSheetPosition) {
//                            print(bottomSheetPosition)
//
//                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
//
//                            if bottomSheetPosition == .relative(0.4) {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                    withAnimation {
//                                        scrollViewProxy.scrollTo(1, anchor: .top)
//                                    }
//                                }
//                            }
//                        }
//                }
//            }
//        }.scaleEffect(y: -1)
//    }
// }
