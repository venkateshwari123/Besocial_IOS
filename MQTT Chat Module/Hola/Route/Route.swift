//
//  Route.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 08/02/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
class Route: NSObject {
    
    
    class func navigateToCamera(navigationController:UINavigationController?, isPresent:Bool = false,isForStory:Bool = false, isFromStoryListVC:Bool = false, isFromChat : Bool = false,isFromPostedByMusicScreen : Bool = false,selectedAudio : Audio? = nil, color:UIColor? = .clear, isFromProfilePage :Bool = false,delegate:CameraViewDelegate? = nil, cameraPickingDelegate : CameraPickingDelegate? = nil, customAudioPath : String? = nil, customAudioUrl : String? = nil){
        
        guard let camVc = UIStoryboard.init(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController else{return}
        camVc.isForStory = isForStory
        camVc.delegate = delegate
        camVc.isFromStoryListVC = isFromStoryListVC
        camVc.view.backgroundColor = color
        camVc.isFromProfilePage = isFromProfilePage
        camVc.chatVcDelegateObj = cameraPickingDelegate
        camVc.isFromChat = isFromChat
        camVc.selectedAudio = selectedAudio
        camVc.customAudioPath = customAudioPath
        camVc.customAudioUrl = customAudioUrl
        if isPresent{
            let newNav = UINavigationController(rootViewController: camVc)
            newNav.isNavigationBarHidden = true
            newNav.modalPresentationStyle = .fullScreen
            navigationController?.present(newNav, animated: true, completion:nil)
        }
        else{
            navigationController?.pushViewController(camVc, animated: false)
        }
    }
    
    class func navigateToInstaDetailsVc(navigationController:UINavigationController?,postsArray:[SocialModel]?, needToCallApi:Bool,postId:String?,delegate:SocialDetailsViewControllerDelegate? = nil,index:Int = -1){
        guard let socialDetailsVC =  UIStoryboard.init(name: AppConstants.StoryBoardIds.instaHome, bundle: nil).instantiateViewController(withIdentifier: String(describing: SocialDetailsViewController.self)) as? SocialDetailsViewController else{return}
        socialDetailsVC.needToCallApi = needToCallApi
        socialDetailsVC.postId = postId
        socialDetailsVC.scrollToSelectedIndex = index
        socialDetailsVC.delegate = delegate
        if postsArray != nil {
            socialDetailsVC.socialViewModel.socialModelArray = postsArray!
        }
        navigationController?.pushViewController(socialDetailsVC, animated: true)
    }
    
    class func  navigateToAllPostsVertically(navigationController:UINavigationController?,  postId:String? = nil, postsArray: [SocialModel]? = nil,profileViewModel:ProfileViewModel? = nil,hashTagName:String? = nil, selectedIndex:Int? = nil,currentIndex:Int? = -1, isCommingFromChat:Bool = false, isFromProfilePage : Bool = false,isCommingFromPostsList:Bool? = false, isComingFromChannelPost:Bool = false,isFromTrendingPage:Bool? = false ,delegate:PostDetailsViewControllerDelegate? = nil ,postedByVcDelegateObj:PostedByViewControllerDelegate? = nil){
        
        
        guard let postDetailsVC =  UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PostDetailsViewController") as? PostDetailsViewController else{return}
        postDetailsVC.postId = postId
        postDetailsVC.isCommingFromChat = isCommingFromChat
        postDetailsVC.hidesBottomBarWhenPushed = true
        postDetailsVC.isFromProfilePage = isFromProfilePage
        postDetailsVC.selectedIndex = selectedIndex ?? 0
        postDetailsVC.currentIndex = currentIndex ?? 0
        postDetailsVC.profileViewModel = profileViewModel ?? ProfileViewModel()
        postDetailsVC.isComingFromChannelPost = isComingFromChannelPost
        postDetailsVC.isCommingFromPostsList = isCommingFromPostsList ?? false
        postDetailsVC.isFromTrendingPage =  isFromTrendingPage ?? false
        postDetailsVC.hashTagName = hashTagName ?? ""
        postDetailsVC.delegate = delegate
        postDetailsVC.postedByVcDelegateObj = postedByVcDelegateObj
        if postsArray != nil{
            postDetailsVC.postDetailsViewModel.socialModelArray = postsArray!
        }
        /* Bug Name : the screen is flickering while switching from a video to other in the exclusive tab
         Fix Date : 10-May-2021
         Fixed By : Jayaram G
         Description Of Fix : animation set to false
         */
        navigationController?.pushViewController(postDetailsVC, animated: false)
    }
    
