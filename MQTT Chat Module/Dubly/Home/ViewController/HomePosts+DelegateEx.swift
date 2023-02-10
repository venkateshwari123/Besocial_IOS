//
//  HomePosts+DelegateEx.swift
//  Do Chat
//
//  Created by Rahul Sharma on 28/08/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation

//import GoogleMobileAds
import UIKit

extension PostDetailsViewController: HomeFeedCollectionViewCellDelegate{
    func showMediaOptions() {
        
        if let status = Utility.getIsGuestUser() , status {
          presentWelcomeController()
          return
        }
        
        self.stopVideoPlayer()
        var url = ""
        let storyboard = UIStoryboard.init(name: "Home", bundle: nil)
        let shareMediaVC : ShareMediaOptionsVC = storyboard.instantiateViewController(withIdentifier: "ShareMediaOptionsVC") as! ShareMediaOptionsVC
        shareMediaVC.delegateObj = self
        shareMediaVC.dataModel = postDetailsViewModel
        shareMediaVC.imageArrayToVideoURL = imageArrayToVideoURL
        var postData :SocialModel
        if !forYouPostsCollectionView.isHidden {
            postData = postDetailsViewModel.forYouPostsModelArray[forYouPostsCurrenctIndex]
            url = postDetailsViewModel.forYouPostsModelArray[forYouPostsCurrenctIndex].imageUrl!
            if postData.userId != Utility.getUserid(){
                if postData.isPaid{
                    Helper.showAlert(head: "", message: "Post needs to be unlocked first to enable custom action".localized)
                    return
                }
            }
        }else if !postDetailsCollectionView.isHidden {
            postData = postDetailsViewModel.socialModelArray[currentIndex]
            url = postDetailsViewModel.socialModelArray[currentIndex].imageUrl!
            if postData.userId != Utility.getUserid(){
                if postData.isPaid{
                    Helper.showAlert(head: "", message: "Post needs to be unlocked first to enable custom action".localized)
                    return
                }
            }
        }else {
            postData = postDetailsViewModel.xclusivePostsModelArray[xClusivePostsCurrentIndex]
            url = postDetailsViewModel.xclusivePostsModelArray[xClusivePostsCurrentIndex].imageUrl!
            if postData.userId != Utility.getUserid(){
                if postData.isPaid{
                    Helper.showAlert(head: "", message: "Post needs to be unlocked first to enable custom action".localized)
                    return
                }
            }
        }
        shareMediaVC.data = postData
        shareMediaVC.callBack = { path,isDismiss, bookmarkStatus in
            
            if !self.forYouPostsCollectionView.isHidden {
                self.postDetailsViewModel.forYouPostsModelArray[self.forYouPostsCurrenctIndex].isBookMarked = bookmarkStatus
            }else if !self.postDetailsCollectionView.isHidden {
                self.postDetailsViewModel.socialModelArray[self.currentIndex].isBookMarked = bookmarkStatus
            }else if !self.xclusiveCollectionView.isHidden {
                self.postDetailsViewModel.xclusivePostsModelArray[self.xClusivePostsCurrentIndex].isBookMarked = bookmarkStatus
            }
            if isDismiss && self.isViewVisible{
                self.playVideoPlayerFromStoppedState()
            }else{
                Route.navigateToCamera(navigationController:self.navigationController,isFromPostedByMusicScreen:true,customAudioPath: path,customAudioUrl:url)
            }
        }
        shareMediaVC.showMoreOptions = {
            self.moreOptions(data: postData)
        }
        shareMediaVC.hidesBottomBarWhenPushed = true
        shareMediaVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        let nav = UINavigationController.init(rootViewController:shareMediaVC )
        nav.modalPresentationStyle = .overCurrentContext
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(nav, animated: true, completion: nil)
    }
    
    
    /*
     Refactor Name:- Unlock post navigation from home screen
     Refactor Date:- 06/05/2021
     Refactored By:- Jayaram
     Description of Refactor:- Added unlock post flow navigation
     */
    func forYoupaidPostTap(isFromTrending: Bool, index: Int,isXclusive: Bool) {
        if let status = Utility.getIsGuestUser() , status {
            presentWelcomeController()
            return
        }
        var  modelData : SocialModel
        if isFromTrending{
            modelData = self.postDetailsViewModel.forYouPostsModelArray[index]
        }
        else if isXclusive{
            modelData = self.postDetailsViewModel.xclusivePostsModelArray[index]
        }else {
            modelData = self.postDetailsViewModel.socialModelArray[index]
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
    
    /*
     Refactor Name:- subscribe navigation from home screen
     Refactor Date:- 06/05/2021
     Refactored By:- Jayaram
     Description of Refactor:- Added subscribe user flow navigation
     */
    func forYounavigateToConfirmSubscriptionVc(isFromTrending: Bool, index: Int,isXclusive: Bool) {
        if let status = Utility.getIsGuestUser() , status {
            presentWelcomeController()
            return
        }
        var  modelData : SocialModel
        if isFromTrending{
            modelData = self.postDetailsViewModel.forYouPostsModelArray[index]
        }
        else if isXclusive{
            modelData = self.postDetailsViewModel.xclusivePostsModelArray[index]
        }else {
            modelData = self.postDetailsViewModel.socialModelArray[index]
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
    
    func sendTipAction(isFromTrending: Bool, index: Int,isXclusive: Bool) {
        if let status = Utility.getIsGuestUser() , status {
            presentWelcomeController()
            return
        }
        var  modelData : SocialModel
        if isFromTrending{
            modelData = self.postDetailsViewModel.forYouPostsModelArray[index]
        }
        else if isXclusive{
            modelData = self.postDetailsViewModel.xclusivePostsModelArray[index]
        }else {
            modelData = self.postDetailsViewModel.socialModelArray[index]
        }
        
        let sendTipStoryBoard = UIStoryboard.init(name: "SendTip", bundle: nil)
        if #available(iOS 13.0, *) {
            guard let sendTipVC = sendTipStoryBoard.instantiateViewController(withIdentifier: "SendTipCoinsViewController") as? SendTipCoinsViewController else {return}
            sendTipVC.definesPresentationContext = true
            sendTipVC.modalPresentationStyle = .overCurrentContext
            sendTipVC.delegate = self
            sendTipVC.hidesBottomBarWhenPushed = true
            sendTipVC.socialModelData = modelData
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
    func forYouviewmoreTapped(isViewed: Bool, index: Int,isFromTrending: Bool,isXclusive: Bool) {
        let collectionView : UICollectionView
        if isFromTrending{
            self.postDetailsViewModel.forYouPostsModelArray[index].isExpand = isViewed
        }else if isXclusive {
            self.postDetailsViewModel.xclusivePostsModelArray[index].isExpand = isViewed
        }else{
            self.postDetailsViewModel.socialModelArray[index].isExpand = isViewed
        }
         
          }
    
    func muteAudio(isFromTrending: Bool,isXclusive: Bool) {
        if followingPostsBtnOutlet.isSelected, let visibleCell = self.postCollectionViewCurrentVisibleCellInCenter().1{
            visibleCell.muteBtn.isSelected = !visibleCell.muteBtn.isSelected
            self.audioPaused = visibleCell.muteBtn.isSelected
            self.currentIJKPlayer?.playbackVolume = visibleCell.muteBtn.isSelected ? 0.0 : 1.0
            isVideoPaused = true
        }else if forYouPostsBtnOutlet.isSelected , let visibleCell = self.trendingCollectionViewCurrentVisibleCellInCenter().1  {
            visibleCell.muteBtn.isSelected = !visibleCell.muteBtn.isSelected
            self.audioPaused = visibleCell.muteBtn.isSelected
            self.currentIJKPlayer?.playbackVolume = visibleCell.muteBtn.isSelected ? 0.0 : 1.0
            isVideoPaused = true
        }else if xclusivePostsButton.isSelected , let visibleCell = self.xclusiveCollectionViewCurrentVisibleCellInCenter().1 {
            visibleCell.muteBtn.isSelected = !visibleCell.muteBtn.isSelected
            self.audioPaused = visibleCell.muteBtn.isSelected
            self.currentIJKPlayer?.playbackVolume = visibleCell.muteBtn.isSelected ? 0.0 : 1.0
            isVideoPaused = true
            }
    }
    func forYouupdateBookMarkData(index: Int, isSelected: Bool,isFromTrending: Bool,isXclusive: Bool) {
        if isFromTrending{
            self.postDetailsViewModel.forYouPostsModelArray[index].isBookMarked = isSelected
        }else if isXclusive{
            self.postDetailsViewModel.xclusivePostsModelArray[index].isBookMarked = isSelected
        }else{
            self.postDetailsViewModel.socialModelArray[index].isBookMarked = isSelected
        }
        
    }
    
    /*
     Feature Name :- Add swipe to switch follow and foryou
     Feature Date :- 21/04/2021
     Featured By :- Jayaram G
     Description Of Feature :- Added swipe gestures actions
     */
    func switchFollowingAndForYou(isFromTrending: Bool,isXclusive: Bool, gesture: UISwipeGestureRecognizer) {
        print("swipe detected")
        /*
         Bug Name:- Handle swipe for three tabs
         Fix Date:- 04/05/2021
         Fixed By:- Jayaram
         Description of Fix:- Added swipe for exclusive posts
         */
        if self.navigationItem.titleView?.isHidden != true{
            if isFromTrending{
                if gesture.direction == .left {
                    self.xclusivePostsAction(self.xclusivePostsButton)
                }else {
                    self.followingPostsAction(self.followingPostsBtnOutlet)
                }
            }else if isXclusive {
                if gesture.direction == .right {
                    self.forYouPostsAction(self.forYouPostsBtnOutlet)
                }
            }else{
                if gesture.direction == .left {
                    self.forYouPostsAction(self.forYouPostsBtnOutlet)
                }
            }
        }
    }
    
    func forYouviewCollection(isFromTrending:Bool,isXclusive: Bool) {
        let mainStroyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let bookMarkedVC : BookMarkedPostsViewController = mainStroyBoard.instantiateViewController(withIdentifier: "BookMarkedPostsViewController") as! BookMarkedPostsViewController
        guard let savedCollectionData = self.savedCollectionObj else {return}
        bookMarkedVC.collection = savedCollectionData
        bookMarkedVC.isCollectionDetails =  true
        bookMarkedVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(bookMarkedVC, animated: true)
    }
    
    func forYoumoveToCOllections(isFromTrending:Bool,isXclusive: Bool) {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        let collectionVC = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SavedCollectionsViewController) as! SavedCollectionsViewController
        collectionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(collectionVC, animated: true)
    }
    
    func forYousaveToCollectionAction(isFromTrending:Bool,isXclusive: Bool) {
        
    }
    
    
    func forYouopenBusinessProductLink(productUrlStr: String,title:String,isFromTrending:Bool,isXclusive: Bool) {
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
    
    func forYouchannelButtonTapped(index: Int,isFromTrending:Bool,isXclusive: Bool) {
        let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        var  modelData : SocialModel
        if isFromTrending{
            modelData = self.postDetailsViewModel.forYouPostsModelArray[index]
        }
        else if isXclusive{
            modelData = self.postDetailsViewModel.xclusivePostsModelArray[index]
        }else{
            modelData = self.postDetailsViewModel.socialModelArray[index]
        }
        postedbyController.isChannel = true
        postedbyController.channelName = modelData.channelName
        postedbyController.hashTagName = modelData.channelId
        if self.postDetailsViewModel.channelViewModelArray.count > index {
            postedbyController.hashTagName = self.postDetailsViewModel.channelViewModelArray[index].channelId
        }
        postedbyController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(postedbyController, animated: true)
    }
    
    func forYoumusicButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool) {
        let postedByMusicVC = PostedByMusicViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByMusicViewController
        var data:SocialModel
        if isFromTrending{
            data = self.postDetailsViewModel.forYouPostsModelArray[index]
        }else if isXclusive {
            data = self.postDetailsViewModel.xclusivePostsModelArray[index]
        }else{
            data = self.postDetailsViewModel.socialModelArray[index]
        }
        postedByMusicVC.postedByViewModel.mediaModel = data.mediaData
        postedByMusicVC.hidesBottomBarWhenPushed = true
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.pushViewController(postedByMusicVC, animated: true)
    }
    
    func forYousingleTapOnCell(isFromTrending:Bool,isXclusive: Bool) {
        if followingPostsBtnOutlet.isSelected,let visibleIndex = self.postCollectionViewCurrentVisibleCellInCenter().0, let visibleCell = self.postCollectionViewCurrentVisibleCellInCenter().1, let player = self.currentIJKPlayer{
            if player.isPlaying(){
                visibleCell.playImageView.isHidden = false
                player.pause()
                isVideoPaused = true
                
            }else{
                if !player.isPreparedToPlay{
                    self.playVideoOnTheCell(cellType : .FollowingPosts,cell: visibleCell, indexPath: visibleIndex)
                    return
                }
                if let isCallGoingOn = UserDefaults.standard.value(forKey: "iscallgoingOn") as? Bool, isCallGoingOn {
                    return
                }
                player.play()
                visibleCell.playImageView.isHidden = true
                isVideoPaused = false
            }
        
        }else if forYouPostsBtnOutlet.isSelected , let visibleIndex = self.trendingCollectionViewCurrentVisibleCellInCenter().0,let visibleCell = self.trendingCollectionViewCurrentVisibleCellInCenter().1, let player = self.currentIJKPlayer {
            if player.isPlaying(){
                visibleCell.playImageView.isHidden = false
                player.pause()
                isVideoPaused = true
                
            }else{
                if !player.isPreparedToPlay{
                    self.playVideoOnTheCell(cellType : .TrendingPosts,cell: visibleCell, indexPath: visibleIndex)
                    return
                }
                if let isCallGoingOn = UserDefaults.standard.value(forKey: "iscallgoingOn") as? Bool, isCallGoingOn {
                    return
                }
                player.play()
                visibleCell.playImageView.isHidden = true
                isVideoPaused = false
            }
         
        }else if xclusivePostsButton.isSelected ,let visibleIndex = self.xclusiveCollectionViewCurrentVisibleCellInCenter().0, let visibleCell = self.xclusiveCollectionViewCurrentVisibleCellInCenter().1,let player = self.currentIJKPlayer {
            if player.isPlaying(){
                visibleCell.playImageView.isHidden = false
                if let isCallGoingOn = UserDefaults.standard.value(forKey: "iscallgoingOn") as? Bool, isCallGoingOn {
                    return
                }
                player.pause()
                isVideoPaused = true
                
            }else{
                if !player.isPreparedToPlay{
                    self.playVideoOnTheCell(cellType : .ExclusivePosts, cell: visibleCell, indexPath: visibleIndex)
                    return
                }
                player.play()
                visibleCell.playImageView.isHidden = true
                isVideoPaused = false
            }
      
            }
    }
    

    
    func forYoucommentButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool) {
        if let status = Utility.getIsGuestUser() , !status {
            var data:SocialModel
            if isFromTrending{
                data = self.postDetailsViewModel.forYouPostsModelArray[index]
            }else if isXclusive {
                data = self.postDetailsViewModel.xclusivePostsModelArray[index]
            }
            else{
                data = self.postDetailsViewModel.socialModelArray[index]
            }
            if let isComment = data.allowComment, isComment{
                self.stopVideoPlayer()
                guard let followVC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "LikesCommentsVC") as? DublyFollowViewController else {return}
                // followVC.followListType = .likeListView
                followVC.postOrUserId = data.postId
                followVC.hidesBottomBarWhenPushed = true
                followVC.isFromHome = true
                followVC.isCommentsTabSelected = true
                followVC.data = data
                followVC.callBack = { isDismiss in
                    if isDismiss, self.isViewVisible{
                        self.playVideoPlayerFromStoppedState()
                        self.updateFollowFollowingData()
                    }
                }
                followVC.updateCommentsCount = { newCount in
                    if isFromTrending{
                        self.postDetailsViewModel.forYouPostsModelArray[index].commentCount = newCount
                    }else if isXclusive {
                        self.postDetailsViewModel.xclusivePostsModelArray[index].commentCount = newCount
                    }
                    else{
                        self.postDetailsViewModel.socialModelArray[index].commentCount = newCount
                    }
                    
                }
                followVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                let nav = UINavigationController.init(rootViewController:followVC )
                nav.modalPresentationStyle = .overCurrentContext
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(nav, animated: true, completion: nil)
            }
            else{
                Helper.showAlert(head: "Message".localized, message: "Comments are disabled for this post".localized)
            }
        }else{
            presentWelcomeController()
        }
    }
    
    func forYouviewCountButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool){
        var data:SocialModel
        if isFromTrending{
            data = self.postDetailsViewModel.forYouPostsModelArray[index]
        }else if isXclusive {
            data = self.postDetailsViewModel.xclusivePostsModelArray[index]
        }
        else{
            data = self.postDetailsViewModel.socialModelArray[index]
        }
        
        if let status = Utility.getIsGuestUser() , !status {
            let followVC = FollowViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as FollowViewController
            followVC.followListType = .viewListView
            followVC.postOrUserId = data.postId
            followVC.viewTitle = "Viewers".localized
            self.navigationController?.pushViewController(followVC, animated: true)
        }
        else{
            
            presentWelcomeController()
        }
    }
    
    /*
     Bug Name:- Add share post on home screen
     Fix Date:- 20/04/2021
     Fixed By:- Jayaram
     Description of Fix:- added creating deeplink function
     */
    func forYoushareButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool) {
        if let status = Utility.getIsGuestUser() , !status {
            var data:SocialModel
            if isFromTrending{
                data = self.postDetailsViewModel.forYouPostsModelArray[index]
            }else if isXclusive {
                data = self.postDetailsViewModel.xclusivePostsModelArray[index]
            }
            else{
                data = self.postDetailsViewModel.socialModelArray[index]
            }
            
            if let status = Utility.getIsGuestUser() , status {
                           presentWelcomeController()
                return
                         }
            guard let sharePostVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharePostViewController") as? SharePostViewController else {return}
            sharePostVC.sharePostViewModel.followersFolloweeModelArray = self.postDetailsViewModel.followersFolloweeModelArray
            sharePostVC.postDetails = data
            sharePostVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            tabBarController?.present(sharePostVC, animated: true, completion: nil)

                     
        }else {
            presentWelcomeController()
        }
    }
    
