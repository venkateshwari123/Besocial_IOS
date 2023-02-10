//
//  ChannelModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 31/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

struct ChannelModel {
    
    var channelId: String?
    var channelName: String?
    var createdOn: Double?
    var privicy: Int = 0
    var sunscriber: Int = 0
    var channeldesc: String?
    var userId: String?
    var isSubscribed: Int = 0
    var channelImageUrl: String?
    var category:CategoryListModel?
    
    init(channelData: [String: Any]){
        if let id = channelData["_id"] as? String{
            self.channelId = id
        }
        if let name = channelData["channelName"] as? String{
            self.channelName = name
        }
        if let created = channelData["createdOn"] as? Double{
            self.createdOn = created
        }
        if let privicy = channelData["private"] as? Int{
            self.privicy = privicy
        }
        if let subscriber = channelData["subscriber"] as? Int{
            self.sunscriber = subscriber
        }
        if let descrip = channelData["description"] as? String{
            self.channeldesc = descrip
        }
        if let userId = channelData["userId"] as? String{
            self.userId = userId
        }
        if let isSubcr = channelData["isSubscribed"] as? Int{
            self.isSubscribed = isSubcr
        }
        if let url = channelData["channelImageUrl"] as? String{
            self.channelImageUrl = url
        }
        
        self.category = CategoryListModel(modelData:channelData)
    }
    
    init(socialModel: SocialModel){

        self.channelId = socialModel.channelId
        self.channelName = socialModel.channelName
        self.channelImageUrl = socialModel.channelImageUrl
        if let catId = socialModel.categoryId, catId != ""{
            self.category = CategoryListModel(socialModel: socialModel)
        }
    }
}

