//
//  LoginVCUIE.swift
//  Shoppd
//
//  Created by Rahul Sharma on 24/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

extension LoginVC{
    
    func initialSetUp(){
        
        emailView.layer.cornerRadius = 16
        passwordView.layer.cornerRadius = 16
        mobileNoView.layer.cornerRadius = 16
        
        appleLoginButton.layer.cornerRadius = 16
        googleLoginButton.layer.cornerRadius = 16
        facebookLoginButton.layer.cornerRadius = 16
        emailLoginButton.layer.cornerRadius = 16
        emailLoginButton.clipsToBounds = true
        popupView.layer.cornerRadius = 30
        loginButtonView.layer.cornerRadius = 16
        loginButtonView.clipsToBounds =  true
        self.countryCode.textColor = Utility.appColor()
//        doneButton.layer.cornerRadius = doneButton.bounds.height / 2
//        doneButton.clipsToBounds = true
        
        let color = UIColor.setColor(lightMode: AppColourStr.loginTxtBackground, darkMode: AppColourStr.whiteColor)
        
        /*
         Bug Name:- change phoneTF place holder
         Fix Date:- 25/03/2021
         Fixed By:- Nikunj C
         Description of Fix:- change place holder
         */
        
        
        phoneNumberTF.attributedPlaceholder = NSAttributedString(string: "Enter".localized + " " + "Phone Number".localized, attributes: [NSAttributedString.Key.foregroundColor   : color, NSAttributedString.Key.font : UIFont(name: "ProductSans-Bold", size: 16) as Any ])
        
        
        Fonts.setFont(emailTF, fontFamiy: .custom("ProductSans-Bold"), size: .custom(16), color:  #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1) )
        Fonts.setFont(passwordTF, fontFamiy: .custom("ProductSans-Bold"), size: .custom(16), color: #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        
        let placehlderColor = UIColor.setColor(lightMode: AppColourStr.loginTxtBackground, darkMode: AppColourStr.whiteColor)
        
        let plaeholderDic  : [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "ProductSans-Bold", size: 16) as Any, NSAttributedString.Key.foregroundColor : placehlderColor]
        
        emailTF.attributedPlaceholder = NSAttributedString(string: "Email".localized, attributes: plaeholderDic )
        passwordTF.attributedPlaceholder = NSAttributedString(string: "Password".localized, attributes: plaeholderDic )
        Fonts.setFont(termsTF, fontFamiy: .ternary(.Regular), size: .custom(16), color:#colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        
        let color1 = UIColor.setColor(lightMode: AppColourStr.picoaddaHeadingLabel, darkMode: AppColourStr.whiteColor)
        
        let attrStr = NSMutableAttributedString()
        attrStr.append(NSAttributedString(string: "Welcome to".localized + " ", attributes: [NSAttributedString.Key.font : UIFont(name: "ProductSans-Regular", size: 16) as Any, NSAttributedString.Key.foregroundColor :color1 ]))
    
        
        attrStr.append(NSAttributedString(string: AppConstants.AppName, attributes: [NSAttributedString.Key.font : UIFont(name: "ProductSans-Bold", size: 16) as Any, NSAttributedString.Key.foregroundColor :color1 ]))
        
        welcomeLabel.attributedText = attrStr
        descriptionLabel.text = "Manage your account".localized + ", " + "check notification".localized + ", " + "comment on videos and more".localized
        enterPasswordLbl.text = "Enter Password".localized
        forgotPasswordLbl.text = "Forgot Password".localized
        loginTitleLabel.text = "LOG IN".localized
        emailLoginButton.setTitle("Login with Email".localized, for: .normal)
//        createAccountTitle.text = "Don’t have an account?"
//        forgotPasswordButton.text = "Forgot Password?"
//        createAccountButton.setTitle("Create one.", for: .normal)
        orTitleLabel.text = "OR".localized
//        emailTF.placeholderLabel.text = "Email Address"
//        passwordTF.placeholderLabel.text = "Password"
        navigationController?.navigationBar.isHidden = true
//        clearPhoneBGView.isHidden = true
        Fonts.setFont(forgotPasswordLbl, fontFamiy: .primary(.Regular), size: .custom(11), color:UIColor.setColor(lightMode: AppColourStr.blackColor, darkMode: AppColourStr.whiteColor))
//        Fonts.setFont(loginTitleLabel, fontFamiy: .primary(.Medium), size: .custom(15), color: .white)
       
//        Fonts.setFont(createAccountTitle, fontFamiy: .primary(.Regular), size: .standard(.h12), color: UIColor.Dark.gray)
//        Fonts.setFont(createAccountButton, fontFamiy: .primary(.Medium), size: .standard(.h12), color: UIColor.blue)

//        Fonts.setFont(invalideCredentialMessage, fontFamiy: .primary(.Regular), size: .custom(13), color: UIColor.Light.red)
//        clearemailButton.isHidden = true
//        Helper.addShadowToCustomView(view: googleView)
//        Helper.addShadowToCustomView(view: loginView)
//        Helper.addShadowToCustomView(view: facebookView)
//        invalideCredentialMessage.isHidden = true
        emailTF.delegate = self
        passwordTF.delegate = self
        phoneNumberTF.delegate = self
        
       loginButtonViewIsEnable = false
//        emailTF.placeholderFontScale = 0.85
//        emailTF.placeholderColor = UIColor.Light.black.withAlphaComponent(0.59)
//        passwordTF.placeholderFontScale = 0.85
//        passwordTF.placeholderColor = UIColor.Light.black.withAlphaComponent(0.59)
//        Fonts.setFont(countryCode, fontFamiy: .primary(.Medium), size: .custom(15), color: UIColor.Dark.black)
//        Fonts.setFont(phoneNumberPlaceHolder, fontFamiy: .primary(.Regular), size: .standard(.h12), color: UIColor.Light.black.withAlphaComponent(0.59))
//        Fonts.setFont(phoneNumberTF, fontFamiy: .primary(.Medium), size: .custom(15), color: UIColor.Dark.black)
//        emailPlaceHolder = false
//        passwordPlaceHolder = false
        emailLoginButton.setBackgroundColor(UIColor.setColor(lightMode: AppColourStr.loginTxtBackground, darkMode: AppColourStr.whiteColor), forState: .normal)
        mobileNoView.backgroundColor = UIColor.setColor(lightMode: AppColourStr.loginTxtBackground, darkMode: AppColourStr.whiteColor)
        emailView.backgroundColor = UIColor.setColor(lightMode: AppColourStr.loginTxtBackground, darkMode: AppColourStr.whiteColor)
        passwordView.backgroundColor = UIColor.setColor(lightMode: AppColourStr.loginTxtBackground, darkMode: AppColourStr.whiteColor)
        emailTF.addAccessoryView()
        passwordTF.addAccessoryView()
        phoneNumberTF.addAccessoryView()
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "go-back-left-arrow")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "go-back-left-arrow")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        invalideCredentialMessage.isHidden = true
//        invailideStackView.isHidden = true
    }
    
