//
//  BackViewWeather.swift
//  backgroundGraphics
//
//  Created by Anton on 03.02.2025.
//

import SwiftUI
import Foundation

struct BackViewWeather: View {
    @ObservedObject var weather: Weather
    let weatherResponse: WeatherResponse?
    
    var body: some View {
        let weather_index = weatherResponse?.current_weather.weathercode ?? 0
        
        ZStack {
            BackgroundView(weather: weather, weatherResponse: weatherResponse)
            if weather_index != 0 {
                CloudsView()
            }
            switch weather_index {
            case 51...67:
                PrecipitationView(rain: true, snow: false)
            case 71...77:
                PrecipitationView(rain: false, snow: true)
            case 80...82:
                PrecipitationView(rain: true, snow: false)
            case 85...86:
                PrecipitationView(rain: true, snow: true)
            default:
                PrecipitationView(rain: false, snow: false)
            }
            
        }
    }
}
