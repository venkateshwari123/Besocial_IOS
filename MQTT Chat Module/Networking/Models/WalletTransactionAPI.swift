//
//  WalletTransactionAPI.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 02/04/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//


import UIKit
import RxCocoa
import RxSwift
import Locksmith
import Alamofire

class WalletTransactionAPI: NSObject {
    
    override init() {
        super.init()
    }
    
    //Get Transction Data Api
    func getTransctionData(withURL strURL: String,params: [String:Any]?, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
     
        let urlString = strURL
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        print(token)
        
        let headers = ["authorization":token,
                       "lan": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: urlString, requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            guard let dataArray = dict["data"] else {return}
            complitation(dataArray,nil)
        }, onError: {error in
             
            complitation(nil,error as? CustomErrorStruct)
        })
    }

    //Get Wallet Data And Blance Api
    func getWalletData(withURL strURL: String,params: [String:Any]?, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
       // let params = [String : Any]()
       // let urlString = strURL.replace(target: " ", withString: "%20")
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        print(token)
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here:- \(dict)")
            guard let dataArray = dict["data"] else {return}
            complitation(dataArray,nil)
        }, onError: {error in
             
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    //Get Payment Method
    func getPaymentMethod(withURL strURL: String,params: [String:Any]?, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
       // let params = [String : Any]()
       // let urlString = strURL.replace(target: " ", withString: "%20")
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        print(token)
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here:- \(dict)")
            guard let dataArray = dict["data"] else {return}
            complitation(dataArray,nil)
        }, onError: {error in
             
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    
    ///Post service call
      func postPasswordData(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
          guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}

        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
          let headers = ["authorization":"\(basicAuth)","lang": Utility.getSelectedLanguegeCode(),"token":"\(basicAuth)"]
          
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
    
    
    ///Post service call
    func transferMoneyApi(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            guard let dataArray = response["data"] else {return}
            complitation(dataArray, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
}
