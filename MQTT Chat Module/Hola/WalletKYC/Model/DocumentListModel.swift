//
//  DocumentListModel.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/25/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import Foundation

struct DocumentListModel {
    
    var data: [String]?
    
    init(modelData : [String:Any]) {
        
        if let data = modelData["data"] as? [String] {
             self.data = [String]()
            for index in data {
               self.data?.append(index)
            }
        }
    }
}
