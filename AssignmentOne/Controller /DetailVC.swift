//
//  DetailVC.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/1/24.
//

import UIKit






class DetailVC: UIViewController {

//    @IBOutlet weak var test: UILabel!
    var lableName = ""
    var weatherResponse: WeatherResponse? // This will hold the data passed from the previous VC

    
    @IBOutlet weak var TestLable: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()

    
    }
    
    
    
    

    func setup() {
        
        if let weather = weatherResponse {
            
            TestLable.text = weather.name
            
        }
        NetworkService.shared.fetchWeatherData(forCity: lableName)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5.0
    }
}



// this is scrollView delegation method, here we gonna decide which ui view elements can be zoom in out so I made UI View with name "mainView" here on storyboard you guys can add elements and then test it and modify it.
extension DetailVC: UIScrollViewDelegate {
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
     
        return TestLable
        
    }
}








