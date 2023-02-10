//
//  MobileConfigurationViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/7/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
import TextFieldEffects
import libPhoneNumber_iOS
class MobileConfigurationViewController: UIViewController,UIGestureRecognizerDelegate{
    
    
    //MARK:-Outlets
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var visibleSwitchOutlet: UISwitch!
    @IBOutlet weak var countryFlagImage: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    
    
    //MARK:- Declarations&Constants
    var isValidNumber: Bool = false
    var currentCountryName = "US"
    var mobileNumber:String?
    var countryCode :String?
    var mobileConfiguraionVmObject = MobileConfigurationViewModel()
    var isVisibleNormalUserMobileNumber = false
    var visibleMobileNumberInteger:Int?
    var isSwitchChanged:Bool = false
    var mobileNumberForTest:String = ""
//    var accountKit:AccountKitManager!
    
    struct Constants {
        static let mobileConfigurationViewControllerId = "MobileConfigurationViewControllerId"
        //  static let updatingPhoneNumberViewControllerId = "UpdatingPhoneNumberViewControllerId"
        static let verificationViewControllerId = "VerificationViewControllerId"
        static let countryPickerVcId = "countryPickerController"
        
    }
    
  
    
    //MARK:-View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        loadData()
        addDoneButtonOnKeyboard()
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        if visibleMobileNumberInteger == 1 {
            self.visibleSwitchOutlet.isOn = true
        }else {
            self.visibleSwitchOutlet.isOn = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isValidNumber = false
        phoneNumberTextField.becomeFirstResponder()
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
    func setUpUI(){
        self.phoneNumberTextField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.phoneNumberTextField.font = Utility.Font.Regular.ofSize(17)
        let frame = self.phoneNumberTextField.frame
        self.phoneNumberTextField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Confirm Phone Number")
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: Strings.done.localized, style: .done, target: self, action: #selector(nextAction))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func loadData(){
        let starUserDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.verifyProfileDetails) as? [String:Any]
        if let starUserPhoneNumber = starUserDetails?["starUserPhoneNumber"] as? String{
            self.phoneNumberTextField.text = starUserPhoneNumber
            self.mobileConfiguraionVmObject.mobileNumber = starUserPhoneNumber
            self.mobileNumberForTest = starUserPhoneNumber
            mobileNumber = starUserPhoneNumber
            if let starCountryCode = starUserDetails?["countryCode"] as? String {
                countryCodeLabel.text = starCountryCode
                let path = Bundle.main.path(forResource: Strings.callingCodes, ofType: Strings.plist)
                let array = NSArray(contentsOfFile: path!) as! [[String: String]]
                if let defaultCountry = array.filter({$0[Strings.dialCode] == starCountryCode}).first{
                    currentCountryName =  defaultCountry[Strings.code] ?? "US"
                }
                self.mobileConfiguraionVmObject.countryCode = starCountryCode
                self.countryCode = starCountryCode
                countryFlagImage.image = VNHCountryPicker.getCountryImage(code: starCountryCode)
            }else {
                /// Getting Current Country Details
                if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
                    countryCodeLabel.text = VNHCountryPicker.dialCode(code: countryCode).dialCode
                    
                    self.mobileConfiguraionVmObject.countryCode = VNHCountryPicker.dialCode(code: countryCode).dialCode
                    self.countryCode = VNHCountryPicker.dialCode(code: countryCode).dialCode
                    currentCountryName = VNHCountryPicker.dialCode(code: countryCode).code
                    countryFlagImage.image = VNHCountryPicker.getCountryImage(code: countryCode)
                }
            }
        }
    }
    
    /// Presenting Country Picker ViewController
     ///
     /// - Parameter sender: country picker button
     @IBAction func countryPickerAction(_ sender: UIButton) {
        let countryPickerVc = VNHCountryPicker.instantiate(storyBoardName: AppConstants.StoryBoardIds.CountryPicker) as VNHCountryPicker
         countryPickerVc.delegate = self
         self.present(countryPickerVc, animated: true)
     }
    
    
    @objc func nextAction() {
        mobileConfigurationOTPCall()
//        self.navigationController?.popViewController(animated: true)
    }
    
    /// Adding ToolBar On the KeyBoard
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: Strings.done.localized, style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        phoneNumberTextField.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction(){
        phoneNumberTextField.resignFirstResponder()
    }
    
    /// Popping ViewController
    ///
    /// - Parameter sender: Back Button
    @IBAction func backToConfigVc(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
//    func prepareLoginViewController(loginViewController: AKFViewController) {
//        loginViewController.delegate = self
//        loginViewController.isSendToFacebookEnabled = true
//        //  loginViewController.enableGetACall = true
//        loginViewController.isSMSEnabled = true
//
//
//        // uiTheme Modification
//        loginViewController.uiManager = SkinManager.init(skinType: .contemporary, primaryColor:  #colorLiteral(red: 0.831372549, green: 0.6666666667, blue: 0.3647058824, alpha: 1))
        //        let theme:Theme = Theme.default()
        //      theme.headerTextType
        //        loginViewController.setTheme(theme)
//    }
    
    
    @IBAction func editMobileNumberAction(_ sender: UIButton) {
      //  accountKit = AccountKitManager.init(responseType: .accessToken)
//        let loginVC =  accountKit.viewControllerForPhoneLogin(with: nil, state: "0")
//        self.prepareLoginViewController(loginViewController: loginVC )
//        self.present(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func visibleSwitchAction(_ sender: UISwitch) {
        isSwitchChanged = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        if visibleSwitchOutlet.isOn {
            self.isVisibleNormalUserMobileNumber = true
        }else {
            self.isVisibleNormalUserMobileNumber = false
        }
    }
    
    
    /// Requesting OTP For Mobile Configuration
    func mobileConfigurationOTPCall(){
        Helper.showPI()
        let url = AppConstants.requestMobileVerification
        self.mobileConfiguraionVmObject.requestMobileOtpCall(strUrl: url) { (success, error) in
            if success{
                /// Pushing To VerificationViewController
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: Constants.verificationViewControllerId) as! VerificationViewController
                verificationVc.resendingMobileConfigDelegate = self
                verificationVc.isVisibleMobileNumber = self.isVisibleNormalUserMobileNumber
                verificationVc.viaEmailOrPhone = Strings.viaMobile
                verificationVc.phoneNumber = self.mobileNumber
                verificationVc.countryCode = self.countryCode
                verificationVc.isStarConfiguration = true
                self.navigationController?.pushViewController(verificationVc, animated: true)
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
        Helper.hidePI()
    }
    
    /// Requesting OTP For Mobile Configuration
    func resendingOTPCall(){
      
        let url = AppConstants.requestMobileVerification
        self.mobileConfiguraionVmObject.requestMobileOtpCall(strUrl: url) { (success, error) in
            if success{
                Helper.showAlertViewOnWindow(Strings.message.localized, message: "The verification code has been resent , please check your inbox.")
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        Helper.hidePI()
        }
      
    }
    
    
    
    
    
    
//    internal func viewController(_ viewController: UIViewController & AKFViewController, didCompleteLoginWith accessToken: AKFAccessToken, state: String) {
//        self.accountKit.requestAccount { (account, error) in
//            if error == nil {
//                self.mobileNumber = account?.phoneNumber?.phoneNumber
//
//             //   self.phoneNumber = account?.phoneNumber?.phoneNumber
//                if (account?.phoneNumber?.countryCode.hasPrefix("+"))!{
//                    self.countryCode = account?.phoneNumber?.countryCode
//                    self.phoneNumberTextField.text = "\(account?.phoneNumber?.countryCode ?? "")\(account?.phoneNumber?.phoneNumber ?? "")"
//                }else {
//                    self.countryCode = "+\(account?.phoneNumber?.countryCode ?? "")"
//                   self.phoneNumberTextField.text = "+\(account?.phoneNumber?.countryCode ?? "")\(account?.phoneNumber?.phoneNumber ?? "")"
//                }
//            }
//        }
//    }
//
//    func viewController(_ viewController: UIViewController & AKFViewController, didCompleteLoginWith code: String, state: String) {
//
//    }
//
//    func viewController(_ viewController: UIViewController & AKFViewController, didFailWithError error: Error) {
//        print(error.localizedDescription)
//    }
//
//    func viewControllerDidCancel(_ viewController: UIViewController & AKFViewController) {
//        print("User cancelled operation")
//    }
//
//

    
}

//MARK:-Extension

// MARK: - UITextFieldDelegate
extension MobileConfigurationViewController:UITextFieldDelegate,mobileConfigDelegate{
    func resendingOtpForMobileConfig() {
        resendingOTPCall()
    }
    
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
        
        guard let text = phoneNumberTextField.text else{ return true}
        mobileConfiguraionVmObject.mobileNumber = txtAfterUpdate
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
        if mobileNumberForTest == txtAfterUpdate && !isSwitchChanged {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
//        if self.isValidNumber {
//            self.navigationItem.rightBarButtonItem?.isEnabled = true
//        }else{
//            self.navigationItem.rightBarButtonItem?.isEnabled = false
//        }
        //        formatter.inputString(textWithoutSpaces) // This is the initial value of the phoneFormatter each time the delegate method is called
        //
        //        let formattedNumber: String!
        //        if string == "" {
        //            formattedNumber = formatter.removeLastDigit()
        //        } else {
        //            formattedNumber = formatter.inputDigit(string)
        //        }
        //
        //        // set the textField text with the new formattedNumber
        //        textField.text = formattedNumber
        //        return false
        //    }
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
extension MobileConfigurationViewController:VNHCountryPickerDelegate{
    
    /// After Selecting Country
    ///
    /// - Parameters:
    ///   - country: VNHCountry
    ///   - flag: UIIMage
    func didPickedCountry(country: VNHCounty, flag: UIImage) {
        self.phoneNumberTextField.becomeFirstResponder()
        self.countryFlagImage.image = flag
        self.mobileConfiguraionVmObject.countryCode = country.dialCode
        self.currentCountryName = country.code
        self.countryCodeLabel.text = country.dialCode
        countryCode = country.dialCode
    }
}
