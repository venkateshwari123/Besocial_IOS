//
//  ResetPasswordVC.swift
//  Shoppd
//
//  Created by Rahul Sharma on 26/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit
import RxSwift
import TextFieldEffects

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var countryCode: UILabel!
    @IBOutlet weak var phoneNumberPlaceholder: UILabel!
    @IBOutlet weak var continueButtonOutlet: UIButton!
    @IBOutlet weak var phoneNumberBoarderView: UIView!
    @IBOutlet weak var countryPickerButton: UIButton!
    @IBOutlet weak var newPasswordBoarderView: UIView!
    @IBOutlet weak var repearPasswordBoarderView: UIView!
    @IBOutlet weak var emailBoarderView: UIView!
    @IBOutlet weak var resetTitle: UILabel!
    @IBOutlet weak var userIdStackView: UIStackView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var resetPasswordStackView: UIStackView!
    @IBOutlet weak var resetTitleDescription: UILabel!
    @IBOutlet weak var newPasswordTF: HoshiTextField!
    @IBOutlet weak var repeatNewPasswordTF: HoshiTextField!
    @IBOutlet weak var emailTF: HoshiTextField!
    @IBOutlet weak var phoneNumberStackView: UIStackView!
    @IBOutlet weak var emailStackView: UIStackView!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var loginTitle: UILabel!
     @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var invalidMessage: UILabel!
    var emailSentPrompt:EmailSentPrompt?
    var successResetPassword:SuccessResetPassword?
    var currentCountryCode:String?
    let disposeBag = DisposeBag()
    var tokenID:String?
    var countryName = ""
    var emailId = ""
    var loginVM = LoginViewModel(api: LoginAPI())
    
    
    override func loadView() {
        super.loadView()
        initialSetUp()
        configureVC()
    }
    
    var resetType:LoginType = .Phone(.loginPassword)
    
    var isEnableButton:Bool = true{
        didSet{
            loginButtonView.backgroundColor = loginButtonView.setColor(colors:Colors.rgba_red)
            continueButtonOutlet.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         Refactor Name:- simplify reachability code
         Refactor Date:- 12/04/21
         Refactor By  :- Nikunj C
         Description of Refactor:- make commen function in helper class
         */
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            self.countryCode.text = VNHCountryPicker.dialCode(code: countryCode).dialCode
            currentCountryCode = VNHCountryPicker.dialCode(code: countryCode).dialCode
           countryName = VNHCountryPicker.dialCode(code: countryCode).code
            self.countryFlag.image = VNHCountryPicker.getCountryImage(code: countryCode)
               }
        self.emailTF.text = self.emailId
        addTextFieldAction()
        if AppConstants.appType == .dubly {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    
    
    @IBAction func continueButtonAction(_ sender: Any) {
        continueButtonOutlet.isEnabled = false
        self.emailTF.resignFirstResponder()
        self.newPasswordTF.resignFirstResponder()
        self.repeatNewPasswordTF.resignFirstResponder()
        switch resetType {
        case .Email(let type):
            if type == .setPassword {
                guard let emailAddress = emailTF.text,!emailAddress.isEmpty else{return}
                guard let password = newPasswordTF.text, let confirmPassword = repeatNewPasswordTF.text else{return}
                if password != confirmPassword{
                    invalidMessage.text = "Entered passwords do not match".localized + "."
                    invalidMessage.isHidden = false
                    return
                }
                loginVM.forgotPassword(password:password,email:emailAddress, type: .Email ){ success,id  in
                    if success{
                    self.handleSuccessResponse()
                    }else{
                    self.handleErrorResponse()
                    }
                }
            }else{
                guard let emailAddress = emailTF.text,!emailAddress.isEmpty else{return}
                loginVM.requestOtpEmail(withType: 2, andUserEmailId: emailAddress)
                loginVM.didUpdateAny = { userObj in
                    self.handleSuccessResponse()                }
                loginVM.didError = { error in
                    self.handleErrorResponse()
                }

//                forgotPassword(email:emailAddress, type: .Email ){ success,id  in
//                    if success{
//                    self.handleSuccessResponse()
//                    }else{
//                    self.handleErrorResponse()
//                    }
//                }
            }
            

        case .Phone(let viewType):

            if viewType == .loginPassword{
                guard let countryCode = countryCode.text, let phoneNumber = phoneNumberTF.text else{return}
                loginVM.forgotPassword(password:newPasswordTF.text!, mobile:phoneNumber, dialCode: countryCode, type: .Phone ){ (success, id) in
                    if success{
                    self.handleSuccessResponse(otpId: id)
                    }else{
                    self.handleErrorResponse()
                    }
                    
                }
                
            }else{
                guard let password = newPasswordTF.text, let confirmPassword = repeatNewPasswordTF.text,let token = tokenID else{return}
                if password != confirmPassword{
                    invalidMessage.text = "Entered passwords do not match".localized + "."
                    invalidMessage.isHidden = false
                    return
                }
                
                loginVM.resetPassword(tokenId: token, newPassword: confirmPassword){success,_ in
                    if success{
                    self.handleSuccessResponse()
                    }else{
                    self.handleErrorResponse()
                    }
                }
            }

        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        emailTF.resignFirstResponder()
        phoneNumberTF.resignFirstResponder()
        switch resetType{
        case .Email:
            navigationController?.popViewController(animated: true)
        case .Phone(let type):
            if type == .setPassword{
                navigationController?.viewControllers.forEach{
                    if $0 != navigationController?.viewControllers.last{
                        if $0 is ResetPasswordVC{
                            navigationController?.popToViewController($0 as! ResetPasswordVC, animated: true)
                        }
                    }
                }
            }else{
                navigationController?.popViewController(animated: true)
            }
        }
        
    }
    @IBAction func countryPickerButtonAction(_ sender: Any) {
        let countryPicker = CountryPickerVC.instantiate(storyBoardName: "Authentication") as CountryPickerVC
        countryPicker.backButtonActionClosure = countryPickerAction
        countryPicker.currentCountryCode = currentCountryCode
        countryPicker.countryDataDelegate = self
        present(countryPicker, animated: true, completion: nil)
    }
    
    func closeEmailPrompt(){
        emailSentPrompt?.removeFromSuperview()
        let vc = VerificationVC.instantiate(storyBoardName: "Authentication") as VerificationVC
        vc.verificationType = .resetPassword
        vc.emailId = self.emailTF.text!
        self.navigationController?.pushViewController(vc, animated: false)
        
//        navigationController?.popViewController(animated: true)
    }
}
