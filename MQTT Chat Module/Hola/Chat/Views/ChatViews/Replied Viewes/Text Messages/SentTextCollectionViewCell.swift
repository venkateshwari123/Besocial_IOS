//
//  SentTextCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 12/03/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController


class SentTextCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var replyViewOutlet: ReplyView!
    @IBOutlet weak var repliedMsgLabelOutlet: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    
    var msgObj : Message! {
        didSet {
            self.setMessageData()
            replyViewOutlet.selectedMessage = msgObj
        }
    }
    
    var repliedButtonPressedDelegate : ReplyViewDismissDelegate? {
        didSet {
            replyViewOutlet.replyViewDismissDelegate = repliedButtonPressedDelegate
        }
    }
    
    func setMessageData() {
        self.repliedMsgLabelOutlet.text = msgObj.messagePayload
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
    }
}

extension SentTextCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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

/// RepliedTextSentMessageMediaItem inherites the JSQMessageMediaData properties
class RepliedTextSentMessageMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedTextCollectionViewCell
    let repliedTextCell = SentTextCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 275, height: 70))
    
    func mediaView() -> UIView? {
        return repliedTextCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return repliedTextCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 275, height: 70)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}


