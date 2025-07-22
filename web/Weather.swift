//
//  Weather.swift
//  web
//
//  Created by Anton on 28.01.2025.
//

import SwiftUI
import CoreLocation
import Combine

class Weather: ObservableObject {
    @Published var cityName: String = "Unknown"
    @Published var locationManager = LocationManager()
    @Published var backgroundColor: Color = .blue
    
    private var cancellables = Set<AnyCancellable>()
    
    func myLocation() {
        locationManager.findMe()
    }
    
    // Метод для получения названия города через геокодирование
    func getCityName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Ошибка при геокодировании: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                if let city = placemark.locality {
                    DispatchQueue.main.async {
                        self?.cityName = city
                        print("Город обновлен на главном потоке: \(city)")
                    }
                }
            }
        }
    }
    // Этот метод нужно вызывать при выборе города из списка, чтобы обновить cityName
    func updateCityName(for city: String) {
        self.cityName = city
    }
}
