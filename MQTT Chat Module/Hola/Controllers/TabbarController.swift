//
//  TabbarController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 10/10/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

class TabbarController: UITabBarController,UITabBarControllerDelegate {
    
    let selfID = Utility.getUserid()
    
    var isFromFindFriendsAction:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addObserVerForCamera()
        self.delegate = self
//        tabBar.itemPositioning = .centered
       // tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 5, bottom: -10, right: -5)
        tabBar.items?.forEach({ (item) in
            item.title = nil
            item.imageInsets = UIEdgeInsets(top: 5, left: 5, bottom: -5, right: -5)
        })
//        if
        UITabBarItem.appearance().setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor):AppColourStr.themeColor]) , for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.lightGray]), for: .normal)
        
        
        if let isLogin =  UserDefaults.standard.value(forKey: "iscomingFormLogin") as? Bool {
            if isLogin {
                //                self.selectedIndex = 2
                //                UserDefaults.standard.set(false, forKey: "iscomingFormLogin")
                //            } else {
                //                self.selectedIndex = 1
                //                self.tabBar.items?[1].title = "Chats"
                self.getChatInitially()
            }
        }else if isFromFindFriendsAction {
           self.selectedIndex = 3
        }
        else {
            //            self.selectedIndex = 1
            //            self.tabBar.items?[1].title = "Chats"
            self.getChatInitially()
        }
    }
    
    func enablePushNotification() {
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.synchronize()
    }
    

    
    
    /// For fetching chats initially.
    func getChatInitially() {
        let couchbaseObj = Couchbase.sharedInstance
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        guard let chats = chatsDocVMObject.getChats() else { return }
        //get chatList from api call
        if let userID = selfID {
            MQTTChatManager.sharedInstance.subscribeGetChatTopic(withUserID: userID)
            if chats.count==0 {
                ChatAPI().getChats(withPageNo:"0", withCompletion: { response in
                    print(response)
                })
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = tabBarController.viewControllers?.index(of: viewController)
        guard let status = Utility.getIsGuestUser() else { return false }
        
        /*
         Feat Name:- when click on home button should scroll to top recent post
         Feat Date:- 27th Jan 2022
         Feat By:- Nikunj C
         */
        
        if index == 0{
            
            if let swipeNav = self.viewControllers?[0] as? SwipeNavigationController {
                guard let homeVC = swipeNav.viewControllers.first as? SocialViewController else {return false}
                homeVC.socialCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                homeVC.playVideoPlayerFromStoppedState()
            }
               
        }
        if status && index != 0 {
            Route.navigateToLoginVC(vc: (self.viewControllers?.first)!)
            return false
        }
        if index == 2 {
            
            /*
             Bug Name:- when open camera video from post playing in background
             Fix Date:- 27th Jan 2022
             Fix By:- Nikunj C
             Description of Fix:- stop player before present camera screen
             */
            
            if let swipeNav = self.viewControllers?[0] as? SwipeNavigationController {
                guard let homeVC = swipeNav.viewControllers.first as? SocialViewController else {return false}
                homeVC.stopVideoPlayer()
            }
            NotificationCenter.default.post(name: NSNotification.Name("openCameraForPost"), object: nil)
            return false
        } else if index == 4{
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isFromTabProfile)
            return true
        }else{
            return true
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
