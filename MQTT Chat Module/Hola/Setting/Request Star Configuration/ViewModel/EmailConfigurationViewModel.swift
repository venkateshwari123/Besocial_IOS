//
//  EmailConfigurationViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 11/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import Foundation
class EmailConfigurationViewModel: NSObject {
    
    //MARK:- Variables&Declarations
    let emailConfigApi = SocialAPI()
    var email:String?
    
    
    /// Requesting OTP API Call
    ///
    /// - Parameters:
    ///   - strUrl: requestEmailVerification string url
    ///   - type:  for starUserEmail verification type = 2 / for User email verification type = 1
    ///   - complitation: complitation handler after compliting service call
    func requestOtpCall(strUrl: String,type : Int, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let params = ["starUserEmailId" : self.email,
                      "type" : type] as [String : Any]
        if Helper.isValidEmail(emailText: self.email ?? ""){
            self.emailConfigApi.postSocialDataWithBasicAuth(with: strUrl, params: params as [String : Any]) { (response, error) in
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
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterValidEmail.localized)
        }
    }
}
