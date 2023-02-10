//
//  ReplyView.swift
//  SwiftExample
//
//  Created by Sachin Nautiyal on 09/03/2018.
//  Copyright © 2018 MacMeDan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Kingfisher

protocol ReplyViewDismissDelegate {
    func replyViewClosedButtonSelected(_ : UIView)
    func replyMessageSelected(withMessageId :String)
}

class ReplyView: UIView {
    
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var repliedMessageOutlet: UILabel!
    @IBOutlet weak var msgImageViewOutlet: UIImageView!
    var isReplyingView = false
    
    let selfID = Utility.getUserid()
    var selectedMessage : Message! {
        didSet {
            self.addReplyMessageDetails(withMsgObj: selectedMessage)
        }
    }
    var replyViewDismissDelegate : ReplyViewDismissDelegate?
    
    @IBAction func crossButtonAction(_ sender: UIButton) {
        if let delegate = replyViewDismissDelegate {
            delegate.replyViewClosedButtonSelected(self)
        }
    }
    
    @IBAction func replyMsgButtonAction(_ sender: UIButton) {
        if let delegate = replyViewDismissDelegate, let previousID = selectedMessage.repliedMessage?.previousId {
            delegate.replyMessageSelected(withMessageId : previousID)
        }
    }
    
    func getMessageType(withMsg msgObj : Message) -> MessageTypes? {
        if isReplyingView {
            if let repliedMsg = msgObj.repliedMessage {
                return repliedMsg.replyMessageType
            } else {
                return msgObj.messageType
            }
        } else {
            if let repliedMsg = msgObj.repliedMessage {
                return repliedMsg.previousType
            } else {
                return msgObj.messageType
            }
        }
    }
    
    func setMsgType(withMsgObj : Message) {
        if isReplyingView {
            
        } else {
            
        }
    }
    
    func addReplyMessageDetails(withMsgObj msgObj: Message) {
        self.msgImageViewOutlet.isHidden = true
        self.msgImageViewOutlet.backgroundColor = UIColor.clear
        if msgObj.messageFromID == selfID {
            self.userNameOutlet.text = "You".localized
        } else {
            self.userNameOutlet.text = msgObj.senderDisplayName
        }
        if let messageMediaType : MessageTypes = self.getMessageType(withMsg: msgObj) {
            switch messageMediaType {
            case .image:
                self.setImage(fromMessage: msgObj)
                self.repliedMessageOutlet?.text = "Image".localized
                self.msgImageViewOutlet.isHidden = false
                break
                
            case .text:
                self.repliedMessageOutlet?.text = msgObj.messagePayload
                if let repliedMsg = msgObj.repliedMessage {
                    self.repliedMessageOutlet?.text = repliedMsg.previousPayload
                }
                if isReplyingView {
                    self.repliedMessageOutlet?.text = msgObj.messagePayload
                }
                break
                
            case .video:
                self.setImage(fromMessage: msgObj)
                self.repliedMessageOutlet?.text = "Video".localized
                self.msgImageViewOutlet.isHidden = false
                
            case .location:
                self.repliedMessageOutlet?.text = "Location".localized
                self.msgImageViewOutlet.isHidden = false
                self.msgImageViewOutlet.image = #imageLiteral(resourceName: "DefaultLocation")
                self.setImage(fromMessage: msgObj)
                
            case .contact:
                self.repliedMessageOutlet?.text = "Contact".localized
                
            case .audio:
                self.repliedMessageOutlet?.text = "Audio".localized
                
            case .sticker:
                self.repliedMessageOutlet?.text = "Sticker".localized
                self.msgImageViewOutlet.isHidden = false
                self.setImage(fromMessage: msgObj)
                
            case .doodle:
                self.repliedMessageOutlet?.text = "Doodle".localized
                self.msgImageViewOutlet.isHidden = false
                self.setImage(fromMessage: msgObj)
                
            case .gif:
                self.repliedMessageOutlet?.text = "Gif".localized
                self.msgImageViewOutlet.isHidden = false
                self.setImage(fromMessage: msgObj)
                
            case .document:
                self.repliedMessageOutlet?.text = "Document".localized
                self.msgImageViewOutlet.isHidden = false
                self.msgImageViewOutlet.image = #imageLiteral(resourceName: "doc_unknown")
                self.msgImageViewOutlet.backgroundColor = .white
                
            case .replied:
                if let repliedMsg = msgObj.repliedMessage {
                    if let msgRepliedType = repliedMsg.replyMessageType {
                        switch msgRepliedType {
                        case .text:
                            self.repliedMessageOutlet?.text = repliedMsg.previousPayload
                            
                        case .image:
                            self.setImage(fromMessage: msgObj)
                            self.repliedMessageOutlet?.text = "Image".localized
                            
                        case .video:
                            self.setImage(fromMessage: msgObj)
                            self.repliedMessageOutlet?.text = "Video".localized
                            
                        case .location:
                            self.repliedMessageOutlet?.text = "Location".localized
                            self.msgImageViewOutlet.image = #imageLiteral(resourceName: "DefaultLocation")
                            
                        case .contact:
                            self.repliedMessageOutlet?.text = "Contact".localized
                            
                        case .audio:
                            self.repliedMessageOutlet?.text = "Audio".localized
                            
                        case .sticker:
                            self.repliedMessageOutlet?.text = "Sticker".localized
                            self.setImage(fromMessage: msgObj)
                            
                        case .doodle:
                            self.setImage(fromMessage: msgObj)
                            self.repliedMessageOutlet?.text = "Doodle".localized
                            
                        case .gif:
                            self.repliedMessageOutlet?.text = "Gif".localized
                            self.setImage(fromMessage: msgObj)
                            
                        case .document:
                            self.repliedMessageOutlet?.text = "Document".localized
                            self.msgImageViewOutlet.backgroundColor = .white
                            self.msgImageViewOutlet.image = #imageLiteral(resourceName: "doc_unknown")
                            break
                        case .post:
                            self.setImage(fromMessage: msgObj)
                            self.repliedMessageOutlet?.text = "Post".localized
                            break
                        case .transfer:
                            self.repliedMessageOutlet?.text = "Transfer".localized
                            break
                        default :
                            break
                        }
                    }
                }
            case .deleted:
                break
            case .post:
                self.setImage(fromMessage: msgObj)
                self.repliedMessageOutlet?.text = "Post".localized
                self.msgImageViewOutlet.isHidden = false
                break
            case .transfer:
                self.repliedMessageOutlet?.text = "Transfer".localized
                break
            case .missedCallMessage:
                break
                
            case .callMessage:
                break
            }
        }
    }
    
