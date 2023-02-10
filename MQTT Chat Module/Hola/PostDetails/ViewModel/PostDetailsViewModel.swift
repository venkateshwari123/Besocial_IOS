//
//  PostDetailsViewModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 15/11/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class PostDetailsViewModel: NSObject {

    let postDetaiApi = SocialAPI()
    var socialModelArray = [SocialModel]()
    var storyModelArray = [StoryModel]()
    var followersFolloweeModelArray = [FollowersFolloweeModel]()
    var reportReasonArray = [String]()
    var channelViewModelArray = [ProfileChannelModel]()
    var offset: Int = 0
    let limit = 20
    let couchbase = Couchbase.sharedInstance
    
    /// To mark that this user saw the post
    ///
    /// - Parameter postId: post id of this post
    func viewPostApi(for index: Int){
        var data = self.socialModelArray[index]
        if data.isViewed{
            return
        }
        data.isViewed = true
        self.socialModelArray[index] = data
        let url: String = AppConstants.post + "?postId=\(data.postId ?? "")"
        postDetaiApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [String : Any]{
                print(result)
            }else if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    
    func getHomeServiceData(finished: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        var strURl = AppConstants.home + "?offset=\(offset)&limit=\(limit)"
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            strURl = AppConstants.guestUserAPI + "?offset=\(offset)&limit=\(limit)"
        }
        postDetaiApi.getSocialData(withURL: strURl, params: nil) { (modelArray, customError) in
            if let modelData = modelArray as? [Any]{
                print(modelData)
                self.createModelArray(dataArray: modelData)
                let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                finished(true, nil, canServiceCall)
            }
            if let error = customError{
                if error.code == 204{
                    if self.offset == 0{
                        self.socialModelArray.removeAll()
                    }
                    finished(true, error, false)
                }else{
                    finished(true, error, true)
                }
            }
        }
    }
    
    
    func createModelArray(dataArray: [Any]){
        if offset == 0{
            socialModelArray.removeAll()
        }
        for modelData in dataArray{
            if let data = modelData as? [String : Any]{
                let socialData = SocialModel(modelData: data)
                socialModelArray.append(socialData)
            }
        }
    }
    
    
    
    
    /// To like and unlike a post
    ///
    /// - Parameters:
    ///   - index: index of that post in social model array
    ///   - isSelected: if already selected then unlike and if not then like
    func likeAndUnlikeService(index: Int, isSelected: Bool,complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let data = self.socialModelArray[index]
        var strUrl: String = AppConstants.like
        if isSelected{
            strUrl = AppConstants.unlike
        }
        guard let userID = Utility.getUserid() else { return }
        let params = ["userId" : userID,
                      "postId" : data.postId]
        ContactAPI.likeAndUnlike(strURL: strUrl, with: params, complitation: {(success, error) in
            if success{
               complitation(true,nil)
            }else{
//                Helper.showAlertViewOnWindow("Message".localized, message: (error?.localizedDescription))
                complitation(false,error as? CustomErrorStruct)
            }
        })
    }
    
    func followAndUnFollowUserService(index: Int, isSelected: Bool){
        let data = self.socialModelArray[index]
//        var strUrl: String = AppConstants.follow
//        if isSelected{
//            strUrl = AppConstants.unfollow
//        }
        let peopleId = data.userId!
        ContactAPI.followAndUnfollowService(with: !isSelected, followingId: peopleId, privicy: 0)
    }
    
    
    
    /// To get report reasons
    ///
    /// - Parameter complitation: complitation handler after getting response
    func getReportReasonsService(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let url: String = AppConstants.reportReasons
        postDetaiApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [String]{
                print(result)
                self.reportReasonArray = result
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error)
            }
            Helper.hidePI()
        }
    }
    
    /// To report a post
    ///
    /// - Parameters:
    ///   - reasonIndex: reason of report
    ///   - postIndex: index of post in report reason array
    ///   - complitation: complitation handler to handle response
    func postReportReasonService(postId:String,reasonIndex: Int, postIndex: Int, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let url: String = AppConstants.reportReasons
        if self.reportReasonArray.count > reasonIndex && postIndex > -1{
            let reason = self.reportReasonArray[reasonIndex]
            
            let params = ["postId" : postId,
                          "reason": reason,
                          "message" : reason]
            
            postDetaiApi.postSocialData(with: url, params: params) { (response, error) in
                if let result = response{
                    print(result)
                    complitation(true, nil)
                }else if let error = error{
                    print(error.localizedDescription)
                    complitation(false, error)
                }
                Helper.hidePI()
            }
        }else{
            Helper.hidePI()
            complitation(false, nil)
        }
    }
    
    
    /// To get post response from post id
    ///
    /// - Parameters:
    ///   - postId: post id
    ///   - complitation: complitation handler after getting response
    func getPostDetailsService(postId: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let url: String = AppConstants.post + "?postId=\(postId)"
        postDetaiApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [String : Any]{
                print(result)
                let socialData = SocialModel(modelData: result)
                self.socialModelArray.append(socialData)
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error)
            }
            Helper.hidePI()
        }
    }
    
    func deletePostService(postId: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let url: String = AppConstants.post + "?postId=\(postId)"
        let params = [String : Any]()
        postDetaiApi.deleteSocialData(with: url, params: params) { (response, error) in
            if let result = response{
                print(result)
                complitation(true, nil)
            }else if let error = error{
                complitation(false, error)
            }
            Helper.hidePI()
        }
    }
    
    
    /// To get followersFollowing array data
    func followFollowingServiceCall(){
        let url = AppConstants.followersFollowee + "?skip=0&limit=\(limit)"
        postDetaiApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setfollowersDataInModel(modelArray: result)
            }else if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    
    /// To set data in followersFollowes data received from service call
    ///
    /// - Parameter modelArray: data array to set in model
    func setfollowersDataInModel(modelArray: [Any]){
        Utility.storeFollowListInDatabase(couchbase: couchbase, modelArray: modelArray)
        for data in modelArray{
            guard let dict = data as? [String : Any] else{continue}
            let followModel = FollowersFolloweeModel(modelData: dict)
            self.followersFolloweeModelArray.append(followModel)
        }
    }
}
