//
//  ActivityCommentModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 11/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ActivityCommentModel: NSObject {
    
    //    "_id" = 5b923e3a794e318065070a0d;
    //    message = " liked post ";
    var activityId: String?
    var message: String = ""
    //    postData =         {
    //    categoryId = 5b7d79771669556712644211;
    //    channelId = 5b7d79771669556712644211;
    //    city = "";
    //    comments =             (
    //    );
    //    createdOn = "2018-09-04T14:54:59.625Z";
    //    distinctViews = 0;
    //    hashTags =             (
    //    );
    //    imageUrl1 = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536072899/posts/z0drcru0vlisdjohxz8i.jpg";
    //    imageUrl1Height = 720;
    //    imageUrl1Width = 720;
    //    likesCount = 1;
    //    location =             {
    //    latitude = 0;
    //    longitude = 0;
    //    };
    //    mediaType1 = 0;
    //    place = "";
    //    postId = 5b8e9cc321806c0a95cef08b;
    //    profilePic = "https://res.cloudinary.com/dqodmo1yc/image/upload/c_thumb,w_200,g_face/v1536126847/default/profile_one.png";
    //    thumbnailUrl1 = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536072899/posts/z0drcru0vlisdjohxz8i.jpg";
    //    timeStamp = 1536072899625;
    //    title = "actions movies are thrilling";
    //    totalComments = 0;
    //    userId = 5b755a84e8f3214e1d7a0f9d;
    //    userName = jojojo;
    //    };
    
    //    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1535613765/profile/hadgtfq6oagimfemf7d1.jpg";
    //    targetId = 5b755a84e8f3214e1d7a0f9d;
    //    targetProfilePic = "https://res.cloudinary.com/dqodmo1yc/image/upload/c_thumb,w_200,g_face/v1536126847/default/profile_one.png";
    //    targetUserName = jojojo;
    //    timeStamp = 1536310842454;
    //    type = 2;
    //    userId = 5b4dbe3d8dde25190edec674;
    //    userName = jaddu;
    var postData: PostDataModel?
    var profilePic: String?
    var targetId: String?
    var targetProfilePic: String?
    var targetUserName: String = ""
    var timeStamp: Double = 0
    var type: Int?
    var userId: String?
    var userName: String = ""
    var firstName: String = ""
    var lastName: String = ""
    
    
    init(modelData: [String : Any]){
        
        if let id = modelData["_id"] as? String{
            self.activityId = id
        }
        if let msg = modelData["message"] as? String{
            self.message = msg
        }
        if let postData = modelData["postData"] as? [String : Any]{
            self.postData = PostDataModel(modelData: postData)
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let id = modelData["targetId"] as? String{
            self.targetId = id
        }
        if let pic = modelData["targetProfilePic"] as? String{
            self.targetProfilePic = pic
        }
        if let name = modelData["targetUserName"] as? String{
            self.targetUserName = name
        }
        if let timeStamp = modelData["timeStamp"] as? Double{
            self.timeStamp = timeStamp
        }
        if let type = modelData["type"] as? Int{
            self.type = type
        }
        if let id = modelData["userId"] as? String{
            self.userId = id
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
        
        if let fname = modelData["firstName"] as? String{
            self.firstName = fname
        }
        
        if let lname = modelData["lastName"] as? String{
            self.lastName = lname
        }
        
    }
    
}
