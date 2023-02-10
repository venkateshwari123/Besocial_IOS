//
//  ContactMessageCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 13/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController

protocol ContactMessageActionDelegate {
    func sendMessageToUser(withUserIds : [String])
    func inviteToAppAction(withPhNumbers: [String])
    func openContactDetail(withMsgVMObj : ContactMessageViewModal)
    func contactForwardActionCliked(_ cell: SentContactMessageCollectionViewCell)
    func receivedContactForwardActionClicked(_ cell: ReceivedContactCollectionViewCell)
}

class SentContactMessageCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var inviteMessageBtnOutlet: UIButton!

    @IBOutlet weak var navBtnOutlet: UIButton!
    @IBOutlet weak var userImageOutlet: UIImageView!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var singleViewOutlet: UIView!
    @IBOutlet weak var twoOptionViewOutlet: UIView!
    @IBOutlet weak var forwardButtonOutlet: UIButton!
    @IBOutlet weak var senderImageView: UIImageView!
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    var contactMessageDelegates : ContactMessageActionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteOptions(_:)))
        longPress.minimumPressDuration = 1.0
        self.navBtnOutlet.addGestureRecognizer(longPress)

    }
    /// model object of message. see didSet for more details.
    var msgObj  : ContactMessageViewModal!{
        didSet {
            /*
             Bug Name:- invite to picoadda instead of “invite to Dub.ly "
             Fix Date:- 09/07/2021
             Fixed By:- jayaram G
             Discription of Fix:- Showing appname according to scheme
             */
            self.inviteMessageBtnOutlet.setTitle("Invite".localized + " " + "to".localized + " \(AppConstants.AppName)", for: .normal)
            self.setValues(withMsgObj : msgObj)
        }
    }
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func deleteOptions(_ gesture: UILongPressGestureRecognizer){
        print("doubletapped")
        deleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgObj.message)
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
    
    @IBAction func saveContactsAction(_ sender: UIButton) {
        if (contactMessageDelegates != nil) {
            msgObj.saveContactAction()
        }
    }
    
    @IBAction func messageUserAction(_ sender: UIButton) {
        if (contactMessageDelegates != nil) {
            let userIDs = msgObj.getRegisteredUserID()
            contactMessageDelegates?.sendMessageToUser(withUserIds : userIDs)
        }
    }
    
    @IBAction func openContactDetailsAction(_ sender: UIButton) {
        if (contactMessageDelegates != nil) {
            contactMessageDelegates?.openContactDetail(withMsgVMObj: msgObj)
        }
    }
    
    @IBAction func inviteToHola(_ sender: UIButton) {
        if (contactMessageDelegates != nil) {
            let numbers = msgObj.getNumbers()
            contactMessageDelegates?.inviteToAppAction(withPhNumbers: numbers)
        }
    }
    
    @IBAction func forwardButtonAction(_ sender: UIButton) {
        
        contactMessageDelegates?.contactForwardActionCliked(self)
    }
}

extension SentContactMessageCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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
class SentContactMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedLocationCell
    let contactCell = SentContactMessageCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 335, height: 90))
    
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
