//
//  DetailVC.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/1/24.
//


import UIKit
import UnsplashPhotoPicker

class DetailVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, SecondNetworkLayerDelegate {
    // MARK: - NetworkServiceDelegate Methods

    // Called when weather data is successfully retrieved
    func didGetWeatherResponse(_ weatherResponse: WeatherResponse) {
        
        print(weatherResponse.main.temp)
        print(weatherResponse.main.tempMax)
        print(weatherResponse.main.tempMin)

        updateTemperatureLabels(for: weatherResponse.main)
    }
    
    // Called when an error occurs during the network request
    func didFailWithError(_ error: any Error) {
        // Print the error's localized description
        print(error.localizedDescription)
    }
    
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var forecastSlider: UISlider!
    @IBOutlet weak var forecastLabel: UILabel!
    @IBOutlet weak var refreshStepper: UIStepper!
    @IBOutlet weak var refreshLabel: UILabel!
    @IBOutlet weak var unitPicker: UIPickerView!
    @IBOutlet weak var unitLabel: UILabel!
    
    // MARK: - Properties
    var labelName = ""  // City name or other label passed from previous VC
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var cityWeather: WeatherResponse?  // Holds the weather data passed from the previous VC
    
    let units = ["Celsius", "Fahrenheit"] // Picker options
    var selectedUnit = "Celsius" // Default unit selection
    var refreshTimer: Timer?
    private var photos = [UnsplashPhoto]()
    var hasPresentedPhotoPicker = false



    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Verify if maxTempLabel is properly connected

        print("Is maxTempLabel connected? \(maxTempLabel != nil)")
        
        // Configure Unsplash Photo Picker with sample data for the city name  You should choose city and then it going to place on UIimage view and then you are able to zoom in and out

        let configuration = UnsplashPhotoPickerConfiguration(
                    accessKey: "r7ICKmr1RBEdfhR1DcX5ZpYL0Qt4oua9DjgBXIe-Fx4",
                    secretKey: "UAPk5AxpaYUQdiKgj9mtZfJceY1IJU8A_pfvUxubmfI",
                    query: cityWeather?.name,
                    allowsMultipleSelection: (SelectionType.single.rawValue != 0)
                )

        let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
            unsplashPhotoPicker.photoPickerDelegate = self
        
        
        present(unsplashPhotoPicker, animated: true, completion: nil)
        setupUI()
        setupPickerView()
        setupSlider()
        setupStepper()
        
        setupRefreshTimer(interval: 10, citName: cityWeather!.name)
        SecondNetworkLayer.shared.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Present Unsplash photo picker only once

