//
//  CurrentlyView.swift
//  3tabs
//
//  Created by Anton on 29.01.2025.
//

import SwiftUI

struct CurrentlyView: View {
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
                } else {
                    if let currently = weatherResponse?.current_weather {
                        Text(weather.cityName)
                            .font(.system(size: 20, weight: .thin))
                            .foregroundColor(.white)
                            .padding()
                        Text("\(String(describing: currently.temperature!))°")
                            .font(.system(size: 80, weight: .thin))
                            .foregroundColor(.white)
                            .padding()
                        Text(weather_description(index: currently.weathercode!))
                            .font(.system(size: 20, weight: .thin))
                            .foregroundColor(.white)
                            .padding()
                        Text("\(String(describing: currently.windspeed!)) km/h")
                            .font(.system(size: 20, weight: .thin))
                            .foregroundColor(.white)
                            .padding()
                    }
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
