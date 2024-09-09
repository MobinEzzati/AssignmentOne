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
    
    // Sample data source
    var items = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix","New York", "Los Angeles", "Chicago", "Houston", "Phoenix"]
    var filteredItems: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

    }

    func initalSetup() {
        // Initialize filtered items
        filteredItems = items
        


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
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: citiesCollectionView)
            if let indexPath = citiesCollectionView.indexPathForItem(at: location) {
                showDeleteConfirmation(forItemAt: indexPath)
            }
        }
    }
    
    func showDeleteConfirmation(forItemAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Delete City", message: "Are you sure you want to delete this city?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            // Remove the item from the data source
            self?.items.remove(at: indexPath.item)
            self?.filteredItems = self?.items ?? []
            
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
                  self.items.append(cityName)
                  self.filteredItems = self.items
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailPage" {
            if let detailVc = segue.destination as? DetailVC {
                detailVc.lableName = selectedItem // Pass the selected item to DetailVC
            }
        }
    }
}

// MARK: - UISearchBarDelegate Extension
extension CitisWeatherCollection: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredItems = items
        } else {
            
            filteredItems = items.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        citiesCollectionView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredItems = items
        citiesCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout Extension
extension CitisWeatherCollection: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .gray  // Customize your cell
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 23
        cell.Temp.text = "28"
        cell.weatherCondition.text = "Sunny"  // Placeholder text
        cell.CityName.text = filteredItems[indexPath.item]  // Use filtered data

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
        selectedItem = filteredItems[indexPath.item]

        // Perform segue to DetailVC
        performSegue(withIdentifier: "goToDetailPage", sender: self)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 10) / 2
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10  // Adjust the space between items
    }
}

// MARK: - NetworkService Delegation

extension CitisWeatherCollection: NetworkServiceDelegate {
    func didGetWeatherResponse(_ weatherResponse: WeatherResponse) {
       
        self.items.append(weatherResponse.name)
        self.filteredItems = self.items
        
        DispatchQueue.main.async {
            self.citiesCollectionView.reloadData()

        }
    
    }
    
    func didFailWithError(_ error: any Error) {
        print(error.localizedDescription)

    }
    
    
}






