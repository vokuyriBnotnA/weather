//
//  Untitled.swift
//  3tabs
//
//  Created by Anton on 29.01.2025.
//

import SwiftUI
import SwiftUI

struct TripleContainer<FirstView: View, SecondView: View, ThirdView: View>: View {
    let firstView: FirstView
    let secondView: SecondView
    let thirdView: ThirdView
    
    @State private var offset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    private let screenWidth = UIScreen.main.bounds.width
    
    // Добавляем массив с названиями иконок (можно передавать извне)
    let tabIcons: [String]
    
    init(
        tabIcons: [String], // Передаем названия иконок
        @ViewBuilder firstView: @escaping () -> FirstView,
        @ViewBuilder secondView: @escaping () -> SecondView,
        @ViewBuilder thirdView: @escaping () -> ThirdView
    ) {
        self.firstView = firstView()
        self.secondView = secondView()
        self.thirdView = thirdView()
        self.tabIcons = tabIcons
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    firstView
                        .frame(width: geometry.size.width)
                    secondView
                        .frame(width: geometry.size.width)
                    thirdView
                        .frame(width: geometry.size.width)
                }
                .offset(x: -offset + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let dragThreshold = screenWidth / 5
                            
                            withAnimation(.interactiveSpring()) {
                                if abs(value.translation.width) > dragThreshold {
                                    if value.translation.width < 0 {
                                        offset = min(offset + screenWidth, screenWidth * 2)
                                    } else {
                                        offset = max(offset - screenWidth, 0)
                                    }
                                }
                            }
                            dragOffset = 0
                        }
                )
                .animation(.interactiveSpring(), value: dragOffset)
            }
            tabBar
        }
    }
    
    private func tabIcon(imageName: String, isSelected: Bool, text: String) -> some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(isSelected ? .white : .white.opacity(0.4))
            
            Text(text)
                .font(.footnote)
                .foregroundColor(isSelected ? .white : .white.opacity(0.4))
        }
    }
    
    private var tabBar: some View {
        HStack {
            Button(action: {
                withAnimation {
                    offset = 0
                }
            }) {
                tabIcon(imageName: tabIcons[0], isSelected: offset == 0, text: "Currently")
            }
            Spacer()
            Button(action: {
                withAnimation {
                    offset = screenWidth
                }
            }) {
                tabIcon(imageName: tabIcons[1], isSelected: offset == screenWidth, text: "Today")
            }
            Spacer()
            Button(action: {
                withAnimation {
                    offset = screenWidth * 2
                }
            }) {
                tabIcon(imageName: tabIcons[2], isSelected: offset == screenWidth * 2, text: "Weekly")
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.1))
    }
}


