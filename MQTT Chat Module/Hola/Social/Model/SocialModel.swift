//
//  SocialModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 27/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

struct SocialModel {

    var id: String?
    var categoryId: String?
    var categoryName: String?
    var categoryUrl: String?
    var allowComment : Bool?
    var allowDownload : Bool?
    var channelId: String?
    var channelName: String?
    var channelImageUrl: String?
    var city: String?
    var palceId:String?
    var totalComments:Int = 0
    var commentCount: Int = 0
    var commentModelArray = [CommentModel]()
    var isSubscribed:Int?
    
    var trendingPostModelArray = [TrendingPostModelArray]()

    var createdOn: String?
    var distinctView: Int = 0
    var isFollowing: Bool = false

    var imageUrl: String?
    var imageUrlHeight: Float = 0
    var imageUrlWidth: Float = 0

    var liked: Int?
    var likesCount = 0

    var lattitude: Double?
    var longitude: Double?
    var place: String?
    var placeId:String?
    var mediaType: Int?
    var mediaData: MediaModel?
    var businessProfileObj:BusinessPostModel?
    var isStar:Int = 0
    var isStarBool:Bool = false
    var postId: String?
    var profilePic: String?
    var thumbnailUrl: String?
    var timeStamp: Double?
    var title: String?
    var userId: String?
    var userName : String?
    var mainImageUrl: String?
    var isViewed: Bool = false

    var fullNameWithSpace: String?
    var isBookMarked : Bool = false
    
    var noOfPosts:Int?
    var hashTagName: String?
    var hashTagImage: String?
    var isPaid : Bool = false
    var isPurchased : Int = 1
    var postAmount : Int?
    var subscriptionAmount : Double?
    var tipsAmount:Double?
    var fullNameWithOutSpace:String?
    /*
     Bug Name :- read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Added flag for to update the status of read more/less
     */
    var isExpand: Bool = false
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.id = id
        }
        if let id = modelData["categoryId"] as? String{
           self.categoryId = id
        }
        if let postAmt = modelData["postAmount"] as? String {
            self.postAmount = postAmt.integerValue
        }
        if let isStarBool = modelData["isStar"] as? Bool{
            self.isStarBool = isStarBool
        }
        if let name = modelData["categoryName"] as? String{
            self.categoryName = name
        }
        if let fullName = modelData["fullName"] as? String {
            self.fullNameWithOutSpace = fullName
        }
        if let placeId = modelData["placeId"] as? String{
            self.placeId = placeId
        }
        if let url = modelData["categoryUrl"] as? String{
            self.categoryUrl = url
        }
        if let id = modelData["channelId"] as? String{
            self.channelId = id
        }
        if let isCommentsAllowed = modelData["allowComment"] as? Bool {
            self.allowComment = isCommentsAllowed
        }
        if let isAllowDownload = modelData["allowDownload"] as? Bool {
            self.allowDownload = isAllowDownload
        }
        if let name = modelData["channelName"] as? String{
            self.channelName = name
        }
        if let url = modelData["channelImageUrl"] as? String{
            self.channelImageUrl = url
        }
        if let city = modelData["city"] as? String{
            self.city = city
        }
        if let count = modelData["commentCount"] as? Int{
            self.commentCount = count
        }
        if let totalCommentCount = modelData["totalComments"] as? Int{
            self.totalComments = totalCommentCount
        }
        if let commentsArray = modelData["comments"] as? [Any]{
            for data in commentsArray{
                if let modelData = data as? [String : Any]{
                    let commentModel = CommentModel(commentData: modelData)
                    self.commentModelArray.append(commentModel)
                }
            }
        }
        if let createdOn = modelData["createdOn"] as? String{
            self.createdOn = createdOn
        }
        if let view = modelData["postViewsCount"] as? Int{
            self.distinctView = view
        }
        if let follow = modelData["followStatus"] as? Int{
            self.isFollowing = (follow != 0) ? true : false
        }
        if let url = modelData["imageUrl1"] as? String{
            self.imageUrl = url
        }
        if let isStar = modelData["isStar"] as? Int {
            self.isStar = isStar
        }
        if let height = modelData["imageUrl1Height"] as? String{
            self.imageUrlHeight = Float(height) ?? 100
        }else if let height = modelData["imageUrl1Height"] as? Int{
            self.imageUrlHeight = Float(height)
        }
        if let width = modelData["imageUrl1Width"] as? String{
            self.imageUrlWidth = Float(width) ?? 100
        }else if let width = modelData["imageUrl1Width"] as? Int{
            self.imageUrlWidth = Float(width)
        }
        if let liked = modelData["liked"] as? Int{
            self.liked = liked
        }
        if let count = modelData["likesCount"] as? Int{
            self.likesCount = count
        }
        if let location = modelData["location"] as? [String : Double]{
            if let latti = location["latitude"]{
                self.lattitude = latti
            }
            if let lon = location["longitude"]{
                self.longitude = lon
            }
        }
        if let place = modelData["place"] as? String{
            self.place = place
        }
        if let type = modelData["mediaType1"] as? Int{
            self.mediaType = type
        }
        if let mediaData = modelData["musicData"] as? [String : Any]{
            self.mediaData = MediaModel(modelData: mediaData)
        }
        if let id = modelData["postId"] as? String{
            self.postId = id
        }
        if let pic = modelData["profilepic"] as? String{
            self.profilePic = pic
        }
        if let pic1 = modelData["profilePic"] as? String{
            self.profilePic = pic1
        }
        if let url = modelData["thumbnailUrl1"] as? String{
            /*
             Bug Name :- Videos are all mostly blurred
             Fix Date :- 02/06/2021
             Fixed By :- Jayaram G
             Description Of Fix :- removing transformation
             */
            let updatedUrl = url.replace(target: "t_media_lib_thumb/", withString: "")
            
            self.mainImageUrl = updatedUrl
            self.thumbnailUrl = updatedUrl
        }
        if let time = modelData["timeStamp"] as? Double{
            self.timeStamp = time
        }
        if let title = modelData["title"] as? String{
            self.title = title
        }
