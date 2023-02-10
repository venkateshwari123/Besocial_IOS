//
//  SavedCollectionModel.swift
//  Citysmart Life
//
//  Created by 3Embed on 30/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class SavedCollectionModel: NSObject {
    var id : String = ""
    var collectionName : String!
    var coverImage : String!
    var userId : String!
    var postIds : [String] = []
    var posts:[SocialModel] = []
    var images:[String] = []
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.id = id
        }
        if let name = modelData["collectionName"] as? String{
            self.collectionName = name
        }
        if let image = modelData["coverImage"] as? String{
            self.coverImage = image
        }
        if let userid = modelData["userId"] as? String{
            self.userId = userid
        }
        if let postids = modelData["postIds"] as? [String]{
            self.postIds = postids
        }
        if let posts = modelData["posts"] as? [[String:Any]] {
            for post in posts{
                self.posts.append(SocialModel.init(modelData: post))
            }
        }
        if let images = modelData["images"] as? [String] {
            for image in images {
                self.images.append(image)
            }
        }
    }
}

class BookMark: NSObject {
    var id : String!
    var thumbnailUrl : String!
    var isSelected : Bool = false
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.id = id
        }
        if let image = modelData["thumbnailUrl1"] as? String{
            self.thumbnailUrl = image
        }
        if let image = modelData["imageUrl1"] as? String{
            self.thumbnailUrl = image
        }
    }
    
    init(image: String){
//        if let id = modelData["_id"] as? String{
//            self.id = id
//        }
//        if let image = modelData["thumbnailUrl1"] as? String{
//            self.thumbnailUrl = image
//        }
//        if let image = modelData["imageUrl1"] as? String{
//            self.thumbnailUrl = image
//        }
        self.thumbnailUrl = image
    }
}

class Collection : NSObject{
    var collectionName : String!
    var thumbnailUrl : String!
    var postId : String!
    
    init(modelData: [String : Any]){
        if let collectionName = modelData["collectionName"] as? String{
            self.collectionName = collectionName
        }
        if let image = modelData["thumbnailUrl1"] as? String{
            self.thumbnailUrl = image
        }
        if let postid = modelData["postId"] as? String{
            self.postId = postid
        }
    }
}
