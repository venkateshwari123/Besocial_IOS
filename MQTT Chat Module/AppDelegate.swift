//
//  AppDelegate.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 08/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Reachability
import Kingfisher
import PushKit
import CallKit
import CocoaLumberjack
import RxReachability
import RxSwift
import RxCocoa
import Locksmith
import AVKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDynamicLinks
import EVURLCache
import GooglePlaces
import GoogleMaps
import OneSignal
import IQKeyboardManagerSwift
import Alamofire

struct appDelegetConstant {
    //static let  window = UIApplication.shared.keyWindow
    static let incomingViewController = "IncomingCallViewController"
    static let window = UIApplication.shared.keyWindow!
}

struct StoryboardId {
    static let PostDetailsViewController = "PostDetailsViewController"
    static let profileViewController = "ProfileViewController"
    static let acceptOrDeleteVC = "acceptOrDeleteVC"
}

public typealias SimpleClosure = (() -> ())

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate ,MessagingDelegate,AVAudioPlayerDelegate, OSSubscriptionObserver, OSPermissionObserver{
    
    var window: UIWindow?
    var chatVcObject : ChatViewController? = nil
    let notificationDelegate = MQTTNotificationDelegate()
    let reachability = Reachability()!
    var isNetworkThere : Bool = true
    let disposebag = DisposeBag()
    var calleeName = ""
    fileprivate let mqttChatManager = MQTTChatManager.sharedInstance
    var uuid:UUID?
    var callProviderDelegate: CallProviderDelegate?
    var deepLinkUserActivity: NSUserActivity?
    let callManager = CallManager()
    var ringToneCount:Int = 0
    var ringToneTimer  = Timer()
    var player: AVAudioPlayer?
    var countDown:Int = 5
    var roomId = ""
    var roomIdForVoip : String?
    var callID = ""
    var arrOfNotificationIds = [String]()
    var mqttCallId = ""
    var acceptedCallFromNotification:Bool = false
    struct pushType {
        static let chatMessage = "ChatMSG"
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
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //MARK:- App life Cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        //        Utility.clearKeychainIfWillUnistall()
        flowCheck()
        //register push notif....
        self.registerPushNotification()
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isTokenRefreshed)
        uuid = UUID()
        IQKeyboardManager.shared.enable = true
        generateRandomScore()
        Helper.fetchIpDetails()
        GMSPlacesClient.provideAPIKey(AppConstants.googleMapKey)
        GMSServices.provideAPIKey(AppConstants.googleMapKey)
        IAPManager.shared.startObserving()
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        
        Reachability.rx.isReachable
            .subscribe(onNext: { isReachable in
                if isReachable == true {self.reachabilityChanged(isReachable)}
                else{self.reachabilityChanged(isReachable)}
            }).disposed(by: disposebag)
        do{
            try reachability.startNotifier()
        }catch{
            DDLogDebug("could not start reachability notifier")
        }
        
        connectToOneSignal()
        
        self.setupNotification(application: application)
        setUpAudioPermissions()
        Messaging.messaging().delegate = self
        
        UserDefaults.standard.set(true, forKey: "callMethodeFirstTimeOnly")
        UINavigationBar.appearance().tintColor = UIColor.black
        
        /*
         Bug Name :- Navigation bar showing in black color in iphone 13
         Fix Date :- 20/10/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Setting bar background color
         */
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
        
        
        ///Clear cache memory
        self.setupURLCache()
        URLCache.shared.removeAllCachedResponses()
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache { print("Done") }
        
        // Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(AppConstants.oneSignalAppID)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        setOneSignalNotify()
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = AppConstants.DeepLinking.CUSTOM_URL_SCHEME
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        //Remove sterm if any there
        self.removerActiveStreamServiceCall()
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func flowCheck(){
        guard let flowType = Bundle.main.object(forInfoDictionaryKey: "Flowtype") as? String else{
            fatalError("Info.plist contains malformed (or missing) GH_API_ENDPOINT for this configuration.")
        }
        let type = Int(flowType) ?? 1
        AppConstants.appType = AppType(rawValue: type) ?? .picoadda
    }
    
    func generateRandomScore(){
        /*
         Refactor Name:- add randomScore params in guest post api
         Refactor Date:- 19/04/21
         Refacotr By  :- Nikunj C
         Description of Refactor:- generate random int for guest api
         */
        
        let randomScore = Int.random(in: 0..<1000000000)
        UserDefaults.standard.set(randomScore, forKey: AppConstants.UserDefaults.randomScore)
    }
    func printFontsNames() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
    
    // [START connect_to_fcm]
    func connectToOneSignal() {
        print("Connecting to FCM.")
        /* Refactor Name :  Need to subscribe with deviceId in Onesignal
         Refactor Date : 07-Apr-2021
         Refactor By : Jayaram G
         Description Of Refactor : subscribing onesignal with deviceId.
         */
        if let oneSignalId = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.oneSignalId) as? String {
            Utility.subscribeToOneSignal(externalUserId: oneSignalId)
        }
        
    }
    
    
    func setUpAudioPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
            DispatchQueue.main.async {
                if granted {
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isAppRequestedAudio)
                } else {
                    UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isAppRequestedAudio)
                }
            }
        })
    }
    
    //MARK: - Setup Notification
    func setupNotification(application: UIApplication) {
        //FCM Push
        FirebaseApp.configure()
        // iOS 10 support
        if #available(iOS 10,iOSApplicationExtension 10.0, *) {
            
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
        
        application.registerForRemoteNotifications()
        
        connectToFcm()
        //        NotificationCenter.default.addObserver(self,
        //                                               selector: #selector(tokenRefreshNotification(notification:)),
        //                                               name: NSNotification.Name.tok,
        //                                               object: nil)
    }
    
    
    // [START refresh_token]
    @objc func tokenRefreshNotification(notification: Notification) {
        print("Connecting to FCM Token.")
        if let refreshedToken = Messaging.messaging().fcmToken {
            //              print("InstanceID token: \(refreshedToken)")
            
            //              Utility.savePushToken(token: refreshedToken)
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    
    // [START connect_to_fcm]
    func connectToFcm() {
        print("Connecting to FCM.")
        if let oneSignalId = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.oneSignalId) as? String {
            Utility.subscribeToOneSignal(externalUserId: oneSignalId)
        }    }
    
    func setOneSignalNotify() {
        let notifWillShowInForegroundHandler: OSNotificationWillShowInForegroundBlock = { notification, completion in
            print("Received Notification: ", notification.notificationId ?? "no id")
            print("launchURL: ", notification.launchURL ?? "no launch url")
            print("content_available = \(notification.contentAvailable)")
            /*
             Bug Name :- Logout automatically
             Fix Date :- 23/03/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Getting "login" type from notifcation and logging out from application
             */
            if let notificationData = notification.additionalData {
                if let type = notificationData[AnyHashable("type")] as? String, let deviceId = notificationData[AnyHashable("deviceId")] as? String {
                    if type == "login" && deviceId != Utility.DeviceId {
                        Utility.logOut()
                    }else{
                        return
                    }
                }
                if let action = notificationData[AnyHashable("action")] as? Int , let type = notificationData[AnyHashable("type")] as? String, type == "audio" {
                    if action == 4 {
                        /*
                         Bug Name :- Call kit screen not removed even call ended
                         Fix Date :- 26/03/2021
                         Fixed By :- Jayaram G
                         Description Of Fix :- Removing call kit screen when we get missed call notification
                         */
                        self.callProviderDelegate?.reportEndCall(nil)
                        self.acceptedCallFromNotification = false
                        
                    }
                }
            }
            
            if UIApplication.shared.applicationState == .inactive || UIApplication.shared.applicationState == .background{
                print("********\(notification.additionalData)")
                if let notificationData = notification.additionalData {
                    if let callID = notificationData[AnyHashable("callId")] as? String ,callID != ""{
                        print("*************Cal Id \(callID)")
                        if let action = notificationData[AnyHashable("action")] as? Int {
                            if action == 1 && (notificationData[AnyHashable("type")] as? String) == "video" {
                                
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                            }
                        }
                    }
                }
                completion(notification)
            }else {
                
                /*
                 Bug Name :- Logout: When User 1 is logged in on device 1 and User 1 logs into another device 2, device 1 should show a message
                 Fix Date :- 23/03/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- checking the action for logout and returning completion(notification)
                 */
                
                if let notificationData = notification.additionalData {
                    if let type = notificationData[AnyHashable("type")] as? String ,let deviceId = notificationData[AnyHashable("deviceId")] as? String{
                        if type == "login" && deviceId != Utility.DeviceId {
                            completion(notification)
                        }else{
                            return
                        }
                    }
                    
                    /*
                     Bug Name :-  Video Calling: Issue when app is open for User 1 and User 2 cuts the call, a push notification should show up for User 1 saying missed call from User 2
                     Fix Date :- 23/03/2021
                     Fixed By :- Jayaram G
                     Description Of Fix :- checking the action for missed call and returning completion(notification)
                     */
                    
                    /*
                     Bug Name :-  Not getting follow , like etc notification when we are on app
                     Fix Date :- 31/03/2021
                     Fixed By :- Jayaram G
                     Description Of Fix :- we are not showing incoming audio & video call notifications when app is opened ,as the user will experience the ring from incoming call screen , other notifications we are showing.
                     */
                    
                    if let action = notificationData[AnyHashable("action")] as? Int {
                        if action == 1 {
                            completion(nil)
                        }else {
                            completion(notification)
                        }
                    }else{
                        completion(notification)
                    }
                }
                
            }
            //                    if notification.notificationId == "example_silent_notif" {
            //                        completion(nil)
            //                    } else {
            //                        completion(notification)
            //                    }
        }
        
        let notificationOpenedBlock: OSNotificationOpenedBlock = { result in
            // This block gets called when the user reacts to a notification received
            let notification: OSNotification = result.notification
            
            print("Message: ", notification.body ?? "empty body")
            print("badge number: ", notification.badge)
            print("notification sound: ", notification.sound ?? "No sound")
            
            if let notificationData = notification.additionalData {
                print("additionalData: ", notificationData)
                
                if let callID = notificationData[AnyHashable("callId")] as? String ,callID != ""{
                    if let action = notificationData[AnyHashable("action")] as? Int {
                        if action == 1 && (notificationData[AnyHashable("type")] as? String) == "video" {
                            /*
                             Bug Name :-  Mqtt call not connecting sometimes
                             Fix Date :- 25/03/2021
                             Fixed By :- Jayaram G
                             Description Of Fix :- set false to receive mqtt data , before we handled for fcm notifcations
                             */
                            self.acceptedCallFromNotification = false
                            
                            self.arrOfNotificationIds.append(notification.notificationId ?? "")
                        }else {
                            self.acceptedCallFromNotification = false
                            //                                center.removeDeliveredNotifications(withIdentifiers: arrOfNotificationIds)
                        }
                    }
                }else {
                    self.acceptedCallFromNotification = false
                    //                        center.removeDeliveredNotifications(withIdentifiers: arrOfNotificationIds)
                }
                
                if let actionSelected = notification.actionButtons {
                    print("actionSelected: ", actionSelected)
                }
                
                // DEEP LINK from action buttons
                if let actionID = result.action.actionId {
                    
                    // For presenting a ViewController from push notification action button
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let instantiateRedViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RedViewControllerID") as UIViewController
                    let instantiatedGreenViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "GreenViewControllerID") as UIViewController
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    
                    print("actionID = \(actionID)")
                    
                    if actionID == "id2" {
                        print("do something when button 2 is pressed")
                        self.window?.rootViewController = instantiateRedViewController
                        self.window?.makeKeyAndVisible()
                        
                        
                    } else if actionID == "id1" {
                        print("do something when button 1 is pressed")
                        self.window?.rootViewController = instantiatedGreenViewController
                        self.window?.makeKeyAndVisible()
                        
                    }
                }
                
                self.manageNotifications(info: notificationData)
            }
            
        }
        
        OneSignal.setNotificationOpenedHandler(notificationOpenedBlock)
        OneSignal.setNotificationWillShowInForegroundHandler(notifWillShowInForegroundHandler)
        OneSignal.add(self as OSPermissionObserver)
        
        OneSignal.add(self as OSSubscriptionObserver)
        
    }
    
    
    // Add this new method
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges) {
        
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        // prints out all properties
        print("PermissionStateChanges: ", stateChanges)
    }
    
    // Output:
    /*
     Thanks for accepting notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSPermissionState: hasPrompted: 0, status: NotDetermined>,
     to:   <OSPermissionState: hasPrompted: 1, status: Authorized>
     >
     */
    
    // TODO: update docs to change method name
    // Add this new method
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges) {
        //            if !stateChanges.from.subscribed && stateChanges.to.subscribed {
        //                print("Subscribed for OneSignal push notifications!")
        //            }
        print("SubscriptionStateChange: ", stateChanges)
    }
    
    
    
    func reachabilityChanged(_ isReachability: Bool) {
        if isReachability == true {
            let mqttModel = MQTT.sharedInstance
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                mqttModel.createConnection()
            }
            isNetworkThere = true
            DDLogDebug("Network is rechable now")
        } else {
            DDLogDebug("Network not reachable")
            isNetworkThere = false
            //            Helper.showAlertViewOnWindow("Oops", message: "Check your internet connection")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationData = notification.request.content.userInfo
        if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive{
            let center = UNUserNotificationCenter.current()
            print("Will Present called, Click on Notification")
            if let callID = notificationData[AnyHashable("callId")] as? String ,callID != ""{
                if let action = notificationData[AnyHashable("action")] as? String {
                    if action == "1" && (notificationData[AnyHashable("type")] as? String) == "video" {
                        acceptedCallFromNotification = true
                        
                        arrOfNotificationIds.append(notification.request.identifier)
                    }else {
                        acceptedCallFromNotification = false
                        center.removeDeliveredNotifications(withIdentifiers: arrOfNotificationIds)
                    }
                }
            }else {
                acceptedCallFromNotification = false
                center.removeDeliveredNotifications(withIdentifiers: arrOfNotificationIds)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                completionHandler([.sound,.alert,.badge])
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive{
            let notificationData = response.notification.request.content.userInfo
            if  let callID =  notificationData[AnyHashable("callId")] as? String ,callID != ""{
                if let action = notificationData[AnyHashable("action")] as? String {
                    if action == "1" && (notificationData[AnyHashable("type")] as? String) == "video" {
                        arrOfNotificationIds.append(response.notification.request.identifier)
                    }else {
                        center.removeDeliveredNotifications(withIdentifiers: arrOfNotificationIds)
                    }
                }
            }
        }else {
            //                completionHandler([.sound,.alert,.badge])
        }
        self.manageNotifications(info: response.notification.request.content.userInfo)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let notificationData = userInfo
        if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive{
            print("************ User Info\(userInfo)")
            if let callID = notificationData[AnyHashable("callId")] as? String ,callID != ""{
                UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
                    print("*************Cal Id \(callID)")
                    if let action = notificationData[AnyHashable("action")] as? String {
                        if action == "4" && (notificationData[AnyHashable("type")] as? String) == "video" {
                            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                        }
                    }
                }
            }
        }else {
            print("************ User Info\(userInfo)")
            if let loginType = notificationData[AnyHashable("msg")] as? String,let deviceId = notificationData[AnyHashable("deviceId")] as? String  {
                if loginType == "login" && deviceId != Utility.DeviceId {
                    Utility.logOut()
                }
            }
            // completionHandler([.sound,.alert,.badge])
        }
    }
    
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
        if let refreshedToken = Messaging.messaging().fcmToken {
            print("FCM token: \(refreshedToken)")
            let defaults = UserDefaults.standard
            defaults.set(refreshedToken , forKey: "USER_INFO.PUSH_TOKEN")
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let refreshedToken = Messaging.messaging().fcmToken {
            print("FCM token: \(refreshedToken)")
            let defaults = UserDefaults.standard
            defaults.set(refreshedToken , forKey: "USER_INFO.PUSH_TOKEN")
        }
    }
    
    
    func setupURLCache() {
        // We want to see all caching actions
        EVURLCache.LOGGING = true
        // We want more than the default: 2^26 = 64MB
        EVURLCache.MAX_FILE_SIZE = 26
        // We want more than the default: 2^30 = 1GB
        EVURLCache.MAX_CACHE_SIZE = 30
        // Use this to force case insensitive filename compare when using a case sensitive filesystem (what OS X can have)
        //        EVURLCache.FORCE_LOWERCASE = true // is already the default. You also have to put all files int he PreCache using lowercase names
        //        // By default cache control settings that come from the server will not be ignored. Here for testing we always ignore it.
        //        EVURLCache.IGNORE_CACHE_CONTROL = true
        //
        //        // You can create your own filtering to prevent using the cache for specific files
        //        EVURLCache.filter { request in
        //            if request.url?.host == "githubbadge.appspot.com" {
        //                return false
        //            }
        //            return true
        //        }
        // Now activate this cache
        
        EVURLCache.activate()
    }
    
    


    

    
    
    //MARK:- Deep linking handling
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return self.handleDeepLinkData(userActivity: userActivity)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                           annotation: "")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            guard let stringUrl = dynamicLink.url?.absoluteString else {return false}
            if stringUrl.contains("\(AppConstants.DynamicLinkUrlForPost)") == true {
                let postId = stringUrl.replacingOccurrences(of: AppConstants.DynamicLinkUrlForPost, with: "")
                guard let posId = postId as? String else {return false}
                print("item id: \(posId)")
                self.openPostDetailsViewController(postId: posId)
            }else if stringUrl.contains(AppConstants.DynamicLinkUrlForProfile) == true{
                let userId = stringUrl.replacingOccurrences(of: AppConstants.DynamicLinkUrlForProfile, with: "")
                guard let useId = userId as? String else {return false}
                print("item id: \(userId)")
                self.openProfileViewController(userId: useId)
            }
            return true
        }
        return false
    }
    
    
    /// To check and get deep link data
     func handleDeepLinkData(userActivity: NSUserActivity)-> Bool{
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            if error == nil{
                guard let link = dynamiclink else{return}
                let stringUrl = link.url?.absoluteString
                if stringUrl?.contains("\(AppConstants.DynamicLinkUrlForPost)") == true {
                    let postId = stringUrl?.replacingOccurrences(of: AppConstants.DynamicLinkUrlForPost, with: "")
                    guard let posId = postId else {return}
                    print("item id: \(posId)")
                    self.openPostDetailsViewController(postId: posId)
                }else if stringUrl?.contains(AppConstants.DynamicLinkUrlForProfile) == true{
                    let userId = stringUrl?.replacingOccurrences(of: AppConstants.DynamicLinkUrlForProfile, with: "")
                    guard let useId = userId else {return}
                    print("item id: \(userId)")
                    self.openProfileViewController(userId: useId)
                }
                
            }
        }
        return handled
    }
    
    
    /// TO open post details controller after getting item id from deep link
     func openPostDetailsViewController(postId: String){
        if AppConstants.appType == .picoadda {
            let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.instaHome, bundle: nil)
            guard let socialDetailsVC = storyboard.instantiateViewController(withIdentifier: String(describing: SocialDetailsViewController.self)) as? SocialDetailsViewController else{return}
            socialDetailsVC.needToCallApi = true
            socialDetailsVC.postId = postId
            
            /*Bug Name :- back button in social details not work while open post through deeplinks
             Fix Date :- 22/03/2021
             Fixed By :- Nikunj C
             Description Of bug :- after open socialDetailsVC through dynamic link not able to go back */
            
            socialDetailsVC.isPresented = true
            let navVC = UINavigationController.init(rootViewController: socialDetailsVC)
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                navVC.modalPresentationStyle = .overCurrentContext
                topRootViewController?.present(navVC, animated: true, completion: nil)
            }
        }else{
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            guard let postDetailsVC = storyboard.instantiateViewController(withIdentifier: "PostDetailsViewController") as? PostDetailsViewController else{return}
            postDetailsVC.isCommingFromChat = true
            postDetailsVC.postId = postId
            postDetailsVC.isViewPresented = true
            let navVC = UINavigationController.init(rootViewController: postDetailsVC)
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                topRootViewController?.present(navVC, animated: true, completion: nil)
            }
            
            /*
             Bug Name :- When we share video via WhatsApp and when open link from WhatsApp the video playing double one original video on app and over its same video playing
             Fix Date :- 10/07/2021
             Fixed By :- Jayaram G
             Description Of Fix :- stopping home video player
             */
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                    if let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController{
                        if let postDetails = swipeNav.viewControllers.first as? PostDetailsViewController{
                            postDetails.stopVideoPlayer()
                        }
                    }
                }
            }
            
        }
    }
    
    /// TO open profile controller after getting item id from deep link
    private func openProfileViewController(userId: String){
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.memberId = userId
        profileVC.isPresented = true
        profileVC.isNotFromTabBar = true
        let navigationController = UINavigationController(rootViewController: profileVC)
        var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
        while ((topRootViewController?.presentedViewController) != nil) {
            topRootViewController = topRootViewController?.presentedViewController
        }
        DispatchQueue.main.async {
            navigationController.modalPresentationStyle = .overCurrentContext
            topRootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MQTT_Chat_Module")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //        DDLogDebug("\(error)")
        //        DDLogDebug("Fail push token \(error)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().isAutoInitEnabled = true
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        NSLog("got RemoteNotification push token \(deviceTokenString)")
        UserDefaults.standard.setValue(deviceTokenString, forKey: AppConstants.UserDefaults.pushToken)
        UserDefaults.standard.synchronize()
        CallAPI.sendCallpushtoServer(with:"")
    }
    
    
    
    func getNameFormDatabase(num:String) -> String{
        
        let favArr  = Helper.getFavoriteDataFromDatabase1()
        let favmutable = favArr
        //        let predicate = NSPredicate.init(format:"registerNum == %@", num)
        //        let fArr =  favmutable.filter({predicate.evaluate(with: $0)})
        let fArr = favmutable.filter { (contact) -> Bool in
            contact.registerNum == num
        }
        if fArr.count ==  0 {
            return num
        }else{
            let contact = fArr[0]
            return contact.fullName!
        }
    }
    
    
 
}

