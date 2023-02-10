//
//  SocialModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 27/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

struct TrendingPostModel {
    
//    hashTagImage = "";
//    hashTags = "#homesweethome";
//    posts = [ SocialModel]()
//    totalPosts = 3
    
//    var hashTagImage
    var posts:[SocialModel] = [SocialModel]()
    var hashTagName:String?
    var hashTagImage:String?
    var totalPosts:Int?
    
    
    
    
    init(modelData: [String : Any]){
        if let posts = modelData["posts"] as? [[String:Any]]{
            self.posts = posts.map({ (data) -> SocialModel in
                SocialModel(modelData: data)
            })
        }
        if let Name = modelData["hashTags"] as? String{
            self.hashTagName = Name
        }
        
        if let hashTagImage = modelData["hashTagImage"] as? String{
            self.hashTagImage = hashTagImage
        }
        if let totalPosts = modelData["totalPosts"] as? Int{
            self.totalPosts = totalPosts
        }
    }
    
}



