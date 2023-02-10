//
//  MediaImageCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 09/02/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class MediaImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mediaImageView: AnimatedImageView!
    @IBOutlet weak var gifIconOutlet: UIImageView!
    
    var msgObject : Message! {
        didSet {
            mediaImageView.image = #imageLiteral(resourceName: "defaultPicture")
            if msgObject.messageType == MessageTypes.replied {
                if let repliedMsg = msgObject.repliedMessage {
                    if let rMsgType = repliedMsg.replyMessageType {
                        if rMsgType == MessageTypes.image || rMsgType == MessageTypes.gif  || rMsgType == MessageTypes.doodle {
                            if let msgUrl = msgObject.messagePayload {
                                if let url = URL(string : msgUrl) {
                                    self.mediaImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "defaultPicture"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, cache, currentUrl) in
                                        DispatchQueue.main.async {
                                            self.mediaImageView.image = image
                                        }
                                    })
                                }
                                else {
                                    let imageMMVObj = ImageMessageViewModal(withMessage: msgObject)
                                    imageMMVObj.getImage(withCompletion: { (image) in
                                        DispatchQueue.main.async {
                                            self.mediaImageView.image = image
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            } else {
                if var msgUrl = msgObject.messagePayload {
                    if msgUrl == "" {
                        if let msgUrlObj = msgObject.mediaURL!.fromBase64() {
                        msgUrl = msgUrlObj
                        }
                    }
                    
                    if let url = URL(string : msgUrl) {
                        mediaImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "defaultPicture"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil) { (result) in
                            
                        }
                       
                    }  else {
                        let imageMMVObj = ImageMessageViewModal(withMessage: msgObject)
                        imageMMVObj.getImage(withCompletion: { (image) in
                            DispatchQueue.main.async {
                                self.mediaImageView.image = image
                            }
                        })
                    }
                }
            }
        }
    }
}
