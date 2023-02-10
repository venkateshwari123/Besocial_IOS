//
//  TrendingModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 26/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
 struct TrendingPostModelArray {
    
    var imageUrl:String?
    var mediaType1:Int?
    var likesCount:Int?
    var categoryId:String?
    var categoryName:String?
    var categoryUrl:String?
    var channelImageUrl:String?
    var city:String?
    var channelName:String?
    var channelStatus:String?
    var commentCount:Int?
    var countrySname:String?
    var createdOn:String?
    var distinctViews:String?
    var imageUrl1Height:Double?
    var imageUrl1Width:Double?
    var lastName:String?
    var firstName:String?
    
    
    init(trendingPostModelData: [String : Any]){
        
        if let imageUrl = trendingPostModelData["imageUrl1"] as? String{
            self.imageUrl = imageUrl
        }
        if let mediaType1 = trendingPostModelData["mediaType1"] as? Int{
            self.mediaType1 = mediaType1
        }

        if let likesCount = trendingPostModelData["likesCount"] as? Int{
           self.likesCount = likesCount
        }
        
        if let categoryId = trendingPostModelData["categoryId"] as? String{
            self.categoryId = categoryId
        }
        if let categoryName = trendingPostModelData["categoryName"] as? String{
            self.categoryName = categoryName
        }
        if let channelImageUrl = trendingPostModelData["channelImageUrl"] as? String{
            self.channelImageUrl = channelImageUrl
        }
        if let commentCount = trendingPostModelData["commentCount"] as? Int{
            self.commentCount = commentCount
        }
        if let city = trendingPostModelData["city"] as? String{
            self.city = city
        }
        if let channelName = trendingPostModelData["channelName"] as? String{
            self.channelName = channelName
        }
        if let channelStatus = trendingPostModelData["likesCount"] as? String{
            self.channelStatus = channelStatus
        }
        if let lastName = trendingPostModelData["lastName"] as? String{
            self.lastName = lastName
        }
        if let firstName = trendingPostModelData["firstName"] as? String{
            self.firstName = firstName
        }
     }
}
