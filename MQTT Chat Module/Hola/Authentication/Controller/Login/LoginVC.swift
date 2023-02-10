//
//  LoginVC.swift
//  Shoppd
//
//  Created by Rahul Sharma on 24/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit
import RxSwift
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class LoginVC: UIViewController, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var backBtnImageView: UIImageView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var termsTF: UITextView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var mobileNoView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var normalHeaderView: UIView!
    @IBOutlet weak var emailHeaderView: UIView!
    
    @IBOutlet weak var emailShowingTextLabel: UILabel!
    @IBOutlet weak var emailValidateButton: UIButton!
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var appleLoginView: UIStackView!
    
    @IBOutlet weak var appleLoginButton: UIButton!
    
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButtonView: UIView!
    
    @IBOutlet weak var clearemailButton: UIButton!
    @IBOutlet weak var checkemailImageView: UIImageView!
    @IBOutlet weak var loginTypeImageView: UIImageView!
    @IBOutlet weak var secureCredentialStackView: UIStackView!
    @IBOutlet weak var toggleSecurableButton: UIButton!
    @IBOutlet weak var invalideCredentialMessage: UILabel!
    @IBOutlet weak var loginTitleLabel: UILabel!
    @IBOutlet weak var forgotPasswordLbl: UILabel!
    @IBOutlet weak var phoneNumberStackView: UIStackView!
    @IBOutlet weak var phoneNumberPlaceHolder: UILabel!
    @IBOutlet weak var emailLoginStackView: UIStackView!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var orTitleLabel: UILabel!
    @IBOutlet weak var createAccountTitle: UILabel!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var countryCode: UILabel!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginImageView: UIImageView!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enterPasswordLbl: UILabel!
    
    var forgotPromptView:ResetViewPrompt?
    
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var orViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var clearPhoneBGView: UIView!
    var logineType:LoginType = .Phone(.loginPassword)
    //    let loginVM = LoginVM()
    var currentCountryCode:String?
    let disposeBag = DisposeBag()
    var loginFrom : Int = 2
    var verificaitonType : Int = 2
    var loginViewModel : LoginViewModel = LoginViewModel.init(api: LoginAPI())
    var strCountryCode : String = "+91"
    var coutryRegionName:String = ""
    var isValidNumber: Bool = false
    var isFromHomeVC:Bool = false
    var countryName:String = "IN"
    
    var isEmailRegister = false
    var isNumberRegister = false
    
    @IBOutlet weak var phoneNumerLoginButton : UIButton!
    
    
    override func loadView() {
        super.loadView()
        initialSetUp()
        configureViews()
    }
    
    var activeTextField:UITextField!
    
//    var emailPlaceHolder:Bool = false{
//        didSet{
//            let fontColor = emailPlaceHolder ? UIColor.Light.black.withAlphaComponent(0.59) : UIColor.Light.black
//            emailTF.placeholderFontScale = 0.85
//            emailTF.placeholderColor = fontColor
//        }
//    }
    
