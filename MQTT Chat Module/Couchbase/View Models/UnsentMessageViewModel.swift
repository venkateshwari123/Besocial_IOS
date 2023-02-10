//
//  UnsentMessageViewModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 30/08/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

class UnsentMessageViewModel: NSObject {
    
    public let couchbase: Couchbase
    
    init(couchbase: Couchbase) {
        self.couchbase = couchbase
    }
    
    func deleteMsgFromUnsentDocAfterSending(withMsgID msgID : UInt16, withunsentDocID unsentDocID : String) {
        guard let unsentMessagesDocumentData = self.couchbase.getData(fromDocID: unsentDocID) else { return }
        guard let unsentMessagesArray = unsentMessagesDocumentData["unsentMessagesArray"] as? [Any] else {return }
        var unsentMessages = unsentMessagesArray
        for (index, unsentMessage) in unsentMessagesArray.enumerated() {
            if let unsentMsgObj = unsentMessage as? [String : Any] {
                if let messageID = unsentMsgObj["messageID"] as? UInt16 {
                    if msgID == messageID {
                        unsentMessages.remove(at: index)
                        break
                    }
                }
            }
        }
        var unsentMsgsModifiedData = unsentMessagesDocumentData
        unsentMsgsModifiedData["unsentMessagesArray"] = unsentMessages
        self.couchbase.updateData(data: unsentMsgsModifiedData, toDocID: unsentDocID)
    }
    
    /// This method will create the unsent document for storing unread messages.
    ///
    /// - Returns: Doc ID for the current message Document.
    func createUnsentMessagesDocumentID() -> String? {
        let documentID = self.couchbase.createDocument(withProperties: ["unsentMessagesArray":[]])
        return documentID
    }
}
