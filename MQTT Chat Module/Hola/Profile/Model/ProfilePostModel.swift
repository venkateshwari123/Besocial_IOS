//
//  ProfilePostModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 18/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ProfilePostModel: NSObject {

//    "_id" = 5b727caedbe34d52327bd138;
//    categoryId = "";
//    categoryName = entertainment;
//    categoryUrl = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535005155/w1antsv7xmqev8es1bh5.png";
    var id: String?
    var categoryId: String?
    var categoryName: String?
    var categoryUrl: String?
//    channelId = "";
//    channelImageUrl = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536648760/cxbxbleyzj8mqnui0lwu.jpg";
//    channelName = ppd;
//    city = "";
    var channelId: String?
    var channelImageUrl: String?
    var channelName: String?
    var city: String?
//    comments =     (
//    {
//        comment = hi;
//        commentId = 5b925656498b706adb9739b0;
//        commentedBy = jaddu;
//        commentedByProfilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535613765/profile/hadgtfq6oagimfemf7d1.jpg";
//        commentedOn = 1536317014660;
//    }
//    );
//    createdOn = "2018-09-11T06:53:35.058Z";
//    distinctViews = 1;
//    hashTags =     (
//    "",
//    "#love",
//    "#pet",
//    "#love"
//    );
    var comments = [CommentModel]()
    var createdOn: Double = 0
    var distinctView: Int = 0
    var hashTags = [String]()
//    imageUrl1 = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536648813/posts/zxfaak966giuy35f0usd.jpg";
//    imageUrl1Height = 1704;
//    imageUrl1Width = 1080;
//    liked = 0;
//    likesCount = 1;
//    mediaType1 = 0;
//    place = "";
//    postId = 5b97666fa6c8507de52f5df5;
    var imageUrl: String?
    var imageUrlHeight: Int = 0
    var imageUrlWidth: Int = 0
    var liked: Int = 0
    var likesCount: Int = 0
    var mediaType: Int = 0
    var place: String?
    var postId: String?
//    profilePic = "https://res.cloudinary.com/dqodmo1yc/image/upload/v1535024930/c8lschdgz7evudnmikd9.jpg";
//    thumbnailUrl1 = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536648813/posts/zxfaak966giuy35f0usd.jpg";
//    timeStamp = 1536648815058;
//    title = "@dipen etuii";
//    totalComments = 0;
//    userId = 5b727caedbe34d52327bd138;
//    userName = alokalok;
    var profilePic: String?
    var thumbnailUrl: String?
    var timeStamp: Double = 0
    var title: String?
    var totalComment: Int = 0
    var userId: String?
    var userName: String?
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.id = id
        }
        if let id = modelData["categoryId"] as? String{
            self.categoryId = id
        }
        if let name = modelData["categoryName"] as? String{
            self.categoryName = name
        }
        if let url = modelData["categoryUrl"] as? String{
            self.categoryUrl = url
        }
        if let id = modelData["channelId"] as? String{
            self.channelId = id
        }
        if let url = modelData["channelImageUrl"] as? String{
            self.channelImageUrl = url
        }
        if let name = modelData["channelName"] as? String{
            self.channelName = name
        }
        if let city = modelData["city"] as? String{
            self.city = city
        }
        if let comments = modelData["comments"] as? [[String : Any]]{
            for comment in comments{
                let data = CommentModel(commentData: comment)
                self.comments.append(data)
            }
        }
        if let created = modelData["createdOn"] as? Double{
            self.createdOn = created
        }
        if let view = modelData["distinctViews"] as? Int{
            self.distinctView = view
        }
        if let tags = modelData["hashTags"] as? [String]{
            self.hashTags = tags
        }
        if let url = modelData["imageUrl1"] as? String{
            self.imageUrl = url
        }
        if let height = modelData["imageUrl1Height"] as? Int{
            self.imageUrlHeight = height
        }
        if let width = modelData["imageUrl1Width"] as? Int{
            self.imageUrlWidth = width
        }
        if let liked = modelData["liked"] as? Int{
            self.liked = liked
        }
        if let count = modelData["likesCount"] as? Int{
            self.likesCount = count
        }
        if let type = modelData["mediaType1"] as? Int{
            self.mediaType = type
        }
        if let place = modelData["place"] as? String{
            self.place = place
        }
        if let id = modelData["postId"] as? String{
            self.postId = id
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let thumbnail = modelData["thumbnailUrl1"] as? String{
            self.thumbnailUrl = thumbnail
        }
        if let timeStamp = modelData["timeStamp"] as? Double{
            self.timeStamp = timeStamp
        }
        if let title = modelData["title"] as? String{
            self.title = title
        }
        if let total = modelData["totalComments"] as? Int{
            self.totalComment = total
        }
        if let id = modelData["userId"] as? String{
            self.userId = id
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
    }
}