    func forYouprofileImageViewTap(index: Int, userName: String?,isFromTrending:Bool,isXclusive: Bool) {
        if let status = Utility.getIsGuestUser() , !status {
            var data:SocialModel
            if isFromTrending{
                data = self.postDetailsViewModel.forYouPostsModelArray[index]
            }else if isXclusive {
                data = self.postDetailsViewModel.xclusivePostsModelArray[index]
            }else{
                data = self.postDetailsViewModel.socialModelArray[index]
            }
            if data.channelName != ""{
                let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
                postedbyController.isChannel = true
                if isFromTrending{
                    postedbyController.socialModelArray = self.postDetailsViewModel.forYouPostsModelArray
                }else if isXclusive {
                    postedbyController.socialModelArray = self.postDetailsViewModel.xclusivePostsModelArray
                }
                else{
                    postedbyController.socialModelArray = self.postDetailsViewModel.socialModelArray
                }
                
                
                postedbyController.channelName = data.channelName
                postedbyController.hashTagName = data.channelId
                
                /*
                 Bug Name:- follow button not work properly
                 Fix Date:- 25/03/2021
                 Fixed By:- Nikunj C
                 Description of Fix:- add delegate and pass cell index
                 */
                
                postedbyController.forYouPostSelectedCellIndex = index
                postedbyController.updatingHomePagePostsObject = self
                if self.postDetailsViewModel.channelViewModelArray.count > index {
                    postedbyController.hashTagName = self.postDetailsViewModel.channelViewModelArray[index].channelId
                }
                postedbyController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(postedbyController, animated: true)
            }else {
                let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
                profileVC.isFromPostDetailsPage = true
                /*
             Bug Name:- Handle profile tab for self profile and other profile
             Fix Date:- 22/04/21
             Fix By  :- Jayaram G
             Description of Fix:- Passing flag for to hide tabbar
             */
            profileVC.isNotFromTabBar = true
                profileVC.updatingHomePagePostsObject = self
                    
                /*
                 Bug Name:- follow button not work properly
                 Fix Date:- 25/03/2021
                 Fixed By:- Nikunj C
                 Description of Fix:- pass cell index
                 */
                
                profileVC.forYouPostSelectedCellIndex = index
                profileVC.hidesBottomBarWhenPushed = true
                if userName == nil{
                    profileVC.memberId = data.userId
                }else{
                    profileVC.userNameTag = userName
                }
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        }else {
            presentWelcomeController()
        }
    }
    
    func forYoulikeButtonTap(index: Int, isSelected: Bool,isFromTrending:Bool,isXclusive: Bool) {
        var data :SocialModel
        if isFromTrending{
            data = self.postDetailsViewModel.forYouPostsModelArray[index]
        }else if isXclusive {
            data = self.postDetailsViewModel.xclusivePostsModelArray[index]
        }
        else{
            data = self.postDetailsViewModel.socialModelArray[index]
        }
        
        if let status = Utility.getIsGuestUser() , !status {
            self.postDetailsViewModel.likeAndUnlikeService(data: data,index: index, isSelected: isSelected, complitation: {(success, error) in
                if success{
                    
                    if isFromTrending{
                        
                        if self.postDetailsViewModel.forYouPostsModelArray[index].liked == 1{
                            self.postDetailsViewModel.forYouPostsModelArray[index].liked = 0
                            self.postDetailsViewModel.forYouPostsModelArray[index].likesCount = (self.postDetailsViewModel.forYouPostsModelArray[index].likesCount) - 1
                            self.delegate?.likeUnlikePost?(index: index, isLike: true)
                        }else{
                            self.postDetailsViewModel.forYouPostsModelArray[index].liked = 1
                            self.postDetailsViewModel.forYouPostsModelArray[index].likesCount = (self.postDetailsViewModel.forYouPostsModelArray[index].likesCount) + 1
                            self.delegate?.likeUnlikePost?(index: index, isLike: false)
                        }
                    }else if isXclusive {
                        if self.postDetailsViewModel.xclusivePostsModelArray[index].liked == 1{
                            self.postDetailsViewModel.xclusivePostsModelArray[index].liked = 0
                            self.postDetailsViewModel.xclusivePostsModelArray[index].likesCount = (self.postDetailsViewModel.xclusivePostsModelArray[index].likesCount) - 1
                            self.delegate?.likeUnlikePost?(index: index, isLike: true)
                        }else{
                            self.postDetailsViewModel.xclusivePostsModelArray[index].liked = 1
                            self.postDetailsViewModel.xclusivePostsModelArray[index].likesCount = (self.postDetailsViewModel.xclusivePostsModelArray[index].likesCount) + 1
                            self.delegate?.likeUnlikePost?(index: index, isLike: false)
                            
                        }
                    }
                    else{
                        if self.postDetailsViewModel.socialModelArray[index].liked == 1{
                            self.postDetailsViewModel.socialModelArray[index].liked = 0
                            self.postDetailsViewModel.socialModelArray[index].likesCount = (self.postDetailsViewModel.socialModelArray[index].likesCount) - 1
                            self.delegate?.likeUnlikePost?(index: index, isLike: true)
                        }else{
                            self.postDetailsViewModel.socialModelArray[index].liked = 1
                            self.postDetailsViewModel.socialModelArray[index].likesCount = (self.postDetailsViewModel.socialModelArray[index].likesCount) + 1
                            self.delegate?.likeUnlikePost?(index: index, isLike: false)
                        }
                    }
                    
                    
                    self.isLikeUpadated = true
                }else{
                    
                    self.isLikeUpadated = true
                }
            })
        }
        else {
            presentWelcomeController()
        }
    }
    
    func forYoulikeCountButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool){
        var data:SocialModel
        if isFromTrending{
            data = self.postDetailsViewModel.forYouPostsModelArray[index]
        }else if isXclusive {
            data = self.postDetailsViewModel.xclusivePostsModelArray[index]
        }
        else{
            data = self.postDetailsViewModel.socialModelArray[index]
        }
        if let status = Utility.getIsGuestUser() , !status {
            self.stopVideoPlayer()
            guard let followVC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "LikesCommentsVC") as? DublyFollowViewController else {return}
            followVC.postOrUserId = data.postId
            followVC.hidesBottomBarWhenPushed = true
            followVC.isFromHome = true
            followVC.isLikesTabSelected = true
            followVC.data = data
            followVC.callBack = { isDismiss in
                if isDismiss, self.isViewVisible{
                    self.playVideoPlayerFromStoppedState()
                    self.updateFollowFollowingData()
                }
            }
            followVC.updateCommentsCount = { newCount in
                if isFromTrending{
                    self.postDetailsViewModel.forYouPostsModelArray[index].commentCount = newCount
                }else if isXclusive {
                    self.postDetailsViewModel.xclusivePostsModelArray[index].commentCount = newCount
                }
                else{
                    self.postDetailsViewModel.socialModelArray[index].commentCount = newCount
                }
                
            }
            followVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            let nav = UINavigationController.init(rootViewController:followVC )
            nav.modalPresentationStyle = .overCurrentContext
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(nav, animated: true, completion: nil)
        }
        else {
            presentWelcomeController()
        }
    }
    
    func forYoucategoryButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool){
        var data:SocialModel
        if isFromTrending{
            data = self.postDetailsViewModel.forYouPostsModelArray[index]
        }else if isXclusive {
            data = self.postDetailsViewModel.xclusivePostsModelArray[index]
        }
        else{
            data = self.postDetailsViewModel.socialModelArray[index]
        }
        if let status = Utility.getIsGuestUser() , !status {
            let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
            postedbyController.isCategory = true
            postedbyController.categoryName = data.categoryName
            postedbyController.hashTagName = data.categoryId
            postedbyController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(postedbyController, animated: true)
        }else {
            presentWelcomeController()
        }
    }
    
    
    func forYoufollowUserButtonTap(index: Int, isSelected: Bool,isFromTrending:Bool,isXclusive: Bool){
        
        
        if let status = Utility.getIsGuestUser() , !status {
            if isFromTrending{
                guard let cell = self.forYouPostsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? HomeFeedCollectionViewCell else {return}
                
                guard let userId = self.postDetailsViewModel.forYouPostsModelArray[index].userId else {return }
                if isSelected == false {
                    let userName = "\(self.postDetailsViewModel.forYouPostsModelArray[index].userName ?? "")"
                    
                    Helper.toastViewForReachability(messsage: "Now you are following".localized + " \(userName)",fromHome: true ,view: self.view)
                }
                if (self.postDetailsViewModel.forYouPostsModelArray[index].isFollowing){
                    self.postDetailsViewModel.forYouPostsModelArray[index].isFollowing = false
                    trendingRemoveFollowersList.append(userId)
                    if trendingNewFollowersList.contains(userId), let index = trendingNewFollowersList.firstIndex(of: userId){
                        trendingNewFollowersList.remove(at: index)
                    }
                    cell.newFollowersList = trendingNewFollowersList
                    cell.removeFollowersList = trendingRemoveFollowersList
                    postedByVcDelegateObj?.updateDataFollow(following: false, index: index)
                }else{
                    self.postDetailsViewModel.forYouPostsModelArray[index].isFollowing = true
                    trendingNewFollowersList.append(userId)
                    if trendingRemoveFollowersList.contains(userId), let index = trendingRemoveFollowersList.firstIndex(of: userId){
                        trendingRemoveFollowersList.remove(at: index)
                    }
                    cell.newFollowersList = trendingNewFollowersList
                    cell.removeFollowersList = trendingRemoveFollowersList
                    postedByVcDelegateObj?.updateDataFollow(following: true, index: index)
                    
                }
            }else if isXclusive {
                guard let userId = self.postDetailsViewModel.xclusivePostsModelArray[index].userId else {return }
                guard let cell = self.xclusiveCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? HomeFeedCollectionViewCell else {return}
                if isSelected == false {
                    let userName = "\(self.postDetailsViewModel.xclusivePostsModelArray[index].userName ?? "")"
                    
                    Helper.toastViewForReachability(messsage: "Now you are following".localized + " \(userName)",fromHome: true ,view: self.view)
                }
                if (self.postDetailsViewModel.xclusivePostsModelArray[index].isFollowing){
                    self.postDetailsViewModel.xclusivePostsModelArray[index].isFollowing = false
                    removeFollowersList.append(userId)
                    if newFollowersList.contains(userId), let index = newFollowersList.firstIndex(of: userId){
                        newFollowersList.remove(at: index)
                    }
                    cell.newFollowersList = newFollowersList
                    cell.removeFollowersList = removeFollowersList
                    postedByVcDelegateObj?.updateDataFollow(following: false, index: index)
                }else{
                    self.postDetailsViewModel.xclusivePostsModelArray[index].isFollowing = true
                    newFollowersList.append(userId)
                    if removeFollowersList.contains(userId), let index = removeFollowersList.firstIndex(of: userId){
                        removeFollowersList.remove(at: index)
                    }
                    cell.newFollowersList = newFollowersList
                    cell.removeFollowersList = removeFollowersList
                    postedByVcDelegateObj?.updateDataFollow(following: true, index: index)
                    
                }
            }
            else{
                guard let userId = self.postDetailsViewModel.socialModelArray[index].userId else {return }
                guard let cell = self.postDetailsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? HomeFeedCollectionViewCell else {return}
                if isSelected == false {
                    let userName = "\(self.postDetailsViewModel.socialModelArray[index].userName ?? "")"
                    
                    Helper.toastViewForReachability(messsage: "Now you are following".localized + " \(userName)",fromHome: true ,view: self.view)
                }
                if (self.postDetailsViewModel.socialModelArray[index].isFollowing){
                    self.postDetailsViewModel.socialModelArray[index].isFollowing = false
                    removeFollowersList.append(userId)
                    if newFollowersList.contains(userId), let index = newFollowersList.firstIndex(of: userId){
                        newFollowersList.remove(at: index)
                    }
                    cell.newFollowersList = newFollowersList
                    cell.removeFollowersList = removeFollowersList
                    postedByVcDelegateObj?.updateDataFollow(following: false, index: index)
                }else{
                    self.postDetailsViewModel.socialModelArray[index].isFollowing = true
                    newFollowersList.append(userId)
                    if removeFollowersList.contains(userId), let index = removeFollowersList.firstIndex(of: userId){
                        removeFollowersList.remove(at: index)
                    }
                    cell.newFollowersList = newFollowersList
                    cell.removeFollowersList = removeFollowersList
                    postedByVcDelegateObj?.updateDataFollow(following: true, index: index)
                    
                }
            }
            
            
            /* Bug Name : crashes on following rihan star from exclusive post Think it’s a random crash
             Fix Date : 13-05-2021
             Fixed By : Jayaram G
             Description Of Fix : Handled data for xclusive posts
             */

            self.postDetailsViewModel.followAndUnFollowUserService(index: index, isSelected: isSelected,isForYouPosts: isFromTrending, isXclusive: isXclusive)
        }else{
            presentWelcomeController()
        }
    }
    
    func forYousubscriberUserButton(index: Int, isSelected: Bool,channelId: String){
        if let status = Utility.getIsGuestUser() , !status {
            postedByViewModel.subscribeAndUnsubscribChannel(subscribe: isSelected, channelId: channelId) {  (success, error) in
                if success {
                    // self?.forYouPostsCollectionView.reloadData()
                }
            }
        }
        else{
            presentWelcomeController()
        }
    }
    
    
    
    func forYouhashtagTextTapped(index: Int, hashTag: String,isFromTrending:Bool,isXclusive: Bool){
        
        /* Bug Name : as a guest user I don’t need to login to see hash tag posts or user profile but bow if I click on hash tag or user profile the app is asking me to look
                 Fix Date : 4-5-2021
                 Fixed By : Vishal V
                 Description Of Fix : removed login condition
                 */

//        if let status = Utility.getIsGuestUser() , !status {
        let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
            postedbyController.hashTagName = hashTag
            
            if isFromTrending{
                postedbyController.hashTagImageUrl = self.postDetailsViewModel.forYouPostsModelArray[index].hashTagImage
            }else if isXclusive {
                postedbyController.hashTagImageUrl = self.postDetailsViewModel.xclusivePostsModelArray[index].hashTagImage
            }
            else{
                postedbyController.hashTagImageUrl = self.postDetailsViewModel.socialModelArray[index].hashTagImage
            }
            
            postedbyController.isHashTag = true
            postedbyController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(postedbyController, animated: true)
//        }else{
//            presentWelcomeController()
//        }
    }
    
    
    func forYoulocationButtonTap(index: Int){
        if let status = Utility.getIsGuestUser() , !status {
            /*
             Bug Name :- Application crashed on clicking tagged location
             Fix Date :- 09/07/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Changed storyboard
             */
            let postsLocationVC = PostsLocationViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostsLocationViewController
            if !self.forYouPostsCollectionView.isHidden{
                         let data = self.postDetailsViewModel.forYouPostsModelArray[index]
                         postsLocationVC.hidesBottomBarWhenPushed = true
                         postsLocationVC.placeName = data.place
                         postsLocationVC.placeId = data.placeId ?? ""
                         postsLocationVC.lattitude = data.lattitude
                         postsLocationVC.longitude = data.longitude
            }else if !self.postDetailsCollectionView.isHidden  {
                         let data = self.postDetailsViewModel.socialModelArray[index]
                         postsLocationVC.hidesBottomBarWhenPushed = true
                         postsLocationVC.placeName = data.place
                         postsLocationVC.placeId = data.placeId ?? ""
                         postsLocationVC.lattitude = data.lattitude
                         postsLocationVC.longitude = data.longitude
            }else if !self.xclusiveCollectionView.isHidden {
                let data = self.postDetailsViewModel.xclusivePostsModelArray[index]
                postsLocationVC.hidesBottomBarWhenPushed = true
                postsLocationVC.placeName = data.place
                postsLocationVC.placeId = data.placeId ?? ""
                postsLocationVC.lattitude = data.lattitude
                postsLocationVC.longitude = data.longitude
   }
            self.navigationController?.pushViewController(postsLocationVC, animated: true)
            
        }else{
            presentWelcomeController()
        }
    }
    
  
    func moreOptions(data:SocialModel?){
        let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
        guard let optionsVC = storyBoard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.customOptionsAlertViewControllerId) as? CustomOptionsAlertViewController else {return}
        optionsVC.definesPresentationContext = true
        optionsVC.modalPresentationStyle = .overCurrentContext
        optionsVC.hidesBottomBarWhenPushed = true
        optionsVC.delegate = self
        if let postData = data, let postUserId = postData.userId, postUserId == Utility.getUserid(){
            optionsVC.isSelf = true
        }else {
            optionsVC.isSelf = false
        }
        DispatchQueue.main.async {
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(optionsVC, animated: true, completion: nil)
        }
    }
}


