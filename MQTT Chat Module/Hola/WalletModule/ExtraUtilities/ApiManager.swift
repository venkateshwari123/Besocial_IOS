//
//  ApiManager.swift
//  Yelo
//
//  Created by Rahul Sharma on 20/12/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

import UIKit
import Alamofire

class ApiManager{
    
    var invalidStatusCodes = [APIStatusCode.ErrorCode.Unauthorized.rawValue,
                              APIStatusCode.ErrorCode.InvalidToken.rawValue,
                              APIStatusCode.ErrorCode.ExpiredToken.rawValue,
                              APIStatusCode.ErrorCode.NotAcceptable.rawValue]
    //clear local storage and guest login
    func clearKeychainAndGuestLogin(message: String = "Something went wrong"){
        
//        KeychainHelper.sharedInstance.clearKeychain()
//        SplashViewModel().guestLogin()
//        UserProfile.shared.profile = Profile()
//        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
//            Helper.showAlert(head: "Oops", message: message)
//        }
    }
    
    
    var networkAvailability:Bool {
        return Connectivity1.isConnectedToInternet()
    }
    
    
    
    
    
    func getRequest(_ strURL: String, isLoaderEnable : Bool = true , success:@escaping ([String : Any]) -> Void, failure:@escaping (Error) -> Void) {
        if !networkAvailability {return}
        Helper.showPI(string: StringConstants.getInstance().ProgressIndicator(),showLabel: isLoaderEnable)
        let manager = Alamofire.Session.default
        manager.request(strURL,headers: APIUtility.getHeaderForPost()).responseJSON { (responseObject) -> Void in
            Helper.hidePI()
            
            switch responseObject.result{
            case let .success(value):
                
                if let statusCode = responseObject.response?.statusCode, statusCode == 204{
                    success(["statusCode":statusCode])
                }
                
                if var resJson = value as? [String : Any] {
                    
                    if let statusCode = responseObject.response?.statusCode{
                        
                        if self.invalidStatusCodes.contains(statusCode){
                            print(">>>>>>>>>> STATUS CODE - \(statusCode) >>>>>")
                            if let message = resJson["message"] as? String{
                                self.clearKeychainAndGuestLogin(message: message)
                            }else{
                                self.clearKeychainAndGuestLogin()
                            }
                            
                            return
                        }
                        resJson["statusCode"] = statusCode
                    }
                    success(resJson)
                }
            case let .failure(error):
                let error : Error = error
                if let statusCode = responseObject.response?.statusCode{
                    print("ERROR STATUS CODE - \(statusCode)")
                }
                failure(error)
            }
        }
    }
    
    
    
    func postRequest(_ strURL : String,isLoaderEnable : Bool = false, params : [String : Any]?, success:@escaping ([String : Any]) -> Void, failure:@escaping (Error) -> Void) {
        if !networkAvailability {return}
        var header = APIUtility.getHeaderForPost()
        if  header[APIRequestParams.getInstance().Authorization] != "" {
            header =  APIUtility.getHeaderForPost()
        } else{
            header = APIUtility.getGuestHeaders()
        }
        Helper.showPI(string: StringConstants.getInstance().ProgressIndicatorForPosting(),showLabel: isLoaderEnable)
        let manager = Alamofire.Session.default
        manager.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (responseObject) -> Void in
            Helper.hidePI()
            print("Api name \(strURL) with status code \(responseObject.response?.statusCode)")
            switch responseObject.result{
            case let .success(value):
                
                if var resJson = value as? [String : Any] {
                    if let statusCode = responseObject.response?.statusCode{
                        if self.invalidStatusCodes.contains(statusCode){
                            print(">>>>>>>>>> STATUS CODE - \(statusCode) >>>>>")
                            if let message = resJson["message"] as? String{
                                print(message)
                                self.clearKeychainAndGuestLogin(message: message)
                            }else{
                                self.clearKeychainAndGuestLogin()
                            }
                            return
                        }
                        resJson["statusCode"] = statusCode
                    }
                    success(resJson)
                }
            case let .failure(error):
                
                print(">>>>>ApiMangerFail - post>>>>> \(String(describing: responseObject.response?.statusCode))")
                let error = error
                failure(error)
            }
        }
    }
    
    
    
    func patchRequest(_ strURL: String, params : [String:Any]?, success: @escaping([String: Any]) -> Void, failure:@escaping (Error) -> Void){
        if !networkAvailability {return}
        var header = APIUtility.getHeaderForPost()
        if  header[APIRequestParams.getInstance().Authorization] != "" {
            header =  APIUtility.getHeaderForPost()
        } else{
            header = APIUtility.getGuestHeaders()
        }
        let manager = Alamofire.Session.default
        manager.request(strURL, method: .patch,parameters: params, encoding: JSONEncoding.default, headers: header ).responseJSON { (responseObject) in
            
            switch responseObject.result{
            case let .success(value):
                if var resJson = value as? [String : Any] {
                    if let statusCode = responseObject.response?.statusCode{
                        if self.invalidStatusCodes.contains(statusCode){
                            print(">>>>>>>>>> STATUS CODE - \(statusCode) >>>>>")
                            if let message = resJson["message"] as? String{
                                self.clearKeychainAndGuestLogin(message: message)
                            }else{
                                self.clearKeychainAndGuestLogin()
                            }
                            return
                        }
                        resJson["statusCode"] = statusCode
                    }
                    success(resJson)
                }
            case let .failure(error):
                print(">>>>>ApiMangerFail - patch>>>>>")
                let error = error
                failure(error)
            }
        }
    }
    
    
    func deleteRequest(_ strURL: String, params : [String:Any]?, success: @escaping([String: Any]) -> Void, failure:@escaping (Error) -> Void){
        if !networkAvailability {return}
        let manager = Alamofire.Session.default
        manager.request(strURL, method: .delete,parameters: params, encoding: JSONEncoding.default, headers: APIUtility.getHeaderForPost()).responseJSON { (responseObject) in
            
            switch responseObject.result{
            case let .success(value):
                if var resJson = value as? [String : Any] {
                    if let statusCode = responseObject.response?.statusCode{
                        if self.invalidStatusCodes.contains(statusCode){
                            print(">>>>>>>>>> STATUS CODE - \(statusCode) >>>>>")
                            if let message = resJson["message"] as? String{
                                self.clearKeychainAndGuestLogin(message: message)
                            }else{
                                self.clearKeychainAndGuestLogin()
                            }
                            return
                        }
                        resJson["statusCode"] = statusCode
                    }
                    success(resJson)
                }
            case let .failure(error):
                print(">>>>>ApiMangerFail - delete>>>>>")
                let error = error
                failure(error)
            }
        }
    }
}

