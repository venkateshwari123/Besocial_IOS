//
//  PostSentCollectionViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 04/12/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import UICircularProgressRing
import Kingfisher


class PostSentCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var backgrundViewOutlet: UIView!
    @IBOutlet weak var imageTappedOutlet: UIButton!
    @IBOutlet weak var postNameLabel: UILabel!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var retryButtonOutlet: UIButton!
    @IBOutlet weak var circlularProgressIndicator: UICircularProgressRing!
    
    @IBOutlet weak var gifViewOutlet: UIView!
    @IBOutlet weak var forwardButtonOutlet: UIButton!    
    @IBOutlet weak var senderImageView: UIImageView!
    /// tells that user is replying for a message.
    var isReplying : Bool?
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    /// If isReplying == true then this will be the message you are going to reply.
    var replyMsg : Message?
    
    var postTappedDelegate : PostCellTappedDelegate? = nil
    var chatDocID : String!
    
    
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
    
    
    var postType: Int?{
        didSet{
            if postType == 0{
                self.playImageView.isHidden = true
            }else{
                self.playImageView.isHidden = false
            }
        }
    }
    
    var msgVMObj : PostMessageViewModel! {
        didSet {
            self.imageViewOutlet.autoPlayAnimatedImage = false
            self.imageViewOutlet.stopAnimating()
            self.setImage()
//            self.postNameLabel.text = 
            switch msgVMObj.mediaState {
            case .notUploaded:
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
        self.msgVMObj.getPost(withCompletion: { (img) in
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
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func deleteOptions(_ gesture: UILongPressGestureRecognizer){
        print("doubletapped")
        deleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgVMObj.message)
    }
    
    @IBAction func imageTappedAction(_ sender: UIButton) {
        if let delegate = postTappedDelegate {
            delegate.postCellTapped(withPostMVModal: msgVMObj)
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
        
        postTappedDelegate?.postForwardActionCliked(self)
        
    }
    
    @IBAction func gifPlayAction(_ sender: UIButton) {
        self.gifViewOutlet.isHidden = true
        self.imageViewOutlet.startAnimating()
    }
}

extension PostSentCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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
class SentPostMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of SentLocationCell
    let postCell = PostSentCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 290, height: 210))
    
    func mediaView() -> UIView? {
        return postCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return postCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 290, height: 210)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
