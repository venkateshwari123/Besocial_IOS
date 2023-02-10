//
//  EmailConfigurationViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/7/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
import TextFieldEffects
class EmailConfigurationViewController: UIViewController,UIGestureRecognizerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var emailTExtField: UITextField!
    @IBOutlet weak var visibleBtn: UISwitch!
    
    
    //MARK:- Declarations&Constants
    var emailConfigurationVMObject = EmailConfigurationViewModel()
    var email:String?
    var visibleEmail = false
    var visibleEmailInteger:Int?
    var emailForTest:String = ""
    var isSwitchChanged:Bool = false
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        let starUserDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.verifyProfileDetails) as? [String:Any]
        if let starUserEmail = starUserDetails?["starUserEmail"] as? String{
            self.emailTExtField.text = starUserEmail
            emailForTest = starUserEmail
            self.emailConfigurationVMObject.email = starUserEmail
            email = starUserEmail
            
        }
    }
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        uiDesign()
        if visibleEmailInteger == 1 {
            self.visibleBtn.isOn = true
        }else{
            self.visibleBtn.isOn = false
        }
     }
    
    override func viewDidAppear(_ animated: Bool) {
        emailTExtField.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    //MARK:- UIDesign
    func uiDesign(){
        self.emailTExtField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.emailTExtField.font = Utility.Font.Regular.ofSize(17)
        let frame = self.emailTExtField.frame
//        self.emailTExtField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Email Verification")
        let doneBtn = UIBarButtonItem.init(title: Strings.done.localized, style: .done, target: self, action: #selector(nextAction))
        doneBtn.tintColor = .label
        navigationItem.rightBarButtonItem = doneBtn
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
    @objc func nextAction() {
       emailConfigurationRequestOTP()
    }
    
//    //MARK:-Button actions
//    @IBAction func nextAction(_ sender: UIButton) {
//        emailConfigurationRequestOTP()
//    }
    
    @IBAction func visibleBtnAction(_ sender: UISwitch) {
        isSwitchChanged = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        if visibleBtn.isOn {
            self.visibleEmail = true
        }else {
            self.visibleEmail = false
        }
    }
    
    
    
    
    /// Requesting Otp For Email configuration
    func emailConfigurationRequestOTP(){
        Helper.showPI()
        let url = AppConstants.requestEmailVerification
        self.emailConfigurationVMObject.requestOtpCall(strUrl: url, type: 2) { (success, error) in
            if success{
                /// Pushing To VerificationViewController
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshUserDetails), object: nil)
                
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.verificationViewControllerId) as! VerificationViewController
                verificationVc.resendingEmailConfigDelegate = self
                verificationVc.viaEmailOrPhone = Strings.viaEmail
                verificationVc.emailId = self.emailTExtField.text!
                verificationVc.isVisibleEmail = self.visibleEmail
                verificationVc.isStarConfiguration = true
                self.navigationController?.pushViewController(verificationVc, animated: true)
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
        Helper.hidePI()
    }
    
    
    /// Requesting Otp For Email configuration
    func resendingEmailOtp(){
       
        let url = AppConstants.requestEmailVerification
        self.emailConfigurationVMObject.requestOtpCall(strUrl: url, type: 2) { (success, error) in
            if success{
                /// Pushing To VerificationViewController
                Helper.showAlertViewOnWindow(Strings.message.localized, message: "The verification code has been resent , please check your inbox.")
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error, message: error.localizedDescription)
            }
              Helper.hidePI()
        }
      
    }
    
    
}

//MARK:- Extensions
// MARK: - UITextFieldDelegate
extension EmailConfigurationViewController:UITextFieldDelegate,emailConfigurationDelegate{
    func resendingOtpForEmailConfig() {
         resendingEmailOtp()
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
        emailConfigurationVMObject.email = txtAfterUpdate
        email = txtAfterUpdate
        if emailForTest == txtAfterUpdate && !isSwitchChanged {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        return true
    }
    
    
}
