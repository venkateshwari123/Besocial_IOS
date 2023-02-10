//
//  ImageReceivedCollectionViewCell.swift
//  
//
//  Created by Sachin Nautiyal on 22/01/2018.
//

import UIKit
import JSQMessagesViewController
import UICircularProgressRing
import Kingfisher

class StickerReceivedCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var reloadButtonOutlet: UIButton!
    @IBOutlet var imageViewOutlet: AnimatedImageView!
    @IBOutlet weak var progressRingOutlet: UICircularProgressRing!
    
    @IBOutlet weak var mainViewOutlet: UIView!
    @IBOutlet weak var senderImageView: UIImageView!
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    var chatDocID : String!
    var stickerCollectionViewCellDelegate : StickerCollectionViewCellDelegate?
    
    var msgVMObj : ImageMessageViewModal! {
        didSet {
            self.downloadImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteOptions(_:)))
        longPress.minimumPressDuration = 1.0
        self.mainViewOutlet.addGestureRecognizer(longPress)

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
    
    func wifiCheck() -> Bool{
        //Check current reachablity status
        //check network status given by user in Setting ..default is both
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let status = appdelegate.reachability.connection //Wifi or cell network
        guard let value = UserDefaults.standard.object(forKey: "Photos") as? Int else { return true }
        
        if value == 0 { // Never - 0
            return false
        }
        else if value == 1 { // WIFI - 1
            if status == .wifi {
                return true
            } else { return false }
        }
        else if value == 2 { // WIFI and Cell - 2
            if status == .none {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    private func downloadImage() {
        if wifiCheck() {
            if let imageURL = msgVMObj.message.messagePayload {
                DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    DispatchQueue.main.async {
                        strongSelf.imageViewOutlet.kf.setImage(with: URL(string: imageURL),
                                                               placeholder: nil ,
                                                               options: [.backgroundDecode],
                                                               progressBlock: { receivedSize, totalSize in
                                                                let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
                                                                print(percentage)
                                                               strongSelf.progressRingOutlet.startProgress(to: CGFloat(percentage), duration: 1)}
                            , completionHandler: { (result) in
                                
                        })
                   
                }
            }
            }
        }
    }
    
    @IBAction func forwardButtonAction(_ sender: UIButton) {
        self.stickerCollectionViewCellDelegate?.receivedStickerForwardAction(self)
    }
    
}

extension StickerReceivedCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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
class StickerReceivedMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedLocationCell
    let imageCell = StickerReceivedCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 290, height: 200))
    
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
