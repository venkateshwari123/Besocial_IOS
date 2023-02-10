//
//  RegistrationVC.swift
//  Shoppd
//
//  Created by Rahul Sharma on 27/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit
import RxSwift
import TextFieldEffects
class RegistrationVC: UIViewController {

    @IBOutlet weak var signInScrollView: UIScrollView!
    @IBOutlet weak var userNameStackView: UIStackView!
    @IBOutlet weak var phoneNumberStackView: UIStackView!
    @IBOutlet weak var signUpBottomConstraaint: NSLayoutConstraint!
    @IBOutlet weak var checkemailImageView: UIImageView!
    @IBOutlet weak var checkEmailButton: UIButton!
    @IBOutlet weak var emailStackView: UIStackView!
    @IBOutlet weak var titleHeader: UILabel!
    @IBOutlet weak var paswordStackView: UIStackView!
    @IBOutlet weak var checkPhoneNumberImageView: UIImageView!
    @IBOutlet weak var confirmPaswordStackView: UIStackView!
    @IBOutlet weak var titleHeaderDescription: UILabel!
    @IBOutlet weak var firstNameTF: HoshiTextField!
    @IBOutlet weak var firstNameBoarder: UIView!
    @IBOutlet weak var checkUsernameImageView: UIImageView!
  
    @IBOutlet weak var termsTF: UITextView!
    @IBOutlet weak var mobileNoView: UIView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userNameBoarder: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var emailBoarder: UIView!
    @IBOutlet weak var phoneNumberPlaceHolder: UILabel!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var countryCode: UILabel!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var phoneNumberBoarder: UIView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordBoarder: UIView!
    @IBOutlet weak var confirmPasswordTF: HoshiTextField!
    @IBOutlet weak var confirmPasswordBoarder: UIView!
    @IBOutlet weak var invalidMessage: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var emailinvalid: UILabel!
    @IBOutlet weak var usernameInvalid: UILabel!
    @IBOutlet weak var phoneNumberinvalid: UILabel!
    
    @IBOutlet weak var validUsernameView: UIView!
    @IBOutlet weak var validEmailView: UIView!
    @IBOutlet weak var validPhoneView: UIView!
    
    @IBOutlet weak var lastNameTF: UITextField!
    
    @IBOutlet weak var lastNameBoarder: UIView!
    @IBOutlet weak var passwordButton: UIButton!
    
    @IBOutlet weak var popupView : UIView!
    
    @IBOutlet weak var firstNameView: UIView!
    
    @IBOutlet weak var countryPickerButton : UIButton!
    
    @IBOutlet weak var firstNameErrorLabel : UILabel!
    @IBOutlet weak var lastNameErrorLabel : UILabel!
    @IBOutlet weak var passwordErrorLabel : UILabel!
    
    
    @IBOutlet weak var sublineLabel: UILabel!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var confirmPaswdButton: UIButton!
    
    @IBOutlet weak var clearMobileBtn: UIButton!
    
    @IBOutlet weak var clearUserNameBtn: UIButton!
    let termText = "I accept the Terms & Conditions and Privacy Policy."
    let term = "Terms & Conditions"
    let policy = "Privacy Policy"
    var signUpViewModel : SignUpViewModel = SignUpViewModel()
    var mobileNumber: String = ""
    var strCountryCode : String = "+91"
    var coutryRegionName:String = ""
    var isValidNumber: Bool = false
    var isPrivate : Bool = false
    var profileImageObj:UIImage?
    var termBtnSelected:Bool = false
    var loginViewModel : LoginViewModel = LoginViewModel.init(api: LoginAPI())
    var toPrivacy : Bool = false
    let captureDevice: AVCaptureDevice? = nil
    var imagePickerObj = UIImagePickerController()
    var countryName = ""
    var googleId : String?
    var facebookId : String?
    var appleId : String?
    var user : User? = nil
    var validSignUpData:Bool = true
    var loginType : LoginType?
    var emailId : String?
    var password : String?
    
//    {
//        didSet{
//            signInButton.isEnabled =  self.validSignUpData
//            signInButton.setBackgroundImage(UIImage(named: self.validSignUpData ? "continue" : "continue2"), for: .normal)
//        }
//    }
    
    var isValidEmail = false
    {
        didSet{
            self.checkEmailButton.isHidden = self.isValidEmail
            checkemailImageView.image = UIImage(named: self.isValidEmail ? "validate" : "cross")
        }
    }
    
    var isValidUsername = false
    {
        didSet{
            self.clearUserNameBtn.isHidden = self.isValidUsername
            checkUsernameImageView.image = UIImage(named: self.isValidUsername ? "validate" : "cross")
        }
    }
    var isValidPhoneNumber = false
    {
        didSet{
            self.clearMobileBtn.isHidden = self.isValidPhoneNumber
            checkPhoneNumberImageView.image = UIImage(named: self.isValidPhoneNumber ? "validate" : "cross")
        }
    }

