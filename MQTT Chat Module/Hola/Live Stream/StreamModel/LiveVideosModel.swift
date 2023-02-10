//
//  LiveVideosModel.swift
//  PicoAdda
//
//  Created by 3Embed on 13/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class LiveVideosModel: NSObject {
    
    var duration:Double?
    var thumbnail:String = ""
    var timestamp:Double?
    var video:String = ""
    
    init(modelData: [String : Any]){
        if let duration = modelData["duration"] as? Double{
            self.duration = duration
        }
        if let thumbnail = modelData["thumbnail"] as? String{
            self.thumbnail = thumbnail
        }
        if let timestamp = modelData["timestamp"] as? Double{
            self.timestamp = timestamp
        }
        if let video = modelData["video"] as? String{
            self.video = video
        }
    }
    
    
}
