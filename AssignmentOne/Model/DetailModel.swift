//
//  DetailViewModel.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/22/24.
//

import Foundation

protocol DetailModelTempDelegate: AnyObject {
    func didReceiveItems(_ items: WeatherResponse)
    func didFailWithError(_ error: Error)
}

class DetailModel: NetworkServiceDelegate {
    
    private var cities: [WeatherResponse] = []
    weak var delegate: DetailModelTempDelegate?
    
    init() {
        NetworkService.shared.delegate = self // Set the model as the delegate for the network service
        

    }
    
     func startRefreshingData(interval: Int, citName:String) {
        NetworkService.shared.startRefreshingData(forCity: "\(citName)", refreshTime: interval)

    }
    
    
    // MARK: - NetworkServiceDelegate Methods
    
    func didGetWeatherResponse(_ weatherResponse: WeatherResponse) {
        // Add the new weather response to the cities array
        delegate?.didReceiveItems(weatherResponse)
        // Notify the relevant part of the app (via delegate or callback) that new data is available
        // For example, you might want to reload the UI
    }
    
    func didFailWithError(_ error: Error) {
        // Handle the error (e.g., show an alert)
        print("Failed to fetch weather data: \(error.localizedDescription)")
        delegate?.didFailWithError(error)

    }
    
    
    deinit {
        NetworkService.shared.delegate = nil
    }
}