//MARK: - Push Kit
extension AppDelegate : PKPushRegistryDelegate {
    func registerPushNotification() {
        // Create a push registry object
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: nil)
        // Set the registry's delegate to self
        voipRegistry.delegate = self
        // Set the push type to VoIP
        voipRegistry.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType){
        
        let deviceTokenString = credentials.token.reduce("", {$0 + String(format: "%02X", $1)})
        print("ppush device token \(deviceTokenString)")
        UserDefaults.standard.setValue(deviceTokenString, forKey: AppConstants.UserDefaults.callPushToken)
        UserDefaults.standard.synchronize()
        CallAPI.sendCallpushtoServer(with:"")
    }
    
    
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType){
        print("*****VOIP Called")
        callProviderDelegate = CallProviderDelegate.init()
        let msgdict = ["room":payload.dictionaryPayload[AnyHashable("room")],
                       "callId":payload.dictionaryPayload[AnyHashable("callId")],
                       "userImage":payload.dictionaryPayload[AnyHashable("userImage")],
                       "type":payload.dictionaryPayload[AnyHashable("type")],
                       "userId":payload.dictionaryPayload[AnyHashable("userId")],
                       "action":payload.dictionaryPayload[AnyHashable("action")],
                       "userName":payload.dictionaryPayload[AnyHashable("userName")]]
        calleeName = payload.dictionaryPayload[AnyHashable("userName")] as? String ?? "Unknown"
        if msgdict["type"] as? Int == 2{
            let userID = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userID) as? String ?? ""
            let topic = AppConstants.MQTT.calls + userID
            MQTTCallManager.didReceive(withMessage: msgdict as [String : Any], inTopic: topic)
            callProviderDelegate?.displayIncomingcall(uuid : UUID() , handel: "InvalidType" , hasVideo: false,isUpdate: true)
        }else{
            callProviderDelegate?.callID = callID
            callProviderDelegate?.messageData = msgdict as [String : Any]
            var sameVOIPCall : Bool = false
            if let room = payload.dictionaryPayload[AnyHashable("room")] as? String{
                sameVOIPCall =  self.roomIdForVoip ?? "" == room
                self.roomIdForVoip = room
            }
                self.callProviderDelegate?.displayIncomingcall(uuid : UUID() , handel: calleeName , hasVideo: false,isUpdate: sameVOIPCall)
        }
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType){
        DDLogDebug("didFail ......push")
    }
}

