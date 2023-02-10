//
//  DeletedReceivedCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 31/03/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class DeletedReceivedCollectionViewCell: JSQMessagesCollectionViewCell {
   
    @IBOutlet weak var deleteMessageTextOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        deleteMessageTextOutlet.text = "This message was deleted".localized + "."
        // Initialization code
        self.delegate = self
    }
}

extension DeletedReceivedCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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

/// RepliedReceivedAudioMediaItem inherites the JSQMessageMediaData properties
class DeletedMessageMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedAudioCell
    let deletedCell = DeletedReceivedCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 215, height: 18))
    
    func mediaView() -> UIView? {
        return deletedCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return deletedCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 215, height: 15)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
