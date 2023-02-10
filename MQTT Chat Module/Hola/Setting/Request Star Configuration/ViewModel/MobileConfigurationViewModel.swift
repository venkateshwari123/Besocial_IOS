//
//  MobileConfigurationVmObject.swift
//  Starchat
//
//  Created by Rahul Sharma on 11/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
class MobileConfigurationViewModel: NSObject {
    
    //MARK:- Variables&Verification
    let mobileConfigApi = SocialAPI()
    var mobileNumber:String?
    var countryCode:String?
    let api = LoginAPI()
    var didUpdateAny : (([String : Any]) -> Void)?
    var didError: ((CustomErrorStruct) -> Void)?
    
    
    /// Requesting For OTP Via Mobilenumber
    ///
    /// - Parameters:
    ///   - strUrl: requestMobileVerification url String
    ///   - complitation: complitation handler after compliting service call
    func requestMobileOtpCall(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        let params = ["phoneNumber" : mobileNumber ?? "" as Any,
                      "countryCode" : countryCode as Any,
                      "deviceId" : deviceID,
                      "development" : false,
                      "type" : 2] as [String : Any]
        
        if mobileNumber?.count ?? 1 > 6{
            self.mobileConfigApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
                print(response as Any)
                if let result = response{
                    complitation(true, error)
                }else if let error = error{
                    print(error.localizedDescription)
                    Helper.showAlertViewOnWindow(Strings.message.localized, message: error.localizedDescription)
                    complitation(false, error)
                }
            }
        }else {
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterValidPhoneNumber.localized)
        }
    }
    
    /*
     Feat Name:- check is phone number exist
     Feat Date:- 19/04/21
     Feat   By:- Nikunj c
     Description of Feat:- check is entered number exist 
     */
    // is isValidmobileNumberOtp
    func isValidmobileNumberOtp(number : String, andcountryCode countryCode : String) {
     
        self.api.checkingMobileNumberOTP(number: number, andcountryCode: countryCode) { (objLogin, error) in
            if let loginObj = objLogin {
                if let didUpdate = self.didUpdateAny {
                    didUpdate(loginObj)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
}
