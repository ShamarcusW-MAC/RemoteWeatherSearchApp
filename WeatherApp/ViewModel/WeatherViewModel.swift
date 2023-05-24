//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Sha'Marcus Walker on 5/22/23.
//

import Foundation
import CoreLocation
import SwiftUI

final class WeatherViewModel: ObservableObject {
    
    private let weatherManager: NetworkProtocol
    var location: Forecast?
    @Published var forecast: Forecast?
    var currentTemp: Int = 0
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    let lastSearchedCityKey = "LastSearchedCity"
    private var fetchTask: Task<Void, Never>?

    init(weatherManager: NetworkProtocol) {
        self.weatherManager = weatherManager
        let lastSearchedCity = UserDefaults.standard.string(forKey: lastSearchedCityKey)
        if let city = lastSearchedCity {
            fetchWeatherInfo(city: city)
        }
    }
    
    func fetchWeatherInfo(city: String) {
        fetchTask?.cancel()
        Task {
            do {
                
                let _location = try await weatherManager.fetchData(endpoint: WeatherEndpoint.getWeatherLocation(city: city), useCache: true)
                                
                await MainActor.run {
                    location = _location
                    latitude = _location.coord.lat ?? 0.0
                    longitude = _location.coord.lon ?? 0.0
                }
                
                let _forecast = try await weatherManager.fetchData(endpoint: WeatherEndpoint.getCurrentWeatherData(lat: latitude, lon: longitude), useCache: true)
    
                await MainActor.run {
                    forecast = _forecast
                    currentTemp = tempConversion(temp: forecast?.main.temp ?? 0.0)
                }
                
                UserDefaults.standard.set(forecast?.name.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+"), forKey: lastSearchedCityKey)

            } catch let error {
                location = nil
                forecast = nil
                print("Error fetching data: \(error)")
            }
        }
    }
    
    
    func fetcheDefaultWeatherInfo(_ location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        Task {
            do {
                let _forecast = try await weatherManager.fetchData(endpoint: WeatherEndpoint.getCurrentWeatherData(lat: latitude, lon: longitude), useCache: true)
                
                await MainActor.run {
                    forecast = _forecast
                    currentTemp = tempConversion(temp: forecast?.main.temp ?? 0.0)
                }
            } catch let error {
                forecast = nil
                print("Error fetching data: \(error)")
            }
        }
    }
    //Since the default temperature is in Kelvins, we need the temperature to Fahrenheit
    func tempConversion(temp: Double) -> Int {
        var fahrenheitTemp: Double
        fahrenheitTemp = (temp - 273.15) * 9/5 + 32
        round(fahrenheitTemp)
        return Int(fahrenheitTemp)
    }
}
