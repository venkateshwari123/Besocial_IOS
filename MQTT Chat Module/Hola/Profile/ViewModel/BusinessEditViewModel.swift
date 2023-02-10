//
//  BusinessEditViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation

class BusinessEditViewModel: NSObject  {
    
    
    /// declarations
    let  businessEditApi = SocialAPI()
    var businessMobileNumber:String?
    var businessCountryCode:String?
    
    
    
    /// Get Mobile Otp Api call
    ///
    /// - Parameters:
    ///   - strUrl: strUrl description
    ///   - complitation: completion handler
    func getMobileOtp(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let params  = ["businessPhone" : businessMobileNumber as Any,
                       Strings.countryCode : businessCountryCode as Any] as [String:Any]
        businessEditApi.postSocialData(with: strUrl, params: params) { (response, customError) in
            print(response as Any)
            if let result = response{
                complitation(true, customError)
            }else if let error = customError{
                print(error.localizedDescription)
                Helper.showAlertViewOnWindow(Strings.message.localized, message: error.localizedDescription)
                complitation(false, error)
            }
        }
        }
    }
    