extension PostDetailsViewController: ReportViewDelegate{
    
    func reportSelectedAtIndex(index: Int) {
        self.postReportReason(index: index)
    }
    
    func onDismissView(){
        self.startVideoPlayer()
    }
}




extension PostDetailsViewController: CommentsViewControllerDelegate{
    
    func commentCount(count: Int) {
        if self.postDetailsCollectionView.isHidden && self.xclusiveCollectionView.isHidden{
            var data = postDetailsViewModel.forYouPostsModelArray[forYouPostsCurrenctIndex]
            let totalComment = data.commentCount + count
            data.commentCount = totalComment
            postDetailsViewModel.forYouPostsModelArray[forYouPostsCurrenctIndex] = data
            DispatchQueue.main.async {
                self.forYouPostsCollectionView.reloadData()
            }
        }else if self.xclusiveCollectionView.isHidden && self.forYouPostsCollectionView.isHidden {
            var data = postDetailsViewModel.socialModelArray[currentIndex]
            let totalComment = data.commentCount + count
            data.commentCount = totalComment
            postDetailsViewModel.socialModelArray[currentIndex] = data
            DispatchQueue.main.async {
                self.postDetailsCollectionView.reloadData()
            }
        }else if self.postDetailsCollectionView.isHidden && self.forYouPostsCollectionView.isHidden {
            var data = postDetailsViewModel.xclusivePostsModelArray[self.xClusivePostsCurrentIndex]
            let totalComment = data.commentCount + count
            data.commentCount = totalComment
            postDetailsViewModel.xclusivePostsModelArray[currentIndex] = data
            DispatchQueue.main.async {
                self.xclusiveCollectionView.reloadData()
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}


extension PostDetailsViewController {
    
    /*
     Bug Name:- Added once post showing twice in post page and profile page
     Fix Date:- 4th Oct 2021
     Fixed By:- Nikunj C
     Description of Fix:- instead of notification use function
     */
    
    func uploadNewPost(newPostModel: NewPostModel?) {
        if let newpost = newPostModel {
            DispatchQueue.main.async {
                self.uploadingProgressView.progress = 0.0
                self.uploadingPercentageLabel.text = "0%"
            }
            /*
             Bug Name:- post uploaded multiple time
             Fix Date:- 12th Jul 2021
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
        self.navigationController?.navigationBar.layer.zPosition = -1
        let image = UIImage(contentsOfFile:newPost.mediaPath)
        self.newPostedImageView.image = image
        
        CloudinaryManager.sharedInstance.uploadImage(image: image!, folder: .post,progress: { (progress) in
            
            DispatchQueue.main.async {
                let uploadedProgress = Float (Float(progress.completedUnitCount) / Float(progress.totalUnitCount))
                let progress = Int(uploadedProgress * 100)
                self.uploadingPercentageLabel.text = "\(progress)%"
                self.uploadingProgressView.setProgress(uploadedProgress, animated: true)
            }
            
        }) { (result, error) in
            DispatchQueue.main.async {
                self.uploadingViewHeightConstraint.constant = 0
                self.navigationController?.navigationBar.layer.zPosition = 0
            
            if let result = result {
                var updatedPostObj = newPost
                updatedPostObj.mediaPath = result.url!;
                updatedPostObj.height = result.height ?? 100
                updatedPostObj.width = result.width ?? 100
                updatedPostObj.cloudinaryPublicID = result.publicId!;
                self.requestForCreateNewPost(newPost:updatedPostObj)
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
        self.navigationController?.navigationBar.layer.zPosition = -1
        self.newPostedImageView.image = newPost.image
        
        //        let videoSavedUrl = URL(string: newPost.mediaPath)
        
        CloudinaryManager.sharedInstance.uploadVideo(video: URL(string: newPost.mediaPath)!) { (progress) in
            DispatchQueue.main.async {
                let uploadedProgress = Float (Float(progress.completedUnitCount) / Float(progress.totalUnitCount))
                let progress = Int(uploadedProgress * 100)
                self.uploadingPercentageLabel.text = "\(progress)%"
                self.uploadingProgressView.setProgress(uploadedProgress, animated:true)
            }
        } onCompletion: { (result, error) in
            DispatchQueue.main.async {
                self.uploadingViewHeightConstraint.constant = 0
                self.navigationController?.navigationBar.layer.zPosition = 0
                    if let result = result {
                        var updatedPostObj = newPost
                        updatedPostObj.mediaPath = result.url!;
                        updatedPostObj.height = result.height ?? 100
                        updatedPostObj.width = result.width ?? 100
                        updatedPostObj.cloudinaryPublicID = result.publicId!;
                        self.requestForCreateNewPost(newPost:updatedPostObj)
                    }
                }
        }
    }
    
    func requestForCreateNewPost(newPost:NewPostModel) {
        let socialApi = SocialAPI()
        socialApi.createNewPost(newpostDetails:newPost , complitation: { (isPosted,newPost) in
            if isPosted, let post = newPost{
                self.postDetailsViewModel.socialModelArray.insert(post, at: 0)
                DispatchQueue.main.async {
                    self.postDetailsCollectionView.reloadData()
                    self.postDetailsCollectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .top, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                        self.postDetailsViewModel.offset = 0
                        self.homeServiceCall()
                        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.postUpdate)
                    }
                }
            }
        })
    }
    
    func requestForUpdateAPost(post: NewPostModel){
        let socialApi = SocialAPI()
        socialApi.updatePost(newpostDetails: post) { (isUpdates) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.newFollowersList.removeAll()
                self.removeFollowersList.removeAll()
                self.postDetailsViewModel.offset = 0
                self.homeServiceCall()
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.postUpdate)
            })
        }
    }
    
    /*
     Refactor Name:- Handling Observers
     Refactor Date:- 11/05/21
     Refacotr By  :- Jayaram G
     Description of Refactor:- Adding all observers at one place viewDidLoad
     */
    func addObserVerAllObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPostsData(_:)), name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTrendingPostsData(_ :)), name: NSNotification.Name(rawValue: "RefreshForYouPosts"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showViewCollections), name: NSNotification.Name(rawValue: "showViewCollectionsForPostDetails"), object: nil)
    }
    
    
}


extension PostDetailsViewController: UpdatingHomePagePosts,UpdatingHomePageSubscribePosts {
    func updatePosts() {
        
    }
    
    
    /*
     Bug Name:- follow button not work properly
     Fix Date:- 25/03/2021
     Fixed By:- Nikunj C
     Description of Fix:- delegate methods
     */
    
