//
//  BusinessButtonModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 19/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation

struct BusinessButtonModel {
    var buttonColor: String
    var buttonText: String
    
    init(modelData: [String : Any]){
        var butColor: String = ""
        var butText: String = ""
        if let color = modelData["buttonColor"] as? String{
            butColor = color
        }
        if let text = modelData["buttonText"] as? String{
            butText = text
        }
        self.buttonColor = butColor
        self.buttonText = butText
    }
}
