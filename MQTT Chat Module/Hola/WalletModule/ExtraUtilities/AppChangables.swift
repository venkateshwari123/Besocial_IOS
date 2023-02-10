//
//  AppChangables.swift
//  Yelo
//
//  Created by 3Embed on 8/31/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

import Foundation

class AppChangables {
    
    fileprivate static var obj : AppChangables!
    private init(){
    }
    public static func getInstance()-> AppChangables{
        if obj == nil{
            obj = AppChangables()
        }
        return obj
    }
    
    // Base URL
    let appBaseURL = AppConstants.constantURL
 
    
    
    
    let PublicKey            = "zOuWROhWIXGfVAV1qgYIPlLq20f6S65h"
    let AppId                = "157606"
    let CLOUD_NAME           = "a-mil-por-hora-sl"
    let API_KEY              = "514647771579974"
    let uploadPreset         = "xqkdbqea"
    let googleKey            = "AIzaSyAflgLXDQTx3iMRWHDUkhhkP5U1sYKqhlI"
    static let stripeKey : String = {
        guard let stripeKey = Bundle.main.object(forInfoDictionaryKey: "Stripe_Key") as? String else {
            fatalError("Missing key")
        }
        return stripeKey
    }()
//    let googleKey            = "AIzaSyDqg9xqC7sYb02vO-txgUh_dr6x8sd9peE"
    
}
