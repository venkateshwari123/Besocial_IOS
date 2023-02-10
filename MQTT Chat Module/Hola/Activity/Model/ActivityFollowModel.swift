//
//  ActivityFollowModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ActivityFollowModel: NSObject {

//    "_id" = 5b966348794e318065070b3b;
//    message = "started following";
//    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535351035/profile/wfnchm1dmkmy6uqnajth.jpg";
//    targetId = 5b960a7a09d87a6d230d4ea3;
//    targetProfilePic = "https://res.cloudinary.com/dqodmo1yc/image/upload/c_thumb,w_200,g_face/v1536126847/default/profile_one.png";
//    targetUserName = luna;
//    timeStamp = 1536582472302;
//    type = 3;
//    userId = 5b8398640052cf34322c0ad3;
//    userName = appscrip;
    
//    "am_I_Following" = 1;
    
    var activityId: String?
    var message: String = ""
    var profilePic: String?
    var targetId: String?
    var targetProfilePic: String?
    var targetUserName: String = ""
    var timeStamp: Double = 0.0
    var type: Int?
    var userId: String?
    var userName: String = ""
    var amIFollowing: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.activityId = id
        }
        if let message = modelData["message"] as? String{
            self.message = message
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let id = modelData["targetId"] as? String{
            self.targetId = id
        }
        if let pic = modelData["targetProfilePic"] as? String{
            self.targetProfilePic = pic
        }
        if let name = modelData["targetUserName"] as? String{
            self.targetUserName = name
        }
        if let time = modelData["timeStamp"] as? Double{
            self.timeStamp = time
        }
        if let type = modelData["type"] as? Int{
            self.type = type
        }
        if let id = modelData["userId"] as? String{
            self.userId = id
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
        if let follow = modelData["am_I_Following"] as? Int{
            self.amIFollowing = follow
        }
        if let fname = modelData["firstName"] as? String{
            self.firstName = fname
        }
        
        if let lname = modelData["lastName"] as? String{
            self.lastName = lname
        }
    }
    
}
