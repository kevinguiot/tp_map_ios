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
import CoreLocation

struct Poi {
    var Id : Int;
    var Name : String;
    var Image : String;
    var Latitude : Float;
    var Longitude : Float;
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //Création de la map
    var map = MKMapView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        map.delegate = self
        
        //Coordonnées de Cannes
        let coordinatesCannes: [Float] = [
            43.551534,
            7.016659
        ];

        //Gestion de la map
        map.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true
        
        //Ajout du centre
        map.centerCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinatesCannes[0]),longitude: CLLocationDegrees(coordinatesCannes[1]));
        
        //Ajout du zoom sur Cannes
        let latDelta:CLLocationDegrees = 0.05
        let lonDelta:CLLocationDegrees = 0.05
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(
            CLLocationDegrees(coordinatesCannes[0]),
            CLLocationDegrees(coordinatesCannes[1])
        )
        
        let region = MKCoordinateRegionMake(location, span);
        map.setRegion(region, animated: false)

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

            //On récupère les coordonnées
            let longitude = CLLocationDegrees(pois.Longitude)
            let latitude  = CLLocationDegrees(pois.Latitude)
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude);

            //On y rajoute les coordonnées
            poi.coordinate = coordinate

            //On récupère l'adresse de l'emplacement
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
                let address = getAddress(placemark: (placemarks?[0])!)
                
                //On rajoute l'adresse du pin
                poi.subtitle = address;
            })
            
            //On rajoute le nom du pin
            poi.title = pois.Name;
            
            let pinAnnotationView = MKPinAnnotationView(annotation: poi, reuseIdentifier: String(pois.Id))
            
            map.addAnnotation(pinAnnotationView.annotation!)
        }
        
        self.view.addSubview(map);
    }
    
    //Fonction pour afficher le MKAnnotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.hash))
        
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.tag = annotation.hash
        
        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.rightCalloutAccessoryView = rightButton
        
        return pinView
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
