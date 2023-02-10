//
//  GiftDisplayView.swift
//  Live
//
//  Created by leo on 16/7/15.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import Kingfisher

class GiftDisplayView: XibBasedView {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var coinsText: UILabel!
    @IBOutlet weak var giftName: UILabel!
    
    var currentCombo = 0
    var initialGiftEvent: GiftEvent! {
        didSet {
            /*
             Bug Name:- Need to show coin values
             Fix Date:- 16/06/21
             Fix By  :- Jayaram G
             Description of Fix:- Added coin ui , and showing username and gift name also
             */
            coinsText.text = "\(initialGiftEvent.coins) Coins"
            self.giftName.text = initialGiftEvent.name
            Helper.addedUserImage(profilePic: initialGiftEvent.userImage, imageView: userImageView, fullName: initialGiftEvent.userName ?? "P")
            textLabel.text = initialGiftEvent.userName
            self.imageView.kf.setImage(with: URL(string: initialGiftEvent.image),
                                         placeholder:UIImage.init(named: "Group 302"),
                                         options: [.transition(ImageTransition.fade(1))],
                                         progressBlock: { receivedSize, totalSize in
            },
                                         completionHandler: { image, error, cacheType, imageURL in
                                            if error == nil{
                                             
                                            }
                                            
            })
        }
    }
    
    var finalCombo = 0
    var timer: Timer?
    
    var lastEventTime: TimeInterval!
    var maximumStaySeconds: TimeInterval = 5
    
    var needsDismiss: ((_ view: GiftDisplayView) -> ())!
    
    override func load() {
        super.load()
        textContainer.layer.cornerRadius = 16
    }

    func startAnimateCombo() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(GiftDisplayView.tick(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func prepareForReuse() {
        currentCombo = 0
        finalCombo = 0
    }
    
    
    @objc func tick(_ timer: Timer) {
        let now = Date().timeIntervalSince1970
        guard (now - lastEventTime) < maximumStaySeconds else {
            self.timer?.invalidate()
            self.timer = nil
            needsDismiss(self)
            return
        }
        guard finalCombo > currentCombo else {
            return
        }
        self.currentCombo += 1
    }
}
