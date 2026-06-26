////
////  CommentsHeader.swift
////  Home
////
////  Created by polezhaev_aleksandr on 10.10.2024.
////
//
// import SwiftUI
// import BottomSheet
//
// struct CommentsHeader: View {
//    @Binding var bottomSheetPosition: BottomSheetPosition
//
//    var chatItem: ChatItem
//    var postItem: PostItem
//
//    var body: some View {
//        HStack {
//            Text("Comments")
//                .font(.system(size: 18,
//                              weight: .bold,
//                              design: .rounded))
//            Text("\(postItem.comments.count)")
//                .font(.system(size: 14,
//                              weight: .medium,
//                              design: .rounded))
//                .padding(6)
////                .background(Circle().fill(  isNeedToReadAndNotMine(dialogueBubble: dialogueBubble) ? .gray : .pink))
//                .foregroundColor(.white)
//            Spacer()
//
//            Image(systemName: "timer")
//                .font(.system(size: 14,
//                              weight: .medium,
//                              design: .rounded))
//            Text("test")
//                .font(.system(size: 14,
//                              weight: .medium,
//                              design: .rounded))
//
//
//            if bottomSheetPosition != .relative(0.4) {
//                Button(action: {
//                    UIApplication.shared.hideKeyboard()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        bottomSheetPosition = .relative(0.4)
//                    }
//                }, label: {
//                    Image(systemName: "xmark.circle")
//                        .resizable()
//                        .frame(width: 24, height: 24)
//                        .foregroundStyle(.gray)
//                        .padding(8)
//                })
//            }
//        }
//        .padding(.horizontal)
//    }
// }
