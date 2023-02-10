//
//  RxAlmofire.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 06/11/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire
import CocoaLumberjack
import Alamofire
import Locksmith

// MARK: - To call api without making cache of response
class RxAlmofireClass {
    
    let disposebag = DisposeBag()
    let subject_response = PublishSubject<[String:Any]>()
    
    /*
     Feat Name:- handle network check
     Feat Date:- 20/04/21
     Feat By  :- Nikunj C
     Description of Feat:- function checkForReachability return network status
     */
    
    let net = Alamofire.NetworkReachabilityManager(host: "www.apple.com")

    func checkForReachability(completion: @escaping ((Bool) -> ())) {
        
        net?.startListening(onUpdatePerforming: { status in
            switch status {
            case .reachable(.ethernetOrWiFi),.reachable(.cellular):

                Toast.hideMessage()

                print("The network is reachable over the WiFi connection")
                completion(true)
          
            case .notReachable:
                print("The network is not reachable")
                completion(false)
                
            case .unknown:
                completion(false)
            }
        })

    }
    
    func newtworkRequestAPIcall (serviceName:String ,requestType: Alamofire.HTTPMethod  , parameters: [String:Any]?,headerParams: HTTPHeaders,responseType:String){
        var strURL = AppConstants.baseUrl + "/" + serviceName //+
        if serviceName == "https://api.besocial.app/calls" {
            strURL = serviceName
        } else if serviceName == "https://api.besocial.app/languageAPI/?status=1" {
            strURL = serviceName
        }
        else{
            strURL = AppConstants.baseUrl + "/" + serviceName
        }
        
        let manager = Alamofire.Session.default
        var headerWithoutCache = headerParams
        headerWithoutCache.add(HTTPHeader.init(name: "cache-control", value: "no-cache"))
        manager.request(strURL, method: requestType, parameters: parameters, encoding: JSONEncoding.default, headers: headerWithoutCache).responseJSON { (response) in

                print("API NAME \(strURL) Status Code \(response.response?.statusCode ?? 0)////// Parameters \(parameters ?? [:])")
            
            switch response.result{
                
            case let .success(value):
                
                var statuscode:Int = 200
                if let res = response.response{
                    statuscode = res.statusCode
                    print("api name \(serviceName)")
                }
                if  var dict  = value as? [String:Any]{
                    dict[AppConstants.resposeTypeKey] = responseType
                    self.checkResponse(statusCode: statuscode, responseDict: dict ,reposeType: responseType)
                }else{
                    self.checkResponse(statusCode: statuscode, responseDict: [String:Any]() ,reposeType: responseType)
                }

                
            case let .failure(error):
                
                self.subject_response.onError(error)
                DispatchQueue.main.async{
                    if error.localizedDescription == "The Internet connection appears to be offline." || error.localizedDescription == "The request timed out."{
                        DispatchQueue.main.async {
                            Helper.hidePI()
                        }
                    }
                }
                if error.localizedDescription != AppConstants.noInternetMsg {
                    print(error.localizedDescription)
                }
                
            }
            
        }
    }
    
    func newtworkRequestAPIcallForPython(serviceName:String ,requestType: Alamofire.HTTPMethod  , parameters: [String:Any]?,headerParams: HTTPHeaders,responseType:String){
        let strURL = AppConstants.pythonURL +  serviceName
        var headerWithoutCache = headerParams
        headerWithoutCache.add(HTTPHeader.init(name: "cache-control", value: "no-cache"))
        let manager = Alamofire.Session.default
        manager.request(strURL, method: requestType, parameters: parameters, encoding: JSONEncoding.default, headers: headerWithoutCache  ).responseJSON { (response) in
                print("Python API NAME \(strURL) Status Code \(response.response?.statusCode ?? 0) with header\(headerParams)")
       
            switch response.result{
                
            case let .success(value):
                
                var statuscode:Int = 200
                if let res = response.response{
                    statuscode = res.statusCode
                    print("api name \(serviceName)")
                }
                if  var dict  = value as? [String:Any]{
                    dict[AppConstants.resposeTypeKey] = responseType
                    self.checkResponse(statusCode: statuscode, responseDict: dict ,reposeType: responseType)
                }else{
                    self.checkResponse(statusCode: statuscode, responseDict: [String:Any]() ,reposeType: responseType)
                }

                
            case let .failure(error):
                
                self.subject_response.onError(error)
                DispatchQueue.main.async{
                 //   Helper.hidePI()
                }
                if error.localizedDescription != AppConstants.noInternetMsg {
                  //  Helper.showAlertViewOnWindow(serviceName, message: error.localizedDescription)
                    print(error.localizedDescription)
                }
                
            }
                
        }
        
    }
    
