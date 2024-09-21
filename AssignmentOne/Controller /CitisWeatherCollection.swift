//
//  CitisWeatherCollection.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/1/24.
//

import UIKit
import UnsplashPhotoPicker




class CitisWeatherCollection: UIViewController {
    
    

    @IBOutlet weak var searchCity: UISearchBar!
    @IBOutlet weak var citiesCollectionView: UICollectionView!
    
    
    
    @IBOutlet weak var TableViewContainer: UIView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    var selectedItem = ""
    var searchWorkItem: DispatchWorkItem?
    var cityWeatherModel = CityWeatherModel()
    
    
    let objcTableViewController = TableViewControllerObjc()
    var cities :[WeatherResponse] = []
    var filteredItems: [WeatherResponse] = []
    private var photos = [UnsplashPhoto]()
    var unsplashImageView: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
        
   

    }
    
    
    
    
    
    func getFavoriteItemInex(cell:CollectionViewCell){
        
        print("click on favorite star")
        let indexPathTapped = citiesCollectionView.indexPath(for: cell)
        print(indexPathTapped ?? 0)
    }


    func initalSetup() {
        // Initialize filtered items
        filteredItems = cityWeatherModel.getCities()
        cityWeatherModel.getCityImage(cityName: "dallas")

        // Setup the collection view
        citiesCollectionView.delegate = self
        citiesCollectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        citiesCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        citiesCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        

        // Setup the search bar
        searchCity.placeholder = "Search for a city"
        searchCity.delegate = self
        searchCity.layer.borderWidth = 1
        searchCity.layer.borderColor = UIColor.clear.cgColor
        

    
        //Setup SegmentedController
        segmentedController.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        
        
        
        // setup Network delegation
//        NetworkService.shared.delegate = self
        cityWeatherModel.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
           citiesCollectionView.addGestureRecognizer(longPressGesture)
        
        
 

        
    }
    
    
    
    // switch between light and dark
    
    @IBAction func LightAndDark(_ sender: UISwitch) {
        
        cityWeatherModel.toggleTheme(isDarkMode: sender.isOn)
    }
    
    
    
    
    

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Show the Objective-C table view controller's view
            if objcTableViewController.view.superview == nil {
                addChild(objcTableViewController)
                TableViewContainer.addSubview(objcTableViewController.view)
                objcTableViewController.view.frame = TableViewContainer.bounds
                objcTableViewController.didMove(toParent: self)
            }
            objcTableViewController.view.isHidden = false
            TableViewContainer.isHidden = false
            citiesCollectionView.isHidden = true

        case 1:
            // Hide the Objective-C table view controller's view
            objcTableViewController.view.isHidden = true
            TableViewContainer.isHidden = true
            citiesCollectionView.isHidden = false
            citiesCollectionView.frame = view.bounds
            citiesCollectionView.isUserInteractionEnabled = true
            citiesCollectionView.allowsSelection = true



        default:
            break
        }
    }

    
    
    // with this function you can delete the collection view cell
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: citiesCollectionView)
            if let indexPath = citiesCollectionView.indexPathForItem(at: location) {
                showDeleteConfirmation(forItemAt: indexPath)
            }
        }
    }
    
    
    // this function will put seleceted city from all collection view to favorite tableView
    
    
    // this function pop up's the alter box and says that are you sure that you want to delete city

    func showDeleteConfirmation(forItemAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Delete City", message: "Are you sure you want to delete this city?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            // Remove the item from the data source
            self?.cityWeatherModel.removeCity(at: indexPath.item)
            self?.filteredItems = self?.cityWeatherModel.getCities() ?? []
            
            // Delete the item from the collection view
            self?.citiesCollectionView.deleteItems(at: [indexPath])
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    @IBAction func addCity(_ sender: Any) {
        
        self.objcTableViewController.view.isHidden = true
        self.TableViewContainer.isHidden = true
        self.segmentedController.selectedSegmentIndex = 1
       
        
        let alert = UIAlertController(title: "Add City", message: "Enter the name of the city", preferredStyle: .alert)
          alert.addTextField { textField in
              textField.placeholder = "City name"
          }
          let addAction = UIAlertAction(title: "Add", style: .default) { _ in
              if let cityName = alert.textFields?.first?.text, !cityName.isEmpty {
//                  NetworkService.shared.fetchWeatherData(forCity: cityName)
                  self.cityWeatherModel.getCityInfo(cityName: cityName)
                  self.citiesCollectionView.reloadData()

              }
              
             
          }
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alert.addAction(addAction)
          alert.addAction(cancelAction)
          present(alert, animated: true, completion: nil)

    }
    
}

// MARK: - UISearchBarDelegate Extension
extension CitisWeatherCollection: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            // Use the model to filter cities based on the search text
            self.filteredItems = self.cityWeatherModel.filterCities(by: searchText.lowercased())
            
            // Reload the collection view to reflect changes
            self.citiesCollectionView.reloadData()
            self.objcTableViewController.tableView.reloadData()
        }

        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Clear the search text
        searchBar.text = ""
        
        // Dismiss keyboard
        searchBar.resignFirstResponder()

        // Reset the filteredItems to all cities
        filteredItems = cityWeatherModel.getCities()
        citiesCollectionView.reloadData()

        // Optionally, hide the cancel button after cancelling
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout Extension
extension CitisWeatherCollection: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CollectionViewCellDelegate {
    
