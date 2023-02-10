//
//  WithdrawMoneyViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 08/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol WithdrawMoneyViewControllerDelegate {
    func withdrawSuccess()
}

class WithdrawMoneyViewController: BaseViewController {
    
    let viewModel = WithdrawMoneyViewModel()
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var withdrawAmountStaticlabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var bankNumberLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var bottomConstraintConfirmButton: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var recevingAccountStaticLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var withDrawFeeLabel: UILabel!
    @IBOutlet weak var detailsView: UIView!
    
    var delegate: WithdrawMoneyViewControllerDelegate?
    
    //Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
        registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
        self.amountTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    func setUp(){
        
        titleLabel.text = "Withdraw Money".localized
        recevingAccountStaticLabel.font = Theme.getInstance().withdrawLogTitleStyle.getFont()
        recevingAccountStaticLabel.textColor = UIColor.setColor(lightMode: AppColourStr.lightGray, darkMode: AppColourStr.whiteColor)
        recevingAccountStaticLabel.text = "Receiving Account".localized
        changeButton.setTitle("Change".localized, for: .normal)
        
        detailsView.backgroundColor = UIColor.setColor(lightMode: AppColourStr.cardBackground, darkMode: AppColourStr.blackColor)
        withdrawButton.setTitle("Withdraw".localized, for: .normal)
        withdrawButton.titleLabel?.font = Theme.getInstance().promotionBuyButtonStyle.getFont()
        withdrawButton.layer.cornerRadius = withdrawButton.frame.height/2
        titleLabel.font = Theme.getInstance().navBartitleStyle.getFont()
        titleLabel.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        withdrawAmountStaticlabel.text = "Withdraw Amount".localized
        withdrawAmountStaticlabel.font = Theme.getInstance().popupMessageStyle.getFont()
        withdrawAmountStaticlabel.textColor = UIColor.setColor(lightMode: AppColourStr.lightGray, darkMode: AppColourStr.whiteColor)
        amountTextField.font = Theme.getInstance().addAddressButtonStyle.getFont()
        amountTextField.tintColor = UIColor.setColor(lightMode: AppColourStr.darkGrayColor, darkMode: AppColourStr.whiteColor)
        amountTextField.font = Theme.getInstance().walletRechargeAmountStyle.getFont()
        amountTextField.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        amountTextField.delegate = self
        bankNumberLabel.font = Theme.getInstance().walletCardNoStyle.getFont()
        bankNumberLabel.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        errorLabel.text = ""
        errorLabel.font = Theme.getInstance().errorLabelStyle.getFont()
        errorLabel.textColor = Theme.getInstance().errorLabelStyle.getTextColor()
    
        bankNumberLabel.text = "**** **** **** " + viewModel.selectedBank.last4
        self.withDrawFeeLabel.text = "\(viewModel.selectedBank.fee) " + "withdrawal fee deducted".localized
        errorLabel.text = "Balance".localized + " : \(Utility.getWalletCurrenySymbol()) " + KeychainHelper.sharedInstance.getWalletBalance()
        errorLabel.textColor = .lightGray
        currencyButton.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        currencyButton.setTitle("\(Utility.getWalletCurreny())  ", for: .normal)
        amountTextField.keyboardType = .decimalPad
        amountTextField.placeholder = "Enter".localized + " " + "Amount".localized
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss_Keyboard))
        self.view.addGestureRecognizer(tap)
    }

    
    @IBAction func withdrawButtonAction(_ sender: Any) {
        amountTextField.resignFirstResponder()
        if validateAmountTextField(){
            askForConfirmation()
//            navigateToWithdrawOtpVc()
        }
    }
    
    @IBAction func changeButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func openCurrencyListAction(_ sender: Any) {
        /*
         Bug Name:- Add dynamic currency selection
         Fix Date:- 02/06/2021
         Fixed By:- Jayaram G
         Discription of Fix:- Added navigation to choose dynamic currency
         */
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
        let currencyVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.currencyViewControllerVcId) as! CurrencyViewController
        currencyVc.delegateObj = self
        self.navigationController?.pushViewController(currencyVc, animated: true)
    }
    
     func navigateToWithdrawOtpVc() {
//            Helper.showPI(string: "", showLabel: false)
//            guard let withDrawVerifyVc = UIStoryboard(name: "WithdrawMoney", bundle: nil).instantiateViewController(withIdentifier: "WithDrawMoneyOTPViewController") as? WithDrawMoneyOTPViewController else { return }
//            withDrawVerifyVc.totalMoney =  amountTextField.text!
//            withDrawVerifyVc.cuurencySymbol = "\(Utility.getCurrenySymbol())" // Utility.getCurrenySymbol()
//            withDrawVerifyVc.delegate = self
//            withDrawVerifyVc.viewModel.selectedBank = self.viewModel.selectedBank
//            self.navigationController?.pushViewController(withDrawVerifyVc, animated: true)
         }
    
    func askForConfirmation(){
        guard let confirmationVC = UIStoryboard(name: "DeleteProfile", bundle: nil).instantiateViewController(withIdentifier: "DeactivateConfirmationViewController") as? DeactivateConfirmationViewController else {return}
        confirmationVC.modalPresentationStyle = .overCurrentContext
        confirmationVC.setPageDetails(title: "Confirm Withdrawal", description: "Are you sure you want to withdraw \(Utility.getWalletCurrenySymbol())\(self.amountTextField.text!) from your wallet ?", whiteButtonText: "No", blueButtonText: "Yes")
        confirmationVC.delegate = self
        self.present(confirmationVC, animated: true)
    }
    
    func validateAmountTextField() -> Bool{
        if amountTextField.text == "" {
            errorLabel.text = "Please enter Amount"
            errorLabel.textColor = Theme.getInstance().errorLabelStyle.getTextColor()
            return false
        }
        
        if let intAmount = Int(amountTextField.text ?? ""), intAmount <= 0{
            errorLabel.text = "Enter valid Amount"
            errorLabel.textColor = Theme.getInstance().errorLabelStyle.getTextColor()
            return false
        }
        if let walletBalance = (KeychainHelper.sharedInstance.getWalletBalance() as NSString).integerValue as? Int {
            if let intAmount = Int(amountTextField.text ?? ""), intAmount > walletBalance  {
                errorLabel.text = "Insufficient balance."
                errorLabel.textColor = Theme.getInstance().errorLabelStyle.getTextColor()
                return false
            }
        }
        
        errorLabel.text = ""
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var enteredAmount : String = ""
        if let text = textField.text as NSString? {
            enteredAmount = text.replacingCharacters(in: range, with: string)
        }
        if !Helper.decimalValidation(txtAfterUpdate: enteredAmount){
            return false
        }
        if string == "" {
            enteredAmount = String(enteredAmount.dropLast())
        }else{
            enteredAmount = enteredAmount + string
        }
        
        if let walletBalance = Int(KeychainHelper.sharedInstance.getWalletBalance()), let intEnteredAmount = Int(enteredAmount){
            if intEnteredAmount > walletBalance{
//                return false
            }
        }
        errorLabel.text = "Balance : \(Utility.getWalletCurrenySymbol())" + KeychainHelper.sharedInstance.getWalletBalance()
        errorLabel.textColor = .lightGray
        if let intEnteredAmount = Int(enteredAmount), intEnteredAmount > 0{
            //                viewModel.getEstimateAmount(fromCurrency: "usd", toCurrency: "usd", amount: enteredAmount){
            //                    print(self.viewModel.estimatedAmount)
            //                }
        }else{
            viewModel.estimatedAmount = "0"
        }
        return true
    }
}
 