    func updateSubscribePosts(cellIndex: Int, subscribe: Int) {
        if self.postDetailsCollectionView.isHidden{
            self.postDetailsViewModel.forYouPostsModelArray[cellIndex].isSubscribed = subscribe
            self.forYouPostsCollectionView.reloadData()
        }
    }
    
    func updatePosts(cellIndex:Int,followStatus:Bool) {
        
        if self.postDetailsCollectionView.isHidden{
            self.postDetailsViewModel.forYouPostsModelArray[cellIndex].isFollowing = followStatus
            self.forYouPostsCollectionView.reloadData()
        }else{
            self.newFollowersList.removeAll()
            self.removeFollowersList.removeAll()
            self.postDetailsViewModel.offset = 0
            self.homeServiceCall()
        }
        
    }
}


extension PostDetailsViewController: PostDetailsControllerDelegate{
    func playVideo() {
        self.startVideoPlayer()
    }
    
 
    func editPost() {
            let data:SocialModel!
            data = postDetailsViewModel.socialModelArray[currentIndex]
            
        let shareVc = CreatePostViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.CreatePost) as CreatePostViewController
            shareVc.hidesBottomBarWhenPushed = true
            self.navigationController?.isNavigationBarHidden = false
            shareVc.updateDeleagetObj = self
            shareVc.mediaPath = data.imageUrl!
            if let businessPostTypeId = data.businessProfileObj?.businessPostType{
                shareVc.postTypeId = businessPostTypeId
            }
            if let businessPostType = data.businessProfileObj?.businessPostTypeName {
                shareVc.postType = businessPostType
            }
            if let businessLinkObj = data.businessProfileObj?.businessUrl {
                shareVc.businessLink = businessLinkObj
            }
            
