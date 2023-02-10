//
//  SocialViewModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 27/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

enum StoryType {
    case myStory
    case otherStory
}

class SocialViewModel: NSObject {

    let socialApi = SocialAPI()
    var socialModelArray = [SocialModel]()
    var followersFolloweeModelArray = [FollowersFolloweeModel]()
    var myStories:userStory = userStory(storiesDetails:[:])
    var recentStories:[userStory] = []
    var viewedStories:[userStory] = []
    var popularUserArray = [PopularUserModel]()
    let verificationApi = VerificationAPI()
    var kycverify = KycVerifyAPI()
    var verificationModel : VerificationModel?
    
    var offset: Int = -20
    let limit: Int = 20
    var myStoryOffset = -20
    var otherStoryOffset = -20
    var couchbase = Couchbase.sharedInstance
    
    //MARK:- Init model
    override init() {
        super.init()
    }
    
    func socialModelArrayCount() -> Int {
        return self.socialModelArray.count
    }
    
    func getHomeServiceData(finished: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        
        offset = offset + 20
        /*
         Refactor Name:- add randomScore params in guest post api
         Refactor Date:- 19/04/21
         Refacotr By  :- Nikunj C
         Description of Refactor:- add randomScore params in guest post api
         */
        var randomScore = 0
        if let randomValue = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.randomScore)as? Int{
            randomScore = randomValue
        }else {
            randomScore = Int.random(in: 0..<1000000000)
        }
        var strURl = AppConstants.home + "?offset=\(offset)&limit=\(limit)"
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            strURl = AppConstants.guestUserAPI + "?offset=\(offset)&limit=\(limit)" + "&randomScore=\(randomScore)"
            let trendingApi = TrendingAPI()
            trendingApi.postTrendingData(with: strURl) { (modelArray, customError) in
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
        }else{
            socialApi.getSocialData(withURL: strURl, params: nil) { (modelArray, customError) in
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
    
    func followFollowingServiceCall(strUrl: String){
        let url = strUrl + "?skip=0&limit=\(limit)"
        socialApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setfollowersDataInModel(modelArray: result)
            }else if let error = error{
                DispatchQueue.main.async{
                    Helper.hidePI()
                }
                print(error.localizedDescription)
            }
        }
    }
    
    
    func getPopularUserService(complitation: @escaping([PopularUserModel], CustomErrorStruct?)->Void){
        guard let userId = Utility.getUserid() else { return }
        let strUrl = AppConstants.popularUser
        let url = strUrl + "?" + "userId=\(userId)&set=0&skip=0"
        TrendingAPI().postTrendingData(with: url) { (response, error) in
            if let modelData = response as? [Any]{
                self.createModelArrayPopularUser(dataArray: modelData)
                complitation(self.popularUserArray, nil)
            }else{
                complitation(self.popularUserArray, error)
                }
        }
                Helper.hidePI()
            }
    
    func createModelArrayPopularUser(dataArray: [Any]){
        self.popularUserArray.removeAll()
        for modelData in dataArray{
            if let data = modelData as? [String : Any]{
                let popularUserData = PopularUserModel(modelData: data)
                popularUserArray.append(popularUserData)
                
            }
        }
    }
    
    
    /// To set follow user details in model
    ///
    /// - Parameter modelArray: follow user list
    func setfollowersDataInModel(modelArray: [Any]){
        self.followersFolloweeModelArray.removeAll()
        Utility.storeFollowListInDatabase(couchbase: couchbase, modelArray: modelArray)
        for data in modelArray{
            guard let dict = data as? [String : Any] else{continue}
            let followModel = FollowersFolloweeModel(modelData: dict)
            self.followersFolloweeModelArray.append(followModel)
        }
    }
    
    
    /// To like and unlike a post
    ///
    /// - Parameters:
    ///   - index: index of that post in social model array
    ///   - isSelected: if already selected then unlike and if not then like
    func likeAndUnlikeService(index: Int, isSelected: Bool,complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        if index >= self.socialModelArray.count{
            return
        }
        let data = self.socialModelArray[index]
        var strUrl: String = AppConstants.like
        if isSelected{
            strUrl = AppConstants.unlike
        }
        guard let userID = Utility.getUserid() else { return }
        let params = ["userId" : userID,
                      "postId": data.postId]
        ContactAPI.likeAndUnlike(strURL: strUrl, with: params, complitation: {(success, error) in
            if success{
                complitation(true,nil)
            }else{
//                Helper.showAlertViewOnWindow("Message".localized, message: (error?.localizedDescription)!)
                complitation(false,error as? CustomErrorStruct)
            }
        })
    }
    
