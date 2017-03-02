//
//  InfoPinViewController.swift
//  td5
//
//  Created by GUIOT Kevin on 27/02/2017.
//  Copyright © 2017 GUIOT Kevin / RUGOLETTO Romuald. All rights reserved.
//

import UIKit
import MapKit

class InfoPinViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var map: MKMapView!
    
    
    //Actions
    @IBAction func call(_ sender: UIButton) {
        
    }
    
    @IBAction func openMap(_ sender: UIButton) {
        
    }
    
    @IBAction func share(_ sender: UIButton) {
        
    }
    
    //Déclarations
    var poi = Poi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(poi.Name)
        print(poi.Image)
 
        
        self.title = poi.Name;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
