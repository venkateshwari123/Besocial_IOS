//
//  DublyTabbarViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 05/07/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class DublyTabbarViewController: UITabBarController,UITabBarControllerDelegate {
    
    let selfID = Utility.getUserid()
    
    var isFromFindFriendsAction:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addObserVerForCamera()
        self.tabBar.clipsToBounds = true
        self.delegate = self
        if let isLogin =  UserDefaults.standard.value(forKey: "iscomingFormLogin") as? Bool {
            if isLogin {
                self.getChatInitially()
            }
        }else if isFromFindFriendsAction {
            self.selectedIndex = 0
        }
        else {
            self.getChatInitially()
        }
        
        /* Bug Name : Chat count not updating after reopening the app
         Fix Date : 14-Apr-2021
         Fixed By : Jayaram G
         Description Of Fix : updating chat list count when tabbar is presenting
         */
        updatingChatListCount()
        

    }
    
    
    func updatingChatListCount() {
        guard let swipeNav = self.viewControllers?[3] as? SwipeNavigationController else {
            return
        }
        guard let chatList = swipeNav.viewControllers.first as? ChatsListViewController else {return}
        chatList.updateChatCountWhenOpeningApp()
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
        let index = tabBarController.viewControllers?.firstIndex(of: viewController)
        if index == 4 {
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isFromTabProfile)
        }else{
            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isFromTabProfile)
        }
        guard let status = Utility.getIsGuestUser() else { return false }
        
        if status && index == 0 {
            if let items =  tabBar.items {
            items[1].image = UIImage.init(named: "explore_unselected_white.dubly")
            items[3].image = UIImage.init(named: "chat_unselected_white.dubly")
            items[4].image = UIImage.init(named: "live_tab_icon_unselected_white.dubly")
                
            }
            return true
        }else if status && index == 1 {
            if let items =  tabBar.items {
                items[1].image = UIImage.init(named: "explore_unselected.dubly")
                items[3].image = UIImage.init(named: "chat_unselected.dubly")
                items[4].image = UIImage.init(named: "live_tab_icon_unselected.dubly")
                
            }
            return true
        }else if status {
            showAlert()
            return false
        }else {
            if index != 0 && index != 2 {
                if let items =  tabBar.items {
                    items[1].image = UIImage.init(named: "explore_unselected.dubly")
                    items[3].image = UIImage.init(named: "chat_unselected.dubly")
                    items[4].image = UIImage.init(named: "live_tab_icon_unselected.dubly")
                }
            }else {
                if let items =  tabBar.items {
                    items[1].image = UIImage.init(named: "explore_unselected_white.dubly")
                    items[3].image = UIImage.init(named: "chat_unselected_white.dubly")
                    items[4].image = UIImage.init(named: "live_tab_icon_unselected_white.dubly")

                }
            }
            return true
        }
    }
    
    private func showAlert() {
        presentWelcomeController()
    }
    
    func presentWelcomeController() {
        /*
         Bug Name:- while app is on background and call is receiving. on click of notification call screen is opening. bug : in background post sound is coming
         Fix Date:- 01/04/2021
         Fixed By:- jayaram G
         Discription of Fix:- Accessing tabbar object here , from tabbar getting postdetails viewcontroller and calling function pauseVideo()
         */
        guard let swipeNav = self.viewControllers?[0] as? SwipeNavigationController else {
            return
        }
        if let postVC = swipeNav.viewControllers.first(where: { postVC in
            return postVC.isKind(of:PostDetailsViewController.self )
        }) as? PostDetailsViewController{
            postVC.isVideoPaused = true
            postVC.currentIJKPlayer?.pause()
        }
        let loginVC = LoginVC.instantiate(storyBoardName: "Authentication") as LoginVC
        loginVC.isFromHomeVC = true
        let navVC = UINavigationController(rootViewController: loginVC)
        navVC.modalPresentationStyle = .overCurrentContext
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true, completion: nil)
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
