//
//  MediaModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 15/11/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

struct MediaModel {
  
    var artist: String = ""
    var mediaId: String?
    var audioStatus: Int = 0
    var audioStatusText: String?
    var duration: String?
    var imageUrl: String?
    var musicCategory: String?
    var name: String?
    var path: String?
    var sequenceId: Int = -1
    
    var musicCategoryName: String?
    var musicCategoryImageUrl: String?
    var totalVideos: Int = 0
    var isFavourite: Bool = false
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.mediaId = id
        }
        if let status = modelData["audioStatus"] as? Int{
            self.audioStatus = status
        }
        if let statusText = modelData["audioStatusText"] as? String{
            self.audioStatusText = statusText
        }
        if let dura = modelData["duration"] as? String{
            self.duration = dura
        }
        if let url = modelData["imageUrl"] as? String{
            self.imageUrl = url
        }
        if let artist = modelData["artist"] as? String{
            self.artist = artist
        }
        if let category = modelData["musicCategory"] as? String{
            self.musicCategory = category
        }
        if let category = modelData["musicCategory_id"] as? String{
            self.musicCategory = category
        }
        if let name = modelData["musicCategoryName"] as? String{
            self.musicCategoryName = name
        }
        if let imageUrl = modelData["musicCategoryImageUrl"] as? String{
            self.musicCategoryImageUrl = imageUrl
        }
        if let total = modelData["totalVideos"] as? Int{
            self.totalVideos = total
        }
        if let fav = modelData["isFavourite"] as? Int{
            self.isFavourite = fav == 0 ? false : true
        }
        if let name = modelData["name"] as? String{
            self.name = name
        }
        if let path = modelData["path"] as? String{
            self.path = path
        }
        if let id = modelData["sequenceId"] as? Int{
            self.sequenceId = id
        }
    }
}
