//
//  ChatUser.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 20/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import CocoaLumberjack
import SwiftyJSON
import Alamofire

class Contact: NSObject {
    
    struct Constants {
        static let errorKeyIdentifier = Strings.error.localized
    }
    
    var userID : String?
    var name : String?
    var profilePic : String?
    var status :String?
    var userName :String?
    
    init(userID : String?, name : String?, profilePic :String?, status : String?, userName :String?) {
        self.userID = userID
        self.name = name
        self.profilePic = profilePic
        self.status = status
        self.userName = userName
    }
    
    
    /// Used for creating the Contact object.
    ///
    /// - Parameter userDetails: contact Data in array format
    /// - Returns: Array of contact objects.
    class fileprivate func getContact(withContactDetails userDetails: [Any]?) -> [Contact] {
        var contacts = [Contact]()
        guard let userDetails = userDetails else { return [] }
        
        for userDetail in userDetails {
            guard let userDetail = userDetail as? [String:Any] else { return [] }
            guard  let contactName = userDetail["contactName"] as? String, let contactStatus = userDetail["contactStatus"] as? String, let userID = userDetail["contactUID"] as? String, let userName = userDetail["contactUserName"] as? String else {
                return []
            }
            let user = Contact(userID: userID, name: contactName, profilePic: userDetail["contactPicUrl"] as? String, status: contactStatus, userName: userName)
            contacts.append(user)
        }
        return contacts
    }
    
    
    /// This method will going to return all the users in the callback whenever the data comes from the API
    ///
    /// - Parameter callback: array of Contact
    
    class func getAllUsers(callback: @escaping(([Contact]) -> Void)){
        let strURL = AppConstants.constantURL + AppConstants.getUsers
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        let headers = ["Authorization": "\(basicAuth)"]
        AFWrapper.requestPOSTURL(serviceName: strURL,
                                 params: nil, header: HTTPHeaders.init(headers),
                                 success: { (response) in
                                    guard let contacts = self.updateDataToContactsDoc(withData: response["data"].arrayObject) else { return }
                                    callback(contacts)
                                    DDLogDebug("\(response["data"].arrayObject!)")
        },
                                 failure: { (Error) in
                                    UIApplication.shared.keyWindow?.rootViewController?.showAlert(Constants.errorKeyIdentifier, message: Error.localizedDescription)
        })
    }
    
    /// Updates data to contact doc and return a Contact array.
    class fileprivate func updateDataToContactsDoc(withData data: [Any]?) -> [Contact]? {
        let couchbase = Couchbase.sharedInstance
        let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
        let contactsVMObject = ContactsDocumentViewModel(couchbase: couchbase)
        let usersDocVMObject = UsersDocumentViewModel(couchbase: couchbase)
        
        
        guard let userID = Utility.getUserid() else { return nil }
        guard let indexID = indexDocVMObject.getIndexValue(withUserSignedIn: true) else { return nil }
        
        guard let indexData = couchbase.getData(fromDocID: indexID) else { return nil }
        
        guard let userIDArray = indexData["userIDArray"] as? [String] else { return nil }
        
        if userIDArray.contains(userID) {
            
            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return nil }
            
            if let index = userIDArray.index(of: userID) {
                
                let userDocID = userDocArray[index]
                
                guard let userDocData = couchbase.getData(fromDocID: userDocID) else { return nil }
                
                if let contactID = userDocData["contactsDocument"] as? String {
                    couchbase.deleteDocument(withDocID: contactID)
                }
                
                guard let contactDocID = contactsVMObject.createContactsDocument(withcontactData: data) else { return nil }
                
                usersDocVMObject.updateUserDocument(withContactsDocumentID: contactDocID, intoThisUserDocID: userDocID)
                
                guard let updatedData = couchbase.getData(fromDocID: contactDocID) else { return nil }
                
                guard let contactsArray = updatedData["contactsArray"] as? [Any] else { return nil }
                
              
                let contacts = self.getAllUserDetails(withuserData: contactsArray)
                
                
                return contacts
            }
        }
        return nil
    }
    
    
    
    /// Used for get all the users data and return the contact object.
    class fileprivate func getAllUserDetails(withuserData userData : [Any]?) -> [Contact] {
        let userLists = Contact.getContact(withContactDetails: userData)
        return userLists
    }
    
    
}

