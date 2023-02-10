//
//  UpdateEmailViewController.swift
//  Starchat
//
//  Created by 3Embed on 03/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

/*
 Feat Name:- should navigate to other page on click of business username,name and website
 Feat Date:- 03/05/21
 Feat By  :- Nikunj C
 Description of Feat:- require protocol and changes
 */
enum UpdateFieldType : Int
{
    case firstName = 1, lastName, userName, bio, email, mobile, knownAs
    case none
}

enum UpdateBusinessFieldType: Int
{
    case businessUserName = 1,BusinessName, email, mobile,businessWebsite,about
    case none
}

protocol UpdateEmailViewControllerDelegate : NSObjectProtocol {
    func updateDone(fieldType : UpdateBusinessFieldType, value : String)
    func updateDone(fieldType : UpdateFieldType, value : String)
    func updateDone(fieldType : UpdateFieldType, value : String, countryCode : String)
    func updateDone(fieldType : UpdateBusinessFieldType, value : String, countryCode : String)
}



class UpdateEmailViewController: UIViewController {
    
    /// Outlets
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var fieldLabel : UILabel!
    @IBOutlet weak var mobileNoTextFiled : UITextField!
    
    @IBOutlet weak var emailView : UIView!
    @IBOutlet weak var mobileView : UIView!
    
    @IBOutlet weak var nextButton : UIButton!
    @IBOutlet weak var errorLabel : UILabel!
    
    @IBOutlet weak var checkemailImageView : UIImageView!
    @IBOutlet weak var checkMobileImageView : UIImageView!
    @IBOutlet weak var stackViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var userNameVerificationView: UIView!
    
    /// Variables and Declarations
    var email:String?
    var value : String?
    var isForBusinessProfie:Bool = false
    var isFromBussinessCreate = false
    var emailConfigurationVMObject = EmailConfigurationViewModel()
    var currentUpdateField : UpdateFieldType = .firstName
    var currentBusinessField: UpdateBusinessFieldType = .businessUserName
    var updateEmailPhoneVMObject = UpdateEmailPhoneViewModel()
    weak var delegate : UpdateEmailViewControllerDelegate?
   
    @IBOutlet weak var contryCodeButton: UIButton!
    
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    

    var strCountryCode : String? = "+91"
    var coutryRegionName:String = ""
    var countryName:String = "IN"
    var oldMobileNumber : String?
    var oldCountryCode : String?
    
    var oldEmail : String?
    var oldUserName : String?
    
    var isMobileValid = false
    {
        didSet{
            checkMobileImageView.image = UIImage(named: self.isMobileValid ? "Success_Check" : "cross")
            checkMobileImageView.isUserInteractionEnabled = !self.isMobileValid
            errorLabel.isHidden = isMobileValid
            checkMobileImageView.isHidden = isMobileValid
            stackViewHeightConstraint.constant =   35
        }
    }
    
