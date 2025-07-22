//
//  TodayView.swift
//  3tabs
//
//  Created by Anton on 29.01.2025.
//
import SwiftUI
import Charts

struct TodayView: View {
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
                } else if let hourly = weatherResponse?.hourly {
                    Text(weather.cityName)
                        .font(.system(size: 20, weight: .thin))
                        .shadow(color: .black, radius: 1.3, x: 2, y: 2) // Тень: цвет, радиус, смещение по оси X и Y
                        .foregroundColor(.white)
                        .padding()
                    
                    TemperatureChartView(hourlyData: createHourlyData(hourly: hourly, from: weatherResponse?.current_weather.time ?? "2025-01-01'T'12:00"), colorBack: weather.backgroundColor)
                    HorizontalListView(hourlyData: createHourlyData(hourly: hourly, from: weatherResponse?.current_weather.time ?? "2025-01-01'T'12:00"), colorBack: weather.backgroundColor, weatherResponse: weatherResponse)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.isLoading = false
                }
            }
        }
    }
    
    
    struct TemperatureChartView: View {
        let hourlyData: [HourlyWeatherData]
        let colorBack: Color
        
        var body: some View {
            VStack {
                Chart {
                    ForEach(filteredHourlyData) { data in
                        LineMark(
                            x: .value("Hour", data.hour),
                            y: .value("Temp", data.temperature)
                        )
                        .foregroundStyle(.white)
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
                
                .frame(height: 200) // Высота графика
                .padding()
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
        
        // Фильтруем данные, чтобы оставить только временные точки 00, 06, 12, 18
        var filteredHourlyData: [HourlyWeatherData] {
            hourlyData.filter { data in
                let hour = Int(data.hour.prefix(2)) ?? 0
                return [0, 3, 6, 9, 12, 15, 18, 21, 23].contains(hour)
            }
        }
    }
    
    struct HorizontalListView: View {
        let hourlyData: [HourlyWeatherData]
        let colorBack: Color
        let weatherResponse: WeatherResponse?
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack() {
                    ForEach(hourlyData) { item in
                        VStack {
                            Text(item.hour)
                                .font(.system(size: 15, weight: .thin))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            Image(systemName: image_weather(index: item.weathercode, night: isNight(weatherResponse: weatherResponse, dateTimeString: item.hour)))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            Text("\(String(describing: item.temperature))°")
                                .font(.system(size: 15, weight: .thin))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            Text("\(String(describing: item.wind_speed)) km/h")
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
}
