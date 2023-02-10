//
//  SocialViewController.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 27/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import DGElasticPullToRefresh

import QuiltView
import IJKMediaFramework
import AVFoundation
import AVKit
import CocoaLumberjack
import Locksmith
class SocialViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var socialCollectionView: UICollectionView!
    @IBOutlet weak var uploadingStatusLabel: UILabel!
    @IBOutlet weak var uploadingPercentageLabel: UILabel!
    @IBOutlet weak var newPostedImageView: UIImageView!
    @IBOutlet weak var uploadingProgressView: UIProgressView!
    @IBOutlet weak var uploadingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noPostView: UIView!
    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var cameraButtonOulet: UIButton!
    @IBOutlet weak var notFollowedLbl: UILabel!
    @IBOutlet weak var findFriendsLbl: UILabel!
    
    @IBOutlet weak var userProfileView: UIView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var appNameLabel: UILabel!
   
    @IBOutlet weak var balanceLabelOutlet: UILabel!
    @IBOutlet weak var popularUserCollectionView: UICollectionView!
    
    var imageArrayToVideoURL : URL?
    var userDetailsImage = UIImage()
    var isLoadedFirst: Bool = true
    var postDetailsViewModel = PostDetailsViewModel()
    var currentIndex: Int = -1
    var visibleIP: IndexPath?
    var aboutToBecomeInvisibleCell: Int = -1
    var player:IJKFFMoviePlayerController!
    /* bug Name :- No audio playing for videos
     Fix Date :- 10/03/2021
     Fixed By :- Jayaram G
     Description Of fix :- Setting mute status false initially
     */
    var isMuted: Bool = false
    var isSelf:Bool?
    var likeUpdate:Bool = false
    var isBookMarkedDone: Bool = false
    var savedCollectionObj:SavedCollectionModel?
    
    /// Note to run a time to invoke the prepare to play for Player
    var preparetoPlayTimer: Timer?
    /// To check wheather screen is still visible or has tab been swiched
    var isViewVisible = false
    /// Store the index path of current media cell, to compare if same will reload again
    var currentPlayingIndexPath : IndexPath?
    /// To play the video first time without scrolling
    var playFirstTime = true
    
    struct cellIdentifier {
        static let socialCollectionCell = "socialCollectionCell"
        static let SocialStoriesCollectionViewCell = "SocialStoriesCollectionViewCell"
        static let SocialInstaCollectionViewCell = "SocialInstaCollectionViewCell"
    }
    
    struct Controlleridentifier {
        static let postedByController = "postedByController"
        static let commentsViewController = "commentsViewController"
        static let profileViewController = "ProfileViewController"
        static let SharePostViewController = "SharePostViewController"
        static let ViewStoryID = "viewStoryID"
        static let CameraViewController = "CameraViewController"
    }
    
    
    let socialViewModel = SocialViewModel()
    
    var canServiceCall: Bool = true
    
    let bottomEdge: CGFloat = 20.0
    
    var needToRefresh:Bool = true
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        addNotificationCenterObservers()
        addIJKMPMoviePlayerNotificationCenterObservers()
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP])
        loadViewUI()
        UIView.setAnimationsEnabled(true)
        if let guestUserStatus = Utility.getIsGuestUser() , !guestUserStatus {
            ApiHelper.shared.getWallet(userId: Utility.getUserid() ?? "") { _ in
                self.updateWalletData()
            }
        }
        
        
     
        
        let isNetwork = (UIApplication.shared.delegate as? AppDelegate)?.isNetworkThere
        if isNetwork == false{
            Helper.showAlertViewOnWindow("Oops".localized, message: "Check Internet Connection".localized)
        }else{
            if self.socialViewModel.socialModelArray.count == 0 {
                self.homeServiceCall()
            }
            /*
             Bug Name:- stories not updating
             Fix Date:- 31/05/21
             Fixed By:- Jayaram G
             Description of Fix:- calling apis in viewDidload
             */
                self.getMyStoryService()
                self.socialViewModel.myStoryOffset = -20
                self.socialViewModel.otherStoryOffset = -20
                self.getOtherStoryService()
                self.getUserProfile()
        }
        //        self.addObserVerForCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Utility.isDarkModeEnable(){
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .darkContent
        }
        
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
        if let guestUserStatus = Utility.getIsGuestUser() , !guestUserStatus {
            self.updateWalletData()
            socialViewModel.getVerificationStatus { (success, error) in
                if success {
                    print("verification status recieved")
                }else{
                    print(error)
                }
            }
            let isNetwork = (UIApplication.shared.delegate as? AppDelegate)?.isNetworkThere
            if isNetwork == true{
                self.getUserProfile()
            }
        }
        isSelf = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewVisible = true
        
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        
        Helper.checkConnectionAvaibility(view: self.view) { [self] (status) in
            if status && !needToRefresh {
                needToRefresh = true
                if socialViewModel.socialModelArray.count == 0 {
                    self.refresh()
                }
                
            } else {
                needToRefresh = false
            }
        }
        if likeUpdate {
            self.refresh()
        }
        self.playVideoPlayerFromStoppedState()
        DispatchQueue.main.async {
            Helper.addedUserImage(profilePic: Utility.getUserImage(), imageView: self.userProfileImageView, fullName: Utility.getUserFullName() ?? "P")
            self.userNameLabel.text = "@" + Utility.getUserName()
            self.fullNameLabel.text = Utility.getUserFullName()
            self.appNameLabel.text = AppConstants.AppName
            self.userDetailsImage = self.userProfileView.renderViewToImage()
            Helper.generateVideoFromImages(image: self.userDetailsImage) { url in
                self.imageArrayToVideoURL = url
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isSelf = false
        self.removeObserver()
        self.stopVideoPlayer()
        isViewVisible = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationCenterObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStories), name: NSNotification.Name(rawValue: "RefreshChatStories"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMystories(notification:)), name:NSNotification.Name(rawValue:"updateMyChatStories"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeCell), name: NSNotification.Name(rawValue: "ChangeCell"), object: nil)
        
    }
    
    
    func addIJKMPMoviePlayerNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.startAgainPlaying), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playingStateChange), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playbackIsPreparedToPlayDidChange), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
        
        // background event
        NotificationCenter.default.addObserver(self, selector: #selector(stopVideoPlayer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // foreground event
        NotificationCenter.default.addObserver(self, selector: #selector(startVideoPlayer), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // add these 2 notifications to prevent freeze on long Home button press and back
        NotificationCenter.default.addObserver(self, selector: #selector(stopVideoPlayer), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startVideoPlayer), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "createNewPost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RefreshChatStories"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:"updateMyChatStories"), object: nil)
    
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
        
        // background event
        NotificationCenter.default.removeObserver(self,name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // foreground event
        NotificationCenter.default.removeObserver(self,name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // add these 2 notifications to prevent freeze on long Home button press and back
        NotificationCenter.default.removeObserver(self,name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self,name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if socialCollectionView != nil{
            socialCollectionView.dg_removePullToRefresh()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func playbackIsPreparedToPlayDidChange(){
                self.preparetoPlayTimer?.invalidate()
                self.preparetoPlayTimer = nil
    }
    
    /// To start playing video from starting
    @objc fileprivate func startVideoPlayer(){
        if let play = self.player{
            if #available(iOS 10.0, *) {
                if play.playbackState == .paused, isViewVisible{
                    play.play()
                }
                else if play.playbackState == .stopped{
                    self.playVideoPlayerFromStoppedState()
                }
            }
        }
    }
    
    /*
     Bug Name:- background video playing when receiving call
     Fix Date:- 25 Aug 2021
     Fixed By:- Jayaram G
     Description of Fix:- setting volume to 0
     */
    func muteVideo(){
        if let play = self.player{
            play.playbackVolume = 0.0
            self.isMuted = true
        }
    }
    
    /// To stop playing video
    @objc  func stopVideoPlayer(){
            self.player?.stop()
            self.preparetoPlayTimer?.invalidate()
            self.preparetoPlayTimer = nil
        }
    
    
    @objc func startAgainPlaying(){
        guard let currentPlayer = self.player else{return}
        //  viewCountUpdate()
        if isViewVisible {
            DispatchQueue.main.async {
                currentPlayer.prepareToPlay()
                currentPlayer.play()
            }
        }
    }
    
    /// To monitor player status changed
    @objc func playingStateChange(){
        guard let currentPlayer = self.player else{return}
        switch currentPlayer.playbackState {
        case .playing:
            print("Start playing")
            break
        case .stopped:
            print("Stop playing")
            break
        case .interrupted:
            print("playing Interrupted")
            break
        case .paused:
            print("playing pause")
            break
        case .seekingForward, .seekingBackward:
            break
        }
    }

    
    /// To load view with initial setup
    func loadViewUI(){
        let logo = UIImage(named: "StarChat")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        self.socialCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: bottomEdge, right: 0)
        self.userProfileImageView.makeCornerRadious(readious: self.userProfileImageView.frame.size.width/2)
        
        // Initialize socialCollectionView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        self.notFollowedLbl.text = "You have not followed anyone".localized + ". " + "Follow some users to see their posts here".localized + "."
        self.findFriendsLbl.text = "Find friends to follow".localized
        socialCollectionView.tintColor = UIColor.white
        socialCollectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            self?.socialViewModel.offset = -20
            self?.socialViewModel.myStoryOffset = -20
            self?.socialViewModel.otherStoryOffset = -20

            /*
             Refactor Name:- add randomScore params in guest post api
             Refactor Date:- 19/04/21
             Refacotr By  :- Nikunj C
             Description of Refactor:- change randomScore when refresh  page
             */
            let randomScore = Int.random(in: 0..<1000000000)
            UserDefaults.standard.set(randomScore, forKey: AppConstants.UserDefaults.randomScore)
            self?.homeServiceCall()
            self?.getMyStoryService()
            self?.getOtherStoryService()
            }, loadingView: loadingView)
        socialCollectionView.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        socialCollectionView.dg_setPullToRefreshBackgroundColor(socialCollectionView.backgroundColor!)
        
        self.uploadingProgressView.progress = 0
        self.uploadingPercentageLabel.text = "0%"
        self.uploadingViewHeightConstraint.constant = 0
        
        //Setting camera related UI's
        //     self.cameraContainerView.makeCornerRadious(readious: cameraContainerView.frame.size.height / 2)
        
        self.cameraButtonOulet.makeCornerRadious(readious: cameraButtonOulet.frame.size.height / 2)
        //        let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
        //        let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
        //  self.cameraContainerView.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
        self.socialCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 65, right: 0)
        
        
    }
    
    func updateWalletData(){
        let walletData = Double(KeychainHelper.sharedInstance.getCoinWalletBalance())?.formatUsingAbbrevation()
        self.balanceLabelOutlet.text = " \(walletData ?? "") "
    }
    
    
    /// To setup no post view
    private func setNoPostView(){
        if self.socialViewModel.socialModelArray.count == 0 || self.socialViewModel.socialModelArray == nil{
            getPopularUser()
            self.popularUserCollectionView.isHidden = false
            self.noPostView.isHidden = false
        }else{
            self.noPostView.isHidden = true
            self.popularUserCollectionView.isHidden = true
        }
    }
    
    //MARK:- Service call
    
    func getPopularUser(){
        socialViewModel.getPopularUserService { (data, error) in
            self.popularUserCollectionView.reloadData()
            Helper.hidePI()
        }
    }
    

    
    @objc func showViewCollections(_ notification: NSNotification){
        if let collectionModel = notification.object as? SavedCollectionModel {
            self.savedCollectionObj = collectionModel
        }
        self.isBookMarkedDone = true
        self.socialCollectionView.reloadData()
    }
    
    
    //MARK:- Button Action
    @IBAction func searchButtonAction(_ sender: Any) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        self.presentSearchViewController()
    }
    
    @IBAction func liveAction(_ sender: Any) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.live, bundle: nil)
        guard let onGoingStreamVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.OnGoingStreamVC) as? OnGoingStreamVC else{return}
        onGoingStreamVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(onGoingStreamVC, animated: true)
    }
    
    
    @IBAction func findFriendAction(_ sender: Any) {
        //        self.presentSearchViewController()
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let addContactsVC = AddContactsViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Contacts) as AddContactsViewController
        addContactsVC.isFromNewFriendsVc = true
        addContactsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addContactsVC, animated: true)
    }
    
    @IBAction func profileAction(_ sender: UIButton) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        profileVC.isSelf = true
        profileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func activityAction(_ sender: Any) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let activityVc = ActivityViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Activity) as ActivityViewController
        activityVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(activityVc, animated: true)
    }
    
    /// To present search view controller
    private func presentSearchViewController(){
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        if let trendingVC : TrendingViewController = ((self.tabBarController?.viewControllers![3] as? SwipeNavigationController)?.viewControllers.first) as? TrendingViewController{
            trendingVC.showSearch = true
        }
        self.tabBarController?.selectedIndex = 1
    }
    
    
    @IBAction func muteAndUnmuteAction(_ sender: Any) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        self.isMuted = !self.isMuted
        guard let button = sender as? UIButton else{return}
        let image = self.isMuted ? UIImage(named: "home_mute") : UIImage(named: "unmute")
        DispatchQueue.main.async{
            button.setImage(image, for: .normal)
            if let play = self.player{
                play.playbackVolume = self.isMuted ? 0.0 : 1.0
            }
        }
    }
    
    
    @IBAction func openCameraButtonAction(_ sender: Any) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        self.presentCameraVC()
    }
    
    

    
    
    //MARK:- Service call
    func homeServiceCall(){
        if self.isLoadedFirst{
            self.isLoadedFirst = false
            Helper.showPI()
        }
        socialViewModel.getHomeServiceData {[weak self] (success, error, canServiceCall) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                Helper.hidePI()
                DispatchQueue.main.async {
                    self.socialCollectionView.dg_stopLoading()
                }
                if success {
                    self.setNoPostView()
                    DispatchQueue.main.async {
                        self.socialCollectionView.dg_stopLoading()
                    }
                } else if let error = error {
                    self.socialCollectionView.dg_stopLoading()
                    // 204 - No data in server
                    if error.code != 204 {
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                    }
                    self.socialViewModel.offset = self.socialViewModel.offset - 20
                }
                self.canServiceCall = canServiceCall
                DispatchQueue.main.async {
                    self.playFirstTime = true
                    self.currentPlayingIndexPath = nil
                    self.socialCollectionView.reloadData()
                }
            }
        }
    }
    
    func getMyStoryService() {
        let strUrl = AppConstants.myStory
        socialViewModel.storyServiceCall(strUrl: strUrl, storyType: .myStory) { [weak self] (success, error) in
            guard let self = self else { return }
            /*
             Bug Name:- Story is not being displayed even after we redirect to other tabs. We have to refresh the page to view the story
             Fix Date:- 24th July 2021
             Fixed By:- Nikunj C
             Description of Fix:- reload section 1 after get response
             */
            if self.socialViewModel.socialModelArray.count > 0 {
                if AppConstants.appType == .picoadda{
                    let index = IndexPath(item: 0, section: 0)
                    self.socialCollectionView.reloadData()
                }
            }
            //            }
        }
    }
    
    func getOtherStoryService(){
        let strUrl = AppConstants.story
        socialViewModel.storyServiceCall(strUrl: strUrl, storyType: .otherStory) { [weak self] (success, error) in
            //            print("success")
            //            DispatchQueue.main.async {
            if self?.socialViewModel.socialModelArray.count ?? 0 > 0{
                if AppConstants.appType == .picoadda{
                    /*
                     Bug Name:- Story is not being displayed even after we redirect to other tabs. We have to refresh the page to view the story
                     Fix Date:- 24th July 2021
                     Fixed By:- Nikunj Cs
                     Description of Fix:- reload section 1 after get response
                     */
                    let index = IndexPath(item: 0, section: 0)
                    self?.socialCollectionView.reloadItems(at: [index])
                }
            }
            //            }
        }
    }
    
    
    
    /// To get follow and following user details to show in share screen
    func followFollowingServiceCall(){
        let strURl: String = AppConstants.followersFollowee
        socialViewModel.followFollowingServiceCall(strUrl: strURl)
    }
    
}

