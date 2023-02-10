//
//  FullCommentModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 12/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class FullCommentModel: NSObject {

//    comment = "checking long comments for that i have to write some text and some farji tetx I think it is enough";
//    commentCount = 3;
//    commentedBy = checking;
//    commentedByUserId = 5b98bbfd22d534779271c218;
//    commentedOn = "2018-10-12T07:34:04.469Z";
//    hashtags =     (
//    );
//    imageUrl1 = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536648813/posts/zxfaak966giuy35f0usd.jpg";
//    postedBy = 5b727caedbe34d52327bd138;
//    profilePic = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536904037/pdrfdjyo0rbd7djxvhzs.jpg";
//    thumbnailUrl1 = "http://res.cloudinary.com/dqodmo1yc/image/upload/v1536648813/posts/zxfaak966giuy35f0usd.jpg";
//    timeStamp = 1539329644469;
    
    var comment: String?
    var commentCount: Int = 0
    var commentedBy: String?
    var commentedByFirstName = ""
    var commentedByLastName = ""
    var commentedByUserId: String?
    var commentedOn: String?
    var imageUrl: String?
    var postedBy: String?
    var profilePic: String?
    var thumbnailUrl: String?
    var timeStamp: Double = 0
    var isExpand:Bool = false
    
    init(modelData: [String : Any]){
        if let comment = modelData["comment"] as? String{
            self.comment = comment
        }
        if let count = modelData["commentCount"] as? Int{
            self.commentCount = count
        }
        if let by = modelData["commentedBy"] as? String{
            self.commentedBy = by
        }
        if let byfName = modelData["commentedByFirstName"] as? String{
            self.commentedByFirstName = byfName
        }
        if let bylName = modelData["commentedByLastName"] as? String{
            self.commentedByLastName = bylName
        }
        if let id = modelData["commentedByUserId"] as? String{
            self.commentedByUserId = id
        }
        if let on = modelData["commentedOn"] as? String{
            self.commentedOn = on
        }
        if let url = modelData["imageUrl1"] as? String{
            self.imageUrl = url
        }
        if let by = modelData["postedBy"] as? String{
            self.postedBy = by
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let url = modelData["thumbnailUrl1"] as? String{
            self.thumbnailUrl = url
        }
        if let timestamp = modelData["timeStamp"] as? Double{
            self.timeStamp = timestamp
        }
    }
    
    
//    "_id" = 5bc07ef58e35950033879dc7;
//    comment = hiii;
//    commentedBy = 5b727caedbe34d52327bd138;
//    commentedOn = "2018-10-12T11:01:09.467Z";
//    hashtags =     (
//    );
//    postId = 5b97666fa6c8507de52f5df5;
//    timeStamp = 1539342069467;

    init(postModelData: [String : Any], userImage: String, userName: String){
        if let comment = postModelData["comment"] as? String{
            self.comment = comment
        }
        if let by = postModelData["commentedBy"] as? String{
            self.commentedByUserId = by
        }
        if let on = postModelData["commentedOn"] as? String{
            self.commentedOn = on
        }
        if let timestamp = postModelData["timeStamp"] as? Double{
            self.timeStamp = timestamp
        }
        self.profilePic = userImage
        self.commentedBy = userName
    }
    
}
