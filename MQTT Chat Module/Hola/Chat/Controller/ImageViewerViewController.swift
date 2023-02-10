//
//  ImageViewerViewController.swift
//  Yelo
//
//  Created by Sachin Nautiyal on 16/11/2017.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit
import AVFoundation

class ImageViewerViewController: UIViewController {
    
    @IBOutlet weak var progressViewOutlet: UIProgressView!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    var imageUrl : String!
    var messageType : MessageTypes!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let mediaUrl = URL(string : imageUrl) else { return }
        if messageType == MessageTypes.image {
            self.openImage(withURL: mediaUrl)
            self.imageViewOutlet.isHidden = false
        } else if messageType == MessageTypes.video {
            let mediaURL = URL(fileURLWithPath: imageUrl)
            self.playVideo(withURL: mediaURL)
            self.imageViewOutlet.isHidden = true
        }
    }
    
    private func playVideo(withURL url : URL) {
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    func openImage(withURL imageurl : URL) {
        self.imageViewOutlet.kf.setImage(with: imageurl, placeholder:UIImage(named:"itemProdDefault"), options:  [.transition(ImageTransition.fade(1))], progressBlock:
            { receivedSize, totalSize in
                let value = receivedSize/totalSize
                self.progressViewOutlet.isHidden = false
                print(value)
                self.progressViewOutlet.progress = Float(value)
        }) { (image, error, cacheType, imageUrl) in
            print("finished")
            self.progressViewOutlet.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
