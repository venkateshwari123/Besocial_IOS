//
//  IndividualChatViewModel.Swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 01/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import CocoaLumberjack

class IndividualChatViewModel: NSObject {
    
    public let couchbase: Couchbase
    let mqttChatManager = MQTTChatManager.sharedInstance
    
    init(couchbase: Couchbase) {
        self.couchbase = couchbase
    }
    
    /// For getting chat doc on respected to receiver ID and secret ID.
    ///
    /// - Parameters:
    ///   - receiverID: receiver ID provided by the contact.
    ///   - secretID: secret ID related to the contact.
    /// - Returns: this will return the chat doc ID respected to receiver ID and secret ID.
    func fetchIndividualChatDoc(withReceiverID receiverID:String, andSecretID secretID : String) -> String? {
        let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
        guard let userID = Utility.getUserid() else { return nil }
        guard let indexID = indexDocVMObject.getIndexValue(withUserSignedIn: true) else { return  nil }
        guard let indexData = couchbase.getData(fromDocID: indexID) else { return  nil }
        guard let userIDArray = indexData["userIDArray"] as? [String] else { return  nil }
        if userIDArray.contains(userID) {
            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return nil }
            if let index = userIDArray.index(of: userID) {
                let userDocID = userDocArray[index]
                guard let userDocData = couchbase.getData(fromDocID: userDocID) else { return nil  }
                if let chatDocID = userDocData["chatDocument"] as? String {
                    guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return nil  }
                    guard let receiverUIDArray = chatData["receiverUidArray"] as? [String] else { return nil  }
                    guard let scretIDArray = chatData["secretIdArray"] as? [String] else { return  nil }
                    guard let receiverChatDocIdArray = chatData["receiverDocIdArray"] as? [String] else { return nil  }
                    if !scretIDArray.isEmpty { // For searching the chat doc id.
                        for index in 0 ..< receiverUIDArray.count {
                            let reciverIDL = receiverUIDArray[index]
                            if (receiverID == reciverIDL ) {
                                if scretIDArray[index] == secretID {
                                    return receiverChatDocIdArray[index]
                                }
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    
    
    fileprivate func insertIndividualDocID(withDocID IndividualDocID : String,receiverID :String, andSecretID secretID : String) -> Bool {
        let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
        guard let userID = Utility.getUserid() else { return false }
        guard let indexID = indexDocVMObject.getIndexValue(withUserSignedIn: true) else { return  false }
        guard let indexData = couchbase.getData(fromDocID: indexID) else { return  false }
        guard let userIDArray = indexData["userIDArray"] as? [String] else { return  false }
        if userIDArray.contains(userID) {
            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return false }
            if let index = userIDArray.index(of: userID) {
                let userDocID = userDocArray[index]
                guard let userDocData = couchbase.getData(fromDocID: userDocID) else { return false  }
                if let chatDocID = userDocData["chatDocument"] as? String {
                    self.updateIndividualChatsDocument(withreceiverDocID: IndividualDocID, secretID: secretID, andreceiverUID: receiverID, intoChatsDocumentID: chatDocID)
                    return true
                }
            }
        }
        return false
    }
    
    /// This method is used for creating a document to maintain all the chats document
    ///
    /// - Parameters:
    ///   - receiverIDArray: String arrray for storing all the receiver UIDs
    ///   - receiverDocIDArray: String array for storing all the Document IDs related to UIDs
    ///   - secretIDArray: String array for storing all the secret IDs related to the UIDs
    /// - Returns: Object of CBLDocument / Document
    func createIndividualChatsDocument(withreceiverUIDArray receiverIDArray: [String], receiverDocIDArray : [String], secretIDArray : [String]) -> String? {
        
        let params = ["receiverUidArray":receiverIDArray,
                      "receiverDocIdArray":receiverDocIDArray,
                      "secretIdArray":secretIDArray] as [String:Any]
        let docID = couchbase.createDocument(withProperties: params)
        return docID
    }
    
    func getChatDocID(withreceiverID receiverID:String, andSecretID secretID : String, withContactObj contactObj: Contacts?, messageData message : [String : Any]?, destructionTime : Int?, isCreatingChat : Bool, recieverNumber : String = "") -> String? {
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbase)
        if let docID = fetchIndividualChatDoc(withReceiverID: receiverID, andSecretID: secretID) {
            return docID
        } else {
            if let contactObj = contactObj {
                /*
                Bug Name:- Show full name in chats instead of username
                Fix Date:- 12/05/2021
                Fixed By:- Jayaram G
                Discription of Fix:- Replaced username with fullname
                */
                guard let docID = chatsDocVMObject.createChatDoc(withReceiverName: "\(contactObj.firstName ?? "")" + " " + "\(contactObj.lastName ?? "")", secretID: secretID, receiverImage: contactObj.profilePic, message: message, receiverID: receiverID, destrcutionTime: nil, isCreatingChat: isCreatingChat, contact: contactObj) else { return nil }
                
                let isDataWrittenToDoc = self.insertIndividualDocID(withDocID: docID, receiverID: receiverID, andSecretID: secretID)
                if isDataWrittenToDoc {
                    return docID
                } else {
                    return nil
                }
            } else { // Used for if there is no chat available.
                if let msgObj = message {
                    let name: String = (msgObj["name"] as? String != nil) ? msgObj["name"] as! String : ""
                    guard let docID = chatsDocVMObject.createChatDoc(withReceiverName: name, secretID : secretID, receiverImage: "", message: msgObj, receiverID: receiverID, destrcutionTime: destructionTime, isCreatingChat: isCreatingChat) else { return nil }
                    
                    let isDataWrittenToDoc = self.insertIndividualDocID(withDocID: docID, receiverID: receiverID, andSecretID: secretID)
                    if isDataWrittenToDoc {
                        return docID
                    }else {
                        return nil
                    }
                } else {
                    
                    guard let docID = chatsDocVMObject.createChatDoc(withReceiverName: recieverNumber, secretID : secretID, receiverImage: "", message: nil, receiverID: receiverID, destrcutionTime: destructionTime, isCreatingChat: isCreatingChat ) else { return nil }
                    
                    let isDataWrittenToDoc = self.insertIndividualDocID(withDocID: docID, receiverID: receiverID, andSecretID: secretID)
                    if isDataWrittenToDoc {
                        return docID
                    }else {
                        return nil
                    }
                }
            }
        }
    }
    
    
    func updateIndividualChatsDocument(withreceiverDocID receiverDocID : String, secretID :String, andreceiverUID receiverUID: String, intoChatsDocumentID chatsDocID : String ) {
        guard let documentData = couchbase.getData(fromDocID: chatsDocID) else {
            DDLogDebug("failed to get documet from provided DocID")
            return
        }
        var dic = documentData
        var docIDArray = dic["receiverDocIdArray"] as! [String]
        var uidArray = dic["receiverUidArray"] as! [String]
        var secretIdArray = dic["secretIdArray"] as! [String]
        if docIDArray.contains("") {
            if let docIDindex = docIDArray.index(of: "") {
                docIDArray.remove(at: docIDindex)
                uidArray.remove(at: docIDindex)
                secretIdArray.remove(at: docIDindex)
            }
        }
        docIDArray.append(receiverDocID)
        dic["receiverDocIdArray"] = docIDArray
        uidArray.append(receiverUID)
        dic["receiverUidArray"] = uidArray
        secretIdArray.append(secretID)
        dic["secretIdArray"] = secretIdArray
        couchbase.updateData(data: dic, toDocID: chatsDocID)
    }
    
    func getIndividualChatDocID(fromMessage message : [String:Any], isCreatingChat : Bool) -> String?   {
        /*
         Bug Name :- show user payments in chat
         Fix Date :- 03/06/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Handled mqtt data
         */
        var fromID = ""
        if let fromId = message["from"] as?  String {
            fromID = fromId
        }else if let senderId = message["senderId"] as? String {
            fromID = senderId
        }
        guard let selfId = Utility.getUserid() else{return nil}
        var toId = ""
        if let group = message["groupId"] as? String, group != "" {
            toId = group
        }else if let messageToId = message["to"] as? String {
            toId = messageToId
        }else if let id = message["receiverId"] as? String {
            toId = id
        }
        let receiverId = (selfId == fromID) ? toId : fromID
        var secretId = ""
        if let secretID = message["secretId"] as? String, secretID != "" {
            secretId = secretID
        }
        guard let chatDocID = self.getChatDocID(withreceiverID: receiverId, andSecretID: secretId, withContactObj: nil, messageData: message, destructionTime: nil, isCreatingChat: isCreatingChat) else { return nil }
        return chatDocID
    }
    
    func getIndividualChatDocIDFromCouchbase() -> String? {
        let indexDocObject = IndexDocumentViewModel(couchbase: couchbase)
        guard let userID = Utility.getUserid() else { return nil }
        guard let indexID = indexDocObject.getIndexValue(withUserSignedIn: true) else { return nil }
        guard let indexData = couchbase.getData(fromDocID: indexID) else { return nil  }
        guard let userIDArray = indexData[AppConstants.indexDocumentConstants.userIDArray] as? [String] else { return nil  }
        if userIDArray.contains(userID) {
            guard let userDocArray = indexData[AppConstants.indexDocumentConstants.userDocIDArray] as? [String] else { return nil  }
            if let index = userIDArray.index(of: userID) {
                let userDocID = userDocArray[index]
                guard let userDocData = couchbase.getData(fromDocID: userDocID) else { return nil  }
                if let chatDocID = userDocData[AppConstants.indexDocumentConstants.chatDocument] as? String {
                    return chatDocID
                }
            }
        }
        return nil
    }
    
    func createIndividualChatDoc(withMsgObj messageObj: [String : Any], receiverID : String, isForCreatingChat : Bool, secretID : String) -> String? { // create Chat id and also update data to individual chat.
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbase)
        guard let chatDocID = self.getChatDocID(withreceiverID: receiverID, andSecretID: secretID, withContactObj: nil, messageData: messageObj, destructionTime: nil, isCreatingChat: isForCreatingChat) else {
            DDLogDebug("Unable to create chat Doc Please debug here")
            return nil
        }
        guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return nil }
        chatsDocVMObject.updateChatData(withData: chatData, msgObject: messageObj, inDocID: chatDocID, isCreatingChat: isForCreatingChat)
        return chatDocID
    }
    
    func updateIndividualChatDoc(withMsgObj msgObject : Any,toDocID docID : String?, isForCreatingChat : Bool) -> String? {
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbase)
        var chatDocId = ""
        if let docID = docID {
            guard let chatData = couchbase.getData(fromDocID: docID) else { return nil }
            chatsDocVMObject.updateChatData(withData: chatData, msgObject : msgObject, inDocID  : docID, isCreatingChat: isForCreatingChat)
            chatDocId = docID
        } else {
            
            guard let chatDocID = self.getIndividualChatDocID(fromMessage: msgObject as! [String : Any], isCreatingChat: isForCreatingChat) else { return nil }
            chatDocId = chatDocID
            guard let chatDta = couchbase.getData(fromDocID: chatDocID) else { return nil }
            guard let chatsDocID = self.getIndividualChatDocIDFromCouchbase() else { return nil }
            guard let chatsData = couchbase.getData(fromDocID: chatsDocID) else { return nil  }
            guard let msgData = msgObject as? [String : Any] else { return nil }
            /*
             Bug Name :- show user payments in chat
             Fix Date :- 03/06/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Handled mqtt data
             */
            var receiverID = ""
            var isStar = 0
            if let id = msgData["from"] as? String {
                receiverID = id
            }else if let senderId = msgData["senderId"] as? String{
                receiverID = senderId
            }else{
                return nil
            }
            var secretId = ""
            if let secretID = msgData["secretId"] as? String, secretID != "" {
                secretId = secretID
            }
            guard let reciverUIDArray = chatsData["receiverUidArray"] as? [String] else { return nil }
            guard let reciverDOCIDArray = chatsData["receiverDocIdArray"] as? [String] else { return nil }
            if reciverUIDArray.count>0 {
                if reciverDOCIDArray.contains(chatDocID) {
                    chatsDocVMObject.updateChatData(withData: chatDta, msgObject: msgObject, inDocID: chatDocID, isCreatingChat: isForCreatingChat)
                } else {
                    //have to create a chat id and have to update in chats doc
                    guard let chatDocID = self.createIndividualChatDoc(withMsgObj: msgData, receiverID: receiverID, isForCreatingChat: isForCreatingChat, secretID: secretId) else { return nil }
                    self.updateIndividualChatsDocument(withreceiverDocID: chatDocID, secretID: secretId, andreceiverUID: receiverID, intoChatsDocumentID: chatsDocID)
                }
            } else {
                //have to create a chat id and have to update in chats doc
                guard let chatDocID = self.createIndividualChatDoc(withMsgObj: msgData, receiverID: receiverID, isForCreatingChat: isForCreatingChat, secretID: secretId) else { return nil }
                self.updateIndividualChatsDocument(withreceiverDocID: chatDocID, secretID: secretId, andreceiverUID: receiverID, intoChatsDocumentID: chatsDocID)
            }
        }
        let name = NSNotification.Name(rawValue: "ChatUpdatedNotification")
        NotificationCenter.default.post(name: name, object: self, userInfo: nil)
        return chatDocId
    }
    
