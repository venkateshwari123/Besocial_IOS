//
//  TransferToFriendViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class TransferToFriendViewController: UIViewController {

    
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    //Outlets
    @IBOutlet weak var senderUserImageView: UIImageView!
    @IBOutlet weak var receiverImageView: UIImageView!
    @IBOutlet weak var payingUserName: UILabel!
    @IBOutlet weak var nextBtnBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var payingStaticMsgOutlet: UILabel!
    @IBOutlet weak var opponentReceiveMessage: UILabel!
    @IBOutlet weak var amountTaxtField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var senderCurrenctLbl: UILabel!
    @IBOutlet weak var receiverCurrenctLbl: UILabel!
    @IBOutlet weak var makePaymentButtonOutlet: UIButton!
    @IBOutlet weak var userCurrecySymbolLbl: UILabel!
    @IBOutlet weak var minimumAmtLbl: UILabel!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var infoBtnOutlet: UIButton!
    
    var userModel:UserProfileModel?
    var isConfirmViewDismissed: Bool = true
    var isNotFromChatList:Bool = false
    var confirmPaymentViewModel = ConfirmPaymentViewModel()
    
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Transfer to a friend".localized
        self.receiverCurrenctLbl.text = self.userModel?.currency?.currencyCode
        let receiverFullName = (self.userModel?.firstName ?? "") + " " + (self.userModel?.lastName ?? "")
        Helper.addedUserImage(profilePic: self.userModel?.profilePic, imageView: self.receiverImageView, fullName: receiverFullName)
        self.setUsersImageUI()
        self.navigationController?.navigationBar.tintColor = .black
        self.setUpUserdetailsInViewUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        if self.isConfirmViewDismissed{
            self.amountTaxtField.becomeFirstResponder()
        }
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUsersImageUI(){
        self.makePaymentButtonOutlet.isEnabled = false
        self.infoBtnOutlet.isHidden = true
        self.makePaymentButtonOutlet.alpha = 0.5
        self.senderUserImageView.makeCornerRadious(readious: self.senderUserImageView.frame.size.width / 2)
        self.receiverImageView.makeCornerRadious(readious: self.receiverImageView.frame.size.width / 2)
    }
    
    func setUpUserdetailsInViewUI(){
        self.currentBalanceLabel.text = "Current Balance".localized + " : \(Utility.getWalletCurrenySymbol()) \(KeychainHelper.sharedInstance.getWalletBalance()) "
        self.senderCurrenctLbl.text = Utility.getWalletCurreny()
        self.userCurrecySymbolLbl.text = Utility.getWalletCurrenySymbol()
        self.payingStaticMsgOutlet.text = "Send a payment to".localized
        self.noteTextField.placeholder = "Add Note".localized
        self.makePaymentButtonOutlet.setTitle("Confirm".localized, for: .normal)
        self.minimumAmtLbl.text = "minimum amount".localized + " \(Utility.getWalletCurrenySymbol()) 00.1"
        let senderImageUrl = Utility.getUserImage()
        Helper.addedUserImage(profilePic: senderImageUrl, imageView: self.senderUserImageView, fullName: Utility.getUserFullName() ?? "P")
        if let receiverName = self.userModel?.userName , receiverName != ""{
            self.payingStaticMsgOutlet.isHidden = false
            self.payingUserName.text = "\(receiverName )"
        }else{
            self.payingStaticMsgOutlet.isHidden = true
        }
    }
    

    
    func transferValidateApi(amount: String) {
        var params = [String:Any]()
        params["fromCurrency"] = Utility.getWalletCurreny()
        params["fromUserType"] = "user"
        params["fromUserId"] = Utility.getUserid()
        params["toCurrency"] = self.userModel?.currency?.currencyCode
        params["toUserId"] = self.userModel?.userId
        params["toUserType"] = "user"
        params["amount"] = amount
        self.confirmPaymentViewModel.transferValidateServiceCall(params: params) { (succes, error) in
            if succes{
                /*
                 Bug Name:- Enable next button only for verified user
                 Fix Date:- 16/06/21
                 Fix By  :- jayaram G
                 Description of Fix:- Enabling in success
                 */
                self.makePaymentButtonOutlet.isEnabled = true
                self.makePaymentButtonOutlet.alpha = 1
                self.infoBtnOutlet.isHidden = false
                if #available(iOS 13.0, *) {
                    self.opponentReceiveMessage.textColor = .label
                } else {
                    self.opponentReceiveMessage.textColor = .black
                    // Fallback on earlier versions
                }
                self.opponentReceiveMessage.text = "\(self.userModel?.userName ?? "") " + "will receive".localized + " \(self.userModel?.currency?.currencySymbol ?? "")\(self.confirmPaymentViewModel.tansferDetails?.finalAmount ?? 0.0)"
            }else if let err = error {
                Helper.showAlert(head: "Message".localized, message: "\(err.localizedDescription)")
            }
        }
    }
    
    
    // To manage view height according to keyboard height
    ///
    /// - Parameter notification: keyboard notification object
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y + 20
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                /*
                 Bug Name:- there is too much white space, Name of users is getting scrolled up too much
                 Fix Date:- 01/06/21
                 Fix By  :- Jayaram G
                 Description of Fix:- Handling contentoffset according to device height
                 */
                if  Utility.getDeviceHeight() > 730.0 {
                    self.scrollViewOutlet.setContentOffset(CGPoint(x: 0, y: 40), animated: true)
                }else{
                    self.scrollViewOutlet.setContentOffset(CGPoint(x: 0, y: 120), animated: true)
                }
                self.nextBtnBottomConstraint.constant = keyboardHeight
            }, completion: nil)
        }
    }
    
    //MARK:- Button Action
    @IBAction func makePaymentAction(_ sender: Any) {
        
        //ConfirmPaymentViewController
        guard let confirmPayVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmPaymentViewController") as? ConfirmPaymentViewController else {return}
        guard let amountToPay = Double(self.amountTaxtField.text!) else{return}
        confirmPayVC.modalPresentationStyle = .overCurrentContext
        confirmPayVC.delegate = self
        confirmPayVC.receiverCurrencyCode = self.userModel?.currency?.currencySymbol ?? "₹"
        confirmPayVC.receiverImage = self.userModel?.profilePic ?? ""
        confirmPayVC.receiverCurrency = self.userModel?.currency?.currencyCode ?? Utility.getWalletCurreny()
        confirmPayVC.receiverAmount = "\(self.confirmPaymentViewModel.tansferDetails?.finalAmount ?? 0.0)"
        confirmPayVC.receiverUserId = self.userModel?.userId
        confirmPayVC.amount = "\(amountToPay)"
        confirmPayVC.note = self.noteTextField.text
        confirmPayVC.receiverName = self.userModel?.userName
        self.present(confirmPayVC, animated: true, completion: nil)
        self.isConfirmViewDismissed = false
    }
    
    @IBAction func processingInfoAction(_ sender: Any) {
        /*
         Bug Name:- need to add that “i” icon with price breakdown details in the wallet transfer page
         Fix Date:- 26/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Added alert info navigation
         */
        if #available(iOS 13.0, *) {
            guard let processingInfoVC = UIStoryboard.init(name: "TransferAlert", bundle: nil).instantiateViewController(identifier: String(describing: TransferAlertViewController.self)) as? TransferAlertViewController else {
                return
            }
            processingInfoVC.sendAmount = self.amountTaxtField.text!
            processingInfoVC.receiverName = self.userModel?.userName ?? ""
            processingInfoVC.receiverCurrency = self.userModel?.currency?.currencySymbol ?? ""
            processingInfoVC.receiverAmount = "\(self.confirmPaymentViewModel.tansferDetails?.finalAmount ?? 0.0)"
            processingInfoVC.processingFee = "\(self.confirmPaymentViewModel.tansferDetails?.appCommission ?? 0.0)"
            processingInfoVC.definesPresentationContext = true
            processingInfoVC.modalPresentationStyle = .overCurrentContext
           var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
           while ((topRootViewController?.presentedViewController) != nil) {
               topRootViewController = topRootViewController?.presentedViewController
           }
           DispatchQueue.main.async {
               topRootViewController?.present(processingInfoVC, animated: false, completion: nil)
           }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
}