//MARK:- Collection view datasource and delegate
extension SocialViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout/* UICollectionViewDataSourcePrefetching*/{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == popularUserCollectionView {
            return 1
        }else{
            return self.socialViewModel.socialModelArray.count + 1
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == popularUserCollectionView {
            return self.socialViewModel.popularUserArray.count
        }else{
            if section == 0{
                return 1
            }else{
                return  2
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView != popularUserCollectionView {
            if indexPath.section != 0  {
                if self.socialViewModel.socialModelArray.count > indexPath.section {
                    let indexPassed: Bool = indexPath.section >= self.socialViewModel.socialModelArray.count - 10
                    if canServiceCall && indexPassed{
                        canServiceCall = false
                        homeServiceCall()
                    }
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == popularUserCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularUserCell", for: indexPath) as? PopularUserCell else{return UICollectionViewCell()}
            let popularArray = self.socialViewModel.popularUserArray[indexPath.item]
            cell.configureCell(modelArray: popularArray)
            cell.delegate = self
            return cell
        }else{
            if indexPath.section == 0{
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.SocialStoriesCollectionViewCell, for: indexPath) as? SocialStoriesCollectionViewCell else { fatalError() }
                let model = self.socialViewModel
                cell.setCellDataInStoryCell(storys: model.myStories, recStories: model.recentStories, viewStories: model.viewedStories)
                cell.delegate = self
                self.view.layoutIfNeeded()
                return cell
            }else{
                if indexPath.row == 1 {
                    guard let detailsCell = collectionView.dequeueReusableCell(withReuseIdentifier: String.init(describing: SocialInstaDetailsCollectionViewCell.self), for: indexPath) as? SocialInstaDetailsCollectionViewCell else{fatalError()}
                    if self.socialViewModel.socialModelArray.count > indexPath.section - 1{
                        let data = self.socialViewModel.socialModelArray[indexPath.section - 1]
                        detailsCell.setSocialCellData(socialModel: data)
                        detailsCell.index = indexPath.section - 1
                        detailsCell.delegate = self
                        detailsCell.btnBookmark.tag = indexPath.section - 1
                        detailsCell.btnBookmark.isSelected = data.isBookMarked
                        self.view.layoutIfNeeded()
                    }
                   
                    return detailsCell
                }else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.SocialInstaCollectionViewCell, for: indexPath) as? SocialInstaCollectionViewCell else{fatalError()}
                              
                              if self.socialViewModel.socialModelArray.count > indexPath.section-1 {
                                  let data = self.socialViewModel.socialModelArray[indexPath.section-1]
                                  cell.setSocialCellData(socialModel: data)
                                  if isBookMarkedDone {
                                      self.isBookMarkedDone = false
                                      guard let savedCollectionData = savedCollectionObj else {return UICollectionViewCell()}
                                   //   cell.showViewBookMark(socialModel: data, collectionModel: savedCollectionData)
                                  }
                                  
                                  cell.index = indexPath.section - 1
                                  cell.btnOptions.tag = indexPath.section - 1
                                  cell.btnSaveToCollection.tag = indexPath.section - 1
                                  cell.delegate = self
                                  let postUserId = data.userId!
    //                              if let userId = Utility.getUserid(){
    //                                  if postUserId == userId{
    //                                      cell.btnOptions.isHidden = false
    //                                  }else{
    //                                      cell.btnOptions.isHidden = true
    //                                  }
    //                              }
                                /*
                                 Bug Name:- In Home Page: the video post once muted and page refereshed, the video is still mute and the mute button is crossed even when we unmute other video and scroll back to the muted old video post.
                                 Fix Date:- 17/06/21
                                 Fixed By:- Jayaram G
                                 Description of Fix:- changing mute icon
                                 */
                                  let image = self.isMuted ? UIImage(named: "home_mute") : UIImage(named: "unmute")
                                  cell.muteUnmuteButtonOutlet.setImage(image, for: .normal)
                                  self.view.layoutIfNeeded()
                                  
                              }
                    //Note : to play first visible video on invoking datasource methods
                    if  indexPath.section ==  1, playFirstTime{
                        cell.playPauseVideoImageView.isHidden = true
                        self.playFirstTime = false
                        self.playVideoOnTheCell(cell: cell, indexPath: indexPath)
                    }
                              return cell
                          }
                }
        }
    
          
    }
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let visibleIndex = self.CurrentVisibleCellInCenter().0, let visibleCell = self.CurrentVisibleCellInCenter().1{
            let image = self.isMuted ? UIImage(named: "home_mute") : UIImage(named: "unmute")
            visibleCell.muteUnmuteButtonOutlet.setImage(image, for: .normal)
            visibleCell.playPauseVideoImageView.isHidden = true
                self.playVideoOnTheCell(cell: visibleCell, indexPath: visibleIndex)
        }
     }

