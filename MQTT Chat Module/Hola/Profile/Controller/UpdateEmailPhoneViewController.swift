//
//  UpdateEmailPhoneViewController.swift
//  Do Chat
//
//  Created by Rahul Sharma on 18/05/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import libPhoneNumber_iOS

protocol saveDetailsToNewEditProfile {
    func changedDetails(businessEmail:String,businessPhone:String,businessCountryCode:String,isforEmail:Bool)
    func changeNormalUserDetails(email:String,phone:String,countryCode:String,isforEmail:Bool)
}

class UpdateEmailPhoneViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var phoneHoldingView: UIView!
    @IBOutlet weak var phoneErrorHoldingView: UIView!
    @IBOutlet weak var phoneTFPlaceHolderLabel: UILabel!
    @IBOutlet weak var emailHoldingView: UIView!
    @IBOutlet weak var emailErrorHoldingView: UIView!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailErrorImage: UIImageView!
    @IBOutlet weak var phoneErrorImage: UIImageView!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    @IBOutlet weak var doneButtonOutlet: UIButton!
    @IBOutlet weak var businessEmailVerificationStatusLabel: UILabel!
    @IBOutlet weak var businessPhoneVerificationStatusLabel: UILabel!
    @IBOutlet weak var businessEmailVerificationImageView: UIImageView!
    @IBOutlet weak var businessPhoneVerificationImageView: UIImageView!

    
    /// variables and Declarations
    var countryCode: String = "IN"
    var countryCodeNumber: String = "+91"
    var phoneNumber: String = ""
    var email:String = ""
    var businessPhoneNumber:String = ""
    var businessEmail:String = ""
    var isValidNumber: Bool = false
    var isChanged: Bool = false
    var isChangingEmail:String?
    var isChangingMobileNumber:String?
    var delegate: EditPhoneNumberViewControllerDelegate?
    var isForPhone: Bool = false
    var isForBusiness: Bool = false
    var updateEmailPhoneVMObject = UpdateEmailPhoneViewModel()
    var delegateForSave: saveDetailsToNewEditProfile?
    var userDetails: UserProfileModel?
    var verifiedStatus:Bool = false

    var isEmailValid = false
    var isMobileValid = false
    var oldMobileNumber : String?
    var oldCountryCode : String?
    var oldEmail : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        phoneTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUP()
        if self.isChanged{
            self.delegate?.isPhoneNumberupdated()
            self.dismiss(animated: false, completion: nil)
        }
        if isForPhone{
            self.emailHoldingView.isHidden = true
            self.phoneHoldingView.isHidden = false
            self.countryCodeLabel.text = countryCodeNumber
            self.oldCountryCode = countryCodeNumber
            if self.verifiedStatus{
                self.doneButtonOutlet.setTitle("Save".localized, for: UIControl.State.normal)
            }else{
                self.doneButtonOutlet.setTitle("Confirm and verify".localized, for: UIControl.State.normal)
            }
            if isForBusiness{
                self.title = "Edit".localized + " " + "Bussiness Phone".localized
                self.phoneTFPlaceHolderLabel.text = "Bussiness Phone".localized
                self.phoneTF.text = businessPhoneNumber
                self.isChangingMobileNumber = businessPhoneNumber
                self.oldMobileNumber = businessPhoneNumber
                
            }else{
                self.title = "Edit".localized + "Phone Number".localized
                self.phoneTFPlaceHolderLabel.text = self.title
                self.phoneTF.text = phoneNumber
                self.isChangingMobileNumber = phoneNumber
            }
            
        }else{
            self.emailHoldingView.isHidden = false
            self.phoneHoldingView.isHidden = true
            if self.verifiedStatus{
                self.doneButtonOutlet.setTitle("Save".localized, for: UIControl.State.normal)
            }else{
                self.doneButtonOutlet.setTitle("Confirm and verify".localized, for: UIControl.State.normal)
            }
            if isForBusiness{
                self.emailTF.text = businessEmail
                self.title = "Edit".localized + " " + "Bussiness Email".localized
                self.emailTF.placeholder = "Bussiness Email".localized
                self.isChangingEmail = businessEmail

            }else{
                self.emailTF.text = email
                self.title = "Email Address".localized
                self.emailTF.placeholder = self.title
                self.isChangingEmail = email
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isValidNumber = false
        if isForPhone{
            self.phoneTF.becomeFirstResponder()
        }else{
            self.emailTF.becomeFirstResponder()
        }
        
        Helper.checkConnectionAvaibility(view: self.view)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isForPhone{
            self.phoneTF.resignFirstResponder()
        }else{
            self.emailTF.resignFirstResponder()
        }
    }
    /// To manage view height according to keyboard height
    ///
    /// - Parameter notification: keyboard notification object
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                let frame = self.view.frame
                let height = UIScreen.main.bounds.height - keyboardHeight
                self.view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height)
            }, completion: nil)
            view.layoutIfNeeded()
        }
    }
    
    func setUP(){
        
        /*
         Feat Name:- for normal user should show verified label
         Feat Date:- 10/07/21
         Feat By  :- Nikunj C
         Description of Fix:- show verified/unVerified label from userDetails
         */
        if isForPhone{
            if self.verifiedStatus{
                self.businessPhoneVerificationStatusLabel.text = "Verified".localized + " !"
                self.businessPhoneVerificationStatusLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.7647058824, blue: 0.06274509804, alpha: 1)
                self.businessPhoneVerificationImageView.image = #imageLiteral(resourceName: "verified_profile")
            }else{
                self.businessPhoneVerificationStatusLabel.text = "Not verified".localized + " !"
                self.businessPhoneVerificationStatusLabel.textColor = #colorLiteral(red: 0.9699947238, green: 0.1412755549, blue: 0, alpha: 1)
                self.businessPhoneVerificationImageView.image = #imageLiteral(resourceName: "notVerified")
            }
        }else{
            if self.verifiedStatus{
                self.businessEmailVerificationStatusLabel.text = "Verified".localized + " !"
                self.businessEmailVerificationStatusLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.7647058824, blue: 0.06274509804, alpha: 1)
                self.businessEmailVerificationImageView.image = #imageLiteral(resourceName: "verified_profile")
            }else{
                self.businessEmailVerificationStatusLabel.text = "Not verified".localized + " !"
                self.businessEmailVerificationStatusLabel.textColor = #colorLiteral(red: 0.9699947238, green: 0.1412755549, blue: 0, alpha: 1)
                self.businessEmailVerificationImageView.image = #imageLiteral(resourceName: "notVerified")
            }
        }
        
        
    }
    
    fileprivate func setMobileLabelErrorStatus(isStatus : Bool) {
        self.businessPhoneVerificationStatusLabel.textColor = isStatus ? #colorLiteral(red: 0.1176470588, green: 0.7647058824, blue: 0.06274509804, alpha: 1) : #colorLiteral(red: 0.9699947238, green: 0.1412755549, blue: 0, alpha: 1)
        self.businessPhoneVerificationImageView.image = isStatus  ? #imageLiteral(resourceName: "verified_profile") : #imageLiteral(resourceName: "notVerified")
    }
    
    @objc fileprivate func checkBunessionMobile() {
        guard let mobile = phoneTF.text, mobile.isEmpty == false else {
            return
        }
        let bussesionVM = BusinessContactInfoViewModel()
        let params = ["phone":mobile,"countryCode": countryCode ,"type":2] as [String : Any]
        
        bussesionVM.validateEmailPhone(strUrl: AppConstants.businessPhoneEmailValidate, params: params) { (strData, isSuccess, error) in
            if isSuccess
            {
                self.isMobileValid = false
                self.setNextButtonStatus(isStatus: false)
                self.businessPhoneVerificationStatusLabel.text = strData
                self.setMobileLabelErrorStatus(isStatus : false)
            }
            else
            {
                if error?.code == 204 {
                    self.isMobileValid = true
                    self.businessPhoneVerificationStatusLabel.text = "Available".localized + " " + "!"
                    self.setMobileLabelErrorStatus(isStatus : true)
                    self.setNextButtonStatus(isStatus: true)
                }
            }
        }
    }
    
    
    fileprivate func setEmailLabelStatus(isStatus : Bool) {
        self.businessEmailVerificationStatusLabel.textColor =  isStatus ? #colorLiteral(red: 0.1176470588, green: 0.7647058824, blue: 0.06274509804, alpha: 1) : #colorLiteral(red: 0.9699947238, green: 0.1412755549, blue: 0, alpha: 1)
        self.businessEmailVerificationImageView.image = isStatus ?  #imageLiteral(resourceName: "verified_profile") : #imageLiteral(resourceName: "notVerified")
    }
    
     @objc fileprivate func checkBunessionEmail() {
        guard let email = self.emailTF.text, email.isEmpty == false else {
            return
        }
        let bussesionVM = BusinessContactInfoViewModel()
        let params = ["email":email,"type":1] as [String : Any]
        
        bussesionVM.validateEmailPhone(strUrl: AppConstants.businessPhoneEmailValidate, params: params) { (strData, isSuccess, error) in
        
            if isSuccess
            {
                self.businessEmailVerificationStatusLabel.text = strData
                self.setEmailLabelStatus(isStatus : false)
                self.isEmailValid = false
                self.setNextButtonStatus(isStatus: false)
            }
            else
            {
                if error?.code == 204 {
                    self.isEmailValid = true
                    self.setNextButtonStatus(isStatus: true)
                    self.setEmailLabelStatus(isStatus : true)
                    self.businessEmailVerificationStatusLabel.text = "Available".localized + " " + "!"

                }
            }
            
        }
    }
    
    func setNextButtonStatus(isStatus: Bool){
        if isStatus {
            self.doneButtonOutlet.isEnabled = true
            self.doneButtonOutlet.backgroundColor = Utility.appColor()
        }else{
            self.doneButtonOutlet.isEnabled = false
            self.doneButtonOutlet.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func openCountryCodeAction(_ sender: Any) {
        let vc = CountryPickerVC.instantiate(storyBoardName: "Authentication") as CountryPickerVC
        vc.currentCountryCode = countryCodeNumber
        vc.countryDataDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        let isNetwork = (UIApplication.shared.delegate as? AppDelegate)?.isNetworkThere
        if isNetwork == false{
            Helper.showAlertViewOnWindow(Strings.oops.localized, message: Strings.checkInternetConnection.localized)
            return
        }
        self.view.endEditing(true)
        
        if self.isForPhone{
            if self.isForBusiness{
                let  businessUniqueId  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessUniqueId) as? String ?? ""
                
                let params = ["businessCountryCode":self.countryCodeLabel.text ?? "","businessPhone":self.phoneTF.text ?? "",
                              "businessUniqueId" : businessUniqueId]
                
//                self.delegateForSave?.changedDetails(businessEmail: "", businessPhone: self.phoneTF.text ?? "", businessCountryCode: self.countryCodeLabel.text ?? "", isforEmail: false)
                self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
//                    self.navigationController?.popViewController(animated: true)
                    self.updateEmailPhoneVMObject.sendOTP(updateType: .phoneNumber, email: nil, phoneNumber: self.phoneTF.text, countryCode: self.countryCodeLabel.text) { (isSuccess, otpId) in
                        if isSuccess {
                            let controller =  VerificationVC.instantiate(storyBoardName: "Authentication") as VerificationVC
                            controller.phoneNumber = self.phoneTF.text ?? ""
                            controller.counrtyCode = self.countryCodeLabel.text ?? ""
                            controller.userEnteredNumber = self.countryCodeLabel.text!+self.phoneTF.text!
                            controller.isBessines = true
                            controller.isFromEditProfile = true
                            controller.delegate = self
                            controller.otpId = otpId
                            let nav = UINavigationController(rootViewController: controller)
                            nav.modalPresentationStyle = .overCurrentContext
                            nav.navigationBar.isHidden = true
                            self.present(nav, animated: true, completion: nil)
                        }
                    }
                    
                    
                }
            }else{
                
                /*
                 Feat Name:- for normal user should show verified label
                 Feat Date:- 10/07/21
                 Feat By  :- Nikunj C
                 Description of Fix:-  api call
                 */
                
                let params = ["countryCode":self.countryCodeLabel.text ?? "","mobile":self.phoneTF.text ?? "",]
                
                self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                    self.updateEmailPhoneVMObject.sendOTP(updateType: .phoneNumber, email: nil, phoneNumber: self.phoneTF.text, countryCode: self.countryCodeLabel.text) { (isSuccess, otpId) in
                        if isSuccess {
                            let controller =  VerificationVC.instantiate(storyBoardName: "Authentication") as VerificationVC
                            controller.phoneNumber = self.phoneTF.text ?? ""
                            controller.counrtyCode = self.countryCodeLabel.text ?? ""
                            controller.userEnteredNumber = self.countryCodeLabel.text!+self.phoneTF.text!
                            controller.isFromEditProfile = true
                            controller.delegate = self
                            controller.otpId = otpId
                            let nav = UINavigationController(rootViewController: controller)
                            nav.modalPresentationStyle = .overCurrentContext
                            nav.navigationBar.isHidden = true
                            self.present(nav, animated: true, completion: nil)
                        }
                    }
            }
        }
        }else{
            if self.isForBusiness{
                
                let  businessUniqueId  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessUniqueId) as? String ?? ""
                
                let params = [Strings.businessEmail:self.emailTF.text ?? "",
                              "businessUniqueId" : businessUniqueId]
//                self.delegateForSave?.changedDetails(businessEmail: self.emailTF.text ?? "", businessPhone: "", businessCountryCode: "", isforEmail: true)
                self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
//                    self.navigationController?.popViewController(animated: true)
                    self.updateEmailPhoneVMObject.sendOTP(updateType: .email, email: self.emailTF.text ?? "", phoneNumber: nil, countryCode: nil,isForBusiness: true) { [self] (isSuccess, otpId) in
                        if isSuccess {
                            let vc = EmailSentVC.instantiate(storyBoardName: "Authentication") as EmailSentVC
                            vc.delegateObj = self
                            vc.titleText = "Sent On Email".localized
                            vc.message = String(format: "We have send you the link to".localized + " \n\(self.emailTF.text!)")
                            vc.definesPresentationContext = true
                            vc.modalPresentationStyle = .overCurrentContext
                            let nav = UINavigationController(rootViewController: vc)
                            nav.modalPresentationStyle = .overCurrentContext
                            nav.navigationBar.isHidden = true
                            self.present(nav, animated: true, completion: nil)
                        }
                    }
                }
            }else{
                
                /*
                 Feat Name:- for normal user should show verified label
                 Feat Date:- 10/07/21
                 Feat By  :- Nikunj C
                 Description of Fix:-  api call
                 */
                
                let params = ["email":self.emailTF.text ?? ""]
                self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                    self.updateEmailPhoneVMObject.sendOTP(updateType: .email, email: self.emailTF.text ?? "", phoneNumber: nil, countryCode: nil,isForBusiness: false) { [self] (isSuccess, otpId) in
                        if isSuccess {
                            let vc = EmailSentVC.instantiate(storyBoardName: "Authentication") as EmailSentVC
                            vc.delegateObj = self
                            vc.titleText = "Sent On Email".localized
                            vc.message = String(format: "We have send you the link to".localized + " \n\(self.emailTF.text!)")
                            vc.definesPresentationContext = true
                            vc.modalPresentationStyle = .overCurrentContext
                            let nav = UINavigationController(rootViewController: vc)
                            nav.modalPresentationStyle = .overCurrentContext
                            nav.navigationBar.isHidden = true
                            self.present(nav, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
//        if self.phoneTF.text?.count == 0{
//            return
//        }
//        //Checing and Removing first charector if it is zero in entered number
//        guard var number = self.phoneTF.text?.digits else { return }
//        if number.first == "0"{
//            number.remove(at: number.startIndex)
//        }
//        phoneNumber = number
//        let phoneUtil = NBPhoneNumberUtil()
//        do {
//            let phoneNum = try phoneUtil.parse(phoneNumber, defaultRegion: countryCode)
//            if (phoneUtil.isValidNumber(phoneNum)) {
//                //Removed popup
//                let customView = CustomAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
//                customView.tag = 10
//                customView.delegete  = self
//                customView.userNumberLbl.text =  "\(String(describing: countryCodeLabel.text!))" + "\(String(describing: phoneNumber))"
//                appDelegetConstant.window.addSubview(customView)
//                customView.popUpAnimation()
//            } else {
//                let alert = UIAlertController(title: Strings.alert, message: Strings.yourPhoneNumberisINCorrect, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: Strings.okay, style: .default, handler: { (action) in
//                    alert.dismiss(animated: true, completion: nil)
//                }))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//        catch let error{
//            //            DDLogDebug(error.localizedDescription)
//            print(error)
//            Helper.showAlertViewOnWindow(Strings.oops, message: Strings.phoneNumberIsTooLong)
//        }
        
    }
    
    //MARK:- Service call
    func requestChnageNumber() {
        Helper.showPI()
        if self.isForBusiness{
            var fieldType : FiledVerificationType
            if self.isForPhone{
                fieldType = .phoneNumber
            }else{
                fieldType = .email
            }
            self.updateEmailPhoneVMObject.sendOTP(updateType: fieldType,email: self.businessEmail,phoneNumber: self.businessPhoneNumber,countryCode: self.countryCodeNumber,isForBusiness: true) { (sucess, error) in
                if sucess{
                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                    let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessVerificationViewControllerId) as! BusinessVerificationViewController
                    verificationVc.businessMobileConfigDelegate = self
                    verificationVc.viaEmailOrPhone =  Strings.viaMobile
                    verificationVc.phoneNumber = self.businessPhoneNumber
                    verificationVc.countryCode = self.countryCode
                    self.navigationController?.pushViewController(verificationVc, animated: true)
                    Helper.hidePI()
                }
            }
        }else{
            var fieldType : FiledVerificationType
            if self.isForPhone{
                fieldType = .phoneNumber
            }else{
                fieldType = .email
            }
            self.updateEmailPhoneVMObject.sendOTP(updateType: fieldType,email: self.businessEmail,phoneNumber: self.businessPhoneNumber,countryCode: self.countryCodeNumber,isForBusiness: false) { (sucess, error) in
                if sucess{
                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                    let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessVerificationViewControllerId) as! BusinessVerificationViewController
                    verificationVc.businessMobileConfigDelegate = self
                    verificationVc.viaEmailOrPhone =  Strings.viaMobile
                    verificationVc.phoneNumber = self.businessPhoneNumber
                    verificationVc.countryCode = self.countryCode
                    self.navigationController?.pushViewController(verificationVc, animated: true)
                    Helper.hidePI()
                }
            }
        }
        
        //        guard let number = self.phoneNumberOutlet.text?.digits else { return }
        
        
    }
}

