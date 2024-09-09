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
     
        NetworkService.shared.delegate = self
        
        // Fetch weather data for a city
        NetworkService.shared.fetchWeatherData(forCity: "Salt Lake City")
    }
}


extension ViewController: NetworkServiceDelegate {
    func didGetWeatherResponse(_ weatherResponse: WeatherResponse) {
        print(weatherResponse.main.humidity)
    }
    
    func didFailWithError(_ error: any Error) {
        print(error.localizedDescription)

    }
    
    
}


