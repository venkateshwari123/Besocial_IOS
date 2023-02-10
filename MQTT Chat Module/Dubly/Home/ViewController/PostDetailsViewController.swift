
//
//  PostDetailsViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 22/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Kingfisher
import Locksmith
import CocoaLumberjack
import Alamofire
import IJKMediaFramework


@objc protocol PostDetailsViewControllerDelegate: AnyObject {
    func homeDataChanged()
    @objc optional func deletedPost(isChannel: Bool)
    @objc optional func deleteSocialPost(index: Int)
    @objc optional func likeUnlikePost(index: Int, isLike:Bool)
    
}

protocol PostedByViewControllerDelegate {
    func updateDataFollow(following: Bool, index: Int)
}

class PostDetailsViewController: UIViewController {
    
    @IBOutlet weak var postDetailsCollectionView: UICollectionView!
    @IBOutlet weak var popularUserCollectionView: UICollectionView!
    @IBOutlet weak var forYouBottomView: UIView!
    @IBOutlet weak var followingBottomView: UIView!
    @IBOutlet weak var backButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var uploadingStatusLabel: UILabel!
    @IBOutlet weak var uploadingPercentageLabel: UILabel!
    @IBOutlet weak var newPostedImageView: UIImageView!
    @IBOutlet weak var uploadingProgressView: UIProgressView!
    @IBOutlet weak var uploadingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var forYouPostsCollectionView: UICollectionView!
    @IBOutlet weak var followingPostsBtnOutlet: UIButton!
    @IBOutlet weak var coinBalanceOutlet: UILabel!
    @IBOutlet weak var forYouPostsBtnOutlet: UIButton!
    @IBOutlet weak var uploadingViewOutlet: UIView!
    @IBOutlet weak var uploadViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var findFollowPeopleBtn: UIButton!
    @IBOutlet weak var xclusivePostsButton: UIButton!
    @IBOutlet weak var xclusiveCollectionView: UICollectionView!
    @IBOutlet weak var noPostViewOutlet: UIView!
    @IBOutlet weak var profilePicImageOutlet: UIImageView!
    @IBOutlet weak var xclusiveBottomView: UIView!
    @IBOutlet weak var followUserLbl: UILabel!
    @IBOutlet weak var notFollowAnyUser: UILabel!
    @IBOutlet weak var userProfileView: UIView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var appNameLabel: UILabel!
    
    let couchbase = Couchbase.sharedInstance
    /// This is variable to store the new followed userIds
    /// to update the follow/following status rather than calling API
    lazy var newFollowersList = [String]()
    lazy var removeFollowersList = [String]()
    lazy var trendingNewFollowersList = [String]()
    lazy var trendingRemoveFollowersList = [String]()
    var delegate: PostDetailsViewControllerDelegate?
    var savedCollectionObj:SavedCollectionModel?
    var postedByVcDelegateObj:PostedByViewControllerDelegate?
    var currentIJKPlayer:IJKFFMoviePlayerController?
    var postDetailsViewModel = DublyPostDetailsViewModel()
    var profileChannelModelObj:ProfileChannelModel?
    let socialViewModel = SocialViewModel()
    let viewModel = WalletViewModel()
    var profileViewModel = ProfileViewModel()
    var postedByViewModel = PostedByViewModel()
    var socialModelObjec:SocialModel?
    
    
    var isLoadedFirst: Bool = true
    var isCommingFromChat: Bool = false
    var isCommingFromPostsList: Bool = false
    var postId: String?
    var isFromProfilePage: Bool = false
    var isChannelSubscribe:Int?
    var isViewPresented: Bool = false
    
    var imageArrayToVideoURL : URL?
    var userDetailsImage = UIImage()
    // property to maintain the mute status
    var audioPaused:Bool = false
    
    /// This variable is to check if it is first time showing cell to scroll to that item
    var isFirstTime: Bool = true
    
    var isFromTrendingPage :Bool = false
    var isLikeUpadated:Bool = false
    var canServiceCall: Bool = true
    var canServiceCallForXclusive:Bool = true
    var isChannelIdEmpty:String = ""
    var isBookMarkedDone: Bool = false
    var isComingFromSocialPage:Bool = false
    
    
    // Selected Index of media post from where it got navigated.Use this var scroll to selected position
    var selectedIndex: Int = 0
    
    // Selected Index of trending section for playing it from cellForItem method
    var trendingSelectedIndex:Int = 0
    
    // Selected Index of xclusive section for playing it from cellForItem method
    var xclusiveSelectedIndex:Int = 0
    
    // Current media IndexPath for Following section
    var currentPlayingIndexPath : IndexPath?
    // Current media IndexPath for Trending section
    var forYouCurrentPlayingIndexPath : IndexPath?
    // Current media IndexPath for Xclusive section
    var currentIndexPathForXclusive: IndexPath?
    
    // Current media Index for Following section
    var currentIndex: Int = 0
    // Current media Index for Trending section
    var forYouPostsCurrenctIndex:Int = 0
    // Current media Index for Xclusive section
    var xClusivePostsCurrentIndex: Int = 0
    
    var isComingFromChannelPost:Bool = false
    var hashTagName = ""
    var isVideoPaused = false
    
    /// To make sure that user is on Home tab and did not switch to other to avoid playing video in background
    var isViewVisible = false
    
    //store the watched duration for view count
    var watchedDuration = 0
    // store the total duration for view count
    var videoDuration = 0
    var guestTokenVM = GuestTokenViewModel()
    
    //Note : use this variable to play video from datsource cell for row method when we are not scrolling
    var playFollowingSectionVideoFirstTime = true
    //Note : use this variable to play video from datsource cell for row method when we are not scrolling
    var playTrendingSectionVideoFirstTime = true
    //Note : use this variable to play video from datsource cell for row method when we are not scrolling
    var playXclusiveSectionVideoFirstTime = true
    
    struct segueIdentifier {
        static let postByLocationSegue = "postByLocationSegue"
    }
    
    
    lazy var postsRefreshControl: UIRefreshControl = {
        self.postDetailsViewModel.offset = 0
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(self.refreshPostsData(_ :)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor(named: "App base Color")
        
        return refreshControl
    }()
    
    lazy var trendingPostsRefreshControl: UIRefreshControl = {
        self.postDetailsViewModel.offsetForForYouPosts = 0
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(self.refreshTrendingPostsData(_ :)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor(named: "App base Color")
        
        return refreshControl
    }()
    
    
    lazy var xclusivePostsRefreshControl: UIRefreshControl = {
        self.postDetailsViewModel.offsetForForYouPosts = 0
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(self.refreshXclusivePostsData(_ :)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor(named: "App base Color")
        
        return refreshControl
    }()
    
    //MARK:- View life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        if Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) == nil {
            if let token = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.token) as? String {
                do{
                    try Locksmith.saveData(data: ["token":token], forUserAccount: AppConstants.keyChainAccount)
                }catch{
                    DDLogDebug("error handel it")
                }
                
            }
        }
        if let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) {
            if let token = keyDict["token"] {
                UserDefaults.standard.set(token, forKey: AppConstants.UserDefaults.token)
            }
        }
        
