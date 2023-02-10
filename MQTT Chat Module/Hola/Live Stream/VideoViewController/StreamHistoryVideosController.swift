//
//  StreamHistoryVideosController.swift
//  PicoAdda
//
//  Created by 3Embed on 14/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import IJKMediaFramework

class StreamHistoryVideosController: UIViewController {

    @IBOutlet weak var streamVideoBackGroundView: UIView!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var streamVideoImageView: UIImageView!
    @IBOutlet weak var viewForSegProgress: UIView!

    var streamVideoModelData:LiveVideosModel!
    var player:IJKFFMoviePlayerController!
    var isNeedToStart: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeDownDismiss()
        playVideoForCurrentUser(videoView: streamVideoBackGroundView)
        self.streamVideoImageView.setImageOn(imageUrl: streamVideoModelData.video,defaultImage: #imageLiteral(resourceName: "defaultPicture"))
    }
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- check connectivity and show popup for no internet
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.checkConnectionAvaibility(view: self.view)

    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if((player) != nil) {
            player?.pause()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func addSwipeDownDismiss() {
        //adding down gesture to view for dismissing view controller.
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.streamVideoBackGroundView.addGestureRecognizer(swipeDown)
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
    
    func dismissVc() {
        self.dismiss(animated:true, completion:nil)
    }
    
    
    
    func playVideoForCurrentUser(videoView:UIView) {
            DispatchQueue.main.async{ [weak self] in
                self?.showVideoForUrl(videoUrl: (self?.streamVideoModelData.video)! , viewForVideo: self!.streamVideoBackGroundView)
            }
     }
    
    
    
    
    func showVideoForUrl(videoUrl:String,viewForVideo:UIView) {
        if(videoUrl.count > 5) {
            
            let url = URL(string:videoUrl)
            let options = IJKFFOptions.byDefault()
            self.player = IJKFFMoviePlayerController(contentURL: url!, with: options)
            self.player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.player.view.frame = viewForVideo.bounds
            self.player.scalingMode = .aspectFill
            //        cell.autoresizesSubviews = true
            viewForVideo.addSubview((self.player.view)!)
            
//            let center = NotificationCenter.default
//            let mainQueue = OperationQueue.main
//            center.addObserver(forName: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil, queue: mainQueue) { (notification) in
//                self.playingStateChange()
//            }
                        self.player.prepareToPlay()
                        self.isNeedToStart = true
                        self.pauseStatusBar(isPaused: false)
            player?.play()
        } else {
            // ProfileView.userProfileImage.isHidden = false
        }
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
                        print("Stop playing")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
            break
        case .interrupted:
                        print("playing Interrupted")
            break
        case .paused:
                        print("playing pause")
            break
        case .seekingForward, .seekingBackward:
            break
        @unknown default:
            break
        }
    }
    
    
    
    fileprivate func pauseStatusBar(isPaused: Bool){
        if isPaused {
            for subView in self.viewForSegProgress.subviews {
                let layer = subView.layer
                let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                layer.speed = 0.0
                layer.timeOffset = pausedTime
            }
        } else {
            for subView in self.viewForSegProgress.subviews {
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
}
