//
//  VerificationViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/7/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
import Alamofire
protocol verifyUserEmailDelagate {
    func resendingOtpFunc()
    
}
protocol emailConfigurationDelegate {
    func resendingOtpForEmailConfig()
}
protocol mobileConfigDelegate {
    func resendingOtpForMobileConfig()
}
class VerificationViewController: UIViewController,UIGestureRecognizerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var resendOtpBtnOutlet: UIButton!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    
    //MARK:-Variables&Declarations
    var strOTP : String = ""
    //MARK:- Variables and Declarations
    var viaEmailOrPhone:String?
    var verificationOtpVmObject = VerificationOTPViewModel()
    var remainingTime:Double!
    var emailConfigVmObject = EmailConfigurationViewModel()
    var emailId:String?
    var phoneNumber:String?
    var countryCode:String?
    var isStarConfiguration : Bool = false
    var timer:Timer!
    var resendOtpEmailDelegate:verifyUserEmailDelagate?
    var resendingEmailConfigDelegate:emailConfigurationDelegate?
    var resendingMobileConfigDelegate:mobileConfigDelegate?
    var isVisibleEmail:Bool?
    var isVisibleMobileNumber:Bool?
    struct Constant {
        static let toUserProfileSegue = "toUserProfileSegue"
        static let totalTime = 59.0
        static let elapsingTime = 1.0
        static let alertText = "Alert!!!"
        static let okayActionText = "Okay"
        static let didntGetCode  = "Didn't get code?".localized
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
        addDoneButtonOnKeyboard()
        
        self.verificationOtpVmObject.email = emailId
        self.verificationOtpVmObject.mobileNumber = phoneNumber
        self.verificationOtpVmObject.countryCode = countryCode
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        // convertFromNSAttributedStringKeyDictionary(self.otpTextField.defaultTextAttributes).updateValue(25, forKey: convertFromNSAttributedStringKey(NSAttributedString.Key.kern))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isStarConfiguration{
            if viaEmailOrPhone == Strings.viaEmail{
                descriptionLbl.text = "The verification code has been sent to the email address \"\(self.emailId!)\" Please enter the code below."
            }else if viaEmailOrPhone == Strings.viaMobile{
                   descriptionLbl.text = "The verification code has been sent to the phone number \"\(self.countryCode!)\(self.phoneNumber!)\" Please enter the code below."
            }
            return
        }

        if viaEmailOrPhone == Strings.viaEmail {
            descriptionLbl.text = "The verification code has been sent to the email address \"\(self.emailId!)\" Please enter the code below."
        }
        // else if viaEmailOrPhone == Strings.viaMobile {
