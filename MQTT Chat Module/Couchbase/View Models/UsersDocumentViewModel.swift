//
//  UsersDocumentViewModel.Swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 01/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import CocoaLumberjack

class UsersDocumentViewModel: NSObject {
    
    public let couchbase: Couchbase
    
    init(couchbase: Couchbase) {
        self.couchbase = couchbase
    }
    
    func getUserData() -> [String : Any]? {
        guard let docID = self.getCurrentUserDocID() else { return nil}
        guard let userDocData = couchbase.getData(fromDocID: docID) else { return nil }
        return userDocData
    }
    
    func getCurrentUserDocID() -> String?{
        let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
        guard let userID = Utility.getUserid() else { return nil }
        guard let indexID = indexDocVMObject.getIndexValue(withUserSignedIn: true) else { return nil }
        guard let indexData = couchbase.getData(fromDocID: indexID) else { return nil }
        guard let userIDArray = indexData["userIDArray"] as? [String] else { return nil }
        if userIDArray.contains(userID) {
            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return nil }
            if let index = userIDArray.index(of: userID) {
                let userDocID = userDocArray[index]
                return userDocID
            }
        }
        return nil
    }
    
    func updateUserDocument(withContactsDocumentID contactDocID : String, intoThisUserDocID userDocID :String ) {
        guard let documentData = couchbase.getData(fromDocID: userDocID) else {
            DDLogDebug("failed to get documet from provided DocID")
            return
        }
        var dic = documentData
        dic["contactsDocument"] = contactDocID
        couchbase.updateData(data: dic, toDocID: userDocID)
    }
    
    func getUserDocuments(forUserID userID : String) {
        var result : CBLQueryEnumerator
        var documentIdArray = [CBLDocument]()
        do {
            let database = try CBLManager.sharedInstance().databaseNamed(AppConstants.CouchbaseConstant.dbName)
            let query = database.createAllDocumentsQuery()
            query.allDocsMode =  CBLAllDocsMode.allDocs
            query.descending = true
            do {
                result = try query.run()
                documentIdArray.removeAll()
                for i in 0..<result.count {
                    documentIdArray.append(database.document(withID: (result.row(at: i)).documentID!)!)
                }
            }
            catch let error{
                DDLogDebug("Not get data with error ,\(error)")
            }
        }
        catch let error {
            DDLogDebug("Not created with error \(error)")
        }
        for i in 0..<documentIdArray.count {
            let data = documentIdArray[i].properties
            
        }
    }
    
    
    func updateUserDoc(withUserName userName : String?, andImageURL imageURL :String?, loginType :String?, receiverIdentifier: String?, intoDocID docID : String) {
        guard let documentData = couchbase.getData(fromDocID: docID) else {
            DDLogDebug("failed to get documet from provided DocID")
            return
        }
        var dic = documentData
        if let uName = userName {
            dic["userName"] = uName
        }
        if let image = imageURL {
            dic["userImageUrl"] = image
        }
        if let lType = loginType {
            dic["userLoginType"] = lType
        }
        if let rIdentifier = receiverIdentifier {
            if rIdentifier.count>0 {
                dic["receiverIdentifier"] = rIdentifier
            }
        }
        
        couchbase.updateData(data: dic, toDocID: docID)
    }
    
    func updateUserDoc(withUser firstName: String?, lastName: String?, userName: String?, imageUrl: String?, privacy : Int?,
                       loginType: String?, receiverIdentifier: String?, docId: String,refreshToken:String?){
        guard let documentData = couchbase.getData(fromDocID: docId) else {
            DDLogDebug("failed to get documet from provided DocID")
            return
        }
        var dic = documentData
        if let firstName = firstName{
            dic["firstName"] = firstName
        }
        if let lastName = lastName{
            dic["lastName"] = lastName
        }
//        if let publicName = userName{
//            dic["publicName"] = publicName
//        }
        
        if let fN = firstName{
            dic["publicName"] = fN
            if let lN = lastName{
                dic["publicName"] = fN + lN
            }
        }
        
        if let isPrivate = privacy{
            dic["private"] = isPrivate
        }
        if let profilePic = imageUrl {
            dic["userImageUrl"] = profilePic
        }
        if let rIdentifier = receiverIdentifier {
            if rIdentifier.count>0 {
                dic["receiverIdentifier"] = rIdentifier
            }
        }
        if let refreshToken = refreshToken{
            dic["refreshToken"] = refreshToken
        }
        couchbase.updateData(data: dic, toDocID: docId)
    }
    
    func updateUserDoc(withUserData data:[String : Any],userLoginType : String, intoDocID docID : String) {
        
        guard let documentData = couchbase.getData(fromDocID: docID) else {
            DDLogDebug("failed to get documet data from provided DocID")
            return
        }
        var dic = documentData
        dic["userID"] = data["userId"]
        if let firstName = data["firstName"]{
            dic["firstName"] = firstName
        }
        if let lastName = data["lastName"]{
            dic["lastName"] = lastName
        }
        /*
         Bug Name:- Show full name in chats instead of username
         Fix Date:- 12/05/2021
         Fixed By:- Jayaram G
         Discription of Fix:- Replaced username with fullname
         */
        if let publicName = data["userName"]{
            dic["publicName"] = "\(data["firstName"] ?? "")" + " " + "\(data["lastName"] ?? "")"
        }
        if let isPrivate = data["private"]{
            dic["private"] = isPrivate
        }
        if let profilePic = data["profilePic"] {
            dic["userImageUrl"] = profilePic
        }
        if let apiToken = data["token"] {
            dic["apiToken"] = apiToken
        }
//        dic["userLoginType"] = userLoginType
        couchbase.updateData(data: dic, toDocID: docID)
    }
    
    func updateUserDoc(data: [String : Any], withLoginType loginType : String) {
        guard let userID = Utility.getUserid() else { return }
        let indexDocVCModel = IndexDocumentViewModel(couchbase: couchbase)
        guard let indexID = indexDocVCModel.getIndexValue(withUserSignedIn: true) else { return }
        guard let indexData = couchbase.getData(fromDocID: indexID) else { return }
        guard let userIDArray = indexData["userIDArray"] as? [String] else { return }
        if userIDArray.contains(userID) {
            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return }
            if let index = userIDArray.index(of: userID) {
                let userDocID = userDocArray[index]
                self.updateUserDoc(withUserData: data, userLoginType: loginType, intoDocID: userDocID)
            }
        }
    }
    
    /// Used for creating user document which will contain all the data related to the user.
    ///
    /// - Parameters:
    ///   - userID: user ID related to the current user.
    ///   - userName: name for the current user.
    ///   - userImage: image for the current user.
    ///   - apiToken: api authentication token for the current user.
    ///   - userLoginType: type of login that user has done.
    ///   0 - Email.
    ///   1 - Phone.
    ///   2 - Facebook.
    ///   3 - Google.
    ///   - chatDocument: Document address of document which contains all the chat details for the current user.
    ///   - unsentMessagesDocument: Document address of document which contains all the chat details for the current user.
    ///   - mqttTokenDocument: Document address of document which contains all the messages not yet acknowledged by the server, along with the corresponding MQTT token and the docID.
    ///   - callsDocument: This document address of document which contains all the call logs related to current user.
    ///   - contactsDocument: This document address of document which contains all the contacts of current user.
    /// - Returns: Object of CBLDocument / Document ID
    
    func createUserDocument(withUserID userID : String,receiverIdentifier : String, userName:String, userImage:String, apiToken: String, userLoginType : Int, chatDocument: String, unsentMessagesDocument : String, mqttTokenDocument :String, callsDocument :String, contactsDocument : String, isStar : Int) -> String? {
        let params = ["userID":userID,
                      "userName":userName,
                      "userImageUrl":userImage,
                      "apiToken":apiToken,
                      "receiverIdentifier": receiverIdentifier,
                      "userLoginType":userLoginType,
                      "chatDocument":chatDocument,
                      "unsentMessagesDocument":unsentMessagesDocument,
                      "mqttTokenDocument":mqttTokenDocument,
                      "callsDocument":callsDocument,
                      "contactsDocument":contactsDocument,
                      "isStar":isStar] as [String:Any]
        
        let docID = couchbase.createDocument(withProperties: params)
        return docID
    }
}
