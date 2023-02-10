//
//  StoriesModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 10/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class StoriesModel: NSObject {
 
    var id:String?
    
    
    var postModelArray = [postModel]()
    override init() {
        
    }
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
                self.id = id
        }
        if let posts = modelData["posts"] as? [[String:Any]]{
            for data in posts{
                if let modelData = data as? [String : Any]{
                    let story = postModel(storyData: modelData)
                    self.postModelArray.append(story)
                }
            }
        }
        
    }
    
}

class postModel: NSObject {
  
    var thumbnail: String?
    var storyId: String?
    var timestamp: String?
    var mediaType: Int?
    
    init(storyData: [String : Any]){
        if let thumbnail = storyData["thumbnail"] as? String{
            self.thumbnail = thumbnail
        }
        if let storyId = storyData["storyId"] as? String{
            self.storyId = storyId
        }
        if let timestamp = storyData["timestamp"] as? String{
            self.timestamp = timestamp
        }
        if let type = storyData["type"] as? Int{
            self.mediaType = type
        }
       
    }
}