    /// for deleting the document data by passing the chat doc ID.
    ///
    /// - Parameter chatDocId: chat doc ID you want to remove the data.
    func deleteDocIDData(fromChatDocID chatDocId : String?) {
        let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
        guard let userID = Utility.getUserid() else { return }
        guard let chatDocId = chatDocId else { return }
        guard let indexID = indexDocVMObject.getIndexValue(withUserSignedIn: true) else { return }
        guard let indexData = couchbase.getData(fromDocID: indexID) else { return }
        guard let userIDArray = indexData["userIDArray"] as? [String] else { return }
        if userIDArray.contains(userID) {
            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return }
            if let index = userIDArray.index(of: userID) {
                let userDocID = userDocArray[index]
                guard let userDocData = couchbase.getData(fromDocID: userDocID) else { return  }
                if let chatDocID = userDocData["chatDocument"] as? String {
                    guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return  }
                    guard let receiverChatDocIdArray = chatData["receiverDocIdArray"] as? [String] else { return }
                    guard let scretIDArray = chatData["secretIdArray"] as? [String] else { return }
                    guard let receiverUIDArray = chatData["receiverUidArray"] as? [String] else { return }
                    if receiverChatDocIdArray.contains(chatDocId) {
                        if let index:Int = receiverChatDocIdArray.index(of: chatDocId) {
                            
                            var chatDocIDarray = receiverChatDocIdArray
                            var isIndexValid = chatDocIDarray.indices.contains(index)
                            if isIndexValid {
                                chatDocIDarray.remove(at: index)
                            }
                            
                            var secretIDarray = scretIDArray
                            isIndexValid = secretIDarray.indices.contains(index)
                            if isIndexValid {
                                secretIDarray.remove(at: index)
                            }
                            
                            var receiverUIDarray = receiverUIDArray
                            isIndexValid = receiverUIDarray.indices.contains(index)
                            if isIndexValid {
                                receiverUIDarray.remove(at: index)
                            }
                            
                            var chatDocData = chatData
                            chatDocData["receiverDocIdArray"] = chatDocIDarray
                            chatDocData["secretIdArray"] = secretIDarray
                            chatDocData["receiverUidArray"] = receiverUIDarray
                            couchbase.updateData(data: chatDocData, toDocID: chatDocID)
                            couchbase.deleteDocument(withDocID: chatDocId)
                        }
                    }
                }
            }
        }
    }
}
