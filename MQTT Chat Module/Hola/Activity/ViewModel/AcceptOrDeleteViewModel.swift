//
//  AcceptOrDeleteViewModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 13/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class AcceptOrDeleteViewModel: NSObject {

    let acceptOrDeleteApi = SocialAPI()
    
    var requestedChannleArray = [RequestedChannelModel]()
    var followRequestArray = [FollowRequestModel]()
    
    /// To get request data from user
    ///
    /// - Parameters:
    ///   - strUrl: string url for request
    ///   - complitation: complitation first: success and second: error
    func getRequestServiceCall(strUrl: String, requestType: FollowRequestType, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        
        
        acceptOrDeleteApi.getSocialData(withURL: strUrl, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setDataInRequestsArray(response: result, requestType: requestType)
                complitation(true, nil)
            }else if let error = error{
                if error.code == 204{
                    self.setDataInRequestsArray(response: [], requestType: requestType)
                    complitation(true, error)
                }else{
                    complitation(false, error)
                }
            }
            Helper.hidePI()
        }
    }
    ///TO set data in follow user and follow channle array acoording to response
    func setDataInRequestsArray(response: [Any], requestType: FollowRequestType){
        
        switch requestType {
        case .channel:
            //            if self.youOffset == 0{
            self.requestedChannleArray.removeAll()
            //            }
            for dict in response{
                guard let requestData = dict as? [String : Any] else {continue}
                let requestChannelModel = RequestedChannelModel(modelData: requestData)
                self.requestedChannleArray.append(requestChannelModel)
            }
            
            break
        case .user:
            //            if self.youOffset == 0{
            self.followRequestArray.removeAll()
            //            }
            for dict in response{
                guard let requestData = dict as? [String : Any] else {continue}
                let followRequestModel = FollowRequestModel(modelData: requestData)
                self.followRequestArray.append(followRequestModel)
            }
            
            break
        }
    }

    ///To accept or delete user request
    func acceptOrDeleteUserRequest(status: Bool, targetId: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let strUrl = AppConstants.followRequest
        let statusId = status ? 1 : 0
        let params: [String : Any] = ["status":statusId,
                                      "targetId":targetId]
        acceptOrDeleteApi.postSocialData(with: strUrl, params: params) { (response, error) in
            if let result = response{
                print(result)
                complitation(true, nil)
            }else{
                complitation(false, error)
            }
        }
    }
    
    //To accept or delete channel request
    func acceptOrDeleteChannelRequest(channelData: RequestedChannelModel, isAccepted: Bool, row: Int, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let strUrl = AppConstants.RequestedChannels
        let channelId = channelData.requestChannelId!
        let userId = channelData.requestedUserList[row].requestId!
        let params: [String : Any] = ["userId":userId,
                                      "isAccepted":isAccepted,
                                      "channelId":channelId]
        
        acceptOrDeleteApi.putSocialData(with: strUrl, params: params) { (response, error) in
            if let result = response{
                print(result)
                complitation(true, nil)
            }else{
                complitation(false, error)
            }
        }
    }
}