    func newtworkRequestAPIcallForStreaming(serviceName:String ,requestType: Alamofire.HTTPMethod  , parameters: [String:Any]?,headerParams: HTTPHeaders,responseType:String){
        let strURL = AppConstants.baseUrl + "/" + serviceName
        var header = APIUtility.getHeaderForPost()
        
        let manager = Alamofire.Session.default
        var headerWithoutCache = headerParams
        headerWithoutCache.add(HTTPHeader.init(name: "cache-control", value: "no-cache"))
        manager.request(strURL, method: requestType, parameters: parameters, encoding: requestType == .get ? URLEncoding.queryString : JSONEncoding.default, headers: headerWithoutCache).responseJSON { (response) in
            
            print("Stream API NAME \(strURL) Status Code \(response.response?.statusCode ?? 0)")
            switch response.result{
                
            case let .success(value):
                
                var statuscode:Int = 200
                if let res = response.response{
                    statuscode = res.statusCode
                    print("api name \(serviceName)")
                }
                if  var dict  = value as? [String:Any]{
                    dict[AppConstants.resposeTypeKey] = responseType
                    self.checkResponse(statusCode: statuscode, responseDict: dict ,reposeType: responseType)
                }else{
                    self.checkResponse(statusCode: statuscode, responseDict: [String:Any]() ,reposeType: responseType)
                }

                
            case let .failure(error):
                
                self.subject_response.onError(error)
                DispatchQueue.main.async{
                    Helper.hidePI()
                }
                if error.localizedDescription != AppConstants.noInternetMsg {
                        Helper.showAlertViewOnWindow(serviceName, message: error.localizedDescription)
                }
                
            }
                
        }
    }
    
    
    /* Bug Name :- Handle Backend errors
     Fix Date :- 09/06/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Showing alert messages for backend error
     */
    
    func checkResponse(statusCode:Int,responseDict: [String:Any],reposeType:String){
        switch statusCode {
        case 200...203:
            self.subject_response.onNext(responseDict)
            break
        case 137:
            if let message = responseDict["message"] as? String {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                Helper.showAlertViewOnWindow(Strings.error.localized, message: "You have entered same phone number 3 or more times".localized + ". " + "Please try a new number".localized)
                self.subject_response.onError(customError)
            }
        case 105:
            DDLogDebug("No data is there")
        case 138:
            if let message = responseDict["message"] as? String {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                Helper.showAlertViewOnWindow(Strings.error.localized, message: message)
                self.subject_response.onError(customError)
            }
        case 139:
            Helper.showAlertViewOnWindow(Strings.error.localized, message: responseDict["message"] as! String)
            self.subject_response.onError(NSError.init(domain: "", code: statusCode, userInfo: ["message": responseDict["message"] as! String]))
            
        case 140:
            
            Helper.showAlertViewOnWindow(Strings.error.localized, message: "Abuse of device".localized)
            self.subject_response.onError(NSError.init(domain: "", code: statusCode, userInfo: ["message": responseDict["message"] as! String]))
            
        case 204:
            //            Helper.showAlertViewOnWindow(Strings.error.localized, message: responseDict["message"] as! String)
            //            self.subject_response.onError(NSError(domain: "", code: statusCode, userInfo: ["message":responseDict["message"] as! String]))
            let error = CustomErrorStruct(localizedTitle: Strings.error.localized, localizedDescription: "No data", code: 204)
            self.subject_response.onError(error)
        case 205..<300:
            if let message = responseDict["message"] as? String, message != "" {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                Helper.showAlertViewOnWindow(Strings.error.localized, message: message)
                self.subject_response.onError(customError)
            }
        case 400:
            
            if let message = responseDict["message"] as? String, message != "" {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
//                Helper.showAlert(head: "Error", message: message)
                self.subject_response.onError(customError)
            }
        case 401:
            Utility.logOut()
            self.subject_response.onError(NSError())
            DDLogDebug("session Expired")
        case 403:
            if let message = responseDict["message"] as? String, message != "", message != "INSUFFICIENT BALANCE" {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                DispatchQueue.main.async {
                    Helper.showAlert(head: "Error", message: message)
                }
                self.subject_response.onError(customError)
            }else{
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: "403 Status Code", code: statusCode)
                self.subject_response.onError(customError)
            }
        case 404:
            if let message = responseDict["message"] as? String, message != "", message != "Data you have requsted is Not Found." {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                DispatchQueue.main.async {
                    Helper.showAlert(head: "Error", message: message)
                }
                self.subject_response.onError(customError)
            }else{
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: "404 Status Code", code: statusCode)
                self.subject_response.onError(customError)
            }
           
