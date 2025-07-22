//
//  SnowView.swift
//  web
//
//  Created by Anton on 20.02.2025.
//

import SwiftUI

struct SnowView: View {
    // Массив капель дождя
    @State private var raindrops = SnowView.generateRaindrops(count: 150)
    // Таймер, который срабатывает каждые 0.05 секунд (20 кадров в секунду)
    let timer = Timer.publish(every: 0.014, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Canvas отрисовывает капли дождя
            Canvas { context, size in
                for drop in raindrops {
                    // Пример отрисовки капли в Canvas:
                    let rect = CGRect(x: drop.position.x, y: drop.position.y, width: drop.size, height: drop.size) // увеличим высоту для вытянутой формы
                    context.fill(RaindropShape().path(in: rect), with: .color(.white.opacity(0.4)))
                }
            }
            .compositingGroup()
            .blur(radius: 1)
            Canvas { context, size in
                for drop in raindrops {
                    // Пример отрисовки капли в Canvas:
                    let rect = CGRect(x: drop.position.x, y: drop.position.y, width: drop.size, height: drop.size) // увеличим высоту для вытянутой формы
                    context.fill(RaindropShape().path(in: rect), with: .color(.white.opacity(0.4)))
                }
            }
            .ignoresSafeArea()
        }
        // Обновляем капли каждый раз, когда срабатывает таймер
        .onReceive(timer) { _ in
            updateDrops(screenSize: UIScreen.main.bounds.size)
        }
    }
    
    // Функция обновления состояния каждой капли
    func updateDrops(screenSize: CGSize) {
        for i in raindrops.indices {
            // Обновляем вертикальную позицию
            raindrops[i].position.y += raindrops[i].speed
            // Добавляем небольшой горизонтальный сдвиг (дрейф)
            raindrops[i].position.x += raindrops[i].drift
            
            // Если капля вышла за нижнюю границу экрана, сбрасываем её наверх с новым случайным положением по оси X
            if raindrops[i].position.y > screenSize.height {
                raindrops[i].position.y = -raindrops[i].size
                raindrops[i].position.x = CGFloat.random(in: 0...screenSize.width)
            }
            
            // Если капля выходит за горизонтальные пределы, «оборачиваем» её
            if raindrops[i].position.x > screenSize.width {
                raindrops[i].position.x = 0
            } else if raindrops[i].position.x < 0 {
                raindrops[i].position.x = screenSize.width
            }
        }
    }
    
    // Структура, описывающая каплю дождя
    struct Raindrop {
        var position: CGPoint   // Текущее положение
        var speed: CGFloat      // Скорость падения (пикселей за обновление)
        var size: CGFloat       // Размер капли (например, 2–4 пикселя)
        var drift: CGFloat      // Горизонтальный сдвиг (отрицательное значение – влево, положительное – вправо)
    }
    
    // Функция для генерации массива случайных капель
    static func generateRaindrops(count: Int) -> [Raindrop] {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        return (0..<count).map { _ in
            Raindrop(
                position: CGPoint(x: CGFloat.random(in: 0...width),
                                  y: CGFloat.random(in: 0...height)),
                speed: CGFloat.random(in: 2...5),
                size: CGFloat.random(in: 1...8),
                drift: CGFloat.random(in: -1...1)
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
