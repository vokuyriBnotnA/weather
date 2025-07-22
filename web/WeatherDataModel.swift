//
//  WeatherDataModel.swift
//  web
//
//  Created by Anton on 31.01.2025.
//

import SwiftUI
import CoreLocation
import Combine

// Структура для получения данных о погоде

struct WeatherResponse: Codable {
    var current_weather: CurrentWeather
    var hourly: HourlyWeather
    var daily: DailyWeather
    var error_code: Int? = 0
}

struct CurrentWeather: Codable {
    var temperature: Double?
    var windspeed: Double?
    var weathercode: Int?
    var time: String?  // Добавлено: текущее время
}

struct HourlyWeather: Codable {
    let time: [String]?
    let temperature_2m: [Double]?
    let weathercode: [Int]?
    let wind_speed_10m: [Double]?
}

struct DailyWeather: Codable {
    let time: [String]?
    let temperature_2m_max: [Double]?
    let temperature_2m_min: [Double]?
    let weathercode: [Int]?
    let wind_speed_10m_max: [Double]?
    let sunrise: [String]?  // Добавлено: время восхода
    let sunset: [String]?   // Добавлено: время заката
}


class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherResponse? = nil

    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true&hourly=temperature_2m,weathercode,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,weathercode,precipitation_sum,wind_speed_10m_max,sunrise,sunset&timezone=auto"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            weatherData?.error_code = 1
            return
        }
        // Начинаем асинхронный запрос
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data received")
//                self.weatherData?.error_code = 2
                return
            }
            // Печать сырых данных
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Received raw data: \(jsonString)")
//            }
            
            // Попытка декодирования
            do {
                let decodedWeather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.weatherData?.current_weather = decodedWeather.current_weather
                    self.weatherData?.hourly = decodedWeather.hourly
                    self.weatherData?.daily = decodedWeather.daily
                    
                    self.weatherData = decodedWeather
                    self.weatherData?.error_code = 0
//                    print("Weather updated: \(decodedWeather)")
                }
            } catch {
                print("Error decoding weather data: \(error.localizedDescription)")
            }
        }.resume()

    }
}
