
//
//  BusinessMobileConfigurationViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 25/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
import TextFieldEffects
class BusinessMobileConfigurationViewController: UIViewController {
    
    //MARK:- Variables&Declarations
    let businessMobileConfigurationVmObject = BusinessMobileConfigViewModel()
    var isValidNumber: Bool = false
    var currentCountryName = "US"
    var mobileNumber:String?
    var countryCode :String?
    let profileVmObject = ProfileViewModel() // Used for profileViewModel Object Reference
    var isVisibleNormalUserMobileNumber = true
    var visibleMobileNumberInteger:Bool?
    //    var accountKit:AccountKitManager!
    var isFromBusinessCreateVC:Bool = false
    var isPhoneNumberVisibleInt:Double?
    var isEmailVisibleInt:Double?
    var businessCategoryId:String?
    var isChangingMobileNumber:String?
    var isMobileNumberChanged:Bool = false
    var isFromEditBusniess:Bool = false
    var isChangedSwitch:Bool = false
    //MARK:-Outlets
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var visibleBtn: UISwitch!
    @IBOutlet weak var countryImageOutlet: UIImageView!
    @IBOutlet weak var countryNameLabelOutlet: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    //MARK:- Veiw Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //  addDoneButtonOnKeyboard()
        getUserDetails()
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Confirm Phone Number")
        
