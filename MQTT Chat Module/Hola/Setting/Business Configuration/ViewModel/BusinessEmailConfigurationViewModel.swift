//
//  BusinessEmailConfigurationViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 25/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:-  Jayaram G

import Foundation
class BusinessEmailConfigurationViewModel {
    
    //MARK:- Variables&Declarations
    let businessEmailOtpApi = SocialAPI()
    var email:String?
    
    /// Get Otp Via Email
    ///
    /// - Parameters:
    ///   - strUrl: bussinessEmailVerification  string Url
    ///   - complitation: complitation handler after compliting service call
    func getEmailOtp(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        if Helper.isValidEmail(emailText: self.email ?? ""){
            let params = ["bussinessEmailId" : self.email! as Any,
                ] as [String : Any]
            self.businessEmailOtpApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
                print(response as Any)
                if let result = response{
                    complitation(true, error)
                }else if let error = error{
                    print(error.localizedDescription)
//                    Helper.showAlertViewOnWindow(Strings.message.localized, message: error.localizedDescription)
                    complitation(false, error)
                    
                }
            }
        }
        else{
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterValidEmail.localized)
        }
    }
}