    func configureViews(){
        self.emailValidateButton.isHidden = true
        self.normalHeaderView.isHidden = false
        self.emailHeaderView.isHidden = true
        self.backBtnImageView.image = #imageLiteral(resourceName: "cross_dark")
        if AppConstants.appType == .dubly {
            self.dismissView.isHidden = false
        }else{
            self.dismissView.isHidden = true
        }
        
        switch logineType {
        case .Email:
            mobileNoView.isHidden = true
            emailView.isHidden = false
            passwordView.isHidden = true
            loginButtonView.isHidden = true
            orViewTopConstraint.constant = -50
//            loginStackViewHeightConstraint.constant = 60
            self.emailValidateButton.isHidden = !Helper.isValidEmail(emailText: self.emailTF.text!)
            forgotPasswordLbl.isHidden = true
//            invailideStackView.isHidden = true
            emailLoginButton.setTitle("Login with".localized + " " + "Mobile number".localized, for: .normal)
            
            emailLoginButton.setImage(UIImage(named: "login_phone"), for: .normal)
        default:
            emailView.isHidden = true
            passwordView.isHidden = true
            mobileNoView.isHidden = false
            loginButtonView.isHidden = true
            orViewTopConstraint.constant = -50
//            loginStackViewHeightConstraint.constant = 60
            forgotPasswordLbl.isHidden = true
            emailLoginButton.setTitle("Login with".localized + " " + "Email".localized, for: .normal)
            emailLoginButton.setImage(UIImage(named: "login_email"), for: .normal)
        }
    }
    
