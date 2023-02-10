//
//  Couchbase.Swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 21/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import CocoaLumberjack
import GooglePlaces

/// Used for getting the Couch DB Object
class Couchbase: NSObject {
    
    static let locationDocId = "locationDocId"
    
    struct Constants {
        static let DBCreationError = "Database creation or opening failed"
        static let DocumentCreationError = "Failed to create the document"
    }
    
    /// singleton object of Couchbase DB with DB Name "MQTTChatDB"
    static let sharedInstance = Couchbase()
    let manager = CBLManager.sharedInstance()
    
    /// Get the current database object.
    var database : CBLDatabase! = nil
    
    override init() {
        do {
            self.database = try CBLManager.sharedInstance().databaseNamed(AppConstants.CouchbaseConstant.dbName)
        }
        catch let dbCreationError{
//            DDLogDebug("\(Constants.DocumentCreationError,dbCreationError)")
        }
    }
    
    
    /// Used for creating document with given properties and it returns the document ID
    ///
    /// - Parameter properties: document properties
    /// - Returns: document ID in optional format.
    func createDocument(withProperties properties: [String : Any]) -> String? {
        guard let document = self.database?.createDocument() else { return nil }
        do {
            try document.putProperties(properties)
            return document.documentID
        }
        catch let couchBaseError {
//            DDLogDebug("\(Constants.DBCreationError,couchBaseError)")
            return document.documentID
        }
    }
    
    /// Update data into particaular document which can be accessed by the DocID passed along with data.
    ///
    /// - Parameters:
    ///   - data: Data to update into existing document.
    ///   - docID: current documents DocID.
    func updateData(data : [String : Any], toDocID docID: String) {
        guard let document = self.getDocumentObject(fromDocID: docID) else {
            DDLogDebug("failed to get documet from provided DocID")
            return
        }
        do {
            try document.putProperties(data)
        }
        catch let error {
            DDLogDebug("Data not saved \(error)")
        }
    }
    
    
    func updateChatStatus(data:[String:Any],toDocID: String){
        guard let document = self.getDocumentObject(fromDocID: toDocID) else {
            DDLogDebug("failed to get documet from provided DocID")
            return }
        do{
            try document.update { (newRev) -> Bool in
                newRev["messageArray"] = data["messageArray"]
                //print("helllo document changeddddd hereeeeeeee eeeeeeeeeeeeeeeeeeeeeee")
                return true
            }
        }
        catch let error {
            DDLogDebug("cdkvndkv\(error)")
        }
        
    }
    
    func updateDocument(data: [String: Any], toDocID: String){
            guard let document = self.getDocumentObject(fromDocID: toDocID) else {
                DDLogDebug("failed to get documet from provided DocID")
                return }
            do{
                try document.update { (newRev) -> Bool in
                    newRev["contactList"] = data["contactList"]
                   // print("helllo document changeddddd hereeeeeeee eeeeeeeeeeeeeeeeeeeeeee")
                    return true
                }
            }
            catch let error {
                DDLogDebug("cdkvndkv\(error)")
            }
    }
    
    func updateFollowListDocument(data: [String: Any], toDocID: String){
        guard let document = self.getDocumentObject(fromDocID: toDocID) else {
            DDLogDebug("failed to get documet from provided DocID")
            return }
        do{
            try document.update { (newRev) -> Bool in
                newRev[Strings.FollowListStrings.followList] = data[Strings.FollowListStrings.followList]
                // print("helllo document changeddddd hereeeeeeee eeeeeeeeeeeeeeeeeeeeeee")
                return true
            }
        }
        catch let error {
            DDLogDebug("cdkvndkv\(error)")
        }
    }
    
    
    /// It will delete the document by using the docID passed along with.
    ///
    /// - Parameter docID: current docID of the couchbase Document.
    func deleteDocument(withDocID docID : String) {
        guard let document = self.getDocumentObject(fromDocID: docID) else { return }
        do{
            try document.delete()
            return
        }
        catch let error{
            DDLogDebug("unable to delete \(error)")
        }
    }
    
    
    /// To get the data object by using the document.
    ///
    /// - Parameter documentID: Current document ID
    /// - Returns: document
    func getDocumentObject(fromDocID documentID : String) -> CBLDocument? {
        guard let document = database?.document(withID: documentID) else { return nil}
        return document
    }
    
    func getData(fromDocID docID : String) -> [String:Any]? {
        var messageArray = [String:Any]()
        if let document = self.getDocumentObject(fromDocID: docID) {
            messageArray = document.properties ?? [:]
        }
        return messageArray
    }
    
    //MARK:- Location CURD operationzz
    /// To create location document and store location serch
    ///
    /// - Parameter propertie: location data to store
    /// - Returns: document id on which location data will store
    func createLocationDocument(with propertie: [[String : Any]]) ->String?{
        guard let document = self.database?.createDocument() else { return nil}
        do{
            try document.update { (newRev) -> Bool in
                newRev["location"] = propertie
                // print("helllo document changeddddd hereeeeeeee eeeeeeeeeeeeeeeeeeeeeee")
                return true
            }
        }
        catch let error {
            DDLogDebug("cdkvndkv\(error)")
        }
        return document.documentID
    }
    
    
    /// To get all location data (array of GMSAutocompletePrediction object )
    ///
    /// - Returns: array of GMSAutocompletePrediction for location key
    func getLocationData(docId: String) ->[String : Any]?{
        let document = self.getDocumentObject(fromDocID: docId)
        let locationData = document?.properties
        return locationData
    }
    
    
    /// To update location data
    ///
    /// - Parameter location: passing array of GMSAutocompletePrediction
    func updateLocationData(docId: String, location: [[String : Any]]){
        guard let document = self.getDocumentObject(fromDocID: docId) else {
            DDLogDebug("failed to get documet from provided DocID")
            return }
        do{
            try document.update { (newRev) -> Bool in
                newRev["location"] = location
                // print("helllo document changeddddd hereeeeeeee eeeeeeeeeeeeeeeeeeeeeee")
                return true
            }
        }
        catch let error {
            DDLogDebug("cdkvndkv\(error)")
        }
    }
    
    /// Store the data of users, postIds, durations, cities
    /// - Parameters:
    ///   - data: dictionary
    ///   - toDocID: docId
    func storePostsViewersData(data: [String: Any], toDocID: String){
           guard let document = self.getDocumentObject(fromDocID: toDocID) else {
               DDLogDebug("failed to get documet from provided DocID")
               return }
           do{
               try document.update { (newRev) -> Bool in
                   newRev["postsViewers"] = data["postsViewers"]
                   return true
               }
           }
           catch let error {
               DDLogDebug("\(error)")
           }
       }
}