    class func navigateToCoinWallet(navigationController:UINavigationController?){
        let storyBoard = UIStoryboard(name: "CoinWallet", bundle: nil)
        guard let destinationVC = storyBoard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.CoinWallet) as? CoinWalletViewController else {return}
        destinationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    class func navigateToCoinTransaction(navigationController:UINavigationController?){
        let storyBoard = UIStoryboard(name: "CoinWallet", bundle: nil)
        guard let destinationVC = storyBoard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.CoinTransaction) as? CoinTransactionView else {return}
        destinationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
    class func navigateToLoginVC(vc: UIViewController){
        let loginVC = LoginVC.instantiate(storyBoardName: "Authentication") as LoginVC
        loginVC.isFromHomeVC = true
        let navVC = UINavigationController(rootViewController: loginVC)
        navVC.modalPresentationStyle = .overCurrentContext
        navVC.navigationBar.isHidden = true
        vc.present(navVC, animated: true, completion: nil)

        
    }
    
    class func setRootController(){
        if AppConstants.appType == .picoadda {
            let appdel = UIApplication.shared.delegate as! AppDelegate
            let tabbar : TabbarController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: AppConstants.viewControllerIds.TabBarVC) as! TabbarController
            appdel.window?.rootViewController = tabbar
        }else{
            let appdel = UIApplication.shared.delegate as! AppDelegate
            let tabbar : DublyTabbarViewController = UIStoryboard.init(name: "DublyTabbar", bundle: nil).instantiateViewController(withIdentifier: String(describing: DublyTabbarViewController.self)) as! DublyTabbarViewController
            appdel.window?.rootViewController = tabbar
        }
    }

    /*
     Refactor Name:- update profile while save value
     Refactor Date:- 19/05/21
     Refactor By  :- Nikunj C
     Description of Refactor:- navigate to updateEmailPhoneVC with required details and properties
     */
    
    class func naivgateToUpdateEmailPhoneVC(controller:NewEditProfileViewController? = nil,navigationController:UINavigationController?,userDetails:UserProfileModel,businessEmail:String? = "",email:String? = "",phoneNumber:String? = "",businesPhoneNumber:String? = "",isForBusiness:Bool? = false,isForPhone:Bool? = false,countryCode:String? = "",isVerified:Bool? = false) {
        /// Pushing To BusinessMobileConfigurationViewController
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Profile, bundle: nil)
        let updateEmailPhoneVcId = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.UpdateEmailPhoneViewController) as! UpdateEmailPhoneViewController
        updateEmailPhoneVcId.phoneNumber = phoneNumber ?? ""
        updateEmailPhoneVcId.businessPhoneNumber = businesPhoneNumber ?? ""
        updateEmailPhoneVcId.email = email ?? ""
        updateEmailPhoneVcId.businessEmail = businessEmail ?? ""
        updateEmailPhoneVcId.countryCodeNumber = countryCode ?? ""
        updateEmailPhoneVcId.isForPhone = isForPhone ?? false
        updateEmailPhoneVcId.isForBusiness = isForBusiness ?? false
        updateEmailPhoneVcId.delegateForSave = controller
        updateEmailPhoneVcId.userDetails = userDetails
        updateEmailPhoneVcId.verifiedStatus = isVerified ?? false
        navigationController?.pushViewController(updateEmailPhoneVcId, animated: true)
    }

 
    class func rootToHomeVC() {
        
        let appdel = (UIApplication.shared.delegate) as? AppDelegate
        if AppConstants.appType == .dubly {
            let storyBoard = UIStoryboard.init(name: "DublyTabbar", bundle: nil)
            if UserDefaults.standard.value(forKey: AppConstants.UserDefaults.LoggedInUser) != nil {
                 Utility.setIsGuestUser(status: false)
            }else{
                 Utility.setIsGuestUser(status: true)
            }
            
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = storyBoard.instantiateViewController(withIdentifier: "DublyTabbarViewController")
        }else{
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            if UserDefaults.standard.value(forKey: AppConstants.UserDefaults.LoggedInUser) != nil {
                let indexDocVMObject = IndexDocumentViewModel(couchbase: Couchbase.sharedInstance)
                guard let indexID = indexDocVMObject.getIndexValue(withUserSignedIn: false) else { return }
                guard let indexData = Couchbase.sharedInstance.getData(fromDocID: indexID) else { return }
                //            if (indexData["isUserSignIn"] as? Bool) == true{
                appdel?.window?.rootViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
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
                appdel?.window?.rootViewController = navController
            }
        }
    }
}
