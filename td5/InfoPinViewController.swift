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
    
    @IBAction func openMap(_ sender: UIButton) {
        
        //On ouvre la map
        openMapForPlace(
            latitude: CLLocationDegrees(poi.Latitude),
            longitude: CLLocationDegrees(poi.Longitude),
            name: poi.Name
        );
    }
    
    @IBAction func share(_ sender: UIButton) {
        let text = poi.Name;
        let image: UIImage = getImageFromURL(url: poi.Image);
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [(image), text], applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let imageFromURL = getImageFromURL(url: poi.Image);
        
        //On mets à jour les informations
        image.image = imageFromURL
        
        self.title = poi.Name;
        
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true
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


