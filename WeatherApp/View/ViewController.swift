//
//  ViewController.swift
//  WeatherApp
//
//  Created by Sha'Marcus Walker on 5/22/23.
//

import UIKit
import Combine
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    var weatherViewModel: WeatherViewModel?
    var locationManager: CLLocationManager?

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeSubLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var anyCancellable: AnyCancellable?
    override func viewDidLoad() {
        super.viewDidLoad()
        showWelcomeMessage()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        searchBar.delegate = self
        weatherViewModel = WeatherViewModel(weatherManager: WeatherManager())
        
        let lastSearchedCity = UserDefaults.standard.string(forKey: weatherViewModel?.lastSearchedCityKey ?? "")
        searchBar.text = lastSearchedCity
        
            anyCancellable = weatherViewModel?.$forecast.sink(receiveValue: { forecast in
                
                DispatchQueue.main.async {
                    self.errorLabel.isHidden = true
                }
                
                if forecast == nil {
                    self.hideViewsForError()
                } else {
                    
                    self.showViewsForResult()
                    self.cityLabel.text = forecast?.name
                    
                    if let url = URL(string: self.iconURL(icon: forecast?.weather.first?.icon ?? "")) {
                        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                            
                            if let error = error {
                                print("Error loading image: \(error.localizedDescription)")
                            }
                            
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self?.weatherImageView.image = image
                                }
                            }
                            
                        }.resume()
                    }
                    
                    
                    self.tempLabel.text = "\(self.weatherViewModel?.tempConversion(temp: forecast?.main.temp ?? 0.0) ?? 0)°"
                    self.descriptionLabel.text = forecast?.weather.first?.description?.capitalized
                    self.highTempLabel.text = "H: \(self.weatherViewModel?.tempConversion(temp: forecast?.main.tempMax ?? 0.0) ?? 0)°"
                    self.lowTempLabel.text = "L:  \(self.weatherViewModel?.tempConversion(temp: forecast?.main.tempMin ?? 0.0) ?? 0)°"
                    
                }
                
            })
    }
    
    
    //Through these two methods, the weather data is fetched based on the user's searched keyword
    @IBAction func searchLocation(_ sender: Any) {
        guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+"), !searchText.isEmpty else {
            return
        }
        weatherViewModel?.fetchWeatherInfo(city: searchText)
        searchBar.resignFirstResponder()
        showViewsForResult()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+"), !searchText.isEmpty else {
            return
        }
        weatherViewModel?.fetchWeatherInfo(city: searchText)
        searchBar.resignFirstResponder()
        showViewsForResult()
    }
    
    //Through these location methods, the user's location is requested. If the user grants access, the user's location is updated towards our app, and the data is fetched based on their location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
            showViewsForResult()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager?.stopUpdatingLocation()
        weatherViewModel?.fetcheDefaultWeatherInfo(location)
        showViewsForResult()
    }
    
    //To display the image of each weather condition depending on the parameter
    func iconURL(icon: String) -> String {
        return "https://openweathermap.org/img/wn/\(icon)@2x.png"
    }

    func showWelcomeMessage(){
        DispatchQueue.main.async {
            self.welcomeLabel.text = "Weather Search"
            self.welcomeSubLabel.text = "Feel free to search any city to see their current weather condition!"
        }
    }
    
    //Hides these sub views in case the data being pulled based on the user's search keyword comes back nil.
    func hideViewsForError() {
        DispatchQueue.main.async {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "Sorry! We have no information on that city, please try another! :)"
            self.cityLabel.isHidden = true
            self.weatherImageView.isHidden = true
            self.tempLabel.isHidden = true
            self.descriptionLabel.isHidden = true
            self.highTempLabel.isHidden = true
            self.lowTempLabel.isHidden = true
        }
        
    }
    
    //Shows these sub views if the weather data fetch is successful
    func showViewsForResult() {
        DispatchQueue.main.async {
            self.errorLabel.isHidden = true
            self.cityLabel.isHidden = false
            self.weatherImageView.isHidden = false
            self.tempLabel.isHidden = false
            self.descriptionLabel.isHidden = false
            self.highTempLabel.isHidden = false
            self.lowTempLabel.isHidden = false
        }
        
    }

}

