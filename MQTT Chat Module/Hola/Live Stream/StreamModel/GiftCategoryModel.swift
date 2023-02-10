//
//  GiftCategoryModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 08/03/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
class GiftCategoryModel: NSObject {
    var categoryId: String?
    var backgroundImage: String?
    var categoryActiveIconUrl: String?
    var categoryInactiveIconUrl: String?
    var categoryName: String?
    var categoryStatus: Int = 0
    var categoryStatusText: String?
    var createdOn: String?
    var sequenceId: Int?
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.categoryId = id
        }
        
        if let id = modelData["categoryId"] as? String{
            self.categoryId = id
        }
        
        if let image = modelData["backgroundImage"] as? String{
            self.backgroundImage = image
        }
        if let url = modelData["mobileThumbnail"] as? String{
            self.categoryActiveIconUrl = url
        }
        if let url = modelData["categoryInactiveIconUrl"] as? String{
            self.categoryInactiveIconUrl = url
        }
        if let name = modelData["categoryTitle"] as? String{
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
        if let id = modelData["sequenceId"] as? Int{
            self.sequenceId = id
        }
    }
    
    init(socialModel: SocialModel){
        self.categoryId = socialModel.categoryId
        self.categoryName = socialModel.categoryName
    }
}
