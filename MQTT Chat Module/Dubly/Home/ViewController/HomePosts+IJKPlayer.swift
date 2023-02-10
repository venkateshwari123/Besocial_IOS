//
//  HomePosts+IJKPlayer.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 14/07/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
import IJKMediaFramework

extension PostDetailsViewController{
    
    
    func addNotificationCenterObserversForIJKPlayer() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.startAgainPlaying), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.currentIJKPlayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playingStateChange), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.IJKPlayerPreparedToPlayDidChange), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.IJKPlayerPlayerLoadStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: nil)
        
        
        // background event
        NotificationCenter.default.addObserver(self, selector: #selector(stopVideoPlayer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // foreground event
        NotificationCenter.default.addObserver(self, selector: #selector(startVideoPlayer), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // add these 2 notifications to prevent freeze on long Home button press and back
        NotificationCenter.default.addObserver(self, selector: #selector(stopVideoPlayer), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startVideoPlayer), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func removeNotificationCenterObserversForIJKPlayer(){
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
    }
    @objc func IJKPlayerPreparedToPlayDidChange(){
        print("PLAYING DID CHANGE :")
        if let player = self.currentIJKPlayer{
            let size =  player.naturalSize
            if size.height > size.width{
                self.currentIJKPlayer?.scalingMode = .aspectFit
            }else{
                self.currentIJKPlayer?.scalingMode = .aspectFit
            }
        }
    }
    
    
    @objc func IJKPlayerPlayerLoadStateDidChange(){
        print("playing loadState : \(self.currentIJKPlayer?.loadState.rawValue ?? 0)")
//        if self.currentIJKPlayer?.loadState.rawValue == 3{
//         if followingPostsBtnOutlet.isSelected, let visibleCell = self.postCollectionViewCurrentVisibleCellInCenter().1{
////             visibleCell.videoBufferingIndicatorView.stopAnimating()
//         }else if forYouPostsBtnOutlet.isSelected , let visibleCell = self.trendingCollectionViewCurrentVisibleCellInCenter().1  {
//           //  visibleCell.videoBufferingIndicatorView.stopAnimating()
//         }
//         }
//       else if self.currentIJKPlayer?.loadState.rawValue == 4{
//        if followingPostsBtnOutlet.isSelected, let visibleCell = self.postCollectionViewCurrentVisibleCellInCenter().1, self.currentIJKPlayer?.currentPlaybackTime != 0{
//           // visibleCell.videoBufferingIndicatorView.startAnimating()
//        }else if forYouPostsBtnOutlet.isSelected , let visibleCell = self.trendingCollectionViewCurrentVisibleCellInCenter().1, self.currentIJKPlayer?.currentPlaybackTime != 0  {
//          //  visibleCell.videoBufferingIndicatorView.startAnimating()
//        }
//        }
    }
    
    /// To monitor player status changed
    @objc func playingStateChange(_ notification : Notification){
        guard let currentPlayer = self.currentIJKPlayer else{return}
        switch currentPlayer.playbackState {
        case .playing:
            perform(#selector(viewCountUpdate), with: nil, afterDelay: 3.1)
            print("PLAY fpsInMeta : \(self.currentIJKPlayer!.fpsInMeta)")
            print("PLAY fpsAtOutput : \(self.currentIJKPlayer!.fpsAtOutput)")
            if currentPlayer.monitor.httpCode == 200,(currentPlayer.monitor.httpUrl != nil){
             //   self.playVideoPlayerFromStoppedState()
            }
            break
        case .stopped:
            print("ERROR ON PLAY STOPPED")
            break
        case .interrupted:
            print("ERROR ON PLAY INTERUPPTED")
            break
        case .paused:
           if !currentPlayer.isPlaying(),!isVideoPaused, (currentPlayer.monitor.httpUrl != nil){
               print("ERROR ON PLAY AGAIN")
//                self.playVideoPlayerFromStoppedState()
               return
           }
           print("ERROR ON MIGHT BE PAUSE")
            break
        case .seekingForward, .seekingBackward:
            print("SEEKING STARTED")
            break
        @unknown default:
            print("nothing here")
            break
        }
    }
    
    
    /// To stop playing video
    @objc  func stopVideoPlayer(){
        self.currentIJKPlayer?.stop()
    }
    
    
    /// To start playing video from starting
    @objc internal func startVideoPlayer(){
        if let play = self.currentIJKPlayer{
            if #available(iOS 10.0, *) {
                if play.playbackState == .paused, isViewVisible, !isVideoPaused{
                    play.play()
                }
                else if play.playbackState == .stopped,isViewVisible{
                    self.playVideoPlayerFromStoppedState()
                }
            }
        }
    }
    
    
    @objc func startAgainPlaying(_ notification : Notification){
            if let info = notification.userInfo, let reason = info[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? Int{
             
                switch IJKMPMovieFinishReason.init(rawValue:reason ){
                    
                case .playbackEnded :
                    guard let currentPlayer = self.currentIJKPlayer, isViewVisible, currentPlayer.isPreparedToPlay  else{return}
                    viewCountUpdate()
                    DispatchQueue.main.async {
                        currentPlayer.currentPlaybackTime = 0;
                        if (!currentPlayer.isPlaying()) {
                            currentPlayer.play()
                        }
                    }
                  
                    print("playbackEnded")
                case .userExited :
                    print("userExited")
                case .playbackError :
                    self.playVideoPlayerFromStoppedState()
                    print("playbackError")
                
                default :
                    print("playbackPlayBackDidFinish")
                    
                }
                
            }
        }
    
    
    /// To prepare and play video when cell is visiable
    ///
    /// - Parameters:
    ///   - cell: visiable cell
    ///   - indexPath: index path of visiable cell
    func playVideoOnTheCell( cellType : HomeFeedCellType = .FollowingPosts, cell : HomeFeedCollectionViewCell, indexPath : IndexPath,checkCurrentPlayingCondition:Bool = true, isFromWillDisplay : Bool = false){
        
        if !isFromWillDisplay{
            print("*****Not FROMWILL DISPLAY****")
        }
        
        var data : SocialModel
        switch cellType{
        case.FollowingPosts :
            if let currentIndexPath = currentPlayingIndexPath, currentIndexPath == indexPath,checkCurrentPlayingCondition{
                if !(cell.postImageView.subviews.contains(where: {
                    $0.isKind(of: UIView.self) && !$0.isKind(of: UIActivityIndicatorView.self)
                })){
                    if let videoView = (currentIJKPlayer?.view){
                    cell.postImageView.addSubview(videoView)
                    }
                }
                return
            }
            currentIndex = indexPath.row
            currentPlayingIndexPath = indexPath
            guard self.postDetailsViewModel.socialModelArray.count > indexPath.row else {
                return
            }
            data = self.postDetailsViewModel.socialModelArray[indexPath.row]
        case .TrendingPosts :
            
            if let currentIndexPath = forYouCurrentPlayingIndexPath, currentIndexPath == indexPath,checkCurrentPlayingCondition{
                if !(cell.postImageView.subviews.contains(where: {
                    $0.isKind(of: UIView.self) && !$0.isKind(of: UIActivityIndicatorView.self)
                })){
                    if let videoView = (currentIJKPlayer?.view){
                    cell.postImageView.addSubview(videoView)
                    }
                }
                return
            }
            
            forYouCurrentPlayingIndexPath = indexPath
            forYouPostsCurrenctIndex = indexPath.row
            guard self.postDetailsViewModel.forYouPostsModelArray.count > indexPath.row else {
                return
            }
            data = self.postDetailsViewModel.forYouPostsModelArray[indexPath.row]
        case .ExclusivePosts :
            if let currentIndexPath = currentIndexPathForXclusive, currentIndexPath == indexPath,checkCurrentPlayingCondition{
                if !(cell.postImageView.subviews.contains(where: {
                    $0.isKind(of: UIView.self) && !$0.isKind(of: UIActivityIndicatorView.self)
                })){
                    if let videoView = (currentIJKPlayer?.view){
                    cell.postImageView.addSubview(videoView)
                    }
                }
                return
            }
            currentIndexPathForXclusive = indexPath
            xClusivePostsCurrentIndex = indexPath.row
            guard self.postDetailsViewModel.xclusivePostsModelArray.count > indexPath.row else {
                return
            }
            data = self.postDetailsViewModel.xclusivePostsModelArray[indexPath.row]
        }
            //Pause video and remove player from super if mdeia is image
        if self.currentIJKPlayer != nil, (self.currentIJKPlayer!.isPreparedToPlay || self.currentIJKPlayer!.isPlaying() || self.currentIJKPlayer!.playbackState == .stopped || self.currentIJKPlayer!.playbackState == .playing || self.currentIJKPlayer!.playbackState == .paused || self.currentIJKPlayer!.playbackState == .seekingForward  || self.currentIJKPlayer!.playbackState == .seekingBackward){
                
                print("***playbackState Playing :\(self.currentIJKPlayer!.playbackState == .playing)")
                print("***seekingForward :\(self.currentIJKPlayer!.playbackState == .seekingForward)")
                print("***seekingBackward :\(self.currentIJKPlayer!.playbackState == .seekingBackward)")
                print("***STATE\(self.currentIJKPlayer!.playbackState)")
            self.currentIJKPlayer?.shutdown()
            }
        
        if self.currentIJKPlayer != nil,self.currentIJKPlayer!.monitor.httpUrl == cell.videoUrl?.absoluteString{
            
            print("***SAME URL :\(self.currentIJKPlayer!.monitor.httpUrl ?? "")")
        }
            self.currentIJKPlayer?.view.removeFromSuperview()
            self.currentIJKPlayer = nil
            if data.mediaType == 0{
                return
            }
            cell.musicImageView.startRotating()
            guard let url = cell.videoUrl else{
                return
            }
            if isViewVisible{
                self.play(url, cell: cell)
            }
            
    }
    

    fileprivate func play(_ url: URL?, cell: HomeFeedCollectionViewCell) {
        let options = IJKFFOptions.byDefault()
        options?.setCodecOptionValue("8", forKey: "skip_loop_filter")
        options?.setCodecOptionValue("8", forKey: "skip_frame")
        
        //         options?.setOptionIntValue(100, forKey: "analyzemaxduration", of: kIJKFFOptionCategoryFormat)
        //               options?.setOptionIntValue(10240, forKey: "probesize", of: kIJKFFOptionCategoryFormat)
        //     options?.setOptionIntValue(1, forKey: "flush_packets", of: kIJKFFOptionCategoryFormat)
        //          options?.setOptionValue("nobuffer", forKey: "fflags", of: kIJKFFOptionCategoryFormat)
        //             options?.setOptionIntValue(1, forKey: "videotoolbox", of: kIJKFFOptionCategoryPlayer)
        options?.setOptionIntValue(0, forKey: "packet-buffering", of: kIJKFFOptionCategoryPlayer)
        options?.setOptionIntValue(1, forKey: "framedrop", of: kIJKFFOptionCategoryPlayer)
        options?.setCodecOptionIntValue(1, forKey: "auto_convert")
        
        
        options?.setPlayerOptionIntValue(0, forKey: "seek-at-start")
        //        options?.setPlayerOptionIntValue(0, forKey: "first-high-water-mark-ms")
        //        options?.setPlayerOptionIntValue(10 * 1000, forKey: "next-high-water-mark-ms")
        //        options?.setPlayerOptionIntValue(20 * 1000, forKey: "last-high-water-mark-ms")
        options?.setPlayerOptionIntValue(0, forKey: "min-frames")
        options?.setPlayerOptionIntValue((10 * 1024 * 1024), forKey: "max-buffer-size")
        
        //    options?.setCodecOptionIntValue(24, forKey: "max-fps")
        
        //
        //        options?.setPlayerOptionValue("fcc-i420", forKey: "overlay-format")
        //        options?.setPlayerOptionIntValue(0, forKey: "framedrop")
        //        options?.setPlayerOptionIntValue(1, forKey: "max-fps")
        //        options?.setPlayerOptionIntValue(0, forKey: "find_stream_info-fps")
        //
        //        options?.setFormatOptionIntValue(5232493008, forKey: "ijkinject-opaque")
        //        options?.setFormatOptionIntValue(0, forKey: "safe")
        //        options?.setFormatOptionIntValue(1, forKey: "reconnect")
        //        options?.setFormatOptionIntValue(0, forKey: "auto_convert")
        //        options?.showHudView = true
        //        self.player?.shouldShowHudView = true
        //
        let player = IJKFFMoviePlayerController(contentURL: url!, with: options)
        player?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player?.view.frame = cell.postImageView.bounds
        player?.scalingMode = .aspectFill
        player?.shouldAutoplay = true
        cell.autoresizesSubviews = true
        cell.muteBtn.isSelected = self.audioPaused
        if self.audioPaused {
            player?.playbackVolume = 0.0
        }else{
            player?.playbackVolume = 1.0
        }
        currentIJKPlayer = player
        cell.postImageView.addSubview((player?.view)!)
        player?.prepareToPlay()
    }
    
}


extension AVAsset {
    
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let imageGenerator = AVAssetImageGenerator(asset: self)
            let time = CMTime(seconds: 0.0, preferredTimescale: 600)
            let times = [NSValue(time: time)]
            imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                if let image = image {
                    completion(UIImage(cgImage: image))
                } else {
                    completion(nil)
                }
            })
        }
    }
}

enum HomeFeedCellType : Int{
    case FollowingPosts
    case TrendingPosts
    case ExclusivePosts
}
