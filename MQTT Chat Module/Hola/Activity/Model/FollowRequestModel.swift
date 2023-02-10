//
//  FollowRequestModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 12/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class FollowRequestModel: NSObject {

//    "_id" = 5b83a24b15a12a5c0492c539;
//    countryCode = "+91";
//    firstName = Shivangi;
//    lastName = Mudgil;
//    number = "+919582429673";
//    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535353456/profile/a39gehg18hpvwndhe9q1.jpg";
//    userName = shongi;
    var followId: String?
    var countryCode: String?
    var firstName: String = ""
    var lastName: String = ""
    var number: String = ""
    var profilePic: String?
    var userName: String?
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.followId = id
        }
        if let code = modelData["countryCode"] as? String{
            self.countryCode = code
        }
        if let first = modelData["firstName"] as? String{
            self.firstName = first
        }
        if let last = modelData["lastName"] as? String{
            self.lastName = last
        }
        if let num = modelData["number"] as? String{
            self.number = num
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
    }
}
