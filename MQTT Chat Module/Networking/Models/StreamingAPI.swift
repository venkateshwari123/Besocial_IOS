//
//  StreamingAPI.swift
//  Starchat
//
//  Created by Rahul Sharma on 20/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire

class StreamingAPI: NSObject {

    override init() {
        super.init()
    }
    
    func streamGetServiceCall(withURL strURL: String, param: [String : Any]?, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForStreaming(serviceName: strURL, requestType: .get, parameters: param ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            guard let dataArray = dict["data"] else {return}
            complitation(dataArray,nil)
        }, onError: {error in
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    func sereamPostServiceCall(withURL strURL: String, params: [String : Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()/*,"token":token*/]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForStreaming(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    func sereamPutServiceCall(withURL strURL: String, params: [String : Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()/*,"token":token*/]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForStreaming(serviceName: strURL, requestType: .put, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    func getStreamStats(withURL strURL: String, params: [String : Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForStreaming(serviceName: strURL+"?streamId=\(params["streamId"] ?? "")", requestType: .get, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    func endStream(withURL strURL: String, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForStreaming(serviceName: strURL, requestType: .delete, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    func walletGetServiceCall(withURL strURL: String, param: [String : Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForStreaming(serviceName: strURL, requestType: .get, parameters: param ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            guard let dataArray = dict["data"] else {return}
            complitation(dataArray,nil)
        }, onError: {error in
            complitation(nil,error as? CustomErrorStruct)
        })
    }
}
