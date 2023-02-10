//
//  SceneDelegate.swift
//  CreData
//
//  Created by Rahul Sharma on 02/10/21.
//

import UIKit
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        (UIApplication.shared.delegate as? AppDelegate)?.self.window = window
        self.redirectingStoryBoard()
        window?.overrideUserInterfaceStyle = .light
//        Utility.getAppTheme()
        guard let _ = (scene as? UIWindowScene) else { return }
        guard let userActivity = connectionOptions.userActivities.first(where: { $0.webpageURL != nil }) else { return }
        handleDynamicUrl(url: userActivity.webpageURL!)
    }
    
    func redirectingStoryBoard() {
        /* Bug Name :- User should login to see home page
         Fix Date :- 17/05/2021
         Fixed By :- Jayaram G
         Description Of bug :- Changed redirections to loginVC
         */
        
        if AppConstants.appType == .dubly {
            let storyBoard = UIStoryboard.init(name: "DublyTabbar", bundle: nil)
            if UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isGuestLogin) == nil{
                Utility.setIsGuestUser(status: true)
            }
            
            //            if UserDefaults.standard.value(forKey: AppConstants.UserDefaults.LoggedInUser) != nil {
            //                Utility.setIsGuestUser(status: false)
            //            }else{
            //                Utility.setIsGuestUser(status: true)
            //            }
            self.window?.rootViewController = storyBoard.instantiateViewController(withIdentifier: "DublyTabbarViewController")
        }else{
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            if UserDefaults.standard.value(forKey: AppConstants.UserDefaults.LoggedInUser) != nil {
                let indexDocVMObject = IndexDocumentViewModel(couchbase: Couchbase.sharedInstance)
                guard let indexID = indexDocVMObject.getIndexValue(withUserSignedIn: false) else { return }
                guard let indexData = Couchbase.sharedInstance.getData(fromDocID: indexID) else { return }
                //            if (indexData["isUserSignIn"] as? Bool) == true{
                self.window?.rootViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
            } else {
                /*
                 Bug Name :- Need to add background image scrolling
                 Fix Date :- 25/05/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- Changed intial rootviewcontroller
                 */
                let scrollingImageVc = ScrollingImageVC.instantiate(storyBoardName: "Authentication") as ScrollingImageVC
                let navController = UINavigationController(rootViewController: scrollingImageVc)
                navController.isNavigationBarHidden = true
                self.window?.rootViewController = navController
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        IAPManager.shared.stopObserving()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //        setLastWillTopic()
        //            bgTask = application.beginBackgroundTask(withName:"MyBackgroundTask", expirationHandler: {() -> Void in
        //                // Do something to stop our background task or the app will be killed
        //                application.endBackgroundTask(self.bgTask)
        //                self.bgTask = UIBackgroundTaskIdentifier.invalid
        //            })
        //
        //            DispatchQueue.global(qos: .background).async {
        //                //make your API call here
        //                self.removerActiveStreamServiceCall()
        //            }
        
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "appCloseTime")
        UserDefaults.standard.synchronize()
        
        //        UIApplication.shared.setMinimumBackgroundFetchInterval(30)
        
        //free your self
        if let userID = Utility.getUserid(){
            MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)}
        
      //  self.saveContext()
        //        mqttChatManager.sendOnlineStatus(withOfflineStatus: true)
        self.setLastSeenStatus(withOfflineStatus: true)
        
        //            sleep(5)
        //            self.removerActiveStreamServiceCall()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
       // application.applicationIconBadgeNumber = 0
        //        mqttChatManager.sendOnlineStatus(withOfflineStatus: false)
        self.setLastSeenStatus(withOfflineStatus: false)
        if (Utility.getUserid()) != nil {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.checkPendingcalls()
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        self.setLastSeenStatus(withOfflineStatus: true)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        IAPManager.shared.startObserving()
        self.setLastSeenStatus(withOfflineStatus: false)
        if UserDefaults.standard.bool(forKey: "callMethodeFirstTimeOnly") == false {
            APBook.sharedInstance.checkContacisChanged()
            UserDefaults.standard.set(true, forKey: "callMethodeFirstTimeOnly")
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //application.applicationIconBadgeNumber = 0 // For Clear Badge Counts
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests() // To remove all pending notifications which are not delivered yet but scheduled.
        //UserDefaults.standard.set(true, forKey: "callMethodeFirstTimeOnly")
        if let chatDocID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.isUserOnchatscreen) as? String {
            if chatDocID != "" {
                if appDelegate.chatVcObject != nil {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
                        appDelegate.chatVcObject?.checkAndsendReadAck()
                    }

                }
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        self.setLastSeenStatus(withOfflineStatus: true)
    }

    /// To set last seen of user
    fileprivate func setLastSeenStatus(withOfflineStatus status: Bool){
        guard let selfID = Utility.getUserid() else { return }
        var lastStatus = true
        if (UserDefaults.standard.object(forKey:"\(selfID)+Last_Seen") as? Bool) != nil{
            lastStatus = false
        }
        MQTTChatManager.sharedInstance.sendOnlineStatus(withOfflineStatus: status , isLastSeenEnable: lastStatus)
    }
    
    func handleDynamicUrl(url: URL){
       
        
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
            if error == nil{
                guard let link = dynamiclink else{return}
                let stringUrl = link.url?.absoluteString
                if stringUrl?.contains("\(AppConstants.DynamicLinkUrlForPost)") == true {
                    let postId = stringUrl?.replacingOccurrences(of: AppConstants.DynamicLinkUrlForPost, with: "")
                    guard let posId = postId else {return}
                    print("item id: \(posId)")
                    guard let appdel = (UIApplication.shared.delegate) as? AppDelegate else{return}
                    appdel.openPostDetailsViewController(postId: posId)
                }
                
            }
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {

        guard let url = userActivity.webpageURL else {return}
        handleDynamicUrl(url: url)
    }
    
}