//            descriptionLbl.text = "The verification code has been sent to the phone number \"\(self.countryCode!)\(self.phoneNumber!)\" Please enter the code below."
//        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.otpTextField.becomeFirstResponder()
        self.activateTimer()
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
    func uiDesign(){
        self.resendOtpBtnOutlet.isHidden = true
        self.nextBtn.alpha = 0.5
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Enter verification code")
        nextBtn.makeCornerRadious(readious: 20)
    }
    
    //MARK:-Button Actions
    
    /// popping View Controller
    ///
    /// - Parameter sender: back Button
    @IBAction func backToUpdateVc(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// resending OTP Calling API
    ///
    /// - Parameter sender: resend Button
    @IBAction func resendOtpAction(_ sender: UIButton) {
         self.activateTimer()
        self.resendOtpBtnOutlet.isHidden = true
                if isStarConfiguration{
                    if viaEmailOrPhone == Strings.viaEmail {
                        descriptionLbl.text = "The verification code has been sent to the email address \"\(self.emailId!)\" Please enter the code below."
                        resendOtpEmailDelegate?.resendingOtpFunc()
                    }else if viaEmailOrPhone == Strings.viaMobile {
                        descriptionLbl.text = "The verification code has been sent to the phone number \"\(self.countryCode!)\(self.phoneNumber!)\" Please enter the code below."
                        requestOTP()
                    }
                    return
                }
        if viaEmailOrPhone == Strings.viaEmail {
            descriptionLbl.text = "The verification code has been sent to the email address \"\(self.emailId!)\" Please enter the code below."
            resendingEmailConfigDelegate?.resendingOtpForEmailConfig()
        }
                //else if viaEmailOrPhone == Strings.viaMobile {
//            descriptionLbl.text = "The verification code has been sent to the phone number \"\(self.countryCode!)\(self.phoneNumber!)\" Please enter the code below."
//            resendingMobileConfigDelegate?.resendingOtpForMobileConfig()
//        }
       
    }
    
    
    
    
    /// Resending Otp
    func requestOTP() {
        Helper.showPI(_message: "Sending".localized + "...")
        let strURL = AppConstants.requestOTP
        guard let number = self.phoneNumber else { return }
        guard let countryCode = self.countryCode else { return }
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        let params = ["phoneNumber":number,
                      "countryCode":countryCode,
                      "deviceId":deviceID,
                      "development":"true" ] as [String:Any]
        
        let headers = ["authorization":AppConstants.authorization] as [String: String]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.requestOtp.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.requestOtp.rawValue {
                    self.activateTimer()
                    Helper.showAlertViewOnWindow("Message".localized, message: "The verification code has been resent to".localized + " \(self.countryCode!)\(self.phoneNumber!)".localized)
                    Helper.hidePI()
                }
            }, onError: {error in
                Helper.hidePI()
            })
    }
    
    /// Adding ToolBar on Keyboard
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: Strings.done.localized, style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        otpTextField.inputAccessoryView = doneToolbar
    }
    
    /// Done Button Action On ToolBar
    @objc func doneButtonAction(){
        otpTextField.resignFirstResponder()
        verifyingOTPCall()
    }
    
    
    /// Calling Api For verification
    ///
    /// - Parameter sender: next Button
    @IBAction func nextBtnAction(_ sender: UIButton) {
        verifyingOTPCall()
    }
    
    
    ///  verifying OTP
    func verifyingOTPCall(){
        
        // star Configuration
        if isStarConfiguration{
            // viaEmail
            if viaEmailOrPhone == Strings.viaEmail{
                let url = AppConstants.verifyEmail
                self.verificationOtpVmObject.verifyStarEmailID(strUrl: url,email: emailId!, otp: strOTP, isVisible: isVisibleEmail!) { (success, error) in
                    if success{
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshProfileData"), object: nil)
                        let customView = CustomOtpAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                        customView.tag = 30
                        customView.delegete  = self
                        customView.descriptionLabel.text =  Strings.updatedEmail.localized
                        customView.alertImage.image = #imageLiteral(resourceName: "message")
                        self.timerLabel.isHidden = true
                        appDelegetConstant.window.addSubview(customView)
                        customView.popUpAnimation()
                    }else if let error = error{
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                        
                    }
                    Helper.hidePI()
                }
                
            }else if viaEmailOrPhone == Strings.viaMobile{
                // viaPhone
                print("phone")
                let url = AppConstants.verifyStarNumber
                self.verificationOtpVmObject.verifyStarNumerOTP(strUrl: url, isVisible: isVisibleMobileNumber!) { (success, error) in
                    if success{
                        print("Otp verified succesfully")
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshProfileData"), object: nil)
                        let customView = CustomOtpAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                        customView.alertImage.image = #imageLiteral(resourceName: "smartphone (1)")
                        customView.tag = 35
                        customView.delegete  = self
                        self.timerLabel.isHidden = true
                        customView.descriptionLabel.text =  Strings.updatePhoneNumber
                        appDelegetConstant.window.addSubview(customView)
                        customView.popUpAnimation()
                        
                    }else if let error = error{
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                        if error.code == 138 {
                            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterCorrectOtp.localized)
                        }
                    }
                    Helper.hidePI()
                }
                
            }
            return
        }
        // normal verification
        if viaEmailOrPhone == Strings.viaEmail{
            //viaEmail
            let url = AppConstants.verifyOTPByEmail
            self.verificationOtpVmObject.verifyEmailOTP(strUrl: url) { (success, error) in
                if success{
                    print("Otp verified succesfully")
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshProfileData"), object: nil)
                    self.timerLabel.isHidden = true
                    let customView = CustomOtpAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                    customView.tag = 20
                    customView.delegete  = self
                    customView.descriptionLabel.text =  Strings.updatedEmail
                    customView.alertImage.image = #imageLiteral(resourceName: "message")
                    appDelegetConstant.window.addSubview(customView)
                    customView.popUpAnimation()

                }else if let error = error{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                Helper.hidePI()
            }

        }
//        else if viaEmailOrPhone == Strings.viaMobile{
//            //viaPhone
//            print("phone")
//            let url = AppConstants.verifyOTP
//            self.verificationOtpVmObject.verifyMobileOTP(strUrl: url, isVisible: isVisibleMobileNumber!) { (success, error) in
//                if success{
//                    print("Otp verified succesfully")
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshProfileData"), object: nil)
//                    self.timerLabel.isHidden = true
//                    let customView = CustomOtpAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
//                    customView.alertImage.image = #imageLiteral(resourceName: "smartphone (1)")
//                    customView.tag = 35
//                    customView.delegete  = self
//                    customView.descriptionLabel.text =  Strings.updatePhoneNumber
//                    appDelegetConstant.window.addSubview(customView)
//                    customView.popUpAnimation()
//
//                }else if let error = error{
//                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
//                    if error.code == 138 {
//                        Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterCorrectOtp)
//                    }
//                }
//                Helper.hidePI()
//            }
//        }
    }
}
//MARK:- Extensions

