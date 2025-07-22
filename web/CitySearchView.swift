//
//  CitySearchView.swift
//  weather_app
//
//  Created by Anton on 16.01.2025.
//

import SwiftUI
import Combine

/// Модель города
struct City: Identifiable, Decodable {
    var id: UUID { UUID() }
    let name: String
    let country: String?
    let admin1: String?
    let latitude: Double
    let longitude: Double
}

/// Модель ответа API
struct GeocodingResponse: Decodable {
    let results: [City]?
}

class CitySearchViewModel: ObservableObject {
    @Published var cities: [City] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var currentTask: AnyCancellable?
    
    func searchCities(query: String) {
        guard !query.isEmpty else {
            self.cities = []
            return
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        
        currentTask?.cancel()
        
        currentTask = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GeocodingResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("\(error)")
                }
            }, receiveValue: { [weak self] response in
                self?.cities = response.results ?? []
            })
    }
}
