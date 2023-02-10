//
//  PostDetailsViewModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 15/11/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class DublyPostDetailsViewModel: NSObject {
    
    let postDetaiApi = SocialAPI()
    let trendingApi = TrendingAPI()
    var socialModelArray = [SocialModel]()
    var xclusivePostsModelArray = [SocialModel]()
    var popularUserArray = [PopularUserModel]()
    var forYouPostsModelArray = [SocialModel]()
    var storyModelArray = [StoryModel]()
    var followersFolloweeModelArray = [FollowersFolloweeModel]()
    var reportReasonArray = [String]()
    var channelViewModelArray = [ProfileChannelModel]()
    var offset: Int = 0
    let limit = 20
    var offsetForForYouPosts: Int = 0
    var hashTagPostsOffset: Int = 0
    var xclusivePostsOffset:Int = 0
    var xclusivePostsLimit:Int = 20
    let limitForForYouPosts = 20
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
    
    func getPopularUserService(complitation: @escaping([PopularUserModel], CustomErrorStruct?)->Void){
        guard let userId = Utility.getUserid() else { return }
        let strUrl = AppConstants.popularUser
        let url = strUrl + "?" + "userId=\(userId)&set=0&skip=0"
        trendingApi.postTrendingData(with: url) { (response, error) in
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
        
        if offset == 0{
            popularUserArray.removeAll()
        }
        
        for modelData in dataArray{
            if let data = modelData as? [String : Any]{
                let popularUserData = PopularUserModel(modelData: data)
                popularUserArray.append(popularUserData)
                
            }
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
    func likeAndUnlikeService(data: SocialModel,index: Int, isSelected: Bool,complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        
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
    
    func followAndUnFollowUserService(index: Int, isSelected: Bool,isForYouPosts: Bool,isXclusive: Bool){
        /* Bug Name : crashes on following rihan star from exclusive post Think it’s a random crash
         Fix Date : 13-05-2021
         Fixed By : Jayaram G
         Description Of Fix : Handled data for xclusive posts, also removed force unwrapping for userID
         */
        let data:SocialModel!
        if isForYouPosts {
            data = self.forYouPostsModelArray[index]
        }else if isXclusive{
            data = self.xclusivePostsModelArray[index]
        }else {
            data = self.socialModelArray[index]
        }
        
        guard let peopleId = data.userId else {return}
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
    func postReportReasonService(reasonIndex: Int, postIndex: Int,postArray: [SocialModel], complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let url: String = AppConstants.reportReasons
        
        if self.reportReasonArray.count > reasonIndex &&  postArray.count > postIndex && postIndex > -1{
            let reason = self.reportReasonArray[reasonIndex]
            guard let postId = postArray[postIndex].postId else { return }
            
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
    
    
    
    /// Postss From pyhton api for foryou page
    /// - Parameters:
    ///   - complitation: complitation description
    func getTrending(complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        var strUrl = ""
        /*
         Refactor Name:- add randomScore params in guest post api
         Refactor Date:- 09/04/21
         Refacotr By  :- Nikunj C
         Description of Refactor:- add randomScore params in guest post api
         */
        var randomScore = 0
        if let randomValue = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.randomScore)as? Int{
            randomScore = randomValue
        }else {
            randomScore = Int.random(in: 0..<1000000000)
        }
        
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            strUrl = AppConstants.guestUserAPI + "?set=\(self.offsetForForYouPosts)&limit=\(self.limitForForYouPosts)" + "&randomScore=\(randomScore)"
        }
        else{
           strUrl = AppConstants.getTrendingPosts + "?set=\(self.offsetForForYouPosts)&limit=\(self.limitForForYouPosts)"
        }
           
            trendingApi.postTrendingData(with: strUrl) { (response, error) in
                if let modelData = response as? [Any]{
                    print(modelData)
                    self.createModelArrayForYouPosts(dataArray: modelData)
                    let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                    complitation(true, nil, canServiceCall)
                }else if let error = error{
                    if error.code == 204{
                        if self.offsetForForYouPosts == 0{
                            self.forYouPostsModelArray.removeAll()
                        }
                        complitation(true, error, false)
                    }else{
                        complitation(true, error, true)
                    }
                }
                Helper.hidePI()
            }
    }
    
    func uploadViewersData(viewersData: [[String:Any]],complitation: @escaping(Bool, CustomErrorStruct?)->Void){
            let strUrl = "postViews/"
        let param = ["posts" : viewersData]
        trendingApi.uploadViewersData(withURL: strUrl,params:param) { error in
            complitation(true, nil)
                Helper.hidePI()
            }
    }
    
    func createModelArrayForYouPosts(dataArray: [Any]){
        if offsetForForYouPosts == 0{
            forYouPostsModelArray.removeAll()
        }
        for modelData in dataArray{
            if let data = modelData as? [String : Any]{
                let socialData = SocialModel(modelData: data)
                forYouPostsModelArray.append(socialData)
            }
        }
    }
    
    
    /// Postss From pyhton api for foryou page
       /// - Parameters:
       ///   - complitation: complitation description
    func getHashTagPosts(hashTag: String,complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
       let hashTagName = hashTag.replace(target: "#", withString: "")
        /*
        Bug Name : clicking on 2 nd post in hash tag faise , opens the correct post but on scroll up the order does not match what is shown on hash tags list page
        Fix Date : 24-May-2021
        Fixed By : Jayaram G
        Description Of Fix : Changed Api from node to python
      */
        let strUrl = "\(AppConstants.postsByHashtags)?&set=\(self.hashTagPostsOffset)&limit=20&includePaid=1"
        trendingApi.hashTagTrendingPostsData(with: strUrl, hashTag: hashTagName) { (response, error) in
            if let modelData = response as? [Any]{
                print(modelData)
                self.createModelArray(dataArray: modelData)
                let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                if error.code == 204{
                    if self.hashTagPostsOffset == 0{
                        self.socialModelArray.removeAll()
                    }
                    complitation(true, error, false)
                }else{
                    complitation(true, error, true)
                }
            }
            Helper.hidePI()
            
        }
       }
    
    /// Postss From pyhton api for foryou page
       /// - Parameters:
       ///   - complitation: complitation description
    func getXclusivePosts(complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        let strUrl = "\(AppConstants.getXclusivePosts)?set=\(self.xclusivePostsOffset)&limit=20"
        trendingApi.postTrendingData(with: strUrl) { (response, error) in
            if let modelData = response as? [Any]{
                print("xclusive Posts \(strUrl) ________\(modelData)")
                self.createXclusiveModelArray(dataArray: modelData)
                let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                if error.code == 204{
                    if self.xclusivePostsOffset == 0{
                        self.xclusivePostsModelArray.removeAll()
                    }
                    complitation(true, error, false)
                }else{
                    complitation(true, error, true)
                }
            }
            Helper.hidePI()
            
        }
       }
    
    func createXclusiveModelArray(dataArray: [Any]){
        if xclusivePostsOffset == 0{
            xclusivePostsModelArray.removeAll()
        }
        for modelData in dataArray{
            if let data = modelData as? [String : Any]{
                let socialData = SocialModel(modelData: data)
                xclusivePostsModelArray.append(socialData)
            }
        }
    }
    
}
