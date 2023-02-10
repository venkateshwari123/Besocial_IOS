//
//  Contacts.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 18/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import APAddressBook

class Contacts: NSObject {
    
    
   // var firstName: String?
   // var lastName: String?
    var fullName : String?
    var alternateNumbers : NSArray?
    var contactID : String?
    var modificationDate: String?
    var isFavorite : String?
    var registerNum : String?
    var profilePic : String?
    var status : String?
    var chatDocID : String?
    var userID : String?
    var firstName: String?
    var lastName: String?
    ///it contains two keys "status" and "message"
    var follow : [String : Any]?
    var followStatus : Int?
    var privicy: Int?
    var isStar:Int?
    
    init(fullName: String? , alternateNumbers: NSArray? , contactID: String? ,modificationDate : String?,isFavorite: String? , registerNum : String?,profilePic : String? , status: String?, chatDocID : String? , userID: String?, follow: [String : Any]?, followStatus: Int?, privicy: Int?, firstName: String?, lastName: String?,isStar: Int?){
        self.isStar = isStar
        self.fullName = fullName
        self.alternateNumbers = alternateNumbers
        self.contactID = contactID
        self.modificationDate = modificationDate
        self.isFavorite = isFavorite
        self.registerNum = registerNum
        self.profilePic = profilePic
        self.status = status
        self.chatDocID = chatDocID
        self.userID = userID
        self.follow = follow
        self.followStatus = followStatus
        self.privicy = privicy
        self.firstName = firstName
        self.lastName = lastName
    }
    
    init(contact: APContact){
        if let firstName = contact.name?.firstName{
            self.fullName = firstName
            if let lastName = contact.name?.lastName{
                self.fullName = self.fullName! + " " + lastName
            }
        }
        self.contactID = "\(contact.recordID)"
        if let phone = contact.phones?[0]{
            self.registerNum = phone.number
        }        
    }
    
    init(followModel: FollowersFolloweeModel, docId: String?){
        self.fullName = followModel.userName
        self.firstName = followModel.firstName
        self.lastName = followModel.lastName
        self.profilePic = followModel.profilePic
        self.status = followModel.status
        self.userID = followModel.id
        self.registerNum = followModel.number
        self.privicy = followModel.userStatus
        self.chatDocID = docId
        self.isStar = followModel.isStar
    }
    
    init(profileModel: UserProfileModel, docId: String?){
        self.fullName = profileModel.userName
        self.firstName = profileModel.firstName
        self.lastName = profileModel.lastName
        self.profilePic = profileModel.profilePic
        self.status = profileModel.status
        self.userID = profileModel.userId
        self.registerNum = profileModel.number
        self.privicy = profileModel.userStatus
        self.chatDocID = docId
        self.isStar = profileModel.isStar
    }
    
    class func getContactsArrayFormDatabase(database: Couchbase)-> NSArray{
        
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID)
        let document = database.getData(fromDocID: documentID as! String)
        
        if let dbContacts = document?["contactList"] as? NSArray {
            return dbContacts
        }
        
        return []
    }
    
    class func updateContactDataInDatabase(database: Couchbase , contactList: NSArray) {
        
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        if documentID ==  nil{
            let contactDocID = database.createDocument(withProperties: ["contactList":contactList] as [String : Any])
            UserDefaults.standard.set(contactDocID, forKey: AppConstants.UserDefaults.contactDocumentID)
        }else{
            database.updateDocument(data:["contactList": contactList] as [String : Any] , toDocID: documentID!)
        }
    }
    
        
    /// Used for creating the Contact object.
    /// - Parameter userDetails: contact Data in array format
    /// - Returns: Array of contact objects.
    class fileprivate func getContacts(withContactDetails userDetails: [Any]?) -> [Contacts] {
        var contacts = [Contacts]()
        guard let userDetails = userDetails else { return [] }
        
        for userDetail in userDetails {
            guard let userDetail = userDetail as? [String:Any] else { return contacts }
            if var contactFullName = userDetail["fullName"] as? String, let alternateNumbers = userDetail["alternateNumbers"] as? NSArray, let contactID = userDetail["contactID"] as? String , let modificationDate = userDetail["modificationDate"] as? String , let regiNumber = userDetail["registerNum"] as? String, let profilePic = userDetail["profilePic"] as? String , let isfav = userDetail["isFavorite"] as? String , var  status = userDetail["Status"] as? String , let userID = userDetail["userID"] as? String, let follow = userDetail["follow"] as? [String : Any], let followStatus = userDetail["followStatus"] as? Int, let privicy = userDetail["private"] as? Int, let firstName = userDetail["firstName"] as? String, let lastName = userDetail["lastName"] as? String{
                var isStar = 0
                if let star = userDetail["isStar"] as? Int {
                    isStar = star
                }
                if contactFullName.count == 0{
                    contactFullName = regiNumber
                }
                
                if status.count == 0 {
                    status = AppConstants.defaultStatus
                }
                
                var chatDocID:String? = ""
                if let chatDID = userDetail["chatDocID"] as? String {
                    chatDocID = chatDID
                } else { chatDocID = nil }
                
                
                let user = Contacts.init(fullName: contactFullName , alternateNumbers: alternateNumbers, contactID: contactID, modificationDate: modificationDate, isFavorite: isfav , registerNum: regiNumber, profilePic: profilePic, status:status, chatDocID: chatDocID, userID: userID, follow: follow, followStatus: followStatus, privicy: privicy, firstName: firstName, lastName: lastName, isStar: isStar)
                contacts.append(user)
            }else{
                continue
            }
        }
        return contacts
    }
    
    
    class func getonlyOneContact(_ userDetail: [String:Any]?) -> Contacts?{
        guard let userDetail = userDetail as? [String:Any] else { return nil }
        guard var contactFullName = userDetail["fullName"] as? String, let alternateNumbers = userDetail["alternateNumbers"] as? NSArray, let contactID = userDetail["contactID"] as? String , let modificationDate = userDetail["modificationDate"] as? String , let regiNumber = userDetail["registerNum"] as? String, let profilePic = userDetail["profilePic"] as? String , let isfav = userDetail["isFavorite"] as? String , var  status = userDetail["Status"] as? String , let userID = userDetail["userID"] as? String, let follow = userDetail["follow"] as? [String : Any], let followStatus = userDetail["followStatus"] as? Int, let privicy = userDetail["private"] as? Int, let firstName = userDetail["firstName"] as? String, let lastName = userDetail["lastName"] as? String else {
            return nil
        }
        
        if contactFullName.count == 0{
            contactFullName = regiNumber
        }
        
        var isStar = 0
        if let star = userDetail["isStar"] as? Int {
            isStar = star
        }
        
        if status.count == 0 {
            status = AppConstants.defaultStatus
        }
        
         var chatDocID:String? = ""
        if let chatdocId = userDetail["chatDocID"] as? String{
            chatDocID = chatdocId
        }else{ chatDocID = ""}
        
        
        let user = Contacts.init(fullName: contactFullName , alternateNumbers: alternateNumbers, contactID: contactID, modificationDate: modificationDate, isFavorite: isfav , registerNum: regiNumber, profilePic: profilePic, status:status, chatDocID: chatDocID, userID: userID, follow: follow, followStatus: followStatus, privicy: privicy, firstName: firstName, lastName: lastName, isStar: isStar)
    
        return user
    }
    
    
    
    /// Used for get all the users data and return the contact object.
    class  func getAllUserDetail(withuserData userData : [Any]?) -> [Contacts] {
        let userLists = self.getContacts(withContactDetails: userData)
      
        return userLists
    }
    

}
