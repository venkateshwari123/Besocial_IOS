//
//  MQTTContactSyncManager.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 16/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import APAddressBook
import CocoaLumberjack

class MQTTContactSyncManager: NSObject {
    static let sharedInstance = MQTTContactSyncManager()

    
    func getupdateUserdetails(withData data: [String : Any], withTopic topic : String) {
        
       // DDLogDebug("**********\n\n *** getupdateUserdetails ***********\(data)")
        
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        
        if documentID !=  nil{
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        
        
        var isChange = false
        let type = (data["type"] as? Int) ?? 0
        let tempContactArr = dbContactsArr.mutableCopy() as! NSMutableArray
        
        
        switch type {
            
        case 1:
            
            //status update
           
                var dict1:[String:Any] = data as [String:Any]
                //new contact added so add in favList
                let localNum = dict1["number"] as! String
                let pridicate = NSPredicate.init(format:"registerNum CONTAINS [cd] %@",localNum)
                let arr =   dbContactsArr.filtered(using: pridicate)
                
                if (arr.count > 0){
                    
                    let index = tempContactArr.index(of: arr[0])
                    var status = ""
                    
                    if (dict1["socialStatus"] != nil){
                        status = dict1["socialStatus"] as! String
                    }
                    
                    var newDict = arr[0] as! [String:Any]
                    newDict["Status"] = status
                    isChange = true
                    tempContactArr.replaceObject(at: index, with: newDict)
                }
                
        
            
            break
            
        case 2:
            //profile pic update
            
            
                var dict1:[String:Any] = data as [String:Any]
            guard let localNum = dict1["number"] as? String else {return}
                let pridicate = NSPredicate.init(format:"registerNum CONTAINS [cd] %@",localNum)
                let arr =   dbContactsArr.filtered(using: pridicate)
                
                if (arr.count > 0){
                    
                    let index = tempContactArr.index(of: arr[0])
                    var profilePic = ""
                    if (dict1["profilePic"] != nil){
                        profilePic = dict1["profilePic"] as! String
                    }
                    
                    var newDict = arr[0] as! [String:Any]
                    newDict["profilePic"] = profilePic
                    isChange = true
                    tempContactArr.replaceObject(at: index, with: newDict)
                }
                
            
            
            break
            
        case 3:
            
            //your contact join dub.ly Congrats
            guard let dataArr = data["contacts"] as? NSArray
                else{ return }
            
            for dict in dataArr {
                var dict1:[String:Any] = dict as! [String:Any]
                //new contact added so add in favList
                let localNum = dict1["number"] as! String
//                localNum = String(localNum.dropFirst(4))
                let pridicate = NSPredicate.init(format:"numbers_Str CONTAINS [cd] %@",localNum)
                let arr =   dbContactsArr.filtered(using: pridicate)
                
                if (arr.count > 0){
                    
                    let index = tempContactArr.index(of: arr[0])
                    var profilePic = ""
                    let status = ""
                    var follow = [String : Any]()
                    var followStatus : Int = 0
                    var privicy: Int = 0
                    var firstName: String = ""
                    var lastName: String = ""
                    var userName: String = ""
                    if let pic = dict1["profilePic"] as? String{
                        profilePic = pic
                    }
                    if let follo = dict1["follow"] as? [String : Any]{
                        follow = follo
                    }
                    if let fStatus = dict1["followStatus"] as? Int{
                        followStatus = fStatus
                    }
                    if let priv = dict1["private"] as? Int{
                        privicy = priv
                    }
                    if let first = dict1["firstName"] as? String{
                        firstName = first
                    }
                    if let last = dict1["lastName"] as? String{
                        lastName = last
                    }
                    if let name = dict1["userName"] as? String{
                        userName = name
                    }
                    var newDict = arr[0] as! [String:Any]
                    newDict["isFavorite"] = "isFavorite"
                    newDict["registerNum"] = dict1["number"] as! String
                    newDict["profilePic"] = profilePic
                    newDict["Status"] = status
                    newDict["userID"] = dict1["_id"] as! String
                    newDict["follow"] = follow
                    newDict["followStatus"] = followStatus
                    newDict["private"] = privicy
                    newDict["firstName"] = firstName
                    newDict["lastName"] = lastName
                    newDict["userName"] = userName
                    isChange = true
                    if index < tempContactArr.count{
                        tempContactArr.replaceObject(at: index, with: newDict)
                    } ///put check
                }
                
            }

            
            break
            
        case 4:
            
            guard let dataArr = data["contacts"] as? NSArray
                else{ return }
        
            
            for dict in dataArr {
                var dict1:[String:Any] = dict as! [String:Any]
                //new contact added so add in favList
                let localNum = dict1["number"] as! String
                let pridicate = NSPredicate.init(format:"numbers_Str CONTAINS [cd] %@",localNum)
                let arr = dbContactsArr.filtered(using: pridicate)
                
                if (arr.count > 0){
                    
                    let index = tempContactArr.index(of: arr[0])
                    var profilePic = ""
                    let status = ""
                    var follow = [String : Any]()
                    var followStatus : Int = 0
                    var privicy: Int = 0
                    var firstName: String = ""
                    var lastName: String = ""
                    var userName: String = ""
                    if let pic = dict1["profilePic"] as? String{
                        profilePic = pic
                    }
                    if let follo = dict1["follow"] as? [String : Any]{
                        follow = follo
                    }
                    if let fStatus = dict1["followStatus"] as? Int{
                        followStatus = fStatus
                    }
                    if let priv = dict1["private"] as? Int{
                        privicy = priv
                    }
                    if let first = dict1["firstName"] as? String{
                        firstName = first
                    }
                    if let last = dict1["lastName"] as? String{
                        lastName = last
                    }
                    if let name = dict1["userName"] as? String{
                        userName = name
                    }
                    var newDict = arr[0] as! [String:Any]
                    newDict["isFavorite"] = "isFavorite"
                    newDict["registerNum"] = dict1["number"] as! String
                    newDict["profilePic"] = profilePic
                    newDict["Status"] = status
                    newDict["userID"] = dict1["_id"] as! String
                    newDict["follow"] = follow
                    newDict["followStatus"] = followStatus
                    newDict["private"] = privicy
                    newDict["firstName"] = firstName
                    newDict["lastName"] = lastName
                    newDict["userName"] = userName
                    isChange = true
                    if index < tempContactArr.count{
                        tempContactArr.replaceObject(at: index, with: newDict)} ///put check
                }
                
            }
            
            break
            
        case 5:
            //delete contact response
            
            
            break
            
        case 6:
            //Block user heree
            let couchbaseObj = Couchbase.sharedInstance
            let chatsDocVMObject = ChatsDocumentViewModel.init(couchbase: couchbaseObj)
            var dict1:[String:Any] = data as [String:Any]
            if dict1["initiatorId"] != nil{
                guard let otherUserID = dict1["initiatorId"] as? String else {return}
                guard let isBlock = dict1["blocked"] as? Bool else {return}
                if let chatDocID =  self.getChatdocIdforunsavedUser(reciverID:otherUserID ){
                    chatsDocVMObject.updateUserBlockStatus(toDocID: chatDocID, isBlock: isBlock)
                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: "updateBlockUser"), object: nil, userInfo: ["chatDocID": chatDocID,"isBlock":isBlock])
                }
            }
            break
            
        case 7:
            break
            
        default:
            break
 
        }
        if isChange == true {
            Contacts.updateContactDataInDatabase(database: Couchbase.sharedInstance, contactList: tempContactArr as NSArray)
            let fav = FavoriteViewModel.sharedInstance
            fav.updateData()
        }
    }
    
    func mutePushNotification() {
    }
    
    
    private func getChatdocIdforunsavedUser(reciverID: String) -> String?{
        let individualChatDocVMObject = IndividualChatViewModel(couchbase: Couchbase.sharedInstance)
        guard let chatDocID = individualChatDocVMObject.getChatDocID(withreceiverID: reciverID, andSecretID: "", withContactObj: nil, messageData: nil, destructionTime: nil, isCreatingChat: false) else {
            DDLogDebug("error in creating chatdoc \(self)")
            return nil
        }
        return chatDocID
    }
}