 /// Get the visible indexes of the collection view
 /// - Parameter inCollectionView: target collectionview object
 /// - Returns: return the indexPath of fully viisble cell
 func CurrentVisibleCellInCenter() -> (IndexPath?, SocialInstaCollectionViewCell?){
    var visibleRect    = CGRect()
    visibleRect.origin = socialCollectionView.contentOffset
    visibleRect.size   = socialCollectionView.bounds.size
    let visiblePoint   = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

   guard let visibleIndexPath: IndexPath = socialCollectionView.indexPathForItem(at: visiblePoint),visibleIndexPath.row == 0,let visibleCell = self.socialCollectionView.cellForItem(at: visibleIndexPath) as? SocialInstaCollectionViewCell else { return (nil,nil) }
     return (visibleIndexPath,visibleCell)
}



 /// To prepare and play video when cell is visiable
 ///
 /// - Parameters:
 ///   - cell: visiable cell
 ///   - indexPath: index path of visiable cell
 private func playVideoOnTheCell(cell : SocialInstaCollectionViewCell, indexPath : IndexPath,checkCurrentPlayingCondition:Bool = true){
     
             self.preparetoPlayTimer?.invalidate()
             self.preparetoPlayTimer = nil
     
    if let currentIndexPath = currentPlayingIndexPath, currentIndexPath.section == indexPath.section,checkCurrentPlayingCondition{
         return
     }
      currentPlayingIndexPath = indexPath
      currentIndex = indexPath.section - 1
     if self.socialViewModel.socialModelArray.count > indexPath.section-1 {
         let data = self.socialViewModel.socialModelArray[indexPath.section-1]
         //Pause video and remove player from super if mdeia is image
         if self.player != nil{
             self.player.shutdown()
             self.player.view.removeFromSuperview()
             self.player = nil
         }
         if data.mediaType == 0{
             return
         }
         guard let url = cell.videoUrl,isViewVisible else{return}
         self.play(url, cell: cell)
         self.player.playbackVolume = self.isMuted ? 0.0 : 1.0
         
         
     }
 }

