//
//  PlaceInfoViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 03/06/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class PlaceInfoViewController: UIViewController {
    
    @IBOutlet weak var placeInfoLabel: UILabel!
    
    var placeInfo = "Some where on the earth."
    var place = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeInfoLabel.text = placeInfo
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "About - \(place)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
