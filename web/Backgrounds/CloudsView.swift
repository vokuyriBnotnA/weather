//
//  CloudsView.swift
//  backgroundGraphics
//
//  Created by Anton on 05.02.2025.
//

import SwiftUI

struct CloudsView: View {
    var body: some View {
        AnimatedCloudsView()
        AnimatedCloudsView()
    }
}

struct AnimatedCloudsView: View {
    
    @State private var offsetX: CGFloat = CGFloat.random(in: 0...150)
    
    var body: some View {
        ZStack {
            // Задний слой облаков (размытые и медленные)
            CloudLayer(speed: 5, blur: 3, opacity: 0.5, back: true)
                .offset(x: offsetX)
            
            // Передний слой облаков (более четкие и быстрые)
            CloudLayer(speed: 10, blur: 0, opacity: 0.8, back: false)
                .offset(x: offsetX * 1.06)
        }
        .offset(x: CGFloat(Int.random(in: 0...200)), y: CGFloat.random(in: -50 ... -10))
        .onAppear {
            withAnimation(Animation.linear(duration: TimeInterval.random(in: 300...1000)).repeatForever(autoreverses: false)) {
                offsetX = UIScreen.main.bounds.width // Двигаем облака влево
            }
        }
    }
}


struct CloudLayer: View {
    let speed: Double
    let blur: CGFloat
    let opacity: Double
    let back: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Image(systemName: "cloud.fill")
                .resizable()
                .foregroundColor(back ? .gray.opacity(0.15) : .white)
                .scaledToFill()
                .frame(width: CGFloat.random(in: 150...200), height: CGFloat.random(in: 150...200))
                .opacity(opacity)
                .blur(radius: blur)
                .offset(x: 0, y: 0)
        }
    }
}

#Preview {
    ContentView()
}
