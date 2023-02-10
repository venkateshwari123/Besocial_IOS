//
//  verifyUserEmailViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 22/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit
import TextFieldEffects

class verifyUserEmailViewController: UIViewController,UIGestureRecognizerDelegate{
    
    
    //MARK:- Outlets
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var visibleBtn: UISwitch!
    
    
    //MARK:- Declarations&Constants
    var strEmail : String = ""                     // Used To Store The Email
    var emailConfigurationVMObject = EmailConfigurationViewModel() // Used To Get the reference of the EmailConfigurationViewModel Object
    var visibleEmail = false
    var visibleEmailInteger:Int?
    var isSwitchChanged:Bool = false
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
        emailTextField.text = strEmail
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if visibleEmailInteger == 1 {
            self.visibleBtn.isOn = true
        }else {
            self.visibleBtn.isOn = false
        }
        }
    
    override func viewDidAppear(_ animated: Bool) {
        self.emailTextField.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    //MARK:- UIDesign
    func uiDesign(){
        self.emailTextField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        
        
        self.emailTextField.font = Utility.Font.Regular.ofSize(17)
        let frame = self.emailTextField.frame
        self.emailTextField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Verify Email Address")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: Strings.done.localized, style: .done, target: self, action: #selector(nextAction))
        
    }
    
    
    @objc func nextAction() {
          emailConfigurationRequestOTP()
    }
    
    
    @IBAction func emailVisibleAction(_ sender: UISwitch) {
        isSwitchChanged = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        if visibleBtn.isOn {
            self.visibleEmail = true
        }else {
            self.visibleEmail = false
        }
    }
    
    
    
    
    /// Requesting For OTP ViaEmail
    func emailConfigurationRequestOTP(){
        Helper.showPI()
        let url = AppConstants.requestEmailVerification
        self.emailConfigurationVMObject.email = emailTextField.text ?? ""
        self.emailConfigurationVMObject.requestOtpCall(strUrl: url, type: 1) { (success, error) in
            if success{
                
                /// Pushing To Verification ViewController
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.verificationViewControllerId) as! VerificationViewController
                verificationVc.resendOtpEmailDelegate = self
                verificationVc.viaEmailOrPhone = Strings.viaEmail
                verificationVc.isVisibleEmail = self.visibleEmail
                verificationVc.emailId = self.emailTextField.text!
                verificationVc.isStarConfiguration = true
                self.navigationController?.pushViewController(verificationVc, animated: true)
                
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
        Helper.hidePI()
    }
}
// MARK: - UITextFieldDelegate
extension verifyUserEmailViewController:UITextFieldDelegate,verifyUserEmailDelagate{
    func resendingOtpFunc(){

        let url = AppConstants.requestEmailVerification
        self.emailConfigurationVMObject.email = emailTextField.text ?? ""
        self.emailConfigurationVMObject.requestOtpCall(strUrl: url, type: 1) { (success, error) in
            if success{
                Helper.showAlertViewOnWindow(Strings.message.localized, message: "The verification code has been resent , please check your inbox.")
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
            Helper.hidePI()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        if txtAfterUpdate == self.strEmail && !isSwitchChanged {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        return true
    }
}