//MARK:- Pending Call and remove stream API calls
extension AppDelegate{
    
    func checkPendingcalls() {
        var url = AppConstants.pendingCalls
        if AppConstants.appType == .dubly {
            url = "https://api.besocial.app/calls"
        }
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .get, parameters: nil,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.pendingCalls.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            guard let responseKey = response[AppConstants.resposeTypeKey] as? String else {return}
            if responseKey == AppConstants.resposeType.pendingCalls.rawValue {
                print("pending calls api data \(response["data"])")
                if response["data"] != nil {
                    let storyboard = UIStoryboard(name: "CallKit", bundle: nil)
                    if let data = response["data"] as? [String : Any]{
                        if let room = data["room"] as? String, let callId = data["callId"] as? String, let action = data["action"] as? Int, action == 1, let calltype = data["type"] as? String{
                            self.callID = callId
                            let appdel = UIApplication.shared.delegate as! AppDelegate
                            self.roomId = room
                            if calltype == "audio" {
                                return
                            }
                            guard let callVC = storyboard.instantiateViewController(withIdentifier: String(describing:CallViewController.self)) as? CallViewController else { return }
                            callVC.viewModel.room = Int64(room)
                            callVC.viewModel.callId = callId
                            callVC.showIncomingCall = true
                            callVC.userData = data
                            UserDefaults.standard.set(true, forKey: "iscallgoingOn")
                            callVC.callType = calltype == "audio" ? .Audio : .Video
                            callVC.hidesBottomBarWhenPushed = true
                            UIApplication.shared.keyWindow?.endEditing(true)
                            appdel.window!.addSubview(callVC.view)
                        }
                        
                    }
                }
            }
        }, onError : {error in
        })
    }
    
    ///Service call to remove strem data in stream list
    func removerActiveStreamServiceCall(){
        guard (UserDefaults.standard.value(forKey: AppConstants.UserDefaults.activeStreamId) as? String) != nil else{return}
        
        let url = AppConstants.endStream
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .delete, parameters: nil,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.endStream.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {response in
                
                UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.activeStreamId)
            }, onError : {error in
                
            })
    }
}
extension AppDelegate {
    
