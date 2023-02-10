//
//  RequestedChannelModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 12/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class RequestedChannelModel: NSObject {

//    (
//    {
//    "_id" = 5b9766396ac8237df1c46220;
//    channelCreatedOn = 1536648761083;
//    channelImageUrl = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536648760/cxbxbleyzj8mqnui0lwu.jpg";
//    channelName = ppd;
//    private = 1;
//    requestedUserList =         (
//    {
//    "_id" = 5b4dbe3d8dde25190edec674;
//    countryCode = "+91";
//    number = "+919712675218";
//    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535613765/profile/hadgtfq6oagimfemf7d1.jpg";
//    requestedTimestamp = 1536735083108;
//    userName = jaddu;
//    }
//    );
//    }
//    )
    
    var requestChannelId: String?
    var channelCreatedOn: Double = 0
    var channelImageUrl: String?
    var channleName: String?
    var privicy: Int = 0
    var requestedUserList = [RequestedUserModel]()
 
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.requestChannelId = id
        }
        if let created = modelData["channelCreatedOn"] as? Double{
            self.channelCreatedOn = created
        }
        if let url = modelData["channelImageUrl"] as? String{
            self.channelImageUrl = url
        }
        if let name = modelData["channelName"] as? String{
            self.channleName = name
        }
        if let privicy = modelData["private"] as? Int{
            self.privicy = privicy
        }
        if let requestList = modelData["requestedUserList"] as? [Any]{
            for request in requestList{
                guard let dict = request as? [String : Any] else {continue}
                let requestUserModel = RequestedUserModel(modelData: dict)
                self.requestedUserList.append(requestUserModel)
            }
        }
    }
    
    
}