// MARK: - UITextFieldDelegate
extension TransferToFriendViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{return false}
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        switch textField{
        case self.amountTaxtField:
            /*
             Bug Name:- only 2 decimals should be allowed to type for the wallet transfer money input text field
             Fix Date:- 01/06/21
             Fix By  :- Jayaram G
             Description of Fix:- Added validations for entered amount
             */
            if txtAfterUpdate.isEmpty {
                self.makePaymentButtonOutlet.isEnabled = false
                self.infoBtnOutlet.isHidden = true
                self.makePaymentButtonOutlet.alpha = 0.5
                self.opponentReceiveMessage.text = ""
            }else {
                if Double(txtAfterUpdate) ?? 0 > Double(KeychainHelper.sharedInstance.getWalletBalance()) ?? 100000000000000 {
                    self.makePaymentButtonOutlet.isEnabled = false
                    self.infoBtnOutlet.isHidden = true
                    self.makePaymentButtonOutlet.alpha = 0.5
                    self.opponentReceiveMessage.textColor = .red
                    self.opponentReceiveMessage.text = "Insufficient balance".localized + "."
                }else{
                    if Helper.decimalValidation(txtAfterUpdate: txtAfterUpdate) {
                        /*
                         Bug Name:- network handling
                         Fix Date:- 20/04/21
                         Fix By  :- Nikunj C
                         Description of Fix:- check connectivity and show popup for no internet
                         */
//                        self.opponentReceiveMessage.text = "\(self.receiverName ?? "") will receive \(Utility.getWalletCurrenySymbol())\((Double(txtAfterUpdate) ?? 0.0) / 2)"
                        /*
                         Bug Name:- Don't call api after.
                         Fix Date:- 16/06/21
                         Fix By  :- jayaram G
                         Description of Fix:- Added check for validation
                         */
                        if txtAfterUpdate.last != "." {
                            self.transferValidateApi(amount: txtAfterUpdate)
                        }else {
                            self.makePaymentButtonOutlet.isEnabled = false
                            self.infoBtnOutlet.isHidden = true
                            self.makePaymentButtonOutlet.alpha = 0.5
                        }
                    }else{
                        return false
                    }
                }
            }
            break
        case self.noteTextField:
            if text.count > 50 && string != ""{
                return false
            }
            break
        default:
            break
        }
        return true
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.noteTextField{
            self.makePaymentAction(UIButton())
        }
        textField.resignFirstResponder()
        return true
    }
}



