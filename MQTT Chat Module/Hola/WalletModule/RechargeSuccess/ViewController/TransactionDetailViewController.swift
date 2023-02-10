//
//  RechargeSuccessViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 04/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol TransactionDetailViewControllerDelegate {
    func donePressed()
}
enum TrasactionType {
    case sent
    case received
}
class TransactionDetailViewController: BaseViewController {
    
    // these are used when money transfer is done for product
    @IBOutlet var successTopView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var transferStackView: UIStackView!
    @IBOutlet weak var walletRechargeStaticLabel: UILabel!
    @IBOutlet weak var transactionIdStaicLabel: UILabel!
    @IBOutlet weak var transactionId: UILabel!
    @IBOutlet weak var rechargeModeStaticLabel: UILabel!
    @IBOutlet weak var rechargeModeLabel: UILabel!
    @IBOutlet weak var dateTimeLabelStaticLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var successStackView: UIStackView!
    @IBOutlet weak var sentMessageLabel: UILabel!
    
    @IBOutlet weak var processingAmountLabel: UILabel!
    @IBOutlet weak var receiverAmountLabel: UILabel!
    @IBOutlet weak var sentAmountLabel: UILabel!
    @IBOutlet weak var receiverMessageLabel: UILabel!
    @IBOutlet weak var transactionModeViewOutlet: UIView!
    // for details - these are used when recharge or withdrawl has been done
    @IBOutlet weak var detailsTopView: UIView!
    @IBOutlet weak var detailsBottomView: UIView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fromNameLabel: UILabel!
    @IBOutlet weak var forProductLabel: UILabel!
    @IBOutlet weak var detailsTransactionIdLabel: UILabel!
    @IBOutlet weak var detailsFromLabel: UILabel!
    @IBOutlet weak var detailsToLabel: UILabel!
    @IBOutlet weak var detailsTimeLabel: UILabel!
    @IBOutlet var detailsStaticLabel: [UILabel]!
    @IBOutlet var detailsValueLabel: [UILabel]!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var receiverImageView: UIImageView!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var feeViewOutlet: UIView!
    @IBOutlet weak var processingStaticLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    let viewModel = TransactionDetailViewModel()
    let transferInfoViewModel = TransferInfoViewModel()
    var delegate: TransactionDetailViewControllerDelegate?
    var isFromChat: Bool = false
    var txnId: String = ""
    var trasactionType:TrasactionType = .sent
    //Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        unHideNavBar()
        if !isFromChat {
            setNavigationLeftBarBackButton()
        }else{
            let backbtn = UIBarButtonItem(image: UIImage(named: "back_arrow"), style: .plain, target: self, action: #selector(self.dismissView))
            self.navigationItem.leftBarButtonItem = backbtn
        }
        
        Helper.hidePI()
    }
    
    @objc func dismissView() {
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        hideNavBar()
    }
    func setUp(){
        
        DispatchQueue.main.async {
            self.setSuccessUI()
        }
        setDetailsUI()
        setScreen()
        if viewModel.needToCallApi{
            viewModel.getWithdrawDetails { (success) in
                self.insertData()
            }
        }
        else{
            insertData()
        }
    }
    
