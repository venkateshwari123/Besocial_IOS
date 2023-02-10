//
//  ProfileViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 15/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//  Author :- Jayram G

import UIKit
import MessageUI
import Kingfisher
import AVKit
import DGElasticPullToRefresh
protocol ProfileViewControllerDelegate: AnyObject {
    func headerButtonSelected(index: Int)
}
protocol UpdatingHomePagePosts: AnyObject {
    func updatePosts()
    func updatePosts(cellIndex:Int,followStatus:Bool)
}
class ProfileViewController: UIViewController,ReportViewDelegate {
    
    
    //MARK:- Outlets
    @IBOutlet weak var optionBtnOutlet: UIButton!
    @IBOutlet weak var discoverBtnOutlet: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var navUserNameLabel: UILabel!
    @IBOutlet weak var followImageView: UIImageView!
    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var loaderViewOutlet: UIActivityIndicatorView!
    @IBOutlet weak var backBtnOutlet: UIBarButtonItem!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var barButtonView: UIView!
    @IBOutlet weak var floatingButtonOutlet: UIButton!
    
    
    
   
    
    //MARK:- Variables And Declarations
    var userName: String?
    var userFullName: String?
    var statusChanged = false
    var isAccountPrivate = false
    var followedAction: (()->())!
    let profileViewModel = ProfileViewModel()
    var canPostServiceCall: Bool = false
    var canBookMarkServiceCall:Bool = false
    var canUnLockPostServiceCall:Bool = false
    var canTagServiceCall: Bool = false
    var canLikeServiceCall: Bool = false
    let contactInfoTableViewModel = ContactInfoTableViewModel()
    var storyDataArray = [postModel]()
    var selectedIndex: Int = 0
    var isTap: Bool = false
    var safeAreaHeight: CGFloat = 45
    var extraStandardHeight: CGFloat = 0
    var isSelf: Bool = false
    var userNameTag: String?
    var memberId: String?
    var isChanged: Bool = false
    var isPresented: Bool = false
    var isAppearedFirst: Bool = false
    var value: Int?
    var floaty = Floaty()
    var fromBusinessProfile:Bool = false
    var userProfile : UserProfile!
    var isScrollingVertically:Bool = false
    var isFromPostDetailsPage:Bool = false
    var updatingHomePagePostsObject:UpdatingHomePagePosts?
    let socialViewModel = SocialViewModel()
    var isNotFromTabBar :Bool = false
    var needToRefresh:Bool = true
    let viewModel = WalletViewModel()
    var forYouPostSelectedCellIndex:Int?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshProfileData), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.updateProfileData), name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshHomeScreen), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.getUserDetailsService), name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshUserDetails), object: nil)


