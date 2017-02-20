//
//  MapViewController.swift
//  td5
//
//  Created by GUIOT Kevin on 20/02/2017.
//  Copyright © 2017 GUIOT Kevin / RUGOLETTO Romuald. All rights reserved.
//

import UIKit
import SWXMLHash


struct Poi {
    var Id : Int;
    var Name : String;
    var Image : String;
    var Latitude : Float;
    var Longitude : Float;
}

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: "http://dam.lanoosphere.com/poi.xml") {
            
            if let data = try? Data(contentsOf: url) {
                
                let xml = SWXMLHash.parse(data)
                
                var poisList = [Poi]()
                
                for pois in xml["Data"]["POI"].all {

                    let poi = Poi(
                        Id: Int((pois.element?.allAttributes["id"]?.text)!)!,
                        Name: (pois.element?.allAttributes["name"]?.text)!,
                        Image: (pois.element?.allAttributes["image"]?.text)!,
                        Latitude: Float((pois.element?.allAttributes["latitude"]?.text)!)!,
                        Longitude: Float((pois.element?.allAttributes["longitude"]?.text)!)!
                    )
                   
                    poisList.append(poi);
                }
 
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
