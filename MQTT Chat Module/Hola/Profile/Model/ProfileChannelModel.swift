//
//  ProfileChannelModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 22/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ProfileChannelModel: NSObject {

    var id: String?
    var categoryId: String?
    var categoryName: String?
    var categoryUrl: String?
    var channelId: String?
    var channelImageUrl: String?
    var channelName: String?
    var createdOn: Double = 0
    var dataArray = [SocialModel]()
    var desc: String = ""
    var isSubscribed: Int = 0
    var subScriber: Int = 0
    var privicy: Int = 0
    var userId: String?
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.id = id
        }
        if let url = modelData["categoryIconUrl"] as? String{
            self.categoryUrl = url
        }
        if let categoryId = modelData["categoryId"] as? String{
            self.categoryId = categoryId
        }
        if let name = modelData["categoryName"] as? String{
            self.categoryName = name
        }
        if let url = modelData["channelImageUrl"] as? String{
            self.channelImageUrl = url
        }
        if let name = modelData["channelName"] as? String{
            self.channelName = name
        }
        if let creatded = modelData["createdOn"] as? Double{
            self.createdOn = creatded
        }
        if let data = modelData["data"] as? [[String : Any]]{
            for modelData in data{
                let socialData = SocialModel(modelData: modelData)
                self.dataArray.append(socialData)
            }
        }
        if let channelId = modelData["channelId"] as? String{
            self.channelId = channelId
        }
        
        if let channelId = modelData["_id"] as? String{
            self.channelId = channelId
        }
        if let desc = modelData["description"] as? String{
            self.desc = desc
        }
        if let subscribed = modelData["isSubscribed"] as? Int{
            self.isSubscribed = subscribed
        }
        if let subscriber = modelData["subscriber"] as? Int{
            self.subScriber = subscriber
        }
        if let priv = modelData["private"] as? Int{
            self.privicy = priv
        }
        if let id = modelData["userId"] as? String{
            self.userId = id
        }
    }
}
