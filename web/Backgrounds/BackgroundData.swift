//
//  BackgroundData.swift
//  web
//
//  Created by Anton on 20.02.2025.
//

import SwiftUI

func getDayFromDate(referenceTime: String) -> Int? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Указываем временную зону UTC
    
    // Преобразуем строку в Date
    guard let referenceDate = dateFormatter.date(from: referenceTime) else {
//        print("Ошибка преобразования referenceTime: \(referenceTime)")
        return nil
    }
    
    // Извлекаем день месяца с помощью Calendar
    let calendar = Calendar.current
    let day = calendar.component(.day, from: referenceDate)
    
    return day
}

func isNight(weatherResponse: WeatherResponse?, dateTimeString: String) -> Bool {
    if let sunriseTime = weatherResponse?.daily.sunrise?.first,
       let sunsetTime = weatherResponse?.daily.sunset?.first {
        let sunrise = givemehour(time: sunriseTime)
        let sunset = givemehour(time: sunsetTime)
        
        let current_time = givemehour(time: dateTimeString)
        if current_time <= sunrise || current_time >= sunset {
            return true
        }
    }
    return false
}

func givemehour(time: String) -> Int {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    formatter.timeZone = TimeZone(identifier: "UTC") // Парсим строку как UTC
    
    if let date = formatter.date(from: time) {
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = "HH"
        localFormatter.timeZone = TimeZone.current  // Преобразуем в локальный часовой пояс
        
        let localHour = Int(localFormatter.string(from: date)) ?? 12
//        print("Локальный час: \(localHour)")
        return localHour
    } else {
//        print("Ошибка: не удалось преобразовать строку в дату")
        return Int(time) ?? 12
    }
}
