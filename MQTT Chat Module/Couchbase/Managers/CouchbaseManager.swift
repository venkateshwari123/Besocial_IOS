//
//  CouchbaseManager.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 01/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import UserNotifications
import CocoaLumberjack

class CouchbaseManager: NSObject {
    
    static let sharedInstance = CouchbaseManager()
    
    
    
    let selfID = Utility.getUserid()
    fileprivate let mqttChatManager = MQTTChatManager.sharedInstance
    
    class func createInitialCouchBase(withUserSignedIn isUserSignedIn  : Bool ) -> String? {
        var userImage = ""
        var userName = "", userReceiverIdentifier = ""
        var isStar = 0
        let couchbase = Couchbase.sharedInstance
        let userDocVMObject = UsersDocumentViewModel(couchbase: couchbase)
        let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
        let individualChatDocVMObject = IndividualChatViewModel(couchbase: couchbase)
        guard let userID = Utility.getUserid() else { return ""}
        if let usrName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userFullName) as? String {
            userName = usrName
        }
        if let usrImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImageForChats) as? String {
            userImage = usrImage
        }
        if let userNumber = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.userName) as? String{
            userReceiverIdentifier = userNumber
        }
        
        if let isVerified = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.isVerifiedUserProfile) as? Bool{
            isStar = isVerified ? 1 : 0
        }
        
        guard let chatsDocID = individualChatDocVMObject.createIndividualChatsDocument(withreceiverUIDArray: [], receiverDocIDArray: [], secretIDArray: [] ) else { return nil }
        let unsentMessageDocVMObject = UnsentMessageViewModel(couchbase: couchbase)
        guard let unsentMessagesDocumentID = unsentMessageDocVMObject.createUnsentMessagesDocumentID() else { return nil }
        guard let userDocID = userDocVMObject.createUserDocument(withUserID: userID, receiverIdentifier: userReceiverIdentifier, userName: userName, userImage: userImage, apiToken: "", userLoginType: 0, chatDocument: chatsDocID, unsentMessagesDocument: unsentMessagesDocumentID, mqttTokenDocument: "", callsDocument: "", contactsDocument: "", isStar: isStar ) else { return nil }
        
        guard let indexDocID = indexDocVMObject.createIndexDocument(withUserIDs: [userID], userDocIDs: [userDocID], isUserSignedIn: isUserSignedIn, userID: userID) else { return nil }
        return indexDocID
    }
}
