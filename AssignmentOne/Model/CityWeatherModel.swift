//
//  MainModel.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/17/24.
//

import Foundation
import UnsplashPhotoPicker

enum SelectionType: Int {
    case single
    case multiple
}
protocol ControllerServiceDelegate: AnyObject {
    func didReceiveItems(_ items: WeatherResponse)
    func didFailWithError(_ error: Error)
}


class CityWeatherModel: NetworkServiceDelegate {
    
    private var cities: [WeatherResponse] = []
    weak var delegate: ControllerServiceDelegate?
    private var photos = [UnsplashPhoto]()
    
    init() {
        NetworkService.shared.delegate = self // Set the model as the delegate for the network service
        
//        let configuration = UnsplashPhotoPickerConfiguration(
//                    accessKey: "r7ICKmr1RBEdfhR1DcX5ZpYL0Qt4oua9DjgBXIe-Fx4",
//                    secretKey: "UAPk5AxpaYUQdiKgj9mtZfJceY1IJU8A_pfvUxubmfI",
//                    query: "Dallas",
//                    allowsMultipleSelection: (SelectionType.single.rawValue != 0)
//                )
//        
//        let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
//            unsplashPhotoPicker.photoPickerDelegate = self
    }
    
    
    
    // Add city to the list
    func addCity(_ city: WeatherResponse) {
        cities.append(city)
    }
    
    func getCityImage(cityName: String) {
        print("this is get city")
    
        
        
    }
    
    // Fetch weather data for a city
    func getCityInfo(cityName: String) {
        NetworkService.shared.fetchWeatherData(forCity: cityName)
    }
    
    // Remove city from the list
    func removeCity(at index: Int) {
        cities.remove(at: index)
    }
    
    // Return the list of cities
    func getCities() -> [WeatherResponse] {
        return cities
    }
    
    // Get city by index
    func getCityByIndex(at index: Int) -> WeatherResponse {
        return cities[index]
    }
    
    // Theme toggle function
    func toggleTheme(isDarkMode: Bool) {
        let interfaceStyle: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = interfaceStyle
            }
        }
    }
    
    // Filter cities based on search text
    func filterCities(by searchText: String) -> [WeatherResponse] {
        if searchText.isEmpty {
            return cities
        }
        
        let filtered = cities.filter { city in
            city.name.lowercased().contains(searchText.lowercased())
        }
        
        // Sort cities by prioritizing names that start with the search text
        let sortedCities = filtered.sorted {
            let city1StartsWith = $0.name.lowercased().hasPrefix(searchText.lowercased())
            let city2StartsWith = $1.name.lowercased().hasPrefix(searchText.lowercased())
            
            if city1StartsWith != city2StartsWith {
                return city1StartsWith && !city2StartsWith
            } else {
                return $0.name.lowercased() < $1.name.lowercased()
            }
        }
        
        return sortedCities
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
}

