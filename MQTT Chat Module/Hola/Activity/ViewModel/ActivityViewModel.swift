//
//  ActivityViewModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit


/// To define type of following
///
/// - Following: Followin type
/// - Follow: follow type
enum ActivityType {
    case Following
    case Follow
}


/// To define follow request type
///
/// - user: if user requested
/// - channel: if requested for channel
enum FollowRequestType{
    case user
    case channel
}

class ActivityViewModel: NSObject {

    let activityApi = SocialAPI()
    var followingOffset: Int = -20
    var youOffset: Int = -20
    let limit = 20
    
    var followingArray = [Any]()
    var followArray = [Any]()
    var followRequestArray  = [FollowRequestModel]()
    var channelRequestArray = [RequestedChannelModel]()
    var followUserCount: Int = 0
    var followChannelCount: Int = 0
    
    ///  service call for follow and following according to type of table view
    ///
    /// - Parameters:
    ///   - activityType: type of table view
    ///   - complitation: complitation handler after response first: success of fail, second: error, third: it can again service call or not
    func getFollowingService(activityType: ActivityType, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        
        let strUrl: String = getStrUlr(type: activityType)
        
        activityApi.getSocialData(withURL: strUrl, params: [:]) { (modelArray, customError) in
            if let modelData = modelArray as? [Any]{
                print(modelData)
                switch activityType{
                case .Following:
                    self.setFollowingModelData(dataArray: modelData)
                case .Follow:
                    self.setFollowModelData(dataArray: modelData)
                }
                let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }
            if let error = customError{
                if error.code == 204{
                    switch activityType{
                    
                    /*Bug Name :- placeHolder image missing
                      Fix Date :- 22/03/2021
                      Fixed By :- Nikunj C
                      Description Of fix :- make array blank according to activityType*/
                    
                    case .Following:
                        self.setFollowingModelData(dataArray: [])
                    case .Follow:
                        self.setFollowModelData(dataArray: [])
                    }
                    complitation(true, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }
    
    
    /// To get url string according to table view
    ///
    /// - Parameter type: type of table view
    /// - Returns: string url
    func getStrUlr(type: ActivityType)-> String{
        switch type {
        case .Following:
            self.followingOffset = self.followingOffset + 20
            return AppConstants.followingActivity + "?offset=\(followingOffset)&limit=\(limit)"
        case .Follow:
            self.youOffset = self.youOffset + 20
            return AppConstants.activity + "?offset=\(youOffset)&limit=\(limit)"
        }
    }
    
    
    /// To set data in following model
    ///
    /// - Parameter dataArray: data array to set in following model array
    func setFollowingModelData(dataArray: [Any]){
        if self.followingOffset == 0{
            self.followingArray.removeAll()
        }
        for dict in dataArray{
            guard let dictData = dict as? [String : Any] else {continue}
            if let type = dictData["type"] as? Int{
                if type == 3{
                    let activityModel = ActivityFollowModel(modelData: dictData)
                    self.followingArray.append(activityModel)
                }else if type == 2 || type == 5 || type == 1{
                    let activityModel = ActivityCommentModel(modelData: dictData)
                    self.followingArray.append(activityModel)
                }
            }
        }
    }
    
    /// To set data in follow model
    ///
    /// - Parameter dataArray: data array to set in follow model array
    func setFollowModelData(dataArray: [Any]){
        if self.youOffset == 0{
            self.followArray.removeAll()
        }
        for dict in dataArray{
            guard let dictData = dict as? [String : Any] else {continue}
            if let type = dictData["type"] as? Int{
                if type == 3{
                    let activityModel = ActivityFollowModel(modelData: dictData)
                    self.followArray.append(activityModel)
                    /*Bug Name :- Not showing payments in activity
                     Fix Date :- 19/07/2021
                     Fixed By :- Jayaram G
                     Description Of fix :- added type 10
                     */
                   }else if type == 2 || type == 5 || type == 1 || type == 10 || type == 7 || type == 8 || type == 9 || type == 4{
                    let activityModel = ActivityCommentModel(modelData: dictData)
                    self.followArray.append(activityModel)
                }
            }
        }
    }
    
    
    /// To get request data from user
    ///
    /// - Parameters:
    ///   - strUrl: string url for request
    ///   - complitation: complitation first: success and second: error
    func getRequestServiceCall(strUrl: String, requestType: FollowRequestType, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        
        activityApi.getSocialData(withURL: strUrl, params: [:]) { (response, error) in
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
                self.channelRequestArray.removeAll()
//            }
            for dict in response{
                guard let requestData = dict as? [String : Any] else {continue}
                let requestChannelModel = RequestedChannelModel(modelData: requestData)
                self.channelRequestArray.append(requestChannelModel)
            }
            if self.channelRequestArray.count > 0{
                self.followChannelCount = 1
            }else{
                self.followChannelCount = 0
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
            if self.followRequestArray.count > 0{
                self.followUserCount = 1
            }else{
                self.followUserCount = 0
            }
            break
        }
    }
    
    
    //MARK:- follow and unfollow update database and Service call
    
    /// To update user follow status in database and server
    ///
    /// - Parameters:
    ///   - contact: contact to be updated
    ///   - isFollow: follow or unfollow
    func FollowPeopleService(isFollow: Bool, peopleId: String, privicy: Int){
        ContactAPI.followAndUnfollowService(with: isFollow, followingId: peopleId, privicy: privicy)
    }

    
}