// MARK:- Country Picker Delegate
extension UpdateEmailPhoneViewController : VNHCountryPickerDelegate{
    func didPickedCountry(country: VNHCounty, flag: UIImage) {
        self.countryCodeLabel.text = country.dialCode
        self.countryCode = country.code
        self.phoneTF.text = ""
    }
}

// MARK:- Country Picker Text Field Delegate
extension UpdateEmailPhoneViewController : UITextFieldDelegate {
    
    
    @objc func textFieldDidChange(textField : UITextField) {
        if textField == phoneTF {
            guard textField.text?.isEmpty == false else {
                self.businessPhoneVerificationStatusLabel.isHidden = true
                self.businessPhoneVerificationImageView.isHidden = true
                return
            }
            
            if !Helper.isValidNumber("\(self.countryCodeLabel.text ?? "+91" )" + (textField.text!)){
                isMobileValid = false
                setNextButtonStatus(isStatus: false)
                self.businessPhoneVerificationImageView.isHidden = false
                self.businessPhoneVerificationStatusLabel.isHidden = false
                self.businessPhoneVerificationStatusLabel.text =  "Please enter".localized + " " + "valid".localized + "mobile no".localized + "."
                setMobileLabelErrorStatus(isStatus: false)
            }
            else
            {
                if (oldCountryCode ?? "+91") == (self.countryCodeLabel.text ?? "+91" ) && textField.text == businessPhoneNumber {
                    isMobileValid = false
                    setNextButtonStatus(isStatus: false)
                    self.businessPhoneVerificationStatusLabel.isHidden = false
                    self.businessPhoneVerificationImageView.isHidden = false
                    self.businessPhoneVerificationStatusLabel.text =  "Verified".localized + " !"
                    setMobileLabelErrorStatus(isStatus: true)
                }
                else {
//                    checkBunessionMobile()
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkBunessionMobile), object: nil)
                    perform(#selector(checkBunessionMobile), with: nil, afterDelay: 0.8)
                }
                
            }
            
        }
        else if textField == emailTF {
            guard textField.text?.isEmpty == false else {
                self.businessEmailVerificationImageView.isHidden = true
                self.businessEmailVerificationStatusLabel.isHidden = true
                return
            }
            
            if !Helper.isValidEmail(emailText: textField.text!) {
                self.isEmailValid = false
                self.businessEmailVerificationStatusLabel.text =  "Please enter".localized + " " + "valid".localized + "email id".localized + "."
                setEmailLabelStatus(isStatus: false)
                setNextButtonStatus(isStatus: false)
                self.businessEmailVerificationImageView.isHidden = false
                self.businessEmailVerificationStatusLabel.isHidden = false
            }
            else
            {
                if isChangingEmail == textField.text {
                    self.isEmailValid = false
                    self.businessEmailVerificationStatusLabel.text =  "Please enter".localized + "different".localized + "email".localized + "."
                    setEmailLabelStatus(isStatus: false)
                    setNextButtonStatus(isStatus: false)
                    self.businessEmailVerificationImageView.isHidden = false
                    self.businessEmailVerificationStatusLabel.isHidden = false
                }
                else
                {
//                    checkBunessionEmail()
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkBunessionEmail), object: nil)
                    perform(#selector(checkBunessionEmail), with: nil, afterDelay: 0.8)
                }
            }
        }
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        var txtAfterUpdate : String = ""
//        if let text = textField.text as NSString? {
//            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
//        }
//        switch textField {
//        case emailTF:
//            let textWithoutSpaces = txtAfterUpdate.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
//            let email = textWithoutSpaces
//            if self.isChangingEmail != email {
//                self.doneButtonOutlet.isEnabled = true
//                self.doneButtonOutlet.backgroundColor = Utility.appColor()
//            }else{
//                self.doneButtonOutlet.isEnabled = false
//                self.doneButtonOutlet.backgroundColor = UIColor.lightGray
//            }
//            return true
//        case phoneTF:
//            if self.isValidNumber && string != ""{
//                return false
//            }
//            let textWithoutSpaces = txtAfterUpdate.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
//            let number = textWithoutSpaces
//            self.isValidNumber = Helper.isValidNumber(self.countryCodeNumber + number)
//            if self.isValidNumber && self.isChangingMobileNumber != number {
//                self.doneButtonOutlet.isEnabled = true
//                self.doneButtonOutlet.backgroundColor = Utility.appColor()
//            }else{
//                self.doneButtonOutlet.isEnabled = false
//                self.doneButtonOutlet.backgroundColor = UIColor.lightGray
//            }
//            return true
//        default:
//            break
//        }
//        return true
//    }
    
}