        if !isFromBusinessCreateVC{
            if isFromEditBusniess {
                self.phoneNumberTextField.text = "\(mobileNumber ?? "")"
                self.countryNameLabelOutlet.text = self.countryCode
                self.businessMobileConfigurationVmObject.mobileNumber = mobileNumber
                self.isChangingMobileNumber = mobileNumber
                let path = Bundle.main.path(forResource: Strings.callingCodes, ofType: Strings.plist)
                let array = NSArray(contentsOfFile: path!) as! [[String: String]]
                if let defaultCountry = array.filter({$0[Strings.dialCode] == self.countryCode}).first{
                    let countryImageName = defaultCountry[Strings.code]
                    self.countryImageOutlet.image = VNHCountryPicker.getCountryImage(code: countryImageName ?? "")
                }
            }else {
                if self.countryCode == nil {
                    if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
                        self.countryNameLabelOutlet.text = VNHCountryPicker.dialCode(code: countryCode).dialCode
                        self.countryCode = VNHCountryPicker.dialCode(code: countryCode).dialCode
                        currentCountryName = VNHCountryPicker.dialCode(code: countryCode).code
                        self.businessMobileConfigurationVmObject.countryCode = countryCode
                        self.countryImageOutlet.image = VNHCountryPicker.getCountryImage(code: countryCode)
                    }
                }else{
                    self.countryNameLabelOutlet.text = self.countryCode
                    self.businessMobileConfigurationVmObject.countryCode = countryCode
                }
                
                self.phoneNumberTextField.text = "\(mobileNumber ?? "")"
                self.businessMobileConfigurationVmObject.mobileNumber = mobileNumber
                self.isChangingMobileNumber = mobileNumber

                
                if let mobileNumberDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessMobileNumber) as? [String:Any]{
                    if let number = mobileNumberDetails["number"] as? String {
                        let countryCodeObj = mobileNumberDetails["countryCode"]
                        self.phoneNumberTextField.text = "\(number)"
                        self.businessMobileConfigurationVmObject.mobileNumber = number
                        self.isChangingMobileNumber = number
                        self.mobileNumber = number
                    }
                }
            }
        } else {
            self.phoneNumberTextField.text = "\(mobileNumber ?? "")"
            self.businessMobileConfigurationVmObject.mobileNumber = mobileNumber
            self.isChangingMobileNumber = mobileNumber
            if self.countryCode == nil {
                if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
                    self.countryNameLabelOutlet.text = VNHCountryPicker.dialCode(code: countryCode).dialCode
                    self.countryCode = VNHCountryPicker.dialCode(code: countryCode).dialCode
                    currentCountryName = VNHCountryPicker.dialCode(code: countryCode).code
                    self.businessMobileConfigurationVmObject.countryCode = countryCode
                    self.countryImageOutlet.image = VNHCountryPicker.getCountryImage(code: countryCode)
                }
            }else{
                self.countryNameLabelOutlet.text = self.countryCode
                self.businessMobileConfigurationVmObject.countryCode = countryCode
            }
        }
        if let businessPhoneDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessEmail) as? [String:Any]{
            if let isNumberisVisible = businessPhoneDetails[Strings.isVisible] as? Bool{
                if isNumberisVisible {
                    self.isEmailVisibleInt = 1
                }else {
                    self.isEmailVisibleInt = 0
                }
            }
        }
        if visibleMobileNumberInteger == true {
            self.visibleBtn.isOn = true
            isPhoneNumberVisibleInt = 1
        }else {
            self.visibleBtn.isOn = false
            isPhoneNumberVisibleInt = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        phoneNumberTextField.becomeFirstResponder()
        let nextBtn = UIBarButtonItem.init(title: Strings.next.localized, style: .done, target: self, action: #selector(nextAction))
        nextBtn.tintColor = .label
        self.navigationItem.rightBarButtonItem = nextBtn
        
        if self.isMobileNumberChanged {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else {
            if isChangedSwitch {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }else {
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGray
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.phoneNumberTextField.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    
    @objc func nextAction(){
        if self.isFromBusinessCreateVC && !self.isChangedSwitch{
            businessobileConfigurationOTPCall()
        }else if self.isMobileNumberChanged{
            businessobileConfigurationOTPCall()
        }else if self.isChangedSwitch{
            changeMobileNumberVisibleApiCall()
        }
    }
    
    
    
    
    //    @objc func nextAction(){
    //           if self.isFromBusinessCreateVC{
    //            if let businessContactInfoVc : BusinessContactInfoViewController = self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessContactInfoViewController.self)}).first as? BusinessContactInfoViewController{
    //                if isPhoneNumberVisibleInt == 1 {
    //                    businessContactInfoVc.isPhoneNumberIsVisible = true
    //                }else {
    //                    businessContactInfoVc.isPhoneNumberIsVisible = false
    //                }
    //                businessContactInfoVc.businessContactInfoVmObject.phoneNumber = self.mobileNumber
    //                businessContactInfoVc.countryCode = self.countryCode
    //
    //                self.navigationController?.popToViewController(businessContactInfoVc, animated: true)
    //            }
    //            return
    //        }else {
    //          changeMobileNumberVisibleApiCall()
    //        }
    //    }
    //
    //    //MARK:--  functions
    //    func addDoneButtonOnKeyboard(){
    //        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    //        doneToolbar.barStyle = .default
    //        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    //        let done: UIBarButtonItem = UIBarButtonItem(title: Strings.done.localized, style: .done, target: self, action: #selector(self.doneButtonAction))
    //        let items = [flexSpace, done]
    //        doneToolbar.items = items
    //        doneToolbar.sizeToFit()
    //        phoneNumberTextField.inputAccessoryView = doneToolbar
    //    }
    //
    //
    //    /// Done Button Action On toolBar
    //    @objc func doneButtonAction(){
    //        phoneNumberTextField.resignFirstResponder()
    //    }
    
    @IBAction func editButtonAction(_ sender: UIButton) {
        //        var phone:PhoneNumber?
        //        accountKit = AccountKitManager.init(responseType: .accessToken)
        //         phone = PhoneNumber.init(countryCode: self.countryCode ?? "", phoneNumber: self.mobileNumber ?? "")
        //        let loginVC =  accountKit.viewControllerForPhoneLogin(with: phone, state: "")
        //        self.prepareLoginViewController(loginViewController: loginVC )
        //        self.present(loginVC, animated: true, completion: nil)
        
    }
    
    
    @IBAction func countryPickerAction(_ sender: UIButton) {
        movingToCountryVc()
    }
    
    
    /// Presenting Country Picker ViewController
    func movingToCountryVc() {
        let countryPickerVc = VNHCountryPicker.instantiate(storyBoardName: AppConstants.StoryBoardIds.CountryPicker) as VNHCountryPicker
        countryPickerVc.delegate = self
        self.present(countryPickerVc, animated: true)
    }
    
    @IBAction func switchVisibleAction(_ sender: UISwitch) {
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.label
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        isChangedSwitch = true
        if visibleBtn.isOn {
            self.isVisibleNormalUserMobileNumber = true
            isPhoneNumberVisibleInt = 1
        }else {
            self.isVisibleNormalUserMobileNumber = false
            isPhoneNumberVisibleInt = 0
        }
    }
    
    func changeMobileNumberVisibleApiCall(){
        let params = ["isPhoneNumberVisible": self.isPhoneNumberVisibleInt!,
                      "businessCategoryId":self.businessCategoryId as Any,
                      "isEmailVisible":self.isEmailVisibleInt as Any] as [String : Any]
        UpdateProfileApi.updateVisibleMobileNumber(params: params) { (dict) in
            print("profile updated succefully")
            Helper.hidePI()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshUserDetails), object: nil)
            if let businessEditContactOptionsVc : BusinessEditContactOptionsViewController = self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessEditContactOptionsViewController.self)}).first as? BusinessEditContactOptionsViewController{
                businessEditContactOptionsVc.mobileNumber = self.mobileNumber
                businessEditContactOptionsVc.countryCode = self.countryCode
                self.navigationController?.popToViewController(businessEditContactOptionsVc, animated: true)
                return
            }
            self.navigationController?.popViewController(animated: true)
            Helper.hidePI()
        }
    }
    
    func businessobileConfigurationOTPCall(){
        Helper.showPI()
        let url = AppConstants.bussinessPhoneVerification
        self.businessMobileConfigurationVmObject.getMobileOTP(strUrl: url) { (success, error) in
            if success{
                /// Pushing To BusinessVerificationViewController
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessVerificationViewControllerId) as! BusinessVerificationViewController
                verificationVc.isVisibleMobileNumber = self.isVisibleNormalUserMobileNumber
                verificationVc.isVisibleMobileNumberInt = self.isPhoneNumberVisibleInt
                verificationVc.businessMobileConfigDelegate = self
                verificationVc.viaEmailOrPhone =  Strings.viaMobile
                verificationVc.phoneNumber = self.mobileNumber
                verificationVc.countryCode = self.countryCode
                self.navigationController?.pushViewController(verificationVc, animated: true)
            }else if let error = error{
                /*
                 Bug Name:- Add validation for phonenumber in business profile
                 Fix Date:- 23/04/21
                 Fix By  :- Jayaram G
                 Description of Fix:- Showing error if phonenumber already using by others
                 */
                if error.code == 409 {
                    self.errorLabel.text = "This mobile number is linked to another business that is not linked to your profile , please use a different mobile number to verify your business."
                }
            }
        }
        Helper.hidePI()
    }
    
    func getUserDetails(){
        let strUrl = AppConstants.userProfile
        profileVmObject.userDetailsService(strUrl: strUrl, params: [:]) { (success, error, canServiceCall) in
            if success{
                self.businessMobileConfigurationVmObject.countryCode = self.profileVmObject.userProfileModel?.countryCode
                self.currentCountryName = (self.profileVmObject.userProfileModel?.countryCode)!
                self.countryCode = self.profileVmObject.userProfileModel?.countryCode
                
                self.businessCategoryId = self.profileVmObject.userProfileModel?.businessDetails.first?.businessCategoryId
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
        }
    }
}

