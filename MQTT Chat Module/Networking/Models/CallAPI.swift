//
//  CallAPI.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 31/10/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import CocoaLumberjack
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire

class CallAPI: NSObject {

    class func sendCallpushtoServer(with paramas: String) {
        
        guard let guestUserStatus = Utility.getIsGuestUser() , !guestUserStatus else{
            return
        }
        
        let strURL = AppConstants.callpush
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        
        guard  let callpush = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.callPushToken) as? String else {return}
        /*
         Bug Name :- IOS push not working after logout and login firsttime
         Fix Date :- 23/03/2021
         Fixed By :- Jayaram G
         Description Of Fix :- pushToken and call Push token was coming nil , so it was returning this function without calling api , removed unwanted msgPush , and passing empty string on "iosVideoCallPush" , "iosMassageCallPush"
         */
//        guard  let msgpush = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.pushToken) else {return}
        print("____CallPushToken \(callpush)")
        let dict = ["iosAudioCallPush": callpush,
                    "iosVideoCallPush":" ",
                    "iosMassageCallPush":" ",
                    "isdevelopment": true,
                    "appName":"dubly"] as [String:Any]
//
//        let dict = [
//                    "iosVideoCallPush":msgpush,
//                    "iosMassageCallPush":msgpush,
//                    "isdevelopment": false] as [String:Any]
        
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: dict ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.iosPush.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            DDLogDebug("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
        })
    
        
    }
    
    class func getCallLogStatus(complication: @escaping ([String:Any]) -> Void){
        //let timeInterVal = UserDefaults.standard.object(forKey:"logInTimeInterval")
        let timestamp = "1507037988572" //"\(String(describing: timeInterVal!))"    //"0"
       
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        let headerParams = ["authorization":basicAuth,
                            "token":token,"timeStamp": "\(timestamp)"]
       
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.callLogs + "?" + "timeStamp=\(timestamp)", requestType: .get, parameters: [:] ,headerParams:HTTPHeaders.init(headerParams), responseType: AppConstants.resposeType.callLogs.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            complication(response)
            DDLogDebug("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
        })
        
    }
    
//mark: Janus CallAPI Class
    let disposeBag = DisposeBag()
    let createCall = PublishSubject<APIResponse>()
    let disconnectCall = PublishSubject<APIResponse>()
    let joinCall = PublishSubject<APIResponse>()
    
    deinit {
        DDLogInfo("CreateCall is being deinitialise")
    }

    func createCall(_ params: [String:Any]) {
        let strUrl = AppConstants.callUrl
//        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
//        guard  let token = keyDict["token"] as? String  else {return}
        guard let token = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.token) as? String else {return}
       
       let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        DDLogInfo("Create Call Users API called")

        RxAlamofire.requestJSON(.post,
                                strUrl,
                                parameters: params,
                                encoding: JSONEncoding.default,
                                headers: HTTPHeaders.init(headers))
            .subscribe(onNext: { (status, response) in
                if let response = response as? [String:Any] {
                    let apiResponse = APIResponse(response, with: status)
                    self.createCall.onNext(apiResponse)
                }
            }, onError: { (error) in
                self.createCall.onError(error)
                DDLogError("Error occurred in Create Call Users API and error is \(error.localizedDescription)")
            }, onDisposed: {
                DDLogInfo("Create Call Users API disposed")
            }).disposed(by: disposeBag)
    }
    
    func disconnectCall(_ params: [String:Any]) {
        let strUrl = AppConstants.callUrl
//        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
//        guard  let token = keyDict["token"] as? String  else {return}
        guard let token = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.token) as? String else {return}

       let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        DDLogInfo("Disconnect Call Users API called")

        RxAlamofire.requestJSON(.delete,
                                strUrl,
                                parameters: params,
                                encoding: URLEncoding.queryString,
                                headers: HTTPHeaders.init(headers))
            .subscribe(onNext: { [weak self] (status, response) in
                guard let self = self else { return }
                if let response = response as? [String:Any] {
                    let apiResponse = APIResponse(response, with: status)
                    self.disconnectCall.onNext(apiResponse)
                }
            }, onError: { (error) in
                self.disconnectCall.onError(error)
                DDLogError("Error occurred in Disconnect Call Users API and error is \(error.localizedDescription)")
            }, onDisposed: {
                DDLogInfo("Disconnect Call Users API disposed")
            }).disposed(by: disposeBag)
    }
    
    func joinCall(_ callId: String) {
        var params = ["callId": callId] as [String: Any]
        if let sessionId = UserDefaults.standard.value(forKey: "sessionId1"){
            params["sessionId"] = "\(sessionId)"
        }
        let strUrl = AppConstants.callUrl//+"/\(callId)"
//        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
//        guard  let token = keyDict["token"] as? String  else {return}
        guard let token = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.token) as? String else {return}
       let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        DDLogInfo("Join Call Users API called")

        RxAlamofire.requestJSON(.put,
                                strUrl,
                                parameters: params,
                                encoding: URLEncoding.queryString,
                                headers: HTTPHeaders.init(headers))
            .subscribe(onNext: { (status, response) in
                if let response = response as? [String:Any] {
                    let apiResponse = APIResponse(response, with: status)
                    self.joinCall.onNext(apiResponse)
                }
            }, onError: { (error) in
                self.joinCall.onError(error)
                DDLogError("Error occurred in Create Call Users API and error is \(error.localizedDescription)")
            }, onDisposed: {
                DDLogInfo("Create Call Users API disposed")
            }).disposed(by: disposeBag)
    }
    
}
