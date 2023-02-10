//
//  ShowMediaCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 19/02/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit

protocol playButtonActionDelegate {
    func playButtonPressed(withURLString : String)
}

class ShowMediaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var showMediaImageView: AnimatedImageView!
    @IBOutlet weak var playButtonOutlet: UIButton!
    
    var playButtonDelegate : playButtonActionDelegate? = nil
    fileprivate var player : AVPlayer?
    fileprivate var playerLayer : AVPlayerLayer?
    
    var videoURL : String?
    
    var msgObject : Message! {
        didSet {
            self.playButtonOutlet.isHidden = true
            self.contentView.backgroundColor = .clear
            if msgObject.messageType == MessageTypes.video {
                if let tData = msgObject.thumbnailData {
                    self.showMediaImageView.image = #imageLiteral(resourceName: "defaultPicture")
                    DispatchQueue.global(qos: .default).async {
                        let tdata = tData.replace(target: "\n", withString: "")
                        if let tImage = Image.convertBase64ToImage(base64String: tdata), let mediaUrl = self.msgObject.getFilePath() {
                            self.videoURL = mediaUrl
                            DispatchQueue.main.async {
                                self.showMediaImageView.image = tImage
                                self.playButtonOutlet.isHidden = false
                            }
                        }
                    }
                }
            } else if msgObject.messageType == MessageTypes.image || msgObject.messageType == MessageTypes.gif  || msgObject.messageType == MessageTypes.doodle {
                if msgObject.messageType == MessageTypes.doodle {
                    self.contentView.backgroundColor = .white
                } else {
                    self.contentView.backgroundColor = .clear
                }
                if var msgUrl = msgObject.messagePayload {
                    if msgUrl == "" {
                        if let msgUrlObj = msgObject.mediaURL?.fromBase64(){
                        msgUrl =  msgUrlObj
                        }
                     }
                    if let url = URL(string : msgUrl) {
                        self.showMediaImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "defaultPicture"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, cache, currentUrl) in
                            DispatchQueue.main.async {
                                self.showMediaImageView.image = image
                                self.showMediaImageView.startAnimating()
                            }
                        })
                        DispatchQueue.main.async {
                            self.playButtonOutlet.isHidden = true
                        }
                    } else {
                        let imageMMVObj = ImageMessageViewModal(withMessage: msgObject)
                        imageMMVObj.getImage(withCompletion: { (image) in
                            DispatchQueue.main.async {
                                self.showMediaImageView.image = image
                            }
                        })
                    }
                }
            } else if msgObject.messageType == MessageTypes.replied {
                if let repliedMsg = msgObject.repliedMessage {
                    if let rMsgType = repliedMsg.replyMessageType {
                        if rMsgType == MessageTypes.video {
                            if let tData = msgObject.thumbnailData {
                                self.showMediaImageView.image = #imageLiteral(resourceName: "defaultPicture")
                                DispatchQueue.global(qos: .default).async {
                                    let tdata = tData.replace(target: "\n", withString: "")
                                    if let tImage = Image.convertBase64ToImage(base64String: tdata), let mediaUrl = self.msgObject.getFilePath() {
                                        self.videoURL = mediaUrl
                                        DispatchQueue.main.async {
                                            self.showMediaImageView.image = tImage
                                            self.playButtonOutlet.isHidden = false
                                        }
                                    }
                                }
                            }
                        } else if rMsgType == MessageTypes.image || rMsgType == MessageTypes.gif  || rMsgType == MessageTypes.doodle {
                            if rMsgType == MessageTypes.doodle {
                                self.contentView.backgroundColor = .white
                            } else {
                                self.contentView.backgroundColor = .clear
                            }
                            if let msgUrl = msgObject.messagePayload {
                                if let url = URL(string : msgUrl) {
                                    self.showMediaImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "defaultPicture"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, cache, currentUrl) in
                                        DispatchQueue.main.async {
                                            self.showMediaImageView.image = image
                                            self.showMediaImageView.autoPlayAnimatedImage = true
                                        }
                                    })
                                    DispatchQueue.main.async {
                                        self.playButtonOutlet.isHidden = true
                                    }
                                }
                                else {
                                    let imageMMVObj = ImageMessageViewModal(withMessage: msgObject)
                                    imageMMVObj.getImage(withCompletion: { (image) in
                                        DispatchQueue.main.async {
                                            self.showMediaImageView.image = image
                                            self.showMediaImageView.autoPlayAnimatedImage = true
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getRepliedMediaType(fromMessage msg: Message) -> MessageTypes? {
        if let msgType = msg.messageType {
            switch msgType {
            case .replied:
                if let repliedMsg = msg.repliedMessage {
                    if let rMsgType = repliedMsg.replyMessageType {
                        return rMsgType
                    }
                }
            default:
                return msgType
            }
        }
        return nil
    }
    
    @IBAction func videoButtonAction(_ sender: Any) {
        if let delegate = self.playButtonDelegate, let mediaUrl = self.msgObject.getFilePath() {
            delegate.playButtonPressed(withURLString: mediaUrl)
        }
    }
}