// MARK: - customViewdelegte
extension UpdateEmailPhoneViewController: customViewdelegte{
    func  didDonecliked() {
        let customalertView = appDelegetConstant.window.viewWithTag(10)
        //        customalertView?.removeFromSuperview()
        
        customalertView?.popDownAnimation(animationDone: { (finished) in
            self.phoneTF.becomeFirstResponder()
            
            if (self.phoneNumber.count)>4 {
                self.doneButtonOutlet.isEnabled = true
                self.doneButtonOutlet.backgroundColor = Utility.appColor()
            }else{
                self.doneButtonOutlet.isEnabled = false
                self.doneButtonOutlet.backgroundColor = UIColor.lightGray
            }
            self.requestChnageNumber()
        })
    }
    
    
    func  didEditCliked() {
        
        let customalertView = appDelegetConstant.window.viewWithTag(10)
        //        customalertView?.removeFromSuperview()
        customalertView?.popDownAnimation(animationDone: { (finished) in
            self.phoneTF.becomeFirstResponder()
            if (self.phoneNumber.count)>4 {
                self.doneButtonOutlet.isEnabled = true
                self.doneButtonOutlet.backgroundColor = Utility.appColor()
            }else{
                self.doneButtonOutlet.isEnabled = false
                self.doneButtonOutlet.backgroundColor = UIColor.lightGray
            }
        })
    }
}