 fileprivate func play(_ url: URL?, cell: SocialInstaCollectionViewCell) {
     let options = IJKFFOptions.byDefault()
     self.player = IJKFFMoviePlayerController(contentURL: url!, with: options)
     self.player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
     
     self.player.view.frame = cell.postImageView.bounds
     self.player.scalingMode = .aspectFit
     self.player.shouldAutoplay = true
     cell.autoresizesSubviews = true
     cell.postImageView.addSubview((self.player.view)!)
     self.player?.prepareToPlay()
     self.preparetoPlayTimer?.invalidate()
     self.preparetoPlayTimer = nil
     self.preparetoPlayTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.runTimerToInvokePrepareToPlay), userInfo: nil, repeats: false)
 }

 func playVideoPlayerFromStoppedState(){

     DispatchQueue.main.async { [self] in
         if  let visibleCell = CurrentVisibleCellInCenter().1, let visibleIndex = CurrentVisibleCellInCenter().0 {
             let image = self.isMuted ? UIImage(named: "home_mute") : UIImage(named: "unmute")
             visibleCell.muteUnmuteButtonOutlet.setImage(image, for: .normal)
             visibleCell.playPauseVideoImageView.isHidden = true
             self.playVideoOnTheCell(cell: visibleCell, indexPath: visibleIndex,checkCurrentPlayingCondition: false)
         }
     }
 }

 @objc func runTimerToInvokePrepareToPlay(){
     if let play = self.player,!play.isPreparedToPlay, isViewVisible{
         self.stopVideoPlayer()
         self.playVideoPlayerFromStoppedState()
     }
     else{
         self.preparetoPlayTimer?.invalidate()
         self.preparetoPlayTimer = nil
     }
 }

 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     if indexPath.section != 0{
         if let play = self.player, let visibleIndex = CurrentVisibleCellInCenter().0, let newCell = CurrentVisibleCellInCenter().1{
             DispatchQueue.main.async {
                 if play.isPlaying(){
                     newCell.playPauseVideoImageView.isHidden = false
                     play.pause()
                 }else{
                     newCell.playPauseVideoImageView.isHidden = true
                     if !play.isPreparedToPlay{
                        self.playVideoOnTheCell(cell: newCell, indexPath: visibleIndex)
                         return
                     }
                     play.play()
                 }
                 
             }
         }
     }
 }

 
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.popularUserCollectionView{
            let width = self.popularUserCollectionView.frame.size.width/2
            return CGSize(width: width - 30 , height:width + 15)
        }else {
            if indexPath.section == 0 {
                let width = self.view.frame.size.width
                return CGSize(width: width, height: 100)
            }else {
                if indexPath.row == 1 {
                    let width = self.view.frame.size.width
                    //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.SocialInstaCollectionViewCell, for: indexPath) as! SocialInstaCollectionViewCell
                    var titleHeight: CGFloat = 0.0
                    var firstCommentHeight: CGFloat = 0.0
                    var secondCommentHeight: CGFloat = 0.0
                    var viewAllCommentHeight: CGFloat = 0.0
                    if self.socialViewModel.socialModelArray.count > indexPath.section-1 {
                        let data = self.socialViewModel.socialModelArray[indexPath.section-1]
                        /*
                         Bug Name:- Add readmore/readless
                         Fix Date:- 22/06/21
                         Fixed By:- Jayaram G
                         Description of Fix:- Handling item size
                         */
                        if data.isExpand {
                            if data.title?.count != 0, let title =  data.title{
                                titleHeight = 20 + title.height(withConstrainedWidth: width - 20
                                    , font: UIFont.init(name: "CenturyGothic", size: 12.0)!)
                            }
                        }else {
                            if data.title?.count != 0, let title =  data.title{
                            titleHeight = 45
                            }else {
                                titleHeight = 10
                            }
                        }
                        
                        if data.commentModelArray.count > 0{
                            let commentArray = data.commentModelArray
                            let firstComment = commentArray[0].commentedBy! + "  " + commentArray[0].comment!
                            firstCommentHeight = firstComment.height(withConstrainedWidth: width - 20, font: UIFont.init(name: "CenturyGothic", size: 12.0)!)
                            if data.commentModelArray.count > 1{
                                let secondComment = commentArray[1].commentedBy! + "  " + commentArray[1].comment!
                                secondCommentHeight = secondComment.height(withConstrainedWidth: width - 20, font: UIFont.init(name: "CenturyGothic", size: 12.0)!)
                            }
                            if data.commentCount > 2{
                                viewAllCommentHeight = 15.0
                            }
                        }
                    }
                    let height = 70 + titleHeight + firstCommentHeight + secondCommentHeight + viewAllCommentHeight
                    return CGSize(width: width, height: height + 10)
                }else {
                    return CGSize(width: self.view.frame.size.width, height : self.view.frame.size.width + 60)
                }
            }
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt ssection: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
   
   
}


extension SocialViewController: SocialInstaCollectionViewCellDelegate{
    func followUserTapped(index: Int, isSelected: Bool) {
        if  self.socialViewModel.socialModelArray.count > index{
            ContactAPI.followAndUnfollowService(with: isSelected, followingId: self.socialViewModel.socialModelArray[index].userId ?? "", privicy: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.refresh()
        }
    }
    
    func zooming(started: Bool) {
           self.socialCollectionView.isScrollEnabled = !started
       }
    
    func paidPostTap(modelData: SocialModel,index: Int) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        guard let walletAmount = Double(KeychainHelper.sharedInstance.getCoinWalletBalance())  else {return}
        guard let paidAmount = Double(modelData.postAmount ?? 0) as? Double else {return}
        if paidAmount > walletAmount{
            if #available(iOS 13.0, *) {
                guard let inSufficientvc = UIStoryboard.init(name: "SendTip", bundle: nil).instantiateViewController(identifier: String(describing: InSufficientCoinsViewController.self)) as? InSufficientCoinsViewController  else {return}
                inSufficientvc.hidesBottomBarWhenPushed = true
                inSufficientvc.delegate = self
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
        }else{
            let storyBoardObj = UIStoryboard.init(name: "Settings", bundle: nil)
            if #available(iOS 13.0, *) {
                guard let unLockConfirmVc = storyBoardObj.instantiateViewController(identifier: "UnLockPostConfirmationViewController") as? UnLockPostConfirmationViewController else {return}
                 unLockConfirmVc.definesPresentationContext = true
                unLockConfirmVc.modalPresentationStyle = .overCurrentContext
                unLockConfirmVc.index = index
                unLockConfirmVc.socialModelData = modelData
                unLockConfirmVc.delegate = self
                var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
                while ((topRootViewController?.presentedViewController) != nil) {
                    topRootViewController = topRootViewController?.presentedViewController
                }
                DispatchQueue.main.async {
                    topRootViewController?.present(unLockConfirmVc, animated: true, completion: nil)
                }
    //            self.present(unLockConfirmVc,animated: true)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func viewCollection() {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let bookMarkedVC : BookMarkedPostsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookMarkedPostsViewController") as! BookMarkedPostsViewController
        bookMarkedVC.collection = self.savedCollectionObj
        bookMarkedVC.isCollectionDetails =  true
        //        bookMarkedVC.isAllPosts = indexPath.item == 0 ? true : false
        bookMarkedVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(bookMarkedVC, animated: true)
    }
    
    func moveToCOllections() {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        let collectionVC = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SavedCollectionsViewController) as! SavedCollectionsViewController
        collectionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(collectionVC, animated: true)
    }
    
    func openBusinessProductLink(productUrlStr: String,title:String) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        if  let webView =  UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil).instantiateViewController(withIdentifier: "DocumentViewerViewController") as? DocumentViewerViewController{
            webView.isComingfromSetting = true
            if productUrlStr.contains("https://") || productUrlStr.contains("http://") {
                webView.webURL = "\(productUrlStr)"
            }else {
                webView.webURL = "https://\(productUrlStr)"
            }

            webView.titleName = title
            webView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(webView, animated: true)
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    func locationLblTap(index: Int) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        if self.socialViewModel.socialModelArray[index].place == "" {
            return
        }else {
            let postLocationVc = PostsLocationViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostsLocationViewController
            let data = self.socialViewModel.socialModelArray[index]
            postLocationVc.hidesBottomBarWhenPushed = true
            postLocationVc.placeName = data.place
            postLocationVc.placeId = data.placeId ?? ""
            postLocationVc.lattitude = data.lattitude
            postLocationVc.longitude = data.longitude
            self.navigationController?.pushViewController(postLocationVc, animated: true)
        }
        
    }
    

    
    func openProfileView(index: Int, userName: String?) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let data = self.socialViewModel.socialModelArray[index]
        if data.channelName != ""{
            let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
            postedbyController.isChannel = true
            postedbyController.channelName = data.channelName
            postedbyController.hashTagName = data.channelId
            self.navigationController?.pushViewController(postedbyController, animated: true)
        }else {
            let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
            profileVC.isNotFromTabBar = true
            /*
             Bug Name:- Goto any users profile form home Page>> redirecting back to the home page>> the bottom navigation tabs dissappear
             Fix Date:- 10/08/21
             Fixed By:- Jayaram G
             Description of Fix:- hiding tabbar when pushing
             */
            profileVC.hidesBottomBarWhenPushed = true
            if data.userId == Utility.getUserid() {
                profileVC.isSelf = true
            }
            if userName == nil{
                profileVC.memberId = data.userId
            }else{
                profileVC.userNameTag = userName
            }
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        
    }
    
   
}