        case 405:
            Helper.hidePI()
            if  let resposeDict = responseDict["message"] as? String, resposeDict != ""{
                Helper.showAlertViewOnWindow(" ", message: resposeDict)
            }else{
                self.subject_response.onNext(responseDict)
            }
            
        case 406 :
            
          DDLogDebug("No data is there")
                       Helper.hidePI()
            if reposeType != "accessToken" {
                self.refreshTokenAPI()
            }
        case 409 :
            Helper.hidePI()
            if  let resposeDict = responseDict["message"] as? String, resposeDict != ""{
                if resposeDict != "duplicate".localized && resposeDict != "You don't have sufficient balance to make payment".localized{
                    Helper.showAlertViewOnWindow("Error".localized, message: resposeDict)
                }
            }
        case 412:
            if let message = responseDict["message"] as? String, message != "" {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                self.subject_response.onError(customError)
            }
            DDLogDebug("No data is there")
        case 413:
            if let message = responseDict["message"] as? String, message != "" {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                self.subject_response.onError(customError)
            }
        case 414:
            if let message = responseDict["message"] as? String, message != "" {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                self.subject_response.onError(customError)
            }
        case 422 :
            if let message = responseDict["message"] as? String, message != "" {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                self.subject_response.onError(customError)
            }
            Helper.hidePI()
        case 440:
            Helper.showAlertViewOnWindow(Strings.error.localized, message: "session Expired".localized)
            self.subject_response.onError(NSError())
            DDLogDebug("session Expired")
        case 300..<440:
            
            if reposeType == AppConstants.resposeType.leaveGroupAPI.rawValue{
                if  let resposeDict = responseDict["message"] as? String{
                    Helper.showAlertViewOnWindow("Oops".localized, message: resposeDict)
                }
            }
            if reposeType == AppConstants.resposeType.profileResponse.rawValue{
                if  let resposeDict = responseDict["message"] as? String{
                    Helper.showAlertViewOnWindow("Message", message: resposeDict)
                    
                }
            }
            var message = ""
            if let msg = responseDict["message"]as? String{
                message = msg
            }else if let msg = responseDict["detail"] as? String{
                message = msg
            }
            self.subject_response.onError(NSError(domain: "", code: statusCode, userInfo: ["message":message]))
            
            
        case 500..<600:
            if let message = responseDict["message"] as? String {
                let customError = CustomErrorStruct.init(localizedTitle: "", localizedDescription: message, code: statusCode)
                Helper.showAlert(head: "\(statusCode)", message: message)
                self.subject_response.onError(customError)
            }
            
//            if  let resposeDict = responseDict["message"] as? String{
//                Helper.showAlertViewOnWindow("Error", message: resposeDict)
//            }
            
        default:
            DDLogDebug("default code \(statusCode)")
        }
    }
    
     func refreshTokenAPI() {
            guard  let refreshToken = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.refreshToken) as? String else {return}
            
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict["token"] as? String  else {return}
            
            let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode(),"refreshtoken": refreshToken]
    //        let params = [] as [String:Any]
            self.newtworkRequestAPIcall(serviceName: AppConstants.refreshUserToken, requestType: .get, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.refreshToken.rawValue)
            self.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                guard let responseDict = dict["data"] as? [String : Any] else {return}
                do{
                    try Locksmith.deleteDataForUserAccount(userAccount: AppConstants.keyChainAccount)
                }
                catch{
                    DDLogDebug("error handel it")
                }
                guard let token = responseDict["accessToken"] as? String else {return}
                do{
                    try Locksmith.saveData(data: ["token":token], forUserAccount: AppConstants.keyChainAccount)
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isTokenRefreshed)
                }catch{
                    DDLogDebug("error handel it")
                }
                
                 print(responseDict)
             }, onError: {error in
                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isTokenRefreshed)
                Helper.hidePI()
            })
        }
}




