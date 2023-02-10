//
//  GiftsModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 08/03/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
class GiftsModel: NSObject {
    
    var giftId: String?
    var categoryId:String?
    var categoryName: String?
    var categoryStatus: Int = 0
    var categoryStatusText: String?
    var gifIcon:String?
    var gif:String?
    var giftTitle:String?
    var createdOn: String?
    var giftCost: Double?
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.giftId = id
        }
        
        
        if let gifCost = modelData["giftCost"] as? Double{
            self.giftCost = gifCost
        }
        
        if let gifTitle = modelData["giftTitle"] as? String{
            self.giftTitle = gifTitle
        }
        
        if let id = modelData["categoryId"] as? String{
            self.categoryId = id
        }
       
        if var url = modelData["mobileThumbnail"] as? String{
            url = url.replace(target: "upload/", withString: "upload/q_50/")
            self.gifIcon = url
        }
        if var gifUrl = modelData["gifUrl"] as? String{
            gifUrl = gifUrl.replace(target: "upload/", withString: "upload/fl_lossy,q_-2000/")
            self.gif = gifUrl
        }
        if let name = modelData["categoryName"] as? String{
            self.categoryName = name
        }
        if let status = modelData["statusCode"] as? Int{
            self.categoryStatus = status
        }
        if let status = modelData["statusText"] as? String{
            self.categoryStatusText = status
        }
        if let created = modelData["createdDate"] as? String{
            self.createdOn = created
        }
    }
}
