//
//  friendRequestModel.swift
//  PicoAdda
//
//  Created by 3Embed on 23/10/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class friendRequestModel: NSObject {
    
    var myFriendRequestArray = [UserProfile]()
    var friendRequestByArray = [UserProfile]()
    
    init(modelData: [String : Any]){
        
        if let myFriendRequestArray = modelData["myFriendRequest"] as? [[String:Any]] {
            for data in myFriendRequestArray{
                if let modelData = data as? [String : Any]{
                    let myFriendRequest = UserProfile(modelData: modelData)
                    self.myFriendRequestArray.append(myFriendRequest)
                }
            }
            if let friendRequestByArray = modelData["friendRequestBy"] as? [[String:Any]] {
                for data in friendRequestByArray{
                    if let modelData = data as? [String : Any]{
                        let friendRequestBy = UserProfile(modelData: modelData)
                        self.friendRequestByArray.append(friendRequestBy)
                    }
                }
            }
        }
    }
}