    private func setImage(fromMessage messageObj: Message) {
        self.msgImageViewOutlet.backgroundColor = UIColor.clear
        if isReplyingView {
            if let thumbnailData = messageObj.thumbnailData {
                if messageObj.messageType == .gif || messageObj.messageType == .sticker {
                    self.msgImageViewOutlet.kf.setImage(with: URL(string :thumbnailData))
                } else {
                    if messageObj.messageType == .doodle || messageObj.messageType == .document {
                        self.msgImageViewOutlet.backgroundColor = .white
                    }
                    DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                        guard let strongSelf = self else { return }
                        let tData = thumbnailData.replace(target: "\n", withString: "")
                        if let tImage = Image.convertBase64ToImage(base64String: tData) {
                            DispatchQueue.main.async {
                                strongSelf.msgImageViewOutlet.isHidden = false
                                strongSelf.msgImageViewOutlet.image = tImage
                            }
                        }
                    }
                }
            } else if let msgUrl = messageObj.messagePayload {
                if let url = URL(string : msgUrl) {
                    self.msgImageViewOutlet.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "defaultPicture"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil) { (result) in
                    }
                }
            } else {
                let imageMMVObj = ImageMessageViewModal(withMessage: messageObj)
                imageMMVObj.getRepliedImage(withCompletion: { (image) in
                    DispatchQueue.main.async {
                        self.msgImageViewOutlet.image = image
                    }
                })
            }
        } else {
            if let repliedMsg = messageObj.repliedMessage {
                if let thumbnailData = repliedMsg.previousPayload {
                    if repliedMsg.previousType == .gif || repliedMsg.previousType == .sticker {
                        self.msgImageViewOutlet.kf.setImage(with: URL(string :thumbnailData))
                    } else {
                        if repliedMsg.previousType == .doodle || messageObj.messageType == .document {
                            self.msgImageViewOutlet.backgroundColor = .white
                        }
                        DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                            guard let strongSelf = self else { return }
                            let tData = thumbnailData.replace(target: "\n", withString: "")
                            if let tImage = Image.convertBase64ToImage(base64String: tData) {
                                DispatchQueue.main.async {
                                    strongSelf.msgImageViewOutlet.isHidden = false
                                    strongSelf.msgImageViewOutlet.image = tImage
                                }
                            }
                        }
                    }
                } else if let msgUrl = messageObj.messagePayload {
                    if let url = URL(string : msgUrl) {
                        self.msgImageViewOutlet.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "defaultPicture"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil) { (result) in
                            
                        }
                        }
                } else {
                    let imageMMVObj = ImageMessageViewModal(withMessage: messageObj)
                    imageMMVObj.getImage(withCompletion: { (image) in
                        DispatchQueue.main.async {
                            self.msgImageViewOutlet.image = image
                        }
                    })
                }
            }
        }
    }
}
