//
//  EditNumberVarificationViewController.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 27/02/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
protocol EditNumberVarificationViewControllerDelegate: class {
    func isNumberChanged()
}
class EditNumberVarificationViewController: UIViewController {
    
    /// Outlets
    @IBOutlet weak var varificationMsgLabel: UILabel!
    @IBOutlet weak var varificationTextField: UITextField!
    @IBOutlet weak var countDownButton: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var proceedButtonOutlet: UIButton!
    
    
    /// Variables and declarations
    var phoneNumber: String?
    var countryCode: String?
    var timer:Timer!
    var remainingTime:Double!
    var delegate: EditNumberVarificationViewControllerDelegate?
    
    struct Constant {
        static let totalTime = 59.0
        static let elapsingTime = 1.0
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.varificationMsgLabel.text = "Enter 4 digit varification code we sent to \(countryCode!)\(phoneNumber!)"
       // convertFromNSAttributedStringKeyDictionary(self.varificationTextField.defaultTextAttributes).updateValue(35, forKey: convertFromNSAttributedStringKey(NSAttributedString.Key.kern))
        self.varificationTextField.text = ""
        self.proceedButtonOutlet.isEnabled = false
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.activateTimer()
        self.varificationTextField.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// To activate time for 30 seconds and then after only user can request for new verification code
    func activateTimer(){
        remainingTime = Constant.totalTime
        if (timer != nil)
        {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: Constant.elapsingTime, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
    }
    
    
    /// To set value in timer button and enable or disable button
    @objc func countDown(){
        if remainingTime > 0{
            remainingTime = remainingTime - Constant.elapsingTime
            self.countDownButton.isEnabled = false
            self.countDownLabel.text = "00 : \(Int(remainingTime))"
        }
        else {
            timer.invalidate()
            self.countDownLabel.text = Strings.ididntGetCode.localized
            self.countDownButton.isEnabled = true
        }
    }
    
    /// To manage view height according to keyboard height
    ///
    /// - Parameter notification: keyboard notification object
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                let frame = self.view.frame
                let height = UIScreen.main.bounds.height - keyboardHeight
                self.view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height)
            }, completion: nil)
            view.layoutIfNeeded()
        }
    }
    
    //MARK:- Buttons Action
    
    @IBAction func proceedAction(_ sender: Any) {
        self.verifyOtpAPI()
    }
    
    
    @IBAction func countDownButtonAction(_ sender: Any) {
        //        if self.isResendEnable{
        self.requestOTP()
        //        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    //MARK:- Service call
    func verifyOtpAPI() {
        Helper.showPI(_message: Strings.verifying.localized)
        let strURL =  AppConstants.verifyChangeNumber
        guard let number = self.phoneNumber else { return }
        guard let countryCode = self.countryCode else { return }
        
        let params = [Strings.newNumberWithOutCountryCode:number,
                      Strings.countryCode:countryCode,
                      Strings.otpKey: self.varificationTextField.text! as Any,
                      ] as [String:Any]
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
        
        let headers = [Strings.authorizationKey:token,
                       Strings.langKey:Utility.getSelectedLanguegeCode()] as [String: String]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.verifyChangeNumber.rawValue)
        
        apiCall.subject_response
            .subscribe(onNext: {response in
                guard let responseKey = response[AppConstants.resposeTypeKey] as? String else {return}
                Helper.hidePI()
                if responseKey == AppConstants.resposeType.verifyChangeNumber.rawValue {
                    Helper.hidePI()
                    
                    let userDefault = UserDefaults.standard
                    if let number = self.phoneNumber{
                        //     let numberWithCode = "\(code)\(number)"
                        UserDefaults.standard.set(number, forKey: AppConstants.UserDefaults.userNumber)
                    }                    
                    userDefault.synchronize()
                    self.showPopAndGoBack()
                }
            }, onError : {error in
                //                DDLogDebug("\(error.localizedDescription)")
                Helper.hidePI()
                if error._code == 412{
                    self.showErrorPopUpandGoBack()
                }
                self.varificationTextField.text = ""
            })
    }
    
    func showErrorPopUpandGoBack(){
        let alertController = UIAlertController(title: Strings.message.localized, message:Strings.thisNumberTakenByAnotherUser.localized, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: Strings.ok.localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showPopAndGoBack(){
        let alertController = UIAlertController(title: Strings.numberChanged.localized, message:Strings.yourMobileNumberChangedSuccessFully.localized, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: Strings.ok.localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            self.delegate?.isNumberChanged()
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func requestOTP() {
        Helper.showPI(_message: Strings.sending.localized)
        let strURL = AppConstants.requestChangeNumber
        guard let number = self.phoneNumber else { return }
        guard let countryCode = self.countryCode else { return }
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        let deviceName = UIDevice.current.name
        let deviceOS = UIDevice.current.systemVersion
        let deviceModel = UIDevice.modelName
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let params = [Strings.newNumberWithOutCountryCode :number,
                      Strings.countryCode:countryCode,
                      Strings.deviceIdKey:deviceID,
                      Strings.deviceNameKey:deviceName,
                      Strings.deviceOsKey:deviceOS,
                      Strings.modelNumberKey:deviceModel,
                      Strings.deviceTypeKey:"1",
                      Strings.appVersionKey:appVersion as Any] as [String:Any]
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
        
        let headers = [Strings.authorizationKey:token,
                       Strings.langKey:Utility.getSelectedLanguegeCode()] as [String: String]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.requestOtp.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.requestOtp.rawValue {
                    Helper.showAlertViewOnWindow(Strings.message.localized, message: "The verification code has been resent to".localized + " \(countryCode)\(number)")
                    Helper.hidePI()
                    self.activateTimer()
                }
            }, onError: {error in
                Helper.hidePI()
            })
    }
}

// MARK: - UITextFieldDelegate
extension EditNumberVarificationViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 3 && string.count == 1{
            self.proceedButtonOutlet.isEnabled = true
        }
        else if textField.text?.count == 4 && string != ""{
            return false
        }else{
            self.proceedButtonOutlet.isEnabled = false
        }
        return true
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