            if let businessPriceObj = data.businessProfileObj?.businessPrice {
                shareVc.productPrice = businessPriceObj
            }
            
            if let businessButtonTextObj = data.businessProfileObj?.businessButtonText {
                shareVc.businessButtonText = businessButtonTextObj
            }
            
            
            if data.mediaType == 1{
                shareVc.isForVideo = true
                if let modelData = data.mediaData {
                    shareVc.selectedAudio = Audio(mediaModel: modelData)
                    
                }
            }else{
                shareVc.isForVideo = false
            }
            shareVc.isEdit = true
            shareVc.socialModel = data
            
            shareVc.editPostCallback = { model in
                self.postDetailsViewModel.socialModelArray[self.currentIndex] = model
                self.postDetailsCollectionView.reloadData()
//                 self.postDetailsCollectionView.reloadItems(at: [IndexPath.init(row: self.currentIndex, section: 0)])
            }
            
            self.navigationController?.pushViewController(shareVc, animated:true)
        }
    
    func deletePost() {
        let deleteAlert = UIAlertController(title: "Message".localized, message: "please confirm if you are sure you want to delete this post".localized + " ? " + "This action is not reversible".localized + ".", preferredStyle: .actionSheet)
        let deleteObj = UIAlertAction(title: "Delete".localized, style: .default) { (action) in
            self.deletePostService()
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in
            deleteAlert.dismiss(animated: true, completion: nil)
        })
        deleteAlert.addAction(deleteObj)
        deleteAlert.addAction(cancel)
        self.present(deleteAlert,animated: true)
        
    }
    
    func reportPost() {
        self.getReportReasons()
    }
}

