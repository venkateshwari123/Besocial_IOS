//
//  GiftModel.swift
//  Live
//
//  Created by Vengababu Maparthi on 07/02/19.
//  Copyright © 2019 io.ltebean. All rights reserved.
//

import Foundation


class GiftEvent: NSObject {
    
    var senderId: String
    
    var giftId: String
    
    var giftCount: Int
    
    var name:String
    
    var image:String
    
    var userImage:String?
    
    var coins:String = ""
    
    var userName:String?
    
    init(dict: [String: Any]) {
        senderId = dict["streamID"] as! String
        giftId = dict["id"] as! String
        giftCount = 0
        name = dict["name"] as! String
        image = dict["image"] as! String
        if let userImage = dict["userImage"] as? String {
            self.userImage = userImage
        }
        
        if let userImage = dict["userImage"] as? String {
            self.userImage = userImage
        }
        
        if let coin = dict["coin"] as? String {
            self.coins = coin
        }
        
        if let coin = dict["coin"] as? Double {
            self.coins = "\(coin)"
        }
        
        if let userName = dict["userName"] as? String {
            self.userName = userName
        }
    }
    
    func shouldComboWith(_ event: GiftEvent) -> Bool {
        return senderId == event.senderId && giftId == event.giftId
    }
    
}


