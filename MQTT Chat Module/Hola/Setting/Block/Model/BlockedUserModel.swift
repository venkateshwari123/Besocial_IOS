//
//  BlockedUserModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 19/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//  AUthor:- Jayaram G
import UIKit
class BlockedUserModel: NSObject {
    
    //    "_id" = 5b953d6602b46d7a399c3cd0;
    //    countryCode = "+91";
    //    email = "";
    //    firstName = Vaibhav;
    //    lastName = "<null>";
    //    number = "+918586027443";
    //    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536507527/ozrelvwdydd5vliqd2ua.jpg";
    //    status = "Hey! I am using PicoAdda";
    //    userName = vaibhav;
    
    
    //MARK:- Variables&Declarations
    var userId: String?             // Used to Store the User ID
    var countryCode: String?        // Used to Store the CountryCode
    var email: String?              // Used to store the email
    var firstName: String?          // Used to store the first Name
    var lastName: String?           // Used to store the Last Name
    var nummber: String?            // Used to store the number
    var profilePic: String?         // Used to store the profile Pic Url
    var status: String?             // Used to store the Status
    var userName: String?           // Used to store the user name
    
    
    /// initialising BlockedUserModel Data
    ///
    /// - Parameter modelData: modelData Array of Dictionaries
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.userId = id
        }
        if let code = modelData["countryCode"] as? String{
            self.countryCode = code
        }
        if let id = modelData["email"] as? String{
            self.email = id
        }
        if let first = modelData["firstName"] as? String{
            self.firstName = first
        }
        if let last = modelData["lastName"] as? String{
            self.lastName = last
        }
        if let num = modelData["number"] as? String{
            self.nummber = num
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let status = modelData["status"] as? String{
            self.status = status
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
    }
}
