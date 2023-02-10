//
//  UpdateProfileApi.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 27/11/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Locksmith
import Alamofire


class UpdateProfileApi: NSObject {
    
    
    class func updateUserProfile(params: [String:Any], complite: @escaping (([String:Any]) -> Void) )  {
//        DispatchQueue.main.async {
//         Helper.showPI(_message: "Updating...")
//        }
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token, "lang":"en"]
       
        let strURL = AppConstants.profile
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .put, parameters:params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.profileResponse.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                print(dict)
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.profileResponse.rawValue {
                    complite(dict)
                }
            }, onError: {error in
//                Helper.showAlertViewOnWindow("Message", message: String)
                Helper.hidePI()
            })
    }
    
    
    /*
     Bug Name:- updated pic create new image everytime in cloudinary
     Fix Date:- 05/04/21
     Fixed By:- Nikunj C
     Description of Fix:- calling cloudinarySignature api
     */
    
    class func getCloudinarySignature(params: [String:String], complite: @escaping(_ data: Any?,_ error: CustomErrorStruct?) -> Void ){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token, "lang":"en"]
        
        let strURL = AppConstants.signature
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.profileResponse.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                if let dataArray = dict["data"] {
                    complite(dataArray,nil)
                }else{
                    complite(dict,nil)
                }
            }, onError: {error in
//                Helper.showAlertViewOnWindow("Message", message: String)
                complite(nil,error as? CustomErrorStruct)
                Helper.hidePI()
            })
    }
    
    class func updateStatus(status : String, complite: @escaping (([String:Any]) -> Void) ){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":AppConstants.authorization, "token":token]
        Helper.showPI(_message: "Updating...")
        let strURL = AppConstants.updateStatus
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .put, parameters:["socialStatus": status],headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.statusResponse.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.statusResponse.rawValue {
                    complite(dict)
                }
            }, onError: {error in
                Helper.hidePI()
            })
        
        
    }
     
    
    class func updateVisibleMobileNumber(params: [String:Any], complite: @escaping (([String:Any]) -> Void) )  {
        Helper.showPI()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token, "lang":"en"]
        Helper.showPI(_message: "Updating...")
        let strURL = AppConstants.businessRequest
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .put, parameters:params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.profileResponse.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.profileResponse.rawValue {
                    complite(dict)
                }
            }, onError: {error in
                //                Helper.showAlertViewOnWindow("Message", message: String)
                Helper.hidePI()
            })
    }
}
