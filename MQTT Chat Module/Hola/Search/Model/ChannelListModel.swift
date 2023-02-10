//
//  ChannelListModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 04/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ChannelListModel: NSObject {
//    "_id" = 5b62a3ef47519c3a89ce5c17;
//    categoryId = 5b16b62175c23ef87fce8212;
//    channelImageUrl = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1533191150/wpzi5cn70d0ias9izslw.jpg";
//    channelName = biker;
//    private = 0;
//    subscribeStatus = 1;
//    subscriber = 7;
//    userId = 5b629eeb6249a23a88154db4;
    var channelId: String?
    var categoryId: String?
    var channelImageUrl: String?
    var channelName: String?
    var privicy: Int = 0
    var subscribeStatus: Int = 0
    var subscriber: Int = 0
    var userId: String?
    
    init(modelData: [String: Any]){
        
        if let id = modelData["_id"] as? String{
            self.channelId = id
        }
        if let id = modelData["categoryId"] as? String{
            self.categoryId = id
        }
        if let url = modelData["channelImageUrl"] as? String{
            self.channelImageUrl = url
        }
        if let name = modelData["channelName"] as? String{
            self.channelName = name
        }
        if let priv = modelData["private"] as? Int{
            self.privicy = priv
        }
        if let status = modelData["subscribeStatus"] as? Int{
            self.subscribeStatus = status
        }
        if let subscriber = modelData["subscriber"] as? Int{
            self.subscriber = subscriber
        }
        if let id = modelData["userId"] as? String{
            self.userId = id
        }
    }
}
