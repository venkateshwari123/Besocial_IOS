//
//  RechargeViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 02/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol RechargeViewControllerDelegate {
    func rechargeSuccess()
}

class RechargeViewController: BaseViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var rechargeAmountStaticlabel: UILabel!
    @IBOutlet weak var suggestionStaticLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var cardTypeImageView: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var bottomConstraintConfirmButton: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var currencyCodeLbl: UILabel!
    
    var delegate: RechargeViewControllerDelegate?
    let viewModel = RechargeViewModel()
    var itemNumber:Int = 0
    
    //life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp(){
        titleLabel.text = "Recharge".localized
        changeButton.setTitle("Change".localized, for: .normal)
        suggestionStaticLabel.text = "Suggestion".localized
        /*
         Bug Name:- make recharge text in bold in the wallet recharge page
         Fix Date:- 28/06/21
         Fix By  :- jayaram G
         Description of Fix:- changed font style
         */
        titleLabel.font = Utility.Font.Bold.ofSize(17)
        confirmButton.titleLabel?.font = Theme.getInstance().promotionBuyButtonStyle.getFont()
        confirmButton.layer.cornerRadius = confirmButton.frame.height/2
        confirmButton.setTitle("Confirm".localized, for: .normal)
        //titleLabel.textColor = Theme.getInstance().navBartitleStyle.getTextColor()
        titleLabel.textColor = UIColor.setColor(lightMode: AppColourStr.descriptionLabel, darkMode: "#FFFFFF")
        rechargeAmountStaticlabel.font = Theme.getInstance().popupMessageStyle.getFont()
        //rechargeAmountStaticlabel.textColor = Theme.getInstance().popupMessageStyle.getTextColor()
        rechargeAmountStaticlabel.textColor = UIColor.setColor(lightMode: AppColourStr.descriptionLabel, darkMode: "#FFFFFF")
        rechargeAmountStaticlabel.text = "Recharge Amount".localized
        amountTextField.font = Theme.getInstance().addAddressButtonStyle.getFont()
     //   amountTextField.tintColor = .darkGray
        amountTextField.tintColor = UIColor.setColor(lightMode: AppColourStr.descriptionLabel, darkMode: "#FFFFFF")
        amountTextField.font = Theme.getInstance().walletRechargeAmountStyle.getFont()
        //amountTextField.textColor = Theme.getInstance().walletRechargeAmountStyle.getTextColor()
        amountTextField.textColor =  UIColor.setColor(lightMode: AppColourStr.descriptionLabel, darkMode: "#FFFFFF")
        amountTextField.placeholder = "Enter".localized + " " + "Amount".localized
        cardNumberLabel.font = Theme.getInstance().walletCardNoStyle.getFont()
       //cardNumberLabel.textColor = Theme.getInstance().walletCardNoStyle.getTextColor()
        cardNumberLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
        errorLabel.text = ""
        errorLabel.font = Theme.getInstance().errorLabelStyle.getFont()
        errorLabel.textColor = Theme.getInstance().errorLabelStyle.getTextColor()
        
        cardTypeImageView.image = viewModel.selectedCard.brand ?? nil
        cardNumberLabel.text = (viewModel.selectedCard.last4 ?? "")
        currencyButton.setTitle(Utility.getWalletCurreny(), for: .normal)
        currencyCodeLbl.text = Utility.getWalletCurrenySymbol()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss_Keyboard))
       // self.view.addGestureRecognizer(tap)
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        amountTextField.resignFirstResponder()
        if validateAmountTextField(){
            askForConfirmation()
        }
    }
    
    @IBAction func changeButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func askForConfirmation(){
        guard let confirmationVC = UIStoryboard(name: "DeleteProfile", bundle: nil).instantiateViewController(withIdentifier: "DeactivateConfirmationViewController") as? DeactivateConfirmationViewController else {return}
        confirmationVC.modalPresentationStyle = .overCurrentContext
        confirmationVC.setPageDetails(title: "Confirm".localized + " " + "Recharge".localized, description: "Are you sure you want to recharge the wallet with".localized + " \(Utility.getWalletCurrenySymbol())\(self.amountTextField.text!) ?", whiteButtonText: "No".localized, blueButtonText: "Yes".localized)
        confirmationVC.delegate = self
        self.present(confirmationVC, animated: true)
    }
    
    func validateAmountTextField() -> Bool{
        if amountTextField.text == "" {
            errorLabel.text = "Please enter Amount"
            return false
        }
        
        if let intAmount = Int(amountTextField.text ?? ""), intAmount <= 0{
            errorLabel.text = "Enter valid Amount"
            return false
        }
        errorLabel.text = ""
        return true
    }
}


