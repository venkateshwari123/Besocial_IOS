//
//  ReceivedContactCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 13/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Kingfisher

class ReceivedContactCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var mainViewOutlet: UIView!
    @IBOutlet weak var inviteToHolaOutlet: UIButton!
    @IBOutlet weak var userImageOutlet: UIImageView!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var singleViewOutlet: UIView!
    @IBOutlet weak var twoOptionViewOutlet: UIView!
    @IBOutlet weak var senderImageView: UIImageView!
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    var contactMessageDelegates : ContactMessageActionDelegate?
    
    /// model object of message. see didSet for more details.
    var msgObj  : ContactMessageViewModal!{
        didSet {
            /*
             Bug Name:- invite to picoadda instead of “invite to Dub.ly "
             Fix Date:- 09/07/2021
             Fixed By:- jayaram G
             Discription of Fix:- Showing appname according to scheme
             */
            self.inviteToHolaOutlet.setTitle("Invite".localized + " " + "to".localized + " \(AppConstants.AppName)", for: .normal)
            self.setValues(withMsgObj : msgObj)
        }
    }
    
    private func setValues(withMsgObj messageObj: ContactMessageViewModal) {
        if let userImage =  messageObj.getContactImage() {
            self.userImageOutlet.kf.setImage(with: userImage, placeholder: #imageLiteral(resourceName: "voice_call_profile_default_image"), options: nil, progressBlock: nil) { (result) in
                print(result)
            }
        } else {
            self.userImageOutlet.image = #imageLiteral(resourceName: "voice_call_profile_default_image")
        }
        if let name = msgObj.getContactName() {
            self.userNameOutlet.text = name
        }
        if msgObj.getRegisteredUserID().count>0 {
            self.twoOptionViewOutlet.isHidden = false
            self.singleViewOutlet.isHidden = true
        } else {
            self.twoOptionViewOutlet.isHidden = true
            self.singleViewOutlet.isHidden = false
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
        deleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgObj.message)
    }
    
    @IBAction func inviteAction(_ sender: UIButton) {
        if (contactMessageDelegates != nil) {
            let numbers = msgObj.getNumbers()
            contactMessageDelegates?.inviteToAppAction(withPhNumbers: numbers)
        }
    }
    
    @IBAction func contactDetailsAction(_ sender: UIButton) {
        if (contactMessageDelegates != nil) {
            contactMessageDelegates?.openContactDetail(withMsgVMObj: msgObj)
        }
    }
    
    @IBAction func saveContactAction(_ sender: UIButton) {
        if (contactMessageDelegates != nil) {
            msgObj.saveContactAction()
        }
    }
    
    @IBAction func messageButtonAction(_ sender: UIButton) {
        if (contactMessageDelegates != nil) {
            let userIDs = msgObj.getRegisteredUserID()
            contactMessageDelegates?.sendMessageToUser(withUserIds : userIDs)
        }
    }
    
    @IBAction func forwardButtonAction(_ sender: UIButton) {
        self.contactMessageDelegates?.receivedContactForwardActionClicked(self)
    }
}

extension ReceivedContactCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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
class ReceivedContactMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedLocationCell
    let contactCell = ReceivedContactCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 335, height: 90))
    
    func mediaView() -> UIView? {
        return contactCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return contactCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 335, height: 90)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
