//
//  ChatStatusViewController.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 29/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation

// MARK: MQTT Model Delegate
extension ChatViewController {
    
    func didRecieve(withMessage message: Any, inTopic topic: String) {
        guard let msgServerObj = message as? [String:Any] else { return }
        if let fromID = msgServerObj["from"] as? String {
            if fromID == selfID! {
            } else {
                self.messages = self.getMessagesFromChatDoc(withChatDocID: self.chatDocID)
                self.finishReceivingMessage()
            }
        }
    }
    
    class func updateMessageStatus(withMessageObj messageObj : [String:Any]) {
        guard let docID = messageObj["doc_id"] as? String else { return }
        guard let chatDta = CouchbaseOperations().getData(fromDocID: docID) else { return }
        var chatData = chatDta
        var msgArray = chatData["messageArray"] as! [[String:Any]]
        
        guard let msgIDArray = messageObj["msgIds"] as? [String] else { return }
        guard let index:Int = msgArray.index(where: {$0["id"] as! String == msgIDArray[0]}) else { return }
        
        var msgObj = msgArray[index]
        let status = msgObj["deliveryStatus"] as! String
        msgObj["deliveryStatus"] = messageObj["deliveryStatus"]
        if status == "3" {
            msgObj["deliveryStatus"] = "3"
        }
        msgArray[index] = msgObj
        chatData["messageArray"] = msgArray
        CouchbaseOperations().updateData(data: chatData, toDocID: docID)
    }
    
    class func getMessageObjectForUpdatingStatus(withData data : [String : Any], andStatus status: String) -> Any? {
        guard let fromID = data["from"] as? String, let msgIDs = data["id"] as? String, let docID = data["toDocId"] as? String, let toID = data["to"] as? String  else { return nil }
        let params =
            ["from":fromID, //user ID of the sender
                "msgIds":[msgIDs], //array containing the individual message ids to be acknowladged in string.
                "doc_id":docID, // sender's docID which is recieved in the message
                "to":toID, // userID of the sender for whom the acknowledgement is to be sent.
                "status":status] //2 or 3 for message delivered and read respectively.
                as [String : Any]
        return params as Any
    }
    
    func getMessagesFromChatDoc(withChatDocID chatDocID: String) -> [Message]{
        var messages = [Message]()
        if let docData = CouchbaseOperations().getData(fromDocID: chatDocID) {
            if let msgArray = docData["messageArray"] as? [Any] {
                for msgObj in msgArray {
                    if let msgObject = MessageViewModal.getMessage(forData: msgObj, withDocID: chatDocID, andMessageobj: msgObj) {
                        messages.append(msgObject)
                    }
                }
            }
        }
        return messages
    }
    
    func updateStatusForChatMessages(withStatus status : String) {
        
        guard let chatData = CouchbaseOperations().getData(fromDocID: self.chatDocID) else { return }
        var chatDta = chatData
        var msgArray = chatDta["messageArray"] as! [[String:Any]]
        for (idx, dic) in msgArray.enumerated() {
            if ((dic["deliveryStatus"] as? String) != "3") && ((dic["isSelf"] as? Bool) == true){
                var msgData = dic
                msgData["deliveryStatus"] = status
                msgArray[idx] = msgData
            }
        }
        chatDta["messageArray"] = msgArray
        DispatchQueue.main.async {
            CouchbaseOperations().updateData(data: chatDta, toDocID: self.chatDocID)
        }
    }
}
