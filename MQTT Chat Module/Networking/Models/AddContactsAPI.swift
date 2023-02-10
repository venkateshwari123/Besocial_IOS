//
//  AddContactsAPI.swift
//  Starchat
//
//  Created by 3Embed on 14/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import CocoaLumberjack
import Locksmith
import Alamofire

class AddContactsAPI: NSObject {

    func getContactsList(withContacts contacts : [[String : Any]], withCallback callback:@escaping (_ loginData : [UserProfile]? , _ error : CustomErrorStruct?) -> Void) {
        
        let params : [String:Any] = ["contacts":contacts]
        DispatchQueue.main.async {
            Helper.showPI(_message: " " + "Syncing contacts".localized + "... ")
        }
        let strURL =   "contactSync/"
        
        let headers = ["Authorization":Utility.getUserToken(),"lang":Utility.getSelectedLanguegeCode(),"Content-Type":"application/json"] as [String: String]
        
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcallForPython(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            guard let userData = response["contacts"] as? [[String:Any]] else { return }
            var arrContacts : [UserProfile] = []
            userData.forEach({ (objContact) in
                arrContacts.append(UserProfile.init(modelData: objContact))
            })
            print(userData)
            callback(arrContacts,nil)
        }, onError: {error in
//            Helper.hidePI()
             callback(nil,error as? CustomErrorStruct)
        })
    }
    
    func follow(_ userId : String, url : String, withCallback callback: @escaping (_ dict : [String : Any]?, _ error : CustomErrorStruct?) -> Void){
        let params : [String:Any] = ["targetUserId": "\(userId)"]
        
        Helper.showPI()
        let strURL =    url
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["Authorization":token ,"lang":Utility.getSelectedLanguegeCode(),"Content-Type":"application/json"] as [String: String]
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            callback(response,nil)
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
        
    }
    
    func sendRequest(_ userId : String, message : String, withCallback callback: @escaping (_ dict : [String : Any]?, _ error : CustomErrorStruct?) -> Void){
        
        let params : [String:Any] = ["targetUserId":userId,"message":message]
        
        Helper.showPI()
        let strURL =   AppConstants.friend
        
        let headers = ["Authorization":Utility.getUserToken(),"lang":Utility.getSelectedLanguegeCode(),"Content-Type":"application/json"] as [String: String]
        
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            callback(response,nil)
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
    }
    
}
