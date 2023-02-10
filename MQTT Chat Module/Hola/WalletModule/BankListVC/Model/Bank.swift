//
//  Bank.swift
//  Yelo
//
//  Created by Rahul Sharma on 07/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit


class Bank {
    var id = ""
    var account_holder_type = ""
    var last4 = ""
    var country = ""
    var currency = ""
    var fee = ""
    var account = ""
    
    init(data: [String: Any]){
        if let id = data["id"] as? String{
            self.id = id
        }
        
        if let account_holder_type = data["account_holder_type"] as? String{
            self.account_holder_type = account_holder_type
        }
        
        if let last4 = data["last4"] as? String{
            self.last4 = last4
        }
        if let fee = data["fee"] as? String{
            self.fee = fee
        }
        
        if let country = data["country"] as? String{
            self.country = country
        }
        
        if let currency = data["currency"] as? String{
            self.currency = currency
        }
        
        if let account = data["account"] as? String{
            self.account = account
        }
        
    }
}
