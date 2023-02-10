
//
//  BusinessMobileConfigViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 25/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
class BusinessMobileConfigViewModel {
    
    //MARK:- Variables&Declarations
    let businessMobileOtpApi = SocialAPI()
    var mobileNumber:String?
    var countryCode:String?
    
    /// Get Otp, APi Call Via Phone Number
    ///
    /// - Parameters:
    ///   - strUrl: bussinessPhoneVerification string url
    ///   - complitation: complitation handler after compliting service call
    func getMobileOTP(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        let params = ["businessPhone" : mobileNumber as Any,
                      "countryCode" : countryCode as Any] as [String : Any]
        if mobileNumber?.count ?? 1 > 3 && mobileNumber?.count ?? 1 < 16{
            self.businessMobileOtpApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
                print(response as Any)
                if let result = response{
                    complitation(true, error)
                }else if let error = error{
                    print(error.localizedDescription)
//                    Helper.showAlertViewOnWindow(Strings.message.localized, message: error.localizedDescription)
                    complitation(false, error)
                }
            }
        }else {
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterValidPhoneNumber.localized)
        }
    }
 }
