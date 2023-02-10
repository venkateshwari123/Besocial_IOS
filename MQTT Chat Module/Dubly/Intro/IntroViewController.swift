//
//  WelcomeViewController.swift
//  Do Chat
//
//  Created by Rahul Sharma on 03/05/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    var avPlayer : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
    
    @IBOutlet weak var vwVideo: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
                   self.startPlayingVideo()
               }
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func startPlayingVideo(){
      guard let objPath = Bundle.main.path(forResource: "IntroVideo", ofType:"mp4") else {return}
        let videoURL = URL.init(fileURLWithPath: objPath)
        avPlayer = AVPlayer.init(url: videoURL)
        avPlayerLayer = AVPlayerLayer.init(player: avPlayer!)
        avPlayerLayer.frame = UIScreen.main.bounds
        avPlayerLayer.videoGravity = .resizeAspectFill
        vwVideo.layer.addSublayer(avPlayerLayer)
          avPlayer.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { [weak self] _ in
            self?.avPlayer?.seek(to: CMTime.zero)
            self?.avPlayer?.play()
        }
        
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.presentWelcomeController()
    }
    
    func presentWelcomeController() {
        let storyBoard = UIStoryboard.init(name: "DublyTabbar", bundle: nil)
        if UserDefaults.standard.value(forKey: AppConstants.UserDefaults.LoggedInUser) != nil {
             Utility.setIsGuestUser(status: false)
        }else{
             Utility.setIsGuestUser(status: true)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = storyBoard.instantiateViewController(withIdentifier: "DublyTabbarViewController")
        
     }
}
