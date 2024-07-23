//
//  ViewController.swift
//  Weather
//
//  Created by user228349 on 7/21/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    
    let locationManager = CLLocationManager()
        let weatherAPIKey = "2642bc207b64236dc6d48d9984b03d3d"

        override func viewDidLoad() {
            super.viewDidLoad()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                locationManager.stopUpdatingLocation()
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
        
        func fetchWeatherData(latitude: Double, longitude: Double) {
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(43.4750038)&lon=\(-80.5161435)&appid=\(weatherAPIKey)&units=metric"
            guard let url = URL(string: urlString) else { return }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching weather data: \(error.localizedDescription)")
                    return
                }

                guard let data = data else { return }
                do {
                    let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.updateUI(with: weatherResponse)
                    }
                } catch {
                    print("Error decoding weather data: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
        
        func updateUI(with weather: WeatherResponse) {
            cityNameLabel.text = weather.name
            weatherDescriptionLabel.text = weather.weather.first?.description.capitalized
            temperatureLabel.text = "\(weather.main.temp)°C"
            humidityLabel.text = "Humidity: \(weather.main.humidity)%"
            windSpeedLabel.text = "Wind Speed: \(weather.wind.speed) m/s"

            if let icon = weather.weather.first?.icon {
                let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
                if let data = try? Data(contentsOf: iconURL!) {
                    weatherIconImageView.image = UIImage(data: data)
                }
            }
        }
    }

    struct WeatherResponse: Decodable {
        let name: String
        let weather: [Weather]
        let main: Main
        let wind: Wind
    }

    struct Weather: Decodable {
        let description: String
        let icon: String
    }

    struct Main: Decodable {
        let temp: Double
        let humidity: Int
    }

    struct Wind: Decodable {
        let speed: Double
    }
