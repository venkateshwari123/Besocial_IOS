//
//  BusinessVerificationViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 25/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author :- Jayaram G

protocol businessEmailConfigurationDelegate {
    func resendingOtpForEmailConfig()
}
protocol businessMobileConfigDelegate {
    func resendingOtpForMobileConfig()
}
import UIKit
import Alamofire
class BusinessVerificationViewController: UIViewController, UIGestureRecognizerDelegate{
    
    //MARK:- Variables and Declarations
    @IBOutlet weak var descriptionLabel: UILabel!
    var viaEmailOrPhone:String?
    var businessVerificationOtpVmObject = BusinessOtpVerificationViewModel()
    var remainingTime:Double!
    var emailId:String?
    var phoneNumber:String?
    var countryCode:String?
    var isStarConfiguration : Bool = false
    var timer:Timer!
    var strOTP : String = ""
    var isVisibleEmail:Bool?
    var isVisibleMobileNumber:Bool?
    var isVisibleMobileNumberInt:Double?
    var isVisibleEmailInt:Double?
    var businessEmailConfigDelegate:businessEmailConfigurationDelegate?
    var businessMobileConfigDelegate:businessMobileConfigDelegate?
    var isEditingBusiess = false
    
    
    struct Constant {
        static let toUserProfileSegue = "toUserProfileSegue"
        static let totalTime = 59.0
        static let elapsingTime = 1.0
        static let alertText = "Alert!!!"
        static let okayActionText = "Okay"
        static let didntGetCode  = "Didn't get code?".localized
    }
    
    //MARK:- Outlets
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var resendOtpBtnOutlet: UIButton!
    
    
    
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
        addDoneButtonOnKeyboard()
        self.businessVerificationOtpVmObject.email = emailId
        self.businessVerificationOtpVmObject.mobileNumber = phoneNumber
        self.businessVerificationOtpVmObject.countryCode = countryCode
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        //convertFromNSAttributedStringKeyDictionary(self.otpTextField.defaultTextAttributes).updateValue(25, forKey: convertFromNSAttributedStringKey(NSAttributedString.Key.kern))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resendOtpBtnOutlet.isHidden = true
        
                        if viaEmailOrPhone == Strings.viaEmail{
                    descriptionLabel.text = "The verification code has been sent to the email address \"\(self.emailId ?? "")\" Please enter the code below."
                }else if viaEmailOrPhone == Strings.viaMobile{
                            descriptionLabel.text = "The verification code has been sent to the phone number \"\(countryCode!)\(self.phoneNumber!)\" Please enter the code below."
                }
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
    
    /// Tap gesture To Ending view editing mode by typing anywhere
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    //MARK:- UIDesign
    func uiDesign(){
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Enter Verification Code")
 
        let doneBtn = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneAction))
        doneBtn.tintColor = .label
        navigationItem.rightBarButtonItem = doneBtn
    }
    
    //MARK:-Button Actions
    
    /// Popping viewController
    ///
    /// - Parameter sender: backBtn
    @IBAction func backToUpdateVc(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// Resending Otp Again
    ///
    /// - Parameter sender: sender description
    @IBAction func resendOtpAction(_ sender: UIButton) {
        self.activateTimer()
        self.resendOtpBtnOutlet.isHidden = true
        if viaEmailOrPhone == Strings.viaEmail {
            descriptionLabel.text = "The verification code has been sent to the email address \"\(self.emailId!)\" Please enter the code below."
            businessEmailConfigDelegate?.resendingOtpForEmailConfig()
        }else if viaEmailOrPhone == Strings.viaMobile {
            descriptionLabel.text = "The verification code has been sent to the phone number \"\(self.countryCode ?? "")\(self.phoneNumber!)\" Please enter the code below."
             requestOTP()
           // resendingMobileConfigDelegate?.resendingOtpForMobileConfig()
        }
        
       
    }
    
    
    //MARK:- Service calls
    /// To Requesting Otp Again
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
                    Helper.showAlertViewOnWindow(Strings.message.localized, message: "\(Strings.verificationResentMessage.localized) \(self.countryCode!)\(self.phoneNumber!)".localized)
                    Helper.hidePI()
                }
            }, onError: {error in
                Helper.hidePI()
            })
    }
    
    
    /// Adding ToolBar On Keyboard
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
    
    /// Done Button Action On toolBar
    @objc func doneButtonAction(){
        otpTextField.resignFirstResponder()
    }
    
    @objc func doneAction(){
         verifyingOTPCall()
    }
    
    /// Verifying Otp Call after entering
    ///
    /// - Parameter sender: nextBtn
    @IBAction func nextBtnAction(_ sender: UIButton) {
       
    }
    
    
    /// To verify OTP
    func verifyingOTPCall(){
        
        if viaEmailOrPhone == Strings.viaEmail{
            let url = AppConstants.bussinessEmailOptVerify
            self.businessVerificationOtpVmObject.verifyBusinessEmailOTP(strUrl: url, isVisible: isVisibleEmail!){ (success, error) in
                if success{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshUserDetails"), object: nil)
                    let customView = CustomOtpAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                    customView.tag = 40
                    customView.delegete  = self
                    self.timerLabel.isHidden = true
                    customView.descriptionLabel.text =  Strings.updatedEmail.localized
                    customView.alertImage.image = #imageLiteral(resourceName: "message")
                    appDelegetConstant.window.addSubview(customView)
                    customView.popUpAnimation()
                }else if let error = error{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            Helper.hidePI()
        }else if viaEmailOrPhone == Strings.viaMobile{
            let url = AppConstants.bussinessPhoneOptVerify
            self.businessVerificationOtpVmObject.verifyBusinessMobileOTP(strUrl: url, isVisibleMobile: isVisibleMobileNumber!) { (success, error) in
                if success{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshUserDetails"), object: nil)
                    let customView = CustomOtpAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                    customView.alertImage.image = #imageLiteral(resourceName: "smartphone (1)")
                    customView.tag = 45
                    self.timerLabel.isHidden = true
                    customView.delegete  = self
                    customView.descriptionLabel.text = Strings.updatePhoneNumber.localized
                    appDelegetConstant.window.addSubview(customView)
                    customView.popUpAnimation()
                }else if let error = error{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                    if error.code == 138 {
                        Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterCorrectOtp.localized)
                    }
                }
            }
            Helper.hidePI()
        }
    }
}
//MARK:- Extensions