extension PostDetailsViewController: updatePostDelegate {
    func updatePost(updaetedModel: NewPostModel) {
        self.requestForUpdateAPost(post: updaetedModel)
    }
}

extension PostDetailsViewController: PopularCollectionViewCellDelegate{
    func followingButtonAction(cell: PopularUserCell) {
        guard let indexPath = self.popularUserCollectionView.indexPath(for: cell) else{ return }
        let modelArray = self.postDetailsViewModel.popularUserArray
        if modelArray.count > indexPath.item{
            let modelData = modelArray[indexPath.item]
            updatePeopleModelArray(modelData: modelData, index: indexPath)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.postDetailsViewModel.offset = 0
                self.homeServiceCall()
            }
        }
    }
    
    ///To update people table view according to selected or unselected follow button and put to server
    func updatePeopleModelArray(modelData: PopularUserModel, index: IndexPath){
        if modelData.followStatus == 0{
            modelData.followStatus = 1
            self.postDetailsViewModel.FollowPeopleService(isFollow: true, peopleId: modelData.userId, privicy: 0)
        }else{
            modelData.followStatus = 0
            self.postDetailsViewModel.FollowPeopleService(isFollow: false, peopleId: modelData.userId, privicy: 0)
        }
        self.postDetailsViewModel.popularUserArray[index.item] = modelData
        self.popularUserCollectionView.reloadItems(at: [index])
    }
}