extension TransferToFriendViewController: ConfirmPaymentViewControllerDelegate{
    
    func isViewDismissed(isPaymentDone: Bool) {
        /*
         Bug Name:- Wallet update, camera button position is changing
         Fix Date:- 17/06/21
         Fix By  :- jayaram G
         Description of Fix:- ending editing view
         */
        self.view.endEditing(true)
        if isPaymentDone{
            /*
             Bug Name:- The transaction is being displayed in the transaction log but not in chat when we send a transfer to a new user without chatting with the user for a new user whom we
             Fix Date:- 29/06/21
             Fix By  :- jayaram G
             Description of Fix:- popping to root view when user sending payment first time
             */
            if isNotFromChatList {
                self.navigationController?.popToRootViewController(animated: true)
            }else{
                if let chatVC = (self.navigationController?.viewControllers.filter({$0.isKind(of: ChatViewController.self)}).first as? ChatViewController){
                    self.navigationController?.popToViewController(chatVC, animated: true)
                    return
                }
                if let walletVc = (self.navigationController?.viewControllers.filter({$0.isKind(of: WalletViewController.self)}).first as? WalletViewController){
                    walletVc.handleRefresh()
                    self.navigationController?.popToViewController(walletVc, animated: true)
                    return
                }
            }
        }
        self.isConfirmViewDismissed = isPaymentDone
    }
}
