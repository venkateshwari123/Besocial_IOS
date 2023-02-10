//
//  BusinessPostModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 10/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
struct BusinessPostModel {
    var businessButtonText:String?
    var businessButtonColor:String?
    var businessCurrency:String?
    var businessPostType:String = ""
    var businessPostTypeName:String?
    var businessPrice:Double?
    var businessUrl:String?
    var businessName:String?
    var businessProfilePic:String?
    var businessProfileCoverImage:String?
    var businessCurrencySymbol:String?

    
    init(modelData: [String : Any]){
        if let businessButtonText = modelData["businessButtonText"] as? String{
            self.businessButtonText = businessButtonText
        }
        if let color = modelData["businessButtonColor"] as? String{
            self.businessButtonColor = color
        }
        if let businessCurrency = modelData["businessCurrency"] as? String{
            self.businessCurrency = businessCurrency
        }
        if let businessPostType = modelData["businessPostType"] as? String{
            self.businessPostType = businessPostType
        }
        if let businessPostTypeName = modelData["businessPostTypeLabel"] as? String{
            self.businessPostTypeName = businessPostTypeName
        }
        /*
         Bug Name:- Show business post with currency symbol
         Fix Date:- 20/05/21
         Fix By  :- Jayaram G
         Description of Fix:- Added business currency symbol
         */
        if let businessCurrencySymbol = modelData["businessCurrencySymbol"] as? String{
            self.businessCurrencySymbol = businessCurrencySymbol
        }
        if let businessPrice = modelData["businessPrice"] as? Double{
            self.businessPrice = businessPrice
        }
        if let businessUrl = modelData["businessUrl"] as? String{
            self.businessUrl = businessUrl
        }
        if let businessName = modelData["businessName"] as? String {
            self.businessName = businessName
        }
        if let businessProfilePic = modelData["businessProfilePic"] as? String {
            self.businessProfilePic = businessProfilePic
        }
        if let businessProfileCoverImage = modelData["businessProfileCoverImage"] as? String {
            self.businessProfileCoverImage = businessProfileCoverImage
        }
    }
    
}
