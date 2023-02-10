//
//  CallMessageTypeCollectionViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 16/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController

protocol CallMessageTypeCollectionViewCellDelegate: class{
    func callCellTapped()
}


class CallMessageTypeCollectionViewCell: JSQMessagesCollectionViewCell {

    
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var callMessageLabelOutlet: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
         self.delegate = self
        self.backgroundColor = .clear
        // Initialization code
    }

}

extension CallMessageTypeCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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