        if !hasPresentedPhotoPicker {
               hasPresentedPhotoPicker = true
            if let cityName = cityWeather?.name {
                
                initializeUnsplashPicker(cityName: cityName)

            }
           }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the timer when the view disappears
        refreshTimer?.invalidate()
        NetworkService.shared.delegate = nil

        
    }

    
    // MARK: - Setup Methods
    // Set up the initial UI elements with the current weather data

    private func setupUI() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5.0
        
        guard let weather = cityWeather?.main else { return }
        updateTemperatureLabels(for: weather)
        
        if let visibility = cityWeather?.visibility,
           let wind = cityWeather?.wind,
           let clouds = cityWeather?.clouds {
            updateForecastLabel(for: Int(forecastSlider.value), visibility: visibility, wind: wind, clouds: clouds)
        }
        

    }
    
    // Set up the unit picker view with the delegate and data source

    
    private func setupPickerView() {
        unitPicker.delegate = self
        unitPicker.dataSource = self
        unitLabel.text = "Unit: \(selectedUnit)"
    }
    // Configure the forecast slider with default values

    
    private func setupSlider() {
        forecastSlider.minimumValue = 0
        forecastSlider.maximumValue = 2
        forecastSlider.value = 1 // Default to "Wind"
    }
    // Configure the refresh stepper with default values

    private func setupStepper() {
        refreshStepper.minimumValue = 0
        refreshStepper.maximumValue = 2
        refreshStepper.stepValue = 1
        refreshStepper.value = 1 // Default to 30 mins
        updateRefreshLabel(interval: 30)
    }
    
    // Initialize Unsplash Photo Picker with the given city name

    
    private func initializeUnsplashPicker(cityName:String) {
        let configuration = UnsplashPhotoPickerConfiguration(
            accessKey: "r7ICKmr1RBEdfhR1DcX5ZpYL0Qt4oua9DjgBXIe-Fx4",
            secretKey: "UAPk5AxpaYUQdiKgj9mtZfJceY1IJU8A_pfvUxubmfI",
            query: cityName, // using the passed label name for the city image
            allowsMultipleSelection: false
        )
        
        let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
        unsplashPhotoPicker.photoPickerDelegate = self
        
        present(unsplashPhotoPicker, animated: true, completion: nil)
    }
    
    // Update temperature labels based on the provided weather data


    private func updateTemperatureLabels(for weather: Main) {
        
      

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return } // Safely unwrap self
            let tempConversion: (Double) -> String = self.selectedUnit == "Celsius" ?
                { "\((String(format: "%.1f", $0 - 273.15)))°C" } :
                { "\((String(format: "%.1f", ($0 - 273.15) * 9 / 5 + 32)))°F" }

            self.maxTempLabel.text = "Max: \(tempConversion(weather.tempMax))"
            self.currentTempLabel.text = "Current: \(tempConversion(weather.temp))"
            self.minTempLabel.text = "Min: \(tempConversion(weather.tempMin))"
        }
    }
    
    // MARK: - UIPickerView Data Source & Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // Only one component (column) in the picker view
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Return the number of unit options available
        units.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Return the unit option title for the given row
        units[row]
    }
    
    // Update the selected unit when the user selects a row in the picker view

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUnit = units[row]
        unitLabel.text = "Unit: \(selectedUnit)"
        setupUI()
        fetchWeatherData(forecastType: getCurrentForecastType(), unit: selectedUnit)
    }
    
    // MARK: - Actions
    // Update forecast label based on the slider's value

    @IBAction func forecastSliderChanged(_ sender: UISlider) {
        guard let visibility = cityWeather?.visibility, let wind = cityWeather?.wind, let clouds = cityWeather?.clouds else { return }
        updateForecastLabel(for: Int(sender.value), visibility: visibility, wind: wind, clouds: clouds)
    }
    
    // Update the refresh interval when the stepper's value changes

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let intervals = [600, 1800, 3600]
        let interval = intervals[Int(sender.value)]
        
        updateRefreshLabel(interval: interval)
        setupRefreshTimer(interval: interval, citName: cityWeather?.name ?? "")
    }

    // MARK: - Helper Methods
    
    // Update the refresh label to display the chosen interval

    private func updateRefreshLabel(interval: Int) {
        refreshLabel.text = "Refresh every \(interval) Seconds"
    }
    
    
    // Set up the refresh timer to fetch data periodically

    private func setupRefreshTimer(interval: Int, citName:String) {
        SecondNetworkLayer.shared.startRefreshingData(forCity: "\(citName)", refreshTime: interval)

    }
    // Refresh the weather data when the timer triggers

    @objc private func refreshWeatherData() {
        fetchWeatherData(forecastType: getCurrentForecastType(), unit: selectedUnit)
    }
    
    // Update the forecast label based on the selected forecast type

    private func updateForecastLabel(for index: Int, visibility: Int, wind: Wind, clouds: Clouds) {
        let forecastOptions = [
            "Visibility: \(visibility) meters",
            "Wind Speed: \(wind.speed) m/s, Direction: \(wind.deg)°",
            "Cloud Coverage: \(clouds.all)%"
        ]
        forecastLabel.text = forecastOptions[index]
    }
    
    private func fetchWeatherData(forecastType: String, unit: String) {
        print("Fetching \(forecastType) forecast in \(unit)...")
        // Implement network service or API call here to fetch weather data
    }
    
    private func getCurrentForecastType() -> String {
        "Current"
    }
}

// MARK: - UIScrollViewDelegate

// extension for zoom in and out function
extension DetailVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cityImageView
    }
}

// MARK: - UnsplashPhotoPickerDelegate
// extension to setup Unsplash image picker

extension DetailVC: UnsplashPhotoPickerDelegate {
    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        guard let firstPhoto = photos.first, let imageUrl = firstPhoto.urls[.regular] else {
            print("No valid URL found for the photo.")
            self.photos = photos
            return
        }

        // download image from url and put on imageView
        URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, error in
            if let error = error {
                print("Failed to download image: \(error)")
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.cityImageView.image = image
                }
            }
        }.resume()
    }

    func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
        print("Unsplash photo picker did cancel")
    }
}
