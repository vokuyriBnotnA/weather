//
//  TodayData.swift
//  web
//
//  Created by Anton on 20.02.2025.
//

import SwiftUI

struct HourlyWeatherData: Identifiable {
    let id = UUID()
    let hour: String
    let temperature: Double
    let weathercode: Int
    let wind_speed: Double
}

func createHourlyData(hourly: HourlyWeather, from referenceTime: String) -> [HourlyWeatherData] {
    guard let times = hourly.time,
          let temperatures = hourly.temperature_2m,
          let weathercodes = hourly.weathercode,
          let wind_speeds = hourly.wind_speed_10m else { return [] }
    
    var weatherData: [HourlyWeatherData] = []
    
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    // Настройка формата времени для обработки строк "yyyy-MM-dd'T'HH:mm"
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Указываем UTC, если времени нет
    
    // Преобразуем строку referenceTime в Date
    guard let referenceDate = dateFormatter.date(from: referenceTime) else {
//        print("Ошибка преобразования referenceTime: \(referenceTime)")
        return []
    }
    
//    print("Отправное время: \(referenceDate)")
    
    for i in 0..<times.count {
        let timeString = times[i]
        
        // Преобразуем строку времени в Date
        guard let date = dateFormatter.date(from: timeString) else {
//            print("Ошибка преобразования времени в date для строки: \(timeString)")
            continue
        }
        
//        print("Время \(i): \(date)")
        
        // Считаем разницу во времени между referenceDate и date
        if let diff = calendar.dateComponents([.hour], from: referenceDate, to: date).hour {
//            print("Разница: \(diff) часов между \(referenceDate) и \(date)")
            
            // Проверяем, если разница в пределах 24 часов
            if diff >= 0, diff < 23 {
                let hour = formatHour(time: timeString).prefix(2)
                let temp = temperatures[i]
                let weathercode = weathercodes[i]
                let wind_speed = wind_speeds[i]
                
                // Добавляем в список
                weatherData.append(HourlyWeatherData(hour: String(hour), temperature: temp, weathercode: weathercode, wind_speed: wind_speed))
            }
        }
    }
    
//    print("Найдено \(weatherData.count) записей.")
    
    return weatherData
}

// Функция для получения сегодняшней даты в формате "yyyy-MM-dd"
func getTodayDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: Date())
}

// Функция преобразования времени в формат "HH:mm"
func formatHour(time: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    formatter.timeZone = TimeZone.current
    
    if let date = formatter.date(from: time) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        return outputFormatter.string(from: date)
    }
    return "--:--"
}
