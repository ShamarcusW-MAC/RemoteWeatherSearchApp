//
//  WeatherAppViewModelTests.swift
//  WeatherAppTests
//
//  Created by Sha'Marcus Walker on 5/23/23.
//

import XCTest
import Combine
@testable import WeatherApp

final class WeatherAppViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testWeatherDataFetch_When_Everything_isCorrect() {

        let weatherViewModel = WeatherViewModel(weatherManager: FakeWeatherManager())
        
            
        XCTAssertNotNil(weatherViewModel)
            
            let expectation = XCTestExpectation(description: "Fetching Weather information")
            
            weatherViewModel.fetchWeatherInfo(city: "Atlanta")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                
                XCTAssertEqual(33.749, weatherViewModel.forecast?.coord.lat)
                
                XCTAssertEqual(-84.388, weatherViewModel.forecast?.coord.lon)
                
                XCTAssertEqual(293.68, weatherViewModel.forecast?.main.temp)
                
                expectation.fulfill()
            }
            
            self.wait(for: [expectation], timeout: 10)

    }
    
    
    func testWeatherDataFetch_When_Search_Text_isMisspelled() {

        let weatherViewModel = WeatherViewModel(weatherManager: WeatherManager())
        
            
        XCTAssertNotNil(weatherViewModel)
            
            let expectation = XCTestExpectation(description: "Fetching Weather information")
            
            weatherViewModel.fetchWeatherInfo(city: "Lomdom")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                
                XCTAssertEqual(nil, weatherViewModel.forecast?.coord.lat)
                
                XCTAssertEqual(nil, weatherViewModel.forecast?.coord.lon)
                
                XCTAssertEqual(nil, weatherViewModel.forecast?.main.temp)
                
                expectation.fulfill()
            }
            
            self.wait(for: [expectation], timeout: 10)

    }

}