// MARK: - UITextFieldDelegate Methods
extension BusinessVerificationViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text as NSString? {
            strOTP = text.replacingCharacters(in: range, with: string)
        }
        
        self.checkAndEnableNextButton()
        
        // On inputing value to textfield
        
        self.checkAndEnableNextButton()
        if string == ""{
            return true
        }else if strOTP.count == 4{
            textField.resignFirstResponder()
           self.navigationItem.rightBarButtonItem?.isEnabled = true
            otpTextField.text = strOTP
            if viaEmailOrPhone == Strings.viaEmail{
                //                        guard let text = otpTextField.text else{ return true}
                businessVerificationOtpVmObject.emailOtp = strOTP
            } else if viaEmailOrPhone == Strings.viaMobile{
                //                        guard let text = otpTextField.text else{ return true}
                businessVerificationOtpVmObject.mobileOtp = strOTP
            }
            self.verifyingOTPCall()
        }else if (textField.text?.count)! > 4{
            return false
        }
        return true
        
    }
    
    /// Managing next Button Action
    private func checkAndEnableNextButton(){
        if (self.otpTextField.text?.count)! >= 4{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

// MARK: - Timer Extension
extension BusinessVerificationViewController {
    
    /// Activitaion timer when we enter into this ViewController
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
        //        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.gotoNext), userInfo: nil, repeats: false)
        
    }
    
    
    /// CountDown will start
    @objc func countDown(){
        if remainingTime > 0{
            remainingTime = remainingTime - Constant.elapsingTime
            //  self.resendOtpBtnOutlet.isHidden = true
         self.resendOtpBtnOutlet.isHidden = true
            self.resendOtpBtnOutlet.alpha = 0.5
            
            self.timerLabel.text = remainingTime < 10 ? String(format:"00:0%d",Int(remainingTime)) : "00:\(Int(remainingTime))"
        }else {
            timer.invalidate()
            // self.resendOtpBtnOutlet.isHidden = false
             self.resendOtpBtnOutlet.isHidden = false
            self.descriptionLabel.text = "If you have not received the verification code,please get a new one by clicking on the RESEND button."
            self.resendOtpBtnOutlet.alpha = 1.0
            self.timerLabel.text = Constant.didntGetCode
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - CustomAlertOtpViewDelegate
extension BusinessVerificationViewController: CustomAlertOtpViewDelegate{
    func okBtnClicked() {
        if viaEmailOrPhone == Strings.viaEmail{
            let customalertView = appDelegetConstant.window.viewWithTag(40)
            customalertView?.popDownAnimation(animationDone: { (finished) in
                if let businessOptionsVC = self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessEditContactOptionsViewController.self)}).first as? BusinessEditContactOptionsViewController{
                    businessOptionsVC.email = self.emailId
                    self.navigationController?.popToViewController(businessOptionsVC, animated: true)
                 }
                 if let createBusinessVc = (self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessContactInfoViewController.self)}).first as? BusinessContactInfoViewController){
                     createBusinessVc.businessEmail = self.emailId
                    createBusinessVc.businessContactInfoVmObject.isEmailVisibleInt = self.isVisibleEmailInt
                    self.navigationController?.popToViewController(createBusinessVc, animated: true)
                    return
                }
                if let businessConfigVC = self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessConfigurationViewController.self)}).first{
                    self.navigationController?.popToViewController(businessConfigVC, animated: true)
                    return
                }
            })
         } else if viaEmailOrPhone == Strings.viaMobile{
            let customalertView = appDelegetConstant.window.viewWithTag(45)
            customalertView?.popDownAnimation(animationDone: { (finished) in
                 if let businessOptionsVC = self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessEditContactOptionsViewController.self)}).first as? BusinessEditContactOptionsViewController{
                        businessOptionsVC.mobileNumber = self.phoneNumber
                        businessOptionsVC.countryCode = self.countryCode
                        self.navigationController?.popToViewController(businessOptionsVC, animated: true)
                        return
                    }
                if let createBusinessVc = (self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessContactInfoViewController.self)}).first as? BusinessContactInfoViewController){
                    createBusinessVc.businessContactInfoVmObject.phoneNumber = self.phoneNumber
                    createBusinessVc.countryCode = self.countryCode
                    createBusinessVc.businessContactInfoVmObject.isPhoneNumberVisibleInt = self.isVisibleMobileNumberInt
                    self.navigationController?.popToViewController(createBusinessVc, animated: true)
                    return
                }
                
                 if let businessConfigVC = self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessConfigurationViewController.self)}).first{
                    self.navigationController?.popToViewController(businessConfigVC, animated: true)
                    return
                }
                })
        }
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
