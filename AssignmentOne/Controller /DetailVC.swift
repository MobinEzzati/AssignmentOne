//
//  DetailVC.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/1/24.
//

import UIKit






class DetailVC: UIViewController {

    @IBOutlet weak var test: UILabel!
    var lableName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        test.text = lableName
        
    }
    

 
}





