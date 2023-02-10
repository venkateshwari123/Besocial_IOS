//
//  UserProfile.swift
//  Starchat
//
//  Created by 3Embed on 14/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class UserProfile: NSObject {
    
    var lastName : String = ""
    var userName : String = ""
    var isPrivate : Int = 0
    var friendStatusCode : Int = 0
    
    var invite : Int = 0
    var firstName : String = ""
    var number : String = ""
    var friendStatusText : String = ""
    var userId : String = ""
    var followStatus : Int = 0
    var profileVideoThumbnail : String = ""
    var localNumber : String = ""
    var profilePic : String = ""
    var isStar : Bool = false
    var profileVideo : String = ""
    var timestamp : Double = 0
    var socialStatus : Int = 0
    var fullNameWithSpace:String?
    
    init(modelData: [String : Any]){
        print("\(modelData["firstName"] ?? "") - \(modelData["friendStatusCode"] as? Int ?? 155)")
        if let lastName = modelData["lastName"] as? String{
            self.lastName = lastName
        }
        if let userName = modelData["userName"] as? String{
            self.userName = userName
        }
        if let isprivate = modelData["private"] as? Int{
            self.isPrivate = isprivate
        }
        if let invite = modelData["isInvite"] as? Int {
            self.invite = invite
        }
        if let friendStatusCode = modelData["friendStatusCode"] as? Int{
            self.friendStatusCode = friendStatusCode
        }
        if let firstName = modelData["firstName"] as? String{
            self.firstName = firstName
            self.fullNameWithSpace = self.firstName + " " + self.lastName
        }
        if let number = modelData["number"] as? String{
            self.number = number
        }
        if let friendStatusText = modelData["friendStatusText"] as? String{
            self.friendStatusText = friendStatusText
        }
        if let id = modelData["_id"] as? String{
            self.userId = id
        }
        if let followStatus = modelData["followStatus"] as? Int{
            self.followStatus = followStatus
        }
        if let profileVideoThumbnail = modelData["profileVideoThumbnail"] as? String{
            self.profileVideoThumbnail = profileVideoThumbnail
        }
        if let localNumber = modelData["localNumber"] as? String{
            self.localNumber = localNumber
        }
        if let profilePic = modelData["profilePic"] as? String{
            self.profilePic = profilePic
        }
        if let isStar = modelData["isStar"] as? Bool{
            self.isStar = isStar
        }
        if let profileVideo = modelData["profileVideo"] as? String{
            self.profileVideo = profileVideo
        }
        if let timestamp = modelData["timestamp"] as? Double{
            self.timestamp = timestamp
        }
        if let socialStatus = modelData["socialStatus"] as? Int{
            self.socialStatus = socialStatus
        }
    }
}
