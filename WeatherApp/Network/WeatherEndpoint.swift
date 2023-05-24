//
//  WeatherEndpoints.swift
//  WeatherApp
//
//  Created by Sha'Marcus Walker on 5/22/23.
//

import Foundation

struct WeatherEndpoints<Response: Decodable> {
    let url: URL
    let responseType: Response.Type
}

//Due to time constraints and the purpose of this demo, I've decided to store my api key in a less complex way. However, I would much prefer use KeyChain services instead.
struct WeatherEndpoint {
    static func getCurrentWeatherData(lat: Double, lon: Double) -> WeatherEndpoints<Forecast> {
        WeatherEndpoints(url: URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(KeyRef.getAPIKeyThroughConfig())")!,
                         responseType: Forecast.self)
    }
    
    static func getWeatherLocation(city: String) -> WeatherEndpoints<Forecast> {
        WeatherEndpoints(url: URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(KeyRef.getAPIKeyThroughConfig())")!, responseType: Forecast.self)
    }
}
