//
//  SwitchToBusinessModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 28/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class SwitchToBusinessModel {
    
    var businessName: String?
    var businessAddress: String?
    var businessEmail: [String:Any]?
    var businessPhone: [String:Any]?
    
    var switchToBusinessModel: SwitchToBusinessModel?
    
    init(modelData: [String: Any]){
        if let businessName = modelData["BusinessName"] as? String{
            self.businessName = businessName
        }
        if let businessAddress = modelData["address"] as? String{
            self.businessAddress = businessAddress
        }
        if let businessEmail = modelData["email"] as? [String:Any] {
            self.businessEmail = businessEmail
        }
        if let businessPhone = modelData["phone"] as? [String:Any] {
            self.businessPhone = businessPhone
        }
    }
}













