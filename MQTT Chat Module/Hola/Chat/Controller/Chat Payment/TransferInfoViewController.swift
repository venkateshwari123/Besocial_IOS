//
//  TransferInfoViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 12/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//
import UIKit
class TransferInfoViewController: UIViewController {

    ///Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var confirmIndicationImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountLableOutlet: UILabel!
    @IBOutlet weak var fromOrToLabelOutlet: UILabel!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var noteLabelOutlet: UILabel!
    @IBOutlet weak var transactionDetailsView: UIView!
    @IBOutlet weak var paymentStatusLabelOutlet: UILabel!
    @IBOutlet weak var transferTimeLabelOutlet: UILabel!
    @IBOutlet weak var transactionIdLabelOutlet: UILabel!
    @IBOutlet weak var fromLabelOutlet: UILabel!
    @IBOutlet weak var toLabelOutlet: UILabel!
    @IBOutlet weak var transactionLableOutlet: UILabel!
    @IBOutlet weak var transactionIDLableOutlet: UILabel!
    @IBOutlet weak var transactionTitleLbl: UILabel!
    
    @IBOutlet weak var paymentRefundMessageLabel: UILabel!
    
    
    //variables
    let transferInfoViewModel = TransferInfoViewModel()
    var transferMessageObject: TransferMessageViewModel?
    var userImageUrl: String?
    var userName: String?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewsUI()
        self.getTransfermessageDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.amountLableOutlet.resignFirstResponder()
    }
    
    /// To set view UI from transfer Message view model
    private func setViewsUI(){
        self.transactionDetailsView.makeCornerRadious(readious: 5.0)
        self.transactionDetailsView.makeBorderColorAndBorderWidth(UIColor.lightGray.cgColor, borderWidth: 0.4)
        self.transactionDetailsView.makeShadowEffect(color: .lightGray)
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
        self.navigationItem.title = "Transaction Details".localized
        self.transactionIdLabelOutlet.text = "Transaction Id".localized
        guard let msgObj = self.transferMessageObject else{return}
        self.userImageView.setImageOn(imageUrl: self.userImageUrl, defaultImage: #imageLiteral(resourceName: "defaultImage"))
        if let amount = msgObj.message.amount {
        self.amountLableOutlet.text = "\(amount)"
        }
        
        if msgObj.message.isSelfMessage{
            self.fromOrToLabelOutlet.text = "to".localized
            transactionLableOutlet.text = "Sent".localized + " " + "Transaction".localized
            self.transactionStateOfTransaction(transferStatus: msgObj.message.transferStatus!, isSelf: true)
        }else{
            self.fromOrToLabelOutlet.text = "From".localized
            transactionLableOutlet.text = "Received".localized + " " + "Transaction".localized
            self.transactionStateOfTransaction(transferStatus: msgObj.message.transferStatus!, isSelf: false)
        }
        self.userNameOutlet.text = self.userName
    }
    
    
    //MARK:- Service call
    /// To get transfer detial from server
    fileprivate func getTransfermessageDetails(){
        guard let msgObj = self.transferMessageObject else{return}
        let msgId = msgObj.message.txnId
        let strUrl = AppConstants.userTransferDetail + "?transactionId=\(msgId)"
//        let params:[String:Any] = ["messageId":msgId]
        Helper.showPI()
        self.transferInfoViewModel.getTransactionDetailsService(strUrl: strUrl, params: [:]) { (success, error) in
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            if success{
                DispatchQueue.main.async{
                    self.loadTransactionData()
                }
            }else if let err = error{
                DispatchQueue.main.async{
                    Helper.showAlertViewOnWindow(err.localizedTitle, message: err.localizedDescription)
                }
            }
            Helper.hidePI()
        }
    }
    
    
    /// To load transfer datial in view UI after getting response from server
    fileprivate func loadTransactionData(){
        guard let msgObj = self.transferMessageObject else{return}
        guard let transferInfoModel = self.transferInfoViewModel.transferInfoModel else{return}
        self.userImageView.setImageOn(imageUrl: self.userImageUrl, defaultImage: #imageLiteral(resourceName: "defaultImage"))
        self.amountLableOutlet.text = transferInfoModel.fromAmount
        if msgObj.message.isSelfMessage{
            self.fromOrToLabelOutlet.text = "to".localized
            transactionLableOutlet.text = "Sent".localized + " " + "Transaction".localized
            self.transactionStateOfTransaction(transferStatus: transferInfoModel.transferStatus, isSelf: true)
        }else{
            self.fromOrToLabelOutlet.text = "Received".localized + " " + "From".localized
            transactionLableOutlet.text = "Received".localized + " " + "Transaction".localized
            self.transactionStateOfTransaction(transferStatus: transferInfoModel.transferStatus, isSelf: false)
        }
        let callTime = DateExtension().getDateFromDouble(timeStamp: transferInfoModel.messageCreatedDate ?? 1622716517006)
//        self.transferTimeLabelOutlet.text = DateExtension().lastMessageTime(date: callTime!)
        self.transferTimeLabelOutlet.text = DateExtension().lastMessageTime(date: callTime!) + " " + DateExtension().lastSeenTime(date: callTime!)
        self.userNameOutlet.text = self.userName
        self.transactionIdLabelOutlet.text = transferInfoModel.transactionId
        if let tranferFrom = transferInfoModel.senderUserName {
            self.fromLabelOutlet.text = "From".localized + ": " + "tranfer".localized + "From".localized
        }
        if let tranferto = transferInfoModel.receiverUserName {
            self.toLabelOutlet.text = "To".localized + ": " + "tranfer".localized + "to".localized
        }
        if let payload = transferInfoModel.noteText, payload != ""{
            self.noteLabelOutlet.makeCornerRadious(readious: 10)
            self.noteLabelOutlet.text = "\(payload)    "
        }
    }
    
    
    /// To set status of payment
    ///
    /// - Parameters:
    ///   - transferStatus: transfer status
    ///   - isSelf: is self message
    func transactionStateOfTransaction(transferStatus: TransferStatus, isSelf: Bool){
        var status: String = ""
        let name = isSelf ? "\(self.userName!)" : "You".localized
        guard let msgObj = self.transferMessageObject else{return}
        if msgObj.message.isSelfMessage{
            status = "Sent".localized
        }else{
            status = "Received".localized
        }

//        switch transferStatus {
//        case .new:
//            status = isSelf ? "Wating for \(name) confirmation" : "Wating for your confirmation"
//            self.confirmIndicationImageWidthConstraint.constant = 0
//            self.paymentRefundMessageLabel.isHidden = false
//            break
//        case .confirm:
//            status = "\(name) accepted this transaction"
//            self.confirmIndicationImageWidthConstraint.constant = 18
//            self.paymentRefundMessageLabel.isHidden = true
//            break
//        case .timout:
//            status = "Transaction timeout"
//            self.confirmIndicationImageWidthConstraint.constant = 0
//            self.paymentRefundMessageLabel.isHidden = true
//            break
//        case .denied:
//            status = "\(name) rejected this transaction"
//            self.confirmIndicationImageWidthConstraint.constant = 0
//            self.paymentRefundMessageLabel.isHidden = true
//            break
//        case .cenceled:
//            status =  isSelf ? "You cancelled this transaction" : "\(name) cancelled this transaction"
//            self.confirmIndicationImageWidthConstraint.constant = 0
//            self.paymentRefundMessageLabel.isHidden = true
//            break
//        }
        self.paymentStatusLabelOutlet.text = status
    }
}