//MARK:-Extension

// MARK: - UITextFieldDelegate Methods
extension BusinessMobileConfigurationViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
     }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        
        if self.isChangingMobileNumber != txtAfterUpdate{
            self.isMobileNumberChanged = true
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.label
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else{
            self.isMobileNumberChanged = false
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGray
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        self.businessMobileConfigurationVmObject.mobileNumber = txtAfterUpdate
        mobileNumber = txtAfterUpdate
        
        if self.isValidNumber && string != ""{
            return false
        }
        let textWithoutSpaces = textField.text?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        var number = textWithoutSpaces
        if string == ""{
            number?.removeLast()
        }else{
            number = textWithoutSpaces! + string
        }
        self.isValidNumber = self.isEnteredNumberValid(number: number!)
        return true
    }
    
    /// To validate number user is entring is valid or not
    ///
    /// - Parameter number: number entered by user
    /// - Returns: if valid return true otherwise false
    fileprivate func isEnteredNumberValid(number: String) -> Bool{
        var phone = number
        if phone.first == "0"{
            phone.remove(at: number.startIndex)
        }
        mobileNumber = phone
        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNum = try phoneUtil.parse(mobileNumber, defaultRegion: currentCountryName)
            if (phoneUtil.isValidNumber(phoneNum)) {
                return true
            } else {
                return false
            }
        }catch {
            return false
        }
    }
}

// MARK: - VNHCountryPickerDelegate
extension BusinessMobileConfigurationViewController:businessMobileConfigDelegate,VNHCountryPickerDelegate{
    func resendingOtpForMobileConfig() {
        Helper.showPI()
        let url = AppConstants.bussinessPhoneVerification
        self.businessMobileConfigurationVmObject.getMobileOTP(strUrl: url) { (success, error) in
            if success{
                /// Pushing To BusinessVerificationViewController
                /// Pushing To BusinessVerificationViewController
                Helper.showAlertViewOnWindow(Strings.message.localized, message: "The verification code has been resent".localized + " , " + "please check your inbox".localized + ".")
                
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
        Helper.hidePI()
    }
    
    /// After selecting Country
    ///
    /// - Parameters:
    ///   - country: VNHCounty country Object
    ///   - flag:  UIImage
    func didPickedCountry(country: VNHCounty, flag: UIImage) {
        self.phoneNumberTextField.becomeFirstResponder()
        self.countryImageOutlet.image = flag
        self.businessMobileConfigurationVmObject.countryCode = country.dialCode
        self.currentCountryName = country.code
        self.countryNameLabelOutlet.text = country.dialCode
        countryCode = country.dialCode
    }
}
