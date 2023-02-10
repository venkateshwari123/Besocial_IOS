//
//  ReceivedLocationCell.swift
//  Yelo
//
//  Created by Sachin Nautiyal on 13/11/2017.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Kingfisher

/// class for the outlets of the ReceivedLocationCell.
class RepliedReceivedLocationCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var replyViewOutlet: ReplyView!
    @IBOutlet weak var locationImageOutlet: UIImageView!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var locationBtnOutlet: UIButton!
    var locationDelegate : LocationCellDelegate? = nil
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    /// model object of message. see didSet for more details.
    var msgObj  : Message!{
        didSet {
            self.setValues(withMsgObj : msgObj)
            replyViewOutlet.selectedMessage = msgObj
        }
    }
        
    var repliedButtonPressedDelegate : ReplyViewDismissDelegate? {
        didSet {
            replyViewOutlet.replyViewDismissDelegate = repliedButtonPressedDelegate
        }
    }
    
    /// used fo setting values for location inside the cell.
    ///
    /// - Parameter msgObj: Message Object. backgroundDecode
    func setValues(withMsgObj msgObj : Message) {
        var msgStr = ""
        if let msg = msgObj.messagePayload?.fromBase64() {
            msgStr = msg
        } else {
            msgStr = msgObj.messagePayload!
        }
        self.locationImageOutlet.kf.indicatorType = .activity
        self.locationImageOutlet.kf.indicator?.startAnimatingView()
        DispatchQueue.global().async {
            if let latStr = msgStr.slice(from: "(", to: ","), let longStr = msgStr.slice(from: ",", to: ")") {
                let str = "http://maps.googleapis.com/maps/api/staticmap?markers=color:red|\(latStr),\(longStr)&zoom=15&size=180x220&sensor=true&key=\(AppConstants.googleMapKey)"
                if let utfStr = str.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                    if let mapUrl = URL(string: utfStr) {
                        DispatchQueue.main.async {
                            self.locationImageOutlet.kf.setImage(with: mapUrl, placeholder: nil, options: [.backgroundDecode], progressBlock: nil, completionHandler: { (result) in
                                
                            })
                            self.locationImageOutlet.kf.indicator?.stopAnimatingView()
                        }
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteOptions(_:)))
        longPress.minimumPressDuration = 1.0
        self.locationBtnOutlet.addGestureRecognizer(longPress)

    }
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func deleteOptions(_ gesture: UILongPressGestureRecognizer){
        print("doubletapped")
        deleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgObj)
    }
    
    
    @IBAction func tapOnReceivedLocationCell(_ sender: Any) {
        self.locationDelegate?.tapOnLocationDelegate(messageObj: msgObj)
    }
    
}

extension RepliedReceivedLocationCell : JSQMessagesCollectionViewCellDelegate {
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

/// ReceivedLocationMediaItem inherites the JSQMessageMediaData properties
class RepliedReceivedLocationMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedLocationCell
    let locationCell = RepliedReceivedLocationCell(frame:CGRect(x: 0, y: 0, width: 220, height: 260))
    
    func mediaView() -> UIView? {
        return locationCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return locationCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 220, height: 260)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
