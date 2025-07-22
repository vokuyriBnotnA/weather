//
//  BackgroundView.swift
//  backgroundGraphics
//
//  Created by Anton on 05.02.2025.
//

import SwiftUI

struct BackgroundView: View {
    @ObservedObject var weather: Weather
    let weatherResponse: WeatherResponse?
    
    @State private var sunrise: Int = 8
    @State private var sunset: Int = 17
    @State private var currentHour: Int = 12
    @State private var currentGradient: [Color] = [.blue, .blue]
    
    let gradientsClear: [[Color]] = [
        [.orange.opacity(0.8), .blue],
        [.blue, .cyan],
        [.red.opacity(0.6), .blue],
        [.indigo, .black]
    ]
    
    var body: some View {
        let dateTimeString = weatherResponse?.current_weather.time ?? "2025-01-01'T'12:00"
        
        ZStack {
            if weatherResponse?.current_weather.weathercode ?? 0 > 1 {
                LinearGradient(colors: currentGradient, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    .onAppear {
                        updateTimeData()
                    }
                    .onChange(of: dateTimeString) {
                        updateTimeData()
                    }
                    .colorMultiply(Color.gray) // Приглушение цветов
            } else {
                LinearGradient(colors: currentGradient, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    .onAppear {
                        updateTimeData()
                    }
                    .onChange(of: dateTimeString) {
                        updateTimeData()
                    }
            }
            if currentHour > sunset + 1 && (weatherResponse?.current_weather.weathercode)! <= 2 {
                StarsView()
            }
        }
    }
    
    private func updateTimeData() {
        let dateTimeString = weatherResponse?.current_weather.time ?? "2025-01-01'T'12:00"
        let newHour = givemehour(time: dateTimeString)
        
        if let sunriseTime = weatherResponse?.daily.sunrise?.first,
           let sunsetTime = weatherResponse?.daily.sunset?.first {
            sunrise = givemehour(time: sunriseTime)
            sunset = givemehour(time: sunsetTime)
        }
        
        currentHour = newHour
        updateGradient(weather_index: weatherResponse?.current_weather.weathercode ?? 0, hour: currentHour, sunrise: sunrise, sunset: sunset)
    }
    
    func updateGradient(weather_index: Int, hour: Int, sunrise: Int, sunset: Int) {
        
        let noon = (sunset - sunrise) / 2 + sunrise
        let gradients = gradientsClear
        currentGradient = gradients[0]
        
        if hour >= sunrise && hour <= noon - 1 {
            currentGradient = gradients[0] // Утро
            weather.backgroundColor = .blue
        } else if hour >= noon && hour <= sunset - 1 {
            currentGradient = gradients[1] // День
            weather.backgroundColor = .blue
        } else if hour >= sunset - 1 && hour <= sunset + 1 {
            currentGradient = gradients[2] // Вечер
            weather.backgroundColor = .blue
        } else {
            currentGradient = gradients[3] // Ночь
            weather.backgroundColor = .indigo
        }
        
    }
}

struct StarsView: View {
    var body: some View {
        Canvas { context, size in
            for _ in 1...100 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let starSize = CGFloat.random(in: 1...3)
                
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: starSize, height: starSize)),
                    with: .color(.white)
                )
            }
        }
        .opacity(0.8)
        .ignoresSafeArea()
    }
}

