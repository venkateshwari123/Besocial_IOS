//
//  CreateChannelViewModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 14/12/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Locksmith
import Alamofire
class CreateChannelViewModel: NSObject {
    
    let createChannelApi = SocialAPI()
    
    
    /// To create channel
    ///
    /// - Parameters:
    ///   - params: params
    ///   - complitation: After getting service response
    func createChannelService(params: [String : Any], complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let strUlr = AppConstants.channel
        Helper.showPI()
        createChannelApi.postSocialData(with: strUlr, params: params) { (response, error) in
            if let _ = response{
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
                if error.code == 204{
                    complitation(false, error)
                }else{
                    complitation(false, error)
                }
            }
            Helper.hidePI()
        }
    }
    
    
    /// To Edit channel
    ///
    /// - Parameters:
    ///   - params: params
    ///   - complitation: After getting service response
    func editChannelService(channelId: String , params: [String : Any], complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
        
        let headers = [Strings.authorizationKey:/*AppConstants.authorization, "token":*/token, Strings.langKey:Utility.getSelectedLanguegeCode()]
        Helper.showPI(_message: Strings.updating)
//        let strURL = AppConstants.channel + "?channelId=\(channelId)"
        let strURL = AppConstants.channel 
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .put, parameters:params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.profileResponse.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.profileResponse.rawValue {
                    complitation(true,nil)
                }
            }, onError: {error in
                complitation(false,error as? CustomErrorStruct)
                Helper.hidePI()
            })
    }
    
    
    /// Delete Channel Api
    /// - Parameters:
    ///   - channelId: channelId
    ///   - complitation: complitation description
     func deletePostService(channelId: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
           Helper.showPI()
           let url: String = AppConstants.channel + "?channelId=\(channelId)"
           let params = [String : Any]()
           createChannelApi.deleteSocialData(with: url, params: params) { (response, error) in
               if let result = response{
                   print(result)
                   complitation(true, nil)
               }else if let error = error{
                   complitation(false, error)
               }
               Helper.hidePI()
           }
       }
       
}
