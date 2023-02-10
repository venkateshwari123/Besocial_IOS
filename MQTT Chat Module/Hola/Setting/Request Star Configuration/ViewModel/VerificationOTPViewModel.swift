//
//  VerificationOTPViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 11/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import Foundation
class VerificationOTPViewModel: NSObject {
    
    //MARK:- Variables&Declarations
    let emailVerifyOtpApi = SocialAPI()
    let mobileVerifyOtpApi = SocialAPI()
    var email:String?
    var emailOtp:String?
    var mobileOtp:String?
    var mobileNumber:String?
    var countryCode:String?
    
    
    /// Verifying Email OTP
    ///
    /// - Parameters:
    ///   - strUrl: verifyOTPByEmail url String
    ///   - complitation: complitation handler after compliting service call
    func verifyEmailOTP(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let params = ["email" : self.email as Any,
                      "otp" : emailOtp as Any] as [String : Any]
        if Helper.isValidEmail(emailText: self.email ?? ""){
            self.emailVerifyOtpApi.postSocialDataWithBasicAuth(with: strUrl, params: params as [String : Any]) { (response, error) in
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
    
    
    /// Verifying OTP StarUserEmailID
    ///
    /// - Parameters:
    ///   - strUrl: verifyEmail url string
    ///   - email: user Entered email
    ///   - otp: received OTP
    ///   - isVisible: isVisible true / invisible false
    ///   - complitation: complitation handler after compliting service call
    func verifyStarEmailID(strUrl: String, email : String, otp : String, isVisible : Bool, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let params = ["starUserEmailId" : email,
                      "otp" : otp,
                      "isVisible":isVisible] as [String : Any]
        
        if Helper.isValidEmail(emailText: email){
            self.emailVerifyOtpApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
                print(response as Any)
                if response != nil{
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
    
    func verifyEmailID(strUrl: String, email : String, otp : String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let params = ["email" : email,
                      "otp" : otp
                      ] as [String : Any]
        
        if Helper.isValidEmail(emailText: email){
            self.emailVerifyOtpApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
                print(response as Any)
                if response != nil{
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
    
    
    /// Verifying Mobile OTP
    ///
    /// - Parameters:
    ///   - strUrl: verifyOTP url String
    ///   - complitation: complitation handler after compliting service call
    func verifyMobileOTP(strUrl: String,isVisible: Bool, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return}
        let deviceName = UIDevice.current.name
        let deviceOs = UIDevice.current.systemVersion
        guard let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else {return}
        let modelNumber = UIDevice.modelName
        let params = ["countryCode" : countryCode as Any,
                      "phoneNumber" : mobileNumber as Any,
                      "deviceId" : deviceID as Any,
                      "otp" : mobileOtp as Any,
                      "deviceName" : deviceName as Any,
                      "deviceOs" : deviceOs as Any,
                      "modelNumber" : modelNumber as Any,
                      "deviceType" : "1" as Any,
                      "appVersion" : appVersion as Any,
                      "isVisible" : isVisible,
                      "type": 2] as [String : Any]
        if mobileOtp != nil {
            self.mobileVerifyOtpApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
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
            Helper.hidePI()
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterOtp)
        }
    }
    
    
    /// Verify StarUserNumber OTP
    ///
    /// - Parameters:
    ///   - strUrl: verifyStarNumber url string
    ///   - complitation: complitation handler after compliting service call
    func verifyStarNumerOTP(strUrl: String, isVisible : Bool, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        
        let params = ["countryCode" : countryCode as Any,
                      "numberWithOutCountryCode" : mobileNumber as Any,
                      "otp" : mobileOtp as Any,
                      "isVisible": isVisible
                      ] as [String : Any]
        if mobileOtp != nil {
            self.mobileVerifyOtpApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
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
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterOtp)
        }
        
    }
}
