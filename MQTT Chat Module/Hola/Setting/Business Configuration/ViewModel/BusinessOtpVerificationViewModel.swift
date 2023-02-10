//
//  BusinessOtpVerificationViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 25/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author1:- Jayaram G

import Foundation
class BusinessOtpVerificationViewModel {
    
    //MARK:- Variables&Declarations
    let businessEmailVerifyOtpApi = SocialAPI()
    let businessMobileVerifyOtpApi = SocialAPI()
    var email:String?
    var emailOtp:String?
    var mobileOtp:String?
    var mobileNumber:String?
    var countryCode:String?
    
    
    /// Verifying Email Otp
    ///
    /// - Parameters:
    ///   - strUrl: bussinessEmailOptVerify string url
    ///   - complitation: complitation handler after compliting service call
    func verifyBusinessEmailOTP(strUrl: String,isVisible :Bool, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let params = ["bussinessEmailId" : self.email as Any,
                      "otp" : emailOtp as Any,
                      "isVisible": isVisible] as [String : Any]
        if Helper.isValidEmail(emailText: self.email ?? ""){
            self.businessEmailVerifyOtpApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
                print(response as Any)
                if let result = response{
                    complitation(true, error)
                }else if let error = error{
                    print(error.localizedDescription)
                    Helper.showAlertViewOnWindow(Strings.message.localized, message: error.localizedDescription)
                    complitation(false, error)
                }
            }
        }
        else{
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.somethingWentWrong.localized)
        }
    }
    
    /// Verifying Mobile Number Otp
    ///
    /// - Parameters:
    ///   - strUrl: bussinessPhoneOptVerify string url
    ///   - complitation: complitation handler after compliting service call
    func verifyBusinessMobileOTP(strUrl: String , isVisibleMobile: Bool, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let params = ["businessPhone" : mobileNumber as Any,
                      "countryCode" : countryCode as Any,
                      "otp" : mobileOtp as Any,
                      "isVisible":isVisibleMobile] as [String : Any]
        if mobileOtp != nil {
            self.businessMobileVerifyOtpApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
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
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterOtp.localized)
        }
        
    }
    
}