extension UpdateEmailPhoneViewController: EditNumberVarificationViewControllerDelegate,CountryDataDelegate{
    func countryData(countryName: String, phoneCode: String, countryCode: String, countryFlag: UIImage) {
        self.countryCode = countryCode
        self.countryCodeNumber = phoneCode
        self.countryCodeLabel.text = phoneCode
    }
    
    
    func isNumberChanged(){
        self.isChanged = true
    }
}

extension UpdateEmailPhoneViewController:businessMobileConfigDelegate{
    func resendingOtpForMobileConfig() {
        let strURL =  AppConstants.businessEmailPhoneSend
    }
    
    
}


extension UpdateEmailPhoneViewController : VerificationVCDelegate {
    
    /*
     Feat Name:- for normal user should show verified label
     Feat Date:- 10/07/21
     Feat By  :- Nikunj C
     Description of Fix:- send details to newEditProfileVC
     */
    
    func done() {
        if self.isForBusiness{
            self.delegateForSave?.changedDetails(businessEmail: "", businessPhone: self.phoneTF.text ?? "", businessCountryCode: self.countryCodeLabel.text ?? "", isforEmail: false)
            self.navigationController?.popViewController(animated: true)
        }else{
            self.delegateForSave?.changeNormalUserDetails(email: "", phone: self.phoneTF.text ?? "", countryCode: self.countryCodeLabel.text ?? "", isforEmail: false)
            self.navigationController?.popViewController(animated: true)
        }
        
       
    }
}


extension  UpdateEmailPhoneViewController : EmailSentVCDelegate {
    func navigateToLoginVc() {
        self.delegateForSave?.changedDetails(businessEmail: self.emailTF.text ?? "", businessPhone: "", businessCountryCode: "", isforEmail: true)
        self.navigationController?.popViewController(animated: true)

    }
    
    
}