extension RechargeViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{return false}
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        if !Helper.decimalValidation(txtAfterUpdate: txtAfterUpdate) {
            return false
        }
        return txtAfterUpdate.length <= 5
    }
}

extension RechargeViewController: DeactivateConfirmationViewControllerDelegate{
    func confirm() {
        Helper.showPI(string: "", showLabel: false)
        viewModel.rechargeWallet(amount: amountTextField.text!) { _ in
            Helper.hidePI()
             self.navigateToSuccessScreen()
        }
    }
    
    func navigateToSuccessScreen() {
        guard let rechargeSuccessVC = UIStoryboard(name: "RechargeSuccess", bundle: nil).instantiateViewController(withIdentifier: "RechargeSuccessViewController") as? TransactionDetailViewController else { return }
        rechargeSuccessVC.modalPresentationStyle = .overCurrentContext
        rechargeSuccessVC.delegate = self
        rechargeSuccessVC.viewModel.needToCallApi = false
        rechargeSuccessVC.viewModel.transaction = viewModel.transaction
        rechargeSuccessVC.viewModel.selectedSuccessType = .recharge
        self.present(rechargeSuccessVC, animated: true)
    }
}

extension RechargeViewController: TransactionDetailViewControllerDelegate{
    func donePressed() {
        if let viewControllers = self.navigationController?.viewControllers{
            for vc in viewControllers.reversed(){
                if vc.isKind(of: WalletViewController.self){
                    delegate?.rechargeSuccess()
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
                if vc.isKind(of: ProfileViewController.self){
                    delegate?.rechargeSuccess()
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
    }
}



extension RechargeViewController:UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RechargeSuggetionsCell", for: indexPath) as! RechargeSuggetionsCell
        if indexPath.item == itemNumber{
           
            Helper.provideBoderAndCornerReadiusForView(view: cell.backView, radius: 3, borderColor:0xB4DBFF,backgroundColor:0xEAF5FF )
            cell.moneyLabel.textColor = Helper.UIColorFromRGB(rgbValue: 0x3897F0)
        }else {
           
            Helper.provideBoderAndCornerReadiusForView(view: cell.backView, radius: 3, borderColor: 0xE5E8EA,backgroundColor:0xEFF3F7 )
            cell.moneyLabel.textColor = Helper.UIColorFromRGB(rgbValue: 0x464646)
        }
         switch indexPath.item {
        case 0:
            cell.moneyLabel.text = "\(Utility.getWalletCurrenySymbol()) " + "100"
        case 1:
            cell.moneyLabel.text = "\(Utility.getWalletCurrenySymbol()) " + "250"
        case 2:
            cell.moneyLabel.text = "\(Utility.getWalletCurrenySymbol()) " + "500"
        default:
            cell.moneyLabel.text = "\(Utility.getWalletCurrenySymbol()) " + "1000"
        }
        switch itemNumber {
        case 0:
            amountTextField.text =  "100"
        case 1:
            amountTextField.text =  "250"
        case 2:
            amountTextField.text =  "500"
        default:
            amountTextField.text =  "1000"
        }
    
        return cell
    }
}



//MARK:- CollectionView Delegate FlowLayout
extension RechargeViewController:UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     return CGSize(width: self.view.frame.width / 4 - 20, height: 40)
    }
}

//MARK:- CollectionView Delegate
extension RechargeViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemNumber = indexPath.item
        collectionView.reloadData()
    }
}

 

