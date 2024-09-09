//
//  ViewController.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 8/30/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("dfdfdfdfdfd")
        // Example usage to fetch weather data for Tehran
        NetworkService.shared.fetchWeatherData(forCity: "Tehran") { result in
            switch result {
            case .success(let weatherResponse):
                print("City: \(weatherResponse.name)")
                print("Temperature: \(weatherResponse.main.temp)°K")
                print("Weather: \(weatherResponse.weather.first?.description ?? "N/A")")
                
                // Update UI on the main thread
                DispatchQueue.main.async {
                    // Update your UI with weather data here
                }
                
            case .failure(let error):
                print("Error fetching weather data: \(error.localizedDescription)")
                
                // Handle error on the main thread
                DispatchQueue.main.async {
                    // Update UI to show error
                }
            }
        }
    }
}