        self.addNotificationCenterObserversForIJKPlayer()
        self.addObserVerAllObservers()
        if isCommingFromPostsList{
            self.setUIForPostDetails()
        }
        else if isFromTrendingPage {
            self.setUIForPostDetails()
            self.getTrendingHashTagPostsServiceCall()
        }else if isCommingFromChat && !isFromTrendingPage{
            self.setUIForPostDetails()
            self.getPostDetails()
        }
        else if !isCommingFromChat ,!isCommingFromPostsList , !isFromTrendingPage{
            setUIForHomeScreenForVerticalScrolling()
            if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus, Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) == nil{
                guestTokenVM.getGuestTokenApiCall { (success) in
                    if success {
                        self.forYouPostshomeServiceCall()
                    }else{
                        Utility.logOut()
                        return
                    }
                }
            }else{
                guard Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) != nil else{
                    Utility.logOut()
                    return
                }
                self.forYouPostshomeServiceCall()
                if let userId = Utility.getUserid(), userId != "" {
                    ApiHelper.shared.getWallet(userId: userId) { _ in
                        if let walletData = Double(KeychainHelper.sharedInstance.getCoinWalletBalance())?.formatUsingAbbrevation(){
                            self.coinBalanceOutlet.text = walletData
                        }
                    }
                }
            }
            
        }
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.isFirstTime{
                self.isFirstTime = false
                self.postDetailsCollectionView.reloadData()
                if self.selectedIndex > 0 {
                    let index = IndexPath(row: self.selectedIndex, section: 0)
                    self.postDetailsCollectionView.scrollToItem(at: index, at: .bottom, animated: false)
                }
            }
        }
        
        Helper.addedUserImage(profilePic: Utility.getUserImage(), imageView: self.userProfileImageView, fullName: Utility.getUserFullName() ?? "P")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)  {
 
            self.userNameLabel.text = "@" + Utility.getUserName()
            self.fullNameLabel.text = Utility.getUserFullName()
            self.appNameLabel.text = AppConstants.AppName
            self.userDetailsImage = self.userProfileView.renderViewToImage()
            Helper.generateVideoFromImages(image: self.userDetailsImage) { url in
                self.imageArrayToVideoURL = url
            }
        }
        //        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        
        /*
         Bug Name:- toast not appear sometime
         Refactor Date:- 16/04/21
         Refactor By  :- Nikunj C
         Description of Refactor:- refactor extra code
         */
        
        Helper.checkConnectionAvaibility(view: self.view)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        isViewVisible = true
        UIApplication.shared.statusBarStyle = .lightContent
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        /* Bug Name :  Home screen design
         Fix Date : 14-Apr-2021
         Fixed By : Jayaram G
         Description Of Fix : Showing coin balance on top right
         */
        
        /* Bug Name :  API Calling everytime
         Fix Date : 22-Apr-2021
         Fixed By : Jayaram G
         Description Of Fix : removed api call from here
         */
        if let walletData = Double(KeychainHelper.sharedInstance.getCoinWalletBalance())?.formatUsingAbbrevation(){
            self.coinBalanceOutlet.text = walletData
        }
        self.playVideoPlayerFromStoppedState()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationItem.leftBarButtonItem = nil
        
        if !isFromProfilePage && !isFromTrendingPage {
            self.tabBarController?.tabBar.backgroundColor = UIColor.clear
            self.tabBarController?.tabBar.isTranslucent = true
            self.tabBarController?.tabBar.isHidden = false
            self.tabBarController?.tabBar.backgroundImage = UIImage.init(color: UIColor.clear,size: CGSize(width: self.tabBarController!.tabBar.bounds.width,height: self.tabBarController!.tabBar.bounds.height))
        }else {
            self.tabBarController?.tabBar.isHidden = true
        }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.clear
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
            navigationItem.compactAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
        self.setProfileImage()
        self.updateFollowFollowingData()
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        UIApplication.shared.statusBarStyle = .default
        self.updateViewsOnPosts()
        self.stopVideoPlayer()
        isViewVisible = false
        self.navigationController?.navigationBar.backgroundColor = .white
        if isCommingFromChat  || isCommingFromPostsList || isFromProfilePage {
            self.currentIJKPlayer?.shutdown()
            self.currentIJKPlayer?.view.removeFromSuperview()
            self.currentIJKPlayer = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// If user taps to see posts form trending, chats or from profile screen
    func setUIForPostDetails(){
        self.navigationItem.titleView?.isHidden = true
        self.followingPostsBtnOutlet.isSelected = true
        self.forYouPostsCollectionView.isHidden = true
        self.postDetailsCollectionView.isHidden = false
        self.xclusiveCollectionView.isHidden = true
        self.xclusivePostsButton.isSelected = false
        self.noPostViewOutlet.isHidden = true
        backButtonOutlet.tintColor = .white
        backButtonOutlet.image = #imageLiteral(resourceName: "camera_Editor_back")
        
    }
    
    func setUIForHomeScreenForVerticalScrolling(){
        self.navigationItem.titleView?.isHidden = false
        forYouPostsBtnOutlet.isSelected = true
        forYouPostsBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(13)
        followingPostsBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(13)
        self.followingBottomView.isHidden = true
        self.forYouBottomView.isHidden = false
        self.postDetailsCollectionView.isHidden = true
        self.xclusiveCollectionView.isHidden = true
        self.forYouPostsCollectionView.isHidden = false
        
    }
    
    
    func updateWalletData(){
        let walletData = Double(KeychainHelper.sharedInstance.getCoinWalletBalance())?.formatUsingAbbrevation()
        self.coinBalanceOutlet.text = " \(walletData ?? "") "
    }
    
    /*
     Refactor Name:- Get user details when user signed up first time
     Refactor Date:- 06/05/2021
     Refactored By:- Jayaram
     Description of Refactor:- Added users details api call for storing self user data
     */
    func getUserDetailsInitiallyFromSignUp(){
        guard let userId = Utility.getUserid() else {
            return
        }
        profileViewModel.isSelf = true
        let strUrl: String = AppConstants.userProfile + "?memberId=\(userId)"
        profileViewModel.userDetailsService(strUrl: strUrl, params: nil) { (success, error, canServiceCall) in
            if success{
                
            }
        }
    }
    
    func loadGoogleAds(){
        //  interstitial = createAndLoadInterstitial()
    }
    
    //    func createAndLoadInterstitial() -> GADInterstitial {
    ////        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-7422620791332459/7501680023")
    //        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-7422620791332459/8104863998")
    //      interstitial.delegate = self
    //      interstitial.load(GADRequest())
    //      return interstitial
    //    }
    

    
    func hidingTabForPostDetailsScreen() {
        self.tabBarController?.tabBar.isHidden = true
        var tabFrame = self.tabBarController?.tabBar.frame
        // - 40 is editable , the default value is 49 px, below lowers the tabbar and above increases the tab bar size
        //tabFrame?.size.height = 0
        if tabFrame != nil {
            tabFrame!.origin.y = self.view.frame.size.height - tabFrame!.height
            self.tabBarController?.tabBar.frame = tabFrame!
        }
    }
    
    
    @IBAction func followingPostsAction(_ sender: UIButton) {
        
        /*
         Refactor Name:- add find friend button below popular user in trending
         refactor Date:- 25/03/2021
         refactor By:- Nikunj C
         Discription of refactor:- hide and unhide findFollowPeopleBtn according to requirement
         */
        
        if self.followingPostsBtnOutlet.isSelected{
            return
        }
        if let status = Utility.getIsGuestUser() , !status {
            self.stopVideoPlayer()
            followingPostsBtnOutlet.isSelected = true
            self.followingBottomView.isHidden = false
            self.forYouBottomView.isHidden = true
            forYouPostsBtnOutlet.isSelected = false
            /* Bug Name :  Home screen design
             Fix Date : 14-Apr-2021
             Fixed By : Jayaram G
             Description Of Fix : refactored font size of following and foryou
             */
            forYouPostsBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(13)
            followingPostsBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(13)
            self.postDetailsCollectionView.isHidden = false
            self.forYouPostsCollectionView.isHidden = true
            self.xclusiveBottomView.isHidden = true
            self.xclusivePostsButton.isSelected = false
            self.xclusiveCollectionView.isHidden = true
            if self.postDetailsViewModel.socialModelArray.count == 0 {
                self.newFollowersList.removeAll()
                self.removeFollowersList.removeAll()
                self.postDetailsViewModel.offset = 0
                self.homeServiceCall()
                self.noPostViewOutlet.isHidden = false
                self.findFollowPeopleBtn.isHidden = false
                self.popularUserCollectionView.isHidden = false
            }else{
                self.playFollowingSectionVideoFirstTime = true
                self.currentPlayingIndexPath = nil
                self.selectedIndex = currentIndex
                self.postDetailsCollectionView.reloadData()
                self.updateFollowFollowingData()
                self.noPostViewOutlet.isHidden = true
                self.findFollowPeopleBtn.isHidden = true
                self.popularUserCollectionView.isHidden = true
            }
        }else {
            presentWelcomeController()
        }
    }
    
    @IBAction func forYouPostsAction(_ sender: UIButton) {
        /*
         Bug Name:- add find friend button below popular user in trending
         Fix Date:- 25/03/2021
         Fixed By:- Nikunj C
         Discription of Fix:- hide and unhide findFollowPeopleBtn according to requirement
         */
        if self.forYouPostsBtnOutlet.isSelected{
            return
        }
        if let status = Utility.getIsGuestUser() , !status {
            self.stopVideoPlayer()
            /* Bug Name :  Home screen design
             Fix Date : 14-Apr-2021
             Fixed By : Jayaram G
             Description Of Fix : refactored font size of following and foryou
             */
            forYouPostsBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(13)
            followingPostsBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(13)
            forYouPostsBtnOutlet.isSelected = true
            self.followingBottomView.isHidden = true
            self.forYouBottomView.isHidden = false
            self.xclusiveBottomView.isHidden = true
            self.xclusivePostsButton.isSelected = false
            followingPostsBtnOutlet.isSelected = false
            self.postDetailsCollectionView.isHidden = true
            self.xclusiveCollectionView.isHidden = true
            self.forYouPostsCollectionView.isHidden = false
            if self.postDetailsViewModel.forYouPostsModelArray.count == 0 {
                self.postDetailsViewModel.offsetForForYouPosts = 0
                self.trendingNewFollowersList.removeAll()
                self.trendingRemoveFollowersList.removeAll()
                self.forYouPostshomeServiceCall()
            }else{
                self.playTrendingSectionVideoFirstTime = true
                self.forYouCurrentPlayingIndexPath = nil
                self.trendingSelectedIndex = self.forYouPostsCurrenctIndex
                self.forYouPostsCollectionView.reloadData()
                self.noPostViewOutlet.isHidden = true
                self.findFollowPeopleBtn.isHidden = true
                self.popularUserCollectionView.isHidden = true
                self.updateFollowFollowingData()
            }
        }else {
            presentWelcomeController()
        }
    }
    
    @IBAction func xclusivePostsAction(_ sender: Any) {
        /*
         Bug Name:- add find friend button below popular user in trending
         Fix Date:- 25/03/2021
         Fixed By:- Nikunj C
         Discription of Fix:- hide and unhide findFollowPeopleBtn according to requirement
         */
        if self.xclusivePostsButton.isSelected{
            return
        }
        if let status = Utility.getIsGuestUser() , !status {
            self.stopVideoPlayer()
            /* Bug Name :  Home screen design
             Fix Date : 14-Apr-2021
             Fixed By : Jayaram G
             Description Of Fix : refactored font size of following and foryou
             */
            forYouPostsBtnOutlet.isSelected = false
            self.followingPostsBtnOutlet.isSelected = false
            self.xclusivePostsButton.isSelected = true
            self.followingBottomView.isHidden = true
            self.forYouBottomView.isHidden = true
            self.xclusiveBottomView.isHidden = false
            
            
            self.postDetailsCollectionView.isHidden = true
            self.forYouPostsCollectionView.isHidden = true
            self.xclusiveCollectionView.isHidden = false
            if self.postDetailsViewModel.xclusivePostsModelArray.count == 0 {
                self.postDetailsViewModel.xclusivePostsOffset = 0
                self.getXclusivePostsServiceCall()
            }else{
                self.playXclusiveSectionVideoFirstTime = true
                self.currentIndexPathForXclusive = nil
                self.xclusiveSelectedIndex = self.xClusivePostsCurrentIndex
                self.xclusiveCollectionView.reloadData()
                self.noPostViewOutlet.isHidden = true
                self.findFollowPeopleBtn.isHidden = true
                self.popularUserCollectionView.isHidden = true
                self.updateFollowFollowingData()
            }
        }else {
            presentWelcomeController()
        }
    }
    
    
    
    /// Whenever user follow/unfollow the other users store these ids and refresh on showing this screen
    func updateFollowFollowingData(){
        if  let isFollowersChanged =  UserDefaults.standard.value(forKey:"RefreshFollowers") as? Bool, isFollowersChanged{
            self.newFollowersList.removeAll()
            self.removeFollowersList.removeAll()
            self.postDetailsViewModel.offset = 0
            self.homeServiceCall()
            UserDefaults.standard.set(false, forKey: "RefreshFollowers")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    /// Update the user views on the posts  if there is any and clear the database
    func updateViewsOnPosts(){
        if Utility.getViewersFromDatabase(couchbase: couchbase).count > 0, UserDefaults.standard.value(forKey: AppConstants.UserDefaults.LoggedInUser) != nil{
            self.postDetailsViewModel.uploadViewersData(viewersData: Utility.getViewersFromDatabase(couchbase: couchbase)) { (result, error) in
                
            }
            print(Utility.getViewersFromDatabase(couchbase: couchbase))
            guard let docId = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.postsViewersDocId) as? String else {return}
            couchbase.deleteDocument(withDocID:docId )
        }
    }
    
    func playVideoPlayerFromStoppedState(){
        self.playVideoForSelectedSection(checkPlayingConditionForCurrentIndex : false)
    }
    
    @objc func refreshPostsData(_ sender: Any) {
        self.updateViewsOnPosts()
        self.newFollowersList.removeAll()
        self.removeFollowersList.removeAll()
        self.postDetailsViewModel.socialModelArray.removeAll()
        self.postDetailsViewModel.offset = 0
        self.playFollowingSectionVideoFirstTime = true
        self.currentPlayingIndexPath = nil
        self.selectedIndex = 0
        self.homeServiceCall()
    }
    @objc func refreshTrendingPostsData(_ sender: Any) {
        self.updateViewsOnPosts()
        self.trendingNewFollowersList.removeAll()
        self.trendingRemoveFollowersList.removeAll()
        self.postDetailsViewModel.forYouPostsModelArray.removeAll()
        self.postDetailsViewModel.offsetForForYouPosts = 0
        self.playTrendingSectionVideoFirstTime = true
        self.forYouCurrentPlayingIndexPath = nil
        self.trendingSelectedIndex = 0
        self.forYouPostshomeServiceCall()
    }
    @objc func refreshXclusivePostsData(_ sender: Any) {
        self.updateViewsOnPosts()
        self.newFollowersList.removeAll()
        self.removeFollowersList.removeAll()
        self.postDetailsViewModel.xclusivePostsOffset = 0
        self.playXclusiveSectionVideoFirstTime = true
        self.getXclusivePostsServiceCall()
    }

    
    
    /*
     Refactor Name:- Handling Observers
     Refactor Date:- 11/05/21
     Refacotr By  :- Jayaram G
     Description of Refactor:- Removing all observers in deinit
     */
    deinit {
        
        if postDetailsCollectionView != nil{
            postDetailsCollectionView.dg_removePullToRefresh()
        }
        if forYouPostsCollectionView != nil{
            forYouPostsCollectionView.dg_removePullToRefresh()
        }
        if xclusiveCollectionView != nil {
            xclusiveCollectionView.dg_removePullToRefresh()
        }
        /* Bug Name : posting happening multiple times
         Fix Date : 13-May-2021
         Fixed By : Jayaram G
         Description Of Fix : Removing observers in deinit
         */
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self , name: NSNotification.Name(rawValue: "createNewPost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RefreshForYouPosts"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showViewCollectionsForPostDetails"), object: nil)
        self.currentIJKPlayer?.shutdown()
        

        self.removeNotificationCenterObserversForIJKPlayer()
    }
    
    @objc func showViewCollections(_ notification: NSNotification){
        if let collectionModel = notification.object as? SavedCollectionModel {
            self.savedCollectionObj = collectionModel
        }
        self.isBookMarkedDone = true
        self.postDetailsCollectionView.reloadData()
    }
    
    
    func setUpUI() {
        self.postDetailsCollectionView.register(UINib.init(nibName: "HomeFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeFeedCollectionViewCell")
        self.forYouPostsCollectionView.register(UINib.init(nibName: "HomeFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeFeedCollectionViewCell")
        self.xclusiveCollectionView.register(UINib.init(nibName: "HomeFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeFeedCollectionViewCell")
        self.postDetailsCollectionView.refreshControl = postsRefreshControl
        self.forYouPostsCollectionView.refreshControl = trendingPostsRefreshControl
        self.xclusiveCollectionView.refreshControl = xclusivePostsRefreshControl
        self.notFollowAnyUser.text = "You do not have followed anyone".localized + ". " + "Follow some users to see their posts here".localized + "."
        self.followUserLbl.text = "Follow User".localized
        self.findFollowPeopleBtn.setTitle("Find people to follow".localized, for: .normal)
        self.forYouPostsBtnOutlet.setTitle("Trending".localized, for: .normal)
        self.xclusivePostsButton.setTitle("Xclusive".localized, for: .normal)
        self.followingPostsBtnOutlet.setTitle("Following".localized, for: .normal)
        self.profilePicImageOutlet.makeCornerRadious(readious: self.profilePicImageOutlet.frame.width / 2)
        self.userProfileImageView.makeCornerRadious(readious: self.userProfileImageView.frame.width / 2)
        uploadingViewHeightConstraint.constant = 0
        findFollowPeopleBtn.makeGradientToUserView()
        findFollowPeopleBtn.makeCornerRadious(readious: 10)
        UserDefaults.standard.set(false, forKey: "RefreshFollowers")
        UserDefaults.standard.synchronize()
        if UIScreen.main.nativeBounds.height > 2208 || UIScreen.main.nativeBounds.height == 1792 {
            uploadViewTopConstraint.constant = 45
        }else {
            uploadViewTopConstraint.constant = 0
        }
    }
    
    
    //MARK:- Service call
    func homeServiceCall(){
        postDetailsViewModel.getHomeServiceData {[weak self] (success, error, canServiceCall) in
            guard let self = self else { return }
            Helper.hidePI()
            self.postDetailsCollectionView.dg_stopLoading()
            if success {
                if !self.postDetailsCollectionView.isHidden {
                    DispatchQueue.main.async {
                        self.postDetailsCollectionView.dg_stopLoading()
                        self.postDetailsCollectionView.reloadData()
                        self.setNoPostView()
                    }
                }
            } else if let error = error {
                self.postDetailsCollectionView.dg_stopLoading()
                // 204 - No data in server
                if error.code != 204 {
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.postDetailsViewModel.offset = self.postDetailsViewModel.offset - 20
            }
            self.canServiceCall = canServiceCall
            self.postsRefreshControl.endRefreshing()
        }
    }
    
    //MARK:- Service call
    func forYouPostshomeServiceCall(){
        if self.isLoadedFirst{
            self.isLoadedFirst = false
            Helper.showPI()
            /* Bug Name :  Loader stuck issue
             Fix Date : 26-March-2021
             Fixed By : Vishal D
             Description Of Fix : home page : on viewing a few posts and scrolling up and reloading the posts by scrollin up on the first page loading icon is stuck at the top
             */
            DispatchQueue.main.async {
                self.forYouPostsCollectionView.dg_stopLoading()
            }
        }
        
        postDetailsViewModel.getTrending {[weak self] (success, error, canServiceCall) in
            guard let self = self else { return }
            Helper.hidePI()
            DispatchQueue.main.async {
                self.forYouPostsCollectionView.dg_stopLoading()
            }
            
            if success {
                DispatchQueue.main.async  {
                    if !self.forYouPostsCollectionView.isHidden {
                        self.forYouPostsCollectionView.reloadData()
                    }
                }
                self.setNoPostView()
            } else if let error = error {
                self.forYouPostsCollectionView.dg_stopLoading()
                // 204 - No data in server
                if error.code != 204 {
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.postDetailsViewModel.offsetForForYouPosts = self.postDetailsViewModel.offsetForForYouPosts - 20
            }
            self.canServiceCall = canServiceCall
            self.trendingPostsRefreshControl.endRefreshing()
        }
    }
    
    func getTrendingHashTagPostsServiceCall() {
        self.postDetailsViewModel.getHashTagPosts(hashTag: self.hashTagName) { (success, error, canServiceCall) in
            Helper.hidePI()
            DispatchQueue.main.async {
                self.postDetailsCollectionView.dg_stopLoading()
            }
            
            if success {
                DispatchQueue.main.async {
                    if !self.postDetailsCollectionView.isHidden {
                        /* Bug Name :  Videos not playing when navigate from explore page
                         Fix Date : 10-May-2021
                         Fixed By : Jayaram G
                         Description Of Fix : updating currentPlayingIndex
                         */
                        for (index,postData) in self.postDetailsViewModel.socialModelArray.enumerated() {
                            if postData.postId == self.postId {
                                self.currentPlayingIndexPath = nil
                                DispatchQueue.main.async {
                                    self.selectedIndex = index
                                    self.postDetailsCollectionView.reloadData()
                                    self.postDetailsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .bottom, animated: false)
                                }
                            }
                        }
                    }
                }
                self.setNoPostView()
            } else if let error = error {
                // 204 - No data in server
                if error.code != 204 {
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.postDetailsViewModel.hashTagPostsOffset = self.postDetailsViewModel.hashTagPostsOffset - 20
            }
            self.canServiceCall = canServiceCall
            
        }
    }
    
    
    func getXclusivePostsServiceCall() {
        self.postDetailsViewModel.getXclusivePosts() { (success, error, canServiceCall) in
            Helper.hidePI()
            DispatchQueue.main.async {
                self.xclusiveCollectionView.dg_stopLoading()
            }
            
            if success {
                DispatchQueue.main.async {
                    if !self.xclusiveCollectionView.isHidden {
                        self.xclusiveCollectionView.dg_stopLoading()
                        self.xclusiveCollectionView.reloadData()
                    }
                }
                self.setNoPostView()
            } else if let error = error {
                // 204 - No data in server
                if error.code != 204 {
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.postDetailsViewModel.xclusivePostsOffset = self.postDetailsViewModel.xclusivePostsOffset - 20
            }
            self.canServiceCall = canServiceCall
            self.xclusivePostsRefreshControl.endRefreshing()
        }
    }
    
    
    func setNoPostView() {
        
        
        /* Bug Name :  the video that shows that follow user thing for xclusicr that is not required
         Fix Date : 05-May-2021
         Fixed By : Jayaram G
         Description Of Fix : Showing no post view for only following tab
         */
        if self.followingPostsBtnOutlet.isSelected {
            if self.postDetailsViewModel.socialModelArray.count == 0 {
                self.getPopularUser()
                self.noPostViewOutlet.isHidden = false
                self.findFollowPeopleBtn.isHidden = false
                self.popularUserCollectionView.isHidden = false
            }else{
                self.noPostViewOutlet.isHidden = true
                self.findFollowPeopleBtn.isHidden = true
                self.popularUserCollectionView.isHidden = true
            }
        }
    }
    
    func setProfileImage(){
        if let status = Utility.getIsGuestUser() , !status {
            //        if let userImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String{
            //                                profilePicImageOutlet.setImageOn(imageUrl: userImage, defaultImage: #imageLiteral(resourceName: "defaultImage"))
            //                            }else{
            //
            //                            }
            profilePicImageOutlet.isHidden = false
            self.profilePicImageOutlet.tintColor = .white
            self.profilePicImageOutlet.image =  #imageLiteral(resourceName: "Group 52156")
        }else{
            profilePicImageOutlet.isHidden = false
            self.profilePicImageOutlet.image =  #imageLiteral(resourceName: "Group 52156")
        }
    }
    
    @IBAction func profileAction(_ sender: UIButton) {
        /* Bug Name :  Add coin option in home page top right
         Fix Date : 08-Apr-2021
         Fixed By : Jayaram G
         Description Of Fix : Added navigation to coins screen.
         */
        
        if let status = Utility.getIsGuestUser() , !status {
            Route.navigateToCoinWallet(navigationController: self.navigationController)
        }else {
            presentWelcomeController()
        }
    }
    
    func refreshTokenAPI(closure:@escaping (Bool,String)->()) {
        guard  let refreshToken = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.refreshToken) as? String else {return}
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode(),"refreshtoken": refreshToken]
        let strURL = "\(AppConstants.baseUrl)/\(AppConstants.refreshUserToken)"
        
        let manager = Alamofire.Session.default
        manager.request(strURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HTTPHeaders.init(headers)).responseJSON { (response) in
                    
        switch response.result{
            
        case let .success(value):
            
            var statuscode:Int = 200
            if let res = response.response{
                statuscode = res.statusCode
            }
            if  var dict  = value as? [String:Any]{
                guard let responseDict = dict["data"] as? [String : Any] else {return}
                do{
                    try Locksmith.deleteDataForUserAccount(userAccount: AppConstants.keyChainAccount)
                }
                catch{
                    DDLogDebug("error handel it")
                    closure(false,"")
                }
                
                guard let token = responseDict["accessToken"] as? String else {return}
                do{
                    try Locksmith.saveData(data: ["token":token], forUserAccount: AppConstants.keyChainAccount)
                    closure(true,token)
                }catch{
                    DDLogDebug("error handel it")
                    closure(false,"")
                }
            }else{
                Utility.logOut()
            }

            
        case let .failure(error):
            
            DispatchQueue.main.async{
                if error.localizedDescription == "The Internet connection appears to be offline." || error.localizedDescription == "The request timed out."{
                    DispatchQueue.main.async {
                        Helper.hidePI()
                    }
                }
            }
            if error.localizedDescription != AppConstants.noInternetMsg {
                print(error.localizedDescription)
            }
            
        }
        
    }
        
    }
    
    @IBAction func activityAction(_ sender: Any) {
        /* Bug Name : Add live button on home page
         Fix Date : 08-apr-2021
         Fixed By : Jayaram G
         Description Of Fix : Added navigation to live stream screen
         */
        if let status = Utility.getIsGuestUser() , !status {
            let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.live, bundle: nil)
            guard let onGoingStreamVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.OnGoingStreamVC) as? OnGoingStreamVC else{return}
            onGoingStreamVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(onGoingStreamVC, animated: true)
        }
        else{
            presentWelcomeController()
        }
        
    }
    
    
    
    
    /* Bug Name :  View Check that when we open the post from the users profile and viewed for 3 sec is it increasing the count the view. It should increase the view count.
     Fix Date : 05-apr-2021
     Fixed By : Vishal D
     Description Of Fix : added schedular
     */
    @objc func viewCountUpdate(){
        guard let currentPlayer = self.currentIJKPlayer else{return}
        watchedDuration = Int(currentPlayer.currentPlaybackTime)
        videoDuration = Int(currentPlayer.duration)
        var postDetails : SocialModel?
        if !postDetailsCollectionView.isHidden, currentIndex != -1{
            if self.postDetailsViewModel.socialModelArray.count > currentIndex {
                postDetails = self.postDetailsViewModel.socialModelArray[currentIndex]
            }
        }else if !forYouPostsCollectionView.isHidden , forYouPostsCurrenctIndex != -1{
            if self.postDetailsViewModel.forYouPostsModelArray.count > forYouPostsCurrenctIndex {
                postDetails = self.postDetailsViewModel.forYouPostsModelArray[forYouPostsCurrenctIndex]
            }
        }else if !xclusiveCollectionView.isHidden, xClusivePostsCurrentIndex != -1 {
            if self.postDetailsViewModel.xclusivePostsModelArray.count > xClusivePostsCurrentIndex {
                postDetails = self.postDetailsViewModel.xclusivePostsModelArray[xClusivePostsCurrentIndex]
            }
        }
        
        self.storeViewerInDB(postData: postDetails)
    }
    
    
    
    
    
    @IBAction func findFriendAction(_ sender: Any) {
        let addContactsVC = AddContactsViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Contacts) as AddContactsViewController
        addContactsVC.isFromNewFriendsVc = true
        addContactsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addContactsVC, animated: true)
    }
    
    

    
    
    @IBAction func backButtonAction(_ sender: Any) {
        if let status = Utility.getIsGuestUser() , !status {
            
            if self.isCommingFromChat,self.isCommingFromPostsList,let play = self.currentIJKPlayer{
                play.pause()
                play.shutdown()
                self.currentIJKPlayer = nil
            }
            if !self.isCommingFromChat ,!self.isCommingFromPostsList{
                self.activityAction(self.backButtonOutlet as Any)
            }
            else if self.isViewPresented{
                self.dismiss(animated: true, completion: {
                    /*
                     Bug Name :- When we share video via WhatsApp and when open link from WhatsApp the video playing double one original video on app and over its same video playing
                     Fix Date :- 10/07/2021
                     Fixed By :- Jayaram G
                     Description Of Fix :- starting video player after dismiss
                     */
                    self.dismiss(animated: true, completion: {
                        if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                            if let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController{
                                if let postDetails = swipeNav.viewControllers.first as? PostDetailsViewController{
                                    postDetails.startVideoPlayer()
                                }
                            }
                        }
                    })
                })
            }
            else{
                if !self.isFromProfilePage {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }else {
            if isFromTrendingPage {
                self.navigationController?.popViewController(animated: true)
            }else{
                presentWelcomeController()
            }
            
        }
    }
    
    func presentWelcomeController() {
        self.currentIJKPlayer?.pause()
        isVideoPaused = true
        let loginVC = LoginVC.instantiate(storyBoardName: "Authentication") as LoginVC
        loginVC.isFromHomeVC = true
        let navVC = UINavigationController(rootViewController: loginVC)
        navVC.modalPresentationStyle = .overCurrentContext
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true, completion: nil)
    }
    //MARK:- Service call
    
    func getPopularUser(){
        postDetailsViewModel.getPopularUserService { (data, error) in
            self.popularUserCollectionView.reloadData()
            Helper.hidePI()
        }
    }
    
    func getPostDetails(){
        guard let postID = self.postId else {return}
        postDetailsViewModel.getPostDetailsService(postId: postID) { (success, error) in
            if success{
                
                DispatchQueue.main.async {
                    self.postDetailsCollectionView.reloadData()
                }
                
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
        }
    }
    
    func getReportReasons(){
        postDetailsViewModel.getReportReasonsService { (success, error) in
            if success{
                let reportView = ReportView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                reportView.tag = 10
                reportView.delegate  = self
                reportView.reportReasonsArray = self.postDetailsViewModel.reportReasonArray
                appDelegetConstant.window.addSubview(reportView)
                reportView.popUpAnimation()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
        }
    }
    
    func postReportReason(index: Int){
        Helper.showPI()
        var postArray = postDetailsViewModel.socialModelArray
        if !self.postDetailsCollectionView.isHidden{
            postArray = postDetailsViewModel.socialModelArray
        }else if !self.forYouPostsCollectionView.isHidden{
            postArray = postDetailsViewModel.forYouPostsModelArray
        }else if !self.xclusiveCollectionView.isHidden{
            postArray = postDetailsViewModel.xclusivePostsModelArray
        }
        postDetailsViewModel.postReportReasonService(reasonIndex: index, postIndex: currentIndex, postArray: postArray) { (success, error) in
            if success{
                let reportView = appDelegetConstant.window.viewWithTag(10)
                reportView?.popDownAnimation(animationDone: { (finished) in
                    self.showPopUpForSuccessResponse()
                })
                
            } else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.startVideoPlayer()
            }
        }
    }
    
    /// To show pop up and start playing video again
    func showPopUpForSuccessResponse(){
        let alert = UIAlertController(title: "Success".localized, message: "Thank you for your feedback".localized + ". " + "The post has been successfully reported".localized + ".", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok".localized, style: UIAlertAction.Style.default) { (action) in
            self.startVideoPlayer()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// To delete user post
    func deletePostService(){
        
        let data = postDetailsViewModel.socialModelArray[currentIndex]
        guard let postId = data.postId else{return}
        self.postDetailsViewModel.deletePostService(postId: postId) { (success, error) in
            if success{
                if let playingIndex = self.currentPlayingIndexPath{
                    self.postDetailsViewModel.socialModelArray.remove(at: self.currentIndex)
                    self.postDetailsCollectionView.deleteItems(at: [playingIndex])
                    self.setNoPostView()
                }
                
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.postUpdate)
                
                if self.isViewPresented{
                    self.dismiss(animated: true, completion: nil)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
                guard let delegate = self.delegate else{return}
                if self.profileViewModel.postModelArray.count > 0{
                    self.profileViewModel.postModelArray.remove(at: self.currentIndex)
                }
                
                if self.isComingFromSocialPage {
                    delegate.deleteSocialPost!(index: self.currentIndex)
                }
                
                if (delegate.deletedPost != nil){
                    delegate.deletedPost!(isChannel: self.isComingFromChannelPost)
                }
                
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
    }
    
}

//MARK:- collection view delagate and datasource

extension PostDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == postDetailsCollectionView {
            return self.postDetailsViewModel.socialModelArray.count
        }else if collectionView == popularUserCollectionView {
            return self.postDetailsViewModel.popularUserArray.count
        }
        else if collectionView == self.forYouPostsCollectionView {
            return self.postDetailsViewModel.forYouPostsModelArray.count
        }else {
            return self.postDetailsViewModel.xclusivePostsModelArray.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == popularUserCollectionView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularUserCell", for: indexPath) as? PopularUserCell else{return UICollectionViewCell()}
            let popularArray = self.postDetailsViewModel.popularUserArray[indexPath.item]
            cell.configureCell(modelArray: popularArray)
            cell.delegate = self
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeFeedCollectionViewCell", for: indexPath) as? HomeFeedCollectionViewCell else{fatalError()}
            
            /*
             Bug Name:- Handle swipe for three tabs
             Fix Date:- 04/05/2021
             Fixed By:- Jayaram
             Description of Fix:- Added swipe for exclusive posts
             */
            if cell.swipeGesture != nil {
                if collectionView == self.postDetailsCollectionView{
                    cell.swipeGesture?.direction = .right
                }else if collectionView == self.forYouPostsCollectionView{
                    cell.swipeGesture?.direction = .right
                }else if collectionView == self.xclusiveCollectionView{
                    cell.swipeGesture?.direction = .left
                }
            }
            
            if cell.forYouPostsRightGesture != nil {
                if collectionView == forYouPostsCollectionView {
                    cell.forYouPostsRightGesture?.direction = .left
                }
            }
            cell.postDetailsControllerObject = self
            if let tabVC = self.tabBarController{
                cell.bottomConstarint.constant = tabVC.tabBar.frame.size.height
                
            }
            if let tabVC = self.tabBarController{
                cell.bottomConstarint.constant = tabVC.tabBar.frame.size.height
                
            }
            /*
             Bug Name : let’s move the bottom bits up a bit Like ok triller
             Fix Date : 14-May-2021
             Fixed By : Jayaram G
             Description Of Fix : increased bottom space
             */
            if self.tabBarController?.tabBar.isHidden ?? false {
                cell.stackViewBottomConstraint.constant = Utility.getDeviceHeight() > 736.0 ? 40 : 20
            }else{
                cell.stackViewBottomConstraint.constant = Utility.getDeviceHeight() > 736.0 ? 90 : 50
            }
            
            if self.postDetailsViewModel.channelViewModelArray.count > indexPath.row {
                cell.profileChannelModel = self.postDetailsViewModel.channelViewModelArray[indexPath.row]
            }
            
            cell.currentPlayer = self.currentIJKPlayer
            if  collectionView == postDetailsCollectionView, self.postDetailsViewModel.socialModelArray.count > indexPath.row {
                let data = self.postDetailsViewModel.socialModelArray[indexPath.row]
                cell.newFollowersList = self.newFollowersList
                
                /*
                 Feature Name :- Add swipe to switch follow and foryou
                 Feature Date :- 21/04/2021
                 Featured By :- Jayaram G
                 Description Of Feature :- Added swipe gesture left to the following collection view cell
                 */
                if cell.swipeGesture != nil {
                    cell.swipeGesture?.direction = .left
                }
                cell.removeFollowersList = self.removeFollowersList
                cell.socialModel = data
                if isBookMarkedDone {
                    self.isBookMarkedDone = false
                    guard let savedCollectionData = savedCollectionObj else {return UICollectionViewCell()}
                    cell.showViewBookMark(socialModel: data, collectionModel: savedCollectionData)
                }
            }
            else if collectionView == forYouPostsCollectionView, self.postDetailsViewModel.forYouPostsModelArray.count > indexPath.row {
                let data = self.postDetailsViewModel.forYouPostsModelArray[indexPath.row]
                cell.newFollowersList = self.trendingNewFollowersList
                cell.removeFollowersList = self.trendingRemoveFollowersList
                /*
                 Feature Name :- Add swipe to switch follow and foryou
                 Feature Date :- 21/04/2021
                 Featured By :- Jayaram G
                 Description Of Feature :- Added swipe gesture right to the foryou collection view cell
                 */
                if cell.swipeGesture != nil {
                    cell.swipeGesture?.direction = .right
                }
                cell.isTrending = true
                cell.socialModel = data
                if isBookMarkedDone {
                    self.isBookMarkedDone = false
                    guard let savedCollectionData = savedCollectionObj else {return UICollectionViewCell()}
                    cell.showViewBookMark(socialModel: data, collectionModel: savedCollectionData)
                }
            }else if collectionView == xclusiveCollectionView , self.postDetailsViewModel.xclusivePostsModelArray.count > indexPath.row {
                let data = self.postDetailsViewModel.xclusivePostsModelArray[indexPath.row]
                cell.newFollowersList = self.trendingNewFollowersList
                cell.removeFollowersList = self.trendingRemoveFollowersList
                /*
                 Feature Name :- Add swipe to switch follow and foryou
                 Feature Date :- 21/04/2021
                 Featured By :- Jayaram G
                 Description Of Feature :- Added swipe gesture right to the foryou collection view cell
                 */
                if cell.swipeGesture != nil {
                    cell.swipeGesture?.direction = .left
                }
                cell.isXclusive = true
                cell.socialModel = data
                if isBookMarkedDone {
                    self.isBookMarkedDone = false
                    guard let savedCollectionData = savedCollectionObj else {return UICollectionViewCell()}
                    cell.showViewBookMark(socialModel: data, collectionModel: savedCollectionData)
                }
            }
            
            cell.playImageView.isHidden = true
            cell.index = indexPath.row
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("**willDisplay\(indexPath)**")
        guard let cell = cell as? HomeFeedCollectionViewCell  else{
            return
        }
        cell.playImageView.isHidden = true
        self.isVideoPaused = false
        cell.muteBtn.isSelected = self.audioPaused
        cell.setFollowingUserStatus()
        cell.newFollowersList = self.newFollowersList
        cell.removeFollowersList = self.removeFollowersList
        
//        cell.videoBufferingIndicatorView.stopAnimating()
            if followingPostsBtnOutlet.isSelected{
                self.playVideoOnTheCell(cellType : .FollowingPosts,cell: cell, indexPath: indexPath,checkCurrentPlayingCondition: true,isFromWillDisplay: true)
            }else if forYouPostsBtnOutlet.isSelected {
                self.playVideoOnTheCell(cellType :.TrendingPosts ,cell: cell, indexPath: indexPath,checkCurrentPlayingCondition: true,isFromWillDisplay: true)
            }else if xclusivePostsButton.isSelected{
                self.playVideoOnTheCell(cellType:.ExclusivePosts, cell: cell, indexPath: indexPath,checkCurrentPlayingCondition: true,isFromWillDisplay: true)
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        if followingPostsBtnOutlet.isSelected, indexPath == currentPlayingIndexPath{
            self.playVideoForSelectedSection()
            }else if forYouPostsBtnOutlet.isSelected, indexPath == forYouCurrentPlayingIndexPath {
                self.playVideoForSelectedSection()
            }else if xclusivePostsButton.isSelected, indexPath == currentIndexPathForXclusive{
                self.playVideoForSelectedSection()
            }
        
        
        if collectionView != popularUserCollectionView{
            var posts : [SocialModel]?
            if collectionView == postDetailsCollectionView{
                posts = self.postDetailsViewModel.socialModelArray
            }
            else if collectionView == forYouPostsCollectionView{
                posts = self.postDetailsViewModel.forYouPostsModelArray
            }else if collectionView == xclusiveCollectionView {
                posts = self.postDetailsViewModel.xclusivePostsModelArray
            }
            
            
            if let player = self.currentIJKPlayer {
                watchedDuration = Int(player.currentPlaybackTime)
                videoDuration = Int(player.duration)
            }
            else{
                watchedDuration = 0
                videoDuration = 0
            }
            
            
            if collectionView == postDetailsCollectionView && self.followingPostsBtnOutlet.isSelected, self.postDetailsViewModel.socialModelArray.count > indexPath.row{
                // Only for Media cell
                if !self.isFromTrendingPage,!self.isFromProfilePage, indexPath.row == self.postDetailsViewModel.socialModelArray.count - 6 && self.postDetailsViewModel.socialModelArray.count > (self.socialViewModel.limit * self.postDetailsViewModel.offset) + (self.socialViewModel.limit - 6)  {
                    self.postDetailsViewModel.offset = self.postDetailsViewModel.offset + 20
                    self.homeServiceCall()
                }
                else if self.isFromTrendingPage,!self.isFromProfilePage, self.postDetailsViewModel.socialModelArray.count > indexPath.row, indexPath.row == self.postDetailsViewModel.socialModelArray.count - 5 && self.postDetailsViewModel.socialModelArray.count > (self.postDetailsViewModel.limit * self.postDetailsViewModel.hashTagPostsOffset) + (self.postDetailsViewModel.limit - 5) {
                    self.postDetailsViewModel.hashTagPostsOffset = self.postDetailsViewModel.hashTagPostsOffset + 20
                    self.homeServiceCall()
                }
                
            }
            else if collectionView == forYouPostsCollectionView , self.forYouPostsBtnOutlet.isSelected{
                if self.postDetailsViewModel.forYouPostsModelArray.count > indexPath.row ,indexPath.row == self.postDetailsViewModel.forYouPostsModelArray.count - 6 && self.postDetailsViewModel.forYouPostsModelArray.count > (self.postDetailsViewModel.limitForForYouPosts * self.postDetailsViewModel.offset) + (self.postDetailsViewModel.limitForForYouPosts - 6) {
                    self.postDetailsViewModel.offsetForForYouPosts = self.postDetailsViewModel.offsetForForYouPosts + 20
                    self.forYouPostshomeServiceCall()
                    
                }
            }else if collectionView == xclusiveCollectionView, self.postDetailsViewModel.xclusivePostsModelArray.count > indexPath.row, !self.isFromTrendingPage,!self.isFromProfilePage, indexPath.row == self.postDetailsViewModel.xclusivePostsModelArray.count - 6 && self.canServiceCallForXclusive {
                self.postDetailsViewModel.xclusivePostsOffset = self.postDetailsViewModel.xclusivePostsOffset + 20
                self.getXclusivePostsServiceCall()
                
            }
            
            if isCommingFromChat {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    if let data = posts, data.count > indexPath.row , UserDefaults.standard.value(forKey: AppConstants.UserDefaults.LoggedInUser) != nil{
                        self.storeViewerInDB(postData: data[indexPath.row])
                    }
                }
            }
        }
        
        if collectionView != self.popularUserCollectionView{
            var posts : [SocialModel]?
            if collectionView == postDetailsCollectionView{
                posts = self.postDetailsViewModel.socialModelArray
            }
            else if collectionView == forYouPostsCollectionView{
                posts = self.postDetailsViewModel.forYouPostsModelArray
            }else if collectionView == xclusiveCollectionView {
                posts = self.postDetailsViewModel.xclusivePostsModelArray
            }
            if let data = posts, data.count > indexPath.row , UserDefaults.standard.value(forKey: AppConstants.UserDefaults.LoggedInUser) != nil{
                self.storeViewerInDB(postData: data[indexPath.row])
            }
        }
        
    }
    
    func playVideoForSelectedSection(checkPlayingConditionForCurrentIndex:Bool = true){
        if followingPostsBtnOutlet.isSelected,let visibleIndex = self.postCollectionViewCurrentVisibleCellInCenter().0, let visibleCell = self.postCollectionViewCurrentVisibleCellInCenter().1{
            visibleCell.playImageView.isHidden = true
            self.isVideoPaused = false
            visibleCell.muteBtn.isSelected = self.audioPaused
            visibleCell.playImageView.isHidden = true
            self.playVideoOnTheCell(cellType : .FollowingPosts,cell: visibleCell, indexPath: visibleIndex,checkCurrentPlayingCondition: checkPlayingConditionForCurrentIndex)
            
        }else if forYouPostsBtnOutlet.isSelected , let visibleIndex = self.trendingCollectionViewCurrentVisibleCellInCenter().0, let visibleCell = self.trendingCollectionViewCurrentVisibleCellInCenter().1  {
            visibleCell.playImageView.isHidden = true
            visibleCell.muteBtn.isSelected = self.audioPaused
            self.isVideoPaused = false
            self.playVideoOnTheCell(cellType: .TrendingPosts, cell: visibleCell, indexPath: visibleIndex,checkCurrentPlayingCondition: checkPlayingConditionForCurrentIndex)
        }else if xclusivePostsButton.isSelected , let visibleIndex = self.xclusiveCollectionViewCurrentVisibleCellInCenter().0, let visibleCell = self.xclusiveCollectionViewCurrentVisibleCellInCenter().1 {
            visibleCell.playImageView.isHidden = true
            visibleCell.muteBtn.isSelected = self.audioPaused
            self.isVideoPaused = false
            self.playVideoOnTheCell(cellType: .ExclusivePosts,cell: visibleCell, indexPath: visibleIndex,checkCurrentPlayingCondition: checkPlayingConditionForCurrentIndex)
        }
    }
    
    /// Get the visible indexes of the collection view
    /// - Parameter inCollectionView: target collectionview object
    /// - Returns: return the tuple where 0 = Indexpath, 1 = HomeFeedCollectionViewCell
    func postCollectionViewCurrentVisibleCellInCenter() -> (IndexPath?, HomeFeedCollectionViewCell?){
        var visibleRect    = CGRect()
        visibleRect.origin =  postDetailsCollectionView.contentOffset
        visibleRect.size   = postDetailsCollectionView.bounds.size
        let visiblePoint   = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let visibleIndexPath: IndexPath = postDetailsCollectionView.indexPathForItem(at: visiblePoint),let visibleCell = self.postDetailsCollectionView.cellForItem(at: visibleIndexPath) as? HomeFeedCollectionViewCell else { return (nil,nil) }
        return (visibleIndexPath,visibleCell)
    }
    
    /// Get the visible indexes of the collection view
    /// - Parameter inCollectionView: target collectionview object
    /// - Returns: return the indexPath of fully viisble cell
    func trendingCollectionViewCurrentVisibleCellInCenter() -> (IndexPath?, HomeFeedCollectionViewCell?){
        var visibleRect    = CGRect()
        visibleRect.origin =  forYouPostsCollectionView.contentOffset
        visibleRect.size   = forYouPostsCollectionView.bounds.size
        let visiblePoint   = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let visibleIndexPath: IndexPath = forYouPostsCollectionView.indexPathForItem(at: visiblePoint),let visibleCell = self.forYouPostsCollectionView.cellForItem(at: visibleIndexPath) as? HomeFeedCollectionViewCell else { return (nil,nil) }
        return (visibleIndexPath,visibleCell)
    }
    
    /// Get the visible indexes of the collection view
    /// - Parameter inCollectionView: target collectionview object
    /// - Returns: return the indexPath of fully viisble cell
    func xclusiveCollectionViewCurrentVisibleCellInCenter() -> (IndexPath?, HomeFeedCollectionViewCell?){
        var visibleRect    = CGRect()
        visibleRect.origin =  xclusiveCollectionView.contentOffset
        visibleRect.size   = xclusiveCollectionView.bounds.size
        let visiblePoint   = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let visibleIndexPath: IndexPath = xclusiveCollectionView.indexPathForItem(at: visiblePoint),let visibleCell = self.xclusiveCollectionView.cellForItem(at: visibleIndexPath) as? HomeFeedCollectionViewCell else { return (nil,nil) }
        return (visibleIndexPath,visibleCell)
    }
    
    /// Store viewer id and post details
    /// - Parameter post: Post model
    func storeViewerInDB(postData:SocialModel?){
        guard let post = postData, let userId = Utility.getUserid(), let postId =  post.postId, let mediaType =  post.mediaType else{return}
        var param = [
            "postType": mediaType,
            "postId" :  postId ,
            "viewerId" : userId] as [String : Any]
        /* Bug Name :  View    Check that when we open the post from the hastag and viewed the post for 3 sec is it increasing the view count.    It should increase the view count
         Fix Date : 05-apr-2021
         Fixed By : Vishal D
         Description Of Fix : changed time duration
         */
        if mediaType == 1, watchedDuration > 3{
            param.updateValue(videoDuration, forKey: "videoDuration")
            param.updateValue(watchedDuration, forKey: "watchedDuration")
            Utility.storePostsViewersInDatabase(couchbase: couchbase, viewer:param )
        }
        else if mediaType == 0{
            Utility.storePostsViewersInDatabase(couchbase: couchbase, viewer:param )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.popularUserCollectionView{
            let width = self.popularUserCollectionView.frame.size.width/2
            return CGSize(width: width - 30 , height:width + 15)
        }
        let size = self.postDetailsCollectionView.frame.size
        return CGSize(width: size.width , height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.popularUserCollectionView{
            return 5
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.popularUserCollectionView{
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}