extension PostDetailsViewController: ShareMediaOptionsVCDelegate{
    func openSocialShareOptions(data: SocialModel) {
        let shareMediaVC = ShareToSocialViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.ShareToSocial) as ShareToSocialViewController
             shareMediaVC.hidesBottomBarWhenPushed = true
             shareMediaVC.postData = data
             shareMediaVC.imageArrayToVideoURL = self.imageArrayToVideoURL
             shareMediaVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            tabBarController?.present(shareMediaVC, animated: true)
    }
    
    /*
     Bug Name:- Add More options in bottom popup
     Fix Date:- 08/04/2021
     Fixed By:- jayaram G
     Description of Fix:- showing action sheet for more option
     */
    func showMoreOptions() {
        let sheet = UIAlertController(title: "More Options".localized , message: "" , preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Edit Post".localized, style: .default) { (action) in
            self.editPost()
        }
        let deletePost = UIAlertAction(title: "Delete Post".localized, style: .default) { (action) in
            self.deletePost()
        }
        let reportPost = UIAlertAction(title: "Report Post".localized, style: .default) { (action) in
            self.reportPost()
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) in
            sheet.dismiss(animated: true) {
                self.startVideoPlayer()
            }
        }
        if !self.forYouPostsCollectionView.isHidden {
            if postDetailsViewModel.forYouPostsModelArray.count > forYouPostsCurrenctIndex && forYouPostsCurrenctIndex != -1 {
                let data = postDetailsViewModel.forYouPostsModelArray[forYouPostsCurrenctIndex]
                DispatchQueue.main.async {
                    if data.userId == Utility.getUserid() {
                        sheet.addAction(editAction)
                        sheet.addAction(deletePost)
                        sheet.addAction(cancel)
                    }else{
                        sheet.addAction(reportPost)
                        sheet.addAction(cancel)
                    }
                }
            }
        }else if !self.postDetailsCollectionView.isHidden {
            if postDetailsViewModel.socialModelArray.count > currentIndex &&  currentIndex != -1{
                let data = postDetailsViewModel.socialModelArray[currentIndex]
                DispatchQueue.main.async {
                    if data.userId == Utility.getUserid() {
                        sheet.addAction(editAction)
                        sheet.addAction(deletePost)
                        sheet.addAction(cancel)
                    }else{
                        sheet.addAction(reportPost)
                        sheet.addAction(cancel)
                    }
                }
            }
        }else {
            if postDetailsViewModel.xclusivePostsModelArray.count > xClusivePostsCurrentIndex &&  xClusivePostsCurrentIndex != -1{
                let data = postDetailsViewModel.xclusivePostsModelArray[xClusivePostsCurrentIndex]
                DispatchQueue.main.async {
                    if data.userId == Utility.getUserid() {
                        sheet.addAction(editAction)
                        sheet.addAction(deletePost)
                        sheet.addAction(cancel)
                    }else{
                        sheet.addAction(reportPost)
                        sheet.addAction(cancel)
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.present(sheet, animated: true, completion: nil)
        }
    }
}

extension PostDetailsViewController: SendTipCoinsViewControllerDelegate,InSufficientCoinsViewControllerDelegate {
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


/*
 Refactor Name:- Handle delegate methods for unlock and subscribe navigations
 Refactor Date:- 06/05/2021
 Refactored By:- Jayaram
 Description of Refactor:- Added unlock and subscribe delegate methods to handle data and navigations
 */

extension PostDetailsViewController: SubscribeConfirmationVCDelegate {
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
        Helper.showPI()
        for (index, data) in self.postDetailsViewModel.socialModelArray.enumerated() {
            if data.userId == userId {
                self.postDetailsViewModel.socialModelArray[index].isPurchased = 1
                let updatedUrl = self.postDetailsViewModel.socialModelArray[index].imageUrl?.replace(target: "e_blur:2000,o_80,/", withString: "")
                self.postDetailsViewModel.socialModelArray[index].imageUrl = updatedUrl
            }
        }
        
        self.postDetailsCollectionView.reloadData()
        for (index, data) in self.postDetailsViewModel.forYouPostsModelArray.enumerated() {
            if data.userId == userId {
                self.postDetailsViewModel.forYouPostsModelArray[index].isPurchased = 1
                let updatedUrl = self.postDetailsViewModel.forYouPostsModelArray[index].imageUrl?.replace(target: "e_blur:2000,o_80,/", withString: "")
                self.postDetailsViewModel.forYouPostsModelArray[index].imageUrl = updatedUrl
            }
        }
        self.forYouPostsCollectionView.reloadData()
        for (index, data) in self.postDetailsViewModel.xclusivePostsModelArray.enumerated() {
            if data.userId == userId {
                self.postDetailsViewModel.xclusivePostsModelArray[index].isPurchased = 1
                let updatedUrl = self.postDetailsViewModel.xclusivePostsModelArray[index].imageUrl?.replace(target: "e_blur:2000,o_80,/", withString: "")
                self.postDetailsViewModel.xclusivePostsModelArray[index].imageUrl = updatedUrl
            }
        }
        self.xclusiveCollectionView.reloadData()
        Helper.hidePI()
        self.refreshPostsData(self)
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
    


}

extension PostDetailsViewController:UnLockPostConfirmationViewControllerDelegate{
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
        if self.followingPostsBtnOutlet.isSelected {
            if self.postDetailsViewModel.socialModelArray.count > index {
                if var imageUrl = self.postDetailsViewModel.socialModelArray[index].imageUrl {
                    imageUrl = imageUrl.replace(target: "/e_blur:2000,o_80,", withString: "")
                    self.postDetailsViewModel.socialModelArray[index].imageUrl = imageUrl
                }
                if var thumbnilImageUrl = self.postDetailsViewModel.socialModelArray[index].thumbnailUrl {
                    thumbnilImageUrl = thumbnilImageUrl.replace(target: "/e_blur:2000,o_80,", withString: "")
                    self.postDetailsViewModel.socialModelArray[index].thumbnailUrl = thumbnilImageUrl
                }
                self.postDetailsViewModel.socialModelArray[index].isPurchased = 1
                self.postDetailsCollectionView.reloadData()
            }
        }else if self.forYouPostsBtnOutlet.isSelected {
            if self.postDetailsViewModel.forYouPostsModelArray.count > index {
                if var imageUrl = self.postDetailsViewModel.forYouPostsModelArray[index].imageUrl {
                    imageUrl = imageUrl.replace(target: "/e_blur:2000,o_80,", withString: "")
                    self.postDetailsViewModel.forYouPostsModelArray[index].imageUrl = imageUrl
                }
                if var thumbnilImageUrl = self.postDetailsViewModel.forYouPostsModelArray[index].thumbnailUrl {
                    thumbnilImageUrl = thumbnilImageUrl.replace(target: "/e_blur:2000,o_80,", withString: "")
                    self.postDetailsViewModel.forYouPostsModelArray[index].thumbnailUrl = thumbnilImageUrl
                }
                self.postDetailsViewModel.forYouPostsModelArray[index].isPurchased = 1
                self.forYouPostsCollectionView.reloadData()
            }
        }else if self.xclusivePostsButton.isSelected {
            if self.postDetailsViewModel.xclusivePostsModelArray.count > index {
                if var imageUrl = self.postDetailsViewModel.xclusivePostsModelArray[index].imageUrl {
                    imageUrl = imageUrl.replace(target: "/e_blur:2000,o_80,", withString: "")
                    self.postDetailsViewModel.xclusivePostsModelArray[index].imageUrl = imageUrl
                }
                if var thumbnilImageUrl = self.postDetailsViewModel.xclusivePostsModelArray[index].thumbnailUrl {
                    thumbnilImageUrl = thumbnilImageUrl.replace(target: "/e_blur:2000,o_80,", withString: "")
                    self.postDetailsViewModel.xclusivePostsModelArray[index].thumbnailUrl = thumbnilImageUrl
                }
                self.postDetailsViewModel.xclusivePostsModelArray[index].isPurchased = 1
                self.xclusiveCollectionView.reloadData()
            }
        }
    }
}

extension PostDetailsViewController:TipSentVCDelegate {
    
    func updateWallet() {
        self.updateWalletData()
    }
}

//extension PostDetailsViewController: GADFullScreenContentDelegate{
//
//    func presentAD(){
//        if interstitial != nil {
//            do{
//                try interstitial?.canPresent(fromRootViewController: self)
//            }catch{
//                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
//            }
//
//            interstitial?.present(fromRootViewController: self)
//          } else {
//            print("Ad wasn't ready")
//            loadGoogleAd()
//          }
//    }
//
//    func loadGoogleAd(){
//        let request = GADRequest()
//        GADInterstitialAd.load(withAdUnitID:"",
//                               request: request,
//                               completionHandler: { [self] ad, error in
//                                if let error = error {
//                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
//                                    return
//                                }
//                                interstitial = ad
//            self.interstitial?.fullScreenContentDelegate = self
//                               }
//        )
//    }
//
//    /// Tells the delegate that the ad failed to present full screen content.
//      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
//        print("Ad did fail to present full screen content.")
//      }
//
//      /// Tells the delegate that the ad presented full screen content.
//      func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("Ad did present full screen content.")
//      }
//
//      /// Tells the delegate that the ad dismissed full screen content.
//      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("Ad did dismiss full screen content.")
//          interstitial = nil
//      }
//}
