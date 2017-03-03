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

public class Poi {
    var Id : Int = 0;
    var Name : String = "";
    var Image : String = "";
    var Latitude : Float = 0.0;
    var Longitude : Float = 0.0;
    var Phone: String = "";
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //Création de la map
    var map = MKMapView();
    
    //Liste des pins
    var poisList = [Poi]()
    var poisListString = [String]()
    
    //Préparation à la localisation
    let locationManager = CLLocationManager();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
       
        self.title = "Affichage des marqueurs";
        
        map.delegate = self
        
        //Coordonnées de Cannes
        let coordinatesCannes: [Float] = [
            43.551534,
            7.016659
        ];

        //Gestion de la map
        map.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

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
        
        if let url = URL(string: "http://dam.lanoosphere.com/poi.xml") {
            
            if let data = try? Data(contentsOf: url) {
                
                let xml = SWXMLHash.parse(data)
                
                for pois in xml["Data"]["POI"].all {

                    let poi = Poi();
                    
                    poi.Id = Int((pois.element?.allAttributes["id"]?.text)!)!
                    poi.Name = (pois.element?.allAttributes["name"]?.text)!
                    poi.Image = (pois.element?.allAttributes["image"]?.text)!
                    poi.Latitude = Float((pois.element?.allAttributes["latitude"]?.text)!)!
                    poi.Longitude = Float((pois.element?.allAttributes["longitude"]?.text)!)!
                    poi.Phone = (pois.element?.allAttributes["phone"]?.text)!
                    
                    poisList.append(poi);
                    poisListString.append(poi.Name);
                }
            }
        }

        //Parcourt des pins
        for pois in poisList {

            let poi = MKPointAnnotation()

            //On récupère les coordonnées
            let longitude = CLLocationDegrees(pois.Longitude)
            let latitude  = CLLocationDegrees(pois.Latitude)
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude);

            poi.coordinate = coordinate

            //On récupère l'adresse de l'emplacement
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
                let address = getAddress(placemark: (placemarks?[0])!)
                poi.subtitle = address;
            })
            
            poi.title = pois.Name

            let pinAnnotationView = MKPinAnnotationView(annotation: poi, reuseIdentifier: pois.Name)
            
            map.addAnnotation(pinAnnotationView.annotation!)
        }
        
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true

        self.view.addSubview(map);
    }

    //Fonction pour afficher le MKAnnotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(50))
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.tag = annotation.hash
        
        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.rightCalloutAccessoryView = rightButton
        
        return pinView
    }
    
    //Fonction pour détecter le bouton (i)
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        //On se base sur la vue d'exemple
        let InfoPinViewController = self.storyboard?.instantiateViewController(withIdentifier: "InfoPin") as! InfoPinViewController;
        
        //On récupère le poi
        let poi = getPin(title: (view.annotation?.title!)!)
        
        //Si le poi n'est pas vide
        if(poi.Name != "") {
            
            //On envoie le poi à la vue
            InfoPinViewController.poi = poi
            
            //On push la vue
            self.navigationController?.pushViewController(InfoPinViewController, animated: true)
        }
    }
    
    //Fonction permettant de récupérer un poi en fonction de son nom
    func getPin(title: String) -> Poi {
        
        var poi = Poi()
        
        //On regarde si le pin existe
        if(poisListString.contains(title)) {
        
            //On récupère l'indice du poi dans le tableau de string
            let indicePoi = (poisListString.index(of: title)!)
            
            //On récupère le poi
            poi = poisList[indicePoi]
    
        } else {
            print("Poi inexistant");
        }
        
        return poi
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
