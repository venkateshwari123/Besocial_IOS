//
//  checkPasswordApi.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/21/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import Foundation
import Locksmith
import Alamofire
class CheckPasswordApi {
     
    func checkPasswordApi(password: String, withCallback callback:@escaping (_ verifyUser : [String : Any]? , _ error : CustomErrorStruct?) -> Void){
         
        let strUrl = AppConstants.appPassword
        let params : [String:String] = ["password" : password]
         
             Helper.showPI()
    
             guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
                   guard  let token = keyDict["token"] as? String  else {return}
             
             
             let headers = ["authorization": token, "lang" : Utility.getSelectedLanguegeCode()]
             
             let apicall = RxAlmofireClass()
             apicall.newtworkRequestAPIcall(serviceName: strUrl, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
             _ = apicall.subject_response.subscribe(onNext: {response in
                 Helper.hidePI()
                 callback(response,nil)
//                 DDLogDebug("output here \(response)")
                print(response)
             }, onError: {error in
                 Helper.hidePI()
                 callback(nil,error as? CustomErrorStruct)
                 print(error)
             })
         }
}
