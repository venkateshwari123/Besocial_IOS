//
//  StoryModel.swift
//  CameraModule
//
//  Created by Shivansh on 11/16/18.
//  Copyright © 2018 Shivansh. All rights reserved.
//

import UIKit

struct StoryModel {
    var createdOn:Double?
    var mediaUrl:String?
    var thumbNailUrl:String?
    var storyID:String?
    var storyType = 0 // video story or image story. default story type is image
    var viewCount = 0
    var duration = 5
    var isPrivate = 0
    
    var storyText = ""
    var textFontStyle = ""
    var textBackgroundColor = ""
    
    var viewed = false
    var allViewers = [storyViewedUser]()
    
    init(storyDetails:[String:Any]) {
        
        if let type = storyDetails["type"] as? Int {
            self.storyType = type
        }
        
        if let message = storyDetails["statusMessage"] as? String {
            self.storyText = message
        }
        
        if let viewers = storyDetails["viewdList"] as? [Any] {
             for eachViewer in viewers.enumerated() {
                if let viewerDetails = eachViewer.element as? [String:Any]{
                    allViewers.append(storyViewedUser.init(userDetails: viewerDetails))
                }
            }
        }
        
        if let viewed = storyDetails["viewed"] as? Int {
            if viewed == 1 {
                self.viewed = true
            }
        }
        
        if let backgroundColor = storyDetails["backgroundColor"] as? String {
            self.textBackgroundColor = backgroundColor
        }
        
        if let fontType = storyDetails["fontType"] as? String {
            self.textFontStyle = fontType
        }
        
        
        if let durationInSec = storyDetails["duration"] as? String {
            if let duration = durationInSec as? String,durationInSec != ""  {
                let durationInMs = Int(durationInSec)
                let durationInMsDouble = Double(durationInMs!)/1000.0
                self.duration = Int(durationInMsDouble.rounded())
            }
            }
        
        if let duration = storyDetails["uniqueViewCount"] as? Int {
            self.viewCount = duration
        }
        
        if let isPrivate = storyDetails["isPrivate"] as? Int {
            self.isPrivate = isPrivate
        }
        
        if let thumbNailUrl = storyDetails["thumbnail"] as? String {
            self.thumbNailUrl = thumbNailUrl
            if self.storyType == 2 {
                //for video.
                if thumbNailUrl.contains(".mp4") {
                    let modifiedUrl = thumbNailUrl.replace(target:".mp4", withString:".jpeg")
                    self.thumbNailUrl = modifiedUrl
                }
            }
        }
        
        
        
        if let url = storyDetails["urlPath"] as? String {
            self.mediaUrl = url
            if self.storyType == 2 {
                //for video.
                if url.contains(".mp4") {
                    let modifiedUrl = url.replace(target:".mp4", withString:".mov")
                    self.mediaUrl = modifiedUrl
                }
            }
        }
        
        
        if self.storyType == 3 {
            self.thumbNailUrl = self.mediaUrl
        }
        
        if let createdOn = storyDetails["timestamp"] as? Double {
            self.createdOn = createdOn/1000
        }
        
        if let storyID = storyDetails["storyId"] as? String {
            self.storyID = storyID
        }
    }
}


struct storyViewedUser {
    var name = ""
    var profilePic = ""
    var viewedAt:Double = 0.0
    var userId = ""
    
    init(userDetails:[String:Any]) {
        if let createdOn = userDetails["timestamp"] as? Double {
            self.viewedAt = createdOn
        }
        
        if let profilePic = userDetails["profilePic"] as? String {
            self.profilePic = profilePic
        }
        if let name = userDetails["userName"] as? String {
            self.name = name
        }
        if let userId = userDetails["userId"] as? String {
            self.userId = userId
        }
    }
}


struct userStory {
    var userName:String?
    var userProfilePicture:String?
    var lastSeenStoryID:String?
    var currentStoryIndex:Int = 0
    var userStories:[StoryModel] = []
    var hasNewStroy = false
    var lastStoryTimeStamp = 0.0
    
    init(storiesDetails:[String:Any]) {
        
        if let name = storiesDetails["userName"] as? String {
            self.userName = name
        }
        
        if let name = storiesDetails["profilePic"] as? String {
            self.userProfilePicture = name
        }
        
        if let userStoires = storiesDetails["posts"] as? [[String:Any]] {
            for singleStory in userStoires.enumerated() {
                let eachStory = StoryModel.init(storyDetails: singleStory.element)
                if !eachStory.viewed {
                    self.hasNewStroy = true
                }
                userStories.append(eachStory)
            }
            /*
             Bug Name:- storyies not show in chronological order
             Fix Date:- 12/04/21
             Fixed By:- Nikunj C
             Description of Fix:- remove unneccessary sorting of array as data already sorted from api side.
             */
//            userStories = userStories.sorted(by: {$0.createdOn! < $1.createdOn!})
            
            
            for story in self.userStories.enumerated() {
                var islastRecentStory = false
                if !story.element.viewed {
                    if !islastRecentStory {
                        islastRecentStory = true
                        self.currentStoryIndex = story.offset
                        break
                    }
                }
            }
            
            if let lastTime = userStories.first?.createdOn {
                self.lastStoryTimeStamp = lastTime
            }
        }
    }
}