extension SocialViewController {
    
    
    
    @IBAction func btnSaveToCollection_Tapped(_ sender: UIButton) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let addToCollectionVC : SaveToCollectionViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SaveToCollectionViewController") as! SaveToCollectionViewController
        addToCollectionVC.definesPresentationContext = true
        addToCollectionVC.modalPresentationStyle = .fullScreen
        addToCollectionVC.postId = self.socialViewModel.socialModelArray[sender.tag].postId!
        if self.socialViewModel.socialModelArray[sender.tag].imageUrl!.contains(".mp4"){
            addToCollectionVC.imageUrl = self.socialViewModel.socialModelArray[sender.tag].thumbnailUrl!
        }else {
            addToCollectionVC.imageUrl = self.socialViewModel.socialModelArray[sender.tag].imageUrl!
        }
        addToCollectionVC.modalPresentationStyle = .overCurrentContext
        
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(addToCollectionVC, animated: true, completion: nil)
    }
    
    @IBAction func btnActions_Tapped(_ sender : UIButton){
        
        
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        guard let userId = Utility.getUserid() else {return}
        let data = socialViewModel.socialModelArray[sender.tag]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let postUserId = data.userId!
        if postUserId == userId{
            let edit = UIAlertAction(title: "Edit".localized, style: .default) { (action) in
                self.editPostAction(sender.tag)
            }
            let delete = UIAlertAction(title: "Delete".localized, style: .default) { (action) in
                //                self.deletePostService(sender.tag)
                self.deletePostConfirmationPopup(index: sender.tag)
            }
            alert.addAction(edit)
            alert.addAction(delete)
        }else{
            let report = UIAlertAction(title: "Report Post".localized, style: .default) { (action) in
                self.getReportReasons(postId:data.postId ?? "")
            }
            alert.addAction(report)
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel){ (action) in
            self.startVideoPlayer()
        }
        let sharePostDeepLink = UIAlertAction(title: "Share Post".localized, style: .default) { (action) in
            self.shareThroughDeepLinkButtonTap(index: sender.tag, forPost: true)
        }
        
        let shareProfileDeepLink = UIAlertAction(title: "Share Profile".localized, style: .default) { (action) in
            self.shareThroughDeepLinkButtonTap(index: sender.tag, forPost: false)
        }
        
        /*
         Feat Name:- add download option with watermark
         Feat Date:- 22/04/21
         Feat   By:- Nikunj C
         Description of Feat:- function use to download media
         */
        let downloadPost = UIAlertAction(title: "Download".localized, style: .default) { (action) in
            guard var mediaUrl = data.imageUrl, let name = data.title else{
                return
            }
            if let isDownload = data.allowDownload, isDownload, let type = data.mediaType{
                /*
                 Bug Name:- watermark is not look good
                 Fix Date:- 10/05/21
                 Fixed By:- Nikunj C
                 Description of Fix:- manage width, height and padding
                 */
                let width = Int(data.imageUrlWidth/3)
                let height = Int(Double(width)*0.3)
                if type == 0{
                     mediaUrl = mediaUrl.replacingOccurrences(of: "upload/", with: "upload/w_\(width),h_\(height),g_south_east,c_lpad,l_picoaddaWatermark:imageWatermark.png/")
                    Helper.downloadVideoLinkAndCreateAsset( mediaUrl, fileName: name, isVideo: false, messageTag: "Photo")
                }else{
                     mediaUrl = mediaUrl.replacingOccurrences(of: "upload/", with: "upload/w_\(width),h_\(height),g_south_east,l_picoaddaWatermark:videoWatermark.gif/")
                    guard let mediaURL = URL(string: mediaUrl) else {return}
                    guard let videoEndDetailsUrl = self.imageArrayToVideoURL else {return}
                    let fileURLs = [mediaURL,videoEndDetailsUrl]
                    
                    DPVideoMerger().mergeVideos(withFileURLs: fileURLs) { mergedVideoURL, error in
                        if let videoUrl = mergedVideoURL{
                            print(videoUrl)
                            Helper.downloadVideoLinkAndCreateAsset(videoUrl.absoluteString, fileName: name, isVideo: true, messageTag: "Video")
                        }                        
                    }
                }
            }else{
                Helper.toastView(messsage: "Downloading is disabled for this post".localized + ".", view: self.view)
            }
            
        }
        
        alert.addAction(sharePostDeepLink)
        /* Feature Name : Share Profile remove from home screen
         Feature Date : 12-Apr-2021
         Feature Added By : jayaram G
         Description Of Feature : commented share profile option
         */

//        alert.addAction(shareProfileDeepLink)
        alert.addAction(downloadPost)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func moveToWalletVC(_ sender: UIButton) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        Route.navigateToCoinWallet(navigationController:self.navigationController)
    }
    
    
    func getReportReasons(postId: String){
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        postDetailsViewModel.getReportReasonsService { (success, error) in
            if success{
                let reportView = ReportView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                reportView.tag = 10
                reportView.postId = postId
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
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        Helper.showPI()
        guard let postId = self.socialViewModel.socialModelArray[currentIndex].postId else {
            return
        }
        postDetailsViewModel.postReportReasonService(postId: postId, reasonIndex: index, postIndex: currentIndex) { (success, error) in
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            if success{
                DispatchQueue.main.async{
                    let reportView = appDelegetConstant.window.viewWithTag(10)
                    reportView?.popDownAnimation(animationDone: { (finished) in
                        self.showPopUpForSuccessResponse()
                    })
                }
            } else if let error = error{
                if error.code != 204{
                    DispatchQueue.main.async{
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                    }
                }
                self.startVideoPlayer()
            }
        }
    }
    
    /// To show pop up and start playing video again
    func showPopUpForSuccessResponse(){
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let alert = UIAlertController(title: "Success".localized, message: "Thank you for your feedback".localized + ". " + "The post has been successfully reported".localized + ".".localized, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok".localized, style: UIAlertAction.Style.default) { (action) in
            self.startVideoPlayer()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func deletePostConfirmationPopup(index: Int){
        let alert = UIAlertController(title: nil, message: Strings.deletePostPopUp.localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok.localized, style: .default) { (action) in
            self.deletePostService(index)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// To delete user post
    func deletePostService(_ index : Int){
        let data = socialViewModel.socialModelArray[index]
        guard let postId = data.postId else{return}
        self.postDetailsViewModel.deletePostService(postId: postId) { (success, error) in
            if success{
                self.socialViewModel.socialModelArray.remove(at: index)
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.postUpdate)
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.channelUpdate)
//                self.refresh()
                self.socialCollectionView.reloadData()
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
    }
    
    func editPostAction(_ index : Int){
        
        let data = socialViewModel.socialModelArray[index]
        let createPostVc = CreatePostViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.CreatePost) as CreatePostViewController
        self.navigationController?.isNavigationBarHidden = false
        createPostVc.mediaPath = data.imageUrl!
        if let businessPostTypeId = data.businessProfileObj?.businessPostType{
            createPostVc.postTypeId = businessPostTypeId
        }
        if let businessPostType = data.businessProfileObj?.businessPostTypeName {
            createPostVc.postType = businessPostType
        }
        if let businessLinkObj = data.businessProfileObj?.businessUrl {
            createPostVc.businessLink = businessLinkObj
        }
        
        if let businessPriceObj = data.businessProfileObj?.businessPrice {
            createPostVc.productPrice = businessPriceObj
        }
        
        if let businessButtonTextObj = data.businessProfileObj?.businessButtonText {
            createPostVc.businessButtonText = businessButtonTextObj
        }
        if data.mediaType == 1{
            createPostVc.isForVideo = true
            if let modelData = data.mediaData {
                createPostVc.selectedAudio = Audio(mediaModel: modelData)
            }
        }else{
            createPostVc.isForVideo = false
        }
        createPostVc.isEdit = true
        createPostVc.socialModel = data
        createPostVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(createPostVc, animated:true)
    }
    
    func uploadNewPost(newPostModel: NewPostModel?) {
//                DispatchQueue.main.async {
                    self.tabBarController?.selectedIndex = 0
//                }
        if let newpost = newPostModel {
            DispatchQueue.main.async {
                self.uploadingProgressView.progress = 0.0
                self.uploadingPercentageLabel.text = "0%"
            }
            
            /*
             Bug Name:- post uploaded multiple time
             Fix Date:- 20th June 2021
             Fixed By:- Nikunj C
             Description of Fix:- requestForCreateNewPost call multiple time due to dispatchQue.main so remove it from background thread
             */
            
            if newpost.isVideo {
                DispatchQueue.main.async {
                    self.uploadingStatusLabel.text = "Uploading  Video".localized + " ... "
                }
                self.uploadVideoToCloudinary(newPost:newpost)
            } else {
                DispatchQueue.main.async {
                    self.uploadingStatusLabel.text = "Uploading  Image".localized + " ..."
                }
                self.uploadImageToCloudinary(newPost:newpost)
            }
        }
    }
    
    //method to upload data to cloudinary.
    func uploadImageToCloudinary(newPost:NewPostModel) {
        
        if newPost.isEdit{
            self.newPostedImageView.setImageOn(imageUrl: newPost.mediaPath, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            self.requestForUpdateAPost(post:newPost)
            return
        }
        self.uploadingViewHeightConstraint.constant = 75
        let image = UIImage(contentsOfFile:newPost.mediaPath)
        self.newPostedImageView.image = image
        
        CloudinaryManager.sharedInstance.uploadImage(image: image!, folder: .post) { (progress) in
            DispatchQueue.main.async {
                let uploadedProgress = Float (Float(progress.completedUnitCount) / Float(progress.totalUnitCount))
                let progress = Int(uploadedProgress * 100)
                self.uploadingPercentageLabel.text = "\(progress)%"
                self.uploadingProgressView.setProgress(uploadedProgress, animated: true)
            }
        } complication: { (result, error) in
            //Helper.hideProgressIndicator()
            DispatchQueue.main.async {
                self.uploadingViewHeightConstraint.constant = 0
                self.socialViewModel.offset = -20
                self.homeServiceCall()
                if error != nil {
                    //self.uploadingMainView.isHidden = true
                    
                } else {
                    
                    if let result = result {
                        var updatedPostObj = newPost
                        
                        /*bug Name :- incorrect height/width while upload post
                          Fix Date :- 22/03/2021
                          Fixed By :- Nikunj C
                          Description Of fix :- upload cloudinary height and width*/
                        
                        updatedPostObj.height = result.height!;
                        updatedPostObj.width = result.width!;
                        updatedPostObj.mediaPath = result.url!;
                        updatedPostObj.cloudinaryPublicID = result.publicId!;
                        self.requestForCreateNewPost(newPost:updatedPostObj)
                    }
                }
            }
        }
        
    }
    
    
    //method to upload data to cloudinary.
    func uploadVideoToCloudinary(newPost:NewPostModel) {
        
        if newPost.isEdit{
            let url = newPost.mediaPath
            let endIndex = url.index(url.endIndex, offsetBy: -3)
            var truncated = url.substring(to: endIndex)
            truncated = truncated + "jpg"
            self.newPostedImageView.setImageOn(imageUrl: truncated, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            self.requestForUpdateAPost(post:newPost)
            return
        }
        self.uploadingViewHeightConstraint.constant = 75
        self.newPostedImageView.image = newPost.image
        
        CloudinaryManager.sharedInstance.uploadVideo(video: URL(string: newPost.mediaPath)!) { (progress) in
            DispatchQueue.main.async {
                let uploadedProgress = Float (Float(progress.completedUnitCount) / Float(progress.totalUnitCount))
                let progress = Int(uploadedProgress * 100)
                self.uploadingPercentageLabel.text = "\(progress)%"
                self.uploadingProgressView.setProgress(uploadedProgress, animated:true)
            }
        } onCompletion: { (result, error) in
            //Helper.hideProgressIndicator()
            DispatchQueue.main.async {
                self.uploadingViewHeightConstraint.constant = 0
                if error != nil {
                    
                    //self.uploadingMainView.isHidden = true
                    
                } else {
                    
                    if let result = result {
                        var updatedPostObj = newPost
                        
                        /*bug Name :- incorrect height/width while upload post
                          Fix Date :- 22/03/2021
                          Fixed By :- Nikunj C
                         Description Of fix :- upload cloudinary height and width*/
    
                        updatedPostObj.height = result.height!;
                        updatedPostObj.width = result.width!;
                        updatedPostObj.mediaPath = result.url!;
                        updatedPostObj.cloudinaryPublicID = result.publicId!;
                        self.requestForCreateNewPost(newPost:updatedPostObj)
                    }
                }
            }
        }
    }
    
    func requestForCreateNewPost(newPost:NewPostModel) {
        let socialApi = SocialAPI()
        socialApi.createNewPost(newpostDetails:newPost , complitation: { (isPosted,data) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.refresh()
            }
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.postUpdate)
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.channelUpdate)
        })
    }
    
    func requestForUpdateAPost(post: NewPostModel){
        let socialApi = SocialAPI()
        socialApi.updatePost(newpostDetails: post) { (isUpdates) in
            self.socialViewModel.offset = -20
            self.homeServiceCall()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
            })
        }
    }
    
    /*
     Bug Name:- Story is not being displayed even after we redirect to other tabs. We have to refresh the page to view the story
     Fix Date:- 24th July 2021
     Fixed By:- Nikunj C
     Description of Fix:- after upload story call notification
     */
    
    @objc func changeCell(){
        self.refreshStories()
    }
    
    @objc func refreshStories(){
           DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
               self.socialViewModel.offset = -20
               self.socialViewModel.myStoryOffset = -20
               self.socialViewModel.otherStoryOffset = -20
               //            self.socialViewModel.socialModelArray = []
               
               self.getMyStoryService()
               self.getOtherStoryService()
               self.getUserProfile()
           }
       }
       
       
       @objc func updateMystories(notification: NSNotification) {
           if let updatedStories = notification.object as? userStory {
               //            self.myStories = updatedStories
               let model = self.socialViewModel
               model.myStories = updatedStories
               DispatchQueue.main.async {
                   self.socialCollectionView.reloadData()
               }
               //            self.storyTableView.reloadData()
           }
       }
    
    @objc func refresh(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                self.socialViewModel.offset = -20
                self.homeServiceCall()
        }
    }
    
    
}

