//
//  BlockedUsersViewModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 19/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//  Author:- Jayaram
import UIKit
class BlockedUsersViewModel: NSObject {

    //MARK:- variables&Declarations
    let blockedUserApi = SocialAPI()  // Used to get the SocialAPI Object
    var blockedModelArray = [BlockedUserModel]()  // Used To Store the array of  BlockedUserModel
    var offset: Int = -20          // used to store the offset value in api parameter
    let limit: Int = 20            // used to store the limit value in api parameter
    
    
    /// To get all comments
    ///
    /// - Parameters:
    ///   - strUrl: comment string url
    ///   - complitation: complitation handler after compliting service call
    func getBlockedUsersServiceCall(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        offset = offset + 20
        let url = strUrl + "?offset=\(offset)&limit=\(limit)"
        blockedUserApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setBolckedUserModelData(modelData: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error, true)
            }
            Helper.hidePI()
        }
    }
    
    
    /// To set the Blocked User Data
    ///
    /// - Parameter modelData: modelData array of ANY
    func setBolckedUserModelData(modelData: [Any]){
        if offset == 0{
            self.blockedModelArray.removeAll()
        }
        for data in modelData{
            guard let dict = data as? [String : Any] else{continue}
            let blockedModel = BlockedUserModel(modelData: dict)
            self.blockedModelArray.append(blockedModel)
        }
    }
    
    
    /// For unblocking the User
    ///
    /// - Parameter strUrl: unblock url String
    func postUnblockUser(strUrl: String,params: [String:Any]){
        blockedUserApi.postSocialData(with: strUrl, params: params) { (response, error) in
            if let result = response{
                print(result)
            }else if let error = error{
                print(error.localizedDescription)
            }
        }
        
    }
}
