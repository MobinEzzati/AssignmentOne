//
//  DetailVC.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/1/24.
//

import UIKit
import UnsplashPhotoPicker



import UIKit
import UnsplashPhotoPicker

class DetailVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        print("Is maxTempLabel connected? \(maxTempLabel != nil)")
        
        let configuration = UnsplashPhotoPickerConfiguration(
                    accessKey: "r7ICKmr1RBEdfhR1DcX5ZpYL0Qt4oua9DjgBXIe-Fx4",
                    secretKey: "UAPk5AxpaYUQdiKgj9mtZfJceY1IJU8A_pfvUxubmfI",
                    query: "Dallas",
                    allowsMultipleSelection: (SelectionType.single.rawValue != 0)
                )

        let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
            unsplashPhotoPicker.photoPickerDelegate = self
        
        
        present(unsplashPhotoPicker, animated: true, completion: nil)
        setupUI()
        setupPickerView()
        setupSlider()
        setupStepper()
        setupRefreshTimer(interval: 30)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasPresentedPhotoPicker {
               hasPresentedPhotoPicker = true
               initializeUnsplashPicker()
           }
    }
    
    // MARK: - Setup Methods
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
    
    private func setupPickerView() {
        unitPicker.delegate = self
        unitPicker.dataSource = self
        unitLabel.text = "Unit: \(selectedUnit)"
    }
    
    private func setupSlider() {
        forecastSlider.minimumValue = 0
        forecastSlider.maximumValue = 2
        forecastSlider.value = 1 // Default to "Wind"
    }
    
    private func setupStepper() {
        refreshStepper.minimumValue = 0
        refreshStepper.maximumValue = 2
        refreshStepper.stepValue = 1
        refreshStepper.value = 1 // Default to 30 mins
        updateRefreshLabel(interval: 30)
    }
    
    private func initializeUnsplashPicker() {
        let configuration = UnsplashPhotoPickerConfiguration(
            accessKey: "r7ICKmr1RBEdfhR1DcX5ZpYL0Qt4oua9DjgBXIe-Fx4",
            secretKey: "UAPk5AxpaYUQdiKgj9mtZfJceY1IJU8A_pfvUxubmfI",
            query: "dallas", // using the passed label name for the city image
            allowsMultipleSelection: false
        )
        
        let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
        unsplashPhotoPicker.photoPickerDelegate = self
        
        present(unsplashPhotoPicker, animated: true, completion: nil)
    }

    private func updateTemperatureLabels(for weather: Main) {
        let tempConversion: (Double) -> String = selectedUnit == "Celsius" ?
            { "\((String(format: "%.1f", $0 - 273.15)))°C" } :
            { "\((String(format: "%.1f", ($0 - 273.15) * 9 / 5 + 32)))°F" }

        maxTempLabel.text = "Max: \(tempConversion(weather.tempMax))"
        currentTempLabel.text = "Current: \(tempConversion(weather.temp))"
        minTempLabel.text = "Min: \(tempConversion(weather.tempMin))"
    }
    
    // MARK: - UIPickerView Data Source & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { units.count }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        units[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUnit = units[row]
        unitLabel.text = "Unit: \(selectedUnit)"
        setupUI()
        fetchWeatherData(forecastType: getCurrentForecastType(), unit: selectedUnit)
    }
    
    // MARK: - Actions
    @IBAction func forecastSliderChanged(_ sender: UISlider) {
        guard let visibility = cityWeather?.visibility, let wind = cityWeather?.wind, let clouds = cityWeather?.clouds else { return }
        updateForecastLabel(for: Int(sender.value), visibility: visibility, wind: wind, clouds: clouds)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let intervals = [10, 30, 60]
        let interval = intervals[Int(sender.value)]
        updateRefreshLabel(interval: interval)
        setupRefreshTimer(interval: interval)
    }

    // MARK: - Helper Methods
    private func updateRefreshLabel(interval: Int) {
        refreshLabel.text = "Refresh every \(interval) minutes"
    }
    
    private func setupRefreshTimer(interval: Int) {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(timeInterval: TimeInterval(interval * 60), target: self, selector: #selector(refreshWeatherData), userInfo: nil, repeats: true)
    }
    
    @objc private func refreshWeatherData() {
        fetchWeatherData(forecastType: getCurrentForecastType(), unit: selectedUnit)
    }

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
extension DetailVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cityImageView
    }
}

// MARK: - UnsplashPhotoPickerDelegate
extension DetailVC: UnsplashPhotoPickerDelegate {
    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        guard let firstPhoto = photos.first, let imageUrl = firstPhoto.urls[.regular] else {
            print("No valid URL found for the photo.")
            self.photos = photos
            print(photos.first?.urls)
            return
        }

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