//MARK:- Search view controller delegate
extension SocialViewController: SearchViewControllerDelegate{
    
    func didFollowOrUnfollowUser() {
        self.socialViewModel.offset = -20
        self.homeServiceCall()
        self.followFollowingServiceCall()
    }
}


//MARK:- Comment View Controller delegate
extension SocialViewController: CommentsViewControllerDelegate{
    func commentCount(count: Int) {
        self.refresh()
    }
}

//MARK:- Social Stories Collection View cell Delegate
extension SocialViewController: SocialStoriesCollectionViewCellDelegate{
    func cellDidSelect(index: IndexPath) {
        switch index.section {
        case 0:
            if(self.socialViewModel.myStories.userStories.count == 0) {
                //there is no stories avialble.
                //so allow to add new story.
                self.openCamera()
            } else {
                self.openMyStories()
            }
            break
        case 1:
            openOthersRecentStories(openAtIndex:index.row)
            break
        default:
            openOthersVieWedStories(openAtIndex:index.row)
            break
        }
    }
    
    func openStoryCamera(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Add to Your Story".localized, style: .default) { (action) in
            DispatchQueue.main.async {
                self.openCamera()
            }
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancel)
        DispatchQueue.main.async {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    
    func openCamera() {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        Route.navigateToCamera(navigationController:self.navigationController, isPresent:true,isForStory : true,color : UIColor.white)
    }
    
    func openMyStories() {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        //open stories.
        //        openStoriesScreenWithStories(stories:[self.socialViewModel.myStories],isMystory:true, openAtIndex:0)
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        guard let myStoriesVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.StoryListViewController) as? StoryListViewController else {return}
        myStoriesVC.myStories = self.socialViewModel.myStories
        self.navigationController?.pushViewController(myStoriesVC, animated: true)
        
    }
    