    func handleSuccessResponse(){
//        switch logineType{
//        case .Email:
//            navigationController?.dismiss(animated: true, completion: nil)
//        case .Phone(_):
//            guard let token = loginVM.tokenID, let countryCode = countryCode.text, let phoneNumber = phoneNumberTF.text else{return}
//            let vc = VerificationVC.instantiate(storyBoardName: "Authentication") as VerificationVC
//            vc.verificationData = VerificationData(countryCode: countryCode, phoneNumber: phoneNumber, otpId: token)
//            vc.verificationType = .login
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func handlerErrors(errorCode:APICalls.ErrorCode){
        passwordTF.clear()
        loginButtonViewIsEnable = false
//        switch errorCode{
//        case .Unauthorized:
////            switch logineType{
////            case .Email:
////                self.invalideCredentialMessage.text = "Incorrect Password"
////            case .Phone(_):
////                break
////            }
//            loginButtonAction(UIButton())
//        case .NotFound:
//            switch logineType{
//            case .Email(let emailType):
//                switch emailType{
//                case .normal:
////                    self.invalideCredentialMessage.isHidden = false
////                    self.invalideCredentialMessage.text = "Invalid User"
//                    self.presentPrompt(message: loginVM.loginErrorMessage ?? "")
//                case .faceBook:
//                    guard let userdata = LoginVM.faceBookUserData else{return}
//                    loginVM.signUpAPI(name: userdata.name, email: userdata.email, phoneNumber: userdata.picture.data.url, countryCode: userdata.id, terms: 1, loginType: .Email(.faceBook))
//                case .google:
//                    guard let userData = LoginVM.googleUserData else{return}
//                    var imageUrl = ""
//                    if userData.profile.hasImage{
//                        imageUrl = userData.profile.imageURL(withDimension: 200)?.absoluteString ?? ""
//                    }
//                    loginVM.signUpAPI(name: userData.profile.givenName, email: userData.profile.email, phoneNumber: imageUrl, countryCode: userData.userID, terms: 1, loginType: .Email(.google))
//                case .apple:
//                    if #available(iOS 13.0, *) {
//                        guard let userData = LoginVM.appleuserData else {return}
//                        loginVM.signUpAPI(name: userData.fullName?.givenName ?? "", email: userData.email ?? "", phoneNumber: "", countryCode: userData.user, terms: 1, loginType: .Email(.apple))
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                    break
//                }
//            case .Phone(_):
//                clearPhoneBGView.isHidden = false
//                self.presentPrompt(message: loginVM.loginErrorMessage ?? "")
//            }
//        case .accountDeleted,.Rejected,.Banned:
//            switch logineType {
//            case .Phone(_):
//                clearPhoneBGView.isHidden = false
//            default:
//                clearPhoneBGView.isHidden = true
//            }
//            self.presentPrompt(cancel: "Cancel",message: loginVM.loginErrorMessage ?? "")
//        case .InternalServerError,.InternalServerError2,.InternalServerError4:
//            Helper.showAlertWithOutTitle(message: loginVM.loginErrorMessage ?? "Internal Server Error", type: 0)
//        default:
//            self.invalideCredentialMessage.isHidden = false
//            break
//        }
    }
    
    func presentPrompt(cancel:String = "Retry",message:String = ""){
        view.endEditing(true)
//        let alertmessage = message.isEmpty ? "OOps! Seems like this phone number is not registered with us, please try signing up try entering a different phone number" : message
//        let logoutView = LogOutVC.instantiate(storyBoardName: "Authentication") as LogOutVC
//        logoutView.logOutAction = createAcoountAction(_:)
//        logoutView.titleDescription = alertmessage
//        logoutView.logoutTitleText = "Sign Up"
//        logoutView.canceTitle = cancel
//        if let tabBarView = tabBarController{
//            tabBarView.present(logoutView, animated: true, completion: nil)
//        }else{
//            self.present(logoutView, animated: true, completion: nil)
//        }
        let vc = RegistrationVC.instantiate(storyBoardName: "Authentication") as RegistrationVC
        let user = User.init(modelData: [:])
        user.email = emailTF.text ?? ""
        user.number = phoneNumberTF.text ?? ""
        user.countryCode = self.countryCode.text ?? ""
        vc.user = user
        vc.mobileNumber = phoneNumberTF.text ?? ""
        vc.emailId = emailTF.text ?? ""
        vc.strCountryCode = self.countryCode.text ?? ""
        vc.countryName = self.countryName
        vc.loginType = self.logineType
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureWhenViewDisappear(){
        if passwordTF != nil {
            passwordTF.clear()
        }
        switch logineType {
        case .Email:
            loginButtonViewIsEnable = false
        default:
           break
        }
    }
    
    func countryPickerAction(){
        phoneNumberTF.clear()
      //  checkemailImageView.isHidden = true
      //  clearemailButton.isHidden = true
        loginButtonViewIsEnable = false
    }
    
    override func keyboardDidShow(_ notification: Notification) {
        guard let keyboardFrame = notification.keyboardFrame else{return}
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + 25, right: 0)
        mainScrollView.contentInset = insets
            UIView.animate(withDuration: 0.25) {
                let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                self.mainScrollView.scrollIndicatorInsets = insets
            }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        mainScrollView.contentInset = insets
        UIView.animate(withDuration: 0.25) {
            self.mainScrollView.scrollIndicatorInsets = insets
        }
    }
    
}

extension LoginVC:CountryDataDelegate{
    
    func countryData(countryName: String, phoneCode: String, countryCode: String, countryFlag: UIImage) {
        strCountryCode = phoneCode
        self.countryCode.text = phoneCode
        self.countryName = countryCode
    }
}
