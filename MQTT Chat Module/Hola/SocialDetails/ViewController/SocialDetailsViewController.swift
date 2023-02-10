//
//  SocialDetailsViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 08/02/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import DGElasticPullToRefresh

import QuiltView
import IJKMediaFramework
import AVFoundation
import AVKit

 protocol SocialDetailsViewControllerDelegate: AnyObject {
    
    func likeUnlikePost(index: Int, isLike:Bool)
    
}

class SocialDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var socialCollectionView: UICollectionView!
    @IBOutlet weak var uploadingStatusLabel: UILabel!
    @IBOutlet weak var uploadingPercentageLabel: UILabel!
    @IBOutlet weak var newPostedImageView: UIImageView!
    @IBOutlet weak var uploadingProgressView: UIProgressView!
    @IBOutlet weak var uploadingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noPostView: UIView!
    @IBOutlet weak var noPostlbl: UILabel!
    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var cameraButtonOulet: UIButton!
    @IBOutlet weak var balanceLabelOutlet: UILabel!
    @IBOutlet weak var userProfileView: UIView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var appNameLabel: UILabel!
    
    var imageArrayToVideoURL = URL(string: "www.google.in")
    var userDetailsImage = UIImage()
    var isLoadedFirst: Bool = true
    var postDetailsViewModel = PostDetailsViewModel()
    var collection : SavedCollectionModel!
    var scrollToSelectedIndex: Int = -1
    var currentIndex: Int = -1
    var player:IJKFFMoviePlayerController!
    /* bug Name :- No audio playing for videos
     Fix Date :- 10/03/2021
     Fixed By :- Jayaram G
     Description Of fix :- Setting mute status false initially
     */
    var isMuted: Bool = false
    var isSelf:Bool?
    var likeUpdate:Bool = false
    var isPresented: Bool = false
    var isBookMarkedDone: Bool = false
    var savedCollectionObj:SavedCollectionModel?
    var needToCallApi:Bool = false
    var postId:String?
    var isFromTrendingPage:Bool = false
    var hashTag = ""
    var isFromSavedPosts:Bool = false
    let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
    var isShowOptions:Bool = false
    var isComingFromChat:Bool = false
    var delegate: SocialDetailsViewControllerDelegate?
    
    
    /// Note to run a time to invoke the prepare to play for Player
    var preparetoPlayTimer: Timer?
    
    /// To check wheather screen is still visible or has tab been swiched
    var isViewVisible = false
    /// Store the index path of current media cell, to compare if same will reload again
    var currentPlayingIndexPath : IndexPath?
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
    var postedByViewModel = PostedByViewModel()
    
    var canServiceCall: Bool = true
    /*
     Refactor Name:- Pagination not working for hashtagposts
     Refactor Date:- 11/05/21
     Refactored By:- Jayram G
     Description of Refactor:- Added required variable
     */
    var canServiceCallForHashTag: Bool = true
    
    let bottomEdge: CGFloat = 20.0
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewUI()
        if isFromTrendingPage {
            self.getHashTagPostsApiCall()
        }else{
            
            /*Bug Name :- clicked on last post but opens first always
             Fix Date :- 30/06/2021
             Fixed By :- Jayaram G
             Description Of fix :- Scrolling to selected post index and don't scroll if index is 0
             */
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                if self.scrollToSelectedIndex != -1 {
                    self.socialCollectionView.scrollToItem(at: IndexPath(item: 0, section: self.scrollToSelectedIndex + 1), at: .bottom, animated: false)
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.showViewCollections), name: NSNotification.Name(rawValue: "showViewCollections"), object: nil)
        
        /*bug Name :- back button in social details not work while open post through deeplinks
         Fix Date :- 22/03/2021
         Fixed By :- Nikunj C
         Description Of fix :- when post open through deeplink ispresent value is true and directly dismis controller on back action. */
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_arrow"), style: .plain, target: self, action: #selector(self.backButtonAction(_:)))
        
        if isFromSavedPosts {
            self.navigationItem.title = self.collection.collectionName
            self.setNoPostView()
            
        }else{
            let logo = UIImage(named: "StarChat")
            let imageView = UIImageView(image:logo)
            self.navigationItem.titleView = imageView
        }
        if isShowOptions {
            let moreBtn = UIBarButtonItem.init(image: #imageLiteral(resourceName: "storyMore"), style: .plain, target: self, action: #selector(openBookMarkOptions))
            if #available(iOS 13.0, *) {
                moreBtn.tintColor = .label
            } else {
                moreBtn.tintColor = .black
                // Fallback on earlier versions
            }
            self.navigationItem.rightBarButtonItem = moreBtn
        }
        
        let isNetwork = (UIApplication.shared.delegate as? AppDelegate)?.isNetworkThere
        if isNetwork == false{
            Helper.showAlertViewOnWindow("Oops".localized, message: "Check Internet Connection".localized)
        }else{
            if needToCallApi {
                self.getPostDetails()
            }
        }
        //        self.addObserVerForCamera()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        isSelf = true
        isViewVisible = true
        let isNetwork = (UIApplication.shared.delegate as? AppDelegate)?.isNetworkThere
        if isNetwork == true{
        }
        self.playVideoPlayerFromStoppedState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewVisible = true
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopVideoPlayer()
        isViewVisible = false
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showViewCollections), name: NSNotification.Name(rawValue: "showViewCollections"), object: nil)
        isSelf = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*bug Name :- back button in social details not work while open post through deeplinks
     Fix Date :- 22/03/2021
     Fixed By :- Nikunj C
     Description Of fix :- add dismiss action */
    
    @objc func backButtonAction(_ sender: Any) {
        if self.isPresented{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func openBookMarkOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let alertDelete = UIAlertController(title: "Delete Collection".localized + "?", message: "When you delete this collection".localized + ", " + "the photos and videos will still be saved".localized + ".", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Edit Collection".localized, style: .default , handler:{ (UIAlertAction)in
            let editCollectionVC : AddNewCollectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCollectionViewController") as! AddNewCollectionViewController
            editCollectionVC.isEdit = true
            editCollectionVC.collection = self.collection
            self.navigationController?.pushViewController(editCollectionVC, animated: true)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Add to Collection".localized, style: .default , handler:{ (UIAlertAction)in
            let bookMarkedPostsVC : BookMarkedPostsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookMarkedPostsViewController") as! BookMarkedPostsViewController
            bookMarkedPostsVC.strCollectionName = self.collection.collectionName
            bookMarkedPostsVC.toChangeItemsInCollection = true
            bookMarkedPostsVC.collection = self.collection
            self.navigationController?.pushViewController(bookMarkedPostsVC, animated: true)
            
        }))
        //            alert.addAction(UIAlertAction(title: "Delete Collection", style: .destructive , handler:{ (UIAlertAction)in
        //                self.present(alertDelete, animated: true, completion: nil)
        //            }))
        
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        alertDelete.addAction(UIAlertAction(title: "Delete".localized, style: .destructive , handler:{ (UIAlertAction)in
            if self.collection.id != nil {
                self.model.deleteCollection(self.collection.id)
                self.model.didUpdateDict = { response in
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.bookMarkUpdate)
                    self.navigationController?.popViewController(animated: true)
                }
                self.model.didError = { error in
                }
            }
        }))
        alertDelete.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
    }
    
    /// To load view with initial setup
    func loadViewUI(){
        
        self.noPostlbl.text = "No posts to show".localized
        addIJKMPMoviePlayerNotificationCenterObservers()
        self.userProfileImageView.makeCornerRadious(readious: self.userProfileImageView.frame.size.width/2)
        self.socialCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: bottomEdge, right: 0)
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP])

        // Initialize socialCollectionView
        //        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        //        socialCollectionView.tintColor = UIColor.white
        //        socialCollectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
        //            // Add your logic here
        //            self?.socialViewModel.offset = -20
        //            self?.homeServiceCall()
        //            }, loadingView: loadingView)
        //        socialCollectionView.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        //        socialCollectionView.dg_setPullToRefreshBackgroundColor(socialCollectionView.backgroundColor!)
        
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
    
    
    /// To setup no post view
    private func setNoPostView(){
        if self.socialViewModel.socialModelArray.count == 0 || self.socialViewModel.socialModelArray == nil{
            self.noPostView.isHidden = false
        }else{
            self.noPostView.isHidden = true
        }
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
    
    @objc func showViewCollections(_ notification: NSNotification){
        if let collectionModel = notification.object as? SavedCollectionModel {
            self.savedCollectionObj = collectionModel
        }
        self.isBookMarkedDone = true
        self.socialCollectionView.reloadData()
    }
    
    //MARK:- Button Action
    @IBAction func searchButtonAction(_ sender: Any) {
        self.presentSearchViewController()
    }
    
    @IBAction func findFriendAction(_ sender: Any) {
        //        self.presentSearchViewController()
        
        let addContactsVC = AddContactsViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Contacts) as AddContactsViewController
        addContactsVC.isFromNewFriendsVc = true
        addContactsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addContactsVC, animated: true)
    }
    
    @IBAction func profileAction(_ sender: UIButton) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        profileVC.isSelf = true
        profileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func activityAction(_ sender: Any) {
        let activityVc = ActivityViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Activity) as ActivityViewController
        activityVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(activityVc, animated: true)
    }
    
    /// To present search view controller
    private func presentSearchViewController(){
        if let trendingVC : TrendingViewController = ((self.tabBarController?.viewControllers![3] as? SwipeNavigationController)?.viewControllers.first) as? TrendingViewController{
            trendingVC.showSearch = true
        }
        self.tabBarController?.selectedIndex = 1
        
        //        guard let searchViewController = storyboard?.instantiateViewController(withIdentifier: controllerIdentifierName.searchViewController) as? SearchViewController else {return}
        //        searchViewController.delegate = self
        //        let navController = UINavigationController.init(rootViewController: searchViewController)
        //        self.present(navController, animated: true, completion: nil)
    }
    
    
    @IBAction func muteAndUnmuteAction(_ sender: Any) {
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
        self.presentCameraVC()
    }
    
    
    //MARK:- Service call
    
    func getPostDetails(){
        guard let postID = self.postId else {return}
        socialViewModel.getPostDetailsService(postId: postID) { (success, error) in
            if success{
                self.socialCollectionView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
        }
    }
    /*
     Refactor Name:- required refactor
     Refactor Date:- 11/05/21
     Refactored By:- Jayram G
     Description of Refactor:- separated hashTag posts api call
     */
    func getHashTagPostsApiCall() {
        self.postedByViewModel.getPostedByHashTagData(isHashTag: true, hashTag: self.hashTag, isChannel: false) { (success, erro, canServiceCall) in
            if success {
                self.socialViewModel.socialModelArray = self.postedByViewModel.postedByArray
                DispatchQueue.main.async {
                    self.setNoPostView()
                    /*
                     Bug Name:- Not redirecting to particular post from trending
                     Fix Date:- 27/05/21
                     Fixed By:- Jayaram G
                     Description of Fix:- Scrolling to particular post
                     */
                    self.socialCollectionView.reloadData()
                    self.socialCollectionView.scrollToItem(at: IndexPath(item: 0, section: self.scrollToSelectedIndex + 1), at: .bottom, animated: false)
                    
                }
            }
            self.canServiceCallForHashTag = canServiceCall
        }
    }
    
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
                    self.socialCollectionView.reloadData()
                }
            }
        }
    }
    
    func getMyStoryService() {
        let strUrl = AppConstants.myStory
        socialViewModel.storyServiceCall(strUrl: strUrl, storyType: .myStory) { [weak self] (success, error) in
            guard let self = self else { return }
            if self.socialViewModel.socialModelArray.count > 0 {
                //                let index = IndexPath(item: 0, section: 0)
                // self?.socialCollectionView.reloadItems(at: [index])
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
                let index = IndexPath(item: 0, section: 0)
                //     self?.socialCollectionView.reloadItems(at: [index])
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
extension SocialDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout/* UICollectionViewDataSourcePrefetching*/{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.socialViewModel.socialModelArray.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }else{
            return  2
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section != 0  {

            if self.socialViewModel.socialModelArray.count > indexPath.section {
                let indexPassed: Bool = indexPath.section >= self.socialViewModel.socialModelArray.count - 10
                /*
                 Fix Name:- Pagination not working for hashtagposts
                 Fix Date:- 11/05/21
                 Fixed By:- Jayram G
                 Description of Fix:- added condition to call hashTag posts api call
                 */
                if isFromTrendingPage {
                    if canServiceCallForHashTag && indexPassed{
                        canServiceCallForHashTag = false
                        self.getHashTagPostsApiCall()
                    }
                }else {
                    if canServiceCall && indexPassed{
                        canServiceCall = false
                        //                        homeServiceCall()
                    }
                }
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            return UICollectionViewCell()
        }else{
            if indexPath.row == 1 {
                guard let detailsCell = collectionView.dequeueReusableCell(withReuseIdentifier: String.init(describing: SocialSubDetailsCollectionViewCell.self), for: indexPath) as? SocialSubDetailsCollectionViewCell else{fatalError()}
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
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SocialDetailsInstaCollectionViewCell.self), for: indexPath) as? SocialDetailsInstaCollectionViewCell else{fatalError()}
                
                if self.socialViewModel.socialModelArray.count > indexPath.section-1 {
                    let data = self.socialViewModel.socialModelArray[indexPath.section-1]
                    cell.setSocialCellData(socialModel: data)
                    if isBookMarkedDone {
                        self.isBookMarkedDone = false
                        guard let savedCollectionData = savedCollectionObj else {return UICollectionViewCell()}
                        //   cell.showViewBookMark(socialModel: data, collectionModel: savedCollectionData)
                    }
                    
                    cell.index = indexPath.section - 1
                    if cell.btnOptions != nil {
                        cell.btnOptions.tag = indexPath.section - 1
                        
                    }
                    cell.btnSaveToCollection.tag = indexPath.section - 1
                    cell.delegate = self
                    let postUserId = data.userId
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
                    
                    if  self.scrollToSelectedIndex >= 0,indexPath.section == self.scrollToSelectedIndex + 1{
                        cell.muteUnmuteButtonOutlet.setImage(image, for: .normal)
                        cell.playPauseVideoImageView.isHidden = true
                        self.playVideoOnTheCell(cell: cell, indexPath: indexPath)
                    }
                    self.view.layoutIfNeeded()
                    
                }
                return cell
            }
        }
        
    }


   func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if let visibleIndex = CurrentVisibleCellInCenter().0 ,let visibleCell = CurrentVisibleCellInCenter().1{
        let image = self.isMuted ? UIImage(named: "home_mute") : UIImage(named: "unmute")
        visibleCell.muteUnmuteButtonOutlet.setImage(image, for: .normal)
        visibleCell.playPauseVideoImageView.isHidden = true
        self.playVideoOnTheCell(cell: visibleCell, indexPath: visibleIndex)
    }
}

/// Get the visible indexes of the collection view
/// - Parameter inCollectionView: target collectionview object
/// - Returns: return the indexPath of fully viisble cell
func CurrentVisibleCellInCenter() -> (IndexPath?,  SocialDetailsInstaCollectionViewCell?){
    var visibleRect    = CGRect()
    visibleRect.origin = socialCollectionView.contentOffset
    visibleRect.size   = socialCollectionView.bounds.size
    let visiblePoint   = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

    guard let visibleIndexPath: IndexPath = socialCollectionView.indexPathForItem(at: visiblePoint),visibleIndexPath.row == 0,let visibleCell = self.socialCollectionView.cellForItem(at: visibleIndexPath) as? SocialDetailsInstaCollectionViewCell else { return (nil,nil) }
     return (visibleIndexPath,visibleCell)
}



/// To prepare and play video when cell is visiable
///
/// - Parameters:
///   - cell: visiable cell
///   - indexPath: index path of visiable cell
private func playVideoOnTheCell(cell : SocialDetailsInstaCollectionViewCell, indexPath : IndexPath,checkCurrentPlayingCondition:Bool = true){
    
            self.preparetoPlayTimer?.invalidate()
            self.preparetoPlayTimer = nil
    
    if let currentIndexPath = currentPlayingIndexPath, currentIndexPath == indexPath,checkCurrentPlayingCondition{
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

fileprivate func play(_ url: URL?, cell: SocialDetailsInstaCollectionViewCell) {
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
    if indexPath.section == 0 {
        let width = self.view.frame.size.width
        return CGSize(width: 0.0, height: 0.0)
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


func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return .zero
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt ssection: Int) -> CGFloat {
    return 0
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
}



@IBAction func btnSaveToCollection_Tapped(_ sender: UIButton) {
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
    
    //        let addToCollectionVC : SaveToCollectionViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SaveToCollectionViewController") as! SaveToCollectionViewController
    //        addToCollectionVC.definesPresentationContext = true
    //        addToCollectionVC.modalPresentationStyle = .fullScreen
    //        addToCollectionVC.postId = self.socialViewModel.socialModelArray[sender.tag].postId!
    //        addToCollectionVC.imageUrl = self.socialViewModel.socialModelArray[sender.tag].imageUrl!
    //        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(addToCollectionVC, animated: true, completion: nil)
    //
    //        return
    
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
            self.getReportReasons()
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
                guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let videoEndDetailsUrl = documentsDirectoryURL.appendingPathComponent("userProfile.m4v")
                let fileURLs = [mediaURL,videoEndDetailsUrl]
                
                DPVideoMerger().mergeVideos(withFileURLs: fileURLs) { mergedVideoURL, error in
                        if let videoUrl = mergedVideoURL{
                            print(videoUrl)
                            Helper.downloadVideoLinkAndCreateAsset(videoUrl.absoluteString, fileName: name, isVideo: true, messageTag: "Video")
                        }
                        
                    
                }
            }
        }else{
            Helper.toastView(messsage: "Downloading is disabled for this post.", view: self.view)
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
    Route.navigateToCoinWallet(navigationController:self.navigationController)
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
    let alert = UIAlertController(title: "Success".localized, message: "Thank you for your feedback".localized + ". " + "The post has been successfully reported".localized + ".", preferredStyle: UIAlertController.Style.alert)
    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (action) in
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
            //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
            //                self.refresh()
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.postUpdate)
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
    //        shareVc.newPostDetails?.channel = data.
    
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


}


extension SocialDetailsViewController: SocialDetailsInstaCollectionViewCellDelegate{
    
    func followUserTapped(index: Int, isSelected: Bool) {
        if  self.socialViewModel.socialModelArray.count > index{
            ContactAPI.followAndUnfollowService(with: isSelected, followingId: self.socialViewModel.socialModelArray[index].userId ?? "", privicy: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            for (indexInt,postData) in self.socialViewModel.socialModelArray.enumerated() {
                if postData.userId ==  self.socialViewModel.socialModelArray[index].userId{
                    self.socialViewModel.socialModelArray[indexInt].isFollowing = isSelected
                    DispatchQueue.main.async {
                        self.socialCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func zooming(started: Bool) {
        self.socialCollectionView.isScrollEnabled = !started
    }
    
    func paidPostTap(modelData: SocialModel,index: Int) {
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
                unLockConfirmVc.index = index
                unLockConfirmVc.modalPresentationStyle = .overCurrentContext
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
    
    func navigateToConfirmSubscriptionVc(modelData: SocialModel) {
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
    
    
    
    func viewCollection() {
        let bookMarkedVC : BookMarkedPostsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookMarkedPostsViewController") as! BookMarkedPostsViewController
        bookMarkedVC.collection = self.savedCollectionObj
        bookMarkedVC.isCollectionDetails =  true
        //        bookMarkedVC.isAllPosts = indexPath.item == 0 ? true : false
        bookMarkedVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(bookMarkedVC, animated: true)
    }
    
    func moveToCOllections() {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        let collectionVC = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SavedCollectionsViewController) as! SavedCollectionsViewController
        collectionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(collectionVC, animated: true)
    }
    
    func openBusinessProductLink(productUrlStr: String,title:String) {
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
        let data = self.socialViewModel.socialModelArray[index]
        if data.channelName != ""{
            let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
            postedbyController.isChannel = true
            postedbyController.channelName = data.channelName
            postedbyController.hashTagName = data.channelId
            postedbyController.noofPostsCount = data.noOfPosts
            self.navigationController?.pushViewController(postedbyController, animated: true)
        }else {
            let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
            profileVC.isNotFromTabBar = true
            /*
             Bug Name:- The follow button next to user name in the locations page is not working appropriately
             Fix Date:- 20th July 2021
             Fixed By:- Nikunj C
             Description of Fix:- use callback and call respective api
             */
            profileVC.followedAction = {
                self.postedByViewModel.hashTagOffSet = -20
                self.getHashTagPostsApiCall()
            }
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


extension SocialDetailsViewController {
    
    
    
    
    func getCurrentTimeStamp() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmssa"
        formatter.locale = Locale.current
        let result = formatter.string(from: date)
        return result
    }
    
    
    
    
}

//MARK:- Search view controller delegate
extension SocialDetailsViewController: SearchViewControllerDelegate{
    
    func didFollowOrUnfollowUser() {
        self.socialViewModel.offset = -20
        self.homeServiceCall()
        self.followFollowingServiceCall()
    }
}


extension SocialDetailsViewController: SubscribeConfirmationVCDelegate {
    
    func navigateToSubcribeSuccess(fullName : String,userId: String) {
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
    
    func inSufficientBalance(userName: String) {
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
    
    func navigateToUnSubcribeSuccess(model: UserProfileModel) {
        
    }
    
}

//MARK:- Comment View Controller delegate
extension SocialDetailsViewController: CommentsViewControllerDelegate{
    func commentCount(count: Int) {
        //        self.refresh()
    }
}

extension SocialDetailsViewController: ReportViewDelegate{
    
    func reportSelectedAtIndex(index: Int) {
        self.postReportReason(index: index)
    }
    
    func onDismissView(){
        //        self.startVideoPlayer()
    }
}


extension SocialDetailsViewController: SocialSubDetailsCollectionViewCellDelegate{
    
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
    
    func sendTipAction(index: Int) {
        if self.socialViewModel.socialModelArray[index].userId == Utility.getUserid() {
            return
        }
        //        let sendTipStoryBoard = UIStoryboard.init(name: "SendTip", bundle: nil)
        //        guard let sendTipVC = sendTipStoryBoard.instantiateViewController(withIdentifier: "SendTipCoinsViewController") as? SendTipCoinsViewController else {return}
        //        sendTipVC.delegate = self
        //        sendTipVC.hidesBottomBarWhenPushed = true
        //        sendTipVC.socialModelData = self.socialViewModel.socialModelArray[index]
        //        self.navigationController?.pushViewController(sendTipVC, animated: true)
        
        
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
        guard let cell = socialCollectionView.cellForItem(at: IndexPath(item: 0, section:  index + 1)) as? SocialDetailsInstaCollectionViewCell else {return}
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
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        /*
         Bug Name:- The follow button next to user name in the locations page is not working appropriately
         Fix Date:- 20th July 2021
         Fixed By:- Nikunj C
         Description of Fix:- use callback and call respective api
         */
        profileVC.followedAction = {
            self.postedByViewModel.hashTagOffSet = -20
            self.getHashTagPostsApiCall()
        }
        profileVC.isNotFromTabBar = true
        profileVC.memberId = userId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    func commentButtonTap(index: Int) {
        let commentVC = CommentsViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Main) as CommentsViewController
        guard let userID = Utility.getUserid() else { return }
        let data = self.socialViewModel.socialModelArray[index]
        commentVC.postId = data.postId
        commentVC.userId = userID
        commentVC.hidesBottomBarWhenPushed = true
        commentVC.delegate = self
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func shareInChatButtonTap(index: Int) {
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        guard let sharePostVC = storyboard.instantiateViewController(withIdentifier: Controlleridentifier.SharePostViewController) as? SharePostViewController else {return}
        sharePostVC.sharePostViewModel.followersFolloweeModelArray = socialViewModel.followersFolloweeModelArray
        let data = socialViewModel.socialModelArray[index]
        sharePostVC.postDetails = data
        sharePostVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        tabBarController?.present(sharePostVC, animated: true, completion: nil)
    }
    
    func shareThroughDeepLinkButtonTap(index: Int,forPost:Bool) {
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
        self.socialViewModel.socialModelArray[index] = socialModel
        self.socialViewModel.likeAndUnlikeService(index: index, isSelected: isSelected, complitation: {(success, error) in
            if success{
                
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.likeUpdate)
                print("like updated successfully")
                if FromDoubleTap {
                    self.socialViewModel.socialModelArray[index].liked = 1
                    self.socialViewModel.socialModelArray[index].likesCount += 1
                    self.delegate?.likeUnlikePost(index: index, isLike: false)
                    self.socialCollectionView.reloadData()
                }else {
                    if isSelected {
                        self.socialViewModel.socialModelArray[index].liked = 0
                        self.delegate?.likeUnlikePost(index: index, isLike: true)
                        self.socialCollectionView.reloadData()
                    }else{
                        self.socialViewModel.socialModelArray[index].liked = 1
                        self.delegate?.likeUnlikePost(index: index, isLike: false)
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
    
    func hastagOrProfileSelected(byTag: String,noOfPost:Int) {
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
            postedbyController.noofPostsCount = noOfPost
            postedbyController.isHashTag = true
            self.navigationController?.pushViewController(postedbyController, animated: true)
        }
    }
    
    
    func viewCountButtonTap(index: Int){
        let followVC = FollowViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as FollowViewController
        let data = self.socialViewModel.socialModelArray[index]
        followVC.followListType = .viewListView
        followVC.postOrUserId = data.postId
        followVC.viewTitle = "Viewers".localized
        self.navigationController?.pushViewController(followVC, animated: true)
    }
    
    func likeCountButtonTap(index: Int){
        let followVC = FollowViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as FollowViewController
        let data = self.socialViewModel.socialModelArray[index]
        followVC.followListType = .likeListView
        followVC.postOrUserId = data.postId
        followVC.viewTitle = "Likes".localized
        self.navigationController?.pushViewController(followVC, animated: true)
    }
}

extension SocialDetailsViewController: SendTipCoinsViewControllerDelegate,InSufficientCoinsViewControllerDelegate,TipSentVCDelegate {
    
    func updateWallet() {
        
    }
    func showSendTipSuccessScreen(userName: String) {
        if #available(iOS 13.0, *) {
            guard let successVc = UIStoryboard.init(name: "SendTip", bundle: nil).instantiateViewController(identifier: "TipSentSuccessfullyViewController") as? TipSentSuccessfullyViewController else {return}
            //            successVc.delegate = self
            successVc.userName = userName
            successVc.isFromSendTip = true
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
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func moveToInSufficientVc() {
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
        Route.navigateToCoinWallet(navigationController:self.navigationController)
    }
    func dismissToNavigateWallet() {
        Route.navigateToCoinWallet(navigationController:self.navigationController)
    }
}

extension SocialDetailsViewController:UnLockPostConfirmationViewControllerDelegate{
    func showSuccessScreen() {
        if #available(iOS 13.0, *) {
            let storyBoardObj = UIStoryboard.init(name: "SendTip", bundle: nil)
            guard let successVc = storyBoardObj.instantiateViewController(identifier: "TipSentSuccessfullyViewController") as? TipSentSuccessfullyViewController else {return}
            successVc.delegate = self
            successVc.isFromPurchase = true
            successVc.modalPresentationStyle = .fullScreen
            self.present(successVc,animated: true)
            print("Successfully updated")
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    
    func updateData(index: Int) {
        if var imageUrl = self.socialViewModel.socialModelArray[index].imageUrl {
            imageUrl = imageUrl.replace(target: "/e_blur:2000,o_80,", withString: "")
            self.socialViewModel.socialModelArray[index].imageUrl = imageUrl
        }
        if var thumbnilImageUrl = self.socialViewModel.socialModelArray[index].thumbnailUrl {
            thumbnilImageUrl = thumbnilImageUrl.replace(target: "/e_blur:2000,o_80,", withString: "")
            self.socialViewModel.socialModelArray[index].imageUrl = thumbnilImageUrl
        }
        self.socialViewModel.socialModelArray[index].isPurchased = 1
        self.socialCollectionView.reloadData()
    }
}
