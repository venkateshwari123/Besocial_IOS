//
//  ImageSentCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 29/01/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import UICircularProgressRing
import Kingfisher
protocol DeleteChatMessageCellDelegate {
    func deleteChatMessage(index: IndexPath, msg: Message)
}
class ImageSentCollectionViewCell: JSQMessagesCollectionViewCell {
    
    
    @IBOutlet weak var backgrundViewOutlet: UIView!
    @IBOutlet weak var imageTappedOutlet: UIButton!
    @IBOutlet weak var retryButtonOutlet: UIButton!
    @IBOutlet weak var circlularProgressIndicator: UICircularProgressRing!
    
    @IBOutlet weak var gifViewOutlet: UIView!
    @IBOutlet weak var forwardButtonOutlet: UIButton!
    
    @IBOutlet weak var senderImageView: UIImageView!
    var imageDeleteDelegate: DeleteChatMessageCellDelegate? = nil
    /// tells that user is replying for a message.
    var isReplying : Bool?
    
    /// If isReplying == true then this will be the message you are going to reply.
    var replyMsg : Message?
    
    var imageTappedDelegate : ImageCellTappedDelegate? = nil
    var chatDocID : String!
    
    var index = IndexPath()
    @IBOutlet weak var imageViewOutlet: AnimatedImageView!
    
    var imageMsgType : MessageTypes? {
        didSet {
            if imageMsgType == .gif {
                self.gifViewOutlet.isHidden = false
                self.imageViewOutlet.autoPlayAnimatedImage = false
                self.imageViewOutlet.stopAnimating()
            } else {
                self.gifViewOutlet.isHidden = true
            }
        }
    }
    
    var msgVMObj : ImageMessageViewModal! {
        didSet {
            self.imageViewOutlet.autoPlayAnimatedImage = false
            self.imageViewOutlet.stopAnimating()
            self.setImage()
            switch msgVMObj.mediaState {
            case .notUploaded, .notApplicable:
                ///For uploading image in background thread. Added in conurrent dispatch queue task
                DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.msgVMObj.uploadImage(withChatDocID: strongSelf.chatDocID, replyingMsg: strongSelf.replyMsg, isReplyingMessage: strongSelf.isReplying, progress : { (progress) in
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

    
    //MARK:- tap gesture delegate
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func deleteOptions(_ gesture: UILongPressGestureRecognizer){
        print("doubletapped")
        imageDeleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgVMObj.message)
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
    
    private func setImage() {
        self.setImageFromCache()
    }
    
    private func setImageFromCache() {
        self.msgVMObj.getImage(withCompletion: { (img) in
            if let image = img {
                self.imageViewOutlet.image = image
            } else {
                // Image not found locally.
                self.downloadImage()
            }
        })
    }
    
    private func downloadImage() {
        if var  imageURL = msgVMObj.message.messagePayload {
            
            if imageURL == "" {
                if let imageUrlObj = msgVMObj.message.mediaURL!.fromBase64() {
                    imageURL = imageUrlObj
                }
            }
            
            DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.imageViewOutlet.kf.setImage(with: URL(string: imageURL),
                                                           placeholder: nil ,
                                                           options: [.backgroundDecode],
                                                           progressBlock: nil,
                                                           completionHandler: { image, error, cacheType, imageURL in
                                                            print("\(String(describing: strongSelf.msgVMObj.message.messagePayload)): Finished")
                    })
                }
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
        self.imageTappedOutlet.addGestureRecognizer(longPress)
    }
    
    @IBAction func imageTappedAction(_ sender: UIButton) {
        if let delegate = imageTappedDelegate {
            delegate.imageCellTapped(withImageMVModal: msgVMObj)
        }
    }
    
    @IBAction func retryButtonAction(_ sender: UIButton) {
        self.retryButtonOutlet.isHidden = true
        self.msgVMObj.retryUploadingimage(withProgress: { (progress) in
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
        
        imageTappedDelegate?.imageForwardActionCliked(self)
        
    }
    
    @IBAction func gifPlayAction(_ sender: UIButton) {
        self.gifViewOutlet.isHidden = true
        self.imageViewOutlet.startAnimating()
    }
}

extension ImageSentCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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

/// SentLocationMediaItem inherites the JSQMessageMediaData properties
class SentImageMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of SentLocationCell
    let imageCell = ImageSentCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 290, height: 200))
    
    func mediaView() -> UIView? {
        return imageCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return imageCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 290, height: 200)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}