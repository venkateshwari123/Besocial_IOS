//
//  ViewStoryViewController.swift
//  CameraModule
//
//  Created by Shivansh on 11/15/18.
//  Copyright © 2018 Shivansh. All rights reserved.
//

import UIKit
import Kingfisher
import Gemini
//import VGPlayer
import Locksmith
import Alamofire
import IJKMediaFramework

protocol viewStoryDelegate {
    func storyDeleted(deletedStory:StoryModel)
}

class ViewStoryViewController: UIViewController,SampleProtocol {
    var viewForSegProgressBar: UIView!
    let storyAPIObj = StoryAPI()
    var allStories:[userStory] = []
    var player:IJKFFMoviePlayerController?
    var isMyStory = true
    var isTheCurrentStoryIsVideo = false
    var jumpToIndex = 0
    var onceOnly = false
    var viewStoryDeleg:viewStoryDelegate?
    var openWatchedUsers = false
    
    var isFromSocialView:Bool = false
    var isFromProfileView:Bool = false
    
    var isNeedToStart: Bool = false
    
    @IBOutlet weak var storiesCollectionView: GeminiCollectionView!
    
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addSwipeDownDismiss()
        storiesCollectionView.gemini
            .cubeAnimation()
            .shadowEffect(.fadeIn)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.storiesCollectionView.scrollToItem(at: IndexPath.init(row: self.jumpToIndex, section: 0), at: .right, animated: true)
            self.view.layoutIfNeeded()
            
            
            if self.openWatchedUsers {
                self.openWatchStoryUsers()
            }
        }
        
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if((player) != nil) {
            player?.shutdown()
            player = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        print("deinit called")
    }
    
    /// To monitor player status changed
    @objc func playingStateChange(){
        guard let currentPlayer = self.player else{return}
        switch currentPlayer.playbackState {
        case .playing:
            print("****************************Start playing:isTreu:\(self.isNeedToStart)\n\n\n\n\n")
            if self.isNeedToStart{
                print("****************************Start playing\n\n\n\n\n")
                self.isNeedToStart = false
                DispatchQueue.main.async{ [weak self] in
                    self?.pauseStatusBar(isPaused: false)
                }
            }
            break
        case .stopped:
            //            print("Stop playing")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
            break
        case .interrupted:
            //            print("playing Interrupted")
            break
        case .paused:
            //            print("playing pause")
            break
        case .seekingForward, .seekingBackward:
            break
        @unknown default:
            break
        }
    }
    
    
    //MARK:- Button Actions
    @IBAction func watchStoryViewrsBtnAction(_ sender: Any) {
        openWatchStoryUsers()
    }
    
    @IBAction func moreBtnAction(_ sender: Any) {
        if isMyStory {
            deleteCurrentStoy()
        }
    }
    
    
    func deleteCurrentStoy() {
        self.pauseStory(isPaused: true)
        let alert = UIAlertController(title:nil, message:"Delete this story update".localized + "? " + "It will also be deleted for everyone who received it".localized + ".", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive , handler:{ (UIAlertAction)in
            
            let currentIndex:Int = Int(self.storiesCollectionView.contentOffset.x / self.storiesCollectionView.frame.size.width)
            let currentUserIndex =  IndexPath(item: currentIndex, section: 0)
            let currentUser = self.allStories[currentUserIndex.row]
            
            let selectedStory = currentUser.userStories[currentUser.currentStoryIndex]
            self.deleteStory(selectedStory:selectedStory)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel , handler:{ (UIAlertAction)in
            self.pauseStory(isPaused: false)
        }))
        
        self.present(alert, animated: true, completion:nil)
    }
    
    func deleteStory(selectedStory:StoryModel) {
        Helper.showPI()
        let deleteApi = "story" + "?storyId=\(selectedStory.storyID!)"
        
        storyAPIObj.deleteStory(with:deleteApi , params:[:], complitation: { (response, error) in
            if error != nil {
                Helper.hidePI()
                return
            }
            if response != nil ,let respDict = response as? [String:Any]{
                if let resultMsg = respDict["message"] as? String {
                    if resultMsg == "success" {
                        var allMyStories = self.allStories[0].userStories
                        for eachStory in allMyStories.enumerated() {
                            if(eachStory.element.storyID == selectedStory.storyID) {
                                allMyStories.remove(at:eachStory.offset)
                            }
                        }
                        self.allStories[0].userStories = allMyStories
                        NotificationCenter.default.post(name: NSNotification.Name("updateMyStories"), object: self.allStories[0])
                        self.allStories[0].userStories = allMyStories
                        NotificationCenter.default.post(name: NSNotification.Name("updateMyChatStories"), object: self.allStories[0])
                        Helper.hidePI()
                        self.dismiss(animated: true, completion:{
                            self.viewStoryDeleg?.storyDeleted(deletedStory: selectedStory)
                        })
                    }
                }
            }
        })
    }
    
    
    @IBAction func backbUTTONaCTION(_ sender: Any) {
        dismissVc()
    }
    
    func dismissVc() {
        self.dismiss(animated:true, completion:nil)
    }
    
    func showVideoForUrl(videoUrl:String,viewForVideo:UIView) {
        if(videoUrl.count > 5) {
            if self.player != nil {
                self.player?.shutdown()
                self.player?.view.removeFromSuperview()
                self.player = nil
            }
            let url = URL(string:videoUrl)
            let options = IJKFFOptions.byDefault()
            self.player = IJKFFMoviePlayerController(contentURL: url!, with: options)
            self.player?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.player?.view.frame = viewForVideo.bounds
            self.player?.scalingMode = .aspectFill
            viewForVideo.addSubview((self.player?.view)!)
            let center = NotificationCenter.default
            let mainQueue = OperationQueue.main
            center.addObserver(forName: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil, queue: mainQueue) { (notification) in
                self.playingStateChange()
            }
        }
    }
    
    
    func getAllStories() {
        if var fetchOldStories = UserDefaults.standard.array(forKey:"myStories") as? [[String: Any]] {
            
            fetchOldStories = fetchOldStories.reversed()
            let singleUserStories = [
                "userStories":fetchOldStories
            ]
            
            for _ in fetchOldStories {
                let userStoryModel = userStory.init(storiesDetails: singleUserStories)
                //creating user storyModel and checking user has stories or not.
                if(userStoryModel.userStories.count > 0 ) {
                    allStories.append(userStoryModel)
                }
            }
        }
    }
    
    func addSwipeDownDismiss() {
        //adding down gesture to view for dismissing view controller.
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.down:
                self.dismissVc()
            default:
                break
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ViewStoryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allStories.count
        
    }
    
    func playVideoForCurrentUser(videoView:UIImageView, currentIndex : Int) {
//        if let currentIndex = storiesCollectionView.indexPathsForVisibleItems.first{
//            currentIndex = visibleIndex.item + 1
        let currentUserIndex =  IndexPath(item: currentIndex, section: 0)
        let currentUser = allStories[currentUserIndex.row]
        //checking storyis video or not.
        
        if let currentVisibleCell = storiesCollectionView.cellForItem(at: currentUserIndex) as? StoryCollectionViewCell {
            if currentUser.userStories[currentUser.currentStoryIndex].storyType == 2 {
                if let videoUrl = currentUser.userStories[currentUser.currentStoryIndex].mediaUrl {
                    self.showVideoForUrl(videoUrl: videoUrl , viewForVideo:currentVisibleCell.storyImageView)
                    
                }
            }else{
                if self.player != nil {
                    self.player?.shutdown()
                    self.player?.view.removeFromSuperview()
                    self.player = nil
                }
            }
        } else {
            if currentUserIndex.row >= 0 {
                if currentUser.userStories[currentUser.currentStoryIndex].storyType == 2 {
                    if let videoUrl = currentUser.userStories[currentUser.currentStoryIndex].mediaUrl {
                        self.showVideoForUrl(videoUrl: videoUrl , viewForVideo:videoView)
                    }
                }
            }
            else{
                if self.player != nil {
                    self.player?.shutdown()
                    self.player?.view.removeFromSuperview()
                    self.player = nil
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.createAndSetStatusBar(indexPath: indexPath)
        
    }
    
    
    fileprivate func createAndSetStatusBar(indexPath: IndexPath){
        DispatchQueue.main.async{ [weak self] in
            guard let self = self else{return}
            let currentIndex = self.storiesCollectionView.indexPathsForVisibleItems.first!
            
            let numberOfStories = self.allStories[currentIndex.row].userStories.count
            let total = Float(self.view.frame.size.width-20) / Float(numberOfStories)
            
            self.viewForSegProgressBar.isHidden = false
            for subview in self.viewForSegProgressBar.subviews {
                subview.removeFromSuperview()
            }
            
            let currentIndexPosition = self.allStories[currentIndex.row].currentStoryIndex * Int(total)
            
            let originalFrame = CGRect(x:Int(currentIndexPosition), y: 0, width: 0, height:4)
            let animateView = UIView(frame:originalFrame)
            animateView.backgroundColor = UIColor.white
            animateView.tag = Int(total)
            animateView.layer.cornerRadius = 2
            animateView.clipsToBounds = true
            self.viewForSegProgressBar.addSubview(animateView)
            self.viewForSegProgressBar.layoutIfNeeded()
            
            let userStoryIndex = self.allStories[currentIndex.row].currentStoryIndex
            let duration =  self.allStories[currentIndex.row].userStories[userStoryIndex].duration
            let storyType = self.allStories[currentIndex.row].userStories[userStoryIndex].storyType
            if storyType == 2 {
                self.isTheCurrentStoryIsVideo = true
            } else {
                self.isTheCurrentStoryIsVideo = false
            }
            
            if !self.isMyStory {
                let storyIdentifier = self.allStories[currentIndex.row].userStories[userStoryIndex].storyID
                self.updateViewStory(storyID:storyIdentifier!)
            }
            
            UIView.animate(withDuration:TimeInterval(duration), animations:{
                var originalFrame = animateView.frame
                originalFrame.size.width = CGFloat(total)
                animateView.frame = originalFrame
            }, completion: {(finshed) in
                if finshed {
                    self.goToForwardStories()
                }
            })
            if self.isTheCurrentStoryIsVideo{
                self.pauseStatusBar(isPaused: true)
                self.isNeedToStart = true
                self.player?.prepareToPlay()
            }else {
                self.player?.pause()
            }
        }
    }
    
    func updateViewStory(storyID:String) {
        
        let strURL =  AppConstants.story + "?storyId=\(storyID)"
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        //        let params = ["storyId":storyID]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName:strURL, requestType: .patch, parameters: [:], headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {response in
        }, onError: { error in
            Helper.hidePI()
        })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !onceOnly {
            if self.jumpToIndex > 0{
                let indexToScrollTo = IndexPath(item: self.jumpToIndex, section: 0)
                self.storiesCollectionView.scrollToItem(at: indexToScrollTo, at: .left, animated: false)
            }
            self.createAndSetStatusBar(indexPath: indexPath)
            onceOnly = true
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"storyCell", for: indexPath) as! StoryCollectionViewCell
        
        self.viewForSegProgressBar = cell.viewForSegProgressBar
        //assinging storyDetails to cell.
        cell.storiesDetails = allStories[indexPath.row]
        cell.mainViewWidth = Float(self.view.frame.size.width-20)
        cell.progressCollectionView.reloadData()
        
        let userStory = allStories[indexPath.row].userStories
        
        //checking and modifying the current story index if it is outofbound range.
        var userCurrentStoryIndex = allStories[indexPath.row].currentStoryIndex
        if userCurrentStoryIndex <= 0 {
            userCurrentStoryIndex = 0
        } else if userStory.count-1 < userCurrentStoryIndex {
            userCurrentStoryIndex = userStory.count-1
        }
        cell.moreBtn.isHidden = !isMyStory
        
        
        //adding all the story created user details.
        //name,posted time and profile picture.
        cell.setupStoryDetails(currentIndex:userCurrentStoryIndex)
        
        if userStory[userCurrentStoryIndex].storyType == 2 {
            //video story.
            playVideoForCurrentUser(videoView:cell.storyImageView, currentIndex: indexPath.row)
            cell.storyImageView.contentMode = .scaleToFill
        } else {
            cell.storyImageView.contentMode = .scaleAspectFit
        }
        
        if userStory[userCurrentStoryIndex].storyType == 3 {
            cell.viewForTextLabel.isHidden = false
            cell.textViewForStory.text = userStory[userCurrentStoryIndex].storyText
            cell.viewForTextLabel.backgroundColor = Helper.hexStringToUIColor(hex:userStory[userCurrentStoryIndex].textBackgroundColor)
            cell.textViewForStory.backgroundColor = Helper.hexStringToUIColor(hex:userStory[userCurrentStoryIndex].textBackgroundColor)
            cell.textViewForStory.font = UIFont(name:userStory[userCurrentStoryIndex].textFontStyle , size: cell.textViewForStory.font!.pointSize)
        } else {
            cell.viewForTextLabel.isHidden = true
        }
        
        
        
        //adding tap gesture for forward and backward the story.
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        cell.storyImageView.isUserInteractionEnabled = true
        
        
        //adding long gesture for pause and play the story.
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        if userStory[userCurrentStoryIndex].storyType == 3 {
            cell.textViewForStory.addGestureRecognizer(lpgr)
            cell.textViewForStory.delegate = self
        } else {
            cell.storyImageView.addGestureRecognizer(tap)
            cell.storyImageView.addGestureRecognizer(lpgr)
        }
        
        // Attach a block to be called when the user taps a URL
        cell.textViewForStory.isAutomaticLinkDetectionEnabled = true
        cell.textViewForStory.urlLinkTapHandler = { (_,_,_) in
            
        }
        
        if isMyStory {
            cell.watchStoryViewersBtn.isHidden = false
            let numberOfUsers = " \(userStory[userCurrentStoryIndex].viewCount)"
            cell.watchStoryViewersBtn.setTitle(numberOfUsers, for:.normal)
            cell.storyUpArrowBtn.isHidden = false
            cell.viewForBottom.isHidden = false
            //Setup
            let panGR = UIPanGestureRecognizer(target: self, action: #selector(pan))
            cell.viewForBottom.addGestureRecognizer(panGR)
        }
        
        //cell.
        
        return cell
    }
    
    
    @objc func pan(recognizer : UIPanGestureRecognizer){
        if recognizer.direction == .up{
            self.openWatchStoryUsers()
        }
    }
    
    func openWatchStoryUsers() {
        self.pauseStory(isPaused: true)
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        guard let sharePostVC = storyboard.instantiateViewController(withIdentifier: "SharePostViewController") as? SharePostViewController else {return}
        sharePostVC.isForStory = true
        sharePostVC.storyDelga = self
        let currentIndex:Int = Int(storiesCollectionView.contentOffset.x / storiesCollectionView.frame.size.width)
        let currentUserIndex =  IndexPath(item: currentIndex, section: 0)
        let currentUser = allStories[currentUserIndex.row]
        sharePostVC.selectedStory = currentUser.userStories[currentUser.currentStoryIndex]
        sharePostVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.present(sharePostVC, animated: true, completion:{
            self.pauseStory(isPaused: true)
        })
    }
    
    func openSafari(with Url:URL) {
        Helper.openUrl(string: Url)
    }
    
    func tapped(onTextView touchLocation: CGPoint) {
        updateNextStory(selectedPoint:touchLocation)
    }
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let selectedPoint:CGPoint = sender.location(in: sender.view)
        //insert your touch based code here
        updateNextStory(selectedPoint:selectedPoint)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
    }
    
    
    func goToForwardStories() {
        let selectedIndex = storiesCollectionView.indexPathsForVisibleItems.first!
        // show next story if available.
        if(selectedIndex.item+1 == allStories.count) {
            //reached last user.
            if allStories[selectedIndex.row].currentStoryIndex == allStories[selectedIndex.row].userStories.count-1 {
                // current user stories finished.show next user stories.
                //curent user is last user so dismiss the VC.
                self.dismissVc()
                return;
            }
        } else {
            if allStories[selectedIndex.row].currentStoryIndex == allStories[selectedIndex.row].userStories.count-1 {
                // current user stories finished.show next user stories.
                //show next user stories.
                let nextCellIndex = IndexPath(item: selectedIndex.item+1, section:0)
                storiesCollectionView.scrollToItem(at:nextCellIndex , at: .centeredHorizontally, animated: true)
                return;
            }
        }
        
        // show current user next story.
        //change current storyIndex and update cell.
        updateCellAtIndexPath(selectedIndex: selectedIndex, isNext: true)
    }
    
    func goToBackStories() {
        let selectedIndex = storiesCollectionView.indexPathsForVisibleItems.first!
        // show previous user story if available.
        if(selectedIndex.item-1 >= 0) {
            //reached first user.
            //show previous user stories.
            let currentUser = allStories[selectedIndex.row]
            if(currentUser.currentStoryIndex != 0) {
                //show current user last story.
                updateCellAtIndexPath(selectedIndex: selectedIndex, isNext: false)
            } else {
                //reached user first story. so show last user stories.
                let nextCellIndex = IndexPath(item: selectedIndex.item-1, section:0)
                storiesCollectionView.scrollToItem(at:nextCellIndex , at: .centeredHorizontally, animated: true)
            }
        } else if(selectedIndex.item == 0){
            //first user story.
            //check any has previous stories or not.
            // show current user next story.
            //change current storyIndex and update cell.
            let currentUser = allStories[selectedIndex.row]
            if(currentUser.currentStoryIndex != 0) {
                updateCellAtIndexPath(selectedIndex: selectedIndex, isNext: false)
            }
        }
    }
    
    func updateNextStory(selectedPoint:CGPoint) {
        if(selectedPoint.x > self.view.frame.size.width/2) {
            goToForwardStories()
        } else {
            goToBackStories()
        }
    }
    
    
    func updateCellAtIndexPath(selectedIndex:IndexPath,isNext:Bool) {
        
        var currentUser = allStories[selectedIndex.row]
        if isNext {
            //increment current user story index.
            currentUser.currentStoryIndex = currentUser.currentStoryIndex + 1
        } else {
            //decrement current user story index.
            currentUser.currentStoryIndex = currentUser.currentStoryIndex - 1
        }
        
        allStories[selectedIndex.row] = currentUser
        
        //update cell.
        storiesCollectionView.reloadItems(at:[selectedIndex])
    }
    
    func pauseStory(isPaused:Bool) {
        if isPaused {
            for subView in self.viewForSegProgressBar.subviews {
                let layer = subView.layer
                let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                layer.speed = 0.0
                layer.timeOffset = pausedTime
            }
            if self.isTheCurrentStoryIsVideo {
                self.player?.pause()
            }
        } else {
            for subView in self.viewForSegProgressBar.subviews {
                let layer = subView.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
            if self.isTheCurrentStoryIsVideo {
                self.player?.play()
            }
        }
    }
    
    fileprivate func pauseStatusBar(isPaused: Bool){
        if isPaused {
            for subView in self.viewForSegProgressBar.subviews {
                let layer = subView.layer
                let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                layer.speed = 0.0
                layer.timeOffset = pausedTime
            }
        } else {
            for subView in self.viewForSegProgressBar.subviews {
                let layer = subView.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state == .ended {
            pauseStory(isPaused: false)
        } else if gesture.state == .began {
            pauseStory(isPaused: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewStoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = self.view.frame.height
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            height = height - (window?.safeAreaInsets.top)!
        }
        return CGSize(width: self.view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UIScrollViewDelegate
extension ViewStoryViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        storiesCollectionView.animateVisibleCells()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.viewForSegProgressBar.isHidden = true
        pauseStory(isPaused: true)
    }
}

extension ViewStoryViewController:storyDelegate {
    func dismissedViewScreen() {
        self.pauseStory(isPaused: false)
    }
    
    func deleteStoryTapped() {
        deleteCurrentStoy()
    }
}
