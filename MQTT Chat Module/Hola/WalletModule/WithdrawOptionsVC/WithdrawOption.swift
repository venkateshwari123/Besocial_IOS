//
//  WithdrawOption.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 28/05/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
class WithdrawOption{
    var id = ""
    var pgName = ""
    var imageUrl = ""
    var countryCode = ""
    var payoutAvailable = false
    var _id = ""
    
    init(data: [String: Any]){
        if let id = data["pgId"] as? String{
            self.id = id
        }
        
        if let _id = data["_id"] as? String{
            self._id = _id
        }
        
        if let countryCode = data["countryCode"] as? String{
            self.countryCode = countryCode
        }
        
        
        if let name = data["pgName"] as? String{
            self.pgName = name
        }
        
        if let imageUrl = data["pgIcon"] as? String{
            self.imageUrl = imageUrl
        }
        
        if let payoutAvailable = data["payoutAvailable"] as? Bool {
            self.payoutAvailable = payoutAvailable
        }
    }
    
}

class WithdrawAmountDetails{

    
    var appCommission = 0
    var withdrawChargeInPer = ""
    var withdrawAmount = 0.0
    var totalAmount = 0.0
    
    init(data: [String: Any]){
        if let appCommision = data["appCommission"] as? Int {
            self.appCommission = appCommision
        }
        if let withdrawChargeInPer = data["withdrawChargeInPer"] as? String {
            self.withdrawChargeInPer = withdrawChargeInPer
        }
        if let withdrawAmount = data["withdrawAmount"] as? Int {
            self.withdrawAmount = Double(withdrawAmount)
        }
        
        if let withdrawAmount = data["withdrawAmount"] as? Double {
            self.withdrawAmount = withdrawAmount
        }
        
        if let totalAmount = data["totalAmount"] as? Int {
            self.totalAmount = Double(totalAmount)
        }
        
        if let totalAmount = data["totalAmount"] as? Double{
            self.totalAmount = totalAmount
        }
    }
    
}
