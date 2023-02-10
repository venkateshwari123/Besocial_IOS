//
//  UpdateEmailPhoneViewModel.swift
//  Do Chat
//
//  Created by Rahul Sharma on 19/05/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
class UpdateEmailPhoneViewModel: NSObject {

    func sendOTP(updateType : FiledVerificationType, email : String? = nil, phoneNumber : String? = nil, countryCode : String? = nil ,isForBusiness : Bool = false , callback : @escaping (Bool,String)->())  {
        
        var url = ""
        var params  : [String : Any ] = ["type" : updateType.rawValue]
        
        /*
         Feat Name:- for normal user should show verified label
         Feat Date:- 10/07/21
         Feat By  :- Nikunj C
         Description of Fix:- add url and params for normal user also
         */
        
        if isForBusiness{
            url =  AppConstants.businessEmailPhoneSend
            if updateType == .email
            {
                params = ["type":1,"email":email ?? ""]
            }
            else
            {
                params = ["type":2,"mobile":phoneNumber ?? "","countryCode":countryCode ?? ""]
            }
        }else{
            url =  AppConstants.profileEmailPhoneSend
            if updateType == .email
            {
                params = ["type":1,"email":email ?? ""]
                
            }
            else
            {
                params = ["type":2,"mobile":phoneNumber ?? "","countryCode":countryCode ?? ""]
            }
        }
        
        
        /*
         Bug Name:- when try to update email it logout
         Fix Date:- 15/05/21
         Fixed By:- Nikunj C
         Description of Fix:- change header details
         */
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
        
        let headers = [Strings.authorizationKey:token,
                       Strings.langKey:Utility.getSelectedLanguegeCode()] as [String: String]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .post, parameters: params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.requestChangeNumber.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                guard  let data = dict["data"] as? [ String : Any] else {
                    callback(false,"")
                    return
                }
                let otpId = data["otpId"] as? String
                callback(true, otpId ?? "")
            }, onError: {error in
                //                DDLogDebug("\(error)")
                print(error.localizedDescription)
                callback(false,error.localizedDescription)
                Helper.hidePI()
            })
        
    }
    
    /*
     Feat Name:- for normal user should show verified label
     Feat Date:- 10/07/21
     Feat By  :- Nikunj C
     Description of Fix:- use rxalamofire class instead of APIManager & sendOtp call for normal user
     */
    
    func  verifyBusinessPhoneOTP(phoneNumber : String, countryCode : String, otpId : String, otpCode : String,  callback : @escaping (Bool,String)->()) {
        let url =  AppConstants.businessEmailPhoneVerify
        var param  : [String : Any ] = ["type" : 2]
        param["otpId"] = otpId
        param["otpCode"] = otpCode
        param["mobile"] = phoneNumber
        param["countryCode"] = countryCode
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
        
        let headers = [Strings.authorizationKey:token,
                       Strings.langKey:Utility.getSelectedLanguegeCode()] as [String: String]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .post, parameters: param,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.requestChangeNumber.rawValue)
        
        apiCall.subject_response
            .subscribe(onNext: {dict in

                callback(true, "")
            }, onError: {error in
                //                DDLogDebug("\(error)")
                print(error.localizedDescription)
                callback(false,error.localizedDescription)
                Helper.hidePI()
            })
        
    }
    
    func  verifyNormalUserPhoneOTP(phoneNumber : String, countryCode : String, otpId : String, otpCode : String,  callback : @escaping (Bool,String)->()) {
        let url =  AppConstants.profileEmailPhoneVerify
        var param  : [String : Any ] = ["type" : 2]
        param["otpId"] = otpId
        param["otpCode"] = otpCode
        param["mobile"] = phoneNumber
        param["countryCode"] = countryCode
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
        
        let headers = [Strings.authorizationKey:token,
                       Strings.langKey:Utility.getSelectedLanguegeCode()] as [String: String]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .post, parameters: param,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.requestChangeNumber.rawValue)
        
        apiCall.subject_response
            .subscribe(onNext: {dict in
                callback(true, "")
            }, onError: {error in
                //                DDLogDebug("\(error)")
                print(error.localizedDescription)
                callback(false,error.localizedDescription)
                Helper.hidePI()
            })
    }
    
    func verifyOTP(updateType : FiledVerificationType, otpId : String, otpCode : String, email : String? = nil, phoneNumber : String? = nil, countryCode : String? = nil , callback : @escaping (String?,String?)->() )
    {
        var url = ""
        var param  : [String : Any ] = ["type" : updateType.rawValue]
        param["otpId"] = otpId
        param["otpCode"] = otpCode
        if updateType == .email
        {
              param["email"] = email
            url = AppConstants.constantURL + AppConstants.verifyOTPByEmail
        }
        else
        {
            param["mobile"] = phoneNumber!
            param["countryCode"] = countryCode!
            url = AppConstants.constantURL + AppConstants.verifyOTP
        }
        
      
        
        APIManager.networkService(url: url, params: param, header: Helper.getDefaultHeader(), method: .post, showLoader: true) { (data) in
            
            if let error = data.error,error != .success,error != .created, let errorMessage = APIManager.getErrorMessage(data:data.data ){
                callback(nil,errorMessage)
                return
            }
            
            do{
                if let dictionary = try JSONSerialization.jsonObject(with: data.data, options: []) as? [String: Any], let errorMessage = dictionary["message"] as? String {
                    callback(errorMessage,nil)
                    
                }
            }catch{
                callback(nil,error.localizedDescription)
            }
            
          

        } failure: { (error) in
            callback(nil,error.localizedDescription)
        }
    }
    
    func updateProfile(params:[String:Any],complite: @escaping (([String:Any]) -> Void)){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token, "lang":Utility.getSelectedLanguegeCode()]
       
        let strURL = AppConstants.profile
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .patch, parameters:params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.profileResponse.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                print(dict)
                /*
                 Bug Name:- Profile not updating immediately
                 Fix Date:- 09/07/21
                 Fixed By:- Jayaram G
                 Description of Fix:- Setting flag true to update data
                 */
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.profileUpdate)
               complite(dict)
            }, onError: {error in
                print(error.localizedDescription)
                Helper.hidePI()
            })
    }
    
}
