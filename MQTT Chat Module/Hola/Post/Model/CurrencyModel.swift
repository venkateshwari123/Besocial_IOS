//
//  CurrencyModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class CurrencyModel: NSObject {
    
    var currencyName: String?
    var currencySymbol: String?
        
    init(modelData: [String : Any]){
    
        if let currencyName = modelData["currency"] as? String{
            self.currencyName = currencyName
        }
        
        if let currencySymbol = modelData["symbol"] as? String{
            self.currencySymbol = currencySymbol
        }
    }
        

}