    func setSuccessUI() {
        receiverImageView.makeCornerRadious(readious: receiverImageView.frame.width / 2)
        priceLabel.font = Theme.getInstance().walletRechargeAmountStyle.getFont()
            //Theme.getInstance().walletRechargeAmountStyle.getTextColor()
        
        walletRechargeStaticLabel.font = Theme.getInstance().rechargeSuccessPlaceHolderStyle.getFont()
            //Theme.getInstance().rechargeSuccessPlaceHolderStyle.getTextColor()
        
        transactionIdStaicLabel.text = "Transaction Id".localized
        
        transactionIdStaicLabel.font = Theme.getInstance().rechargeSuccessDetailPlaceHolderStyle.getFont()
        
        transactionId.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
            //Theme.getInstance().rechargeSuccessDetailStyle.getTextColor()
        
        rechargeModeStaticLabel.font = Theme.getInstance().rechargeSuccessDetailPlaceHolderStyle.getFont()
        
        rechargeModeLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
        
        dateTimeLabelStaticLabel.text = "Date".localized + " & " + "Time".localized
        
        dateTimeLabelStaticLabel.font = Theme.getInstance().rechargeSuccessDetailPlaceHolderStyle.getFont()
        
        dateTimeLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
           // Theme.getInstance().rechargeSuccessDetailStyle.getTextColor()
        
        notesLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
            //Theme.getInstance().rechargeSuccessDetailStyle.getTextColor()
        
        doneButton.titleLabel?.font = Theme.getInstance().promotionBuyButtonStyle.getFont()
        doneButton.layer.cornerRadius = doneButton.frame.height/2
        doneButton.setTitle(Strings.done.localized, for: .normal)
        
        processingAmountLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
        
        sentAmountLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
        
        sentMessageLabel.text = "Sent amount".localized
        
        receiverAmountLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
        
        receiverMessageLabel.text = "Received amount".localized
        
        sentMessageLabel.font = Theme.getInstance().rechargeSuccessDetailPlaceHolderStyle.getFont()
        
        receiverMessageLabel.font = Theme.getInstance().rechargeSuccessDetailPlaceHolderStyle.getFont()
        
        processingStaticLabel.text = "Processing fee".localized
        
        processingStaticLabel.font = Theme.getInstance().rechargeSuccessDetailPlaceHolderStyle.getFont()
        if isFromChat {
            
        }else{
            switch viewModel.selectedSuccessType {
            case .recharge:
                rechargeModeStaticLabel.text = "Recharge Mode".localized
                if viewModel.transaction.description != "" {
                    walletRechargeStaticLabel.text = viewModel.transaction.description
                }else {
                    walletRechargeStaticLabel.text = "Wallet Recharged".localized
                }
                feeViewOutlet.isHidden = true
            case .withdrawl:
                rechargeModeStaticLabel.text = "Withdrawl Mode".localized
                if viewModel.transaction.description != "" {
                    walletRechargeStaticLabel.text = viewModel.transaction.description
                }else {
                    walletRechargeStaticLabel.text = "Withdrawal Request Submitted Sucessfully".localized
                }
//                feeViewOutlet.isHidden = false
            }
        }
    }
    
    func setDetailsUI() {
        profileImageView.makeCornerRadious(readious: profileImageView.frame.height / 2)
        productImageView.makeCornerRadious(readious: productImageView.frame.height / 2)
        detailsBottomView.layer.borderColor = #colorLiteral(red: 0.8274509804, green: 0.8862745098, blue: 0.937254902, alpha: 1)
        detailsBottomView.makeCornerRadious(readious: 10)
        detailsBottomView.layer.borderWidth = 1
        amountLabel.font = Theme.getInstance().rechargeDetailsAmountLabelStyle.getFont()
        amountLabel.textColor = Theme.getInstance().rechargeDetailsAmountLabelStyle.getTextColor()
        
        fromNameLabel.font = Theme.getInstance().rechargeDetailsFromAndToNameStyle.getFont()
        fromNameLabel.textColor = Theme.getInstance().rechargeDetailsFromAndToNameStyle.getTextColor()
        
        forProductLabel.font = Theme.getInstance().rechargeDetailsFromAndToNameStyle.getFont()
        forProductLabel.textColor = Theme.getInstance().rechargeDetailsFromAndToNameStyle.getTextColor()
        
        for label in detailsStaticLabel{
            label.font = Theme.getInstance().rechargeSuccessDetailPlaceHolderStyle.getFont()
            label.textColor = Theme.getInstance().rechargeSuccessDetailPlaceHolderStyle.getTextColor()
            switch label.tag{
            case 1:
                label.text = "Transaction Id".localized
            case 2:
                label.text = "From".localized
            case 3:
                label.text = "To".localized
            case 4:
                label.text = "Date".localized + " & " + "Time".localized
            default:
                break
            }
            
        }
        
        for label in detailsValueLabel{
            label.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
            label.textColor = Theme.getInstance().rechargeSuccessDetailStyle.getTextColor()
        }
    }
    
