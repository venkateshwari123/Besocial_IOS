//
//  CategoryModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 07/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

struct CategoryModel {

  
    var categoryId: String?
    var backgroundImage: String?
    var categoryActiveIconUrl: String?
    var categoryInactiveIconUrl: String?
    var categoryName: String?
    var categoryStatus: Int = 0
    var categoryStatusText: String?
    var createdOn: Double?
    var sequenceId: Int?

    
    init(modelData: [String : Any]){
        
        if let id = modelData["_id"] as? String{
            self.categoryId = id
        }
        if let image = modelData["backgroundImage"] as? String{
            self.backgroundImage = image
        }
        if let url = modelData["categoryActiveIconUrl"] as? String{
            self.categoryActiveIconUrl = url
        }
        if let url = modelData["categoryInactiveIconUrl"] as? String{
            self.categoryInactiveIconUrl = url
        }
        if let name = modelData["categoryName"] as? String{
            self.categoryName = name
        }
        if let status = modelData["categoryStatus"] as? Int{
            self.categoryStatus = status
        }
        if let statusText = modelData["categoryStatusText"] as? String{
            self.categoryStatusText = statusText
        }
        if let on = modelData["createdOn"] as? Double{
            self.createdOn = on
        }
        if let id = modelData["sequenceId"] as? Int{
            self.sequenceId = id
        }
    }
}
