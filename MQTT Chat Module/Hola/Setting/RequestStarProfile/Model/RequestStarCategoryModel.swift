//
//  RequestStarCategoryModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/8/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import Foundation
class RequestStarCategoryModel: NSObject {
    
    //MARK:- Variables&Declarations
    var userId:String?         // Used To Store Used Id
    var categorie:String?      // Used To Store Category Name
    var icon:String?           // Used To Store Icon
    
    
    /// Used To initialize the Star Category Model Data
    ///
    /// - Parameter modelData: modelData array of Dictionary
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.userId = id
        }
        if let category = modelData["categorie"] as? String{
            self.categorie = category
        }
        if let icon = modelData["icon"] as? String{
            self.icon = icon
        }
    }
}
