//
//  Login.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 24/08/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

class Login: NSObject {
    
    /// Name of the user
    var name: String?
    
    /// ID for the user provided by the API
    var iD : String?
    
    /// Current User Image url
    var userImageURL : String?
    
    /// Used for initializing the Login object with provided data
    ///
    /// - Parameters:
    ///   - name: user name
    ///   - iD: user ID
    ///   - userImageURL: contains user image in a string format.
    init(name : String?, iD : String?, userImageURL : String?) {
        self.name = name
        self.iD = iD
        self.userImageURL = userImageURL
    }
}
