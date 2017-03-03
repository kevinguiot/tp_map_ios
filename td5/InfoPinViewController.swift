//
//  InfoPinViewController.swift
//  td5
//
//  Created by GUIOT Kevin on 27/02/2017.
//  Copyright © 2017 GUIOT Kevin / RUGOLETTO Romuald. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InfoPinViewController: UIViewController,  CLLocationManagerDelegate, MKMapViewDelegate {
    
    //Déclarations
    var poi = Poi()
    var route : MKRoute!
    
    //On prépare la localisation
    let locationManager = CLLocationManager()

    //Outlets
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var map: MKMapView!
    
    //Actions
    @IBAction func call(_ sender: UIButton) {

        //On créé l'URL d'appel
        let url = NSURL(string: "tel://" + poi.Phone);
        
        //On procède à l'appel
        UIApplication.shared.open(url as! URL, options: [:], completionHandler: nil)
    }
    
    //Fonction pour ouvrir la map
    @IBAction func openMap(_ sender: UIButton) {
        
        //On ouvre la map
        openMapForPlace(
            latitude: CLLocationDegrees(poi.Latitude),
            longitude: CLLocationDegrees(poi.Longitude),
            name: poi.Name
        );
    }
    
    //Fonction pour partager
    @IBAction func share(_ sender: UIButton) {
        let text = poi.Name;
        let image: UIImage = getImageFromURL(url: poi.Image);
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [(image), text], applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Demandes de l'affichage de la position de l'utilisateur
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //On précise la région
        let latDelta:CLLocationDegrees = 0.05
        let lonDelta:CLLocationDegrees = 0.05
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(
            CLLocationDegrees(poi.Latitude),
            CLLocationDegrees(poi.Longitude)
        )
        let region = MKCoordinateRegionMake(location, span);
        map.setRegion(region, animated: false)
        
        //Création des PointAnnotation
        let poiAnnotation = MKPointAnnotation()
        
        //On récupère les coordonnées du pin
        let coordinatePin = CLLocationCoordinate2DMake(CLLocationDegrees(poi.Latitude), CLLocationDegrees(poi.Longitude));
        
        poiAnnotation.coordinate = coordinatePin
        poiAnnotation.title = poi.Name
        map.addAnnotation(poiAnnotation)
        
        //Création des Placemark (si la localisation est affichée
        if(String(describing: locationManager.location?.coordinate.latitude) != "") {
            
            let markPin = MKPlacemark(coordinate: coordinatePin)
            let markPos = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (CLLocationDegrees((locationManager.location?.coordinate.latitude)!)), longitude: CLLocationDegrees((locationManager.location?.coordinate.longitude)!)))

            //On prépare la direction entre la localisation et la position
            let directionsRequest = MKDirectionsRequest()
            
            directionsRequest.source = MKMapItem(placemark: markPin)
            directionsRequest.destination = MKMapItem(placemark: markPos)
            
            directionsRequest.transportType = MKDirectionsTransportType.automobile
            let directions = MKDirections(request: directionsRequest)
            
            directions.calculate(completionHandler: {
                response, error in
                
                if error == nil {
                    self.route = response!.routes[0] as MKRoute
                    self.map.add(self.route.polyline)
                }
            })
            
        }

        //On mets à jour les paramètres de la map
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true
        map.delegate = self
        
        //On mets à jour les informations de la vue
        let imageFromURL = getImageFromURL(url: poi.Image);
        
        image.image = imageFromURL
        
        self.title = poi.Name;
    }
    
    //Fonction pour afficher une route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let myLineRenderer = MKPolylineRenderer(polyline: route.polyline)
        myLineRenderer.strokeColor = UIColor.blue
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Fonction permettant de récupérer une image via une URL
    func getImageFromURL(url: String) -> UIImage {
        
        let image = UIImageView();
        
        if let data = try? Data(contentsOf: NSURL(string: url) as! URL) {
            image.image = UIImage(data: data)
            image.alpha = 1
        }
        
        return image.image!
    }
    
    //Fonction permettant d'ouvrir Plan avec des coordonnées précises
    func openMapForPlace(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String) {
        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        //On précise les options
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
            MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
        ] as [String : Any]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)

        mapItem.name = name;
        mapItem.openInMaps(launchOptions: options)
    }
}


