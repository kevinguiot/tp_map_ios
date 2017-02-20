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

        //Parcourt des pins
        for pois in poisList {
            
            //On créé le POI
            let poi = MKPointAnnotation();
            
            let longitude = CLLocationDegrees(pois.Longitude)
            let latitude  = CLLocationDegrees(pois.Latitude)

            let location = CLLocation(latitude: latitude, longitude: longitude)
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude);

            //On y rajoute les coordonnées
            poi.coordinate = coordinate

            //On place le reverseGeocodeLocation
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                let addresse = getAddress(placemark: (placemarks?[0])!)
            })
            
            //On rajoute le pin à la map
            map.addAnnotation(poi);
        }

        self.view.addSubview(map);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//Fonction permettant de récupérer une adresse d'un marqueur
func getAddress(placemark : CLPlacemark) -> String {
    
    var adresse : String = ""
    
    /*format Chine*/
    if placemark.isoCountryCode == "TW" {
        if placemark.country != nil {
            adresse = placemark.country!
        }
        if placemark.subAdministrativeArea != nil {
            adresse = adresse + placemark.subAdministrativeArea! + ", "
        }
        if placemark.postalCode != nil {
            adresse = adresse + placemark.postalCode! + " "
        }
        if placemark.locality != nil {
            adresse = adresse + placemark.locality!
        }
        if placemark.thoroughfare != nil {
            adresse = adresse + placemark.thoroughfare!
        }
        if placemark.subThoroughfare != nil {
            adresse = adresse + placemark.subThoroughfare!
        }
    } else {
        if placemark.subThoroughfare != nil {
            adresse = placemark.subThoroughfare! + " "
        }
        if placemark.thoroughfare != nil {
            adresse = adresse + placemark.thoroughfare! + ", "
        }
        if placemark.postalCode != nil {
            adresse = adresse + placemark.postalCode! + " "
        }
        if placemark.locality != nil {
            adresse = adresse + placemark.locality!
        }
    }
    
    return adresse
}
