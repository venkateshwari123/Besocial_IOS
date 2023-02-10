//
//  FavoriteViewModel.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 16/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts
import CocoaLumberjack
import APAddressBook

class FavoriteViewModel: NSObject {
    
    static let  sharedInstance  = FavoriteViewModel()
    var apBook :APBook? = nil
    var contactPermissionView : UIView?
    
    override init() {
        apBook = APBook.sharedInstance
    }
    
    
    func getFavoriteDataFromDatabase() -> [Contacts] {
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        if documentID !=  nil{
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        
        let predicate = NSPredicate.init(format: "isFavorite == %@","isFavorite")
        let favArr =  dbContactsArr.filtered(using: predicate)
        if favArr.count > 0  {
            // print("fav database =\(favArr)")
            return Contacts.getAllUserDetail(withuserData: favArr )
        }
        return []
    }
    

    
    @objc func openSetting(){
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
    }
    
    func refreshContactList(){
        apBook?.refreshContact()
    }
    
    /// Used for updating registerNum into contacts Object in couchbase.
    ///
    /// - Parameters:
    ///   - contactDocID : Current contact ID if there is any contact exist.
    ///   - chatDocID : current registerNum which should be udpated to the contact Doc.
    func updateContactDoc(withUserID userID: String?, andChatDocId chatDocID : String? ) {
        // DDLogDebug(contactID ?? "", chatDocID ?? "")
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        if documentID !=  nil{
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        let tempContactArr = dbContactsArr.mutableCopy() as! NSMutableArray
        guard let userId = userID  else { return }
        let predicate = NSPredicate.init(format: "userID == %@",userId)
        let arr =  dbContactsArr.filtered(using: predicate)
        if arr.count > 0 {
            let index = tempContactArr.index(of: arr[0])
            var newDict = arr[0] as! [String:Any]
            newDict["chatDocID"] = chatDocID
            if index < tempContactArr.count {
                tempContactArr.replaceObject(at: index, with: newDict) } ///put check
        }
        DispatchQueue.main.async {
            if tempContactArr.count>0 {
                Contacts.updateContactDataInDatabase(database: Couchbase.sharedInstance, contactList:
                    tempContactArr)
            }
        }
    }
    
    /// Used for returning contact object on the basis of contactID
    ///
    /// - Parameter contactID: current userID if it exists on the contact DB.
    /// - Returns: Current contact object.
    func getContactObject(forContactID contactID : String?) -> Contacts? {
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        if documentID !=  nil{
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        guard let contactId = contactID else {return nil}
        let predicate = NSPredicate.init(format: "contactID == %@",contactId)
        let favArr =  dbContactsArr.filtered(using: predicate)
        if favArr.count > 0  {
            return  Contacts.getonlyOneContact(favArr[0] as? [String:Any])
        }
        return nil
    }
    
    /// Used for returning contact object on the basis of contactID
    ///
    /// - Parameter contactID: current userID if it exists on the contact DB.
    /// - Returns: Current contact object.
    func getUserID(forContactNumber contactNum : String) -> Contacts? {
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        if documentID !=  nil {
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        let pridicate = NSPredicate.init(format:"registerNum CONTAINS [cd] %@",contactNum)
        let favArr =  dbContactsArr.filtered(using: pridicate)
        if favArr.count > 0  {
            return  Contacts.getonlyOneContact(favArr[0] as? [String:Any])
        }
        return nil
    }
    
    /// Used for returning contact object on the basis of userID
    ///
    /// - Parameter userId: current userID if it exists on the contact DB.
    /// - Returns: Current contact object.
    func getContactObject(forUserID userId : String?) -> Contacts? {
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        if documentID !=  nil {
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        guard let userID = userId else {return nil}
        let predicate = NSPredicate.init(format: "userID == %@",userID)
        let favArr =  dbContactsArr.filtered(using: predicate)
        if favArr.count > 0  {
            return  Contacts.getonlyOneContact(favArr[0] as? [String:Any])
        }
        return nil
    }
    
    func openCreatContactView(){
        
    }
    
    func  updateData() {
        Helper.hidePI()
    }
    
    
    
    
     func getOwnUserID() -> String{
        if  let selfID = Utility.getUserid(){
           return selfID
        }else {
           return ""
        }
    }
    
    func getOwnNumber() -> String {
        
        if  let selfID = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String{
            return selfID
        }else {
            return ""
        }
    }
    
    func getOwnname() -> String{
        if  let selfID = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String{
            return selfID
        }else {
            return ""
        }
    }
    
    //MARK:- follow and unfollow update database and Service call
    
    /// To update user follow status in database and server
    ///
    /// - Parameters:
    ///   - contact: contact to be updated
    ///   - isFollow: follow or unfollow
    func updateDatabaseAndServiceCall(contact: Contacts, isFollow: Bool){
        guard let userId = contact.userID else { return }
//        guard let number = contact.registerNum else { return }
        var strUrl: String = ""
        if isFollow{
            strUrl = AppConstants.follow
        }else{
             strUrl = AppConstants.unfollow
        }
        ContactAPI.followAndUnfollowService(with: isFollow, followingId: userId, privicy: contact.privicy!)
//        contactToUpdate(contact: contact, isFollow: isFollow)
    }
    
    /// To update contact follow status in database
    ///
    /// - Parameters:
    ///   - contact: number to be updated
    ///   - isFollow: is follow or unfollow
    func contactToUpdate(contact: Contacts, isFollow: Bool){
        
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        if documentID !=  nil{
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        
        guard let contactToSearch = contact.registerNum else{return}

        let tempContactArr = dbContactsArr.mutableCopy() as! NSMutableArray
        let pridicate = NSPredicate.init(format:"numbers_Str CONTAINS [cd] %@",contactToSearch)
        var arr = dbContactsArr.filtered(using: pridicate)
        if arr.count == 0{
            let registerNumberpridicate = NSPredicate.init(format:"registerNum CONTAINS [cd] %@",contactToSearch)
            arr = dbContactsArr.filtered(using: registerNumberpridicate)
        }
        if arr.count>0{
            let index = tempContactArr.index(of: arr[0])
             var newDict = arr[0] as! [String:Any]
            if isFollow{
//                newDict["followStatus"] = 1
                if let privicy = contact.privicy, privicy == 1{
                    newDict["follow"] = ["message" : " requested to follow", "type" : 2]
                }else{
                    newDict["follow"] = ["message" : " started following", "type" : 1]
                }
            }else{
//                newDict["followStatus"] = 0
                newDict["follow"] = ["message" : "not following", "type" : 0]
            }
            if index < tempContactArr.count{
                tempContactArr.replaceObject(at: index, with: newDict)} ///put check
            Contacts.updateContactDataInDatabase(database: Couchbase.sharedInstance, contactList: tempContactArr as NSArray)
        }
    }
    
    /// To update database and service call to follow all contacts
    func followAllContact(){
        
    }
    
    
    /// To update all contact in database as following
    
}
