//
//  WithdrawApi.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/20/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import Foundation
import Locksmith
import Alamofire
class WithdrawApi {
    
       func getWithdrawLogs(withURL strURL: String,params: [String:Any]?, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
         // let params = [String : Any]()
          let urlString = strURL.replace(target: " ", withString: "%20")
          guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
          guard  let token = keyDict["token"] as? String  else {return}
          print(token)
          
          let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
          let apiCall = RxAlmofireClass()
          apiCall.newtworkRequestAPIcall(serviceName: urlString, requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
          apiCall.subject_response.subscribe(onNext: {dict in
              print("output here \(dict)")
              complitation(dict,nil)
          }, onError: {error in
               
              complitation(nil,error as? CustomErrorStruct)
          })
      }
}