    var isEmailValid = false
    {
        didSet{
            checkemailImageView.image = UIImage(named: self.isEmailValid ? "Success_Check" : "cross")
            checkemailImageView.isUserInteractionEnabled = !self.isEmailValid
            errorLabel.isHidden = isEmailValid
            checkemailImageView.isHidden  = isEmailValid
            stackViewHeightConstraint.constant =  35
        }
    }
   
    
    /// View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mobileNoTextFiled.delegate = self
        tfEmail.delegate = self
        errorLabel.isHidden = true
        stackViewHeightConstraint.constant = 35
        verifiedLabel.text = "Username".localized + " " + "verified".localized
        mobileNoTextFiled.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tfEmail.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        nextButton.layer.cornerRadius = 16
        
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(tapGestureViewHandle))
         view.addGestureRecognizer(tapGestureView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkemailImageViewTapGesture))
        checkemailImageView.addGestureRecognizer(tapGesture)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(checkMobileImageViewTapGesture))
        checkMobileImageView.addGestureRecognizer(tapGesture1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        tfEmail.text = value
        emailView.isHidden = true
        mobileView.isHidden = true
        contryCodeButton.isHidden = true
        nextButton.setTitle("Save".localized, for: UIControl.State.normal)
        nextButton.isEnabled = false
        nextButton.backgroundColor = .lightGray
        
        switch currentUpdateField {
        case .firstName:
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Edit".localized + " " + "First Name".localized)
            fieldLabel.text =  "First Name".localized
            emailView.isHidden = false
        case .lastName:
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Edit".localized + " " + "Last Name".localized)
            fieldLabel.text = "Last Name".localized
            emailView.isHidden = false
        case .userName:
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Edit".localized + " " + "Username".localized)
            userNameVerificationView.isHidden = false
            fieldLabel.text = "Username".localized
            emailView.isHidden = false
            
            setNextButtonStatus(isStatus: false)
            oldUserName = email
        case .knownAs:
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Edit".localized + " " + "KnownAs".localized)
            fieldLabel.text = "KnownAs".localized
            emailView.isHidden = false
        case .email:
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Edit".localized + " " + Strings.emailVeirfication.localized)
            fieldLabel.text = Strings.emailVeirfication.localized
            tfEmail.text = email
            oldEmail = email
            emailView.isHidden = false
            nextButton.setTitle("Next".localized, for: UIControl.State.normal)
        case .mobile:
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Edit".localized + " " + "Contact Number".localized)
            fieldLabel.text = "Contact Number".localized
            mobileNoTextFiled.text = value!
            
            oldMobileNumber = value
            mobileView.isHidden = false
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightGray
            contryCodeButton.isHidden = false
            nextButton.setTitle("Next".localized, for: UIControl.State.normal)
            oldCountryCode = strCountryCode
        default:
            break
        }
        
        /*
         Feat Name:- should navigate to other page on click of business username,name and website
         Feat Date:- 03/05/21
         Feat By  :- Nikunj C
         Description of Feat:- initial setup for business profile
         */
        
        switch currentBusinessField {
        case .businessUserName:
            let tilte =  isFromBussinessCreate ?  "Business User Name".localized  : "Edit".localized + " " + "Business User Name".localized
            self.userNameVerificationView.isHidden = isFromBussinessCreate ?  true  : false
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: tilte)
            fieldLabel.text =  "Business User Name".localized
            emailView.isHidden = false
        case .BusinessName:
            let tilte =  isFromBussinessCreate ?  "Business Name".localized  : "Edit".localized + " " + "Business Name".localized
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: tilte)
            fieldLabel.text =  "Business Name".localized
            emailView.isHidden = false
        case .businessWebsite:
            let tilte =  isFromBussinessCreate ?  "Business Website".localized  : "Edit".localized + " " + "Business Website".localized
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: tilte)
            fieldLabel.text =  "Business Website".localized
            emailView.isHidden = false
        case .email:
            let tilte =  isFromBussinessCreate ?  "Business Email".localized  : "Edit".localized + " " + "Business Email".localized
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: tilte)
            fieldLabel.text =  "Business Email".localized
            emailView.isHidden = false
        case .mobile:
            let tilte =  isFromBussinessCreate ?  "Business Number".localized  : "Edit".localized + " " + "Business Number".localized
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: tilte)
            fieldLabel.text = "Contact Number".localized
            mobileNoTextFiled.text = value ?? ""
            oldMobileNumber = value
            mobileView.isHidden = false
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightGray
            contryCodeButton.isHidden = false
            self.contryCodeButton.setTitle(strCountryCode ?? "+91", for: .normal)
            nextButton.setTitle("Next".localized, for: UIControl.State.normal)
            oldCountryCode = strCountryCode
        case .about:
            let tilte =  isFromBussinessCreate ?  "Business About".localized  : "Edit".localized + " " + "Business About".localized
            self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: tilte)
            fieldLabel.text =  "Business About".localized
            emailView.isHidden = false
        default:
            break
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /*
         Bug Name:- keyboard not open for business profile
         Fix Date:- 12/06/21
         Fixed By:- Nikunj C
         Description of Fix:- add required condtion
         */
        
        if currentUpdateField == .mobile || currentBusinessField == .mobile {
            mobileNoTextFiled.becomeFirstResponder()
        }else{
            tfEmail.becomeFirstResponder()
        }
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
        NotificationCenter.default.removeObserver(self)
    }
    
    func setNextButtonStatus(isStatus : Bool)
    {
        nextButton.isEnabled = isStatus
        nextButton.backgroundColor = isStatus ? Utility.appColor() : .lightGray
    }
    
   
    // To manage view height according to keyboard height
    ///
    /// - Parameter notification: keyboard notification object
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y + 20
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                self.nextButtonBottomConstraint.constant = keyboardHeight
            }, completion: nil)
            view.layoutIfNeeded()
        }
    }
    
    
    @objc func tapGestureViewHandle( _ gesture : UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func checkemailImageViewTapGesture( _ gesture : UITapGestureRecognizer){
        tfEmail.text = ""
        errorLabel.isHidden = true
        checkemailImageView.isHidden = true
    }
    
    @objc func checkMobileImageViewTapGesture( _ gesture : UITapGestureRecognizer){
        mobileNoTextFiled.text = ""
        errorLabel.isHidden = true
        checkMobileImageView.isHidden = true
    }
    
    @IBAction func contryCodeButtonAction(_ sender: UIButton) {
        let countryPicker = CountryPickerVC.instantiate(storyBoardName: "Authentication") as CountryPickerVC
        countryPicker.currentCountryCode = self.strCountryCode
        countryPicker.countryDataDelegate = self
        present(countryPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func btnNext_Tapped(_ sender: Any) {
        
        /*
         Feat Name:- should navigate to other page on click of business username,name and website
         Feat Date:- 03/05/21
         Feat By  :- Nikunj C
         Description of Feat:- require action for business profile
         */
        
        if isFromBussinessCreate {
            if currentBusinessField == .mobile && isMobileValid {
                delegate?.updateDone(fieldType: currentBusinessField, value: mobileNoTextFiled.text ?? "", countryCode : strCountryCode ?? "+91")
            }
            else
            {
                if isEmailValid {
                    delegate?.updateDone(fieldType: currentBusinessField, value: tfEmail.text ?? "" )
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
        else  if isForBusinessProfie{
            if currentBusinessField == .businessUserName{
                if isEmailValid{
                    /*
                     Refactor Name:- update profile while save value
                     Refactor Date:- 19/05/21
                     Refactor By  :- Nikunj C
                     Description of Refactor:- call profile api to update value
                     */
                    let  businessUniqueId  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessUniqueId) as? String ?? ""
                    
                    let params = [Strings.businessUserNameKey:tfEmail.text!,
                                  "businessUniqueId" : businessUniqueId]
                    delegate?.updateDone(fieldType: currentBusinessField, value: tfEmail.text!)
                    self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            }
            else if currentBusinessField == .BusinessName{
                if isEmailValid{
                    /*
                     Refactor Name:- update profile while save value
                     Refactor Date:- 19/05/21
                     Refactor By  :- Nikunj C
                     Description of Refactor:- call profile api to update value
                     */
                    let  businessUniqueId  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessUniqueId) as? String ?? ""
                    
                    let params = [Strings.businessNameKey:tfEmail.text!,
                                  "businessUniqueId" : businessUniqueId]
                    delegate?.updateDone(fieldType: currentBusinessField, value: tfEmail.text!)
                    self.navigationController?.popViewController(animated: true)
                    self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }else if currentBusinessField == .businessWebsite{
                if isEmailValid{
                    /*
                     Refactor Name:- update profile while save value
                     Refactor Date:- 19/05/21
                     Refactor By  :- Nikunj C
                     Description of Refactor:- call profile api to update value
                     */
                    let  businessUniqueId  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessUniqueId) as? String ?? ""

                    let params = [Strings.businessWebsite:tfEmail.text!,"businessUniqueId":businessUniqueId]
                    delegate?.updateDone(fieldType: currentBusinessField, value: tfEmail.text!)
                    self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            else{
                if isEmailValid{
                    /*
                     Refactor Name:- update profile while save value
                     Refactor Date:- 19/05/21
                     Refactor By  :- Nikunj C
                     Description of Refactor:- call profile api to update value
                     */
                    let params = [Strings.businessEmail:tfEmail.text!]
                    self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                        self.navigationController?.popViewController(animated: true)
                    }
                    delegate?.updateDone(fieldType: currentBusinessField, value: tfEmail.text!)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }else{
            if currentUpdateField == .email
            {
                if isEmailValid
                {
                    let updateFieldModel = UpdateViewModel()
                    updateFieldModel.sendOTP(updateType: .email,  email: tfEmail.text){ [self] (OtpId, err) in
                        if err != nil
                        {
                            Helper.showAlert(head: "", message: err!)
                            return
                        }
                        /*
                         Refactor Name:- update profile while save value
                         Refactor Date:- 19/05/21
                         Refactor By  :- Nikunj C
                         Description of Refactor:- call profile api to update value
                         */
                        let params = [Strings.emailKey:tfEmail.text!]
                        self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                            self.navigationController?.popViewController(animated: true)
                        }
                        delegate?.updateDone(fieldType : currentUpdateField , value : tfEmail.text! )
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }
            }
            else if currentUpdateField == .userName
            {
                if isEmailValid {
                    /*
                     Refactor Name:- update profile while save value
                     Refactor Date:- 19/05/21
                     Refactor By  :- Nikunj C
                     Description of Refactor:- call profile api to update value
                     */
                    let params = [Strings.userNameKey:tfEmail.text!]
                    self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                        self.navigationController?.popViewController(animated: true)
                    }
                    delegate?.updateDone(fieldType: currentUpdateField, value: tfEmail.text!)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else if currentUpdateField == .lastName
            {
                /*
                 Refactor Name:- update profile while save value
                 Refactor Date:- 19/05/21
                 Refactor By  :- Nikunj C
                 Description of Refactor:- call profile api to update value
                 */
                let params = [Strings.lastName:tfEmail.text!]
                self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                    self.navigationController?.popViewController(animated: true)
                }
                delegate?.updateDone(fieldType : currentUpdateField , value : tfEmail.text! )
                self.navigationController?.popViewController(animated: true)
            }
            else if currentUpdateField == .firstName
            {
                /*
                 Refactor Name:- update profile while save value
                 Refactor Date:- 19/05/21
                 Refactor By  :- Nikunj C
                 Description of Refactor:- call profile api to update value
                 */
                let params = [Strings.firstName:tfEmail.text!]
                self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                    self.navigationController?.popViewController(animated: true)
                }
                delegate?.updateDone(fieldType : currentUpdateField , value : tfEmail.text! )
                self.navigationController?.popViewController(animated: true)
            }else if currentUpdateField == .mobile
            {
                if isMobileValid
                {
                    let params = [Strings.mobile:self.mobileNoTextFiled.text!,Strings.countryCode:self.strCountryCode]
                    self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            let updateFieldModel = UpdateViewModel()
                            updateFieldModel.sendOTP(updateType: .phoneNumber,  phoneNumber:  self.mobileNoTextFiled.text!, countryCode: self.strCountryCode){ (OtpId, err) in
                                if err != nil
                                {
                                    Helper.showAlert(head: "", message: err!)
                                    return
                                }
                                let vc = VerificationVC.instantiate(storyBoardName: "Authentication") as VerificationVC
                                vc.verificationData = VerificationData(countryCode: self.strCountryCode!, phoneNumber: self.mobileNoTextFiled.text!, otpId: "")
                                vc.verificationType = .updateMobile
                                vc.phoneNumber = self.mobileNoTextFiled.text!
                                vc.counrtyCode = self.strCountryCode
                                vc.isFromEditProfile = true
                                vc.countryName = self.countryName
                                vc.userEnteredNumber = self.strCountryCode!+self.mobileNoTextFiled.text!
                                vc.delegate = self
                                let navigationControler = UINavigationController(rootViewController: vc)
                                navigationControler.modalPresentationStyle = .overCurrentContext
                                self.present(navigationControler, animated: true, completion: nil)
                            }
                        }
                    }
                }
               
            }else if currentUpdateField == .knownAs{
                /*
                 Bug Name:- Not able to edit konwn as in edit user profile page
                 Fix Date:- 12th Jul 2021
                 Fixed By  :- Nikunj C
                 Description of Fix:- update known as value
                 */
                let params = [Strings.starUserKnownBy:tfEmail.text!]
                self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                    self.navigationController?.popViewController(animated: true)
                }
                delegate?.updateDone(fieldType : currentUpdateField , value : tfEmail.text! )
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                /*
                 Refactor Name:- update profile while save value
                 Refactor Date:- 19/05/21
                 Refactor By  :- Nikunj C
                 Description of Refactor:- call profile api to update value
                 */
                let params = ["":tfEmail.text!]
                self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                    self.navigationController?.popViewController(animated: true)
                }
                delegate?.updateDone(fieldType : currentUpdateField , value : tfEmail.text! )
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    func emailConfigurationRequestOTP(){
        Helper.showPI()
        let url = AppConstants.requestEmailVerification
        self.emailConfigurationVMObject.email = tfEmail.text!
        self.emailConfigurationVMObject.requestOtpCall(strUrl: url, type: 2) { (success, error) in
            if success{
                /// Pushing To VerificationViewController
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.verificationViewControllerId) as! VerificationViewController
                verificationVc.viaEmailOrPhone = Strings.viaEmail
                verificationVc.isStarConfiguration = false
                verificationVc.emailId = self.tfEmail.text!
                self.navigationController?.pushViewController(verificationVc, animated: true)
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
        Helper.hidePI()
    }
    
    
    
    
}


extension UpdateEmailViewController  :  UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.userNameVerificationView.isHidden = true
        if currentUpdateField == .userName {
           let cs = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz_.").inverted
           let filtered = string.components(separatedBy: cs).joined(separator: "")
           return (string == filtered)
       }else if  currentBusinessField == .businessUserName || currentUpdateField == .knownAs{
            let cs = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.").inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered)
        }
        else if (currentUpdateField == .firstName || currentUpdateField == .lastName)
        {
            let cs = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered)
        }
        return true
    }
    
    
    
    fileprivate func checkMobileNoIsExits() {
        let loginViewModel = LoginViewModel(api: LoginAPI())
        loginViewModel.validateRegisteration(type: .phonenumber ,number: mobileNoTextFiled.text!  , dialCode: strCountryCode) { [self] (isSucces, erorr,errorCode) in
            if erorr != nil
            {
                self.isMobileValid = true
                setNextButtonStatus(isStatus: true)
                return
            }
            if isSucces {
                self.isMobileValid = false
                self.errorLabel.text = "Entered".localized + " " + "phone number".localized + " " + "is already registered".localized + "."
                setNextButtonStatus(isStatus: false)
                return
            }
            else
            {
                if errorCode == 204 {
                    self.isMobileValid = true
                    self.setNextButtonStatus(isStatus: true)
                }
                
            }
        }
    }
    
    @objc fileprivate func createBunessionValidation() {
      
        if currentBusinessField == .businessUserName {
            
            if (tfEmail.text?.isEmpty ?? true) {
                self.isEmailValid = false
                errorLabel.text =  ""
                checkemailImageView.isHidden = true
                setNextButtonStatus(isStatus: false)
                return
            }
            
            if tfEmail.text == value {
                self.isEmailValid = false
                errorLabel.text =  "Please enter".localized + " " + "new business username".localized + "."
                setNextButtonStatus(isStatus: false)
            }
            else {
                if (tfEmail.text?.count ?? 0) > 2 {
                    chekcUserNameIsExtstis()
                }
                else {
                    self.isEmailValid = false
                    setNextButtonStatus(isStatus: false)
                }
                
            }
        }
        else if  currentBusinessField == .email {
            guard tfEmail.text?.isEmpty == false else {
                self.isEmailValid = false
                errorLabel.text =  ""
                checkemailImageView.isHidden = true
                return
            }
            
            if !Helper.isValidEmail(emailText: tfEmail.text!) {
                self.isEmailValid = false
                errorLabel.text =  "Please enter".localized + " " + "valid".localized + "email id".localized + "."
                setNextButtonStatus(isStatus: false)
            }
            else
            {
                checkBunessionEmail()
            }
         }
        
        else if currentBusinessField == .mobile {
            guard mobileNoTextFiled.text?.isEmpty == false else {
                self.isMobileValid = false
                errorLabel.text =  ""
                checkMobileImageView.isHidden = true
                return
            }
            
            if !Helper.isValidNumber("\(strCountryCode ?? "+91")" + (mobileNoTextFiled.text!)){
                isMobileValid = false
                setNextButtonStatus(isStatus: false)
                errorLabel.text =  "Please enter".localized + " " + "valid".localized + " " + "phone number".localized
            }
            else
            {
                checkBunessionMobile()
            }
        
        }
        
        else if currentBusinessField == .businessWebsite {
            if tfEmail.text?.isEmpty == true {
                self.isEmailValid = false
                errorLabel.text =  ""
                checkemailImageView.isHidden = true
                self.setNextButtonStatus(isStatus: false)
            }
            else{
                if Helper.isValidWebsite(websiteText: tfEmail.text!) {
                    self.isEmailValid = true
                    self.setNextButtonStatus(isStatus: true)
                }
                else {
                    self.isEmailValid = false
                    self.errorLabel.text = "Please enter".localized + " " + "vaild".localized + " " + "business website".localized
                    self.setNextButtonStatus(isStatus: false)
                }
                
            }
        }
        else if currentBusinessField == .about {
            if tfEmail.text?.isEmpty == true {
                self.isEmailValid = false
                self.errorLabel.text = "Please enter".localized + "about the business".localized
                self.setNextButtonStatus(isStatus: false)
            }
            else{
                self.isEmailValid = true
                self.setNextButtonStatus(isStatus: true)
            }
        }
        else if currentBusinessField == .BusinessName {
            if tfEmail.text?.isEmpty == true {
                self.isEmailValid = false
                errorLabel.text =  ""
                checkemailImageView.isHidden = true
                self.setNextButtonStatus(isStatus: false)
            }
            else{
                self.isEmailValid = true
                self.setNextButtonStatus(isStatus: true)
            }
        }
        
    }
    
    @objc func textFieldDidChange( _ textField : UITextField)
     {
        if isFromBussinessCreate {
//            createBunessionValidation()
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(createBunessionValidation), object: nil)
            perform(#selector(createBunessionValidation), with: nil, afterDelay: 1)
            return
        }
         if textField == mobileNoTextFiled {
             if currentUpdateField == .mobile
             {
                if  mobileNoTextFiled.text!.count > 15
                 {
                     setNextButtonStatus(isStatus: false)
                     self.isMobileValid = false
                    errorLabel.text =  "Please enter".localized + " " + "valid".localized + "phone number".localized + "."
                 }
                 else
                 {
                     if mobileNoTextFiled.text == oldMobileNumber  && oldCountryCode == strCountryCode{
                         setNextButtonStatus(isStatus: false)
                        errorLabel.text =  "Please enter".localized + " " + "a new".localized + " " + "phone number".localized + " " + "and".localized + " " + "try again".localized + "."
                         self.isMobileValid = false
                     }
                     else
                     {
                         checkMobileNoIsExits()
                     }
                    
                 }
                 
                 
             }
         }
         else if textField == tfEmail {
             
             if currentUpdateField == .lastName{
                 setNextButtonStatus(isStatus: true)
             }else{
                 if (tfEmail.text?.isEmpty ?? true) {
                    setNextButtonStatus(isStatus: false)
                     return
                 }
             }
             
             if currentUpdateField == .firstName   {
                 if tfEmail.text == value {
                     setNextButtonStatus(isStatus: false)
                 }
                 else {
                     setNextButtonStatus(isStatus: true)
                 }
             }
             else  if  currentUpdateField == .userName
             {
                if (tfEmail.text?.isEmpty ?? true) {
                    self.isEmailValid = false
                    errorLabel.text =  "Please enter".localized + " " + "userName".localized + "."
                   setNextButtonStatus(isStatus: false)
                    return
                }
                
                if tfEmail.text == value {
                    self.isEmailValid = false
                    errorLabel.text =  "Please enter".localized + " " + "new".localized + " " + "userName".localized + "."
                    setNextButtonStatus(isStatus: false)
                }
                else {
                    if (tfEmail.text?.count ?? 0) > 2 {
                        chekcUserNameIsExtstis()
                    }
                    else {
                         self.isEmailValid = false
                        setNextButtonStatus(isStatus: false)
                    }
                    
                }
             }
             else  if  currentUpdateField == .knownAs
             {
                if (tfEmail.text?.isEmpty ?? true) {
                    self.isEmailValid = false
                    errorLabel.text =  "Please enter".localized + " " + "known as".localized + "."
                   setNextButtonStatus(isStatus: false)
                    return
                }else{
                    self.isEmailValid = true
                   setNextButtonStatus(isStatus: true)
                }
                
                
             }
             else if currentUpdateField == .email
             {
                if !Helper.isValidEmail(emailText: tfEmail.text!) {
                    self.isEmailValid = false
                    errorLabel.text =  Strings.pleaseEnterValidEmailId.localized
                    setNextButtonStatus(isStatus: false)
                }
                else
                {
                    if tfEmail.text == oldEmail {
                        errorLabel.text =  "Please enter".localized + "a new".localized + " " + "email".localized + " " + "and".localized + " " + "try again".localized + "."
                       self.isEmailValid = false
                        setNextButtonStatus(isStatus: false)
                    }
                    else {
                        checkEmailIdIsExitsts()
                    }
                }
                
                 
             }
             
             /*
              Feat Name:- should navigate to other page on click of business username,name and website
              Feat Date:- 03/05/21
              Feat By  :- Nikunj C
              Description of Feat:- require validation for business profile
              */
             
             else if currentBusinessField == .businessUserName{
                if (tfEmail.text?.isEmpty ?? true) {
                    self.isEmailValid = false
                    errorLabel.text =  "Please enter".localized + " " + "business username".localized + "."
                   setNextButtonStatus(isStatus: false)
                    return
                }
                
                if tfEmail.text == value {
                    self.isEmailValid = false
                    errorLabel.text =  "Please enter".localized + " " + "new".localized + " " + "business username".localized + "."
                    setNextButtonStatus(isStatus: false)
                }
                else {
                    if (tfEmail.text?.count ?? 0) > 2 {
                        chekcUserNameIsExtstis()
                    }
                    else {
                         self.isEmailValid = false
                        setNextButtonStatus(isStatus: false)
                    }
                }
             }
             else if currentBusinessField == .BusinessName{
                if (tfEmail.text?.isEmpty ?? true) {
                    self.isEmailValid = false
                    errorLabel.text =  "Please enter".localized + " " + "business name".localized + "."
                   setNextButtonStatus(isStatus: false)
                    return
                }
                
                if tfEmail.text == value {
                    self.isEmailValid = false
                    errorLabel.text =  "Please enter".localized + " " + "new".localized + " " + "business name".localized + "."
                    setNextButtonStatus(isStatus: false)
                }
                else {
                    self.isEmailValid = true
                    setNextButtonStatus(isStatus: true)
                }
             }
             else if currentBusinessField == .businessWebsite{
                if (tfEmail.text?.isEmpty ?? true) {
                    self.isEmailValid = false
                    errorLabel.text =  "Please enter".localized + " " + "business website".localized + "."
                   setNextButtonStatus(isStatus: false)
                    return
                }
                
                if tfEmail.text == value {
                    self.isEmailValid = false
                    errorLabel.text =  "Please enter".localized + " " + "new".localized + " " + "business website".localized + "."
                    setNextButtonStatus(isStatus: false)
                }
                else {
                    if Helper.isValidWebsite(websiteText: tfEmail.text ?? "") {
                        self.isEmailValid = true
                       setNextButtonStatus(isStatus: true)
                    }
                    else {
                         self.isEmailValid = false
                        setNextButtonStatus(isStatus: false)
                    }
                    
                }
             }
             
         }
     }
    
    
    fileprivate func checkBunessionEmail() {
        guard let email = tfEmail.text, email.isEmpty == false else {
            return
        }
        let bussesionVM = BusinessContactInfoViewModel()
        let params = ["email":email,"type":1] as [String : Any]
        
        bussesionVM.validateEmailPhone(strUrl: AppConstants.businessPhoneEmailValidate, params: params) { (strData, isSuccess, error) in
        
            if isSuccess
            {
                self.isEmailValid = false
                self.errorLabel.text = strData
                self.setNextButtonStatus(isStatus: false)
            }
            else
            {
                if error?.code == 204 {
                    self.isEmailValid = true
                    self.setNextButtonStatus(isStatus: true)
                }
            }
            
        }
    }
    
    
    fileprivate func checkBunessionMobile() {
        guard let mobile = mobileNoTextFiled.text, mobile.isEmpty == false else {
            return
        }
        let bussesionVM = BusinessContactInfoViewModel()
        let params = ["phone":mobile,"countryCode": self.strCountryCode ?? "+91","type":2] as [String : Any]
        
        bussesionVM.validateEmailPhone(strUrl: AppConstants.businessPhoneEmailValidate, params: params) { (strData, isSuccess, error) in
            if isSuccess
            {
                self.isMobileValid = false
                self.errorLabel.text = strData
                self.setNextButtonStatus(isStatus: false)
            }
            else
            {
                if error?.code == 204 {
                    self.isMobileValid = true
                    self.setNextButtonStatus(isStatus: true)
                }
            }
        }
    }
    
    fileprivate func chekcUserNameIsExtstis() {
//        view.endEditing(true)
        let loginViewModel = LoginViewModel(api: LoginAPI())
        loginViewModel.validateRegisteration(type: .username, userName: tfEmail.text!) { [self] (isSuccess,message, errorCode) in
            if isSuccess
            {
                self.isEmailValid = false
                self.errorLabel.text = "This".localized + " " + "user name".localized + " " + "is already registered".localized + " " + "with us" + "."
                self.setNextButtonStatus(isStatus: false)
            }
            else
            {
                if errorCode == 204 {
                    self.isEmailValid = true
                    self.setNextButtonStatus(isStatus: true)
                }
            }
        }
    }
    
    fileprivate func checkEmailIdIsExitsts() {
        let loginViewModel = LoginViewModel(api: LoginAPI())
        loginViewModel.validateRegisteration(type: .email , emailAddress: tfEmail.text ) { [self] (isSucces, erorr,errorCode) in
            if erorr != nil
            {
                self.isEmailValid = false
                errorLabel.text = erorr?.localized
                self.errorLabel.text = "Entered".localized + " " + "email".localized + " " + "is already registered".localized + "."
                setNextButtonStatus(isStatus: false)
                return
            }
            if isSucces {
                self.isEmailValid = false
                setNextButtonStatus(isStatus: false)
                self.errorLabel.text = "Entered".localized + " " + "email".localized + " " + "is already registered".localized + "."
                return
            }
            else
            {
                if errorCode == 204 {
                    self.isEmailValid = true
                    setNextButtonStatus(isStatus: true)
                }
                
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfEmail
        {
            if currentUpdateField == .email
            {
                if !Helper.isValidEmail(emailText: tfEmail.text!){
                    self.isEmailValid = false
                    errorLabel.text =  Strings.pleaseEnterValidEmailId.localized
                }
            }
            else if currentUpdateField == .userName
            {
                guard let userName = tfEmail.text , !userName.isEmpty else {
                    self.isEmailValid = false
                    self.errorLabel.text = "Please enter".localized + " " + "username".localized + "."
                   return
                }
            }
            /*
             Feat Name:- should navigate to other page on click of business username,name and website
             Feat Date:- 03/05/21
             Feat By  :- Nikunj C
             Description of Feat:- require validation for business profile
             */
            else if currentBusinessField == .businessUserName{
                guard let userName = tfEmail.text , !userName.isEmpty else {
                    self.isEmailValid = false
                    self.errorLabel.text = "Please enter".localized + " " + "business username".localized + "."
                   return
                }
            }
            else if currentBusinessField == .BusinessName{
                guard let userName = tfEmail.text , !userName.isEmpty else {
                    self.isEmailValid = false
                    self.errorLabel.text = "Please enter".localized + " " + "business name".localized + "."
                   return
                }
            }
            else if currentBusinessField == .businessWebsite{
                guard let userName = tfEmail.text , !userName.isEmpty else {
                    self.isEmailValid = false
                    self.errorLabel.text = "Please enter".localized + " " + "business website".localized + "."
                   return
                }
            }
        }
        else if textField == mobileNoTextFiled
        {
            guard let mobile = mobileNoTextFiled.text , !mobile.isEmpty else {
                self.isMobileValid = false
                self.errorLabel.text = "Please enter".localized + " " + "phone number".localized + "."
                 setNextButtonStatus(isStatus: false)
               return
            }
        }
        
    }
}

extension UpdateEmailViewController : VerificationVCDelegate {
    func done() {
        if isForBusinessProfie {
            delegate?.updateDone(fieldType: currentBusinessField, value: self.mobileNoTextFiled.text!, countryCode: strCountryCode!)
            self.navigationController?.popViewController(animated: true)
        }else{
            delegate?.updateDone(fieldType: currentUpdateField, value: self.mobileNoTextFiled.text!, countryCode: strCountryCode!)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
extension UpdateEmailViewController :CountryDataDelegate{
    
    func countryData(countryName: String, phoneCode: String, countryCode: String, countryFlag: UIImage) {
        self.strCountryCode = phoneCode
        self.contryCodeButton.setTitle(phoneCode, for: .normal)
    }
}
