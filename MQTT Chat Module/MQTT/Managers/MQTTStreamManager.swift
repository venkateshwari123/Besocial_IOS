//
//  MQTTStreamManager.swift
//  Citysmart Life
//
//  Created by Rahul Sharma on 24/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit



class MQTTStreamManager: NSObject {
    
    static let sharedInstance = MQTTStreamManager()
    private override init() {}
    
    func getLiveUserData(data: [String: Any]){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamNow.rawValue), object: nil, userInfo: ["data": data])
    }
    
    func getStreamSubscribeData(data: [String : Any], topic: String){
//        let subData: [String : Any] = ["data": data,
//                       "topic" : topic]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.subscribeStream.rawValue), object: nil, userInfo: ["data": data])
    }
    
    func getChatData(data: [String : Any], topic: String){
//        let subData: [String : Any] = ["data": data,
//                                       "topic" : topic]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamChat.rawValue), object: nil, userInfo: ["data": data])
    }
    
    func getGiftData(data: [String : Any], topic: String){
//        let subData: [String : Any] = ["data": data,
//                                       "topic" : topic]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamGift.rawValue), object: nil, userInfo: ["data": data])
    }
    
    func getLikeData(data: [String : Any], topic: String){
//        let subData: [String : Any] = ["data": data,
//                                       "topic" : topic]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamLike.rawValue), object: nil, userInfo: ["data": data])
    }
    
}
