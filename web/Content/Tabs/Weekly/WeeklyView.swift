//
//  WeeklyView.swift
//  3tabs
//
//  Created by Anton on 29.01.2025.
//

import SwiftUI
import Charts

struct WeeklyView: View {
    @ObservedObject var weather: Weather
    let weatherResponse: WeatherResponse?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .ignoresSafeArea()
            
            VStack {
                if weather.cityName == "Unknown" {
                    Text("Please, write name of the city or press \(Image(systemName: "location")) for auto GPS.")
                        .font(.system(size: 20, weight: .thin))
                        .foregroundColor(.white)
                        .padding()
                } else if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white)) // Индикатор с белым цветом
                        .padding()
                        .foregroundColor(.white)
                } else if weatherResponse?.error_code != 0 {
                    VStack {
                        Text("Error with api or internet connection!")
                            .font(.system(size: 20, weight: .thin))
                            .foregroundColor(.red)
                            .padding()
                    }
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(15)
                } else if let weekly = weatherResponse?.daily {
                    Text(weather.cityName)
                        .font(.system(size: 20, weight: .thin))
                        .shadow(color: .black, radius: 1.3, x: 2, y: 2) // Тень: цвет, радиус, смещение по оси X и Y
                        .foregroundColor(.white)
                        .padding()
                    
                    TemperatureChartDailyView(weeklyData: createDailyData(weekly: weekly), colorBack: weather.backgroundColor)
                    HorizontalListWeeklyView(weeklyData: createDailyData(weekly: weekly), colorBack: weather.backgroundColor)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.isLoading = false
                }
            }
        }
    }
}

struct HorizontalListWeeklyView: View {
    let weeklyData: [DailyWeatherData]
    let colorBack: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(weeklyData) { item in
                    VStack {
                        Text(item.time)
                            .font(.system(size: 15, weight: .thin))
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        Image(systemName: image_weather(index: item.weathercode, night: false))
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        Text("\(item.temperature_2m_min, specifier: "%.0f")°.. \(item.temperature_2m_max, specifier: "%.0f")°")
                            .font(.system(size: 15, weight: .thin))
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                    }
                    .padding()
                }
            }
        }
        .padding(.horizontal)
        .background(
            colorBack
                .colorMultiply(Color.gray)
                .blur(radius: 20)
        )
        .cornerRadius(15)
        .frame(width: UIScreen.main.bounds.width * 0.95)
        .frame(maxWidth: .infinity)
    }
}


struct TemperatureChartDailyView: View {
    let weeklyData: [DailyWeatherData]
    let colorBack: Color
    
    var body: some View {
        VStack {
            Chart {
                ForEach(weeklyData) { data in
                    LineMark(
                        x: .value("Day", data.time),
                        y: .value("Temperature", data.temperature_2m_max)
                    )
                    .foregroundStyle(.red)
                    .symbol(by: .value("", ""))
                    .symbol(.circle)
                }
                ForEach(weeklyData) { data in
                    LineMark(
                        x: .value("Day", data.time),
                        y: .value("Temperature", data.temperature_2m_min)
                    )
                    .foregroundStyle(.cyan)
                    .symbol(.circle)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(centered: true).foregroundStyle(.white.opacity(0.5)) // Сетка Y-оси
                    AxisTick().foregroundStyle(.white) // Тики Y-оси
                    AxisValueLabel().foregroundStyle(.white) // Метки Y-оси
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisGridLine(centered: true).foregroundStyle(.white.opacity(0.5)) // Сетка X-оси
                    AxisTick().foregroundStyle(.white) // Тики X-оси
                    AxisValueLabel().foregroundStyle(.white) // Метки X-оси
                }
            }
            .frame(height: 200)
            .padding()
            HStack() {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                    Text("Max Temp")
                        .foregroundColor(.white)
                        .font(.caption)
                }
                HStack {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 10, height: 10)
                    Text("Min Temp")
                        .foregroundColor(.white)
                        .font(.caption)
                }
                .padding()
            }
        }
        .background(
            colorBack
                .colorMultiply(Color.gray)
                .blur(radius: 20)
        )
        .cornerRadius(15)
        .frame(width: UIScreen.main.bounds.width * 0.95)
        .frame(maxWidth: .infinity)
    }
}