    func manageNotifications(info: [AnyHashable :Any]) {
        
        /*
         Bug Name :- Navigating to application according to the notification
         Fix Date :- 23/03/2021
         Fixed By :- Jayaram G
         Description Of Fix :- response was changed from one signal , so handled according to response
         */
        switch info[AnyHashable("type")] as? String{
        case pushType.postCommented:
            self.openPostDetailsPage(pustData: info)
            break
        case pushType.followed:
            self.openUserProfile(pushData: info)
            print("Follow")
            break
        case pushType.following:
            self.openUserProfile(pushData: info)
            print("Following")
            break
        case pushType.followRequest:
            self.openRequestView(pushData: info)
            print("follow request")
            break
        case pushType.channelRequest:
            self.openchannelRequestView(pushData: info)
            print("follow request")
            break
        case pushType.postLiked:
            self.openPostDetailsPage(pustData: info)
            break
        case pushType.newPost:
            self.openPostDetailsPage(pustData: info)
            break
        case pushType.rewardEarned:
            self.openTransactionsView(pushData: info)
            break
        case pushType.liveStream:
            break
        case pushType.channelSubscribe:
            openChannelPostPage(pustData: info)
            break
        case pushType.chatMessage:
            self.openChatController(withData: info)
            break
        default:
            break
        }
    }
    
