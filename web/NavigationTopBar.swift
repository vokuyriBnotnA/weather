//
//  NavigationTopBar.swift
//  web
//
//  Created by Anton on 20.02.2025.
//

import SwiftUI

struct NavigationTopBar: View {
    @Binding var searchText: String
    @FocusState var isSearchBarFocused: Bool
    @StateObject var weather: Weather
    @StateObject var citySearchViewModel: CitySearchViewModel
    @StateObject var weatherViewModel: WeatherViewModel
    @Binding var showAlert: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .focused($isSearchBarFocused)
                    .foregroundColor(.white)
                TextField("", text: $searchText)
                    .focused($isSearchBarFocused)
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .onSubmit {
                        let filteredCities = citySearchViewModel.cities.filter { city in
                            city.name.lowercased().contains(searchText.lowercased())
                        }
                        
                        if let firstCity = filteredCities.first {
                            searchText = ""
                            weather.updateCityName(for: "\(firstCity.name) \(firstCity.admin1 ?? ""), \(firstCity.country ?? "")")
                            weatherViewModel.fetchWeather(
                                latitude: firstCity.latitude,
                                longitude: firstCity.longitude
                            )
                        } else {
                            print("Города не найдены")
                        }
                    }
                    .onChange(of: isSearchBarFocused) {
                        if isSearchBarFocused {
                            if searchText.isEmpty {
                                citySearchViewModel.searchCities(query: " ") // Запрос без текста, чтобы список появился
                            } else {
                                citySearchViewModel.searchCities(query: searchText)
                            }
                        } else {
                            searchText = "" // Очищаем текст при потере фокуса
                            citySearchViewModel.cities = [] // Очищаем список городов
                        }
                    }
                
                    .onChange(of: searchText) {
                        if !searchText.isEmpty {
                            citySearchViewModel.searchCities(query: searchText)
                        } else if isSearchBarFocused {
                            citySearchViewModel.searchCities(query: searchText) // Повторный вызов при фокусе
                        } else {
                            citySearchViewModel.cities = [] // Очищаем список
                        }
                        
                    }
                ZStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            searchText = "" // Очищаем текст поиска
                            citySearchViewModel.cities = [] // Очищаем список городов
                            isSearchBarFocused = false // Сбрасываем фокус
                        }
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white) // Текст белый
                    }
                    .opacity(isSearchBarFocused ? 1 : 0) // Плавное появление
                    .offset(x: isSearchBarFocused ? 0 : 50) // Двигаем кнопку справа налево
                    .animation(.easeInOut(duration: 0.3), value: isSearchBarFocused)
                    
                    Button(action: {
                        if let userLocation = weather.locationManager.userLocation {
                            // Если местоположение уже получено, обновляем название города и погоду
                            weather.getCityName(from: userLocation)
                            weatherViewModel.fetchWeather(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                        } else {
                            // Если местоположение еще не получено, запрашиваем его
                            weather.myLocation()
                            
                            // Подписываемся на обновления местоположения
                            weather.locationManager.didUpdateLocation = { location in
                                // Когда местоположение обновится, мы обновим название города и погоду
                                weather.getCityName(from: location)
                                weatherViewModel.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                            }
                        }
                        
                        // Если ошибка с геолокацией, показываем предупреждение
                        showAlert = weather.locationManager.locationError != nil
                        isSearchBarFocused = false // Скрываем клавиатуру
                    }
                    ) {
                        Image(systemName: "location")
                            .foregroundColor(.white)
                    }
                    .opacity(isSearchBarFocused ? 0 : 1) // Исчезает при фокусе
                    .offset(x: isSearchBarFocused ? -50 : 0) // Двигаем кнопку влево
                    .animation(.easeInOut(duration: 0.3), value: isSearchBarFocused)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Permission to access location"),
                            message: Text(weather.locationManager.locationError ?? "An unknown error occurred"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
            .padding(8)
            .background(isSearchBarFocused ? Color.gray : Color.black.opacity(0.1))
            .animation(.easeInOut(duration: 0.5), value: isSearchBarFocused)
            .cornerRadius(8)
            .focused($isSearchBarFocused) // Привязываем фокус
            .onChange(of: isSearchBarFocused) {
                if !isSearchBarFocused {
                    searchText = "" // Очищаем текст при потере фокуса
                    citySearchViewModel.cities = [] // Очищаем список городов
                }
            }
            .onChange(of: searchText) {
                if !searchText.isEmpty {
                    citySearchViewModel.searchCities(query: searchText)
                } else {
                    citySearchViewModel.cities = [] // Очищаем список
                }
            }
            .onSubmit {
                citySearchViewModel.searchCities(query: searchText)
            }
        }
        .padding(8)
        .zIndex(2)
        .background(isSearchBarFocused ? Color.white : Color.black.opacity(0.1))
        .animation(.easeInOut(duration: 0.5), value: isSearchBarFocused)
    }
}

