//
//  CitisWeatherCollection.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/1/24.
//

import UIKit




class CitisWeatherCollection: UIViewController {

    @IBOutlet weak var searchCity: UISearchBar!
    @IBOutlet weak var citiesCollectionView: UICollectionView!
    var selectedItem = ""
    var searchWorkItem: DispatchWorkItem?

    

    var cities :[WeatherResponse] = []
  
    var filteredItems: [WeatherResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

    }

    func initalSetup() {
        // Initialize filtered items
        filteredItems = cities
        


        // Setup the collection view
        citiesCollectionView.delegate = self
        citiesCollectionView.dataSource = self
        citiesCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        citiesCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")

        // Setup the search bar
        searchCity.placeholder = "Search for a city"
        searchCity.delegate = self
        searchCity.layer.borderWidth = 1
        searchCity.layer.borderColor = UIColor.clear.cgColor
        
        // setup Network delegation
        NetworkService.shared.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
           citiesCollectionView.addGestureRecognizer(longPressGesture)
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
    
    // this function pop up's the alter box and says that are you sure that you want to delete city

    func showDeleteConfirmation(forItemAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Delete City", message: "Are you sure you want to delete this city?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            // Remove the item from the data source
            self?.cities.remove(at: indexPath.item)
            self?.filteredItems = self?.cities ?? []
            
            // Delete the item from the collection view
            self?.citiesCollectionView.deleteItems(at: [indexPath])
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    

    @objc func addTapped() {
        // Your add functionality here, for example, showing an alert to input a new city
        let alert = UIAlertController(title: "Add City", message: "Enter the name of the city", preferredStyle: .alert)
          alert.addTextField { textField in
              textField.placeholder = "City name"
          }
          let addAction = UIAlertAction(title: "Add", style: .default) { _ in
              if let cityName = alert.textFields?.first?.text, !cityName.isEmpty {
                  self.filteredItems = self.cities
                  self.citiesCollectionView.reloadData()
              }
          }
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alert.addAction(addAction)
          alert.addAction(cancelAction)
          present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addCity(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add City", message: "Enter the name of the city", preferredStyle: .alert)
          alert.addTextField { textField in
              textField.placeholder = "City name"
          }
          let addAction = UIAlertAction(title: "Add", style: .default) { _ in
              if let cityName = alert.textFields?.first?.text, !cityName.isEmpty {
                  NetworkService.shared.fetchWeatherData(forCity: cityName)

              }
          }
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alert.addAction(addAction)
          alert.addAction(cancelAction)
          present(alert, animated: true, completion: nil)
        
//        if let city = searchCity.text {
//            
//
//            
//        }
//        

    }
    
}

// MARK: - UISearchBarDelegate Extension
extension CitisWeatherCollection: UISearchBarDelegate {


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            if searchText.isEmpty {
                self.filteredItems = self.cities
            } else {
                self.filteredItems = self.cities.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
            self.citiesCollectionView.reloadData()
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem) // Delay by 0.3 seconds
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder() // Dismiss keyboard
        filteredItems = cities
        citiesCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout Extension
extension CitisWeatherCollection: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .gray  // Customize your cell
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 23
        cell.CityName.text = cities[indexPath.row].name

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
        let size = (collectionView.frame.size.width - 10) / 2
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10  // Adjust the space between items
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailPage" {
            let destination = segue.destination as! DetailVC
            
            // Pass the selected `WeatherResponse` object
            if let weatherResponse = sender as? WeatherResponse {
                destination.weatherResponse = weatherResponse
            }
        }
    }
}

// MARK: - NetworkService Delegation

extension CitisWeatherCollection: NetworkServiceDelegate {
    func didGetWeatherResponse(_ weatherResponse: WeatherResponse) {
       
        self.cities.append(weatherResponse)
        self.filteredItems = self.cities
        
        
        DispatchQueue.main.async {
            self.citiesCollectionView.reloadData()

        }
    
    }
    
    func didFailWithError(_ error: any Error) {
        print(error.localizedDescription)

    }
    
    
}






