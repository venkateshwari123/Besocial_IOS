//
//  AddBankViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol AddBankVCDelegate{
    func bankAccountAdded()
}

class AddBankViewController: BaseViewController {
    
    @IBOutlet weak var bankCodePlaceHolderLabel: UILabel!
    @IBOutlet weak var accountNumberPlaceHolderLabel: UILabel!
    @IBOutlet weak var confirmAccountNumberHolderLabel: UILabel!
    
    @IBOutlet weak var bankCodeErrorLabel: UILabel!
    @IBOutlet weak var accountNumberErrorLabel: UILabel!
    @IBOutlet weak var confirmAccountNumberErrorLabel: UILabel!
    
    @IBOutlet weak var routingNumberTextField: UITextField!
    @IBOutlet weak var accountNumberTextfield: UITextField!
    @IBOutlet weak var accountHolderNameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bottomConstraintSaveButton: NSLayoutConstraint!
    
    
    let viewModel = AddBankViewModel()
    var delegate: AddBankVCDelegate?
    
    //Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unHideNavBar()
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
    
    func setUp(){
        title = "Add Bank Account"
        setNavigationLeftBarBackButton()
        routingNumberTextField.setTheme()
        accountNumberTextfield.setTheme()
        accountHolderNameTextField.setTheme()
        
        routingNumberTextField.delegate = self
        accountNumberTextfield.delegate = self
        accountHolderNameTextField.delegate = self
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss_Keyboard))
               self.view.addGestureRecognizer(tap)
        
        saveButton.layer.cornerRadius = saveButton.frame.height/2
        bankCodePlaceHolderLabel.font = Theme.getInstance().makeOfferPlaceHolderStyle.getFont()
        bankCodePlaceHolderLabel.textColor = Theme.getInstance().makeOfferPlaceHolderStyle.getTextColor()
        
        accountNumberPlaceHolderLabel.font = Theme.getInstance().makeOfferPlaceHolderStyle.getFont()
        accountNumberPlaceHolderLabel.textColor = Theme.getInstance().makeOfferPlaceHolderStyle.getTextColor()
        
        confirmAccountNumberHolderLabel.font = Theme.getInstance().makeOfferPlaceHolderStyle.getFont()
        confirmAccountNumberHolderLabel.textColor = Theme.getInstance().makeOfferPlaceHolderStyle.getTextColor()
        
        bankCodeErrorLabel.font = Theme.getInstance().errorLabelStyle.getFont()
        bankCodeErrorLabel.textColor = Theme.getInstance().errorLabelStyle.getTextColor()
        
        accountNumberErrorLabel.font = Theme.getInstance().errorLabelStyle.getFont()
        accountNumberErrorLabel.textColor = Theme.getInstance().errorLabelStyle.getTextColor()
        
        confirmAccountNumberErrorLabel.font = Theme.getInstance().errorLabelStyle.getFont()
        confirmAccountNumberErrorLabel.textColor = Theme.getInstance().errorLabelStyle.getTextColor()
        bankCodeErrorLabel.text = ""
        accountNumberErrorLabel.text = ""
        confirmAccountNumberErrorLabel.text = ""
    }
    
    @IBAction func saveButtonAction(){
        if validateTextFields(){
            viewModel.addBankAccount(accountHolderName: accountHolderNameTextField.text!, routingNumber: routingNumberTextField.text!, accountNo: accountNumberTextfield.text!) { _ in
                self.delegate?.bankAccountAdded()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
 
}


//Validation
extension AddBankViewController{
    func validateTextFields() -> Bool {
        if validateBankCodeTextField(), validateConfirmAccountTextfield(), validateConfirmAccountTextfield(){
            return true
        }
        return false
    }
    
    func validateBankCodeTextField() -> Bool {
        if routingNumberTextField.text == ""{
            bankCodeErrorLabel.text = "Enter Routing Number"
            return false
        }else if routingNumberTextField.text?.count != 9 {
            bankCodeErrorLabel.text = "Routing number should be 9 characters"
            return false
        }
        bankCodeErrorLabel.text = ""
        return true
    }
    
    func validateAccountNoTextField() -> Bool{
        if accountNumberTextfield.text == "" {
            accountNumberErrorLabel.text = "Enter account number"
            return false
        }
        accountNumberErrorLabel.text = ""
        return true
    }
    
    func validateConfirmAccountTextfield() -> Bool{
        if accountHolderNameTextField.text == "" {
            confirmAccountNumberErrorLabel.text = "Please Enter Account Holder Name"
            return false
        }
        confirmAccountNumberErrorLabel.text = ""
        return true
    }
}


