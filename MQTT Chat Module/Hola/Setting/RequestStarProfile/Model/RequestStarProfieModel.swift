//
//  RequestStarProfieModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/7/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
class RequestStarProfieModel:NSObject {
    
    //MARK:- Variables&Declarations
    var starUserEmail:String?        // Used To Store the Star User Email
    var starUserKnownAs:String?      // Used To Store the Star User Known As
    var starUserPhoneNumber:String?  // Used To Store the Star User Phone Number
    var starUserStatus:String?       // Used To Store the Star User Status
    
    
    /// Used To Initialize the Star Profile Model Data
    ///
    /// - Parameter modelData: modelData Array Of Dictionaries
    init(modelData: [String : Any]){
        if let email = modelData["starUserEmail"] as? String{
            self.starUserEmail = email
        }
        if let starUserKnownBy = modelData["starUserKnownBy"] as? String{
            self.starUserKnownAs = starUserKnownBy
        }
        if let phoneNumber = modelData["starUserPhoneNumber"] as? String{
            self.starUserPhoneNumber = phoneNumber
        }
        if let starUserStatus = modelData["starUserProfileStatusText"] as? String{
            self.starUserStatus = starUserStatus
        }
    }
}
