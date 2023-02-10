//
//  MQTTNotificationDelegate.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 29/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import UserNotifications
import CocoaLumberjack

class MQTTNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    struct pushType {
        static let postCommented = "postCommented"
        static let followed = "followed"
        static let following = "following"
        static let followRequest = "followRequest"
        static let channelSubscribe = "channelSubscribe"
        static let channelRequest = "channelRequest"
        static let postLiked = "postLiked"
        static let rewardEarned = "reward"
        static let newPost = "newPost"
        static let liveStream = "liveStream"
     }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Play sound and show alert to the user
        if let userID = Utility.getUserid(){
            let notificationData = notification.request.content.userInfo
            guard let body = notificationData["data"] as? [String:Any] else{return}
            print(body)
            guard let message = body["message"] as? [String:Any] else{return}
            if let fromId = message["from"] as? String{
                if userID == fromId{
                    completionHandler([.sound])
                }else{
                    completionHandler([.sound,.alert])
                }
            }else if let callId = message["callType"] as? String, callId == "1"{
                let state = UIApplication.shared.applicationState
                if state == .background || state == .inactive {
                    // background
                    completionHandler([.sound,.alert])
                } else if state == .active {
                    // foreground
                    completionHandler([.sound,.alert])
                }
            }else if let callType = message["type"] as? String, callType == "video"{
                let state = UIApplication.shared.applicationState
                if state == .background || state == .inactive {
                    // background
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    completionHandler([.sound,.alert])
                } else if state == .active {
                    // foreground
                    completionHandler([.sound])
                }
            }
            else{
                completionHandler([.sound,.alert])
            }
        } else {
            completionHandler([.sound,.alert])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notificationData = response.notification.request.content.userInfo
        if let body = notificationData["data"] as? [String:Any] {
            if let message = body["message"] as? [String:Any] {
                print(body)
//                if let pushData = message["data"] as? [String : Any]{
                    switch body["type"] as? String{
                    case pushType.postCommented:
                        self.openPostDetailsPage(pustData: body)
                        break
                    case pushType.followed:
                        self.openUserProfile(pushData: body)
                        print("Follow")
                        break
                    case pushType.following:
                    self.openUserProfile(pushData: body)
                    print("Following")
                    break
                    case pushType.followRequest:
                        self.openRequestView(pushData: body)
                        print("follow request")
                        break
                    case pushType.channelRequest:
                        self.openchannelRequestView(pushData: body)
                        print("follow request")
                        break
                    case pushType.postLiked:
                        self.openPostDetailsPage(pustData: body)
                        break
                    case pushType.newPost:
                        self.openPostDetailsPage(pustData: body)
                        break
                    case pushType.rewardEarned:
                        self.openTransactionsView(pushData: body)
                        break
                    case pushType.liveStream:
                    break
                    case pushType.channelSubscribe:
                        openChannelPostPage(pustData: body)
                        break
                    default:
                        break
                    }
                if let type = message["callType"] as? String, type == "1" {
                    //video call
                }else{
                    self.openChatController(withData: message)
                }
            }
        }else  {
            if  let body =  notificationData[AnyHashable("data")]! as? String {
                if let dict = body.convertToDictionary() {
                    print(dict)
                    if let typeObj = dict["type"] as? String {
//                        if typeObj == pushType.channelRequest {
//                                self.openchannelRequestView(pushData: dict)
//                        }else if typeObj == pushType.channelSubscribe {
//                            self.openchannelPostsView(pushData: dict)
//                        }
                        switch typeObj {
                        case pushType.postCommented:
                            self.openPostDetailsPage(pustData: dict)
                            break
                        case pushType.followed:
                            self.openUserProfile(pushData: dict)
                            print("Follow")
                            break
                        case pushType.following:
                        self.openUserProfile(pushData: dict)
                        print("Following")
                        break
                        case pushType.followRequest:
                            self.openRequestView(pushData: dict)
                            print("follow request")
                            break
                        case pushType.channelRequest:
                            self.openchannelRequestView(pushData: dict)
                            print("follow request")
                            break
                        case pushType.postLiked:
                            self.openPostDetailsPage(pustData: dict)
                            break
                        case pushType.newPost:
                            self.openPostDetailsPage(pustData: dict)
                            break
                        case pushType.rewardEarned:
                            self.openTransactionsView(pushData: dict)
                            break
                        case pushType.liveStream:
                        break
                        case pushType.channelSubscribe:
                            openChannelPostPage(pustData: dict)
                            break
                        case pushType.channelRequest:
                              self.openchannelRequestView(pushData: dict)
                            break
                            
                        default:
                            break
                        }
                    }
                }
            }
    }
        completionHandler()
    }
    
    func openChatController(withData data: [String : Any]) {
        
        
        NSLog("got notification here \(data)")
        
        if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            DispatchQueue.main.async {
                if let controller = tabController.viewControllers?[0] as? UINavigationController {
                    controller.popToRootViewController(animated: false)
                    tabController.selectedIndex = 0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                let name = NSNotification.Name(rawValue: "notificationTapped")
                NotificationCenter.default.post(name: name, object: nil, userInfo: ["chatObj":data])
            }
        }
        else if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navController.popToRootViewController(animated: false)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                let name = NSNotification.Name(rawValue: "notificationTapped")
                NotificationCenter.default.post(name: name, object: nil, userInfo: ["chatObj":data])
            }
        }
    }
    
    func openChannelPostPage(pustData: [String : Any]){

        guard let postId = pustData["postId"] as? String else{return}
        let postedByVC = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        postedByVC.isChannel = true
        postedByVC.isPresented = true
        postedByVC.hashTagName = postId
        let navVC = UINavigationController.init(rootViewController: postedByVC)
        var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
        while ((topRootViewController?.presentedViewController) != nil) {
            topRootViewController = topRootViewController?.presentedViewController
        }
        DispatchQueue.main.async {
            navVC.modalPresentationStyle = .fullScreen
            topRootViewController?.present(navVC, animated: true, completion: nil)
        }
    }
    
    func openPostDetailsPage(pustData: [String : Any]){
        if AppConstants.appType == .picoadda {
            guard let postId = pustData["postId"] as? String else{return}
            guard let socialDetailsVC =  UIStoryboard.init(name: AppConstants.StoryBoardIds.instaHome, bundle: nil).instantiateViewController(withIdentifier: String(describing: SocialDetailsViewController.self)) as? SocialDetailsViewController else{return}
            socialDetailsVC.postId = postId
            let navVC = UINavigationController.init(rootViewController: socialDetailsVC)
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                navVC.modalPresentationStyle = .fullScreen
                topRootViewController?.present(navVC, animated: true, completion: nil)
            }
        }else{
            guard let postId = pustData["postId"] as? String else{return}
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            guard let postDetailsVC = storyboard.instantiateViewController(withIdentifier: "PostDetailsViewController") as? PostDetailsViewController else{return}
            postDetailsVC.isCommingFromChat = true
            postDetailsVC.isViewPresented = true
            postDetailsVC.postId = postId
            let navVC = UINavigationController.init(rootViewController: postDetailsVC)
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                navVC.modalPresentationStyle = .fullScreen
                topRootViewController?.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    func openUserProfile(pushData: [String : Any]){
        guard let userId = pushData["userId"] as? String else{return}
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        profileVC.memberId = userId
        profileVC.isPresented = true
        let navigationController = UINavigationController(rootViewController: profileVC)
        var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
        while ((topRootViewController?.presentedViewController) != nil) {
            topRootViewController = topRootViewController?.presentedViewController
        }
        DispatchQueue.main.async {
            navigationController.modalPresentationStyle = .fullScreen
            topRootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
        func openTransactionsView(pushData: [String : Any]){
    //        guard let userId = pushData["userId"] as? String else{return}
                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
//            let transactionVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.transactionVc) as! TransactionHistoryViewController
//            let navigationController = UINavigationController(rootViewController: transactionVc)
//            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
//            while ((topRootViewController?.presentedViewController) != nil) {
//                topRootViewController = topRootViewController?.presentedViewController
//            }
//            DispatchQueue.main.async {
//                navigationController.modalPresentationStyle = .fullScreen
//                topRootViewController?.present(navigationController, animated: true, completion: nil)
//            }
        }
        

    
    func openRequestView(pushData: [String : Any]){
        let acceptOrDeleteVC = AcceptOrDeleteViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Activity) as AcceptOrDeleteViewController

        acceptOrDeleteVC.isChannel = false
        acceptOrDeleteVC.isCommingFromPush = true
        let navigationController = UINavigationController(rootViewController: acceptOrDeleteVC)
        var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
        while ((topRootViewController?.presentedViewController) != nil) {
            topRootViewController = topRootViewController?.presentedViewController
        }
        DispatchQueue.main.async {
            navigationController.modalPresentationStyle = .fullScreen
            topRootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func openchannelRequestView(pushData: [String : Any]){
        let acceptOrDeleteVC = AcceptOrDeleteViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Activity) as AcceptOrDeleteViewController
            acceptOrDeleteVC.isChannel = true
            acceptOrDeleteVC.isCommingFromPush = true
            let navigationController = UINavigationController(rootViewController: acceptOrDeleteVC)
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                navigationController.modalPresentationStyle = .fullScreen
                topRootViewController?.present(navigationController, animated: true, completion: nil)
            }
        }
    
    
    func openchannelPostsView(pushData: [String : Any]){
        let postedByVc = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        postedByVc.isChannel = true
        postedByVc.channelName = ""
        postedByVc.isPresented = true
        
        if let channelId = pushData["channelId"] as? String {
            postedByVc.hashTagName = channelId
        }
        let navigationController = UINavigationController(rootViewController: postedByVc)
        var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
        while ((topRootViewController?.presentedViewController) != nil) {
            topRootViewController = topRootViewController?.presentedViewController
        }
        DispatchQueue.main.async {
            navigationController.modalPresentationStyle = .fullScreen
            topRootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    
}


extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}
