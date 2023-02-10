//
//  StoryAPI.swift
//  dub.ly
//
//  Created by Shivansh on 11/20/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Locksmith
import Alamofire

class StoryAPI: NSObject {
    
    
    override init() {
        super.init()
    }
    
    
    //Get service call
    func getAllStories(withURL strURL: String, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
   
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            guard let dataArray = dict["data"] else {return}
            complitation(dataArray,nil)
        }, onError: {error in
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    
    //Post service call for python apis
    func deleteStory(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .delete, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.postTrendingResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    //Post service call for python apis
    func postNewStory(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.postTrendingResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }

    
}