//    var passwordPlaceHolder:Bool = false{
//        didSet{
//            let fontColor = passwordPlaceHolder ? UIColor.Light.black.withAlphaComponent(0.59) : UIColor.Light.black
//            passwordTF.placeholderFontScale = 0.9
//            passwordTF.placeholderColor = fontColor
//        }
//    }
    
    var isvalidEmail:Bool = false{
        didSet{
//            checkemailImageView.image = UIImage(named: self.isvalidEmail ? "Success_Check" : "cross")
//            clearemailButton.isHidden = isvalidEmail
        }
    }
    
    var loginButtonViewIsEnable:Bool = false {
        didSet{
            loginButtonView.backgroundColor  = self.loginButtonViewIsEnable ? UIColor.blue : UIColor.blue.withAlphaComponent(0.4)
            loginButtonOutlet.isEnabled = self.loginButtonViewIsEnable
            phoneNumerLoginButton.isHidden = !self.loginButtonViewIsEnable
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            self.countryCode.text = VNHCountryPicker.dialCode(code: countryCode).dialCode
            strCountryCode = VNHCountryPicker.dialCode(code: countryCode).dialCode
           countryName = VNHCountryPicker.dialCode(code: countryCode).code
               }
        self.setUpTermsText()
        passwordTF.addTarget(self, action: #selector(textFieldDidChangeText(_:)), for: .editingChanged)
        phoneNumberTF.addTarget(self, action: #selector(textFieldDidChangeText(_:)), for: .editingChanged)
        emailTF.addTarget(self, action: #selector(textFieldDidChangeText(_:)), for: .editingChanged)
        phoneNumerLoginButton.isHidden = true
        switch logineType{
        case .Email(let type):
            if type == .normal{
                emailTF.becomeFirstResponder()
            }
        case .Phone(_):
            phoneNumberTF.becomeFirstResponder()
        }
                
        /*
         Bug Name :- make app background transparent
         Fix Date :- 22/03/2021
         Fixed By :- Jayaram G
         Description Of Fix :- changed view background color
         */
        if AppConstants.appType == .dubly {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
        

        setUpSignInAppleButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//                GIDSignIn.sharedInstance().delegate = self
//                GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance()?.clientID = AppConstants.googleClientKey
        self.navigationController?.navigationBar.isHidden = true
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        mainScrollView.contentInset = insets
        mainScrollView.scrollIndicatorInsets = insets
        addObserver()
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        configureWhenViewDisappear()
        removeObserver()
    }
    
    
    func setUpTermsText() {
        
        self.termsTF.delegate = self
        
        self.termsTF.isEditable = false
        
        
        let str = "By Login".localized + ", " + "you agree to our".localized + " " + "Terms of Service".localized + " " + "and".localized + " " + "Privacy Policy".localized
        let attributedString = NSMutableAttributedString(string: str)
        if #available(iOS 13.0, *) {
            self.termsTF.tintColor = .label
            self.termsTF.textColor = .label
            self.termsTF.linkTextAttributes = [ .foregroundColor: UIColor.label,.underlineStyle:NSUnderlineStyle.single.rawValue ]
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: (str as NSString).range(of: str))
        } else {
            self.termsTF.tintColor = .black
            self.termsTF.textColor = .black
            self.termsTF.linkTextAttributes = [ .foregroundColor: UIColor.black,.underlineStyle:NSUnderlineStyle.single.rawValue ]
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: (str as NSString).range(of: str))
        }
        var foundRange = attributedString.mutableString.range(of: "Terms of Service".localized)
        attributedString.addAttribute(NSAttributedString.Key.link, value: AppConstants.termsConditionUrl, range: foundRange)
        foundRange = attributedString.mutableString.range(of: "Privacy Policy".localized)
        attributedString.addAttribute(NSAttributedString.Key.link, value: AppConstants.PrivacyPolicy, range: foundRange)
        termsTF.attributedText = attributedString
    }
    
    
    @IBAction func backGroundButtonAction(_ sender: Any) {
        if AppConstants.appType == .dubly {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func showAndHidePasswordAction(_ sender: Any) {
        guard let button = sender as? UIButton else{return}
        passwordTF.isSecureTextEntry = !(button.tag == 0)
        toggleSecurableButton.setImage(UIImage(named: button.tag == 0 ? "show_passwrd":"hide_paswrd" ), for: .normal)
        button.tag = button.tag == 0 ? 1 : 0
    }
    
    
    @IBAction func googleSignIN(_ sender: Any) {
        // GIDSignIn.sharedInstance().signIn()
    }
    
   
    
    @IBAction func loginWithPhoneNumberAction(_ sender: Any) {
        view.endEditing(true)
        switch logineType {
        case .Email:
            navigationController?.popViewController(animated: false)
        default:
            guard let vc = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else{return}
            vc.logineType = .Email(.normal)
            vc.modalTransitionStyle = .crossDissolve
            self.navigationController?.pushViewController(vc, animated: false)
         
          
        }
    }
    
    @IBAction func forgotButtonAction(_ sender: Any) {
        view.endEditing(true)
//        forgotPromptView = UINib(nibName: "ResetPasswordView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? ResetViewPrompt ?? ResetViewPrompt()
//        forgotPromptView?.selectedLoginOption = resetPasswordType(_:)
//        forgotPromptView?.closeButtonAction = closeForgotPrompt
//        forgotPromptView?.frame = view.bounds
//        view.addSubview(forgotPromptView!)
        /*
        Bug Name : Update forgot password flow
        Fix Date : 14-May-2021
        Fixed By : Jayaram G
        Description Of Fix : Changed navigations to new screen
      */
        guard let vc = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "NewResetPasswordVC") as? NewResetPasswordVC else{return}
//        guard let button = sender as? UIButton else{return}
//        vc.resetType = .Email(.normal)
        vc.emailId = self.emailTF.text!
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
   @IBAction func facebookLoginAction (sender : UIButton)
    {
      // facebookLogin()
    }
    
    func facebookLogin(){

            let facebookLoginManager =  LoginManager.init()
        facebookLoginManager.logIn(permissions: ["public_profile", "email"], viewController: self) { (result) in
            switch result {
            case .cancelled:
                break
            case .failed(let error):
                Helper.showAlert(message: "FaceBook", head: "Login failed due to \(error.localizedDescription)", type: 0)
            case .success( _, _, _):
      
                Profile.loadCurrentProfile { (profile, error) in
                    if let user = profile {
                        self.loginViewModel.checkSocialLogin(id:user.userID , type: SocialLogin.Facebook){ isSuccess in
                            let userData = User.init(modelData: [:])
                            userData.firstName = user.firstName ?? ""
                            userData.lastName = user.lastName ?? ""
                            if isSuccess{
                                
                            }else{
                                let vc = RegistrationVC.instantiate(storyBoardName: "Authentication") as RegistrationVC
                                vc.facebookId = user.userID
                                vc.user = userData
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    
                    }
                }
                break
            }
        }
       

    }
    
    
    @IBAction func countryPickerAction(_ sender: Any) {
        let vc = CountryPickerVC.instantiate(storyBoardName: "Authentication") as CountryPickerVC
        vc.backButtonActionClosure = countryPickerAction
        vc.currentCountryCode = strCountryCode
        vc.countryDataDelegate = self
        present(vc, animated: true, completion: nil)
    }
    func resetPasswordType(_ type:LoginType){
        forgotPromptView?.removeFromSuperview()
        guard let vc = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "NewResetPasswordVC") as? NewResetPasswordVC else{return}
//        vc.resetType = type
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func closeForgotPrompt(){
        forgotPromptView?.removeFromSuperview()
    }
    
    @IBAction func createAcoountAction(_ sender: Any) {
        let vc = RegistrationVC.instantiate(storyBoardName: "Authentication") as RegistrationVC
        let user = User.init(modelData: [:])
        user.email = emailTF.text ?? ""
        user.number = phoneNumberTF.text ?? ""
        user.countryCode = self.countryCode.text ?? ""
        vc.user = user
        vc.mobileNumber = phoneNumberTF.text ?? ""
        vc.emailId = emailTF.text ?? ""
        vc.strCountryCode = self.countryCode.text ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clearEmailButtonAction(_ sender: Any) {
        switch logineType{
        case .Phone(_):
            phoneNumberTF.clear()
            clearPhoneBGView.isHidden = true
        //            phoneNumberTF.textFieldDidEndEditing()
        default:
            emailTF.clear()
            checkemailImageView.isHidden = true
            clearemailButton.isHidden = true
//            emailTF.textFieldDidEndEditing()
        }
    }
    @IBAction func dismissButtonAction(_ sender: Any) {
        /*
         Bug Name :- clicking on back from password should take me to enter email and not close controllle
         Fix Date :- 21/05/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Handled back button action
         */
        if forgotPasswordLbl.isHidden {
            view.endEditing(true)
            dismiss(animated: true, completion: nil)
        }else{
            self.configureViews()
        }
    }
    

    
    @IBAction func emailValidationAction(_ sender: Any) {
        guard let email = emailTF.text, email.count > 0 else{return}
        loginViewModel.isValidEmailOtp(mail: email , userName: Utility.getUserName() ?? "", number: "", andcountryCode: "")
        loginViewModel.didUpdateAny = { userObj in
            self.emailShowingTextLabel.text = "Enter the correct password for".localized + " \(email)"
            self.emailHeaderView.isHidden = false
            self.normalHeaderView.isHidden = true
            /*
             Bug Name :- Show back button when user is on password view
             Fix Date :- 27/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Showing back button when user is on password view
             */
            if #available(iOS 13.0, *) {
                self.backBtnImageView.tintColor = .label
            } else {
                self.backBtnImageView.tintColor = .black
                // Fallback on earlier versions
            }
            self.backBtnImageView.image = #imageLiteral(resourceName: "back_arrow")
            self.dismissView.isHidden = false
            self.emailView.isHidden = true
            self.passwordView.isHidden = false
            self.forgotPasswordLbl.isHidden = false
            self.orViewTopConstraint.constant = 20
            self.loginButtonView.isHidden = false
        }
        loginViewModel.didError = { error in
            if error.code == 204 {
                self.presentPrompt(message: "")
            }
        }
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        
        view.endEditing(true)
        
        switch logineType {
        case .Email:
            guard let email = emailTF.text,let password = passwordTF.text, email.count > 0, password.count > 0 else{return}
            self.logineType = .Email(.normal)
            self.loginViewModel.fetchLoginData(withuserName: email, andPassword: password, andnumber: "", andcountryCode: "", countryName: self.countryName)
            self.loginViewModel.didUpdateUser = { userObj in
                print(userObj.firstName)
                self.invalideCredentialMessage.isHidden = true
                UserDefaults.standard.set(userObj.refreshToken, forKey: AppConstants.UserDefaults.refreshToken)
                UserDefaults.standard.setValue(userObj.countryCode, forKeyPath: AppConstants.UserDefaults.countryCode)
                UserDefaults.standard.setValue(userObj.userName, forKeyPath: AppConstants.UserDefaults.userName)
                UserDefaults.standard.synchronize()
                Helper.setDataInNSUser(userObj, key: AppConstants.UserDefaults.LoggedInUser)
                Utility.setIsGuestUser(status: false)
                Utility.createMQTTConnection()
                Utility.creatDocforGroupChat()
                Route.setRootController()
                
            }
            self.loginViewModel.didError = { error in
                if error.code == 204 {
                    self.presentPrompt(message: "")
                }
                if error.code == 412 {
                    self.invalideCredentialMessage.isHidden = false
                    self.invalideCredentialMessage.text = "Incorrect password."
                }
                
            }
        case .Phone(let loginType):
            
            guard let phoneNumber = phoneNumberTF.text else{return}
            loginButtonOutlet.isEnabled = false
            
            self.logineType = .Phone(loginType)
            if !Helper.isValidNumber("\(strCountryCode)" + (phoneNumber)){
                Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrPhoneNumber)
                return
            }
            loginViewModel.isValidmobileNumberOtp(number: phoneNumberTF.text!, andcountryCode: strCountryCode)
            loginViewModel.didUpdateAny = { userObj in
                print(userObj)
                
                self.loginViewModel.requestOtp(withType: 1, andnumber: self.phoneNumberTF.text!, andcountryCode: self.strCountryCode)
                self.loginViewModel.didUpdateAny = { userObj in
                    print(userObj)
                    //Helper.showAlertViewOnWindow("", message: "Otp sent")
                    //                        let controller = self.storyboard?.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.VerifyOTPVC) as! VerifyOTPViewController
                    //                        self.navigationController?.pushViewController(controller, animated: true)
                    let vc = VerificationVC.instantiate(storyBoardName: "Authentication") as VerificationVC
                    //                                    vc.verificationData = VerificationData(countryCode: countryCode, phoneNumber: phoneNumber, otpId: token)
                    //                                    vc.verificationType = .login
                    vc.phoneNumber = self.phoneNumberTF.text!
                    vc.counrtyCode = self.strCountryCode
                    vc.countryName = self.countryName
                    vc.userEnteredNumber = self.strCountryCode+self.phoneNumberTF.text!
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                self.loginViewModel.didError = { error in
                    print(error.localizedDescription)
                }
            }
            loginViewModel.didError = { error in
                  if error.code == 204 {
//                    self.clearPhoneBGView.isHidden = false
                    self.presentPrompt(message: "")
                }
                
                print(error.localizedDescription)
            }
            
            
        //            if tfPassword.text?.count == 0{
        //                Helper.showAlertViewOnWindow("", message: "Please enter password")
        //            }
        //
        //            loginViewModel.verifyOtp(withType: 1, andnumber: tfPhone.text!, andcountryCode: strCountryCode, andotp: tfPassword.text!)
        //            loginViewModel.didUpdateUser = { userObj in
        //                print(userObj.number)
        //                UserDefaults.standard.setValue(userObj, forKey: "UserObject")
        //                Helper.showAlertViewOnWindow("", message: "Logged in successfully")
        //            }
        //            loginViewModel.didError = { error in
        //                print(error.localizedDescription)
        //            }
        
        }
        
//        if loginFrom == UserLoginFrom.UserName{
            //                if tfPhone.text?.count == 0{
            //                    Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrStarChatId)
            //                }else if tfPassword.text?.count == 0{
            //                    Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrPassword)
            //                }else{
            //                    loginViewModel.fetchLoginData(withuserName: tfPhone.text!, andPassword: tfPassword.text!, andnumber: "", andcountryCode: "", countryName: self.countryName)
            //                    loginViewModel.didUpdateUser = { userObj in
            //                        print(userObj.firstName)
            //                        UserDefaults.standard.set(userObj.refreshToken, forKey: AppConstants.UserDefaults.refreshToken)
            //                        UserDefaults.standard.setValue(userObj.countryCode, forKeyPath: AppConstants.UserDefaults.countryCode)
            //                           UserDefaults.standard.synchronize()
            //                        Helper.setDataInNSUser(userObj, key: AppConstants.UserDefaults.LoggedInUser)
            //                        Utility.setIsGuestUser(status: false)
            //
            //                        Route.setRootController()
            //                    }
            //                    loginViewModel.didError = { error in
            //                        print(error.localizedDescription)
            //                    }
            //                }
//        }
//        else if loginFrom == UserLoginFrom.MobileNumber && verificaitonType == VerficiationType.VerificationCodeelse if loginFrom == UserLoginFrom.MobileNumber && verificaitonType == VerficiationType.Password{
            //                if !Helper.isValidNumber(strCountryCode + (tfPhone.text ?? "")){
            //                    Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrPhoneNumber)
            //                }
            //                else if tfPassword.text?.count == 0{
            //                    Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrPassword)
            //                }else{
            //                    loginViewModel.fetchLoginData(withuserName: "", andPassword: tfPassword.text!, andnumber: tfPhone.text!, andcountryCode: strCountryCode, countryName: self.countryName)
            //                    loginViewModel.didUpdateUser = { userObj in
            //                        print(userObj.firstName)
            //                        UserDefaults.standard.set(userObj.refreshToken, forKey: AppConstants.UserDefaults.refreshToken)
            //                           UserDefaults.standard.synchronize()
            //                        if let userPhone = userObj.number as? String {
            //                          userPhone.replace(target: userObj.countryCode, withString: "")
            //                            UserDefaults.standard.set(userObj.number, forKey: AppConstants.UserDefaults.userNumber)
            //
            //                        }
            //                        Utility.setIsGuestUser(status: false)
            //                        UserDefaults.standard.setValue(userObj.countryCode, forKeyPath: AppConstants.UserDefaults.countryCode)
            //                        Helper.setDataInNSUser(userObj, key: AppConstants.UserDefaults.LoggedInUser)
            //                        Route.setRootController()
            //
            //                    }
            //                    loginViewModel.didError = { error in
            //                        if error.code == 404 {
            //                            Helper.showAlertViewOnWindow("Message", message: "Phone number not registered")
            //                            let alertView = UIAlertController.init(title: "Mobile number is not registered.", message: "Do you want to Sign up with this number", preferredStyle: .alert)
            //
            //                            let changeAction = UIAlertAction.init(title: "Change", style: .default, handler: { (action) in
            //                                alertView.dismiss(animated: true, completion: nil)
            //                            })
            //                            let signUpAction = UIAlertAction.init(title: "Signup", style: .default, handler: { (action) in
            //                                let signupVC : SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SignUpVC) as! SignUpViewController
            //                                signupVC.mobileNumber = self.tfPhone.text!
            //                                signupVC.signUpViewModel.number = self.tfPhone.text!
            //                                signupVC.signUpViewModel.countryCode = self.strCountryCode
            //                                self.navigationController?.pushViewController(signupVC, animated: true)
            //
            //                            })
            //                            alertView.addAction(changeAction)
            //                            alertView.addAction(signUpAction)
            //                            self.present(alertView,animated: true)
            //                        }
            //                }
            //            }
//        }
        //        view.endEditing(true)
        //        switch logineType {
        //        case .Email:
        //            guard let email = emailTF.text,let password = passwordTF.text else{return}
        //            loginButtonAction.isEnabled = false
        //            self.logineType = .Email(.normal)
        //            loginVM.loginAPI(parameter1: email, parameter2: password, loginType: logineType)
        //        case .Phone(let loginType):
        //            guard let phoneNumber = phoneNumberTF.text,let countryCode = countryCode.text else{return}
        //            loginButtonAction.isEnabled = false
        //            self.logineType = .Phone(loginType)
        //            loginVM.loginAPI(parameter1: countryCode, parameter2: phoneNumber, loginType: logineType)
        //        }
    }
    
    /// This method is used to assignUI for UIview  fro apple login
    func setUpSignInAppleButton() {
//        if #available(iOS 13.0, *) {
//            let authorizationButton = ASAuthorizationAppleIDButton()
//            authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
//            authorizationButton.cornerRadius = 25
//            //Add button on some view or stack
//            self.appleLoginView.addArrangedSubview(authorizationButton)
//        } else {
//            self.appleLoginView.isHidden = true
//            // Fallback on earlier versions
//        }
    }
    
    
    /// This method is used to get the user data from the apple login
    
   @IBAction func appleLoginButtonAction(sender : UIButton)
    {
        handleAppleIdRequest()
    }
    
    
    @objc func handleAppleIdRequest() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
    }
    
}

extension LoginVC:GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        loginViewModel.checkSocialLogin(id:user.userID , type: SocialLogin.Google){ isSuccess in
            let userData = User.init(modelData: [:])
            userData.firstName = user.profile.givenName ?? ""
            userData.lastName = user.profile.familyName ?? ""
            userData.email = user.profile.email ?? ""
            if isSuccess{
                
            }else{
                let vc = RegistrationVC.instantiate(storyBoardName: "Authentication") as RegistrationVC
                vc.googleId = user.userID
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
     
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
   
    }
    
}


/// This extension is used to take care of Sign in with Apple Delegates
extension LoginVC : ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let user = User.init(modelData: [:])
            user.firstName = appleIDCredential.fullName?.givenName ?? ""
            user.lastName = appleIDCredential.fullName?.familyName ?? ""
            user.email = appleIDCredential.email ?? ""
            loginViewModel.checkSocialLogin(id:userIdentifier , type: SocialLogin.Apple){ isSuccess in
                
                if isSuccess{
                    
                }else{
                    let vc = RegistrationVC.instantiate(storyBoardName: "Authentication") as RegistrationVC
                    vc.appleId = userIdentifier
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
        // Handle error.
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
