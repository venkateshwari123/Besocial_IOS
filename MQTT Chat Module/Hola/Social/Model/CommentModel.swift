//
//  CommentModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 27/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

struct CommentModel {
    
    var comment: String?
    var commentId: String?
    var commentedBy: String?
    var commentedByProfilePic: String?
    var commentedOn: Double?
    
    init(commentData: [String : Any]){
        if let comment = commentData["comment"] as? String{
            self.comment = comment
        }
        if let commentId = commentData["commentId"] as? String{
            self.commentId = commentId
        }
        if let by = commentData["commentedBy"] as? String{
            self.commentedBy = by
        }
        if let pic = commentData["commentedByProfilePic"] as? String{
            self.commentedByProfilePic = pic
        }
        if let commentedOn = commentData["commentedOn"] as? Double{
            self.commentedOn = commentedOn
        }
    }
}