    /*
     Bug Name:- validation not work properly
     Fix Date:- 03/04/21
     Fixed By:- Nikunj C
     Description of Fix:- show validate image according to first name validation and last name
     */
    
//    var isValidFirstName = false
//    {
//        didSet{
//            checkFirstnameImageView.image = UIImage(named: self.isValidFirstName ? "validate" : "cross")
//        }
//    }
//
//    var isValidLastName = false
//    {
//        didSet{
//            checkLastnameImageView.image = UIImage(named: self.isValidLastName ? "validate" : "cross")
//        }
//    }
    
    let disposeBag = DisposeBag()
    override func loadView() {
        super.loadView()
        initialSetUp()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        Bug Name:- for sign up take deivce region's code
        Fix Date:- 25/03/21
        Fixed By:- Nikunj C
        Discription of Fix:- remove code of take region from device and set button title from country name
        */
        
        countryPickerButton.setTitle(strCountryCode, for: .normal)
        
        signInButton.isEnabled = false
        setUpTermsText()
        /*
         Bug Name :- make app background transparent
         Fix Date :- 22/03/2021
         Fixed By :- Jayaram G
         Description Of Fix :- changed view background color
         */
        if AppConstants.appType == .dubly {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }

        self.setDataFromSocial()
        
        switch loginType  {
        case .Email:
            isValidEmail = true
        default:
            isValidPhoneNumber = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        addObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    func setUpTermsText() {
        
        self.termsTF.delegate = self
        
        self.termsTF.isEditable = false
        
        
        let str = "By Signup".localized + ", " + "you agree to our".localized + " " + "Terms of Service".localized + " " + "and".localized + " " + "Privacy Policy".localized
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
    
    @IBAction func countryPickerAction(_ sender: Any) {
        let countryPickerVc = VNHCountryPicker.instantiate(storyBoardName: AppConstants.StoryBoardIds.CountryPicker) as VNHCountryPicker
        countryPickerVc.delegate = self
        self.present(countryPickerVc, animated: true)
    }
    
    
    
    @IBAction func confirmButtonAction(_ sender: UIButton) {

            passwordTF.isSecureTextEntry = !(sender.tag == 0)
            passwordButton.setImage(UIImage(named: sender.tag == 0 ? "show_passwrd":"hide_paswrd" ), for: .normal)
            sender.tag = sender.tag == 0 ? 1 : 0
        
    }
    
    
    @IBAction func backGroundButtonAction(_ sender: Any) {
        if AppConstants.appType == .dubly {
            self.dismiss(animated: true, completion: nil)
        }else{
            return
        }
        
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func checkMarkButtonAction(_ sender: Any) {
        guard let button = sender as? UIButton else{return}
        UIView.animate(withDuration: 0.25) {
            self.checkMarkImageView.image = UIImage(named: button.tag == 0 ? "checkbox_on_light" : "checkbox_off_light")
        }
        button.tag = button.tag == 0 ? 1 : 0
        validateSignUpFields()
    }
    @IBAction func termsAndConditionsAction(_ sender: Any) {
        
    }
    
    
    @IBAction func clearButtonAction(_ sender: UIButton) {
        if sender.tag == 0{
            self.checkemailImageView.image = nil
            self.checkEmailButton.isHidden = true
            emailTF.clear()
            emailinvalid.isHidden = true
        }else if sender.tag == 1{
            self.checkPhoneNumberImageView.image = nil
            self.clearMobileBtn.isHidden = true
            phoneNumberTF.clear()
            phoneNumberinvalid.isHidden = true
        }
        else{
            self.clearUserNameBtn.isHidden = true
            self.checkUsernameImageView.image = nil
            userNameTF.clear()
            usernameInvalid.isHidden = true
        }
    }
    
    @IBAction func signInButtonAction(_ sender: Any) {
        
        var isFirstName = false
        var isLastName = false
        var isPassword = false
        
        /*
         Bug Name:- validation not work properly
         Fix Date:- 03/04/21
         Fixed By:- Nikunj C
         Description of Fix:- if first name is empty then show error
         */
        if let fname  = firstNameTF.text
        {
            if fname.isEmpty {
                firstNameErrorLabel.text = "Enter First Name"
                firstNameErrorLabel.isHidden = false
            }else{
                firstNameErrorLabel.isHidden = true
            }
        }
        
        
        /*
         Bug Name:- validation not work properly
         Fix Date:- 03/04/21
         Fixed By:- Nikunj C
         Description of Fix:- if last name is empty then show error
         */
        
        if let fname  = lastNameTF.text
        {
//            if fname.isEmpty {
//                lastNameErrorLabel.text = "Enter Last Name"
//                lastNameErrorLabel.isHidden = false
//            }else{
                lastNameErrorLabel.isHidden = true
//            }
            
        }
        
        if let fname  = passwordTF.text
        {
            if fname.isEmpty {
                passwordErrorLabel.text = "Enter Password"
                passwordTF.isHidden = false
            }
            else
            {
                passwordErrorLabel.isHidden = true
            }
        }
        
        /*
         Bug Name:- validation not work properly
         Fix Date:- 03/04/21
         Fixed By:- Nikunj C
         Description of Fix:- if username is empty then also show error in username
         */
        
        if let uName = userNameTF.text
        {
            if uName.isEmpty {
                usernameInvalid.text = "Enter Username"
                checkUsernameImageView.isHidden = false
                usernameInvalid.isHidden = false
            }else if uName.count > 14{
                usernameInvalid.text = "Username must be less than 15 characters."
                checkUsernameImageView.isHidden = false
                usernameInvalid.isHidden = false
            }
            else{
                usernameInvalid.isHidden = true
            }
        }
        var email = ""
        var mobile = ""
        switch loginType {
        case .Email:
            email = self.emailId!
            mobile = self.phoneNumberTF.text!
            isValidEmail = true
            isValidNumber = true
        default:
            email =  emailTF.text!
            mobile = self.mobileNumber
            isValidNumber = true
            isValidEmail = true
        }
        
        
        
        if !isValidEmail || !isValidNumber || !isValidUsername
        {
            return
        }
        
        self.view.endEditing(true)
        self.signUpViewModel.verifySignupDetails(withemailID: email, andUsername: userNameTF.text!, andnumber: mobile, andcountryCode: strCountryCode)
        self.signUpViewModel.didUpdateAny = { [self] response in
            self.loginViewModel.requestOtp(withType: 1, andnumber: mobile, andcountryCode: self.strCountryCode)
            self.loginViewModel.didUpdateAny = { userObj in
                print(userObj)
                guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
                let deviceName = UIDevice.current.name
                let deviceOs = UIDevice.current.systemVersion
                guard let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else {return}
                let modelNumber = UIDevice.modelName
                let controller =  VerificationVC.instantiate(storyBoardName: "Authentication") as VerificationVC
                controller.phoneNumber = mobile
                controller.counrtyCode = self.strCountryCode
                controller.userEnteredNumber = self.strCountryCode+mobile
                var params = ["email":email,
                              "password":self.passwordTF.text!,
                              "userName":self.userNameTF.text!,
                              "firstName":self.firstNameTF.text!,
                              "lastName":self.lastNameTF.text!,
                              "number":mobile,
                              "countryCode":self.strCountryCode,
                              "isPrivate":false,
                              "uploadProfilePic":"false",
                              "deviceId":deviceID,
                              "deviceName":deviceName,
                              "deviceOs":deviceOs,
                              "modelNumber": modelNumber,
                              "countryName": countryName,
                              "appVersion":appVersion,
                              "countryCodeName":countryName,
                              "deviceType":"1"] as [String : Any]
                if let id = self.googleId{
                    params["googleId"] = id
                }
                if let id = self.facebookId{
                    params["facebookId"] = id
                }
                if let id = self.appleId{
                    params["appleId"] = id
                }
                controller.signUpData = params
                controller.isFromRegistration = true
                controller.profileImageObj = self.profileImageObj
                controller.countryName = countryName
                self.navigationController?.pushViewController(controller, animated: false)
            }
            self.loginViewModel.didError = { error in
                print(error.localizedDescription)
            }
        }
        //                }
        //        guard let phonenumber = phoneNumberTF.text, let countryCode = countryCode.text, checkMarkButton.tag == 1 else{return}
        //        signInButton.isEnabled = false
        //
        // loginVM.sendOTP(parameter1: countryCode, parameter2: phonenumber, type: .signUp)
    }
}




//MARK:- CountryPicker Delegate
extension RegistrationVC : VNHCountryPickerDelegate{
    func didPickedCountry(country: VNHCounty, flag: UIImage) {
        countryPickerButton.setTitle(country.dialCode , for: .normal)
        coutryRegionName = country.code
        countryName = country.name
        strCountryCode = country.dialCode
        
        /*
         Bug Name:- phone number validation not work when login with email
         Fix Date:- 09/04/21
         Fix By  :- Nikunj C
         Description of Fix:- put phone number validation
         */
        
        guard  Helper.isValidNumber("\(strCountryCode)" + (self.phoneNumberTF.text ?? "")) else {
            self.isValidPhoneNumber = false
            self.validateSignUpFields()
            return }
//        self.countryCode.text = strCountryCode
    }
}
