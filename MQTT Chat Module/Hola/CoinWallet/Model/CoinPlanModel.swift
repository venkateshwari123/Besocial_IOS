//
//  CoinPlanModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 19/01/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
class CoinPlanModel: NSObject {
    
    var planCost:Double?
    var appstoreId:String?
    var planid:String?
    var currency:String?
    var currencySymbol:String?
    var desc:String?
    var imgUrl:String?
    var planTitle:String?
    
    override init(){
    }
    
    init(modelData: [String : Any]){
        if let planCost = modelData["planCost"] as? Double {
            self.planCost = planCost
        }
        if let planId = modelData["_id"] as? String {
            self.planid = planId
        }
        if let appstoreId = modelData["appstoreId"] as? String {
            self.appstoreId = appstoreId
        }
        if let currency = modelData["currency"] as? String {
            self.currency = currency
        }
        if let currencySymbol = modelData["currencySymbol"] as? String {
            self.currencySymbol = currencySymbol
        }
        if let desc = modelData["description"] as? String {
            self.desc = desc
        }
        if let img = modelData["image"] as? String {
            self.imgUrl = img
        }
        if let planTitle = modelData["planTitle"] as? String {
            self.planTitle = planTitle
        }
        
        
    }
    
}
