////
////  ContentView.swift
////  web
////
////  Created by Anton on 21.01.2025.

import SwiftUI

struct ContentView: View {
    @StateObject var weather = Weather()
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var citySearchViewModel = CitySearchViewModel()
    @State private var searchText: String = ""
    @FocusState private var isSearchBarFocused: Bool
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                BackViewWeather(weather: weather, weatherResponse: weatherViewModel.weatherData)
                NavigationTopBar(searchText: $searchText, isSearchBarFocused: _isSearchBarFocused, weather: weather, citySearchViewModel: citySearchViewModel, weatherViewModel: weatherViewModel, showAlert: $showAlert)
                List {
                    Section {
                        Button("Use my location") {
                            if let userLocation = weather.locationManager.userLocation {
                                weather.getCityName(from: userLocation)
                                weatherViewModel.fetchWeather(
                                    latitude: userLocation.coordinate.latitude,
                                    longitude: userLocation.coordinate.longitude
                                )
                            } else {
                                weather.myLocation()
                            }
                            showAlert = weather.locationManager.locationError != nil
                            searchText = ""
                            isSearchBarFocused = false
                        }
                    }
                    
                    if isSearchBarFocused { // Убрали проверку на !searchText.isEmpty
                        if citySearchViewModel.cities.isEmpty {
                            Text("No cities found")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(citySearchViewModel.cities.filter { city in
                                searchText.isEmpty ? true : city.name.lowercased().contains(searchText.lowercased())
                            }.prefix(5), id: \.id) { city in
                                HStack {
                                    Text("\(city.name)")
                                        .bold()
                                    Text("\(city.admin1 ?? ""), \(city.country ?? "")")
                                }
                                .onTapGesture {
                                    searchText = ""
                                    weather.updateCityName(for: "\(city.name) \(city.admin1 ?? ""), \(city.country ?? "")")
                                    weatherViewModel.fetchWeather(
                                        latitude: city.latitude,
                                        longitude: city.longitude
                                    )
                                    isSearchBarFocused = false
                                }
                                .onChange(of: isSearchBarFocused) {
                                    print("Search bar focused: \(isSearchBarFocused)")
                                }
                            }
                        }
                    }
                }
                .zIndex(1)
                .opacity(isSearchBarFocused || !searchText.isEmpty ? 1 : 0) // Теперь список всегда виден при фокусе
                .offset(y: isSearchBarFocused ? 0 : -500)
                .animation(.easeInOut(duration: 0.5), value: isSearchBarFocused)
                .padding(.top, 30)
                
                TripleContainer(
                    tabIcons: [image_weather(index: weatherViewModel.weatherData?.current_weather.weathercode ?? 0, night: isNight(weatherResponse: weatherViewModel.weatherData, dateTimeString: weatherViewModel.weatherData?.current_weather.time ?? "12")), "\(getDayFromDate(referenceTime: weatherViewModel.weatherData?.current_weather.time ?? "10") ?? 10).square", "calendar"],
                    firstView: { CurrentlyView(weather: weather, weatherResponse: weatherViewModel.weatherData) },
                    secondView: { TodayView(weather: weather, weatherResponse: weatherViewModel.weatherData) },
                    thirdView: { WeeklyView(weather: weather, weatherResponse: weatherViewModel.weatherData) })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
    }
}
