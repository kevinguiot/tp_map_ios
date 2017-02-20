//
//  MapViewController.swift
//  td5
//
//  Created by GUIOT Kevin on 20/02/2017.
//  Copyright © 2017 GUIOT Kevin / RUGOLETTO Romuald. All rights reserved.
//

import UIKit
import SWXMLHash
import MapKit


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
        
        //Gestion de la map
        let map = MKMapView()
        map.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.center = view.center
        
        //Liste des pins
        var poisList = [Poi]()

        if let url = URL(string: "http://dam.lanoosphere.com/poi.xml") {
            
            if let data = try? Data(contentsOf: url) {
                
                let xml = SWXMLHash.parse(data)
                
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
        
        for pois in poisList {
            
            //On créé le POI
            let poi = MKPointAnnotation();
            
            //On y rajoute les coordonnées
            poi.coordinate = CLLocationCoordinate2DMake(
                CLLocationDegrees(pois.Latitude),
                CLLocationDegrees(pois.Longitude)
            )
            
            //On l'ajoute à la map
            map.addAnnotation(poi)
        }
        
        self.view.addSubview(map);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
