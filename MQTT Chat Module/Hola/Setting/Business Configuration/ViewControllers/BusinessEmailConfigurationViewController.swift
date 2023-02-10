
//
//  BusinessEmailConfigurationViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 25/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit
import TextFieldEffects
class BusinessEmailConfigurationViewController: UIViewController ,UIGestureRecognizerDelegate{
    
    //MARK:- Variables&Declarations
    let businessEmailConfigurationVmObject = BusinessEmailConfigurationViewModel()
    @IBOutlet weak var errorLabel: UILabel!
    var loginViewModel : LoginViewModel = LoginViewModel.init(api: LoginAPI())
    var email:String?
    var isEmailVisible:Bool?
    var visibleEmail = true
    var isChangingEmail:String?
    var isEmailVisibleInt:Double?
    var isMobileNumberVisible:Double?
    var businessCategoryId = ""
    var isChangedVisible:Bool = false
    var isFromEditBusniess:Bool = false
    var emailForTest:String = ""
    var isSwitchChanged:Bool = false

    
    //MARK:- Outlets
    @IBOutlet weak var emailTExtField: UITextField!
    @IBOutlet weak var visibleBtn: UISwitch!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGray
        
        if isFromEditBusniess {
            self.emailForTest = email ?? ""
            self.emailTExtField.text = email
            self.isChangingEmail = email
            self.businessEmailConfigurationVmObject.email = email
        }else {
            if let businessEmailDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessEmail) as? [String:Any]{
                if let email = businessEmailDetails["id"] as? String{
                    self.emailTExtField.text = email
                    self.email = email
                    self.isChangingEmail = email
                    self.businessEmailConfigurationVmObject.email = email
                }
            }else {
                self.emailTExtField.text = email
                 self.businessEmailConfigurationVmObject.email = email
            }
        }

        
        if let businessDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessDetails) as? [[String:Any]] {
            if let businessCategoryId = businessDetails.first?["businessCategoryId"] as? String {
                self.businessCategoryId = businessCategoryId
            }
        }
        
        if let businessPhoneDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessMobileNumber) as? [String:Any]{
            if let isNumberisVisible = businessPhoneDetails[Strings.isVisible] as? Bool{
                if isNumberisVisible {
                    self.isMobileNumberVisible = 1
                }else {
                    self.isMobileNumberVisible = 0
                }
            }
        }
        
        let doneBtn = UIBarButtonItem.init(title: Strings.save, style: .plain, target: self, action: #selector(nextAction))
        doneBtn.tintColor = .label
        self.navigationItem.rightBarButtonItem = doneBtn
        self.navigationItem.rightBarButtonItem?.isEnabled = false
     }
    
    override func viewWillAppear(_ animated: Bool) {
        if isEmailVisible == true {
            self.visibleBtn.isOn = true
            self.isEmailVisibleInt = 1
        }else{
            self.isEmailVisibleInt = 0
            self.visibleBtn.isOn = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
        
        self.emailTExtField.becomeFirstResponder()
    }
    
    /// Tap gesture To Ending view editing mode by typing anywhere
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    //MARK:- UIDesign
    func uiDesign(){
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Email Verification")
        self.emailTExtField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.emailTExtField.placeholder = Strings.email
        self.emailTExtField.font = Utility.Font.Regular.ofSize(17)
        let frame = self.emailTExtField.frame
        self.emailTExtField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
       
    }
    
    
    @objc func nextAction() {
        //         if self.isChangingEmail == email{
        //            changeEmailVisibleApiCall()
        //        }else {
        //            changeEmailVisibleApiCall()
        //
        //                    }
        self.errorLabel.text = ""
        if isFromEditBusniess {
            changeEmailVisibleApiCall()
        }else {
            if self.isChangingEmail == email && !isSwitchChanged{
                if let createBusinessVc = (self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessContactInfoViewController.self)}).first as? BusinessContactInfoViewController){
                    createBusinessVc.businessEmail = self.email
                    createBusinessVc.businessContactInfoVmObject.isEmailVisibleInt = self.isEmailVisibleInt
                    self.navigationController?.popToViewController(createBusinessVc, animated: true)
                    return
                }
                else {
                    emailConfigurationRequestOTP()
                }
            }else if isSwitchChanged{
                changeEmailVisibleApiCall()
            }
            else {
                emailConfigurationRequestOTP()
            }
        }
    }
    
    
    @IBAction func switchVisibleAction(_ sender: UISwitch) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        isSwitchChanged = true
        isChangedVisible = true
        
        if self.isChangingEmail == self.email{
         self.navigationItem.rightBarButtonItem?.title = "Save"
        }
        
         if visibleBtn.isOn {
            isEmailVisibleInt = 1
            self.visibleEmail = true
        }else {
            isEmailVisibleInt = 0
            self.visibleEmail = false
        }
    }

    /// Requesting OTP Via Email
    func emailConfigurationRequestOTP(){
        Helper.showPI()
        let url = AppConstants.bussinessEmailVerification
        self.businessEmailConfigurationVmObject.getEmailOtp(strUrl: url) { (success, error) in
            if success{
                  /// Pushing To BusinessVerificationViewController
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessVerificationViewControllerId) as! BusinessVerificationViewController
                verificationVc.isVisibleEmail   = self.visibleEmail
                verificationVc.businessEmailConfigDelegate = self
                verificationVc.viaEmailOrPhone = Strings.viaEmail
                verificationVc.isVisibleEmailInt = self.isEmailVisibleInt
                verificationVc.emailId = self.email
                self.navigationController?.pushViewController(verificationVc, animated: true)
            }else if let error = error{
                /*
                 Bug Name:- Add validation for email in business profile
                 Fix Date:- 23/04/21
                 Fix By  :- Jayaram G
                 Description of Fix:- Showing error if email already using by others
                 */
                if error.code == 409 {
                    self.errorLabel.text = "This email is linked to another business that is not linked to your profile , please use a different email to verify your business."
                }
//                Helper.showAlertViewOnWindow(Strings.error, message: error.localizedDescription)
            }
        }
        Helper.hidePI()
    }
  
    
    func changeEmailVisibleApiCall(){
        let params = ["isPhoneNumberVisible": self.isMobileNumberVisible as Any,
                      "businessCategoryId":self.businessCategoryId as Any,
                      "isEmailVisible":self.isEmailVisibleInt as Any] as [String : Any]
        UpdateProfileApi.updateVisibleMobileNumber(params: params) { (dict) in
            print("profile updated succefully")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshUserDetails), object: nil)
            if self.isChangingEmail == self.email{
                if let businessEditContactOptionsVc : BusinessEditContactOptionsViewController = self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessEditContactOptionsViewController.self)}).first as? BusinessEditContactOptionsViewController{
                    businessEditContactOptionsVc.email = self.email
                    //                businessEditContactOptionsVc.mobileNumber = self.mobileNumber
                    //                businessEditContactOptionsVc.countryCode = self.countryCode
                    self.navigationController?.popToViewController(businessEditContactOptionsVc, animated: true)
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }else {
                self.emailConfigurationRequestOTP()

            }
             Helper.hidePI()
        }
    }
}
    


