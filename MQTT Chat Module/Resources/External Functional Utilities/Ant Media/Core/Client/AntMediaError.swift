//
//  AntMediaError.swift
//  AntMediaSDK
//
//  Created by Oğulcan on 18.06.2018.
//  Copyright © 2018 AntMedia. All rights reserved.
//

import Foundation

class AntMediaError {
    
    static func localized(_ message: String) -> String {
        switch message {
            case "no_stream_exist":
                return "This live stream has ended."
            case "unauthorized_access":
                return "Unauthorized access: Check your token"
            default:
                return "An error occured, please try again"
        }
    }
    
}
