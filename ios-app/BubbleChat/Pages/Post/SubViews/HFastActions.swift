////
////  HFastActions.swift
////  BubbleChat
////
////  Created by polezhaev_aleksandr on 18.10.2024.
////
//
// import SwiftUI
// import BottomSheet
//
// struct HFastActions: View {
//    @EnvironmentObject var homeSettings: HomeSettings
//
//    var dialogueBubble: DialogueBubble
//
//    @Binding var bottomSheetPosition: BottomSheetPosition
//
//    var body: some View {
//        HStack {
//            Spacer()
//            HStack {
//                Image("tabbar-item-0")
//                Image("tabbar-item-1")
//                Image("tabbar-item-2")
//            }.padding(8)
//                .opacity(0.3)
//                .background(RoundedRectangle(cornerRadius: 45).fill(Color.white))
//                .onTapGesture {
//                    homeSettings.showAlert(title: "Under development", message: "Adding stickers to bubbles")
//                }
//
//            //            Text("1.5x")
//            //                .font(.system(size: 16,
//            //                              weight: .medium,
//            //                              design: .rounded))
//            //                .padding(14)
//            //                .background(Circle().fill(Color.white))
//            //                .onTapGesture {
//            //                    homeSettings.showAlert(title: "Under development", message: "Changing video speed")
//            //                }
//
//            Button {
//                bottomSheetPosition = .relative(0.8)
//            } label: {
//                ZStack(alignment: .topTrailing) {
//                    Image(systemName: "bubble.left.and.bubble.right")
//                        .padding(14)
//                        .background(Circle().fill(Color.white))
//
//                    Text("\(dialogueBubble.comments.count)")
//                        .font(.system(size: 10,
//                                      weight: .medium,
//                                      design: .rounded))
//                        .foregroundStyle(.white)
//                        .padding(4)
//
//                }
//            }
//
//            Spacer()
//            Image(systemName: "arrowshape.turn.up.left")
//                .padding()
//                .background(Circle()
//                    .fill(Color.white))
//                .onTapGesture {
//                    homeSettings.showAlert(title: "Under development", message: "Reply to a bubble")
//                }
//            Spacer()
//        }
//    }
// }