    func openChatController(withData data: [AnyHashable : Any]) {
        
        
        NSLog("got notification here \(data)")
        
        if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            DispatchQueue.main.async {
                if let controller = tabController.viewControllers?[0] as? UINavigationController {
                    controller.popToRootViewController(animated: false)
                    tabController.selectedIndex = 3
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                UserDefaults.standard.set("", forKey: AppConstants.UserDefaults.isUserOnchatscreen)
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
    
    func openChannelPostPage(pustData: [AnyHashable : Any]){
        
        guard let postId = pustData[AnyHashable("postId")] as? String else{return}
        let postedByVc = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        postedByVc.isChannel = true
        postedByVc.isPresented = true
        postedByVc.hashTagName = postId
        let navVC = UINavigationController.init(rootViewController: postedByVc)
        var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
        while ((topRootViewController?.presentedViewController) != nil) {
            topRootViewController = topRootViewController?.presentedViewController
        }
        DispatchQueue.main.async {
            navVC.modalPresentationStyle = .fullScreen
            topRootViewController?.present(navVC, animated: true, completion: nil)
        }
    }
    
    func openPostDetailsPage(pustData: [AnyHashable : Any]){
        if AppConstants.appType == .picoadda {
            guard let postId = pustData[AnyHashable("postId")] as? String else{return}
            let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.instaHome, bundle: nil)
            guard let postDetailsVC = storyboard.instantiateViewController(withIdentifier: "SocialDetailsViewController") as? SocialDetailsViewController else{return}
            postDetailsVC.isComingFromChat = true
            postDetailsVC.isPresented = true
            postDetailsVC.postId = postId
            postDetailsVC.needToCallApi = true
            let navVC = UINavigationController.init(rootViewController: postDetailsVC)
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                navVC.modalPresentationStyle = .fullScreen
                topRootViewController?.present(navVC, animated: true, completion: nil)
            }
        }else{
            guard let postId = pustData[AnyHashable("postId")] as? String else{return}
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
            
            /*
             Bug Name :- When we share video via WhatsApp and when open link from WhatsApp the video playing double one original video on app and over its same video playing
             Fix Date :- 10/07/2021
             Fixed By :- Jayaram G
             Description Of Fix :- stopping home video player
             */
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                    if let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController{
                        if let postDetails = swipeNav.viewControllers.first as? PostDetailsViewController{
                            postDetails.stopVideoPlayer()
                        }
                    }
                }
            }
        }
    }
    
    func openUserProfile(pushData: [AnyHashable : Any]){
        guard let userId = pushData[AnyHashable("userId")] as? String else{return}
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.memberId = userId
        /*
         Bug Name:- Handle profile tab for self profile and other profile
         Fix Date:- 22/04/21
         Fix By  :- Jayaram G
         Description of Fix:- Passing flag for to hide tabbar
         */
        profileVC.isNotFromTabBar = true
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
    
    func openTransactionsView(pushData: [AnyHashable : Any]){
        //        guard let userId = pushData["userId"] as? String else{return}
        //                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
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
    
    
    
    func openRequestView(pushData: [AnyHashable : Any]){
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
    
    func openchannelRequestView(pushData: [AnyHashable : Any]){
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
    
    
    func openchannelPostsView(pushData: [AnyHashable : Any]){
        let postedByVc = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        postedByVc.isChannel = true
        postedByVc.channelName = ""
        postedByVc.isPresented = true
        
        if let channelId = pushData[AnyHashable("channelId")] as? String {
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
extension UIApplication {
    
    ///It returns top most view controller
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
    return input.rawValue
}
