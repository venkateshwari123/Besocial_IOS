//
//  MessageDeliveryStatus.swift
//  Infra.Market Messenger
//
//  Created by 3Embed Software Tech Pvt Ltd on 30/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation

//deliveredAt = 1556634185602;
//memberId = 5ca7030d09f7bf724431b03a;
//memberIdentifier = "+919620826142";
//profilePic = "--";
//readAt = 1556634184813;

struct MessageDeliveryStatus {
    var memberId: String = ""
    var memberIdentifier: String = ""
    var profilePic: String = ""
    var deliveredAt: Double?
    var readAt: Double?
    
    init(modelData: [String : Any]){
        if let id = modelData["memberId"] as? String{
            self.memberId = id
        }
        if let identifier = modelData["memberIdentifier"] as? String{
            self.memberIdentifier = identifier
        }
        if let pic = modelData["profilePic"] as? String, pic != "--"{
            self.profilePic = pic
        }
        if let read = modelData["readAt"] as? Double{
            self.readAt = read
        }
        if let delivered = modelData["deliveredAt"] as? Double{
            self.deliveredAt = delivered
        }
    }
}
