//
//  HashTagModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 04/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class HashTagModel: NSObject {

//    hashTags = "#screen";
//    totalPublicPosts = 1;
    var hashTag: String = ""
    var totalPublicPost: Int = 0
    var hashTagImage:String?
    init(modelData: [String: Any]){
        if let tag = modelData["hashTags"] as? String{
            self.hashTag = tag
        }
        if let publicPosts = modelData["totalPublicPosts"] as? Int{
            self.totalPublicPost = publicPosts
        }
        if let image = modelData["image"] as? String{
            self.hashTagImage = image
        }
    }
}
