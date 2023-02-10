//
//  WithdrawMoneyApi.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/21/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import Foundation
import Locksmith
import Alamofire

class WithdrawMoneyApi {
    
    func getBankFieldsApi(withURL strURL: String,complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
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
    
    func getBankApi(withURL strURL: String,complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
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
    
   
    func postBankApi(with strURL: String,params: [String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
           guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
           guard  let token = keyDict["token"] as? String  else {return}
           
           let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
          
           let apiCall = RxAlmofireClass()
           apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
           apiCall.subject_response.subscribe(onNext: {response in
               print(response)
               complitation(response, nil)
           }, onError: { error in
               Helper.hidePI()
               complitation(nil,error as? CustomErrorStruct)
           })
       }
    
    func postWithdrawMoneyApi(with strURL: String,params: [String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
       
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }

}
