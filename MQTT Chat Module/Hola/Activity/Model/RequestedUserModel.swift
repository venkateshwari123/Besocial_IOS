//
//  RequestedUserModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 12/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class RequestedUserModel: NSObject {

    
    //    "_id" = 5b4dbe3d8dde25190edec674;
    //    countryCode = "+91";
    //    number = "+919712675218";
    //    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535613765/profile/hadgtfq6oagimfemf7d1.jpg";
    //    requestedTimestamp = 1536735083108;
    //    userName = jaddu;

    var requestId: String?
    var countryCode: String?
    var number: String?
    var profilePic: String?
    var requestedTimeStamp: Double = 0
    var userName: String?
    
    init(modelData: [String : Any]){
        
        if let id = modelData["_id"] as? String{
            self.requestId  = id
        }
        if let code = modelData["countryCode"] as? String{
            self.countryCode = code
        }
        if let num = modelData["number"] as? String{
            self.number = num
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let timeStamp = modelData["requestedTimestamp"] as? Double{
            self.requestedTimeStamp = timeStamp
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
        
    }
}
