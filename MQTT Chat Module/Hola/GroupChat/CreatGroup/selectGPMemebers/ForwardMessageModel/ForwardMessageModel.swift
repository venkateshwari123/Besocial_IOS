//
//  ForwardMessageModel.swift
//  Infra.Market Messenger
//
//  Created by 3Embed Software Tech Pvt Ltd on 16/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import MobileCoreServices


class ForwardMessageModel: NSObject {
    
    let couchbase: Couchbase
    
    init(couchbase: Couchbase) {
        self.couchbase = couchbase
    }
    
    func getImageMessageObject(message: [String : Any], senderId: String, receiverId: String, chatDocId: String) -> [String : Any]?{
        
        let userDocVMObject = UsersDocumentViewModel(couchbase: self.couchbase)
        guard let userData = userDocVMObject.getUserData() else { return nil}
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        var msgData = message
        msgData["to"] = receiverId
        msgData["from"] = senderId
        msgData["timestamp"] = "\(timeStamp)"
        msgData["id"] = "\(timeStamp)"
        msgData["userImage"] = userData["userImageUrl"]!
        msgData["name"] = userData["userName"]!
        msgData["receiverIdentifier"] = userData["receiverIdentifier"]!
        return msgData
    }
    
}
