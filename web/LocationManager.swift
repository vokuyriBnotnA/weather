////
////  LocationManager.swift
////  web
////
////  Created by Anton on 21.01.2025.
///

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationError: String? // Ошибка геолокации
    var didUpdateLocation: ((CLLocation) -> Void)? // Callback, когда местоположение обновляется
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func findMe() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        DispatchQueue.global(qos: .background).async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.locationManager.requestWhenInUseAuthorization() // Запрос на разрешение
                }
            } else {
                DispatchQueue.main.async {
                    self.locationError = "Службы геолокации отключены. Включите их в настройках устройства."
                }
            }
        }
    }
    
    private func checkLocationAuthorization() {
        DispatchQueue.main.async {
            self.authorizationStatus = self.locationManager.authorizationStatus
            
            switch self.locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationError = nil
                self.locationManager.startUpdatingLocation() // Запуск обновления местоположения
            case .denied:
                self.locationError = "Геолокация отключена. Разрешите доступ в настройках устройства."
            case .restricted:
                self.locationError = "Геолокация недоступна. Ограничения на уровне системы."
            case .notDetermined:
                self.locationError = nil // Пользователь еще не выбрал
            @unknown default:
                self.locationError = "Неизвестная ошибка геолокации."
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization() // Проверяем изменения в авторизации
    }
    
    // Обработка обновлений местоположения
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.userLocation = location // Обновляем местоположение на главном потоке
                self.didUpdateLocation?(location) // Вызываем callback с актуальным местоположением
                
                // Останавливаем обновление местоположения после получения первого результата
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    // Обработка ошибок
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "Ошибка определения местоположения: \(error.localizedDescription)"
        }
    }
}
