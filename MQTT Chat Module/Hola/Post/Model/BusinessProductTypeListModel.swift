//
//  BusinessProductTypeListModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 09/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class BusinessProductTypeListModel{
    
    var productTypeId: String?
    var produtTypeName: String?
    
    init(modelData: [String : Any]){
        
        if let productTypeId = modelData["_id"] as? String{
            self.productTypeId = productTypeId
        }
        if let produtTypeName = modelData["text"] as? String{
            self.produtTypeName = produtTypeName
        }
    }
    
    
}
