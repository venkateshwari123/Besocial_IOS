//
//  ContactAPI.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 31/10/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Locksmith
import CocoaLumberjack
import Alamofire

class ContactAPI: NSObject {
    
    class func deleteContacts(with params:[String:Any]) {
        let strurl = AppConstants.getContacts
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForPython(serviceName: strurl, requestType: .delete, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getContactResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
        })
    }
    
    class func sendmodifiedContactsToserver(with params:[String:Any]){
        let strURL =   AppConstants.getContacts
       
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token]

        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForPython(serviceName: strURL, requestType: .put, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getContactResponse.rawValue)
            apiCall.subject_response.subscribe(onNext: {response in
                    DDLogDebug("output here \(response)")
            }, onError: {error in
                Helper.hidePI()
            })
    }
    
    class func sendAllContactsToserver(with params: [String : Any]?) {
        let strURL = AppConstants.getContacts
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForPython(serviceName: strURL, requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getContactResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
//            print("output here \(dict)")
            ContactAPI.gotUserContacts(withData: dict)
        }, onError: {error in
            Helper.hidePI()
        })
    }
    
    
    private class func gotUserContacts(withData data: [String : Any]) {
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        if documentID !=  nil{
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        
        guard let dataArr = data["contacts"] as? NSArray
            else{
                Helper.hidePI()
            Helper.showAlertViewOnWindow("Oops".localized, message: "No Contacts found in".localized + " \(AppConstants.AppName) " + "app".localized + ".")
                return
        }
        if dataArr.count == 0{
            Helper.hidePI()
            Helper.showAlertViewOnWindow("Oops".localized, message: "No Contacts found in".localized + " \(AppConstants.AppName) app".localized + ".")
            return
        }
        print("Contact list: \(dataArr)")
        
        let tempContactArr = dbContactsArr.mutableCopy() as! NSMutableArray
        var isChange = false
        
        for dict in dataArr {
            
            var dict1: [String:Any] = dict as! [String : Any]
            var localNumber = String()
            if let localNum = dict1["number"] as? String{
                localNumber = localNum
            }
            let pridicate = NSPredicate.init(format:"numbers_Str CONTAINS [cd] %@",localNumber)
            let arr =   dbContactsArr.filtered(using: pridicate)
            
            if (arr.count > 0){
                DDLogDebug("***************")
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
        
        if isChange == true{
            Contacts.updateContactDataInDatabase(database: Couchbase.sharedInstance, contactList: tempContactArr as NSArray)
            let fav = FavoriteViewModel.sharedInstance
            fav.updateData()
        }
        
        
        DDLogDebug("contactSync unsubscribe here")
        guard let userID = Utility.getUserid() else { return }
//        let contacSync = AppConstants.MQTT.contactSync+userID
//        MQTT.sharedInstance.unsubscribeTopic(topic: contacSync)
        
        
        //subscribe UserUpdate
        let updateSunc = AppConstants.MQTT.userUpdates + userID
        MQTT.sharedInstance.subscribeTopic(withTopicName: updateSunc, withDelivering: .atLeastOnce)
        
    }
    
    
    class func followAndUnfollowService(with isFollow: Bool, followingId: String, privicy: Int){
        
        var params = [String:Any]()
        var strURL: String = ""
        if isFollow{
            strURL = AppConstants.follow 
            params = ["followingId" : followingId]
        }else{
            strURL = AppConstants.unfollow
         params = ["followingId" : followingId]
         }

        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getContactResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshingPosts"), object: nil)
            
            //
        }, onError: {error in
            Helper.hidePI()
        })
        ContactAPI.updateFollowStatusInDatabase(userId: followingId, isFollow: isFollow, privicy: privicy)
    }
    
    
    /// To update user follow status in contact database
    ///
    /// - Parameters:
    ///   - contact: contact to update status
    ///   - isFollow: follow or unfollow status
    private class func updateFollowStatusInDatabase(userId: String, isFollow: Bool, privicy: Int){
        
        guard let _ = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String else{return}
//        var dbContactsArr = NSArray()
        let dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray

        let tempContactArr = dbContactsArr.mutableCopy() as! NSMutableArray
        let pridicate = NSPredicate.init(format:"userID CONTAINS [cd] %@",userId)
        var arr = dbContactsArr.filtered(using: pridicate)
        if arr.count>0{
            let index = tempContactArr.index(of: arr[0])
            var newDict = arr[0] as! [String:Any]
            if isFollow{
                if privicy == 1{
                    newDict["follow"] = ["message" : " requested to follow", "type" : 2]
                }else{
                    newDict["follow"] = ["message" : " started following", "type" : 1]
                }
            }else{
                newDict["follow"] = ["message" : "not following", "type" : 0]
            }
            if index < tempContactArr.count{
                tempContactArr.replaceObject(at: index, with: newDict)} ///put check
            Contacts.updateContactDataInDatabase(database: Couchbase.sharedInstance, contactList: tempContactArr as NSArray)
        }
    }
    
    class func followAllContacts(with params: [String : Any]?){
        
        let strURL = AppConstants.followAll
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getContactResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
        }, onError: {error in
            Helper.hidePI()
        })
    }
    
    class func  likeAndUnlike(strURL: String, with params: [String : Any]?,complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getContactResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            complitation(true,nil)
        }, onError: {error in
            complitation(false,error as? CustomErrorStruct)
            Helper.hidePI()
        })
    }
}

