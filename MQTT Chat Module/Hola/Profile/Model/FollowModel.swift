//
//  FollowModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class FollowModel: NSObject {

//    "_id" = 5b98bc9d794e318065070c04;
//    end = 0;
//    followee = 5b727caedbe34d52327bd138;
//    follower = 5b98bbfd22d534779271c218;
//    private = 0;
//    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536904037/pdrfdjyo0rbd7djxvhzs.jpg";
//    start = 1536736413067;
//    type =     {
//    message = unfollowed;
//    status = 0;
//    };
//    userName = checking;
//    firstName = checkd;
//    lastName = " ";
//    userId = 5c55344a9f67de34ab3e21a9;

    var followId: String?
    var followee: String?
    var follower: String?
    var privicy: Int = 0
    var profilePic: String?
    var status: Int = 0
    var isStar: Int = 0
    var userName: String?
    var firstName: String = ""
    var lastName: String = ""
    var userId: String?
    var subscriberId:String?
    var starRequest:StarProflie?

    
    init(modelData: [String: Any]){
        if let id = modelData["_id"] as? String{
            self.followId = id
        }
        if let subscriberId = modelData["_id"] as? String{
            self.subscriberId = subscriberId
        }
        
        if let followee = modelData["followee"] as? String{
            self.followee = followee
        }
        if let follower = modelData["follower"] as? String{
            self.follower = follower
        }
        if let priv = modelData["private"] as? Int{
            self.privicy = priv
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let starRequest = modelData["starRequest"] as? [String: Any]{
            self.starRequest = StarProflie.init(modelData: starRequest)
        }
        /*bug Name :- star badge for star user in follow view controller
          Fix Date :- 22/03/2021
          Fixed By :- Nikunj C
          Description Of fix :- add isStar key*/
        
        if let isStar = modelData["isStar"] as? Int{
            self.isStar = isStar
        }

        if let type = modelData["type"] as? [String : Any]{
            if let status = type["status"] as? Int{
                self.status = status
            }
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
        if let first = modelData["firstName"] as? String{
            self.firstName = first
        }
        if let last = modelData["lastName"] as? String{
            self.lastName = last
        }
        if let id = modelData["userId"] as? String{
            self.userId = id
        }
    }
}
