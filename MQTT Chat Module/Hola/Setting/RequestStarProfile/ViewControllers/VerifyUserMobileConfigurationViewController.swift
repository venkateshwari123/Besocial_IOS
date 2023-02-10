//
//  VerifyUserMobileConfigurationViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 22/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit
import TextFieldEffects
class VerifyUserMobileConfigurationViewController: UIViewController {
    
    //MARK:-Outlets
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var countryFlagImage: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var visibleSwitchOutlet: UISwitch!
    
    
    //MARK:- Variables&Declarations
    var strMobile : String = ""                    // Used to Store Mobile Number
    var isValidNumber: Bool = false                // Used to check the entered Number isValid or not
    var currentCountryName = "US"                  // Used to Store current country name
    var mobileNumber:String?                       // Used to store mobile number
    var countryImage = UIImage()                   // Used to Store country Flag Image
    var countryCode:String?                        // Used to store country Code
    var phoneNumber: String = ""                   // Used to store phone number
    var isVisibleMobileNumber = false
    var visibleMobileNumberInteger:Int?
    var isSwitchChanged = false
    var mobileConfigurationVM = MobileConfigurationViewModel() // Used To get the referance of the MobileConfigurationViewModel Object
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberTextField.text = strMobile
        uiDesign()
        addDoneButtonOnKeyboard()
        self.countryFlagImage.image = countryImage
        self.countryCodeLabel.text = countryCode
        self.mobileConfigurationVM.countryCode = countryCode
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
         if visibleMobileNumberInteger == 1 {
            self.visibleSwitchOutlet.isOn = true
        }else {
            self.visibleSwitchOutlet.isOn = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        phoneNumberTextField.becomeFirstResponder()
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
        
        self.phoneNumberTextField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        
        self.phoneNumberTextField.placeholder = Strings.phoneNumber.localized
        self.phoneNumberTextField.font = Utility.Font.Regular.ofSize(17)
        let frame = self.phoneNumberTextField.frame
        self.phoneNumberTextField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
        
        let path = Bundle.main.path(forResource: Strings.callingCodes, ofType: Strings.plist)
        let array = NSArray(contentsOfFile: path!) as! [[String: String]]
        if let defaultCountry = array.filter({$0[Strings.dialCode] == countryCode}).first{
            if let countryImageName = defaultCountry[Strings.code] {
                 currentCountryName = countryImageName
            }
            if let countryImagename = defaultCountry[Strings.code] {
                self.countryImage =  countryImage(code: countryImagename)
            }
         }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: Strings.done.localized, style: .done
        , target: self, action: #selector(nextAction))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Confirm Phone Number")
       
    }
    
    
    
    /// Country Flag Based on country code
    ///
    /// - Parameter code: country code
    /// - Returns: Flag Image
    fileprivate func countryImage(code: String) -> UIImage {
        let bundle = "assets.bundle/"
        return UIImage(named: bundle + code.lowercased() + ".png") ?? UIImage()
    }
    
    
    /// Adding ToolBar and Done button on the Keyboard
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
    