//        if isSelf {
//            self.setFloatingButton()
//        }
        setViewUI()
        self.updateProfileData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            self.tabBarController?.tabBar.backgroundColor = UIColor.systemBackground
            self.tabBarController?.tabBar.backgroundImage = UIImage.init(color: UIColor.systemBackground)
        } else {
            self.tabBarController?.tabBar.backgroundColor = UIColor.white
            self.tabBarController?.tabBar.backgroundImage = UIImage.init(color: UIColor.white)
            // Fallback on earlier versions
        }
        self.tabBarController?.tabBar.isTranslucent = false
        
        if Utility.isDarkModeEnable(){
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .darkContent
        }
        
        /*
         Bug Name:- Profile not updating immediately
         Fix Date:- 09/07/21
         Fixed By:- Jayaram G
         Description of Fix:- Setting flag true to update data
         */
        if let profileUpdate = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.profileUpdate) as? Bool {
            if profileUpdate {
                self.getUserDetailsService()
            }
        }
        
        if let likeUpdate = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.likeUpdate) as? Bool {
            if likeUpdate {
                profileViewModel.likeModelArray.removeAll()
                profileViewModel.likeOffset = -20
                self.getLikeService()
            }
        }
        
        if let postUpdate = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.postUpdate) as? Bool {
            if postUpdate {
                profileViewModel.postOffset = -20
                profileViewModel.postModelArray.removeAll()
                getPostService()
                self.getUserDetailsService()
            }
        }
        
        if let channelUpdate = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.channelUpdate) as? Bool {
            if channelUpdate {
                profileViewModel.channelModelArray.removeAll()
                profileViewModel.channelOffset = -20
//                self.getChannelService()
            }
        }
        
        if let bookMarkUpdate = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.bookMarkUpdate) as? Bool {
            if bookMarkUpdate {
                profileViewModel.bookMarkedArray.removeAll()
                profileViewModel.bookMarkOffset = -20
                self.getBookMarksData()
            }
        }
        
        if let isFromTabProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isFromTabProfile) as? Bool {
            if isFromTabProfile {
                self.isSelf = true
                DispatchQueue.main.async {
                    self.tabBarController?.tabBar.isHidden = false
                    self.navigationController?.tabBarController?.tabBar.isHidden = false
                }
            }else{
                self.navigationController?.tabBarController?.tabBar.isHidden = isNotFromTabBar
                self.tabBarController?.tabBar.isHidden = isNotFromTabBar
            }
        }else{
            self.navigationController?.tabBarController?.tabBar.isHidden = isNotFromTabBar
            self.tabBarController?.tabBar.isHidden = isNotFromTabBar
        }
      
        self.backButtonOutlet.isHidden = !isNotFromTabBar
        
        /*
         Bug Name:- Wallet balance not updating afte receiving gifts
         Fix Date:- 25/05/21
         Fix By  :- Jayaram G
         Description of Fix:- refreshing wallet balance
         */
        if let walletUpdate = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.walletUpdate) as? Bool {
            if walletUpdate {
                viewModel.getWalletDetails()
            }
        }
        
        self.floaty.paddingY = self.tabBarController?.tabBar.frame.size.height ?? 0.0
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "walletStatement"), object: nil)
        super.viewWillAppear(animated)
        self.changeNavItemColor(to: UIColor.white)
        self.profileTableView.reloadData()
        self.navigationController?.navigationBar.layer.zPosition = -1;
        self.navigationController?.navigationBar.isHidden = true
     }
        
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view) { [self] (status) in
            if status && !needToRefresh{
//                self.refreshData()
            }else{
                needToRefresh = false
            }
        }
        
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.likeUpdate)
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.channelUpdate)
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.postUpdate)
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.bookMarkUpdate)
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isFromTabProfile)
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.walletUpdate)
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.profileUpdate)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.layer.zPosition = 0
//        self.navigationController?.tabBarController?.tabBar.isHidden = true
//        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        floaty.close()
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "openCameraForPost"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    override func viewWillLayoutSubviews() {
        if #available(iOS 11.0, *) {
            safeAreaHeight = self.view.safeAreaInsets.top
            if safeAreaHeight > 64{
                extraStandardHeight = 33
            }
//            self.profileTableView.reloadData()
        }
    }
    
    
    deinit {
        print("Deinit get called")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func updateProfileData(){
        getUserDetailsService()
                  if isSelf{
                      profileViewModel.postOffset = -20
                      profileViewModel.postModelArray.removeAll()
                      getPostService()
                  }
    }
    
    /// To setup header view UI
    func setHeaderViewUI(cell: UserProfileHeaderTableViewCell){
        var userImaegeString: String?
        var coverImageString:String?
        var userStatus: String?
        var userQrCode:String?
        var userPrivacy:Int?
        var rucBalance:Double?
        var starRequest:StarProflie?
        var businessId:String?
        var businessCategory:String?
        var businessWebsite:String?
        var businessBio:String?
        var businessAddress:String?
        var businessEmailDetails:BusinessEmail?
        var businessMobileDetails:BusinessPhone?
        var isStar:Int = 0
        var starKnownAs:String?
        var businessChatIsVisible:Int?
        var businessProfileImage: String?
        var businessCoverImage: String?
        var isActiveBusinessProfile:Int?
        var businessName:String?
        var businessUserName:String?
        if let data = profileViewModel.userProfileModel{
            isStar = data.isStar
            userImaegeString = data.profilePic
            self.userFullName = data.firstName + " " + data.lastName
            
            self.userName = data.userName
            //  userName = data.userName
            userStatus = data.status
            coverImageString = data.coverImage
            userPrivacy = data.privicy
            rucBalance = data.rucBalance
            starRequest = data.starRequest
            businessCategory = data.businessDetails.first?.businessCategoryName
            businessWebsite = data.businessDetails.first?.businessWebsite
            businessBio = data.businessDetails.first?.businessBio
            isStar = data.isStar
            if let businessEmailData = data.businessDetails.first?.businessEmail {
                businessEmailDetails = businessEmailData
            }
            if let businessMobileData = data.businessDetails.first?.businessPhone {
                businessMobileDetails = businessMobileData
            }
            businessChatIsVisible = data.businessDetails.first?.isChatvisible
            businessProfileImage = data.profilePic
            businessCoverImage = data.businessDetails.first?.businessCoverImage ?? ""
            businessAddress = "\(data.businessDetails.first?.businessStreetAddress ?? ""),\(data.businessDetails.first?.businessCity ?? ""),\(data.businessDetails.first?.businessZipCode ?? "")"
            businessId = data.businessDetails.first?.businessCategoryId
            businessName = data.businessDetails.first?.businessName
            businessUserName = data.businessDetails.first?.businessUserName
            isActiveBusinessProfile = data.businessProfileActive
            /*
             Bug Name:- always show userstatus in setup business profile screen
             Fix Date:- 23/04/21
             Fixed By  :- Nikunj C
             Description of Fix:- Save userStatus in userdefault
             */
//            if !isSelf {
//                if data.businessDetails.count > 0 {
//                    isActiveBusinessProfile = 1
//                }else{
//                    isActiveBusinessProfile = 0
//                }
//            }else{
//                isActiveBusinessProfile = data.businessProfileActive
//            }
          
            if isActiveBusinessProfile == 1{
                UserDefaults.standard.set(businessBio, forKey: AppConstants.UserDefaults.userStatus)
            }else{
                UserDefaults.standard.set(userStatus, forKey: AppConstants.UserDefaults.userStatus)
            }
        }else if self.isSelf{
            if let image = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String{
                userImaegeString = image
            }
            if let name = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String{
                self.userName = name
            }
            
            if let fullName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userFullName) as? String{
                self.userFullName = fullName
            }
            if let status = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userStatus) as? String{
                userStatus = status
            }
            if let qrCode = self.profileViewModel.userProfileModel?.qrCode {
                userQrCode = qrCode
            }
            if let coverImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.coverImage) as? String{
                coverImageString = coverImage
            }
            
            /*
             feat:- add starKnownAs instead of full name for star user
             feat Date:- 30/04/21
             feat by  :- Nikunj C
             Description of feat:- add starKnownAs value
             */
            if let verified = profileViewModel.userProfileModel?.starRequest{
                if let starKnown = verified.starUserKnownBy{
                    starKnownAs = starKnown
                }
            }
            
        }
        cell.setHeaderView(isMine: self.isSelf, userName: self.userName, name:self.userFullName , status: userStatus, image: userImaegeString, coverImage: coverImageString,starRequest: starRequest,balance: rucBalance, businessId: businessId, businessCategory: businessCategory, businessAddress: businessAddress, businessWebsite: businessWebsite, businessBio: businessBio,isStar: isStar,starKnownAs: starKnownAs, businessEmailDetails: businessEmailDetails, businessMobileDetails: businessMobileDetails,businessChatIsVisible:businessChatIsVisible, businessprofileImage: businessProfileImage, businessCoverImage: businessCoverImage, isActiveBusinessProfile: isActiveBusinessProfile, businessName: businessName, businessUserName: businessUserName)
        cell.contentView.updateConstraints()
        cell.contentView.layoutIfNeeded()
    }
    
    /// To set navigation view and it's items
    func setViewUI(){
        
        /*Bug Name :- profile header discover button visibility issue
          Fix Date :- 22/03/2021
          Fixed By :- Nikunj C
          Description Of Fix :-  if isself or userdefault value is true then unhide followImageView button*/
        
        if let isSelfUserDefault = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isFromTabProfile),isSelfUserDefault as! Bool || isSelf {
            self.followImageView.image = UIImage(named: "adduser_black")
        }else{
            self.followImageView.image = UIImage(named: "share_deep_icon_1")
        }
        self.navigationView.backgroundColor = UIColor.clear
        self.backButtonOutlet.tintColor = UIColor.white
        self.followImageView.tintColor = UIColor.white
        self.optionImageView.tintColor = UIColor.white
        
        /*
         Feat Name:- need to add pull to refresh in profile page
         Feat Date:- 13th July 2021
         Feat By  :- Nikunj C
         Description of Feat:- add refreshController
         */
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        profileTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.refreshData()
            }, loadingView: loadingView)
        profileTableView.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        profileTableView.dg_setPullToRefreshBackgroundColor(profileTableView.backgroundColor!)
    }
    
    //To make gradient color on a view
    func makeGradiantColor(onView: UIView, topColor: UIColor, bottomColor: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = Strings.maskLayer
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = onView.bounds
        onView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    
    //MARK:- Service call
    @objc func getUserDetailsService(){
        var strUrl: String = AppConstants.userProfile
        var params = [String:Any]()
        if !isSelf{
            if var nameTag = self.userNameTag{
                strUrl = AppConstants.memberProfile + "?memberId=\(nameTag)"
            }else if let id = self.memberId{
                strUrl = AppConstants.memberProfile + "?memberId=\(id)"
            }
        }
        profileViewModel.isSelf = self.isSelf
        profileViewModel.userDetailsService(strUrl: strUrl, params: nil) { (success, error, canServiceCall) in
            self.profileTableView.dg_stopLoading()
            if success{
                if let userId = self.profileViewModel.userProfileModel?.userId {
                    if userId == Utility.getUserid() {
                        self.isSelf = true
                    }else{
                        self.isSelf = false
                    }
                }
                self.setUpServicesAndHeader()
                
            }else if let error = error{
                if error.code == 204 {
                    self.profileTableView.dg_stopLoading()
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: "User Not Found".localized + ".")
                }
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                if error.code == 412 {
                    Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.profileDeleted.localized)
                }
            }
        }
    }
    
    
    /// To check and make service call if it is user profile and it's follow and follwers get changed
    func setUpServicesAndHeader(){
        if let memberId = self.profileViewModel.userProfileModel?.userId, let userId = Utility.getUserid(){
            /* Feature Name : Add Share Profile option in profile page
             Feature Date : 12-Apr-2021
             Feature Added By : jayaram G
             Description Of Feature : setting image for share profile for another user
             */
            if memberId == userId{
                self.isSelf = true
                
                /*
                 Refactor Name:- Hide Channel
                 Refactor Date:- 30/03/21
                 Refactor By  :- Nikunj C
                 Discription of Fix:- hide floating button for user's own profile
                 */
                
                self.followImageView.image = UIImage(named: "adduser_black")
                self.floatingButtonOutlet.isHidden = true
            }else{
                self.followImageView.image = UIImage(named: "share_deep_icon_1")
            }
            
        }
        
        
        
            if !self.isChanged{
                self.isChanged = false
    //            self.getTagService()
    //            self.getLikeService()
    //            self.getChannelService()
    //            self.getLiveVideos()
    //            self.getStoryService()
            }
        profileViewModel.postOffset = -20
        self.getPostService()
        //        else{
        //        self.setHeaderViewUI()
        let indexPath = IndexPath(row: 0, section: 0)
        guard let headerCell = self.profileTableView.cellForRow(at: indexPath) as? UserProfileHeaderTableViewCell else{return}
        headerCell.setHeaderViewFromModel(modelData: self.profileViewModel.userProfileModel, isSelf: self.isSelf)
        //        }
//                self.profileTableView.beginUpdates()
//                let index = IndexPath(row: 0, section: 0)
//
//        self.profileTableView.reloadSections([0], with: .none)
//                self.profileTableView.reloadRows(at: [index], with: .none)
//                self.profileTableView.endUpdates()
        
                self.profileTableView.reloadData()
        
        
        //        self.headerView.setHeaderViewFromModel(modelData: self.profileViewModel.userProfileModel, isSelf: self.isSelf)
    }
    
    func getPostService(){
        var strUrl: String = AppConstants.profilePost
        if !self.isSelf{
            if let userId = self.profileViewModel.userProfileModel?.userId{
                strUrl = AppConstants.memberPost + "?memberId=\(userId)&"
            }else{
            strUrl = AppConstants.profilePost + "?"
            }
        }else {
            strUrl = AppConstants.profilePost + "?"
        }
        
        //        self.loaderViewOutlet.startAnimating()
        //        self.loaderViewOutlet.isHidden = false
        
        profileViewModel.getPostDataService(strUrl: strUrl) { (success, error, canServiceCall) in
            self.profileTableView.dg_stopLoading()
            if success{
                print("success")
                //                self.loaderViewOutlet.stopAnimating()
                //                self.loaderViewOutlet.isHidden = true
                self.profileTableView.reloadData()
            }else if let error = error{
                //                self.loaderViewOutlet.stopAnimating()
                //                self.loaderViewOutlet.isHidden = true
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }else if error.code == 204{
                    self.profileTableView.reloadData()
                }
            }
            Helper.hidePI()
            self.canPostServiceCall = canServiceCall
        }
    }
    
    func getTagService(){
        var userNameWithOutSpace = userName
        guard let userName = self.profileViewModel.userProfileModel?.userName else{return}
        if userName.contains(" ") {
            userNameWithOutSpace  = userName.replace(target: " ", withString: "%20")
        }
        let strUrl: String = AppConstants.profileTag + "?userName=\(userNameWithOutSpace ?? "")"
        profileViewModel.getTagDataService(strUrl: strUrl,params: [:] as [String : Any]) { (success, error, canServiceCall) in
            self.profileTableView.dg_stopLoading()
            if success{
                print("success")
                self.profileTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            Helper.hidePI()
            self.canTagServiceCall = canServiceCall
        }
    }
    
     func getLikeService(){
        //http://104.236.56.43:5007/MyLikedPost/5b4dbe3d8dde25190edec674?skip=0&limit=20
        
        
        guard let userId = self.profileViewModel.userProfileModel?.userId else{return}
        let strUrl: String = AppConstants.MyLikedPost + "?userId=\(userId)"
        //let params = ["userId": userId]
        //        self.loaderViewOutlet.startAnimating()
        //        self.loaderViewOutlet.isHidden = false
        profileViewModel.getLikeDataService(strUrl: strUrl,params: [:]) { (success, error, canServiceCall) in
            self.profileTableView.dg_stopLoading()
            if success{
                //                self.loaderViewOutlet.stopAnimating()
                //                self.loaderViewOutlet.isHidden = true
                print("success")
                self.profileTableView.reloadData()
            }else if let error = error{
                //                self.loaderViewOutlet.stopAnimating()
                //                self.loaderViewOutlet.isHidden = true
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            Helper.hidePI()
            self.canLikeServiceCall = canServiceCall
        }
    }
    
    
    func getLiveVideos() {
        guard let userId = self.profileViewModel.userProfileModel?.userId else{return}
        let strUrl = AppConstants.streamHistory + "?userId=\(userId)"
        profileViewModel.getLiveVideosDataService(strUrl: strUrl,params: nil) { (success, error, canServiceCall) in
            if success{
                print("success")
                self.profileTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            Helper.hidePI()
            self.canLikeServiceCall = canServiceCall
        }
    }
    
    func getBookMarksData(){
        let strUrl = AppConstants.collections
        profileViewModel.getBookmarksService(strUrl: strUrl) { (success, error, canServiceCall) in
            self.profileTableView.dg_stopLoading()
            if success{
                print("success")
                //                self.loaderViewOutlet.stopAnimating()
                //                self.loaderViewOutlet.isHidden = true
                self.profileTableView.reloadData()
            }else if let error = error{
                //                self.loaderViewOutlet.stopAnimating()
                //                self.loaderViewOutlet.isHidden = true
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }else if error.code == 204{
                    self.profileTableView.reloadData()
                }
            }
            Helper.hidePI()
            self.canBookMarkServiceCall = canServiceCall
        }
    }
    
    func getChannelService(){
        var strUrl: String = ""
        let params = [String:Any]()
        if self.isSelf{
            guard let userId = Utility.getUserid() else {return}
            strUrl = AppConstants.profileChannels + "?userId=\(userId)&"

            
         }else{
            if let userId = self.profileViewModel.userProfileModel?.userId{
                strUrl = AppConstants.profileChannels + "?userId=\(userId)&"
            }
        }
        profileViewModel.getChannelDataService(strUrl: strUrl, params: params) { (success, error, canServiceCall) in
            self.profileTableView.dg_stopLoading()
            if success{
                print("success")
                DispatchQueue.main.async {
                    self.profileTableView.reloadData()
                }
                
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            Helper.hidePI()
            self.canPostServiceCall = canServiceCall
            
        }
    }
    
    
    func getStoryService(){
        //         http://104.236.56.43:5007/MyLikedPost/5b4dbe3d8dde25190edec674?skip=0&limit=20
        
        guard let userId = self.profileViewModel.userProfileModel?.userId else{return}
        let strUrl: String = AppConstants.storyHistory + "?targetUserId=\(userId)"
        profileViewModel.getStoryDataService(strUrl: strUrl, params: [:]) { (success, error, canServiceCall) in
            if success{
                print("success")
                self.profileTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            Helper.hidePI()
            self.canLikeServiceCall = canServiceCall
        }
    }
    
    func getUnLockedPostService(){
        let strUrl: String = AppConstants.buyPost
        profileViewModel.getUnLockedPostDataService(strUrl: strUrl) { (success, error, canServiceCall) in
            self.profileTableView.dg_stopLoading()
            if success{
                self.profileTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }else if error.code == 204{
                    self.profileTableView.reloadData()
                }
            }
            Helper.hidePI()
            self.canUnLockPostServiceCall = canServiceCall
        }
    }
    
    
    @objc func refreshData(){
        self.getUserDetailsService()
        profileViewModel.tagModelArray.removeAll()
        profileViewModel.tagOffset = -20
        self.getTagService()
        profileViewModel.likeModelArray.removeAll()
        profileViewModel.likeOffset = -20
        self.getLikeService()
//        profileViewModel.channelModelArray.removeAll()
//        profileViewModel.channelOffset = -20
//        self.getChannelService()
//        profileViewModel.allStories.removeAll()
//        profileViewModel.storyOffset = -20
//        self.getStoryService()
        profileViewModel.postModelArray.removeAll()
        profileViewModel.postOffset = -20
        self.getPostService()
//        profileViewModel.liveStreamModelArray.removeAll()
//        profileViewModel.liveOffset = -20
//        self.getLiveVideos()
        profileViewModel.unLockedPostModelArray.removeAll()
        profileViewModel.unLockedPostOffSet = -20
        getUnLockedPostService()
        profileViewModel.bookMarkedArray.removeAll()
        profileViewModel.bookMarkOffset = -20
        getBookMarksData()
        
    }
    
    //MARK:- Buttons Action
    @IBAction func createChannelAction(_ sender: UIButton) {
        guard let CreateChannelVC = self.storyboard?.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.CreateChannelViewController) as? CreateChannelViewController else{return}
        CreateChannelVC.modalPresentationStyle = .fullScreen
        self.present(CreateChannelVC, animated: true, completion: nil)
    }
    
    @IBAction func discoverPeopleButtonAction(_ sender: Any) {
        if !isSelf{
            /* Feature Name : Add Share Profile option in profile page
             Feature Date : 12-Apr-2021
             Feature Added By : jayaram G
             Description Of Feature : Creating the dynamic link and opening acivity view.
             */
            let message = "Hey".localized + "! " + "Check out this profile on".localized + " \(AppConstants.AppName) " + "app".localized
                Helper.createDeepLink(isFromProfile: true,profileModel: self.profileViewModel.userProfileModel, forPost: false) { (success, url) in
                    if success{
                        let items: [Any] = [message, url as Any]
                        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                        }
                        self.present(ac, animated: true)
                        print("Success")
                    }else{
                        print("Failed")
                    }
                    Helper.hidePI()
                }
        }else{
            let addContactsVC = AddContactsViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Contacts) as AddContactsViewController
            let navigation = UINavigationController.init(rootViewController: addContactsVC)
    //        navigation.isNavigationBarHidden = true
            addContactsVC.isFromProfile = true
            navigation.modalPresentationStyle = .fullScreen
    //        discoverPeopleVC.delegate = self
            self.present(navigation, animated: true, completion: nil)

        }
    }
    
    @IBAction func optionButtonAction(_ sender: Any) {
      
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if isSelf{
            self.performSegue(withIdentifier: AppConstants.segueIdentifiers.settingSegue, sender: nil)
        }else{
            guard let userProfileData = self.profileViewModel.userProfileModel else{return}
            let report = UIAlertAction(title: Strings.reportUser.localized, style: .default) { (action) in
                
                self.openReportSpamActionsheet()
            }
            let cancel = UIAlertAction(title: "Cancel".localized.localized, style: .cancel) { (action) in
                print(action)
            }
            alert.addAction(report)
            if userProfileData.isBlocked{
                let unblock = UIAlertAction(title: Strings.unBlock, style: .default) { (action) in
                    self.profileViewModel.blockUserApicall(complitation: { (unblocked, error) in
                        if unblocked {
                            /*
                             Bug Name:- User able to send chat even blocked
                             Fix Date:- 23/06/21
                             Fix By  :- Jayaram G
                             Description of Fix:- Handling block status
                             */
                            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isUserBlockStatusChanged)
                            Helper.showAlertViewOnWindow(Strings.message.localized, message: Strings.userUnBlockedSuccessFully.localized)
                        }
                    })
                }
                alert.addAction(unblock)
            }else{
                let block = UIAlertAction(title: Strings.block.localized, style: .default) { (action) in
                    self.profileViewModel.blockUserApicall(complitation: { (blocked, error) in
                        if blocked {
                            /*
                             Bug Name:- User able to send chat even blocked
                             Fix Date:- 23/06/21
                             Fix By  :- Jayaram G
                             Description of Fix:- Handling block status
                             */
                            self.profileViewModel.FollowPeopleService(isFollow: false, peopleId: userProfileData.userId!, privicy: userProfileData.privicy)
                            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isUserBlockStatusChanged)
                            NotificationCenter.default.post(name: NSNotification.Name(AppConstants.notificationObserverKeys.updatingBlockedUsers), object: nil)
                            Helper.showAlertViewOnWindow(Strings.message.localized, message: Strings.userBlockedSuccessFully.localized)
                        }
                    })
                }
                alert.addAction(block)
            }
            
            if userProfileData.friendStatusCode == 2 {
                let unFriend = UIAlertAction(title: Strings.unFriend.localized, style: .default) { (action) in
                    self.profileViewModel.unFriendServiceCall(complitation: { (unFriend, error) in
                        if unFriend {
                            NotificationCenter.default.post(name: NSNotification.Name(AppConstants.notificationObserverKeys.refreshProfileData), object: nil)
                            Helper.showAlertViewOnWindow(Strings.message.localized, message: Strings.userUnFriendSuccessFully.localized)
                            
                        }
                    })
                }
                alert.addAction(unFriend)
            }
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //Report Spam
    func openReportSpamActionsheet(){
        self.getReportReasons()
    }
    
    
    
    
    /// To get report reasones and showing popup view
    func getReportReasons(){
        contactInfoTableViewModel.getReportReasonsService { (success, error) in
            if success{
                DispatchQueue.main.async {
                    let reportView = ReportView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                    reportView.tag = 10
                    reportView.delegate  = self
                    reportView.reportTitle = "Report User"
                    reportView.reportReasonsArray = self.contactInfoTableViewModel.reportReasonArray
                    appDelegetConstant.window.addSubview(reportView)
                    reportView.popUpAnimation()
                }
            }else if let error = error{
                if error.code != 204{
                    DispatchQueue.main.async {
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    /// To post report with reason
    ///
    /// - Parameter index: selected report index
    func postReportReason(index: Int){
        Helper.showPI()
        guard let oppUserID = self.profileViewModel.userProfileModel?.userId else {return}
        contactInfoTableViewModel.postReportReasonService(targetId: oppUserID, reasonIndex: index) { (success, error) in
            if success{
                DispatchQueue.main.async {
                    let reportView = appDelegetConstant.window.viewWithTag(10)
                    reportView?.popDownAnimation(animationDone: { (finished) in
                        self.showPopUpForSuccessResponse()
                    })
                }
            } else if let error = error{
                if error.code != 204{
                    DispatchQueue.main.async {
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    /// To show pop up and start playing video again
    func showPopUpForSuccessResponse(){
        let alert = UIAlertController(title: Strings.success.localized, message: Strings.ContactInfoStrings.reportSuccessMessage.localized, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: Strings.ok.localized, style: UIAlertAction.Style.default) { (action) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func onDismissView() {
        
    }
    
    
    func reportSelectedAtIndex(index: Int) {
        postReportReason(index: index)
    }
    
    
    
    @IBAction func postButtonAction(_ sender: Any) {
    }
    
    @IBAction func followersButtonAction(_ sender: Any) {
        
        guard let privateAccount = self.profileViewModel.userProfileModel?.privicy else {return }
        if privateAccount != 1 || isSelf{
            self.performSegue(withIdentifier: AppConstants.segueIdentifiers.followSegue, sender: 0)
        }else{
            Helper.toastViewForNavigationBar(messsage: "This user is a Private User".localized, view: self.view)
        }
        
    }
    
    @IBAction func followingButtonAction(_ sender: Any) {
        guard let privateAccount = self.profileViewModel.userProfileModel?.privicy else {return }
        if privateAccount != 1 || isSelf{
            self.performSegue(withIdentifier: AppConstants.segueIdentifiers.followSegue, sender: 1)
        }else{
            Helper.toastViewForNavigationBar(messsage: "This user is a Private User".localized, view: self.view)
        }
        
    }
    
    
    @IBAction func editProfileButtonAction(_ sender: Any) {
        guard let userProfileData = self.profileViewModel.userProfileModel else{
            Helper.showAlertViewOnWindow("Oops".localized, message: "Check Internet Connection".localized)
            return
        }
        if !isSelf{
            return
        }
        guard let editProfileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: AppConstants.viewControllerIds.newEditProfileVewController) as? NewEditProfileViewController else{return}
        let navigation = UINavigationController.init(rootViewController: editProfileVC)
        editProfileVC.userDetails = userProfileData.makeCopy()
        navigation.modalPresentationStyle = .fullScreen
        editProfileVC.delegate = self
        self.present(navigation, animated: true, completion: nil)
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
            if self.isPresented{
                self.dismiss(animated: true, completion: nil)
            }else{
                if let seachvc = self.navigationController?.viewControllers.filter({$0.isKind(of: SearchViewController.self)}).first{
                    self.navigationController?.popToViewController(seachvc, animated: true)
                }else if fromBusinessProfile{                self.navigationController?.popToRootViewController(animated: true)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    
    
    //MARK:- Header cell button action
    @objc func postCollectionTap(sender: UIButton){
        if selectedIndex != 0{
            selectedIndex = 0
            self.isTap = true
            self.profileTableView.reloadData()
            if self.profileViewModel.postModelArray.count == 0 {
                self.getPostService()
            }
         }
    }
    
    @objc func postTableTap(sender: UIButton){
        if selectedIndex != 1{
            selectedIndex = 1
            self.isTap = true
            self.profileTableView.reloadData()
            if self.profileViewModel.likeModelArray.count == 0 {
                self.getLikeService()
            }
            //            self.profileTableView.reloadData()
            //       self.getLikeService()
        }
    }
    
    @objc func tagCollectionTap(sender: UIButton){
        
        if selectedIndex != 2{
            selectedIndex = 2
            self.isTap = true
            self.profileTableView.reloadData()
            if self.profileViewModel.tagModelArray.count == 0 {
                self.getTagService()
            }
        }
    }

    
    @objc func channelTableTap(sender: UIButton){
        
        if selectedIndex != 3{
            selectedIndex = 3
            self.isTap = true
            self.profileTableView.reloadData()
            if self.profileViewModel.channelModelArray.count == 0 {
//              self.getChannelService()
            }
        }
    }
    
    @objc func unLockedPostsTap(sender: UIButton){
        /*
         Refactor Name:- Hide Channel
         Refactor Date:- 30/03/21
         Refactor By  :- Nikunj C
         Discription of Fix:- change selected index as hide channel
         */
        
        if selectedIndex != 3{
            selectedIndex = 3
            self.isTap = true
            self.profileTableView.reloadData()
            if self.profileViewModel.unLockedPostModelArray.count == 0 {
                self.getUnLockedPostService()
            }
        }
    }
    
    @objc func bookMarkedPosts(sender: UIButton){
        
        /*
         Refactor Name:- hide collection for other user
         Refactor Date:- 08/07/21
         Refactor By  :- Nikunj C
         Discription of Fix:- change selected index for other user
         */
        if self.isSelf{
            if selectedIndex != 4{
                selectedIndex = 4
                self.isTap = true
                self.profileTableView.reloadData()
                if self.profileViewModel.bookMarkedArray.count == 0 {
                    self.getBookMarksData()
                }
            }
        }else {
            if selectedIndex != 3{
                selectedIndex = 3
                self.isTap = true
                self.profileTableView.reloadData()
                if self.profileViewModel.bookMarkedArray.count == 0 {
                    self.getBookMarksData()
                }
            }
        }
    }
    
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstants.segueIdentifiers.followSegue{
            guard let followVC = segue.destination as? FollowViewController else{return}
            followVC.hidesBottomBarWhenPushed = true
            followVC.delegate = self
            followVC.isSelf = self.isSelf
            guard let tag = sender as? Int else{return}
            if let userModeldata = profileViewModel.userProfileModel{
                followVC.postOrUserId = userModeldata.userId
                if tag == 0{
                    followVC.viewTitle = Strings.followers.localized
                    //                    followVC.isFollowers = true
                    followVC.followListType = .followersView
                }else if tag == 1{
                    followVC.viewTitle = Strings.following.localized
                    //                    followVC.isFollowers = false
                    followVC.followListType = .followeesView
                }else {
                    followVC.viewTitle = "Subscribers".localized
                    //                    followVC.isFollowers = false
                    followVC.followListType = .subscribersList
                }
            }
        }
    }
}

//MARK:- Table view datatsource and delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.userProfileTableViewCell) as? UserProfileTableViewCell else {fatalError()}
            /*
             Refactor Name:- hide collection for other user
             Refactor Date:- 08/07/21
             Refactor By  :- Nikunj C
             Discription of Fix:- change width multiplier for other user
             */
            if self.isSelf{
                NSLayoutConstraint.setMultiplier(5, of: &cell.scrollViewWidthConstraint)
                cell.bookMarkedCollectionView.isHidden = false
            }else{
                NSLayoutConstraint.setMultiplier(4, of: &cell.scrollViewWidthConstraint)
                cell.bookMarkedCollectionView.isHidden = true
            }
            print("scrollviewWidthConstraint",cell.scrollViewWidthConstraint.multiplier)
            let postArr = self.profileViewModel.postModelArray
            let tagArr = self.profileViewModel.tagModelArray
            let likeArr = self.profileViewModel.likeModelArray
            let channelArr = self.profileViewModel.channelModelArray
            let liveVideoModelArr = self.profileViewModel.liveStreamModelArray
            let storyArr = self.profileViewModel.allStories
            let unLockedPostsArr = self.profileViewModel.unLockedPostModelArray
            cell.setChannelAndPostDataCell(postArray: postArr, likeArray: likeArr, tagArray: tagArr, channelArray: channelArr, storiesArray: storyArr, liveVideoModelArray: liveVideoModelArr, selectedIndex: selectedIndex, isTap: self.isTap, isSelf: self.isSelf, isAppearedFirst: self.isAppearedFirst,unLockedPostsArray: unLockedPostsArr, bookMarkedArray: self.profileViewModel.bookMarkedArray)
            cell.setCanServiceCallData(post: canPostServiceCall, tag: canTagServiceCall, like: canLikeServiceCall,unLock: canUnLockPostServiceCall, bookMark: canBookMarkServiceCall)
            self.isAppearedFirst = true
            cell.delegate = self
            cell.scrollingDelegate = self
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.UserProfileHeaderTableViewCell) as? UserProfileHeaderTableViewCell else{fatalError()}
            cell.postsFollowersBackView.isUserInteractionEnabled = true
            self.setHeaderViewUI(cell: cell)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.profileHeaderTableViewCell) as? ProfileHeaderTableViewCell else {fatalError()}
        
        if isSelf {
            headerCell.bookMarkedHeaderView.isHidden = false
            headerCell.unLockedPostsButton.setImage(#imageLiteral(resourceName: "unlock_unselected"), for: .normal)
            headerCell.unLockedPostsButton.setImage(#imageLiteral(resourceName: "unlock_selected"), for: .selected)
        }else{
            headerCell.bookMarkedHeaderView.isHidden = true
            headerCell.unLockedPostsButton.setImage(#imageLiteral(resourceName: "lock_unselected"), for: .normal)
            headerCell.unLockedPostsButton.setImage(#imageLiteral(resourceName: "lock_selected"), for: .selected)
        }
        headerCell.postCollectionButton.addTarget(self, action: #selector(ProfileViewController.postCollectionTap(sender:)), for: .touchUpInside)
        headerCell.postTableButton.addTarget(self, action: #selector(ProfileViewController.postTableTap(sender:)), for: .touchUpInside)
        headerCell.tagCollectionButton.addTarget(self, action: #selector(ProfileViewController.tagCollectionTap(sender:)), for: .touchUpInside)
        headerCell.channelButton.addTarget(self, action: #selector(ProfileViewController.channelTableTap(sender:)), for: .touchUpInside)
        headerCell.unLockedPostsButton.addTarget(self, action: #selector(ProfileViewController.unLockedPostsTap(sender:)), for: .touchUpInside)
        headerCell.bookMarkedPostsBtn.addTarget(self, action: #selector(ProfileViewController.bookMarkedPosts(sender:)), for: .touchUpInside)
        makeSelectedHeaderButtonFor(headerCell: headerCell, index: selectedIndex)
        return headerCell
    }
    
    /*
     Bug Name:- Private View Not appear for Private User
     Fix Date:- 22nd July 2021
     Fixed By:- Nikunj C
     Description of Fix:- add private view Programatically
     */
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let width = self.view.frame.size.width
        let privateView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 140))
        let lockIcon = UIImageView(frame: CGRect(x: width/2 - (65/2), y: 15, width: 65, height: 65))
        lockIcon.image = #imageLiteral(resourceName: "Lock")
        let headingLabel = UILabel(frame: CGRect(x: 25, y: 95, width: width - 50, height: 18.5))
        headingLabel.text = "This Account is Private".localized
        headingLabel.textAlignment = .center
        headingLabel.font =  UIFont(name:"CenturyGothic-Bold", size: 15.0)
        let detailsLabel = UILabel(frame: CGRect(x: 25, y: 113.5, width: width - 50, height: 16))
        detailsLabel.text = "Follow this account to see their photos and videos".localized + "."
        detailsLabel.font = UIFont(name: "CenturyGothic", size: 13)
        detailsLabel.textColor = .darkGray
        privateView.addSubview(lockIcon)
        privateView.addSubview(headingLabel)
        privateView.addSubview(detailsLabel)
        return privateView
    }
    
    func makeSelectedHeaderButtonFor(headerCell:ProfileHeaderTableViewCell, index: Int){
        
        switch selectedIndex {
        case 0:
            headerCell.postCollectionButton.isSelected = true
            headerCell.postTableButton.isSelected = false
            headerCell.tagCollectionButton.isSelected = false
            headerCell.storiesButton.isSelected = false
            headerCell.channelButton.isSelected = false
            headerCell.liveVideosButton.isSelected = false
            headerCell.bookMarkedPostsBtn.isSelected = false
            break
        case 1:
            headerCell.postCollectionButton.isSelected = false
            headerCell.postTableButton.isSelected = true
            headerCell.tagCollectionButton.isSelected = false
            headerCell.channelButton.isSelected = false
            headerCell.storiesButton.isSelected = false
            headerCell.liveVideosButton.isSelected = false
            headerCell.bookMarkedPostsBtn.isSelected = false
            break
        case 2:
            headerCell.postCollectionButton.isSelected = false
            headerCell.postTableButton.isSelected = false
            headerCell.tagCollectionButton.isSelected = true
            headerCell.channelButton.isSelected = false
            headerCell.storiesButton.isSelected = false
            headerCell.liveVideosButton.isSelected = false
            headerCell.bookMarkedPostsBtn.isSelected = false
            break
        case 3:
            headerCell.liveVideosButton.isSelected = false
            headerCell.postCollectionButton.isSelected = false
            headerCell.postTableButton.isSelected = false
            headerCell.storiesButton.isSelected = false
            headerCell.tagCollectionButton.isSelected = false
            headerCell.channelButton.isSelected = true
            
            /*
             Refactor Name:- Hide Channel
             Refactor Date:- 30/03/21
             Refactor By  :- Nikunj C
             Discription of Refactor:- make unlockedPost button selected
             */
            
            headerCell.bookMarkedPostsBtn.isSelected = false
            headerCell.unLockedPostsButton.isSelected = true
            break
        case 4:
            headerCell.liveVideosButton.isSelected = false
            headerCell.postCollectionButton.isSelected = false
            headerCell.postTableButton.isSelected = false
            headerCell.storiesButton.isSelected = false
            headerCell.tagCollectionButton.isSelected = false
            headerCell.channelButton.isSelected = false
            
            /*
             Refactor Name:- Hide Channel
             Refactor Date:- 30/03/21
             Refactor By  :- Nikunj C
             Discription of Refactor:- make unlockedPost button selected
             */
            
            headerCell.bookMarkedPostsBtn.isSelected = true
            headerCell.unLockedPostsButton.isSelected = false
        case 5:
            headerCell.liveVideosButton.isSelected = false
            headerCell.postCollectionButton.isSelected = false
            headerCell.postTableButton.isSelected = false
            headerCell.storiesButton.isSelected = false
            headerCell.tagCollectionButton.isSelected = false
            headerCell.channelButton.isSelected = false
            headerCell.unLockedPostsButton.isSelected = false
            headerCell.bookMarkedPostsBtn.isSelected = true
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || isAccountPrivate{
            return 0
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return UITableView.automaticDimension
        }else{
            if isAccountPrivate{
                
                return 0
            }else {
                let standardHeight = self.view.frame.size.height - 225 - safeAreaHeight - extraStandardHeight
                let floatingButtonHeight: CGFloat = 0
                /* Bug Name :- more white space is displaying in profile screen
                 Fix Date :- 21/07/2021
                 Fixed By :- Nikunj C
                 Description Of Fix :- use different height for dubly and picoadda
                 */
                switch selectedIndex {
                case 0:
                    var count = self.profileViewModel.postModelArray.count / 3
                    let width = (self.view.frame.size.width - 3) / 3
                    let cellHeight = (width - 5) * 5 / 4
                    if (self.profileViewModel.postModelArray.count % 3) > 0{
                        count = count + 1
                    }
                    var singleHeight = width
                    if AppConstants.appType == .picoadda {
                            singleHeight = width
                    }else{
                            singleHeight = cellHeight
                    }
                    
                    let height = CGFloat(count) * singleHeight  + floatingButtonHeight
                    return height > standardHeight ? height : standardHeight
                case 1:
                    var count = self.profileViewModel.likeModelArray.count / 3
                    let width = (self.view.frame.size.width - 3) / 3
                    let cellHeight = (width - 5) * 5 / 4
                    if (self.profileViewModel.likeModelArray.count % 3) > 0{
                        count = count + 1
                    }
                    var singleHeight = width
                    if AppConstants.appType == .picoadda {
                            singleHeight = width
                    }else{
                            singleHeight = cellHeight
                    }
                    let height = CGFloat(count) * singleHeight  + floatingButtonHeight
                    return height > standardHeight ? height : standardHeight
                case 2:
                    var count = self.profileViewModel.tagModelArray.count / 3
                    let width = (self.view.frame.size.width - 3) / 3
                    let cellHeight = (width - 5) * 5 / 4
                    if (self.profileViewModel.tagModelArray.count % 3) > 0{
                        count = count + 1
                    }
                    var singleHeight = width
                    if AppConstants.appType == .picoadda {
                            singleHeight = width
                    }else{
                            singleHeight = cellHeight
                    }
                    let height = CGFloat(count) * singleHeight  + floatingButtonHeight
                    return height > standardHeight ? height : standardHeight

                case 3:
                    var count = self.profileViewModel.unLockedPostModelArray.count / 3
                    let width = (self.view.frame.size.width - 3) / 3
                    let cellHeight = (width - 5) * 5 / 4
                    if (self.profileViewModel.unLockedPostModelArray.count % 3) > 0{
                        count = count + 1
                    }
                    var singleHeight = width
                    if AppConstants.appType == .picoadda {
                            singleHeight = width
                    }else{
                            singleHeight = cellHeight
                    }
                    let height = CGFloat(count) * singleHeight  + floatingButtonHeight
                    return height > standardHeight ? height : standardHeight
                    
                case 4 :
                    /*
                     fix Name:- collections height not proper if more then 2 collection
                     fix Date:- 25th Nov 2021
                     fixed By  :- Nikunj C
                     Discription of Refactor:- collection cell height not proper
                     */
                    var count = self.profileViewModel.bookMarkedArray.count / 2
                    let singleCellHeight = 35 + self.view.frame.size.width / 2
                    if (self.profileViewModel.bookMarkedArray.count % 2) > 0{
                        count = count + 1
                    }
                    let height = singleCellHeight * CGFloat(count) + 10 + floatingButtonHeight
                    return height > standardHeight ? height : standardHeight
                default:
                    return 0
                }
            }
        }
    }
    
    /*
     Bug Name:- Private View Not appear for Private User
     Fix Date:- 22nd July 2021
     Fixed By:- Nikunj C
     Description of Fix:- manage height of private view footer according to required condition
     */
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1{
            if !self.isSelf{
                if profileViewModel.userProfileModel?.followStatus == 0 &&  profileViewModel.userProfileModel?.isStar == 0{
                    if profileViewModel.userProfileModel?.privicy == 1{
                        return 140
                    }else{
                        return 0
                    }
                }else if profileViewModel.userProfileModel?.isStar == 0{
                    if profileViewModel.userProfileModel?.followStatus == 2{
                        return 140
                    }else{
                        return 0
                    }
                }else{
                    return 0
                }
            }else{
                return 0
            }
            }
        else{
            return 0
        }
    }
    
}

//MARK:- Scroll view delegate
extension ProfileViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.profileTableView{
            let movedOffset = scrollView.contentOffset.y
            let pageWidth: CGFloat = 300
            let ratio = (movedOffset + safeAreaHeight - 50) / pageWidth
            print(ratio)
            self.navUserNameLabel.textColor = UIColor.label.withAlphaComponent(ratio)
            if ratio > 0.2{
                self.navigationView.backgroundColor = .systemBackground
                
                self.navUserNameLabel.text = self.userFullName
                self.navUserNameLabel.font = Utility.Font.Bold.ofSize(16)
                isScrollingVertically = true
                if self.navigationView.layer.sublayers != nil {
                    for layer in self.navigationView.layer.sublayers! {
                        if layer.name == Strings.maskLayer {
                            layer.isHidden  = false
                        }
                    }
                }
                        self.navUserNameLabel.textColor = UIColor.label
                    }else{
                        self.navUserNameLabel.text = ""
                        self.navigationView.backgroundColor = .clear
                        isScrollingVertically = false
                        self.navUserNameLabel.textColor = UIColor.white
                        changeNavItemColor(to: UIColor.white)
                        for layer in self.navigationView.layer.sublayers! {
                            if layer.name == Strings.maskLayer {
                                layer.isHidden  = false
                            }
                        }
                    }
                    if ratio > 0.4{
                        changeNavItemColor(to: UIColor.label)
                    }
                }
    }
    
    func changeNavItemColor(to color: UIColor){
        self.backButtonOutlet.tintColor = color
        self.followImageView.tintColor = color
        self.optionImageView.tintColor = color
    }
}

//MARK:- UserProfileTableViewCell delegate
extension ProfileViewController: UserProfileTableViewCellDelegate{
    func refreshingChannelData() {
//        self.getChannelService()
    }
    
    func moveToPostedChannel(modelData: ProfileChannelModel) {
        let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        postedbyController.isChannel = true
        postedbyController.hidesBottomBarWhenPushed = true
        postedbyController.channelName = modelData.channelName
        postedbyController.hashTagName = modelData.channelId
        self.navigationController?.pushViewController(postedbyController, animated: true)

    }
    func didSelectAtChannel(index: Int, modelData: [SocialModel]) {
        if AppConstants.appType == .picoadda {
            Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: modelData, needToCallApi: false, postId: nil)
        }else{
            Route.navigateToAllPostsVertically(navigationController: self.navigationController,postsArray:modelData,profileViewModel:self.profileViewModel,selectedIndex:index - 1,isFromProfilePage:true,isComingFromChannelPost:true,delegate:self)
        }
    }
    
    func paggingServiceCallFor(tableViewType: profileTableViewType) {
        switch tableViewType {
        case .postTableView:
            self.getPostService()
            break
        case .likeTableView:
            self.getLikeService()
            break
        case .tagTableView:
            self.getTagService()
            break
        case .liveTableView:
//            self.getLiveVideos()
            break
        case .channelTableView:
            break
        case .unLockedPostsTableView:
            self.getUnLockedPostService()
        case .bookmarkCollectionView:
            self.getBookMarksData()
        }
    }
    
    func scrollViewScrolled(index: Int){
        if isScrollingVertically {
            /*
             Bug Name:- more white space is displaying in profile screen
             Fix Date:- 22nd july 2021
             Fix By  :- Nikunj C
             Description of Fix:- make bottom 0 as now tableview is not below tabbar
             */
            self.profileTableView.contentInset = UIEdgeInsets(top: 39, left: 0, bottom: 0, right: 0)
         }else{
            self.profileTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:  0, right: 0)
        }
        selectedIndex = index
        self.isTap = false
        self.profileTableView.reloadData()
    }
    
    
    ///  selecting at index
    ///
    /// - Parameters:
    ///   - index: index index path
    ///   - viewType: viewType profile view type
    func didSelectIndex(index: IndexPath, viewType: ProfileViewType) {
        let viewModel = self.profileViewModel
        switch viewType {
        case .pPostCollectionView:
            openPostDetailsWithArray(socialModelArray: viewModel.postModelArray, selectedIndex: index.item)
            break
        case .pLikeCollectionView:
            openPostDetailsWithArray(socialModelArray: viewModel.likeModelArray, selectedIndex: index.item)
            break
        case .pTagCollectionView:
            openPostDetailsWithArray(socialModelArray: viewModel.tagModelArray, selectedIndex: index.item)
            break
        case .pCahnnelTableView:
            break
        case .pStoryCollectionView:
            openStoryDetailsWithArray(storyModelArray: viewModel.storyModelArray.postModelArray, selectedIndex: index.item)
            break
        case .pLiveVideosCollectionView:
            openLiveStreamVideo(liveVideo: viewModel.liveStreamModelArray, selectedIndex: index.item)
            break
        case .pUnLockedPostsCollectionView:
            openPostDetailsWithArray(socialModelArray: viewModel.unLockedPostModelArray, selectedIndex: index.item)
        case .pBookMarkedCollectionView:
            if AppConstants.appType == .picoadda {
                guard let socialDetailsVC =  UIStoryboard.init(name: AppConstants.StoryBoardIds.instaHome, bundle: nil).instantiateViewController(withIdentifier: String(describing: SocialDetailsViewController.self)) as? SocialDetailsViewController else{return}
                socialDetailsVC.isFromSavedPosts = true
                if index.row == 0 {
                    socialDetailsVC.isShowOptions = false
                }else{
                    socialDetailsVC.isShowOptions = true
                }
                
                socialDetailsVC.collection = viewModel.bookMarkedArray[index.row]
                    socialDetailsVC.socialViewModel.socialModelArray = viewModel.bookMarkedArray[index.row].posts
                navigationController?.pushViewController(socialDetailsVC, animated: true)
            }else{
                let storyBoardObj = UIStoryboard.init(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                let bookMarkedVC : BookMarkedPostsViewController = storyBoardObj.instantiateViewController(withIdentifier: "BookMarkedPostsViewController") as! BookMarkedPostsViewController
                bookMarkedVC.hidesBottomBarWhenPushed = true
                bookMarkedVC.collection = viewModel.bookMarkedArray[index.row]
                bookMarkedVC.isCollectionDetails = index.item == 0 ? false : true
                bookMarkedVC.isAllPosts = index.item == 0 ? true : false
                self.navigationController?.pushViewController(bookMarkedVC, animated: true)
            }
            break

        }
    }
    
    /// To navigate post details view controller
    ///
    /// - Parameters:
    ///   - socialModelArray: social model array to show in postdetials table view
    ///   - selectedIndex: selected index of view
    func openPostDetailsWithArray(socialModelArray: [SocialModel], selectedIndex
        : Int){
        /* Bug Name :- Profile Like post not showing
                          Fix Date :- 23/03/2021
                          Fixed By :- Vishal D
                          Description Of Fix :- Profile Module: Liked posts are not being displayed */
        if AppConstants.appType == .picoadda {
            Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: socialModelArray, needToCallApi: false, postId: nil,delegate: self,index: selectedIndex)
        }else{
            Route.navigateToAllPostsVertically(navigationController: self.navigationController,postsArray:socialModelArray,profileViewModel:self.profileViewModel,selectedIndex:selectedIndex,currentIndex :selectedIndex,isFromProfilePage:true,isCommingFromPostsList:true,delegate:self)

        }
    }
    
    
    //    /// To navigate post details view controller
    //    ///
    //    /// - Parameters:
    //    ///   - socialModelArray: social model array to show in postdetials table view
    //    ///   - selectedIndex: selected index of view
    //    func openChannelPostDetailsWithArray(socialModelArray: [ProfileChannelModel], selectedIndex
    //        : Int){
    //        guard let postDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: storyboardId.PostDetailsViewController) as? PostDetailsViewController else{return}
    //        postDetailsVC.selectedIndex = selectedIndex
    //        postDetailsVC.delegate = self
    //       // postDetailsVC.postDetailsViewModel.socialModelArray = socialModelArray
    //        postDetailsVC.isCommingFromPostsList = true
    //        postDetailsVC.profileViewModel = self.profileViewModel
    //        self.navigationController?.pushViewController(postDetailsVC, animated: true)
    //    }
    
    /// To navigate post details view controller
    ///
    /// - Parameters:
    ///   - socialModelArray: social model array to show in postdetials table view
    ///   - selectedIndex: selected index of view
    func openStoryDetailsWithArray(storyModelArray: [postModel], selectedIndex
        : Int){
        let viewStoryVc = ViewStoryViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Main) as ViewStoryViewController
        viewStoryVc.modalPresentationStyle = .fullScreen
        self.profileViewModel.allStories[0].currentStoryIndex = selectedIndex
        viewStoryVc.allStories = self.profileViewModel.allStories
        viewStoryVc.isFromProfileView = true
        viewStoryVc.isMyStory = self.profileViewModel.isSelf
        self.present(viewStoryVc, animated: true, completion:nil)
    }
    
    
    
    
    
    /// To navigate Stream Video view controller
    ///
    /// - Parameters:
    ///   - socialModelArray: social model array to show in postdetials table view
    ///   - selectedIndex: selected index of view
    func openLiveStreamVideo(liveVideo: [LiveVideosModel], selectedIndex
        : Int){
//        let storyBoard = UIStoryboard.init(name: AppConstants.StoryBoardIds.Main , bundle: nil)
//        guard let liveVideoVc = storyBoard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.StreamHistoryVideosControllerVcId) as? StreamHistoryVideosController else{return}
//        liveVideoVc.streamVideoModelData = liveVideo[selectedIndex]
//         self.present(liveVideoVc,animated: true)
        if var videoUrl = liveVideo[selectedIndex].video as? String {
            let width = Int((self.view.frame.size.width))
            //            urlString = urlString.replace(target: "upload/", withString: "upload/w_\(width),h_300/")
            videoUrl = videoUrl.replace(target: "upload/", withString: "upload/vc_auto,w_\(width),h_300/")
//            videoUrl = videoUrl.replace(target: ".mov", withString: ".webm")
            let player = AVPlayer(url: URL.init(string: videoUrl)!)
            let vc = AVPlayerViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.player = player
            present(vc, animated: true) {
                vc.player?.play()
            }
        }
    }
    
    func subscribeUnSubscribeStarUser(){
        let storyBoardObj = UIStoryboard.init(name: "subscribe", bundle: nil)
        if #available(iOS 13.0, *) {
            guard let subscribeConfirmVc = storyBoardObj.instantiateViewController(identifier: "SubscribeConfirmationViewController") as? SubscribeConfirmationViewController else {return}
            subscribeConfirmVc.definesPresentationContext = true
            subscribeConfirmVc.delegate = self
            subscribeConfirmVc.modalPresentationStyle = .overCurrentContext
            subscribeConfirmVc.isFromProfilePage = true
            if let modelData = self.profileViewModel.userProfileModel{
                subscribeConfirmVc.userDataModel = modelData
            }
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                topRootViewController?.present(subscribeConfirmVc, animated: true, completion: nil)
            }
//            self.present(unLockConfirmVc,animated: true)
        } else {
            // Fallback on earlier versions
        }
        
//        if let modelData = self.profileViewModel.userProfileModel{
//            if modelData.isSubscribe == 0 {
//                self.profileViewModel.subscribeAndUnSubscribeApiCall(isSubscribe:true, userId: modelData.userId ?? "") { (success, error) in
//                    print(success)
//                    if success {
//                        modelData.isSubscribe = 1
//                        self.profileTableView.reloadData()
//                    }
//                }
//            }else{
//                self.profileViewModel.subscribeAndUnSubscribeApiCall(isSubscribe:false, userId: modelData.userId ?? "") { (success, error) in
//                    print(success)
//                    if success {
//                        modelData.isSubscribe = 0
//                        self.profileTableView.reloadData()
//                    }
//                }
//            }
//
//        }
        
    }
}


//MARK:- UserProfileHeaderTableViewCell and  EditProfileViewController Delegate
extension ProfileViewController: UserProfileHeaderTableViewCellDelegate, NewEditProfileViewControllerDelegate,MFMailComposeViewControllerDelegate,UINavigationControllerDelegate{
    func viewMoreButtonTapped() {
        self.profileTableView.reloadData()
    }
    
    
    func moveToCoinVc() {
        Route.navigateToCoinWallet(navigationController: self.navigationController)
    }
    
    func subscribeUserAction() {
        subscribeUnSubscribeStarUser()
    }
    
    func subscribersListAction() {
        guard let privateAccount = self.profileViewModel.userProfileModel?.privicy else {return}
        if privateAccount != 1 || isSelf{
            self.performSegue(withIdentifier: AppConstants.segueIdentifiers.followSegue, sender: 3)
        }
        
    }
    
    func openAddressLocation() {
        // Open and show coordinate
        var optionsArray = [AppConstants.MapsConstant.maps]
        if (UIApplication.shared.canOpenURL(URL(string:"https://maps.google.com")!)) {
            optionsArray.append(AppConstants.MapsConstant.googleMaps)
        }
        self.addPopUpOptions(withOptionsArray: optionsArray)
    }
    
    private func addPopUpOptions(withOptionsArray optionsArray : [String] ) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for optionValue in optionsArray {
            let action = UIAlertAction(title: optionValue, style: .default, handler: { (action) in
                if action.title == AppConstants.MapsConstant.maps {
                    self.openMaps()
                    controller.dismiss(animated: true, completion: nil)
                } else if action.title == AppConstants.MapsConstant.googleMaps {
                    self.openGoogleMaps()
                    controller.dismiss(animated: true, completion: nil)
                } else {
                    // have to handle for Other Options here.
                }
            })
            controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler:nil)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    func openMaps() {
        let url = "http://maps.apple.com/maps?saddr=\(self.profileViewModel.userProfileModel?.businessDetails.first?.businessLat ?? ""),\(self.profileViewModel.userProfileModel?.businessDetails.first?.businessLang ?? "")"
        UIApplication.shared.open(URL(string : url)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    func openGoogleMaps() {
        UIApplication.shared.open(URL(string:
            "https://maps.google.com/?q=@\(self.profileViewModel.userProfileModel?.businessDetails.first?.businessLat ?? ""),\(self.profileViewModel.userProfileModel?.businessDetails.first?.businessLang ?? "")")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    
    func businessWebsiteAction() {
        if let businessWebsite = URL(string: ("https://\(profileViewModel.userProfileModel?.businessDetails.first?.businessWebsite ?? "")" ) ) {
            UIApplication.shared.open(businessWebsite, options: [:], completionHandler: nil)   //canOpenURL(businessWebsite)
        }
    }
    
    
    func openingCallAction() {
        if self.profileViewModel.userProfileModel?.isStar == 1{
            if self.profileViewModel.userProfileModel?.businessDetails != nil && self.profileViewModel.userProfileModel?.businessDetails.count != 0 {
                // business details
                if let businessPhoneDetails = self.profileViewModel.userProfileModel?.businessDetails.first?.businessPhone {
                    if let businessPhoneObj = businessPhoneDetails.mobileNumber{
                        let businessCountryCode = businessPhoneDetails.countryCode ?? ""
                        self.callingPhoneNumber(phoneNumber: businessPhoneObj, countryCode: businessCountryCode)
                    }
                }
            }else {
                if let verified = profileViewModel.userProfileModel?.starRequest{
                    if let verifiedPhoneNumber = verified.starUserPhoneNumber{
                        let verifiedCountryCode = verified.starCountryCode ?? ""
                        self.callingPhoneNumber(phoneNumber: verifiedPhoneNumber, countryCode: verifiedCountryCode)
                    }
                }
            }
        }else {
            if self.profileViewModel.userProfileModel?.businessDetails != nil && self.profileViewModel.userProfileModel?.businessDetails.count != 0{
                // business details
                if let businessPhoneDetails = self.profileViewModel.userProfileModel?.businessDetails.first?.businessPhone {
                    if let businessPhoneObj = businessPhoneDetails.mobileNumber{
                        let businessCountryCode = businessPhoneDetails.countryCode ?? ""
                        self.callingPhoneNumber(phoneNumber: businessPhoneObj, countryCode: businessCountryCode)
                    }
                }
            }
        }
    }
    
    func callingPhoneNumber( phoneNumber: String,countryCode:String){
        if let phoneCallURL:URL = URL(string: "tel:\(phoneNumber )") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                let alertController = UIAlertController(title: AppConstants.AppName, message: "Are you sure you want to call \n \(countryCode)\(phoneNumber)?", preferredStyle: .alert)
                let yesPressed = UIAlertAction(title: Strings.yes.localized, style: .default, handler: { (action) in
                    application.openURL(phoneCallURL)
                })
                let noPressed = UIAlertAction(title: Strings.no.localized, style: .default, handler: { (action) in
                    
                })
                alertController.addAction(yesPressed)
                alertController.addAction(noPressed)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    func openingEmailAction() {
        if MFMailComposeViewController.canSendMail() {
            DispatchQueue.main.async {
                Helper.showPI()
            }
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            if self.profileViewModel.userProfileModel?.isStar == 1{
                if self.profileViewModel.userProfileModel?.businessDetails != nil && self.profileViewModel.userProfileModel?.businessDetails.count != 0 {
                    // business details
                    if let businessEmailDetails = self.profileViewModel.userProfileModel?.businessDetails.first?.businessEmail {
                        let businessEmailObj = businessEmailDetails.emailid
                        mc.setToRecipients([businessEmailObj!])
                    }
                }else {
                    if let verified = profileViewModel.userProfileModel?.starRequest {
                        if let email = verified.starUserEmail{
                            mc.setToRecipients([email])
                        }
                        
                    }
                }
            }else {
                if self.profileViewModel.userProfileModel?.businessDetails != nil && self.profileViewModel.userProfileModel?.businessDetails.count != 0 {
                    // business details
                    if let businessEmailDetails = self.profileViewModel.userProfileModel?.businessDetails.first?.businessEmail {
                        let businessEmailObj = businessEmailDetails.emailid
                        mc.setToRecipients([businessEmailObj!])
                    }
                }
            }
            
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            //            if let verified = profileViewModel.userProfileModel?.verified {
            //                let email = verified[Strings.emailId] as? String
            //                mc.setToRecipients([email!])
            //            }
            //          mc.navigationItem.title = "New Message"
            //      mc.setSubject(emailTitle)
            //            mc.setMessageBody(messageBody, isHTML: false)
            mc.modalPresentationStyle = .fullScreen
            self.present(mc, animated: true, completion: nil)
        }else{
            print("Alert:")
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func switchingAccountVc() {
        let cell = profileTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! UserProfileHeaderTableViewCell
        cell.stackViewOutlet.spacing = 5.0
        if self.profileViewModel.userProfileModel?.businessDetails != nil {
            let businessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile) as? Bool
            if businessProfile == true{
                let url = AppConstants.business
                self.profileViewModel.getBusinessStatus(strUrl: url, status: false, businessCategoryid: self.profileViewModel.userProfileModel?.businessDetails.first?.businessCategoryId ?? "") { (isFinishSuccessfully, error) in
                    if isFinishSuccessfully {
                        
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                        cell.businessBtnOutlet.setTitle(Strings.switchToBusiness.localized, for: .normal)
                        //   cell.emailCallMessageViewOutlet.isHidden = true
                        //       cell.businessCategoryLbl.isHidden = true
                        cell.websiteBtnOutlet.isHidden = true
                        cell.businessAddressLbl.isHidden = true
                        cell.businessBio.isHidden = true
                        cell.userStatus.isHidden = false
                        self.profileTableView.reloadData()
                    }else {
                        //  Helper.showAlertViewOnWindow("Message", message: (error?.localizedDescription)!)                            // if error?.code == 400 {
                        let alertView1 = UIAlertController(title: Strings.message.localized, message: Strings.createBusinessMessage.localized, preferredStyle: .alert)
                        let actionSheet1 = UIAlertAction.init(title: Strings.registerNow.localized, style: .default) { (clicked) in
                            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                            let createBusinessVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.createBusinessProfileVcId) as! CreateBusinessProfileViewController
                            self.navigationController?.pushViewController(createBusinessVc, animated: true)
                        }
                        
                        let actionSheet2 = UIAlertAction.init(title: "Cancel".localized, style: .default) { (clicked) in
                            alertView1.dismiss(animated: true, completion: nil)
                        }
                        alertView1.addAction(actionSheet1)
                        alertView1.addAction(actionSheet2)
                        self.present(alertView1,animated: true)
                    }
                    Helper.hidePI()
                }
            }else {
                if let privateAccount = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isPrivate) as? Bool {
                    if privateAccount {
                        Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.businessPublicAlertMessage.localized)
                    }else{
                        let url = AppConstants.business
                        self.profileViewModel.getBusinessStatus(strUrl: url, status: true, businessCategoryid: self.profileViewModel.userProfileModel?.businessDetails.first?.businessCategoryId ?? "") { (isFinishSuccessfully, error) in
                            if isFinishSuccessfully {
                                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                                cell.businessBtnOutlet.setTitle(Strings.switchToPersonal.localized, for: .normal)
                                //   cell.emailCallMessageViewOutlet.isHidden = false
                                //  cell.businessCategoryLbl.isHidden = false
                                cell.websiteBtnOutlet.isHidden = false
                                cell.businessAddressLbl.isHidden = false
                                cell.businessBio.isHidden = false
                                cell.userStatus.isHidden = true
                                self.profileTableView.reloadData()
                            }else {
                                //     Helper.showAlertViewOnWindow("Message", message: (error?.localizedDescription)!)
                                if error?.code == 400 {
                                    //                                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                                    //                                    let createBusinessVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.createBusinessProfileVcId) as! CreateBusinessProfileViewController
                                    let alertView1 = UIAlertController(title: Strings.message.localized, message: Strings.createBusinessMessage.localized, preferredStyle: .alert)
                                    let actionSheet1 = UIAlertAction.init(title: Strings.registerNow.localized, style: .default) { (clicked) in
                                        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                                        let createBusinessVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.createBusinessProfileVcId) as! CreateBusinessProfileViewController
                                        self.navigationController?.pushViewController(createBusinessVc, animated: true)
                                    }
                                    let actionSheet2 = UIAlertAction.init(title: "Cancel".localized, style: .default) { (clicked) in
                                        alertView1.dismiss(animated: true, completion: nil)
                                    }
                                    
                                    
                                    alertView1.addAction(actionSheet2)
                                    alertView1.addAction(actionSheet1)
                                    self.present(alertView1,animated: true)
                                    //self.navigationController?.pushViewController(createBusinessVc, animated: true)
                                }
                            }
                            Helper.hidePI()
                        }
                    }
                }
            }
        }
        else {
            
            let alertView1 = UIAlertController(title: Strings.message.localized, message: Strings.createBusinessMessage.localized, preferredStyle: .alert)
            let actionSheet1 = UIAlertAction.init(title: Strings.registerNow.localized, style: .default) { (clicked) in
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let createBusinessVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.createBusinessProfileVcId) as! CreateBusinessProfileViewController
                self.navigationController?.pushViewController(createBusinessVc, animated: true)
            }
            let actionSheet2 = UIAlertAction.init(title: Strings.cancel.localized, style: .default) { (clicked) in
                alertView1.dismiss(animated: true, completion: nil)
            }
            
            
            alertView1.addAction(actionSheet2)
            alertView1.addAction(actionSheet1)
            self.present(alertView1,animated: true)
        }
    }
    
    
    func moveToWalletVc() {
        /*
         Bug Name:- QR code on withdrawal Request page is not loading
         Fix Date:- 28/06/2021
         Fixed By:- Jayaram G
         Description of Fix:- passing qr code
         */
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
        let walletVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.walletVcId) as! WalletViewController
        walletVc.qrCode = self.profileViewModel.userProfileModel?.qrCode ?? ""
        self.navigationController?.pushViewController(walletVc, animated: true)
        
    }
    func moveToTransactionVc() {
        /*
         Bug Name:- Wallet: There is no wallet functionality in the ios devices
         Fix Date:- 9/04/2021
         Fixed By:- Jayaram G
         Description of Fix:- Added navigation to wallet screen
         */
        /*
         Bug Name:- QR code on withdrawal Request page is not loading
         Fix Date:- 28/06/2021
         Fixed By:- Jayaram G
         Description of Fix:- passing qr code
         */
        let storyBoard = UIStoryboard(name: "Wallet", bundle: nil)
        guard let resultViewController = storyBoard.instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController else {return}
        resultViewController.qrCode = self.profileViewModel.userProfileModel?.qrCode ?? ""
        resultViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(resultViewController, animated: true)
        }
    
    func moveToQrCodeVc() {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
        let qrCodeVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.qrCodeVc) as! QrCodeViewController
        qrCodeVc.qrCode = self.profileViewModel.userProfileModel?.qrCode
        qrCodeVc.isPrivate = self.profileViewModel.userProfileModel?.privicy ?? 0
        if let qrCode = self.profileViewModel.userProfileModel?.qrCode{
            qrCodeVc.barcodeReaded(barcode: qrCode)
        }
        
        self.navigationController?.pushViewController(qrCodeVc, animated: true)
    }
    
    func moveToActivityVc() {
        let activityVc = ActivityViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Activity) as ActivityViewController
        activityVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(activityVc, animated: true)
    }
    
    
    
    func openWebsiteWithUrl(url: URL) {
        var urlString: String = url.absoluteString
        if !urlString.starts(with: "http://") && !urlString.starts(with: "https://") {
            urlString = "http://\(urlString)"
        }
        guard let url = URL(string: urlString) else {return}
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: self.convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    /*
     Feat Name:- now email tap available for bio status
     Feat Date:- 27/03/21
     Feat by  :- Nikunj C
     Discription of Feat:- action for open email from bio status
     */
    
    func openMailWithReciept(To: String) {
        
        let urlString = "mailto:\(To)"
        
        guard let url = URL(string: urlString) else {return}
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: self.convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func profilegetUpdated(){
        self.profileViewModel.postOffset = -20
        isChanged = true
        self.getUserDetailsService()
    }
    
    
    func didFollowButtonTap(){
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAddContacts"), object: nil)
                
                statusChanged = true
                if let modelData = self.profileViewModel.userProfileModel{
                    if modelData.followStatus == 0{
                        modelData.followStatus = 1
                        if modelData.privicy == 0{
                            modelData.followersCount += 1
                        }
                        if modelData.privicy == 1{
                            modelData.followStatus = 2
                        }
                        self.profileViewModel.FollowPeopleService(isFollow: true, peopleId: modelData.userId!, privicy: modelData.privicy)
                        
                        if let cellIndex = self.forYouPostSelectedCellIndex as? Int{
                            updatingHomePagePostsObject?.updatePosts(cellIndex: cellIndex, followStatus: true)
                        }
                    }else{
                        modelData.followStatus = 0
                        if modelData.followersCount == 0{
                            modelData.followersCount  = 0
                        }else{
                            modelData.followersCount -= 1
                        }
                        self.profileViewModel.FollowPeopleService(isFollow: false, peopleId: modelData.userId!, privicy: modelData.privicy)
                        if let cellIndex = self.forYouPostSelectedCellIndex as? Int{
                            updatingHomePagePostsObject?.updatePosts(cellIndex: cellIndex, followStatus: false)
                        }
                    }
                    let indexPath = IndexPath(row: 0, section: 0)
                    guard let headerCell = self.profileTableView.cellForRow(at: indexPath) as? UserProfileHeaderTableViewCell else{return}
                    headerCell.setFollowButton(modelData: modelData)
                    //            headerView.setFollowButton(modelData: modelData)
                    
                }
                setUpServicesAndHeader()
                self.profileTableView.reloadData()
                if self.followedAction != nil{
                    followedAction()
                }
                updatingHomePagePostsObject?.updatePosts()
            }
    
    func openMessageAction(){
        //ChatViewController
        guard let privateAccount = self.profileViewModel.userProfileModel?.privicy else {return }
        guard let isSelfStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool else{ return}
        if privateAccount != 1 || isSelf{
            let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.chat, bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.ChatViewController) as? ChatViewController  else {return}
            guard let model = self.profileViewModel.userProfileModel else {return}
            let docId = Utility.fetchIndividualChatDoc(withReceiverID: model.userId!, andSecretID: "")
            let contact = Contacts(profileModel: model, docId: docId)
            controller.isStar = (model.isStar == 1)
            controller.favoriteObj = contact
            controller.navigationController?.isNavigationBarHidden = false
            self.navigationController?.pushViewController(controller, animated: true)
        }else if privateAccount == 1{
            Helper.toastViewForNavigationBar(messsage: "This user is a Private User".localized, view: self.view)
        }
        
        
        
    }
}



//MARK:- FollowViewController Delegate
extension ProfileViewController: FollowViewControllerDelegate{
    
    func followDataChanged() {
        isChanged = true
        self.getUserDetailsService()
    }
}

extension ProfileViewController:UserProfileScrollingDelegate {
    func bookMarkData() {
        if profileViewModel.bookMarkedArray.count == 0 {
            self.profileViewModel.bookMarkOffset = -20
            self.getBookMarksData()
        }
    }
    
    func unLockedPostsData() {
        if self.profileViewModel.unLockedPostModelArray.count == 0 {
            self.profileViewModel.unLockedPostOffSet = -20
            self.getUnLockedPostService()
        }
    }
    
    func userPostsData() {
        if self.profileViewModel.postModelArray.count == 0 {
            self.profileViewModel.postOffset = -20
        self.getPostService()
        }
     }
    
    func channelPostData() {
        if profileViewModel.channelModelArray.count == 0 {
            self.profileViewModel.channelOffset = -20
//        self.getChannelService()
        }
     }
    
    func storiesPostData() {
        if profileViewModel.allStories.count == 0 {
            self.profileViewModel.storyOffset = -20
//            self.getStoryService()
        }
    }
    
    func tagPostsData() {
        if profileViewModel.tagModelArray.count == 0 {
            self.profileViewModel.tagOffset = -20
        self.getTagService()
        }
     }
    
    func likedPostsData() {
        if profileViewModel.likeModelArray.count == 0 {
            self.profileViewModel.likeOffset = -20
        self.getLikeService()
        }
        
    }
    func liveVideosData(){
        if profileViewModel.liveStreamModelArray.count == 0 {
            self.profileViewModel.liveOffset = -20
//        self.getLiveVideos()
        }
    }
}

extension ProfileViewController: SubscribeConfirmationVCDelegate ,InSufficientCoinsViewControllerDelegate,TipSentVCDelegate{
    
    
    
    func updateWallet(){
        DispatchQueue.main.async {
            Utility.updateWalletBalance()
        }
    }
    
    func navigateToSubcribeSuccess(fullName :String, userId: String) {
                        if #available(iOS 13.0, *) {
            let storyBoardObj = UIStoryboard.init(name: "SendTip", bundle: nil)
            guard let successVc = storyBoardObj.instantiateViewController(identifier: "TipSentSuccessfullyViewController") as? TipSentSuccessfullyViewController else {return}
            successVc.delegate = self
            successVc.isFromSubscribe = true
            successVc.fullName = fullName
            successVc.modalPresentationStyle = .fullScreen
            self.present(successVc,animated: true)
            print("Successfully updated")
            
        } else {
            // Fallback on earlier versions
        }

    }
    
    func navigateToUnSubcribeSuccess(model :UserProfileModel) {
        if #available(iOS 13.0, *) {
//            let storyBoardObj = UIStoryboard.init(name: "subscribe", bundle: nil)
//            guard let successVc = storyBoardObj.instantiateViewController(identifier: "UnSubscribedSuccessfullyViewController") as? UnSubscribedSuccessfullyViewController else {return}
//            successVc.hidesBottomBarWhenPushed = true
//            successVc.definesPresentationContext = true
//            successVc.modalPresentationStyle = .overCurrentContext
//            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
//            while ((topRootViewController?.presentedViewController) != nil) {
//                topRootViewController = topRootViewController?.presentedViewController
//            }
//            DispatchQueue.main.async {
//                topRootViewController?.present(successVc, animated: true, completion: nil)
//            }
//
//            print("Successfully updated")
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    
    func inSufficientBalance(userName : String) {
        if #available(iOS 13.0, *) {
            guard let inSufficientvc = UIStoryboard.init(name: "SendTip", bundle: nil).instantiateViewController(identifier: String(describing: InSufficientCoinsViewController.self)) as? InSufficientCoinsViewController  else {return}
            inSufficientvc.hidesBottomBarWhenPushed = true
            inSufficientvc.delegate = self
            inSufficientvc.isFromSubscribe = true
            inSufficientvc.userName = userName
            inSufficientvc.definesPresentationContext = true
            inSufficientvc.modalPresentationStyle = .overCurrentContext
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                topRootViewController?.present(inSufficientvc, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func dismissToNavigateWallet() {
        Route.navigateToCoinWallet(navigationController:self.navigationController)
    }
    

}

//MARK:- Post details view controller delegate
extension ProfileViewController: PostDetailsViewControllerDelegate,SocialDetailsViewControllerDelegate{
    func homeDataChanged() {
        self.profileViewModel.postOffset = -20
        isChanged = true
        self.getUserDetailsService()
    }
    func deletedPost(isChannel: Bool){
        if isChannel {
//            self.getChannelService()
        }else {
            isChanged = true
            isAppearedFirst = true
            self.profileViewModel.userProfileModel?.postsCount = self.profileViewModel.userProfileModel!.postsCount - 1
            setUpServicesAndHeader()
            self.profileTableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.profileViewModel.postOffset = -20
                self.profileViewModel.postModelArray.removeAll()
                self.getPostService()
            }
        }
    }
    
    /*
     Bug Name:- like/unlike not update between profile and socialdetailVC
     Fix Date:- 19th Oct 2021
     Fixed By:- Nikunj C
     Description of Fix:- manually change modified data in model
     */
    
    func likeUnlikePost(index: Int, isLike: Bool) {
        if isLike{
            
            self.profileViewModel.postModelArray[index].liked = 0
            self.profileViewModel.postModelArray[index].likesCount -= 1
            
        }else{
            
            self.profileViewModel.postModelArray[index].liked = 1
            self.profileViewModel.postModelArray[index].likesCount += 1
            
        }
        
        self.profileTableView.reloadData()
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
    
}