    func openOthersRecentStories(openAtIndex:Int) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        //open stories.
        openStoriesScreenWithStories(stories:self.socialViewModel.recentStories,isMystory:false, openAtIndex:openAtIndex)
    }
    
    func openOthersVieWedStories(openAtIndex:Int) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        //open stories.
        openStoriesScreenWithStories(stories:self.socialViewModel.viewedStories,isMystory:false, openAtIndex:openAtIndex)
    }
    
    func openStoriesScreenWithStories(stories:[userStory],isMystory:Bool,openAtIndex:Int) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let viewStoryVc = ViewStoryViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Main) as ViewStoryViewController
        viewStoryVc.allStories = stories
        viewStoryVc.jumpToIndex = openAtIndex
        viewStoryVc.isFromSocialView = true
        viewStoryVc.isMyStory = isMystory
        viewStoryVc.modalPresentationStyle = .overFullScreen
        self.present(viewStoryVc, animated: true, completion:nil)
    }
    
    func getUserProfile(){
        let profileViewModel = ProfileViewModel()
        profileViewModel.isSelf = true
        let strUrl: String = AppConstants.userProfile
        profileViewModel.userDetailsService(strUrl: strUrl, params: [:]) { (success, error, canServiceCall) in
            if success{
                
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
        }
    }
}

extension SocialViewController: ReportViewDelegate{
    
    func reportSelectedAtIndex(index: Int) {
        self.postReportReason(index: index)
    }
    
    func onDismissView(){
        //        self.startVideoPlayer()
    }
}


extension SocialViewController: SocialInstaDetailsCollectionViewCellDelegate{
    /*
     Bug Name:- Add readmore/readless
     Fix Date:- 22/06/21
     Fixed By:- Jayaram G
     Description of Fix:- reloading collectionview
     */
    func forYouviewmoreTapped(isViewed: Bool, index: Int) {
        self.socialViewModel.socialModelArray[index].isExpand = isViewed
        self.socialCollectionView.reloadData()
    }
    
    func navigateToConfirmSubscriptionVc(modelData: SocialModel) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let storyBoardObj = UIStoryboard.init(name: "subscribe", bundle: nil)
        if #available(iOS 13.0, *) {
            guard let subscribeConfirmVc = storyBoardObj.instantiateViewController(identifier: "SubscribeConfirmationViewController") as? SubscribeConfirmationViewController else {return}
            subscribeConfirmVc.isFromProfilePage = false
            subscribeConfirmVc.socialModelData = modelData
            subscribeConfirmVc.delegate = self
            subscribeConfirmVc.definesPresentationContext = true
            subscribeConfirmVc.modalPresentationStyle = .overCurrentContext
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
    }
    func sendTipAction(index: Int) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        if self.socialViewModel.socialModelArray[index].userId == Utility.getUserid() {
            return
        }
              let sendTipStoryBoard = UIStoryboard.init(name: "SendTip", bundle: nil)
        if #available(iOS 13.0, *) {
            guard let sendTipVC = sendTipStoryBoard.instantiateViewController(withIdentifier: "SendTipCoinsViewController") as? SendTipCoinsViewController else {return}
            sendTipVC.definesPresentationContext = true
            sendTipVC.modalPresentationStyle = .overCurrentContext
            sendTipVC.delegate = self
            sendTipVC.hidesBottomBarWhenPushed = true
            sendTipVC.socialModelData = self.socialViewModel.socialModelArray[index]
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                topRootViewController?.present(sendTipVC, animated: true, completion: nil)
            }
            //            self.present(unLockConfirmVc,animated: true)
        } else {
            // Fallback on earlier versions
        }

    }
    func openBookMark(index: Int) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        guard let cell = socialCollectionView.cellForItem(at: IndexPath(item: 0, section:  index + 1)) as? SocialInstaCollectionViewCell else {return}
        UIView.animate(withDuration: 0.3, animations: {
            cell.saveToCollectionViewHeightConstraint.constant = 50
        }) { (isFinishedSuccessfully) in
            if isFinishedSuccessfully{
                /*
                 Bug Name:- that option to view saved collection disappears too fast so a user cannot really have. Enough time to clock and make a one because it disappeared too soon when a user tries to bookmark
                 Fix Date:- 15th Sep 2021
                 Fixed By:- Nikunj C
                 Description of Fix:- increate time to dismiss
                 */
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: {
                    UIView.animate(withDuration: 0.3, animations: {
                    cell.saveToCollectionViewHeightConstraint.constant = 0
                    }){ (isFinishedSuccessfully) in
                    }
                })
            }
        }
    }
    
   
 
    
    func lblCommentTap(userId: String) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        profileVC.memberId = userId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    func commentButtonTap(index: Int) {
        /* Bug Name :- Allow comment not working issue
                          Fix Date :- 23/03/2021
                          Fixed By :- Vishal D
                          Description Of Fix :- Create Post: On editing the created Post comment to not allow and opening the same page again it is not being saved */
        
        let data = self.socialViewModel.socialModelArray[index]
        if !(data.allowComment ?? false) {
            /* Bug Name :- Please check space of the toast view on top
             Fix Date :- 16/04/2021
             Fixed By :- Jayram G
             Description Of Fix :- changed toast top view with navigation controller
             */
            
            if self.navigationController != nil {
                Helper.toastView(messsage: "Comments are disabled for this post".localized, view: (self.navigationController?.view)!)
            }
            
            return
        }
        
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let commentVC = CommentsViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Main) as CommentsViewController
        guard let userID = Utility.getUserid() else { return }
        
        commentVC.postId = data.postId
        commentVC.userId = userID
        commentVC.hidesBottomBarWhenPushed = true
        commentVC.delegate = self
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func shareInChatButtonTap(index: Int) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        guard let sharePostVC = storyboard.instantiateViewController(withIdentifier: Controlleridentifier.SharePostViewController) as? SharePostViewController else {return}
        sharePostVC.sharePostViewModel.followersFolloweeModelArray = socialViewModel.followersFolloweeModelArray
        let data = socialViewModel.socialModelArray[index]
        sharePostVC.postDetails = data
        sharePostVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        tabBarController?.present(sharePostVC, animated: true, completion: nil)
    }
    
    func shareThroughDeepLinkButtonTap(index: Int,forPost:Bool) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        if index >= self.socialViewModel.socialModelArray.count{
            return
        }
        var message = ""
        if forPost {
            message = "Hey".localized + "! " + "Check out this post on".localized + " \(AppConstants.AppName) " + "app".localized
        }else{
            message = "Hey".localized + "! " + "Check out this profile on".localized + " \(AppConstants.AppName) " + "app".localized
        }
        let data = socialViewModel.socialModelArray[index]
        /*
         Feat name:- social sharing for post
         Feat Date:- 15th Sep 2021
         Feat By:- Nikunj C
         Description of feat:- add social share option
         */
        let shareMediaVC = ShareToSocialViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.ShareToSocial) as ShareToSocialViewController
        shareMediaVC.hidesBottomBarWhenPushed = true
        shareMediaVC.postData = data
        shareMediaVC.imageArrayToVideoURL = self.imageArrayToVideoURL
        shareMediaVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        tabBarController?.present(shareMediaVC, animated: true)
        
