//
//  KycVerifyAPI.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/15/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Locksmith
import Alamofire

class KycVerifyAPI {
    
    func verifyKyc(ifscCode: String, accountNumber: String, accountHolderName: String,documentType: String,documentNumber: String, documentHolderName: String,documentFrontImage: String,documentBackImage: String, withCallback callback:@escaping (_ verifyUser : [String : Any]? , _ error : CustomErrorStruct?) -> Void){
        
        guard let userId = Utility.getUserid(),let userFullName = Utility.getUserFullName()  else {return}
        guard let phoneNo = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String else {return}
            
        let params : [String:String] = ["ifscCode" : ifscCode, "accountNumber" : accountNumber, "accountHolderName": accountHolderName, "documentName" : documentType, "documentNumber" : documentNumber, "documentHolderName" : documentHolderName, "userId" : userId, "userType": "user", "documentFrontImage": documentFrontImage, "documentBackImage": documentBackImage, "firstName": userFullName, "email": Utility.getUserEmail(),"phoneNo": phoneNo, "userName": Utility.getUserName()]
        
            Helper.showPI()
            let strURL =   AppConstants.userDetail
   
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
                  guard  let token = keyDict["token"] as? String  else {return}
            
            let headers = ["authorization": token, "lan" : Utility.getSelectedLanguegeCode()]
            
            let apicall = RxAlmofireClass()
            apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
            _ = apicall.subject_response.subscribe(onNext: {response in
                Helper.hidePI()
                callback(response,nil)
                DDLogDebug("output here \(response)")
            }, onError: {error in
                Helper.hidePI()
                callback(nil,error as? CustomErrorStruct)
                print(error)
            })
        }
    
    func kycApprovedApi( withCallback callback:@escaping (_ verifyUser : Bool , _ error : CustomErrorStruct?) -> Void){
        
        let strURL = AppConstants.verificationStatus
        
           
                guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
                guard  let token = keyDict["token"] as? String  else {return}
                
                let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
                let params = ["status": "1"]
                let apiCall = RxAlmofireClass()
                apiCall.newtworkRequestAPIcall(serviceName:strURL, requestType: .patch, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
                apiCall.subject_response.subscribe(onNext: {response in
                    print(response)
                    callback(true,nil)
                }, onError: { error in
                    Helper.hidePI()
                    callback(false,error as? CustomErrorStruct)
                })
    }

}
