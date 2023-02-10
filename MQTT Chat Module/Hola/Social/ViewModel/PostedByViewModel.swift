//
//  PostedByViewModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 29/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//
import UIKit
let kMusicData = "musicData"
let kData = "data"

class PostedByViewModel: NSObject {

    let PostedByApi = SocialAPI()
    let limit: Int = 20
    var offset: Int = -20
    var hashTagOffSet:Int = -20
    var postedByArray = [SocialModel]()
    var channelModel: ChannelModel?
    var mediaModel: MediaModel?
    
    
    override init() {
        super.init()
    }
    
    /// To get hashTag and channel service call
    ///
    /// - Parameters:
    ///   - hashTag: hashTag string or channel name
    ///   - finished: callback on success or failure
    func getPostedByHashTagData(isHashTag:Bool, hashTag: String, isChannel: Bool, finished: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        offset = offset + 20
        hashTagOffSet = hashTagOffSet + 20
       var strURL: String = ""
       if isHashTag{
           strURL = "\(AppConstants.postsByHashtags)?set=\(self.hashTagOffSet)&limit=20&includePaid=1"
       }else if isChannel{
           strURL = AppConstants.postedByChannel + "?channelId=\(hashTag)&offset=\(offset)&limit=\(limit)"
       }else{
           strURL = AppConstants.trendingPosts + "?categoryId=\(hashTag)&offset=\(offset)&limit=\(limit)"
       }
       /*
       Bug Name : clicking on 2 nd post in hash tag faise , opens the correct post but on scroll up the order does not match what is shown on hash tags list page
       Fix Date : 24-May-2021
       Fixed By : Jayaram G
       Description Of Fix : Changed Api from node to python for hashtag posts
     */
       if isHashTag {
           let trendingApi = TrendingAPI()
           trendingApi.hashTagTrendingPostsData(with: strURL, hashTag: hashTag) { (modelArray, customError) in
               if let modelData = modelArray as? [Any]{
                   self.createModelArray(dataArray: modelData)
                   let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                   finished(true, nil, canServiceCall)
               }else if let modelData = modelArray as? [String : Any]{
                   self.channelModel = ChannelModel(channelData: modelData)
                   if let dataArray = modelData[kData] as? [Any]{
                       self.createModelArray(dataArray: dataArray)
                       let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                       finished(true, nil, canServiceCall)
                   }
               }
               if let error = customError{
                   Helper.hidePI()
                    finished(false, error, false)
               }
           }
       }else{
        
        /*
         Bug Name:- show many lock post in explore category page
         Fix Date:- 19th Oct 2021
         Fixed By :- Nikunj C
         Description of Fix:- instead of postsByCategory use trendingPosts api
         */
        
           let trendingApi = TrendingAPI()
        trendingApi.postTrendingData(with: strURL) { (modelArray, customError) in
            if let modelData = modelArray as? [Any]{
                self.createModelArray(dataArray: modelData)
                let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                finished(true, nil, canServiceCall)
            }else if let modelData = modelArray as? [String : Any]{
                self.channelModel = ChannelModel(channelData: modelData)
                if let dataArray = modelData[kData] as? [Any]{
                    self.createModelArray(dataArray: dataArray)
                    let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                    finished(true, nil, canServiceCall)
                }
            }
            if let error = customError{
                Helper.hidePI()
                if error.code == 204{
                    finished(true, error, false)
                }else{
                    finished(true, error, true)
                }
            }
        }
       }
         
   }
    
    
    /// To get service response
    ///
    /// - Parameters:
    ///   - strURL: URL to call service
    ///   - complited: callback on success or fail
//    func getPostService(strURL: String, complited: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
//
//        PostedByApi.getSocialData(withURL: strURL, params: [:]) { (modelArray, customError) in
//            if let modelData = modelArray as? [Any]{
//                self.createModelArray(dataArray: modelData)
//                let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
//                complited(true, nil, canServiceCall)
//            }else if let modelData = modelArray as? [String : Any]{
//                self.channelModel = ChannelModel(channelData: modelData)
//                if let dataArray = modelData[kData] as? [Any]{
//                    self.createModelArray(dataArray: dataArray)
//                    let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
//                    complited(true, nil, canServiceCall)
//                }
//            }
//            if let error = customError{
//                Helper.hidePI()
//                if error.code == 204{
//                    complited(true, error, false)
//                }else{
//                    complited(true, error, true)
//                }
//            }
//        }
//    }
    
    
    func getPostedByMusic(complited: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        
        guard let musicId = mediaModel?.mediaId else {
            Helper.hidePI()
            return}
        offset = offset + 20
        let strUrl = AppConstants.postsByMusic + "?musicId=\(musicId)&offset=\(offset)&limit=\(limit)"
        PostedByApi.getSocialDataForDictionaryResponse(withURL: strUrl) { (modelData, customError) in
            if let data = modelData as? [String : Any]{
                if let Musicdata = data[kMusicData] as? [String : Any]{
                    self.mediaModel = MediaModel(modelData:Musicdata)
                }
                if let dataArray = data[kData] as? [Any]{
                    self.createModelArray(dataArray: dataArray)
                    let canServiceCall: Bool = (dataArray.count == self.limit) ? true : false
                    complited(true, nil, canServiceCall)
                }
            }
            if let error = customError{
                if error.code == 204{
                    complited(true, error, false)
                }else{
                    complited(true, error, true)
                }
            }
            Helper.hidePI()
        }
    }
    

    /// To create array of model data
    ///
    /// - Parameter dataArray: array of data to set in social model
    func createModelArray(dataArray: [Any]){
        if hashTagOffSet == 0{
            postedByArray.removeAll()
        }
        for modelData in dataArray{
            if let data = modelData as? [String : Any]{
                let socialData = SocialModel(modelData: data)
                postedByArray.append(socialData)
            }
        }
    }
    
    func subscribeAndUnsubscribChannel(subscribe: Bool, channelId: String, complited: @escaping(Bool, CustomErrorStruct?)->Void){
        var strURL = AppConstants.unSubscribeChannel
        if subscribe{
            strURL = AppConstants.subscribeChannel
        }
         let params: [String : Any] = ["channelId": channelId]
        
        PostedByApi.putSocialData(with: strURL, params: params) { (result, customError) in
            if let response = result{
                print(response)
                complited(true, nil)
            }
            if let error = customError{
                complited(false, error)
            }
        }
    }
    
    func makeFavouriteMusic(isSelected: Bool){
        let strUrl = AppConstants.favouriteMusic
        guard let musicId = mediaModel?.mediaId else {return}
        let params = ["musicId" : musicId as Any,
                      "isFavourite": isSelected] as [String : Any]
        PostedByApi.postSocialData(with: strUrl, params: params) { (response, customError) in
            if let result = response{
                print(result)
//                complited(true, nil)
            }
            if let error = customError{
                print("Error : \(error.localizedDescription)")
//                complited(false, error)
            }
        }
    }
    
}