    /*
     Feat Name:- check isPhone exist
     Feat Date:- 19/04/21
     Feat By  :- Nikunj C
     Description of Feat:- implement isRegister api
     */
    @objc func nextAction() {
        if let userNumber = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String{
            /*
             Bug Name:- done button not work when change only phone number visibility
             Fix Date:- 19/04/21
             Fixed By:- Nikunj C
             Description of Fix:- in if condition add more limit that if is VisibileMobilenumber false then return
             */
            if self.phoneNumberTextField.text! == userNumber && !self.isSwitchChanged{
                return
            }else{
                self.mobileConfigurationVM.isValidmobileNumberOtp(number: self.phoneNumberTextField.text!, andcountryCode: countryCode!)
                self.mobileConfigurationVM.didUpdateAny = { result in
                    print("isExistNumberResult",result)
                    if self.isSwitchChanged{
                        self.requestOtp()
                    }else{
                        Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrExistNumber)
                    }
                }
                self.mobileConfigurationVM.didError = { error in
                    if error.code == 204{
                        self.requestOtp()
                    }else{
                        print("isExistNumber error = ",error.localizedDescription)
                    }
                }
                
            }
        }else {
            requestOtp()
        }
    }
    
    
    func requestOtp() {
        Helper.showPI()
              self.mobileConfigurationVM.mobileNumber = phoneNumberTextField.text ?? ""
              let url = AppConstants.requestMobileVerification
              self.mobileConfigurationVM.requestMobileOtpCall(strUrl: url) { (success, error) in
                  if success{
                      let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                      
                      /// Pushing To Verification View Controller
                      let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.verificationViewControllerId) as! VerificationViewController
                      verificationVc.isVisibleMobileNumber = self.isVisibleMobileNumber
                      verificationVc.viaEmailOrPhone = Strings.viaMobile
                      verificationVc.phoneNumber = self.phoneNumberTextField.text
                      verificationVc.countryCode = self.countryCode
                      verificationVc.isStarConfiguration = true
                      self.navigationController?.pushViewController(verificationVc, animated: true)
                  }else if let error = error{
                      Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                  }
              }
              Helper.hidePI()
    }
    
    /// Presenting Country Picker ViewController
    ///
    /// - Parameter sender: country picker button
    @IBAction func countryPickerAction(_ sender: UIButton) {
        let countryPickerVc = VNHCountryPicker.instantiate(storyBoardName: AppConstants.StoryBoardIds.CountryPicker) as VNHCountryPicker
        countryPickerVc.delegate = self
        self.present(countryPickerVc, animated: true)
    }
    
    @IBAction func visiblePhoneNumber(_ sender: UISwitch) {
        isSwitchChanged = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        if visibleSwitchOutlet.isOn {
            isVisibleMobileNumber = true
        }else {
            isVisibleMobileNumber = false
         }
    }
    
    /// Requesting For OTP Via Mobile Number
    ///
    /// - Parameter sender: Next button
//    @IBAction func btnNext_Tapped(_ sender : UIButton){
//        Helper.showPI()
//        self.mobileConfigurationVM.mobileNumber = phoneNumberTextField.text ?? ""
//        let url = AppConstants.requestMobileVerification
//        self.mobileConfigurationVM.requestMobileOtpCall(strUrl: url) { (success, error) in
//            if success{
//                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
//
//                /// Pushing To Verification View Controller
//                let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.verificationViewControllerId) as! VerificationViewController
//                verificationVc.isVisibleMobileNumber = self.isVisibleMobileNumber
//                verificationVc.viaEmailOrPhone = Strings.viaMobile
//                verificationVc.phoneNumber = self.phoneNumberTextField.text
//                verificationVc.countryCode = self.countryCode
//                verificationVc.isStarConfiguration = true
//                self.navigationController?.pushViewController(verificationVc, animated: true)
//            }else if let error = error{
//                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
//            }
//        }
//        Helper.hidePI()
//    }
}




// MARK: - UITextFieldDelegate
extension VerifyUserMobileConfigurationViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
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
        
        if let userNumber = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String{
                  if txtAfterUpdate == userNumber {
                      navigationItem.rightBarButtonItem?.isEnabled = false
                  }else{
                      navigationItem.rightBarButtonItem?.isEnabled = true
                  }
              }else {
                  navigationItem.rightBarButtonItem?.isEnabled = true
              }
        
        
        
        self.isValidNumber = self.isEnteredNumberValid(number: number!)
        //        formatter.inputString(textWithoutSpaces) // This is the initial value of the phoneFormatter each time the delegate method is called
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
    
    
    
    
    
    
    
    // To validate number user is entring is valid or not
    //
    // - Parameter number: number entered by user
    // - Returns: if valid return true otherwise false
    fileprivate func isEnteredNumberValid(number: String) -> Bool{
        var mobileNumber = number
        if mobileNumber.first == "0"{
            mobileNumber.remove(at: number.startIndex)
        }
        phoneNumber  = mobileNumber
        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNum = try phoneUtil.parse(phoneNumber, defaultRegion: currentCountryName)
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
extension VerifyUserMobileConfigurationViewController:VNHCountryPickerDelegate{
    func didPickedCountry(country: VNHCounty, flag: UIImage) {
        self.countryFlagImage.image = flag
        self.currentCountryName = country.code
        self.countryCodeLabel.text = country.dialCode
        countryCode = country.dialCode
        self.mobileConfigurationVM.countryCode = country.dialCode
    }
}
