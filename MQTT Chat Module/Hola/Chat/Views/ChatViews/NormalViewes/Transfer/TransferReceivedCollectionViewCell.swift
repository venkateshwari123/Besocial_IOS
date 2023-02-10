//
//  TransferReceivedCollectionViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 11/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController

protocol TransferReceivedCollectionViewCellDelegate: class {
    func paymentActionSelected(isAccept: Bool, msgObj: TransferMessageViewModel)
    func transferReceivedCellTapped( msgObj: TransferMessageViewModel)
}

class TransferReceivedCollectionViewCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var paymentStatusLableOutlet: UILabel!
    @IBOutlet weak var amountLabelOutlet: UILabel!
    @IBOutlet weak var backViewOutlet: UIView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var transactionTimeLabel: UILabel!
    @IBOutlet weak var currencySymbolLabel: UILabel!
    
    weak var delegate: TransferReceivedCollectionViewCellDelegate?
    
    var msgObj: TransferMessageViewModel!{
        didSet{
            self.setCellDataInTransferReceivedCell()
        }
    }
    
    /// View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func setCellDataInTransferReceivedCell(){
            var status: String?
            var height: CGFloat = 0
        self.backViewOutlet.makeBorderWidth(width: 1, color: Helper.hexStringToUIColor(hex: "#C9C9C9"))
        self.backViewOutlet.makeCornerRadious(readious: 15)
        self.currencySymbolLabel.text = Utility.getWalletCurrenySymbol()
        status = "Received".localized
//            switch msgObj.message.transferStatus!{
//            case .new:
//                height = 35
//                self.acceptButtonOutlet.setTitle("Accept", for: .normal)
//                self.rejectButtonOutlet.setTitle("Reject", for: .normal)
//                status = Strings.PaymentStatus.pending
//                break
//            case .confirm:
//                status = Strings.PaymentStatus.accepted
//                break
//            case .timout:
//                status = Strings.PaymentStatus.timeout
//                break
//            case .cenceled:
//                status = Strings.PaymentStatus.canceled
//                break
//            case .denied:
//                status = Strings.PaymentStatus.denied
//                break
//            }
            self.layoutIfNeeded()
        self.notesLabel.text = msgObj.message.messagePayload
        self.paymentStatusLableOutlet.text = status
        if let timeStamp = msgObj.message.timeStamp {
            let Date:Date = Helper.getDateObj(fromTimeStamp: timeStamp)
            self.transactionTimeLabel.text = "You received".localized + " • \(Date.toString(dateFormat: "dd MMM"))"
        }
        if let amount = msgObj.message.amount {
        self.amountLabelOutlet.text = "\(amount)"
        }
        
    }
    
    //MARK:- Button Action
    @IBAction func rejectButtonAction(_ sender: Any) {
        self.delegate?.paymentActionSelected(isAccept: false, msgObj: self.msgObj!)
    }
    
    
    @IBAction func acceptButtonAction(_ sender: Any) {
        self.delegate?.paymentActionSelected(isAccept: true, msgObj: self.msgObj!)
    }
    
    @IBAction func transferReceivedCellTappedAction(_ sender: Any) {
        self.delegate?.transferReceivedCellTapped(msgObj: self.msgObj!)
    }
    
    

}


extension TransferReceivedCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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
class TransferReceivedMediaItem : NSObject, JSQMessageMediaData {
    
    init(isPending: Bool, payload: Bool){
        if payload {
            height = 140
        }else{
            height = 120
        }
    }
    var height = 140
    /// Used for the instance of ReceivedLocationCell
//    let contactCell = ReceivedContactCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 240, height: 150))
    
    func mediaView() -> UIView? {
        return ReceivedContactCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 240, height: height))
    }
    
    func mediaPlaceholderView() -> UIView {
        return ReceivedContactCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 240, height: height))
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 240, height: height)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
