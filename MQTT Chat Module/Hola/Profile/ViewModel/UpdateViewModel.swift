//
//  UpdateViewModel.swift
//  Do Chat
//
//  Created by rahul on 06/02/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
enum FiledVerificationType : Int {
    case email = 1
    case phoneNumber
    case businessPhone
    case businessEmail
}


class UpdateViewModel: NSObject {

    
    
    //
    func sendOTP(updateType : FiledVerificationType, email : String? = nil, phoneNumber : String? = nil, countryCode : String? = nil , callback : @escaping (OtpId?,String?)->())  {
        
        var url = ""
        var headers = ["":""]
        var param  = [String : Any ]()
        if updateType == .email
        {
            param["starUserEmailId"] = email
            param["type"] = updateType.rawValue
            url = AppConstants.constantURL + AppConstants.requestEmailVerification
            var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
            basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
            basicAuth = "Basic \(basicAuth)"
            headers = ["Authorization": "\(basicAuth)"]
        }else if updateType == .businessPhone {
            param["mobile"] = phoneNumber!
            param["countryCode"] = countryCode!
            param["type"] = 2
            url = AppConstants.constantURL + AppConstants.businessEmailPhoneSend
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
            
            headers = [Strings.authorizationKey:token,
                           Strings.langKey:Utility.getSelectedLanguegeCode()] as [String: String]
        }else if updateType == .businessEmail{
            param["email"] = email
            param["type"] = 1
            url = AppConstants.constantURL + AppConstants.businessEmailPhoneSend
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
            
            headers = [Strings.authorizationKey:token,
                           Strings.langKey:Utility.getSelectedLanguegeCode()] as [String: String]
        }else{
            param["mobile"] = phoneNumber!
            param["countryCode"] = countryCode!
            param["type"] = updateType.rawValue
            url = AppConstants.constantURL + AppConstants.requestOTP
            var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
            basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
            basicAuth = "Basic \(basicAuth)"
            headers = ["Authorization": "\(basicAuth)"]
        }
        
        /*
         Bug Name:- when try to update email it logout
         Fix Date:- 15/05/21
         Fixed By:- Nikunj C
         Description of Fix:- change header details
         */
        
       
        
        APIManager.networkService(url: url, params: param, header: headers, method: .post, showLoader: true) { (data) in
            
            if let error = data.error,error != .success,error != .created, let errorMessage = APIManager.getErrorMessage(data:data.data ){
                callback(nil,errorMessage)
                return
            }
            do{
                let otpData =  try JSONDecoder().decode(PhoneLogin.self, from: data.data)
                callback(otpData.data,nil)
                return
            }catch {
                callback(nil,nil)
            }

        } failure: { (error) in
            callback(nil,error.localizedDescription)
        }

        
    }
    
    
    
    func verifyOTP(updateType : FiledVerificationType, otpId : String, otpCode : String, email : String? = nil, phoneNumber : String? = nil, countryCode : String? = nil , callback : @escaping (String?,String?)->() )
    {
        var url = ""
        var param  = [String : Any ]()
        var headers = ["":""]
        param["otpId"] = otpId
        param["otpCode"] = otpCode
        if updateType == .email
        {
              param["email"] = email
            param["type"] = updateType.rawValue
            url = AppConstants.constantURL + AppConstants.verifyOTPByEmail
            headers = Helper.getDefaultHeader()
        }else if updateType == .businessPhone {
            param["mobile"] = phoneNumber!
            param["countryCode"] = countryCode!
            param["type"] = 2
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
            
            headers = [Strings.authorizationKey:token,
                           Strings.langKey:Utility.getSelectedLanguegeCode()] as [String: String]
          url = AppConstants.constantURL + AppConstants.businessEmailPhoneVerify
        }else
        {
            param["mobile"] = phoneNumber!
            param["countryCode"] = countryCode!
            param["type"] = updateType.rawValue
            headers = Helper.getDefaultHeader()
            url = AppConstants.constantURL + AppConstants.verifyOTP
        }
        
      
        
        APIManager.networkService(url: url, params: param, header: headers, method: .post, showLoader: true) { (data) in
            
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
    
    
    func changePassword(oldPassword : String, newPassword: String,  callback : @escaping (String?,String?)->())
    {
        let url = "\(AppConstants.constantURL)resetPassword"
        
        let param : [String : Any] = [ "newPassword": newPassword,
                                       "oldPassword": oldPassword,
                                        "resetType": 1,
                                        "logoutAfterChange": 1
                                    ]
        APIManager.networkService(url: url, params: param, header: Helper.getHeaderWithAuthorization(), method: .post, showLoader: true) { (data) in
            
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
}
