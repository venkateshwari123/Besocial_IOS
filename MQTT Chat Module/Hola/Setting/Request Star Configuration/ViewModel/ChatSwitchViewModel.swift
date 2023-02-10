//
//  ChatSwitchViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 13/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
import Locksmith
import Alamofire
class ChatSwitchViewModel{
    
    
func chatStatusChangingApiCall(strUrl: String,status: Bool, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        let params = ["isChatVisible": status as Any,
                      ] as [String:Any]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName:strUrl, requestType: .patch, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            Helper.hidePI()
            complitation(true,nil)
        }, onError: { error in
            complitation(false,error as? CustomErrorStruct)
            Helper.hidePI()
        })
    }




func businessChatStatusChangingApiCall(strUrl: String,status: Bool, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
    Helper.showPI()
    guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
    guard  let token = keyDict["token"] as? String  else {return}
    
    let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
    let params = ["isChatVisible": status as Any,
        ] as [String:Any]
    let apiCall = RxAlmofireClass()
    apiCall.newtworkRequestAPIcall(serviceName:strUrl, requestType: .patch, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
    apiCall.subject_response.subscribe(onNext: {response in
        print(response)
        Helper.hidePI()
        complitation(true,nil)
    }, onError: { error in
        complitation(false,error as? CustomErrorStruct)
        Helper.hidePI()
    })
}
}