//        if let total = modelData["totalComments"] as? Int{
//            self.totalComments = total
//        }
        if let id = modelData["userId"] as? String{
            self.userId = id
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
        if let name = modelData["fullNameWithSpace"] as? String{
            self.fullNameWithSpace = name
        }
        if let bookMarked = modelData["isBookMarked"] as? Bool{
            self.isBookMarked = bookMarked
        }
        
        if let businessProfile = modelData["business"] as? [String : Any]{
            self.businessProfileObj = BusinessPostModel(modelData: businessProfile)
        }
        if let isSubscribedObj = modelData["isChannelSubscribed"] as? Int{
            self.isSubscribed = isSubscribedObj
        }
        
        
        if  let trendingPosts = modelData["posts"] as? [Any] {
            for data in trendingPosts{
                if let modelData = data as? [String:Any]{
                    let postModel = TrendingPostModelArray(trendingPostModelData: modelData)
                    self.trendingPostModelArray.append(postModel)
                }
            }
        }
        if let noOfPosts = modelData["totalPosts"] as? Int {
            self.noOfPosts = noOfPosts
        }
        
        if let hashTagName = modelData["hashTags"] as? String {
            self.hashTagName = hashTagName
        }
        
        if let hashTagImage = modelData["hashTagImage"] as? String {
            self.hashTagImage = hashTagImage
        }
        
        if let isPaidpost = modelData["isPaid"] as? Bool {
            self.isPaid = isPaidpost
        }
        
        if let isPaidpost = modelData["isPaid"] as? Int {
            self.isPaid = isPaidpost == 1 ? true : false
        }
        
        if let isPurchasedpost = modelData["isPurchased"] as? Int {
            self.isPurchased = isPurchasedpost
        }
        
        
        if let postAmt = modelData["postAmount"] as? Int {
            self.postAmount = postAmt
        }
        if let tips = modelData["TipsAmount"] as? Double {
            self.tipsAmount = tips
        }
        if let subc = modelData["subscriptionAmount"] as? Double {
            self.subscriptionAmount = subc
        }
     }
}


struct VerificationModel {
 
 var verificationStatus : Int?

 
 init(data:Int) {
     
     self.verificationStatus = data
 }
}

