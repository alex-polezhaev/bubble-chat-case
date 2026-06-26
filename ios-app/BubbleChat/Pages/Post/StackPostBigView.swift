//
//  StackPostBigView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 05.12.2024.
//

import BottomSheet
import Foundation
import SwiftUI

class SheetPositionControl: ObservableObject {
    @Published var currentSheetPosition: BottomSheetPosition = .relative(0.4)

    var possiblePositions: [BottomSheetPosition] {
        if let maxSheetPosition = maxSheetPosition {
            return [minSheetPosition, maxSheetPosition]
        } else {
            return [minSheetPosition]
        }
    }

    @Published var persistedPosition: BottomSheetPosition?

    @Published var minSheetPosition: BottomSheetPosition = .relative(0.4)
    @Published var maxSheetPosition: BottomSheetPosition?

    func setDefault() {
        minSheetPosition = .relative(0.4)
        maxSheetPosition = .relative(0.8)
    }

    func setCustomMin(height: CGFloat) {
        currentSheetPosition = .absolute(height + 120)
        minSheetPosition = currentSheetPosition
    }

    func setCustomMax(height: CGFloat) {
        maxSheetPosition = .absolute(height + 120)
    }
}

struct StackPostBigView: View {
    @StateObject var sheetControl = SheetPositionControl()

    @StateObject var keyboardResponder = KeyboardResponder()

    var body: some View {
        ZStack {
            StackMediaView()
            BottomSheetComments()
            KeyboardSheetHeightResponder()
        }
        .environmentObject(sheetControl)
        .environmentObject(keyboardResponder)
    }
}

struct BottomSheetComments: View {
    @EnvironmentObject var sheetControl: SheetPositionControl

    var body: some View {
        VStack {}
            .bottomSheet(bottomSheetPosition: $sheetControl.currentSheetPosition,
                         switchablePositions: sheetControl.possiblePositions,
                         headerContent: {
                             HStack {
                                 CommentInfoPanel()
                                 Spacer()
                                 CloseOpenSheetButton()
                             }.padding(.bottom, 10)
                                 .padding(.trailing)

                         },
                         mainContent: { CommentsSheetBody() })
            .customBackground(
                Color.white
                    .cornerRadius(20)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.15), radius: 30, y: 8)
            )
            .showDragIndicator()
            .customAnimation(.snappy)
    }
}

struct CommentsSheetBody: View {
    @EnvironmentObject var sheetControl: SheetPositionControl

    @State var viewHeight: CGFloat = 0

    @EnvironmentObject var chatModel: ChatViewModel
    @EnvironmentObject var stackModel: StackViewModel
    @EnvironmentObject var activityModel: ChatActivityViewModel

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(stackModel.comments, id: \.self) { comment in
                            CommentMessage(comment: comment)
                        }
                    }
                    .padding()
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    if geometry.size.height < HEIGHT * 0.4 {
                                        self.sheetControl.setCustomMin(height: geometry.size.height)
                                    } else if geometry.size.height < HEIGHT * 0.8 {
                                        self.sheetControl.setCustomMax(height: geometry.size.height)
                                    }

                                    if geometry.size.height > HEIGHT * 0.8 {
                                        self.sheetControl.setDefault()
                                    }
                                }
                        }
                    )
                    .frame(maxHeight: .infinity)
                    .scaleEffect(y: -1)
                    .onAppear {
                        scrollViewProxy.scrollTo(stackModel.comments.last, anchor: .top)
                    }
                }.scaleEffect(y: -1)

//                FastCommentField(stackModel: <#StackViewModel#>, chatItem: <#ChatItem#>)
//                    .padding(.bottom, 20)
//                    .padding(.horizontal)
            }
        }
    }
}

#Preview(body: {
    StackPostBigView()
})

struct KeyboardSheetHeightResponder: View {
    @EnvironmentObject var sheetControl: SheetPositionControl
    @EnvironmentObject var keyboardResponder: KeyboardResponder

    var body: some View {
        VStack {}
            .onChange(of: keyboardResponder.isKeyboardVisible) {
                if self.keyboardResponder.isKeyboardVisible {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(nil) {
                            self.sheetControl.persistedPosition = self.sheetControl.currentSheetPosition
                            self.sheetControl.currentSheetPosition = .relative(1)
                        }
                    }
                } else {
                    withAnimation(nil) {
                        self.sheetControl.currentSheetPosition = self.sheetControl.persistedPosition ?? self.sheetControl.minSheetPosition
                    }
                }
            }
    }
}

struct CloseOpenSheetButton: View {
    @EnvironmentObject var sheetControl: SheetPositionControl
    @State var opacity: CGFloat = 1

    var body: some View {
        Button {
            let current = self.sheetControl.currentSheetPosition
            let max = self.sheetControl.maxSheetPosition
            let min = self.sheetControl.minSheetPosition

            withAnimation {
                if current == max {
                    self.sheetControl.currentSheetPosition = min
                }
                if current == min, let max = max {
                    self.sheetControl.currentSheetPosition = max
                }

                if current == .relative(1) {
                    if let max = max {
                        self.sheetControl.currentSheetPosition = max
                    } else {
                        self.sheetControl.currentSheetPosition = min
                    }
                }
            }

        } label: {
            Image(systemName: "chevron.up")
                .foregroundStyle(.gray)
                .padding(8)
                .background(.gray.opacity(0.2))
                .clipShape(Circle())
                .opacity(self.sheetControl.currentSheetPosition == self.sheetControl.minSheetPosition && self.sheetControl.maxSheetPosition == nil ? 0 : 1)
                .rotationEffect(.degrees(self.sheetControl.currentSheetPosition == .relative(1) ? 180 : 0))
                .rotationEffect(.degrees(self.sheetControl.currentSheetPosition == self.sheetControl.maxSheetPosition ? 180 : 0))
        }
    }
}
