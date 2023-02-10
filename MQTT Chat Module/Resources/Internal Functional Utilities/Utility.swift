//
//  Utility.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 28/03/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Kingfisher
import AVFoundation
import Locksmith
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import OneSignal

class Utility: NSObject {
    
    
   class func createThumbnailOfVideoFromFileURL(videoURL: String) -> UIImage? {
        let asset = AVAsset(url: URL(string: videoURL)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return UIImage(named: "no_image")
        }
    }
    
    class func clearKeychainIfWillUnistall() {
    let freshInstall = !UserDefaults.standard.bool(forKey: "alreadyInstalled")
     if freshInstall {
        KeychainHelper.sharedInstance.clearKeychain()
        UserDefaults.standard.set(true, forKey: "alreadyInstalled")
      }
    }
    
    /// To get user name stored in user defaults
    ///
    /// - Returns: user name
    class func getUserName()-> String{
        guard let userName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else { return ""}
        return userName
    }
    
    class func getUserEmail()-> String{
        guard let userName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userEmail) as? String else { return ""}
        return userName
    }
    
    
    /// To get user id, if user id is there then return user id other wise nil
    ///
    /// - Returns: user id
    class func getUserid()-> String?{
        guard let userId = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userID) as? String else{return nil}
        return userId
    }
    
    
    /// to get user image, return nil if image is not there
    ///
    /// - Returns: user image
    class func getUserImage()-> String?{
        guard let userImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String else{return nil}
        return userImage
    }
    
    /// to get user image, return nil if image is not there
    ///
    /// - Returns: user image
    class func getUserFullName()-> String?{
        guard let userFullName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userFullName) as? String else{return nil}
        return userFullName
    }
    
    /// To get user public name
    ///
    /// - Returns: user public name
    class func getPublicName()-> String{
        guard let userName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNameToShow) as? String else { return ""}
        return userName
    }
    
    
    /// To get user privicy status
    ///
    /// - Returns: user status
    class func getUserPrivicyStatus()-> Int{
        guard let userStatus = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isPrivate) as? Int else { return 0}
        return userStatus
    }
    
    
    /// To get user status
    ///
    /// - Returns: user status
    class func getUserStatus()-> String?{
        guard let userStatus = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userStatus) as? String else { return nil}
        return userStatus
    }
    
    
    /// To get stream id
    ///
    /// - Returns: stream id
    class func getStreamId() -> String?{
        guard let streamId = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.streamID) as? String else{return nil}
        return streamId
    }
    
    
    class func getLoggedInUserProfile() -> User?{
        guard let user = Helper.getObjectFromNSUser(AppConstants.UserDefaults.LoggedInUser) as? User else { return nil}
        return user
    }
    
    class func getFcmToken()-> String{
        guard let userName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.fcmToken) as? String else { return ""}
        return userName
    }
    
    
    class func getUserToken()-> String{
         guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return ""}
        guard  let token = keyDict["token"] as? String  else {return ""}
        return token ?? ""
    }
    
    class func getCurreny()-> String{
         guard let currency = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.currency) as? String else { return ""}
         return currency
     }
    
    class func getCurrenySymbol()-> String{
         guard let currencySymbol = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.currencySymbol) as? String else { return ""}
         return currencySymbol
     }
    
    class func getWalletCurreny()-> String{
         guard let currency = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.walletCurrency) as? String else { return ""}
         return currency
     }
    
    class func getWalletCurrenyName()-> String{
         guard let currencyName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.currencycountryCodeName) as? String else { return "US"}
         return currencyName
     }
    
    class func getWalletCurrenySymbol()-> String{
         guard let currencySymbol = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.walletCurrecnySymbol) as? String else { return ""}
         return currencySymbol
     }
    
    class func getDeviceHasSafeAreaStatus() -> Bool {
        if UIApplication.shared.statusBarFrame.height > 21 {
            return true
        }else {
            return false
        }
    }
    
    class func getAppTheme(){
        
        guard let appdel = UIApplication.shared.delegate as? AppDelegate else {return}
        
        if Utility.isDarkModeEnable(){
            appdel.window?.overrideUserInterfaceStyle = .dark
        }else{
            appdel.window?.overrideUserInterfaceStyle = .light
        }
    }
    
    class func isDarkModeEnable() -> Bool{
        
        if let darkMode = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isDarkModeEnable) as? Bool{
            if darkMode{
                return true
            }
        }
        return false
    }
    
    class func isActiveBusinessProfile() -> Bool{
        if let businessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
            if businessProfile {
                return true
            }
        }
           return false
    }
    
    /// To get busniess unique id, if user id is there then return user id other wise nil
    ///
    /// - Returns: user id
    class func getBusinessUniqueId()-> String{
        guard let businessUniqueId = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessUniqueId) as? String else{return ""}
        return businessUniqueId
    }

    
    
    /*bug Name :- Update wallet balance locally
      Fix Date :- 16/06/2021
      Fixed By :- jayaram G
      Description Of bug :- updating balance
     */
    
    class func updateWalletBalance(deductionAmount:String) {
        if let balance = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.walletBalance) as? String {
            let updatedBalance = (Double(balance) ?? 0.0) - (Double(deductionAmount) ?? 0.0)
            KeychainHelper.sharedInstance.setWalletBalance(balance: "\(updatedBalance)")
            UserDefaults.standard.set("\(updatedBalance)", forKey: AppConstants.UserDefaults.walletBalance)
        }
    }
    
    /// For getting chat doc on respected to receiver ID and secret ID.
    ///
    /// - Parameters:
    ///   - receiverID: receiver ID provided by the contact.
    ///   - secretID: secret ID related to the contact.
    /// - Returns: this will return the chat doc ID respected to receiver ID and secret ID.
    class func fetchIndividualChatDoc(withReceiverID receiverID:String, andSecretID secretID : String) -> String? {
        let couchbase = Couchbase.sharedInstance
        guard let userID = Utility.getUserid() else { return nil }
        guard let indexID = getIndexValue(withUserSignedIn: true) else { return  nil }
        guard let indexData = couchbase.getData(fromDocID: indexID) else { return  nil }
        guard let userIDArray = indexData["userIDArray"] as? [String] else { return  nil }
        if userIDArray.contains(userID) {
            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return nil }
            if let index = userIDArray.index(of: userID) {
                let userDocID = userDocArray[index]
                guard let userDocData = couchbase.getData(fromDocID: userDocID) else { return nil  }
                if let chatDocID = userDocData["chatDocument"] as? String {
                    guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return nil  }
                    guard let receiverUIDArray = chatData["receiverUidArray"] as? [String] else { return nil  }
                    guard let scretIDArray = chatData["secretIdArray"] as? [String] else { return  nil }
                    guard let receiverChatDocIdArray = chatData["receiverDocIdArray"] as? [String] else { return nil  }
                    if !scretIDArray.isEmpty { // For searching the chat doc id.
                        for index in 0 ..< receiverUIDArray.count {
                            let reciverIDL = receiverUIDArray[index]
                            if (receiverID == reciverIDL ) {
                                if scretIDArray[index] == secretID {
                                    return receiverChatDocIdArray[index]
                                }
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    
    class func setIsGuestUser(status : Bool) {
        if AppConstants.appType == .dubly {
            UserDefaults.standard.set(status, forKey: AppConstants.UserDefaults.isGuestLogin)
        }else{
            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isGuestLogin)
        }

        UserDefaults.standard.synchronize()
    }
    
    class func makePostsSize(frame: CGRect) -> CGSize {
        let width = frame.size.width / 3
        let height = (width - 5) * 5 / 4
        if AppConstants.appType == .picoadda {
            return CGSize(width: width - 3, height: width - 3)
        }else{
            return CGSize(width: width - 3, height: height)
        }
    }
    
    class func setDefautlCoverImage() -> UIImage {
        return AppConstants.appType == .picoadda ? #imageLiteral(resourceName: "bannerImage") : #imageLiteral(resourceName: "bannerImage")
    }
    class func appColor() -> UIColor {
        return Helper.hexStringToUIColor(hex: AppColourStr.appColor)
    }
    
    class func fetchIpDetails() {
        if let url = URL(string: "http://www.geoplugin.net/json.gp") {
            do {
                let contents = try String(contentsOf: url)
                
                if let data = contents.data(using: String.Encoding.utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                            print(json)
                            
                        }
                    } catch {
                        print("Something went wrong")
                    }
                }
            } catch {
                // contents could not be loaded
            }
        } else {
            // the URL was bad!
        }
    }
    
    /// Used for getting the index DocID. If its there then return the existing one or else create a new one.
    ///
    /// - Returns: String value of index document ID.
    class func getIndexValue(withUserSignedIn isUserSignedIn : Bool) -> String? {
        if let indexDocID = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.indexDocID) as? String {
            if indexDocID.count>1 {
                return indexDocID
            } else {
                return Utility.createIndexDB(withUserSignedIn: isUserSignedIn)
            }
        } else {
            return Utility.createIndexDB(withUserSignedIn: isUserSignedIn)
        }
    }
    
    /// Used for creating Index DB initially
    ///
    /// - Parameter isUserSignedIn: with Adding value for isUserSignedIn
    /// - Returns: Document ID of created index document.
    class func createIndexDB(withUserSignedIn isUserSignedIn : Bool) -> String? {
        let couchbase = Couchbase.sharedInstance
        let userDocVMObj = UsersDocumentViewModel(couchbase: couchbase)
        let indexDocID = CouchbaseManager.createInitialCouchBase(withUserSignedIn: isUserSignedIn)
        UserDefaults.standard.set(indexDocID, forKey: AppConstants.UserDefaults.indexDocID)
        guard let userID = Utility.getUserid() else { return nil }
        userDocVMObj.getUserDocuments(forUserID: userID)
        UserDefaults.standard.synchronize() //why its fetching ? Need to check here.
        return indexDocID
        
    }

    
    
    /// To store follow list in database
    ///
    /// - Parameters:
    ///   - coucbase: database object
    ///   - modelArray: array of follow list
    class func storeFollowListInDatabase(couchbase: Couchbase, modelArray: [Any]){
        let data = [Strings.FollowListStrings.followList : modelArray]
        if let docId = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.followDocumentId) as? String{
            couchbase.updateFollowListDocument(data:data as [String : Any] , toDocID: docId)
        }else{
            let contactDocID = couchbase.createDocument(withProperties: data as [String : Any])
            UserDefaults.standard.set(contactDocID, forKey: AppConstants.UserDefaults.followDocumentId)
        }
    }
    
    class func navigationController() -> SwipeNavigationController?{
        let rootVC : RootViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! RootViewController
        if let cell : collectionControllersCell = rootVC.collectionControllers.cellForItem(at: rootVC.collectionControllers.indexPathsForVisibleItems.first!) as? collectionControllersCell{
            if let tabbarVC : TabbarController = cell.subviews.last?.parentViewController as? TabbarController{
                print(tabbarVC.viewControllers as Any)
                if let nav = (tabbarVC.viewControllers![tabbarVC.selectedIndex] as? SwipeNavigationController){
                    return nav
                }
            }
        }
        return nil
    }
    
    
    /// To update follow list in database after pagging
    ///
    /// - Parameters:
    ///   - couchbase: Couchbase object
    ///   - modelArray: follow list to append
    class func updateFollowListInDatabase(couchbase: Couchbase, modelArray: [Any]){
        if let docId = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.followDocumentId) as? String{
            guard let data = couchbase.getData(fromDocID: docId) else{return}
            guard var followArray = data[Strings.FollowListStrings.followList] as? [Any] else{return}
            followArray.append(contentsOf: modelArray)
            let updatedData = [Strings.FollowListStrings.followList : followArray]
            couchbase.updateFollowListDocument(data:updatedData as [String : Any] , toDocID: docId)
        }else{
            let data = [Strings.FollowListStrings.followList : modelArray]
            let contactDocID = couchbase.createDocument(withProperties: data as [String : Any])
            UserDefaults.standard.set(contactDocID, forKey: AppConstants.UserDefaults.followDocumentId)
        }
    }
    
    /// To get follow list from database
    ///
    /// - Parameter coucbase: couchbase object
    /// - Returns: follow list
    class func getFollowListFromDatabase(couchbase: Couchbase) ->[Any]{
        guard let docId = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.followDocumentId) as? String else{return []}
        guard let data = couchbase.getData(fromDocID: docId) else{return []}
        guard let followArray = data[Strings.FollowListStrings.followList] as? [Any] else{return []}
        return followArray
    }
    
    
    
    /// Author:- Jayaram G
    /// To Set the navigation bar for push View Controller
    ///
    ///- Returns:barbuttonitem
    
    /*bug Name :- back button in social details not work while open post through deeplinks
      Fix Date :- 22/03/2021
      Fixed By :- Nikunj C
      Description Of bug :- add action parameters to give action while use this function*/
    
    class func navigationBar(inViewController viewController: UIViewController, title : String, action: Any = #selector(UIViewController.backAction)) -> UIBarButtonItem{
        viewController.title = title
        viewController.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: Utility.Font.Bold.ofSize(17)])
        viewController.navigationController?.navigationBar.tintColor = .black
        let barbuttonitem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_arrow"), style: .plain, target: viewController, action: #selector(UIViewController.backAction))
        if #available(iOS 13.0, *) {
            barbuttonitem.tintColor = .label
        } else {
            // Fallback on earlier versions
        }
        viewController.navigationController?.interactivePopGestureRecognizer?.delegate = viewController as? UIGestureRecognizerDelegate
        return barbuttonitem
    }
    
    /// Author:- Jayaram G
    /// To Set the navigation bar for present View Controller
    ///
    ///- Returns:barbuttonitem
    class func navigationBarForPresent(inViewController viewController: UIViewController, title : String) -> UIBarButtonItem{
        viewController.title = title
        viewController.navigationController?.navigationBar.tintColor = .black
        let barbuttonitem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_arrow"), style: .plain, target: viewController, action: #selector(UIViewController.dismissVcAction))
        viewController.navigationController?.interactivePopGestureRecognizer?.delegate = viewController as? UIGestureRecognizerDelegate
        return barbuttonitem
    }
    
    
    class func navigationBarWithLeftRight(_ title : String, inViewController viewController : UIViewController, rightButton : UIBarButtonItem?,action:Selector? = #selector(UIViewController.backAction)){
        viewController.title = title
        viewController.navigationController?.isNavigationBarHidden = false
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utility.Font.Bold.ofSize(17)]
        viewController.navigationController?.navigationBar.tintColor = .black
        let barbuttonitem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_arrow"), style: .plain, target: viewController, action: action)
        viewController.navigationItem.leftBarButtonItem = barbuttonitem
        if rightButton != nil {
            viewController.navigationItem.rightBarButtonItem = rightButton
        }
        viewController.navigationController?.interactivePopGestureRecognizer?.delegate = viewController as? UIGestureRecognizerDelegate
        //        return viewController.navigationController!.navigationBar
    }
    
    class func updateWalletBalance() {
        ApiHelper.shared.getWallet(userId: Utility.getUserid() ?? "") { _ in
            print("wallet updated")
        }
    }
    
    
    class func getDeviceHeight()-> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        return screenHeight
    }
    
    
    //MARK:- Activate and deactivate audio session on speaker
    class func setSessionPlayerOn(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch _ {
        }
    }
    
    class func setSessionPlayerOff(){
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ {
        }
    }
    
 
    class func subscribeToOneSignal(externalUserId: String) {
//        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
//        print("******DEVICE ID \(deviceID)")
            // Setting External User Id with Callback Available in SDK Version 2.13.1+
            OneSignal.setExternalUserId(externalUserId) { (results) in
                // The results will contain push and email success statuses
                print("External user id update complete with results: ", results!.description)
                // Push can be expected in almost every situation with a success status, but
                // as a pre-caution its good to verify it exists
                if let pushResults = results!["push"] {
                  print("Set external user id push status: ", pushResults)
                }
                if let emailResults = results!["email"] {
                    print("Set external user id email status: ", emailResults)
                }
            } withFailure: { (error) in
                print(error)
            }
        }
        
       class func unsubscribeOneSignal(externalUserId: String) {
        // Removing External User Id with Callback Available in SDK Version 2.13.1+
        OneSignal.removeExternalUserId({ results in
            // The results will contain push and email success statuses
            print("External user id update complete with results: ", results!.description)
            // Push can be expected in almost every situation with a success status, but
            // as a pre-caution its good to verify it exists
            if let pushResults = results!["push"] {
                print("Remove external user id push status: ", pushResults)
            }
            // Verify the email is set or check that the results have an email success status
            if let emailResults = results!["email"] {
                print("Remove external user id email status: ", emailResults)
            }
        })
        }
    
    
    
    //MARK:- Logout related operations
    /// To get log out
    class func logOut(){
        self.setLastSeenStatus(withOfflineStatus: true)
        if let oneSignalId = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.oneSignalId) as? String {
            Utility.unsubscribeOneSignal(externalUserId: oneSignalId)
        }
        let currency = Utility.getWalletCurreny()
        let isDarkMode = Utility.isDarkModeEnable()
        var isStarverified = false
        var isBusinessProfileCreated = false
        let langCode = Utility.getSelectedLanguegeCode()
        
        if let isStarVerified = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile) as? Bool{
            isStarverified = isStarVerified
        }
        
        if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool{
            isBusinessProfileCreated = businessProfileCreated
        }
        
        
        self.unsubscribeAllMQTTTopics()
        self.deleteAllDocumetsFromDataBase()
        self.deleteAllUserDefaultsData()
        /* Bug Name :- After deleting the user and opening app with same user, it is struck in the home page
          Fix Date :- 10/07/2021
          Fixed By :- Jayaram G
          Description Of bug :- setup guest user true
         */
        Utility.setLanguageCode(lang: langCode)
        UserDefaults.standard.set(isStarverified, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
        UserDefaults.standard.set(isBusinessProfileCreated, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
        Utility.setIsGuestUser(status: true)
        UserDefaults.standard.set(isDarkMode, forKey: AppConstants.UserDefaults.isDarkModeEnable)
        // clearing keychain
        let walletID = KeychainHelper.sharedInstance.getWalletId()
        UserDefaults.standard.set(currency, forKey: AppConstants.UserDefaults.walletCurrency)
        KeychainHelper.sharedInstance.clearKeychain()
        do{
        try Locksmith.deleteDataForUserAccount(userAccount: AppConstants.keyChainAccount)
        }catch{
            
        }
        
        /*
         Bug Name:- after logout and login with email not get wallet id
         Fix Date:- 27th Oct 2021
         Fixed By:- Nikunj C
         Description of Fix:- store wallet id in keychain after clear keychain
         */
        
        KeychainHelper.sharedInstance.setWalletId(id: walletID)
        DispatchQueue.main.async {
            URLCache.shared.removeAllCachedResponses()
            let cache = ImageCache.default
            cache.clearMemoryCache()
            cache.clearDiskCache { print("Done") }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                if AppConstants.appType == .picoadda {
                    /* Bug Name :- User should login to see home page
                      Fix Date :- 17/05/2021
                      Fixed By :- Jayaram G
                      Description Of bug :- Changed redirections to loginVC
                     */
                    /*
                     Bug Name :- Need to add background image scrolling
                     Fix Date :- 25/05/2021
                     Fixed By :- Jayaram G
                     Description Of Fix :- Changed intial rootviewcontroller
                     */
                    let scrollingImageVc = ScrollingImageVC.instantiate(storyBoardName: "Authentication") as ScrollingImageVC
                    let navController = UINavigationController(rootViewController: scrollingImageVc)
                    navController.isNavigationBarHidden = true
                    appDelegate.window?.rootViewController = navController
                }else{
                    let appdel = UIApplication.shared.delegate as! AppDelegate
                    let tabbar : DublyTabbarViewController = UIStoryboard.init(name: "DublyTabbar", bundle: nil).instantiateViewController(withIdentifier: String(describing: DublyTabbarViewController.self)) as! DublyTabbarViewController
                    appdel.window?.rootViewController = tabbar

                }
                appDelegate.registerPushNotification()
            }
            }
    }
    
    
    /// To set last seen of user
    class func setLastSeenStatus(withOfflineStatus status: Bool){
        guard let selfID = Utility.getUserid() else { return }
        var lastStatus = true
        if (UserDefaults.standard.object(forKey:"\(selfID)+Last_Seen") as? Bool) != nil{
            lastStatus = false
        }
        MQTTChatManager.sharedInstance.sendOnlineStatus(withOfflineStatus: status , isLastSeenEnable: lastStatus)
    }
    
    class func getIsGuestUser()-> Bool? {
        guard let isGuestUser = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isGuestLogin) as? Bool else{return nil}
        return isGuestUser
    }
    
    class func getSelectedLanguegeCode() -> String{
        guard let lang = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.currentLang) as? String else{return "en"}
        return lang
    }
    
    class func setLanguageCode(lang:String) {
        UserDefaults.standard.setValue(lang, forKey: AppConstants.UserDefaults.currentLang)
        UserDefaults.standard.synchronize()
    }

    
    class func updateDataAfterSwitchingProfile(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        self.deleteAllDocumetsFromDataBase()
        self.deleteAllUserWhileSiwtchingUser()
        complitation(true,nil)
    }
    
    
    /// To unsubscribe from all mqtt topic
     class func unsubscribeAllMQTTTopics(){
        guard let userID = Utility.getUserid() else { return }
        let mqtt = MQTT.sharedInstance
//        var topic: String = AppConstants.MQTT.contactSync + userID
//        mqtt.unsubscribeTopic(topic: topic)
        var topic = AppConstants.MQTT.userUpdates + userID
        mqtt.unsubscribeTopic(topic: topic)
        topic = AppConstants.MQTT.messagesTopicName+userID
        mqtt.unsubscribeTopic(topic: topic)
        topic = AppConstants.MQTT.groupChats+userID
        mqtt.unsubscribeTopic(topic: topic)
        topic = AppConstants.MQTT.acknowledgementTopicName+userID
        mqtt.unsubscribeTopic(topic: topic)
        topic = AppConstants.MQTT.calls+userID
        mqtt.unsubscribeTopic(topic: topic)
        topic = AppConstants.MQTT.getMessages+userID
        mqtt.unsubscribeTopic(topic: topic)
        topic = AppConstants.MQTT.getChats+userID
        mqtt.unsubscribeTopic(topic: topic)
        mqtt.disconnectMQTTConnection()
        mqtt.manager = nil
    }
    
    
    /// To delete all data in userdefauls related to user
       private class func deleteAllUserWhileSiwtchingUser(){
           UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.indexDocID)
           UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.isUserOnchatscreen)
           UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.receiverIdentifier)
           UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.contactDocumentID)
           UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.CallHistryDocumentID)
           UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.CallHistryDocumentID)
           UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.GroupChatsDocument)
       }
    
    
    /// To delete all data in userdefauls related to user
    private class func deleteAllUserDefaultsData(){
        let domain = Bundle.main.bundleIdentifier!
        
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        Utility.setLanguageCode(lang: Utility.getSelectedLanguegeCode())
        
    }
    
    
    /// to delete all document all data form couchbase database
    private class func deleteAllDocumetsFromDataBase(){
        do {
            let bgDB = try CBLManager.sharedInstance().databaseNamed(AppConstants.CouchbaseConstant.dbName)
            let query = bgDB.createAllDocumentsQuery()
            query.descending = true
            do {
                let result =  try query.run()
                for data in result{
                    guard let queryRow = data as? CBLQueryRow else {continue}
                    let document = bgDB.document(withID: queryRow.documentID!)
                    do {
                        try document?.delete()
                    }catch let deleteError{
                        print("error \(deleteError.localizedDescription)")
                    }
                }
            }catch let queryError{
                print("error \(queryError.localizedDescription)")
            }
        }catch let dbCreationError{
            print("error \(dbCreationError.localizedDescription)")
        }
    }
    
    class func createMQTTConnection() {
        let mqttModel = MQTT.sharedInstance
        mqttModel.createConnection()
        //        self.subscribeAllMQTTTopics()
    }
    
    
   class func creatDocforGroupChat(){
        //Creat FirstTime GroupChatsDocument here
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument) as? String
        if documentID ==  nil{
            let contactDocID =   Couchbase.sharedInstance.createDocument(withProperties: ["GroupChatsDocument":["i":"i"]] as [String : Any])
            UserDefaults.standard.set(contactDocID, forKey: AppConstants.UserDefaults.GroupChatsDocument)
        }
    }
    
    /// Author:- Jayaram G
    /// TO set the Font styles Regular and bold
    ///
    /// - Regular: For regualar font Style
    /// - Bold: For Bold font style
    enum Font{
        case Regular, Bold, SemiBold
        func ofSize(_ size : CGFloat) -> UIFont{
            if AppConstants.appType == .picoadda {
                switch self {
                case .Regular:
                    return UIFont.init(name: "Poppins-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
                case .Bold:
                    return UIFont.init(name: "Poppins-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
                case .SemiBold:
                    return UIFont.init(name: "Poppins-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
                }
            }else{
                switch self {
                case .Regular:
                    return UIFont.init(name: "RobotoCondensed-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
                case .Bold:
                    return UIFont.init(name: "RobotoCondensed-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
                case .SemiBold:
                    return UIFont.init(name: "RobotoCondensed-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
                }
            }
        }
    }
    
    
    /// Author:- Jayaram G
    /// TO set the Font styles Regular and bold
    ///
    /// - Regular: For regualar font Style
    /// - Bold: For Bold font style
    enum DublyFont{
        case Regular, Bold, SemiBold,BoldItalic, LightItalic
        func ofSize(_ size : CGFloat) -> UIFont{
            switch self {
            case .Regular:
                return UIFont.init(name: "RobotoCondensed-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
            case .Bold:
                return UIFont.init(name: "RobotoCondensed-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
            case .SemiBold:
                return UIFont.init(name: "RobotoCondensed-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
            case .BoldItalic:
                return UIFont.init(name: "RobotoCondensed-BoldItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
            case .LightItalic:
                return UIFont.init(name: "RobotoCondensed-Italic", size: size) ?? .italicSystemFont(ofSize: 14)

            }
        }
    }
    
    
    class func storePostsViewersInDatabase(couchbase: Couchbase, viewer: [String:Any]){
         if let docId = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.postsViewersDocId) as? String,let data = couchbase.getData(fromDocID: docId),var viewersArray = data[Strings.postsViewers] as? [[String:Any]] {
             viewersArray.append(viewer)
             let updatedData = [Strings.postsViewers : viewersArray]
             couchbase.storePostsViewersData(data:updatedData as [String : Any] , toDocID: docId)
         }else{
             let data = [Strings.postsViewers : [viewer]]
             let docID = couchbase.createDocument(withProperties: data as [String : Any])
             UserDefaults.standard.set(docID, forKey: AppConstants.UserDefaults.postsViewersDocId)
         }
     }
    
    
    class func getViewersFromDatabase(couchbase: Couchbase) ->[[String:Any]]{
          guard let docId = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.postsViewersDocId) as? String else{return []}
          guard let data = couchbase.getData(fromDocID: docId) else{return []}
        guard let viewersArray = data[Strings.postsViewers] as? [[String:Any]] else{return []}
          return viewersArray
      }
    
    
    //To open setting page of app to grant permission
    class func openSettingsPage(message: String) {
        Helper.showAlertViewWithTwoOption(Strings.PermissionMessage.permissionDenied.localized, message: message) { (isSettings) in
            if isSettings{
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
                            // Handle
                        })
                    }
                }
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