    func removeFromFavList(at index: IndexPath) {
        print("removeSectionClicked")

        // Check if index is valid and within bounds
        if index.row < objcTableViewController.dataArray.count {
            // Remove the item from the dataArray
            objcTableViewController.dataArray.removeObject(at: index.row) // NSMutableArray method
            
            // Reload the tableView to reflect changes
            objcTableViewController.tableView.reloadData()
        } else {
            print("Index out of bounds")
        }
    }

    
    
    // add item to the favorite list by creating object for tableView
    func didTapFavoriteButton(at index: IndexPath) {
        print("addclicked")
        let currentItem = cityWeatherModel.getCityByIndex(at: index.row)
              let newCityWeather: [String: String] = [
                "city": "\(currentItem.name)",  // Example data
                "temp": "\(currentItem.main.temp)",
                "max": "\(currentItem.main.tempMax)",
                "min": "\(currentItem.main.tempMin)"
              ]
              
              // Cast dataArray to NSMutableArray to allow modification
        if let objcDataArray = objcTableViewController.dataArray {
                   objcDataArray.add(newCityWeather)  // Add the new city weather data
                   objcTableViewController.tableView.reloadData()  // Reload table to reflect changes
               } else {
                   print("Failed to cast dataArray to NSMutableArray")
               }
              
              // Reload the table view in case you want to see the updated data
              objcTableViewController.tableView.reloadData()
        
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .gray  // Customize your cell
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 23
        cell.delegate = self 
        cell.indexPath = indexPath
        cell.CityName.text = filteredItems[indexPath.row].name

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        // Scale down animation
        UIView.animate(withDuration: 0.1,
                       animations: {
                           cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                       },
                       completion: { _ in
                           // Scale up animation back to original state
                           UIView.animate(withDuration: 0.1) {
                               cell.transform = CGAffineTransform.identity
                           }
                       })

        // Store selected item name
        // Perform segue to DetailVC
        performSegue(withIdentifier: "goToDetailPage", sender: filteredItems[indexPath.row])

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 20) / 2
        let height = (collectionView.frame.size.height - 20) / 2
        return CGSize(width: 190, height: 190)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10  // Adjust the space between items
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailPage" {
            let destination = segue.destination as! DetailVC
            
            // Pass the selected `WeatherResponse` object
            if let weatherResponse = sender as? WeatherResponse {
                destination.cityWeather = weatherResponse
            }
        }
    }
}

// MARK: - NetworkService Delegation

extension CitisWeatherCollection : ControllerServiceDelegate {
    func didReceiveItems(_ weatherResponse: WeatherResponse) {
           // Add the new weatherResponse to the cities array
        cityWeatherModel.addCity(weatherResponse)
        filteredItems = cityWeatherModel.getCities()
           
           // Reload the tableView to display the new data
           DispatchQueue.main.async {
               self.citiesCollectionView.reloadData()
           }
       }
       
       func didFailWithError(_ error: Error) {
           // Handle error (e.g., show an alert)
           let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           DispatchQueue.main.async {
               self.present(alert, animated: true, completion: nil)
           }
       }
    
}

extension CitisWeatherCollection: UnsplashPhotoPickerDelegate {
    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        print("Unsplash photo picker did select \(photos.count) photo(s)")
        
        // Assuming we want the first selected photo (you can modify this for multiple selections)
        guard let firstPhoto = photos.first else { return }

        // Get the URL for the first available photo size (e.g., small, regular, full)
        guard let imageUrl = firstPhoto.urls.values.first else {
            print("No valid URL found for the photo.")
            return
        }

        // Convert URL to a String and download the image from the URL
        URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
            if let error = error {
                print("Failed to download image: \(error)")
                return
            }

            // Ensure the response contains data
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // Set the downloaded image to the UIImageView
//                    self?.cityImage.image = image
                }
            }
        }.resume()
    }

    func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
        print("Unsplash photo picker did cancel")
    }
}



//extension CitisWeatherCollection: UnsplashPhotoPickerDelegate {
//    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
//        print("Unsplash photo picker did select \(photos.count) photo(s)")
//        
//        // Assuming we want the first selected photo (you can modify this for multiple selections)
//        guard let firstPhoto = photos.first else { return }
//
//        // Get the URL for the first available photo size (e.g., small, regular, full)
//        guard let imageUrl = firstPhoto.urls.values.first else {
//            print("No valid URL found for the photo.")
//            return
//        }
//
//        // Convert URL to a String and download the image from the URL
//        URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
//            if let error = error {
//                print("Failed to download image: \(error)")
//                return
//            }
//
//            // Ensure the response contains data
//            if let data = data, let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    // Set the downloaded image to the UIImageView
//                    self?.unsplashImageView.image = image
//                }
//            }
//        }.resume()
//    }
//
//    func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
//        print("Unsplash photo picker did cancel")
//    }
//}



//
//extension CitisWeatherCollection: NetworkServiceDelegate {
//    func didGetWeatherResponse(_ weatherResponse: WeatherResponse) {
//       
//        cityWeatherModel.addCity(weatherResponse)
//        
//        
//        
//        self.filteredItems = cityWeatherModel.getCities()
//        
//        
//        
//        
//        
//        DispatchQueue.main.async {
//            self.citiesCollectionView.reloadData()
//
//        }
//    
//    }
//    
//    func didFailWithError(_ error: any Error) {
//        print(error.localizedDescription)
//
//    }
//    
//    
//}