    func setScreen() {
        
        if isFromChat {
            self.title = "Payment Details".localized
            self.transferStackView.isHidden = false
            self.getTransactionDetails { (success) in
                if success {
                    Helper.addedUserImage(profilePic: self.transferInfoViewModel.transferInfoModel?.receiverImage, imageView: self.receiverImageView, fullName:  (self.transferInfoViewModel.transferInfoModel?.receiverFirstName ?? "") + (self.transferInfoViewModel.transferInfoModel?.receiverLastName ?? ""))
                    self.sentAmountLabel.text = "\(self.transferInfoViewModel.transferInfoModel?.fromCurrencyCode ?? Utility.getWalletCurrenySymbol()) \(self.transferInfoViewModel.transferInfoModel?.fromAmount ?? "0")"
                    self.receiverAmountLabel.text = "\(self.transferInfoViewModel.transferInfoModel?.toCurrencyCode ?? Utility.getWalletCurrenySymbol()) \(self.transferInfoViewModel.transferInfoModel?.toAmount ?? "0")"
                    self.processingAmountLabel.text = "\(self.transferInfoViewModel.transferInfoModel?.toCurrencyCode ?? Utility.getWalletCurrenySymbol()) \(self.transferInfoViewModel.transferInfoModel?.commissionAmount ?? "0")"
                    if self.trasactionType == .sent {
                        self.priceLabel.text = "\(self.transferInfoViewModel.transferInfoModel?.fromCurrencyCode ?? "") \(self.transferInfoViewModel.transferInfoModel?.fromAmount ?? "0")"
                    }else{
                        self.priceLabel.text = "\(self.transferInfoViewModel.transferInfoModel?.toCurrencyCode ?? "") \(self.transferInfoViewModel.transferInfoModel?.toAmount ?? "0")"
                    }
                    self.walletRechargeStaticLabel.text = self.transferInfoViewModel.transferInfoModel?.description
                    self.transactionId.text = self.transferInfoViewModel.transferInfoModel?.transactionId
                    self.notesLabel.text = self.transferInfoViewModel.transferInfoModel?.noteText
                    if self.transferInfoViewModel.transferInfoModel?.noteText != ""{
                        self.notesView.isHidden = false
                    }
                    self.dateTimeLabel.text = Date().getDateFromTimeStamp(dateString: "\(self.transferInfoViewModel.transferInfoModel?.messageCreatedDate ?? 0.0)", fromFormat : "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toFormate: "dd MMM yyyy,HH:mm:ss")
                }
            }
        }else{
            switch self.viewModel.transaction.trigger {
            case "WALLET RECHARGE":
                self.title = "Recharge Details".localized
                self.transferStackView.isHidden = true
            case "PAYMENT":
                self.title = "Payment Details".localized
                self.transferStackView.isHidden = false
                self.feeViewOutlet.isHidden = true
                self.getTransactionDetails { (success) in
                    if success {
                        Helper.addedUserImage(profilePic: self.transferInfoViewModel.transferInfoModel?.receiverImage, imageView: self.receiverImageView, fullName: (self.transferInfoViewModel.transferInfoModel?.receiverFirstName ?? "") + (self.transferInfoViewModel.transferInfoModel?.receiverLastName ?? ""))
                        self.sentAmountLabel.text = "\(self.transferInfoViewModel.transferInfoModel?.fromCurrencyCode ?? Utility.getWalletCurrenySymbol()) \(self.transferInfoViewModel.transferInfoModel?.fromAmount ?? "0")"
                        self.receiverAmountLabel.text = "\(self.transferInfoViewModel.transferInfoModel?.toCurrencyCode ?? Utility.getWalletCurrenySymbol()) \(self.transferInfoViewModel.transferInfoModel?.toAmount ?? "0")"
                        self.processingAmountLabel.text = "\(self.transferInfoViewModel.transferInfoModel?.toCurrencyCode ?? Utility.getWalletCurrenySymbol()) \(self.transferInfoViewModel.transferInfoModel?.commissionAmount ?? "0")"
                    }
                }
            case "WITHDRAW REQUEST":
                /* Bug Name : Withdrawal details is title
                 Fix Date : 09-July-2021
                 Fixed By : Jayaram G
                 Description Of Fix : Changed text
                 */

                self.title = "Withdrawal Details".localized
                self.transferStackView.isHidden = true
            case "GIFT":
                self.title = "Gift Transfer Details".localized
                self.transferStackView.isHidden = true
            case "Transfer":
                self.title = "Transfer Details".localized
                self.transferStackView.isHidden = true
            default:
                self.title = "Transaction Details".localized
                self.transferStackView.isHidden = true
            }
        }
        
        if isFromChat {
            successTopView.isHidden = false
            successStackView.isHidden = false
            feeViewOutlet.isHidden = true
            doneButton.isHidden = true
            self.rechargeModeLabel.isHidden = true
            self.rechargeModeStaticLabel.isHidden = true
            self.transactionModeViewOutlet.isHidden = true
            detailsTopView.isHidden = true
            detailsStackView.isHidden = true
        }else{
            switch viewModel.selectedTransactionType {
            
            case .productTransactionScreen:
                    
                successTopView.isHidden = false
                successStackView.isHidden = false
                
                doneButton.isHidden = viewModel.pushedFromTableViewCell
                
                detailsTopView.isHidden = true
                detailsStackView.isHidden = true
                
            case .rechargeOrWithdrawlTransactionSuccess:
                successStackView.isHidden = true
                successStackView.isHidden = true
                
                doneButton.isHidden = true
                
                detailsTopView.isHidden = false
                detailsStackView.isHidden = false
            }
        }
        
    }
    
    func insertData() {
        if isFromChat {

        }else{
            if viewModel.selectedTransactionType == .productTransactionScreen{
                if viewModel.transaction.amount == "" {
                    priceLabel.text = "\(Utility.getWalletCurrenySymbol()) " + viewModel.transaction.withdrawalAmount // Utility.getCurrenySymbol() for dynamic
                }else {
                    priceLabel.text = "\(Utility.getWalletCurrenySymbol()) " + viewModel.transaction.amount //// Utility.getCurrenySymbol() for ddynamic
                    
                }
                if viewModel.transaction.fee == "" {
                    self.feeViewOutlet.isHidden = true
                }else {
                self.feeLabel.text = viewModel.transaction.fee + "%"
                }
                
                if viewModel.transaction.txnid == "" {
                    transactionId.text = viewModel.transaction.withdrawid
                }else {
                    transactionId.text = viewModel.transaction.txnid
                }
                
                if viewModel.transaction.rechargemode != ""{
                    rechargeModeLabel.text = viewModel.transaction.rechargemode + "(\(viewModel.transaction.bank))"
                }else if viewModel.transaction.accountNumber != "" {
                    self.rechargeModeStaticLabel.text = "Bank".localized
                    self.rechargeModeLabel.text = viewModel.transaction.accountNumber
                }else  if viewModel.transaction.bank != "" {
                    self.rechargeModeStaticLabel.text = "Bank".localized
                    self.rechargeModeLabel.text = viewModel.transaction.bank
                }else{
                    self.rechargeModeLabel.isHidden = true
                    self.rechargeModeStaticLabel.isHidden = true
                    self.transactionModeViewOutlet.isHidden = true
                }
            }else {
                self.detailsTransactionIdLabel.text = viewModel.transaction.txnid
                self.detailsFromLabel.text = viewModel.transaction.userFrom
                self.detailsToLabel.text = viewModel.transaction.userTo
                self.detailsTimeLabel.text = Date().getDateFromTimeStamp(dateString: viewModel.transaction.txntimestamp, fromFormat : "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toFormate: "dd MMM yyyy,HH:mm:ss")
                self.amountLabel.text = "\(Utility.getWalletCurrenySymbol()) " + viewModel.transaction.amount
                self.fromNameLabel.text = viewModel.transaction.description
                
                Helper.addedUserImage(profilePic: viewModel.transaction.senderImage, imageView: self.profileImageView, fullName:  viewModel.transaction.username)
                
                Helper.addedUserImage(profilePic: viewModel.transaction.senderImage, imageView: self.productImageView, fullName:  viewModel.transaction.username)
            }
            
            
                notesLabel.text = viewModel.transaction.notes
                if viewModel.transaction.notes  != ""{
                    self.notesView.isHidden = false
                }
                dateTimeLabel.text = Date().getDateFromTimeStamp(dateString: viewModel.transaction.txntimestamp, fromFormat : "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toFormate: "dd MMM yyyy,HH:mm:ss")
        }
       
            
        }
    
    //MARK:- Service call
    /// To get transfer detial from server
    fileprivate func getTransactionDetails( complication: @escaping(Bool)-> Void){
        if !isFromChat {
            self.txnId  = self.viewModel.transaction.txnid
        }
        let strUrl = AppConstants.userTransferDetail + "?transactionId=\(self.txnId)"
//        let params:[String:Any] = ["messageId":msgId]
        Helper.showPI()
        self.transferInfoViewModel.getTransactionDetailsService(strUrl: strUrl, params: [:]) { (success, error) in
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            if success{
                DispatchQueue.main.async{
                    complication(true)
                }
            }else if let err = error{
                DispatchQueue.main.async{
                    Helper.showAlertViewOnWindow(err.localizedTitle, message: err.localizedDescription)
                }
            }
            Helper.hidePI()
        }
    }
    
    
    @IBAction func infoAction(_ sender: Any) {
        DispatchQueue.main.async {
            Helper.showAlertViewOnWindow("", message: "This fee is taken by the processor to transfer the money and for any currency conversion that might be necessary".localized + ".")
        }
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.dismiss(animated: false)
        delegate?.donePressed()
    }
}
