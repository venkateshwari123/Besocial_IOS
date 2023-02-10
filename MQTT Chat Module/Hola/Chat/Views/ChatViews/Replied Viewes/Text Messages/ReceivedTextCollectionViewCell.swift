//
//  ReceivedTextCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 12/03/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ReceivedTextCollectionViewCell: JSQMessagesCollectionViewCell {

    @IBOutlet weak var replyViewOutlet: ReplyView!
    @IBOutlet weak var repliedMsgLabelOutlet: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    
    var repliedButtonPressedDelegate : ReplyViewDismissDelegate? {
        didSet {
            replyViewOutlet.replyViewDismissDelegate = repliedButtonPressedDelegate
        }
    }
    
    var msgObj : Message! {
        didSet {
            self.setMessageData()
            replyViewOutlet.selectedMessage = msgObj
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }
    
    func setMessageData() {
        self.repliedMsgLabelOutlet.text = msgObj.messagePayload
    }
}

extension ReceivedTextCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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

/// RepliedTextReceivedMessageMediaItem inherites the JSQMessageMediaData properties
class RepliedTextReceivedMessageMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedTextCollectionViewCell
    let repliedTextCell = ReceivedTextCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 275, height: 100))
    
    func mediaView() -> UIView? {
        return repliedTextCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return repliedTextCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 275, height: 100)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
