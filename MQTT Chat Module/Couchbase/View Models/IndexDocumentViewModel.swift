//
//  IndexDocumentManager.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 01/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

class IndexDocumentViewModel: NSObject {
    
    public let couchbase: Couchbase
    
    init(couchbase: Couchbase) {
        self.couchbase = couchbase
    }
    
    
    func updateIndexDocID(isUserSignedIn : Bool) {
        guard let indexID = self.getIndexValue(withUserSignedIn: false) else { return }
        guard let indexData = self.couchbase.getData(fromDocID: indexID) else { return }
        var indxData = indexData
        indxData["isUserSignIn"] = isUserSignedIn
        couchbase.updateData(data: indxData, toDocID: indexID)
    }
    
    /// This method will create IndexDocument which will hold all the data for UserID and User Documents ID
    ///
    /// - Parameters:
    ///   - userID: current UserID
    ///   - docID: docId related to the User
    /// - Returns: Object of CBLDocument / Document
    func createIndexDocument(withUserIDs userIDArray: [String], userDocIDs docIDArray : [String], isUserSignedIn : Bool, userID : String) -> String? {
        let params = ["userIDArray":userIDArray,
                      "userDocIDArray":docIDArray,
                      "isUserSignIn":isUserSignedIn,
                      "userID":userID] as [String:Any]
        return couchbase.createDocument(withProperties: params)
    }
    
    /// Used for getting the index DocID. If its there then return the existing one or else create a new one.
    ///
    /// - Returns: String value of index document ID.
    func getIndexValue(withUserSignedIn isUserSignedIn : Bool) -> String? {
        if let indexDocID = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.indexDocID) as? String {
            if indexDocID.count>1 {
                return indexDocID
            } else {
                return self.createIndexDB(withUserSignedIn: isUserSignedIn)
            }
        } else {
            return self.createIndexDB(withUserSignedIn: isUserSignedIn)
        }
    }
    
    /// Used for creating Index DB initially
    ///
    /// - Parameter isUserSignedIn: with Adding value for isUserSignedIn
    /// - Returns: Document ID of created index document.
    fileprivate func createIndexDB(withUserSignedIn isUserSignedIn : Bool) -> String? {
        let userDocVMObj = UsersDocumentViewModel(couchbase: couchbase)
        let indexDocID = CouchbaseManager.createInitialCouchBase(withUserSignedIn: isUserSignedIn)
        UserDefaults.standard.set(indexDocID, forKey: AppConstants.UserDefaults.indexDocID)
        guard let userID = Utility.getUserid() else { return nil }
        userDocVMObj.getUserDocuments(forUserID: userID)
        UserDefaults.standard.synchronize() //why its fetching ? Need to check here.
        return indexDocID
        
    }
}
