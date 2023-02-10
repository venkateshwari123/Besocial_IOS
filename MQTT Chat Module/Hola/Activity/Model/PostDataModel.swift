//
//  PostDataModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 11/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class PostDataModel: NSObject {

    
//    {
//    categoryId = 5b16b62175c23ef87fce8212;
//    channelId = 5b16b62175c23ef87fce8212;
//    city = "90, 1st Main Road, Vishveshvaraiah Nagar, Hebbal, Bengaluru, Karnataka 560024, India";
    var categoryId: String?
    var channelId: String?
    var city: String?
//    comments =             (
//    {
//    comment = absb;
//    commentId = 5b8facc3b35cca63cb4e6eba;
//    commentedBy = kate;
//    commentedByProfilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535977824/profile/b2sj8ntiqjjsiaqkkfjt.jpg";
//    commentedOn = 1536142531054;
//    },
//    {
//    comment = abv;
//    commentId = 5b8facc0b35cca63cb4e6eb9;
//    commentedBy = kate;
//    commentedByProfilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535977824/profile/b2sj8ntiqjjsiaqkkfjt.jpg";
//    commentedOn = 1536142528768;
//    },
//    {
//    comment = hello;
//    commentId = 5b8facbfb35cca63cb4e6eb8;
//    commentedBy = kate;
//    commentedByProfilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535977824/profile/b2sj8ntiqjjsiaqkkfjt.jpg";
//    commentedOn = 1536142527227;
//    }
//    );
    var commentArray = [CommentModel]()
//    createdOn = "2018-09-05T10:14:11.534Z";
//    distinctViews = 2;
//    hashTags =             (
//    );
    var createdOn: String?
    var distinctViews: Int = 0
    var hashTagArray = [String]()
//    imageUrl1 = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536142450/posts/hjcuujiaye8vkqsgoabg.jpg";
//    imageUrl1Height = 1080;
//    imageUrl1Width = 1080;
//    likesCount = 1;
    var imageUrl: String?
    var imageUrlHeight: Int?
    var imageUrlWidth: Int?
    var likeCount: Int = 0
//    location =             {
//    latitude = "13.02831778658297";
//    longitude = "77.58929014205933";
//    };
//    mediaType1 = 0;
//    place = "3Embed Software Technologies";
//    postId = 5b8fac73e004c463c5bddd23;
    var lattitude: Double?
    var longitude: Double?
    var mediaType: Int = 0
    var place: String?
    var postId: String?
//    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536142036/profile/vocbajnx31vak1qz3b6m.jpg";
//    thumbnailUrl1 = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536142450/posts/hjcuujiaye8vkqsgoabg.jpg";
//    timeStamp = 1536142451534;
//    title = "pillow talk";
//    totalComments = 3;
//    userId = 5b8faa62ceffce63c43a34ec;
//    userName = mojo;
    var profilePic: String?
    var thumbnailUrl: String?
    var timeStamp: Double?
    var title: String?
    var totalComment: Int = 0
    var userId: String?
    var userName: String?
    
    init(modelData: [String : Any]){
        
        if let id = modelData["categoryId"] as? String{
            self.categoryId = id
        }
        if let id = modelData["channelId"] as? String{
            self.channelId = id
        }
        if let city = modelData["city"] as? String{
            self.city = city
        }
        if let commentArray = modelData["comments"] as? [Any]{
            for comment in commentArray{
                guard let dict = comment as? [String : Any] else{continue}
                let commentModel = CommentModel(commentData: dict)
                self.commentArray.append(commentModel)
            }
        }
        if let created = modelData["createdOn"] as? String{
            self.createdOn = created
        }
        if let view = modelData["distinctViews"] as? Int{
            self.distinctViews = view
        }
        if let tags = modelData["hashTags"] as? [String]{
            self.hashTagArray = tags
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
        if let count = modelData["likesCount"] as? Int{
            self.likeCount = count
        }
        if let location = modelData["location"] as? [String : Any]{
            if let latti = location["latitude"] as? Double{
                self.lattitude = latti
            }
            if let longi = location["longitude"] as? Double{
                self.longitude = longi
            }
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
        
        //    timeStamp = 1536142451534;
        //    title = "pillow talk";
        //    totalComments = 3;
        //    userId = 5b8faa62ceffce63c43a34ec;
        //    userName = mojo;
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let thumbnail = modelData["thumbnailUrl1"] as? String{
            self.thumbnailUrl = thumbnail
        }
        if let time = modelData["timeStamp"] as? Double{
            self.timeStamp = time
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
