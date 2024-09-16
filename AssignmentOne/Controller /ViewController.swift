//
//  ViewController.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 8/30/24.
//

import UIKit

class ViewController: UIViewController {
    
    let objcTableViewController = TableViewControllerObjc()

    override func viewDidLoad() {
        super.viewDidLoad()
     
//        NetworkService.shared.delegate = self
//
        // Mark: Fetch weather data for a city
//        NetworkService.shared.fetchWeatherData(forCity: "Salt Lake City")
        addChild(objcTableViewController)
               view.addSubview(objcTableViewController.view)
               objcTableViewController.view.frame = view.bounds
               objcTableViewController.didMove(toParent: self)
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


