
//
//  QrCodeModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 21/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
class QrCodeModel: NSObject {
    
    /// Variables&Declarations
    var qrCodeString:String?
    var message:String?
    
    
    /// Get QrCodeModel Data
    ///
    /// - Parameter modelData: Array Of Dictionary
    init(modelData: [String : Any]){
        if let data = modelData["data"] as? String{
            self.qrCodeString = data
        }
        if let message = modelData["message"] as? String{
            self.message = message
        }
        
    }
}