//MARK:- Extensions

// MARK: - UITextFieldDelegate Methods
extension  BusinessEmailConfigurationViewController:UITextFieldDelegate,businessEmailConfigurationDelegate{
    
    func resendingOtpForEmailConfig() {
                Helper.showPI()
        let url = AppConstants.bussinessEmailVerification
        self.businessEmailConfigurationVmObject.getEmailOtp(strUrl: url) { (success, error) in
            if success{
                /// Pushing To BusinessVerificationViewController
                Helper.showAlertViewOnWindow(Strings.message.localized, message: "The verification code has been resent".localized + " , " + "please check your inbox".localized + ".")
                
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error, message: error.localizedDescription)
            }
        }
        Helper.hidePI()
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
        
        if txtAfterUpdate == self.isChangingEmail {
            if isChangedVisible {
                self.navigationItem.rightBarButtonItem?.title = "Save".localized
                
            }else {
                self.navigationItem.rightBarButtonItem?.title = "Next".localized

            }
        }else {
            self.navigationItem.rightBarButtonItem?.title = "Next".localized
        }

        if emailForTest == txtAfterUpdate && !isSwitchChanged {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        self.navigationItem.rightBarButtonItem?.tintColor = .label
        
       // guard let text = emailTExtField.text else{ return true}
        businessEmailConfigurationVmObject.email = txtAfterUpdate
        email = txtAfterUpdate
        return true
    }
}