    /// To get user story data and other user story
    ///
    /// - Parameters:
    ///   - strUrl: api url
    ///   - storyType: story type (my story or other story)
    ///   - finished: complication handler to inform view controller about service success or faloure
    func storyServiceCall(strUrl: String, storyType: StoryType, finished: @escaping(Bool, CustomErrorStruct?)->Void){
        var updatedUrl = ""
        if storyType == .myStory {
            myStoryOffset = myStoryOffset + 20
            updatedUrl = strUrl + "?skip=\(self.myStoryOffset)&limit=100"
        }else{
            otherStoryOffset = otherStoryOffset + 20
            updatedUrl = strUrl + "?skip=\(self.otherStoryOffset)&limit=100"
        }
        
        socialApi.getSocialData(withURL: updatedUrl, params: [:]) { (modelArray, customError) in
            if let result = modelArray as? [Any] {
                print(result)
                self.setStoryData(storyType: storyType, responseData: result)
                finished(true, nil)
            }
            if let error = customError{
                if error.code == 204{
                    finished(true, error)
                }else{
                    finished(false, error)
                }
            }
        }
    }
    
    
    /// To set data in my story and other story data according to story type
    ///
    /// - Parameters:
    ///   - storyType: story type
    ///   - responseData: service call result
    func setStoryData(storyType: StoryType, responseData: [Any]){
        switch storyType {
        case .myStory:
            self.setMyStoryInArray(result: responseData)
            break
        case .otherStory:
            self.setOtherStoryInArray(result: responseData)
            break
        }
    }
    
    
    /// To set data in my story array
    ///
    /// - Parameter result: service call result
    func setMyStoryInArray(result: [Any]){
        if result.count > 0 {
            if let dic = result[0] as? [String:Any] {
                if let allStories = dic["posts"] as? [[String:Any]] {
                    print(allStories)
                    self.myStories = userStory.init(storiesDetails:dic)
                }
            }
        }
    }
    
    
    /// To set data other stories according to recent and viewed stories
    ///
    /// - Parameter result: service call result
    func setOtherStoryInArray(result: [Any]){
        self.recentStories.removeAll()
        self.viewedStories.removeAll()
        if result.count > 0 {
            for singleUserStory in result {
                let user = userStory.init(storiesDetails:singleUserStory as! [String : Any])
                if user.hasNewStroy {
                    self.recentStories.append(user)
                } else {
                    self.viewedStories.append(user)
                }
            }
            
            self.recentStories = self.recentStories.sorted(by: {$0.lastStoryTimeStamp > $1.lastStoryTimeStamp})
            
            self.viewedStories = self.viewedStories.sorted(by: {$0.lastStoryTimeStamp > $1.lastStoryTimeStamp})
        }
    }
    
    
    func getVerificationStatus(finished: @escaping(Bool, CustomErrorStruct?)->Void){
//               Helper.showPI()
               let strURl = AppConstants.verificationStatus
               verificationApi.getVerificationStatus(withURL: strURl, params: [:]) { (modelArray, customError) in
                   Helper.hidePI()
                   if let modelData = modelArray as? [String : Any]{
                       self.createVerificationStatusArray(data: modelData)
       //                self.apiResponseRecieved.onNext(true)
                       finished(true, nil)
                   }
                   if let error = customError{
       //                self.apiResponseRecieved.onNext(false)
                       if error.code == 204{
                           finished(true, error)
                       }else{
                           finished(false, error)
                       }
                       print(error)
                       
                   }
               }
           }
           
           func getVerificationStatusPatch(finished: @escaping(Bool, CustomErrorStruct?)->Void){
               kycverify.kycApprovedApi { (success, error) in
                   Helper.hidePI()
                   if success {
                       print("success")
                   finished(true,nil)
                   } else {
                       print(error)
                       
                   }
               }
           }

       func createVerificationStatusArray(data : [String: Any]) {
           if let status = data["verificationStatus"] as? Int {
               self.verificationModel = VerificationModel(data: status)
           }
       }
           
           func getStatus() -> Int? {
                if let status = verificationModel?.verificationStatus {
               return status
               }
               return nil
           }
    
    
    
    /// To get post response from post id
    ///
    /// - Parameters:
    ///   - postId: post id
    ///   - complitation: complitation handler after getting response
    func getPostDetailsService(postId: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let url: String = AppConstants.post + "?postId=\(postId)"
        socialApi.getSocialData(withURL: url, params: [:]) { (response, error) in
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
    
    /// To update user follow status in database and server
    ///
    /// - Parameters:
    ///   - contact: contact to be updated
    ///   - isFollow: follow or unfollow
    func FollowPeopleService(isFollow: Bool, peopleId: String, privicy: Int){
    
        ContactAPI.followAndUnfollowService(with: isFollow, followingId: peopleId, privicy: privicy)
    }
    
}
