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
    
    //Déclarations
    var poi = Poi()
    
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
        
        
    }
    
    @IBAction func share(_ sender: UIButton) {

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageFromURL = getImageFromURL(url: poi.Image);
        
        //On mets à jour les informations
        image.image = imageFromURL
        
        self.title = poi.Name;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//Fonction permettant de récupérer une image via une URL
func getImageFromURL(url: String) -> UIImage {
    
    let image = UIImageView();
    
    if let data = try? Data(contentsOf: NSURL(string: url) as! URL) {
        image.alpha = 0
        
        UIView.transition(with: image, duration: 0.5, options: UIViewAnimationOptions(), animations: { () -> Void in
            image.image = UIImage(data: data)
            image.alpha = 1
        }, completion: { (ended) -> Void in
            
        })
    }
    
    return image.image!
}