// MARK: - UITextFieldDelegate
extension VerificationViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text as NSString? {
            strOTP = text.replacingCharacters(in: range, with: string)
        }
        
        // On inputing value to textfield
        
        self.checkAndEnableNextButton()
        
        if string == ""{
            return true
        }else if strOTP.count == 4{
            self.nextBtn.isEnabled = true
            self.nextBtn.alpha = 1
            textField.resignFirstResponder()
            otpTextField.text = strOTP
            if viaEmailOrPhone == Strings.viaEmail{
                //                        guard let text = otpTextField.text else{ return true}
                verificationOtpVmObject.emailOtp = strOTP
            } else if viaEmailOrPhone == Strings.viaMobile{
                //                        guard let text = otpTextField.text else{ return true}
                verificationOtpVmObject.mobileOtp = strOTP
            }
            self.verifyingOTPCall()
        }else if strOTP.count > 4{
             self.nextBtn.alpha = 1.0
            return false
        }
        return true
        
    }//car/dge/otm/127006
    
    
    /// Managing next Button Action
    private func checkAndEnableNextButton(){
        if (self.otpTextField.text?.count)! >= 4{
            self.nextBtn.alpha = 1.0
            self.nextBtn.isEnabled = true
        }else{
            self.nextBtn.isEnabled = false
        }
    }
}
// Timer Extension

// MARK: - Extension
extension VerificationViewController {
    
    
    /// Activating Timer after coming to this view controller
    func activateTimer()
    {
        remainingTime = Constant.totalTime
        if (timer != nil)
        {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: Constant.elapsingTime, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        
        
        //        firstDigitTextFieldOutlet.text = "1"
        //        secondDigitTextFieldOutlet.text = "1"
        //        thirdDigitTextFieldOutlet.text = "1"
        //        forthDigitTextFieldOutlet.text = "1"
        //
        //        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.gotoNext), userInfo: nil, repeats: false)
        
    }
    
    
    /// Managin CountDown
    @objc func countDown(){
        if remainingTime > 0{
            remainingTime = remainingTime - Constant.elapsingTime
            //  self.resendOtpBtnOutlet.isHidden = true
            self.resendOtpBtnOutlet.isHidden = true
            
            self.timerLabel.text = remainingTime < 10 ? String(format:"00:0%d",Int(remainingTime)) : "00:\(Int(remainingTime))"
        }else {
            timer.invalidate()
            // self.resendOtpBtnOutlet.isHidden = false
            self.resendOtpBtnOutlet.isHidden = false
            self.descriptionLbl.text = "If you have not received the verification code".localized + "," + "please get a new one by clicking on the RESEND button".localized + "."
            self.resendOtpBtnOutlet.alpha = 1.0
            self.timerLabel.text = Constant.didntGetCode
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - CustomAlertOtpViewDelegate
extension VerificationViewController: CustomAlertOtpViewDelegate{
    func okBtnClicked() {
        // for star Configuration
        if isStarConfiguration {
            if viaEmailOrPhone == Strings.viaEmail{
                //viaEmail
                let customalertView = appDelegetConstant.window.viewWithTag(30)
                customalertView?.popDownAnimation(animationDone: { (finished) in
                    if let requestStarVc = self.navigationController?.viewControllers.filter({$0.isKind(of: RequestStarProfileViewController.self)}).first as? RequestStarProfileViewController{
                        requestStarVc.requestStarProfileVmObject.email = self.emailId
                        self.navigationController?.popToViewController(requestStarVc, animated: true)
                    }
                    if let starConfigVC = self.navigationController?.viewControllers.filter({$0.isKind(of: StarConfigurationViewController.self)}).first {
                        
                        self.navigationController?.popToViewController(starConfigVC, animated: true)
                    }
                })
               
                
                
            } else if viaEmailOrPhone == Strings.viaMobile{
                //viaPhone
                let customalertView = appDelegetConstant.window.viewWithTag(35)
                customalertView?.popDownAnimation(animationDone: { (finished) in
                    if let requestStarVc = self.navigationController?.viewControllers.filter({$0.isKind(of: RequestStarProfileViewController.self)}).first as? RequestStarProfileViewController{
                        requestStarVc.requestStarProfileVmObject.phoneNumber = self.phoneNumber
                        requestStarVc.countryCodeName = self.countryCode
                        self.navigationController?.popToViewController(requestStarVc, animated: true)
                    }
                    if let starConfigVC = self.navigationController?.viewControllers.filter({$0.isKind(of: StarConfigurationViewController.self)}).first{
                        
                        self.navigationController?.popToViewController(starConfigVC, animated: true)
                    }
           
                })
            }
            return
        }
//        //For Normal User
        if viaEmailOrPhone == Strings.viaEmail{
            // viaEmail
//            let customalertView = appDelegetConstant.window.viewWithTag(20)
//            customalertView?.popDownAnimation(animationDone: { (finished) in
//                if let editProfileVC : EditProfileViewController = self.navigationController?.viewControllers.filter({$0.isKind(of: EditProfileViewController.self)}).first as? EditProfileViewController{
//                    editProfileVC.emailId = self.emailId!
//                    self.navigationController?.popToRootViewController(animated: true)
//                }
//                self.navigationController?.popViewController(animated: true)
//            })
        }
        // else if viaEmailOrPhone == Strings.viaMobile{
//            //viaEmail
//            let customalertView = appDelegetConstant.window.viewWithTag(25)
//            customalertView?.popDownAnimation(animationDone: { (finished) in
//                self.navigationController?.popViewController(animated: true)
//            })
//        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
