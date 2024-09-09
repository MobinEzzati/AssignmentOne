//
//  NetworkingFile.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/2/24.
//


import Foundation

class NetworkService {
    // Singleton instance for ease of use across the app
    static let shared = NetworkService()
    
    // Base URL for the OpenWeatherMap API
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let apiKey = "23b674b547b9864684ecbfbc12d89b11" // Your OpenWeatherMap API key
    
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
    func fetchWeatherData(forCity city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        // Construct the URL with query parameters
        guard let url = URL(string: "\(baseURL)?q=\(city)&appid=\(apiKey)") else {
            let error = NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }
        
        // Call the generic fetch function with the constructed URL
        fetchData(url: url, completion: completion)
    }
}