//        Helper.createDeepLink(forPost: forPost, postModel: data) { (success, url) in
//            if success{
//                let items: [Any] = [message, url as Any]
//                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//                ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
//                }
//                self.present(ac, animated: true)
//                print("Success")
//            }else{
//                print("Failed")
//            }
//            Helper.hidePI()
//        }
    }
    
    
    func likeButtonTap(index: Int, isSelected: Bool, socialModel: SocialModel,FromDoubleTap: Bool) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        self.socialViewModel.socialModelArray[index] = socialModel
        self.socialViewModel.likeAndUnlikeService(index: index, isSelected: isSelected, complitation: {(success, error) in
            if success{
                
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.likeUpdate)
                print("like updated successfully")
                if FromDoubleTap {
                    self.socialViewModel.socialModelArray[index].liked = 1
                    self.socialViewModel.socialModelArray[index].likesCount += 1
                    self.socialCollectionView.reloadData()
                }else {
                    if isSelected {
                        self.socialViewModel.socialModelArray[index].liked = 0
                        self.socialCollectionView.reloadData()
                    }else{
                        self.socialViewModel.socialModelArray[index].liked = 1
                        self.socialCollectionView.reloadData()
                    }
                }
                //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshProfileData"), object: nil)
            }else{
                //                Helper.showAlertViewOnWindow("Message".localized, message: (error?.localizedDescription)!)
                //                complitation(false,error as? CustomErrorStruct)
            }
        })
    }
    
    func hastagOrProfileSelected(byTag: String) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        if byTag.hasPrefix("@"){
            let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
            profileVC.isNotFromTabBar = true
            /*
             Bug Name:- User not found when click on tagged name from home page in picoadda
             Fix Date:- 1st Nov 2021
             Fixed By:- Nikunj C
             Description of Fix:- no need of @ for call api so need to remove it
             */
            let tag = byTag.replace(target: "@", withString: "")
            profileVC.userNameTag = tag
            profileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileVC, animated: true)
        }else{
            let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
            postedbyController.hashTagName = byTag
            postedbyController.isHashTag = true
            self.navigationController?.pushViewController(postedbyController, animated: true)
        }
    }
    
   
    func viewCountButtonTap(index: Int){
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let followVC = FollowViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as FollowViewController
        let data = self.socialViewModel.socialModelArray[index]
        followVC.followListType = .viewListView
        followVC.postOrUserId = data.postId
        followVC.viewTitle = "Viewers".localized
        self.navigationController?.pushViewController(followVC, animated: true)
    }
    
    func likeCountButtonTap(index: Int){
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        let followVC = FollowViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as FollowViewController
        let data = self.socialViewModel.socialModelArray[index]
        followVC.followListType = .likeListView
        followVC.postOrUserId = data.postId
        followVC.viewTitle = "Likes".localized
        self.navigationController?.pushViewController(followVC, animated: true)
    }
}

extension SocialViewController: SendTipCoinsViewControllerDelegate,InSufficientCoinsViewControllerDelegate,TipSentVCDelegate {
    
    func updateWallet() {
        self.updateWalletData()
    }
    
    func showSendTipSuccessScreen(userName: String) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        if #available(iOS 13.0, *) {
            guard let successVc = UIStoryboard.init(name: "SendTip", bundle: nil).instantiateViewController(identifier: "TipSentSuccessfullyViewController") as? TipSentSuccessfullyViewController else {return}
            successVc.delegate = self
            successVc.isFromSendTip = true
            successVc.userName = userName
            successVc.definesPresentationContext = true
            successVc.modalPresentationStyle = .overCurrentContext
            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topRootViewController?.presentedViewController) != nil) {
                topRootViewController = topRootViewController?.presentedViewController
            }
            DispatchQueue.main.async {
                topRootViewController?.present(successVc, animated: true, completion: nil)
            }
            print("Successfully updated")
            self.refresh()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func moveToInSufficientVc() {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        if #available(iOS 13.0, *) {
            guard let inSufficientvc = UIStoryboard.init(name: "SendTip", bundle: nil).instantiateViewController(identifier: String(describing: InSufficientCoinsViewController.self)) as? InSufficientCoinsViewController  else {return}
            inSufficientvc.hidesBottomBarWhenPushed = true
            inSufficientvc.delegate = self
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
    
    func moveToCoinWalletVc() {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        Route.navigateToCoinWallet(navigationController:self.navigationController)
    }
    
    func dismissToNavigateWallet() {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        Route.navigateToCoinWallet(navigationController:self.navigationController)
    }
}

extension SocialViewController: SubscribeConfirmationVCDelegate {
    func navigateToSubcribeSuccess(fullName :String, userId: String) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        /*
         Bug Name :- Coin balance not updating after subscription
         Fix Date :- 31/05/2021
         Fixed By :- Jayaram G
         Description Of Fix :- refreshing coin balance
         */
        ApiHelper.shared.getWallet(userId: Utility.getUserid() ?? "") { _ in
            self.updateWalletData()
        }
        
            if #available(iOS 13.0, *) {
            let storyBoardObj = UIStoryboard.init(name: "SendTip", bundle: nil)
            guard let successVc = storyBoardObj.instantiateViewController(identifier: "TipSentSuccessfullyViewController") as? TipSentSuccessfullyViewController else {return}
            successVc.isFromSubscribe = true
            successVc.fullName = fullName
            successVc.modalPresentationStyle = .fullScreen
            self.present(successVc,animated: true)
            print("Successfully updated")
            
        } else {
            // Fallback on earlier versions
        }

    }
    func navigateToUnSubcribeSuccess(model: UserProfileModel) {
        
    }
    
    func inSufficientBalance(userName: String) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
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

}

extension SocialViewController:PopularCollectionViewCellDelegate{
    func followingButtonAction(cell: PopularUserCell) {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
        guard let indexPath = self.popularUserCollectionView.indexPath(for: cell) else{ return }
        let modelArray = self.socialViewModel.popularUserArray
        if modelArray.count > indexPath.item{
            let modelData = modelArray[indexPath.item]
            updatePeopleModelArray(modelData: modelData, index: indexPath)
            
        }
    }
    
        ///To update people table view according to selected or unselected follow button and put to server
        func updatePeopleModelArray(modelData: PopularUserModel, index: IndexPath){
            if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
                Route.navigateToLoginVC(vc: self)
                return
            }
            if modelData.followStatus == 0{
                modelData.followStatus = 1
                self.socialViewModel.FollowPeopleService(isFollow: true, peopleId: modelData.userId, privicy: 0)
            }else{
                modelData.followStatus = 0
                self.socialViewModel.FollowPeopleService(isFollow: false, peopleId: modelData.userId, privicy: 0)
            }
            self.socialViewModel.popularUserArray[index.item] = modelData
            self.popularUserCollectionView.reloadItems(at: [index])
            self.refresh()
        }
}
    
extension SocialViewController:UnLockPostConfirmationViewControllerDelegate{
    func showSuccessScreen() {
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            Route.navigateToLoginVC(vc: self)
            return
        }
                        if #available(iOS 13.0, *) {
            let storyBoardObj = UIStoryboard.init(name: "SendTip", bundle: nil)
            guard let successVc = storyBoardObj.instantiateViewController(identifier: "TipSentSuccessfullyViewController") as? TipSentSuccessfullyViewController else {return}
            successVc.isFromPurchase = true
            successVc.delegate = self
            successVc.modalPresentationStyle = .fullScreen
            self.present(successVc,animated: true)
            print("Successfully updated")
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func popAfterSuccess() {
        
    }
    
    func updateData(index: Int) {
        self.updateWalletData()
        self.socialViewModel.socialModelArray[index].isPurchased = 1
        self.socialCollectionView.reloadData()
    }
}


extension Double {
    
    func formatUsingAbbrevation () -> String {
        let numFormatter = NumberFormatter()

        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K"),
                                           (100_000_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 1_000_000_000.0, "B")]
                                           // you can add more !

        let startValue = Double (abs(self))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()

        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        if self < 9999 || self == 9999{
            return "\(self)"
        }else{
            return numFormatter.string(from: NSNumber (value:value))!
        }
        
    }
}
