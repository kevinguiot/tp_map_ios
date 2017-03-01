//
//  InfoPinViewController.swift
//  td5
//
//  Created by GUIOT Kevin on 27/02/2017.
//  Copyright © 2017 GUIOT Kevin / RUGOLETTO Romuald. All rights reserved.
//

import UIKit

class InfoPinViewController: UIViewController {
    
    var poi = Poi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.title = poi.Name;

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
