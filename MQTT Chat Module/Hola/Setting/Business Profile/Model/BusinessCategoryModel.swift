//
//  BusinessCategoryModle.swift
//  Starchat
//
//  Created by Rahul Sharma on 27/05/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
class BusinessCategoryModel: NSObject {
    
    //MARK:- Variables&Declarations
    var businessCategoryId:String?
    var businessCategorieType:String?
    
    
    /// BusinessCategory Model Data
    ///
    /// - Parameter modelData: Array Of Dictionary
    init(modelData: [String : Any]){
        if let businessCategoryId = modelData["_id"] as? String{
            self.businessCategoryId = businessCategoryId
        }
        if let businessCategorieType = modelData["type"] as? String{
            self.businessCategorieType = businessCategorieType
        }
        
    }
}
