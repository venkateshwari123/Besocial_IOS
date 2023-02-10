//
//  PeopleModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 04/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class PeopleModel: NSObject {
//    "_id" = 5b5f1030bd92f23c0afe579c;
//    firstName = jane;
//    followStatus = 0;
//    lastName = april;
//    private = 0;
//    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1533731897/aalxtuvdjl96h5avkjuu.jpg";
//    registeredOn = 1532956720508;
//    userName = jane;
//    userStatus = 1;
    
    
    
//    "_id" = 5d31772cdf933e7e57b36f9e;
//    firstName = Dips;
//    followStatus = 0;
//    friendStatusCode = 1;
//    friendStatusText = notAFirend;
//    isStar = 0;
//    private = 0;
//    profilePic = "https://s3.eu-central-1.amazonaws.com/citysmartlifebucket/profile_image/5d31772cdf933e7e57b36f9e";
//    registeredOn = 1563522860450;
//    userName = dipss;
    
    var peopleId: String?
    var firstName: String = ""
    var lastName: String = ""
    var followStatus: Int = 0
    var privicy: Int = 0
    var isStar: Int = 0
    var profilePic: String?
    var registredOn: Double?
    var userName: String?
    var userStatus: Int?
    var knownAs: String = ""
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.peopleId = id
        }
        if let first = modelData["firstName"] as? String{
            self.firstName = first
        }
        if let last = modelData["lastName"] as? String{
            self.lastName = last
        }
        if let status = modelData["followStatus"] as? Int{
            self.followStatus = status
        }
        if let priv = modelData["private"] as? Int{
            self.privicy = priv
        }
        if let url = modelData["profilePic"] as? String{
            self.profilePic = url
        }
        if let isStar = modelData["isStar"] as? Int{
            self.isStar = isStar
        }
        if let registred = modelData["registeredOn"] as? Double{
            self.registredOn = registred
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
        if let status = modelData["userStatus"] as? Int{
            self.userStatus = status
        }
        if let starRequest = modelData["starRequest"] as? [String:Any]{
            if let starKnownAs = starRequest["starUserKnownBy"] as? String{
                self.knownAs = starKnownAs
            }
        }
    }
}
