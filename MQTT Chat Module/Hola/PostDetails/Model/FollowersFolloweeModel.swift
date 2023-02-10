//
//  FollowersFolloweeModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 26/11/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class FollowersFolloweeModel: NSObject {

//    "_id": "5bfbcfbe476e03222b421a39",
//    "number": "+919191919191",
//    "countryCode": "+91",
//    "userStatus": 1,
//    "profilePic": "http://res.cloudinary.com/dqodmo1yc/image/upload/v1543229544/profile/wzoueih2ot7jny1bk1yq.jpg",
//    "firstName": "Sienna",
//    "status": "Hey! I am using PicoAdda",
//    "lastName": "tylor",
//    "userName": "sienna"
    var id: String = ""
    var number: String?
    var countryCode: String?
    var userStatus: Int = 0
    var profilePic: String?
    var firstName: String = ""
    var lastName: String = ""
    var status: String?
    var userName: String?
    var isStar:Int = 0
    var messageStatus: Int = 0
    var fullName: String = ""
    var isChatEnable: Int = 1
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.id = id
        }
        
        if let isChatEnable = modelData["isChatEnable"] as? Int{
            self.isChatEnable = isChatEnable
        }
        
        if let num = modelData["number"] as? String{
            self.number = num
        }
        if let isStar = modelData["isStar"] as? Int{
            self.isStar = isStar
        }
        
        if let code = modelData["countryCode"] as? String{
            self.countryCode = code
        }
        if let status = modelData["userStatus"] as? Int{
            self.userStatus = status
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let name = modelData["firstName"] as? String{
            self.firstName = name
        }
        if let name = modelData["lastName"] as? String{
            self.lastName = name
        }
        if let status = modelData["status"] as? String{
            self.status = status
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
        if let name = modelData["lastName"] as? String{
            self.lastName = name
            self.fullName = self.firstName ?? "" + " " + name
        }
    }
}
