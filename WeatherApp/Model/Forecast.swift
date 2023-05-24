//
//  Forecast.swift
//  WeatherApp
//
//  Created by Sha'Marcus Walker on 5/22/23.
//

import Foundation

struct Forecast: Decodable {
    let coord: Coordinate
    let weather: [Weather]
    let main: Main
    let visibility: Int
    let wind: Wind
    let rain: Rain?
    let clouds: Clouds
    let dt: Int
    let sys: Sys?
    let timezone, id: Int
    let name: String
    let cod: Int
}

struct Coordinate: Decodable{
    let lon: Double?
    let lat: Double?
}

struct Weather: Decodable {
    let id: Int?
    let main, description, icon: String?
}

struct Clouds: Codable {
    let all: Int?
}

struct Main: Decodable {
    let temp, feelsLike, tempMin, tempMax: Double?
    let pressure, humidity, seaLevel, grndLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct Rain: Decodable {
    let the1H: Double?

    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
}

struct Sys: Decodable {
    let type, id: Int?
    let country: String?
    let sunrise, sunset: Int?
}

struct Wind: Decodable {
    let speed: Double?
    let deg: Int?
    let gust: Double?
}
