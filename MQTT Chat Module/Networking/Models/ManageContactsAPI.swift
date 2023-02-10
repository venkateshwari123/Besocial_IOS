//
//  ManageContactsAPI.swift
//  Starchat
//
//  Created by 3Embed on 01/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaLumberjack
import Alamofire

class ManageContactsAPI: NSObject {
    
    func getFollowees(withCallback callback:@escaping (_ loginData : [UserProfile]? , _ error : CustomErrorStruct?) -> Void){
        let params : [String:Any] = [:]
        Helper.showPI()
        let strURL =   AppConstants.getFollowees+"?\("userId=\(Utility.getLoggedInUserProfile()?.userId ?? "")")&limit=1000"
        
        let headers = ["Authorization":Utility.getUserToken(),"lang":Utility.getSelectedLanguegeCode(),"Content-Type":"application/json"] as [String: String]
        
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil , headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            guard let userData = response["data"] as? [[String:Any]] else { return }
            var arrContacts : [UserProfile] = []
            userData.forEach({ (objContact) in
                arrContacts.append(UserProfile.init(modelData: objContact))
            })
            print(userData)
            callback(arrContacts,nil)
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
    }

    
    
    func getFriendsListApi(searchtext:String,withCallback callback:@escaping (_ loginData : [UserProfile]? , _ error : CustomErrorStruct?) -> Void){
         // Helper.showPI()
        var strURL:String = ""
        if searchtext != "" {
         strURL =   AppConstants.friend + "?searchtext=\(searchtext)&offset=0&limit=1000"
        }else {
            strURL = AppConstants.friend + "?offset=0&limit=1000"
        }
        
        
        let headers = ["Authorization":Utility.getUserToken(),"lang":Utility.getSelectedLanguegeCode(),"Content-Type":"application/json"] as [String: String]

        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
         apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil , headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
         _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            guard let userData = response["data"] as? [[String:Any]] else { return }
            var arrContacts : [UserProfile] = []
            userData.forEach({ (objContact) in
                arrContacts.append(UserProfile.init(modelData: objContact))
            })
            print(userData)
            callback(arrContacts,nil)
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
    }
    
    
    
    func getFriendsRequestListApi(withCallback callback:@escaping (_ loginData : [UserProfile]? , _ error : CustomErrorStruct?) -> Void){
        let params : [String:Any] = [:]
        Helper.showPI()
        let strURL =   AppConstants.friendRequest + "?searchtext=nil&offset=0&limit=1000"
        
        let headers = ["Authorization":Utility.getUserToken(),"lang":Utility.getSelectedLanguegeCode(),"Content-Type":"application/json"] as [String: String]
        
        let apicall = RxAlmofireClass()
         apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
         apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil , headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
         _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            guard let userData = response["data"] as? [[String:Any]] else { return }
            var arrContacts : [UserProfile] = []
            userData.forEach({ (objContact) in
                arrContacts.append(UserProfile.init(modelData: objContact))
            })
            print(userData)
            callback(arrContacts,nil)
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
    }
}
