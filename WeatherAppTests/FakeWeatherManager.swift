//
//  FakeWeatherManager.swift
//  WeatherAppTests
//
//  Created by Sha'Marcus Walker on 5/24/23.
//

import Foundation
@testable import WeatherApp

class FakeWeatherManager: NetworkProtocol {
    lazy var jsonDecoder: JSONDecoder = {
        JSONDecoder()
    }()
    
    // Create a shared instance of URLCache
    static let sharedCache: URLCache = {
        let cacheSize = 50 * 1024 * 1024 // 50 MB
        let cache = URLCache(memoryCapacity: cacheSize, diskCapacity: cacheSize)
        return cache
    }()
    
    
    func fetchData<Response>(endpoint: WeatherEndpoints<Response>, useCache: Bool = false) async throws -> Response {
        
        do{
            let bundle = Bundle(for: FakeWeatherManager.self)
            guard let path = bundle.url(forResource: "MockWeather", withExtension: "json") else{
                throw URLError(.badServerResponse)
            }
            let data = try Data(contentsOf: path)
            let response = try jsonDecoder.decode(Response.self, from: data)
            return response
        }catch {
            throw URLError(.badServerResponse)
        }

        
        if let cachedResponse = WeatherManager.sharedCache.cachedResponse(for: URLRequest(url: endpoint.url)) {
            print("Cached response: \(cachedResponse)")
        } else {
            print("No cached response found.")
        }
        
        
        let (data, response) = try await URLSession.shared.data(from: endpoint.url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard(200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        if useCache {
            let cachedResponse = CachedURLResponse(response: httpResponse, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: endpoint.url))
            print("Stored response in cache for \(endpoint.url)")
        }
        
        return try jsonDecoder.decode(Response.self, from: data)

    }
}

