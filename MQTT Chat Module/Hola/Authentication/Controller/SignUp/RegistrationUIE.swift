//
//  RegistrationUIE.swift
//  Shoppd
//
//  Created by Rahul Sharma on 27/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

extension RegistrationVC {
    
    func initialSetUp(){
        
        popupView.layer.cornerRadius = 30
        firstNameView.layer.cornerRadius = 16
        lastNameView.layer.cornerRadius = 16
        userNameView.layer.cornerRadius = 16
        emailView.layer.cornerRadius = 16
        passwordView.layer.cornerRadius = 16
        signInButton.layer.cornerRadius = 16
        mobileNoView.layer.cornerRadius = 16
        
        let color = #colorLiteral(red: 0.9058823529, green: 0.9098039216, blue: 0.9568627451, alpha: 1)
        
        firstNameView.backgroundColor = color
        lastNameView.backgroundColor = color
        userNameView.backgroundColor = color
        emailView.backgroundColor = color
        passwordView.backgroundColor = color
        mobileNoView.backgroundColor = color
        
        let c = #colorLiteral(red: 0.1490196078, green: 0.0431372549, blue: 0.0431372549, alpha: 1)
        
        
        
        phoneNumberTF.attributedPlaceholder = NSAttributedString(string: "0123456789", attributes: [NSAttributedString.Key.foregroundColor   : #colorLiteral(red: 0.7764705882, green: 0.8196078431, blue: 0.8901960784, alpha: 1), NSAttributedString.Key.font : UIFont(name: "ProductSans-Bold", size: 16) as Any ])
        
        Fonts.setFont(termsTF, fontFamiy: .ternary(.Regular), size: .custom(16), color:#colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        Fonts.setFont(signInButton, fontFamiy: .ternary(.Bold), size: .custom(16), color:  .white)
        Fonts.setFont(sublineLabel, fontFamiy: .ternary(.Regular), size: .custom(14), color:  #colorLiteral(red: 0.6039215686, green: 0.6431372549, blue: 0.7058823529, alpha: 1))
        Fonts.setFont(firstNameTF, fontFamiy: .ternary(.Bold), size: .custom(16), color:  #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        
        Fonts.setFont(userNameTF, fontFamiy: .ternary(.Bold), size: .custom(16), color:#colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        Fonts.setFont(lastNameTF, fontFamiy: .ternary(.Bold), size: .custom(16), color: #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        Fonts.setFont(emailTF, fontFamiy: .ternary(.Bold), size: .custom(16), color: #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        Fonts.setFont(passwordTF, fontFamiy: .ternary(.Bold), size: .custom(16), color: #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1) )
        
        firstNameTF.placeholder = "First Name".localized
        lastNameTF.placeholder = "Last Name".localized
        userNameTF.placeholder = "Username".localized
        emailTF.placeholder = "Email".localized
        passwordTF.placeholder = "Password".localized
        sublineLabel.text = "Create".localized + " " + "a new".localized + "account on".localized + " " + "\(AppConstants.AppName)"
        titleHeader.text = "Sign Up".localized
        signInButton.setTitle("Sign Up".localized, for: .normal)
    
//        phoneNumberTF.placeholder = "Phone Number *"
        
//        firstNameTF.placeholderFontScale = 0.84
//        userNameTF.placeholderFontScale = 0.84
//        lastNameTF.placeholderFontScale = 0.84
        // emailTF.placeholderFontScale = 0.84
               
        
        let placehlderColor = #colorLiteral(red: 0.7764705882, green: 0.8196078431, blue: 0.8901960784, alpha: 1)
//        userNameTF.placeholderColor =  placehlderColor
//        firstNameTF.placeholderColor = placehlderColor
//        lastNameTF.placeholderColor = placehlderColor
//        emailTF.placeholderColor = placehlderColor
//        passwordTF.placeholderColor = placehlderColor
        
        let plaeholderDic  : [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "ProductSans-Bold", size: 16) as Any, NSAttributedString.Key.foregroundColor : placehlderColor]
        
        userNameTF.attributedPlaceholder = NSAttributedString(string: "Username".localized, attributes: plaeholderDic )
        firstNameTF.attributedPlaceholder = NSAttributedString(string: "First Name".localized, attributes: plaeholderDic )
        lastNameTF.attributedPlaceholder = NSAttributedString(string: "Last Name".localized, attributes: plaeholderDic )
        emailTF.attributedPlaceholder = NSAttributedString(string: "Email".localized, attributes: plaeholderDic )
        passwordTF.attributedPlaceholder = NSAttributedString(string: "Password".localized, attributes: plaeholderDic )
        
        firstNameTF.addAccessoryView()
        userNameTF.addAccessoryView()
        lastNameTF.addAccessoryView()
        emailTF.addAccessoryView()
        passwordTF.addAccessoryView()
        firstNameTF.delegate = self
        userNameTF.delegate = self
        lastNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        phoneNumberTF.delegate = self
        emailTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        phoneNumberTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        firstNameTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        userNameTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lastNameTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        firstNameTF.backgroundColor = .clear
        emailTF.backgroundColor = .clear
        lastNameTF.backgroundColor = .clear
        passwordTF.backgroundColor = .clear
        phoneNumberTF.backgroundColor = .clear
        
        switch loginType {
        case .Email:
            emailView.isHidden = true
        default:
            mobileNoView.isHidden = true
        }
        
        signInButton.isEnabled = false
        signInButton.alpha = 0.5
        
    }
    
    func setDataFromSocial(){
        
        self.firstNameTF.text = user?.firstName ?? ""
        self.lastNameTF.text = user?.lastName ?? ""
        self.emailTF.text = user?.email ?? ""
        
        if let emailId  = self.emailId
        {
            self.emailTF.text = emailId
        }
        
        self.passwordTF.text = self.password ?? ""
    
        
        
    }
    
//    func addDoneAction(textfields:[UITextField]){
//        let bar = UIToolbar()
//        let reset = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction(_:)))
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//        bar.items = [flexibleSpace,reset]
//        bar.sizeToFit()
//        textfields.forEach{ $0.inputAccessoryView = bar}
////        textfield.inputAccessoryView = bar
//    }
    
    /// Validate email and Phone and nextresponder
    
    func handleSuccessResponse(){
//        guard let name = userNameTF.text,let lastName = lastNameTF.text,let email = emailTF.text, let password = confirmPasswordTF.text, let phonenumber = phoneNumberTF.text, let countryCode = countryCode.text, checkMarkButton.tag == 1 else{return}
//        let verifyVC = VerificationVC.instantiate(storyBoardName: "Authentication") as VerificationVC
//        verifyVC.signUpData = SignUpData(name: name, lastName: lastName, email: email, password: password, terms: checkMarkButton.tag)
//        verifyVC.verificationData = VerificationData(countryCode: countryCode, phoneNumber: phonenumber, otpId: loginVM.tokenID!)
//        verifyVC.verificationType = .signUp
//        self.navigationController?.pushViewController(verifyVC, animated: true)
    }
    
    func handleErrorResponse(errorCode:APICalls.ErrorCode){
        Helper.showAlert(message: "Error".localized, head: "SignUp".localized, type: errorCode.rawValue)
    }
    
    func validateSignUpFields(){
            var email1 : String? = ""
        var phonenumber : String? =  ""
        switch loginType {
        case .Email:
            email1 = self.emailId
            phonenumber = self.phoneNumberTF.text
            isValidEmail = true
//            isValidPhoneNumber = true
        default:
            email1 =  emailTF.text
            phonenumber = self.mobileNumber
            isValidPhoneNumber = true
        /*
         Bug Name:- email validation not work properly
         Fix date:- 03/04/21
         Fixed By:- Nikunj C
         Description of Fix:- comment isvalidEmail = true as it valid email when enter one character in any textfield
         */
        
//            isValidEmail = true
        }
    
        /*
         Bug Name:- sign up button not enable issue
         Fix date:- 07/04/21
         Fixed By:- Nikunj C
         Description of Fix:- before use guard which return if validation not work so use if and remove name validation for first and last name
         */
        if let email = email1,let name = firstNameTF.text,let lastName = lastNameTF.text, let password = passwordTF.text,password.length>5,name.length>0,isValidEmail,isValidPhoneNumber, isValidUsername{
            validSignUpData = true
        }else{
            validSignUpData = false
        }
        /*
         Refactor Name:- remove firstname and lastname validation from signup screen
         Refactor Date:- 03/04/21
         Refactor By:- Nikunj C
         Description of Refactor:- refactor firstname and lastname validation
         */
        if validSignUpData
        {
            signInButton.isEnabled = true
            signInButton.alpha = 1
        }
        else
        {
            signInButton.isEnabled = false
            signInButton.alpha = 0.5
        }
    }
    
    override func keyboardDidShow(_ notification: Notification) {
        guard let keyboardFrame = notification.keyboardFrame else{return}
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + 25, right: 0)
        signInScrollView.contentInset = insets
        UIView.animate(withDuration: 0.25) {
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            self.signInScrollView.scrollIndicatorInsets = insets
        }
    }
    func countryPickerAction(){
        phoneNumberTF.clear()
        phoneNumberTF.removeRightView()
        phoneNumberBoarder.backgroundColor = phoneNumberBoarder.setColor(colors: Colors.rgba_lightGray17)
        validSignUpData = false
    }
    override func keyboardWillHide(_ notification: Notification) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        signInScrollView.contentInset = insets
        UIView.animate(withDuration: 0.25) {
            self.signInScrollView.scrollIndicatorInsets = insets
        }
    }
    
    @objc func handleTermTapped(gesture: UITapGestureRecognizer) {
//        let termString = termText as NSString
//        let termRange = termString.range(of: term)
//        let policyRange = termString.range(of: policy)
//
//        let tapLocation = gesture.location(in: termsAndConditions)
//        let index = termsAndConditions.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
//
//        if checkRange(termRange, contain: index) {
////            handleViewTermOfUse()
//            handleTerms(isTerms: true)
//            return
//        }else if checkRange(policyRange, contain: index) {
////            handleViewPrivacy()
//            handleTerms(isTerms: false)
//            return
//        }
    }
    
    func handleTerms(isTerms:Bool){
//        if isTerms{
//            Router.navigateToTermsAndConditions(navigationController: self.navigationController)
//        }else{
//            Router.navigateToPrivacyPolicy(navigationController: self.navigationController)
//        }
     
    }
    
    func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }
}

extension RegistrationVC:CountryDataDelegate{
    
    func countryData(countryName: String, phoneCode: String, countryCode: String, countryFlag: UIImage) {
        strCountryCode = phoneCode
        self.countryCode.text = phoneCode
        self.countryFlag.image = countryFlag
        self.countryName = countryCode
    }
}
