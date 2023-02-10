//
//  CoinsAmountListModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 06/11/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation
class CoinsAmountListModel: NSObject {
    
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
