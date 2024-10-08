//
//  SecondNetworkLayer.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/22/24.
//

import Foundation
// Protocol for handling weather response and errors
protocol SecondNetworkLayerDelegate: AnyObject {
    func didGetWeatherResponse(_ weatherResponse: WeatherResponse)
    func didFailWithError(_ error: Error)
}

class SecondNetworkLayer {
    
    // The delegate that will be notified about the result of the network call
    weak var delegate: SecondNetworkLayerDelegate? {
         didSet {
             print("Delegate set to: \(String(describing: delegate))")
         }
     }
    
    // Singleton instance for ease of use across the app
    static let shared = SecondNetworkLayer()
    
    // Base URL for the OpenWeatherMap API
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let apiKey = "23b674b547b9864684ecbfbc12d89b11" // Your OpenWeatherMap API key
    
    private var timer: Timer?
    
    private init() {}
    
    // Generic function to make API requests and decode the response
    private func fetchData<T: Codable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
                completion(.failure(error))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }
        
                
        task.resume()
    }
    
    // Function to fetch weather data for a specific city
    func fetchWeatherData(forCity city: String) {
        // Construct the URL with query parameters
        guard let url = URL(string: "\(baseURL)?q=\(city)&appid=\(apiKey)") else {
            let error = NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            delegate?.didFailWithError(error)
            return
        }
        
        // Call the generic fetch function with the constructed URL
        fetchData(url: url) { [weak self] (result: Result<WeatherResponse, Error>) in
            switch result {
            case .success(let weatherResponse):
                // Notify the delegate when data is successfully received
                self?.delegate?.didGetWeatherResponse(weatherResponse)
            case .failure(let error):
                // Notify the delegate about the failure
                self?.delegate?.didFailWithError(error)
            }
        }
    }
    
    func startRefreshingData(forCity city: String, refreshTime: Int) {
        // Invalidate any existing timer
        stopRefreshingData()
        
        // Schedule a timer to refresh data every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshTime), repeats: true) { [weak self] _ in
            self?.fetchWeatherData(forCity: city)
        }
        
        // Fetch the data immediately
        fetchWeatherData(forCity: city)
    }
    
    func stopRefreshingData() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopRefreshingData() // Ensure the timer is invalidated when the instance is deallocated
    }
    
}



