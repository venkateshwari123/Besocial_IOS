//
//  PopularUserModel.swift
//  Do Chat
//
//  Created by Rahul Sharma on 22/02/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
class PopularUserModel: NSObject {
   
    var lastName : String = ""
    var userName : String = ""
    var firstName : String = ""
    var number : String = ""
    var status : String = ""
    var userId : String = ""
    var id : String = ""
    var profileCoverImage : String = ""
    var profilePic : String = ""
    var score : String = ""
    var countryCode : String = ""
    var countryName : String = ""
    var email : String = ""
//    var isFollowed: Int = 0
    var isPrivate: Int = 0
    var followStatus:Int = 0
    var fullName: String?
    
    init(modelData: [String : Any]){
        print("\(modelData["firstName"] ?? "") - \(modelData["friendStatusCode"] as? Int ?? 155)")
        if let lastName = modelData["lastName"] as? String{
            self.lastName = lastName
        }
        if let userName = modelData["userName"] as? String{
            self.userName = userName
        }
        
        if let isFollowed = modelData["followStatus"] as? Int{
            self.followStatus = isFollowed
        }
        
        if let firstName = modelData["firstName"] as? String{
            self.firstName = firstName
            self.fullName = firstName + " " + self.lastName ?? ""
        }
        if let number = modelData["number"] as? String{
            self.number = number
        }
        
        if let status = modelData["status"] as? String{
            self.status = status
        }
        if let id = modelData["_id"] as? String{
            self.userId = id
        }
       
        if let profileCoverImage = modelData["profileCoverImage"] as? String{
            self.profileCoverImage = profileCoverImage
        }
        
        if let profilePic = modelData["profilePic"] as? String{
            self.profilePic = profilePic
        }
        
        if let score = modelData["score"] as? String{
            self.score = score
        }
        if let countryCode = modelData["countryCode"] as? String{
            self.countryCode = countryCode
        }
        if let countryName = modelData["countryName"] as? String{
            self.countryName = countryName
        }
        if let email = modelData["email"] as? [String:Any]{
            guard let emailId = email["id"]  as? String else {return}
            self.email = emailId
        }
        
        if let isPrivate = modelData["isPrivate"] as? [String:Any]{
                   guard let privateUser = isPrivate["isPrivate"]  as? Int else {return}
                   self.isPrivate = privateUser
               }
    }
}