extension WithdrawMoneyViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension WithdrawMoneyViewController: DeactivateConfirmationViewControllerDelegate{
    func confirm() {
        Helper.showPI(string: "", showLabel: false)
        viewModel.withdrawAmount(amount: self.amountTextField.text!) {
            self.viewModel.withdrawMoney(amount: self.amountTextField.text!) {
                self.navigateToSuccessScreen()
            }
        }
      
        /* with dra verification navigation
 
//        guard let withDrawVerifyVc = UIStoryboard(name: "WithdrawMoney", bundle: nil).instantiateViewController(withIdentifier: "WithDrawMoneyOTPViewController") as? WithDrawMoneyOTPViewController else { return }
//        withDrawVerifyVc.totalMoney =  amountTextField.text!
//        withDrawVerifyVc.cuurencySymbol = "\(Utility.getCurrenySymbol())" // Utility.getCurrenySymbol()
//        withDrawVerifyVc.delegate = self
//        withDrawVerifyVc.viewModel.selectedBank = self.viewModel.selectedBank
        
//        withDrawVerifyVc.persionImageView = persionImageView
//        withDrawVerifyVc.userNameDetail = nameLabel.text!
//        withDrawVerifyVc.noteStr = enterNoteTextField.text ?? ""
//        self.navigationController?.pushViewController(withDrawVerifyVc, animated: true)
 */
    }
    
    func navigateToSuccessScreen() {
        guard let rechargeSuccessVC = UIStoryboard(name: "RechargeSuccess", bundle: nil).instantiateViewController(withIdentifier: "RechargeSuccessViewController") as? TransactionDetailViewController else { return }
        rechargeSuccessVC.modalPresentationStyle = .overCurrentContext
        rechargeSuccessVC.delegate = self
        rechargeSuccessVC.viewModel.needToCallApi = false
        rechargeSuccessVC.viewModel.transaction = viewModel.transaction
        rechargeSuccessVC.viewModel.selectedSuccessType = .withdrawl
        self.present(rechargeSuccessVC, animated: true)
    }
}

//extension WithdrawMoneyViewController: WithdrawMoneyOTPViewControllerDelegate{
//    func withdrawSuccess() {
//        delegate?.withdrawSuccess()
//    }
//
//}

extension WithdrawMoneyViewController: TransactionDetailViewControllerDelegate, CurrencyViewControllerDelegate{
    func donePressed() {
        if let viewControllers = self.navigationController?.viewControllers{
            for vc in viewControllers.reversed(){
                if vc.isKind(of: WalletViewController.self) {
                    delegate?.withdrawSuccess()
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
    }
    
    /*
     Bug Name:- Add dynamic currency selection
     Fix Date:- 02/06/2021
     Fixed By:- Jayaram G
     Discription of Fix:- updating data after selecting currency
     */
    func updateData(currency: String, currencySymbol: String) {
        self.viewModel.withDrawCurrency = currency
        self.currencyButton.setTitle("\(currency)  ", for: .normal)
    }
}

