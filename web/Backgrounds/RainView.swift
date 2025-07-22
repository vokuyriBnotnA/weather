//
//  RainView.swift
//  web
//
//  Created by Anton on 20.02.2025.
//

import SwiftUI

struct RainView: View {
    @State private var raindrops = RainView.generateRaindrops(count: 300)
    // Таймер обновляет состояние примерно 30 раз в секунду (0.033 сек)
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    // Гравитация, добавляемая к всплесковым каплям (пиксели за кадр)
    let gravity: CGFloat = 0.1
    // Вероятность, что нормальная капля при достижении низа «разобьется»
    let splashProbability: CGFloat = 0
    // Количество капель, создаваемых при эффекте разбивания
    let splashCount = 5
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                for drop in raindrops {
                    let rect = CGRect(
                        x: drop.position.x,
                        y: drop.position.y,
                        width: drop.size,
                        height: drop.size * 4 // Увеличим высоту капли
                    )
                    
                    context.fill(
                        RaindropShape().path(in: rect),
                        with: .color(drop.color)
                    )
                }
            }
            
            .ignoresSafeArea()
        }
        .onReceive(timer) { _ in
            updateDrops(screenSize: UIScreen.main.bounds.size)
        }
    }
    
    // Обновление положения капель
    func updateDrops(screenSize: CGSize) {
        var newSplashDrops: [Raindrop] = []
        
        // Проходим по массиву капель (обратный порядок для безопасного удаления)
        for i in raindrops.indices.reversed() {
            // Если это всплесковая капля, обновляем ее скорость (симулируем гравитацию)
            if raindrops[i].isSplash {
                raindrops[i].velocity.dy += gravity
            }
            // Обновляем позицию капли с учетом ее скорости
            raindrops[i].position.x += raindrops[i].velocity.dx
            raindrops[i].position.y += raindrops[i].velocity.dy
            
            // Если капля – нормальная, и она достигла низа экрана (например, нижних 5 пикселей)
            if !raindrops[i].isSplash && raindrops[i].position.y >= screenSize.height {
                // Решаем, делать ли эффект splash, с заданной вероятностью
                if CGFloat.random(in: 0...1) < splashProbability {
                    let baseX = raindrops[i].position.x
                    let baseY = screenSize.height - 110
                    for _ in 0..<splashCount {
                        let splash = Raindrop(
                            position: CGPoint(x: baseX, y: baseY),
                            // Небольшой случайный горизонтальный разброс
                            velocity: CGVector(dx: CGFloat.random(in: -1...1),
                                               dy: -CGFloat.random(in: 2...4)), // небольшое начальное значение вверх
                            size: raindrops[i].size, // всплесковые капли меньше
                            isSplash: true,
                            lifetime: 60, // время жизни всплесковой капли (около 1 секунды при 30 fps)
                            color: raindrops[i].color
                        )
                        newSplashDrops.append(splash)
                    }
                }
                // В любом случае, нормальная капля сбрасывается наверх
                raindrops[i].position.y = -raindrops[i].size
                raindrops[i].position.x = CGFloat.random(in: 0...screenSize.width)
                // Обнуляем скорость нормальной капли (чтобы она падала с исходной скоростью)
                raindrops[i].velocity = CGVector(dx: 0, dy: CGFloat.random(in: 10...15))
            }
            
            // Если это всплесковая капля, уменьшаем её lifetime и удаляем, если оно истекло
            if raindrops[i].isSplash {
                raindrops[i].lifetime -= 1
                if raindrops[i].lifetime <= 0 {
                    raindrops.remove(at: i)
                }
            }
            
            // Обработка горизонтальных границ (оборачиваем)
            if raindrops[i].position.x > screenSize.width {
                raindrops[i].position.x = 0
            } else if raindrops[i].position.x < 0 {
                raindrops[i].position.x = screenSize.width
            }
        }
        
        // Добавляем новые всплесковые капли
        raindrops.append(contentsOf: newSplashDrops)
    }
    
    // Модель капли дождя
    struct Raindrop: Identifiable {
        var id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var size: CGFloat
        var isSplash: Bool
        var lifetime: Int  // используется для всплесковых капель
        var color: Color
    }
    
    // Генерация начального массива нормальных капель
    static func generateRaindrops(count: Int) -> [Raindrop] {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return (0..<count).map { _ in
            Raindrop(
                position: CGPoint(x: CGFloat.random(in: 0...screenWidth),
                                  y: CGFloat.random(in: 0...screenHeight)),
                velocity: CGVector(dx: 0, dy: CGFloat.random(in: 10...15)),
                size: 2,
                isSplash: false,
                lifetime: 0,
                color: .white.opacity(0.2)
            )
        }
    }
    
    struct RaindropShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let midX = rect.midX
            let topY = rect.minY
            let bottomY = rect.maxY
            
            // Начинаем с верхней центральной точки
            path.move(to: CGPoint(x: midX, y: topY))
            
            // Левая сторона: создаем кривую до нижней точки
            path.addCurve(
                to: CGPoint(x: midX, y: bottomY),
                control1: CGPoint(x: rect.minX, y: topY + rect.height * 0.25),
                control2: CGPoint(x: rect.minX, y: bottomY - rect.height * 0.25)
            )
            
            // Правая сторона: создаем кривую обратно к верхней центральной точке
            path.addCurve(
                to: CGPoint(x: midX, y: topY),
                control1: CGPoint(x: rect.maxX, y: bottomY - rect.height * 0.25),
                control2: CGPoint(x: rect.maxX, y: topY + rect.height * 0.25)
            )
            
            path.closeSubpath()
            return path
        }
    }
    
}
