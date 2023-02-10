//
//  GpMessageTypeCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 09/05/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class GpMessageTypeCell: JSQMessagesCollectionViewCell {

    @IBOutlet weak var gpMessageTypeText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         self.delegate = self
    }

}


extension GpMessageTypeCell : JSQMessagesCollectionViewCellDelegate {
    func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell) {
     
    }
    
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: JSQMessagesCollectionViewCell) {
        
    }
    
    func messagesCollectionViewCellDidTap(_ cell: JSQMessagesCollectionViewCell, atPosition position: CGPoint) {
        
    }
    
    func messagesCollectionViewCell(_ cell: JSQMessagesCollectionViewCell, didPerformAction action: Selector, withSender sender: Any) {
        
    }
    
    func messagesCollectionViewCellDidTapAccessoryButton(_ cell: JSQMessagesCollectionViewCell) {
        
    }
    
    
    
    //Fix Cell Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        return CGSize.init(width:self.frame.size.width - 10 , height: 40)
        
    }
    
}
