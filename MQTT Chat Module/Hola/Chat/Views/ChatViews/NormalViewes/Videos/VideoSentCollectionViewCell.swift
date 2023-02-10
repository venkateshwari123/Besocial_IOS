//
//  VideoSentCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 29/01/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import UICircularProgressRing
class VideoSentCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var videoTappedOutlet: UIButton!
    @IBOutlet weak var retryButtonOutlet: UIButton!
    @IBOutlet weak var videoThumbnailViewOutlet: UIImageView!
    @IBOutlet weak var circlularProgressIndicator: UICircularProgressRing!
    @IBOutlet weak var forwardButtonOutlet: UIButton!
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    @IBOutlet weak var senderImageView: UIImageView!
    /// tells that user is replying for a message.
    var isReplying : Bool?
    
    /// If isReplying == true then this will be the message you are going to reply.
    var replyMsg : Message?
    
    var videoTappedDelegate : VideoCellTappedDelegate? = nil
    var chatDocID : String!
    var msgVMObj : VideoMessageViewModal! {
        didSet {
            self.setVideo()
            switch msgVMObj.mediaState {
            case .notUploaded:
                ///For uploading video in background thread. Added in conurrent dispatch queue task
                
                DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.msgVMObj.uploadVideos(withChatDocID: strongSelf.chatDocID, isReplying: strongSelf.isReplying, replyMsg: strongSelf.replyMsg, progress: { (progress) in
                        DispatchQueue.main.async {
                            strongSelf.showUploading(withProgress : progress)
                        }
                    }, Uploadcompletion:{ isUploaded in
                        if isUploaded {
                            DispatchQueue.main.async {
                                strongSelf.hideUploading(withSuccess: true)
                                strongSelf.retryButtonOutlet.isHidden = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                strongSelf.hideUploading(withSuccess: false)
                                /// Show retry button.
                                strongSelf.retryButtonOutlet.isHidden = false
                            }
                        }
                    })
                }
                
            default:
                break;
            }
        }
    }
    
    private func showUploading(withProgress progress : Progress) {
        let pgValue = progress.fractionCompleted*100
        if progress.fractionCompleted == 1 {
            self.circlularProgressIndicator.isHidden = true
        } else {
            self.circlularProgressIndicator.isHidden = false
            self.circlularProgressIndicator.startProgress(to: CGFloat(pgValue), duration: 1)
        }
    }
    
    private func setVideo() {
        self.setVideoFromCache(withChatDocID : self.chatDocID)
    }
    
    private func setVideoFromCache(withChatDocID chatDocID: String ) {
        self.msgVMObj.getVideo(withChatDocID: chatDocID, Completion:{ (img, vid) in
            if let image = img {
                DispatchQueue.main.async {
                    self.videoThumbnailViewOutlet.image = image
                }
            } else {
                // Video and Image not found locally.
                self.downloadVideo()
            }
        })
    }
    
    func downloadVideo() {
        if let videoURL = msgVMObj.message.messagePayload {
            DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                // Have to add thumbnail from the message object.
                // Have to store video locally
                // Have to store local path to "mediaUrl" key in message object
                // Change the state of the message also
            }
        }
    }
    
    private func hideUploading(withSuccess isSucceeded: Bool) {
        self.circlularProgressIndicator.isHidden = true
        if isSucceeded {
            // Update this message as uploaded.
            self.retryButtonOutlet.isHidden = true
        } else {
            // Update this message as not uploaded.
            self.retryButtonOutlet.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteOptions(_:)))
        longPress.minimumPressDuration = 1.0
        self.videoTappedOutlet.addGestureRecognizer(longPress)

    }
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func deleteOptions(_ gesture: UILongPressGestureRecognizer){
        print("doubletapped")
        deleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgVMObj.message)
    }
    
    @IBAction func videoTappedAction(_ sender: UIButton) {
        if let delegate = videoTappedDelegate {
            delegate.videoCellTapped(withVideoMVModal: msgVMObj)
        }
    }
    
    @IBAction func retryButtonAction(_ sender: UIButton) {
        self.retryButtonOutlet.isHidden = true
        self.msgVMObj.retryUploadingVideo(withChatDocID: self.chatDocID, andProgress: { (progress) in
            self.showUploading(withProgress : progress)
        }, completion:{ isUploaded in
            if (isUploaded != nil) {
                self.hideUploading(withSuccess: true)
                /// Set status to uploaded.
            } else {
                self.hideUploading(withSuccess: false)
                /// Set status again to not uploaded. And show retry button.
            }
        })
    }
    
    @IBAction func forwardButtonAction(_ sender: UIButton) {
        self.videoTappedDelegate?.videoForwardActionCliked(self)
    }
}

extension VideoSentCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
    func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell) {
    }
    
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: JSQMessagesCollectionViewCell) {
        
    }
    
    func messagesCollectionViewCellDidTap(_ cell: JSQMessagesCollectionViewCell, atPosition position: CGPoint) {
        
    }
    
    func messagesCollectionViewCell(_ cell: JSQMessagesCollectionViewCell, didPerformAction action: Selector, withSender sender: Any) {
        if let collectionView = self.superview as? UICollectionView {
            if let indexPath = collectionView.indexPathForItem(at: self.center) {
                collectionView.delegate?.collectionView!(collectionView, performAction: action, forItemAt: indexPath, withSender: nil)
            }
        }
    }
    
    func messagesCollectionViewCellDidTapAccessoryButton(_ cell: JSQMessagesCollectionViewCell) {
        
    }
}

/// SentVideoMediaItem inherites the JSQMessageMediaData properties
class SentVideoMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of SentLocationCell
    let videoCell = VideoSentCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 290, height: 200))
    
    func mediaView() -> UIView? {
        return videoCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return videoCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 290, height: 200)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
