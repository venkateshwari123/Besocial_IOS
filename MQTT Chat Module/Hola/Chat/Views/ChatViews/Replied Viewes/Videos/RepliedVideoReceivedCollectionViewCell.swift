//
//  VideoReceivedCollectionViewCell.swift
//  
//
//  Created by Sachin Nautiyal on 22/01/2018.
//

import UIKit
import JSQMessagesViewController
import UICircularProgressRing
import Kingfisher

class RepliedVideoReceivedCollectionViewCell : JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var reloadButtonOutlet: UIButton!
    @IBOutlet var videoTappedButtonOutlet: UIButton!
    @IBOutlet weak var replyViewOutlet: ReplyView!
    @IBOutlet var videoThumbnailViewOutlet: UIImageView!
    @IBOutlet weak var progressRingOutlet: UICircularProgressRing!
    @IBOutlet weak var senderImageView: UIImageView!
    
    var videoTappedDelegate : VideoCellTappedDelegate? = nil
    var chatDocID : String!
    
    var repliedButtonPressedDelegate : ReplyViewDismissDelegate? {
        didSet {
            replyViewOutlet.replyViewDismissDelegate = repliedButtonPressedDelegate
        }
    }
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    var msgVMObj : VideoMessageViewModal! {
        didSet {
            msgVMObj.downloadVideo(withChatDocID: chatDocID, progress: { [weak self] (progress) in
                self?.showDownloading(withProgress: progress)
                }, completion: { [weak self] (image) in
                    self?.videoThumbnailViewOutlet.image = image
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteOptions(_:)))
        longPress.minimumPressDuration = 1.0
        self.videoTappedButtonOutlet.addGestureRecognizer(longPress)

    }
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func deleteOptions(_ gesture: UILongPressGestureRecognizer){
        print("doubletapped")
        deleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgVMObj.message)
    }
    
    @IBAction func reloadButtonAction(sender: UIButton) {
        
    }
    
    @IBAction func openVideoButtonAction(_ sender: UIButton) {
        if let delegate = videoTappedDelegate {
            delegate.videoCellTapped(withVideoMVModal : msgVMObj)
        }
    }
    
    private func showDownloading(withProgress progress : Progress) {
        let pgValue = progress.fractionCompleted*100
        if progress.fractionCompleted == 1 {
            self.progressRingOutlet.isHidden = true
        } else {
            self.progressRingOutlet.isHidden = false
            self.progressRingOutlet.startProgress(to: CGFloat(pgValue), duration: 1)
        }
    }
}

extension RepliedVideoReceivedCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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

/// ReceivedVideoMediaItem inherites the JSQMessageMediaData properties
class RepliedReceivedVideoMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedVideoCell
    let videoCell = RepliedVideoReceivedCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 240, height: 260))
    
    func mediaView() -> UIView? {
        return videoCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return videoCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 240, height: 260)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
