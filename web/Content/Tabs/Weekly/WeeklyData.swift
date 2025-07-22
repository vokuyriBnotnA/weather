//
//  WeeklyData.swift
//  web
//
//  Created by Anton on 20.02.2025.
//

import SwiftUI

struct DailyWeatherData: Identifiable {
    let id = UUID()
    let time: String
    let temperature_2m_max: Double
    let temperature_2m_min: Double
    let weathercode: Int
    let wind_speed_10m_max: Double
}

func createDailyData(weekly: DailyWeather) -> [DailyWeatherData] {
    guard let times = weekly.time,
          let temperatures_max = weekly.temperature_2m_max,
          let temperatures_min = weekly.temperature_2m_min,
          let weathercodes = weekly.weathercode,
          let wind_speeds = weekly.wind_speed_10m_max else { return [] }
    
    var weatherData: [DailyWeatherData] = []
    // Можно добавить условие, если нужно фильтровать данные по дате,
    // или просто заполнять все элементы:
    for i in 0..<times.count {
        let time = times[i].suffix(2)
        let temperature_min = temperatures_min[i]
        let temperature_max = temperatures_max[i]
        let weathercode = weathercodes[i]
        let wind_speed = wind_speeds[i]
        
        weatherData.append(DailyWeatherData(time: String(time),
                                            temperature_2m_max: temperature_max,
                                            temperature_2m_min: temperature_min,
                                            weathercode: weathercode,
                                            wind_speed_10m_max: wind_speed))
    }
    return weatherData
}
