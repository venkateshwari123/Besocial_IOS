//
//  LocationModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 08/03/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationModel: NSObject {

    var primarytext: String = ""
    var secondaryText: String?
    var placeId: String?
    
    init(modelData: GMSAutocompletePrediction){
        self.primarytext = modelData.attributedPrimaryText.string
        self.secondaryText = modelData.attributedSecondaryText?.string
        self.placeId = modelData.placeID
    }
    
    init(dataBaseData: [String : Any]){
        if let primary = dataBaseData["primarytext"] as? String{
            self.primarytext = primary
        }
        if let secondary = dataBaseData["secondaryText"] as? String{
            self.secondaryText = secondary
        }
        if let id = dataBaseData["placeId"] as? String{
            self.placeId = id
        }
    }
}
