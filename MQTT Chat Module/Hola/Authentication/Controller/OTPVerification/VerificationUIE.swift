//
//  VerificationUIE.swift
//  Shoppd
//
//  Created by Rahul Sharma on 27/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

extension VerificationVC{
    
    func initialSetUp(){
        
        codeView1.layer.cornerRadius = 16
        codeView2.layer.cornerRadius = 16
        codeView3.layer.cornerRadius = 16
        codeView4.layer.cornerRadius = 16
        
        popView.layer.cornerRadius = 30
        
        loginButtonView.layer.cornerRadius = 16
        loginButtonView.clipsToBounds = true
        
        codeView1.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.9098039216, blue: 0.9568627451, alpha: 1)
        codeView2.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.9098039216, blue: 0.9568627451, alpha: 1)
        codeView3.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.9098039216, blue: 0.9568627451, alpha: 1)
        codeView4.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.9098039216, blue: 0.9568627451, alpha: 1)
       
        otpTF1.backgroundColor = .clear
        otpTF2.backgroundColor = .clear
        otpTF3.backgroundColor = .clear
        otpTF4.backgroundColor = .clear
        
        /*
            Bug Name:- autofill otp not work properly
            Fix Date:- 11th Jan 2021
            Fixed By:- Nikunj C
            Description of Fix:- add required action
         */
        otpTF1.textContentType = .oneTimeCode
        otpTF2.textContentType = .oneTimeCode
        otpTF3.textContentType = .oneTimeCode
        otpTF4.textContentType = .oneTimeCode
        otpTF1.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        otpTF2.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        otpTF3.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        otpTF4.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        /*
         Feat Name:- hardcode 1111 for otp
         Feat Date:- 23/04/21
         Feat   By:- Nikunj C
         Description of Feat:- hardcord 1111
         */

//        otpTF1.text = ""
//        otpTF2.text = ""
//        otpTF3.text = ""
//        otpTF4.text = ""
        self.isEnableButton = true
        Fonts.setFont(loginViewTitle, fontFamiy: .primary(.SemiBold), size: .standard(.h12), color: .white)
        Fonts.setFont(otpTF1, fontFamiy: .ternary(.Bold), size: .custom(20), color: #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        Fonts.setFont(otpTF2, fontFamiy: .ternary(.Bold), size: .custom(20), color: #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        Fonts.setFont(otpTF3, fontFamiy: .ternary(.Bold), size: .custom(20), color: #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        Fonts.setFont(otpTF4, fontFamiy: .ternary(.Bold), size: .custom(20), color: #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        
        Fonts.setFont(numberLabel, fontFamiy: .ternary(.Bold), size: .custom(14), color: UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor))
        
        if #available(iOS 13.0, *) {
            Fonts.setFont(otpMessage, fontFamiy: .primary(.Regular), size: .custom(13), color: .label)
        } else {
            Fonts.setFont(otpMessage, fontFamiy: .primary(.Regular), size: .custom(13), color: UIColor.Light.black)
        }
        Fonts.setFont(resendText, fontFamiy: .ternary(.Regular), size: .custom(13), color: UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor))
        Fonts.setFont(titleDescription, fontFamiy: .ternary(.Regular), size: .custom(14), color: #colorLiteral(red: 0.6039215686, green: 0.6431372549, blue: 0.7058823529, alpha: 1))
        Fonts.setFont(titleLabel, fontFamiy: .ternary(.Bold), size: .custom(18), color: UIColor.setColor(lightMode: AppColourStr.picoaddaHeadingLabel, darkMode: AppColourStr.whiteColor))
        Fonts.setFont(invalidMessage, fontFamiy: .primary(.Regular), size: .standard(.h12), color: UIColor.Light.red)
        navigationController?.navigationBar.isHidden = true
        continueButton.setTitle("Verify".localized, for: .normal)
        resendText.text = "Resend".localized
        otpTF4.addAccessoryView()
        otpTF1.delegate = self
        otpTF2.delegate = self
        otpTF3.delegate = self
        otpTF4.delegate = self
        otpTF1.addTarget(self, action: #selector(checkOtpText(_:)), for: .editingChanged)
        otpTF2.addTarget(self, action: #selector(checkOtpText(_:)), for: .editingChanged)
        otpTF3.addTarget(self, action: #selector(checkOtpText(_:)), for: .editingChanged)
        otpTF4.addTarget(self, action: #selector(checkOtpText(_:)), for: .editingChanged)
        
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
   
   @objc func updateTime() {
    resendButton.isEnabled = false
    let seconds: Int = totalSeconds % 60
    let minutes: Int = (totalSeconds / 60) % 60
    resendText.text = String(format: "%02d:%02d", minutes, seconds)
        if totalSeconds != 0 {
            totalSeconds -= 1
        } else {
            endTimer()
            resendText.text = "Resend".localized
            resendButton.isEnabled = true
        }
    }
    
    func endTimer() {
        timer.invalidate()
    }
    
    func configureViews(){
        titleLabel.text = "Enter".localized + " " + "Verification code".localized
        titleDescription.text = "Verification code".localized + " " + "has been send to".localized
        otpMessage.text = "Didn't get code".localized + "?"
        switch verificationType {
        case .resetPassword:
            numberLabel.text = self.emailId
        default:
            guard let number = self.phoneNumber else { return }
            guard let countryCode = self.counrtyCode else { return }
            numberLabel.text = countryCode + number
        }
        
    }
    
    func handleSuccessResponse(token : String? = nil){
        switch verificationType {
        case .signUp:
//            if resetResponse{
//                verificationData?.otpId = loginVM.tokenID!
//            }else{
//                loginVM.signUpAPI(name: signUpData!.name, email: signUpData!.email, phoneNumber: verificationData!.phoneNumber, countryCode: verificationData!.countryCode, password: signUpData!.password, terms: signUpData!.terms, loginType: .Email(.normal),lastName: signUpData!.lastName)
//            }
        break
        case .login:
//            if resetResponse{
//                verificationData?.otpId = loginVM.tokenID!
//            }else{
//             navigationController?.dismiss(animated: true, completion: nil)
//            }
        break
        case .resetPassword:
//            if resetResponse{
//                verificationData?.otpId = loginVM.tokenID!
//            }else{
            /*
            Bug Name : Update forgot password flow
            Fix Date : 14-May-2021
            Fixed By : Jayaram G
            Description Of Fix : Changed navigations to new screen
          */
                let vc = NewResetPasswordVC.instantiate(storyBoardName: "Authentication") as NewResetPasswordVC
//                vc.tokenID = token ?? ""
            vc.emailId = self.emailId
//            vc.resetType = .Email(.setPassword)
                self.navigationController?.pushViewController(vc, animated: false)
//            }
        case .changePassword:
//            if resetResponse{
//                verificationData?.otpId = loginVM.tokenID!
//            }else{
//                changePassword?()
//                navigationController?.dismiss(animated: false, completion: nil)
//            }
            break
        default:
            break
        }
    }
    
    func handleErrorResponse(errorCode:APICalls.ErrorCode){
        otpTF1.clear()
        otpTF2.clear()
        otpTF3.clear()
        otpTF4.clear()
        if errorCode == .ExpiredOtp{
            invalidMessage.text = "invalid".localized + " " + "OTP".localized
            invalidMessage.isHidden = false
        }else if errorCode == .MethodNotAllowed{
            invalidMessage.text = "OTP".localized + " " + "expired".localized
            invalidMessage.isHidden = false
        }else{
            Helper.showAlert(message: "Internal Server Error".localized, head: "Verification".localized, type: errorCode.rawValue)
        }
        otpTF1.becomeFirstResponder()
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

extension VerificationVC:UITextFieldDelegate{
    
    /*
        Bug Name:- autofill otp not work properly
        Fix Date:- 11th Jan 2021
        Fixed By:- Nikunj C
        Description of Fix:- add required action
     */
    
    @objc func textFieldDidChange(_ textField: UITextField) {
            
        
        let text = textField.text
        if let otpCode = textField.text, otpCode.count > 3 {
            otpTF1.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 0)])
            otpTF2.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 1)])
            otpTF3.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 2)])
            otpTF4.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 3)])
        }
        
        if  text?.count == 1 {
            
            if textField.isEqual(otpTF1) {
                self.perform(#selector(self.setNextResponder(nextResponder:)), with: otpTF2, afterDelay: 0)
            }
            else if textField.isEqual(otpTF2) {
                self.perform(#selector(self.setNextResponder(nextResponder:)), with:otpTF3, afterDelay: 0)
            }
            else if textField.isEqual(otpTF3) {
                self.perform(#selector(self.setNextResponder(nextResponder:)), with: otpTF4, afterDelay: 0)
            }
        }
        if  text?.count == 0 {
            if textField.isEqual(otpTF4) {
                self.perform(#selector(self.setNextResponder(nextResponder:)), with: otpTF3, afterDelay: 0)
            }
            else if textField.isEqual(otpTF3) {
                self.perform(#selector(self.setNextResponder(nextResponder:)), with: otpTF2, afterDelay: 0)
            }
            else if textField.isEqual(otpTF2) {
                self.perform(#selector(self.setNextResponder(nextResponder:)), with:otpTF1, afterDelay: 0)
            }
        }
        
      }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        invalidMessage.isHidden = true
//        oldLength = textField.text!.sorted().count
//        replacementLength = string.sorted().count
//        let rangeLength = range.length
//        let newLength = oldLength - rangeLength + replacementLength
//
//        // This 'tabs' to next field when entering digits
//        if (newLength == 1)||(replacementLength == 1) {
//            str = string
////            checkOtpText()
//
//            if textField.isEqual(otpTF1) {
//                self.perform(#selector(self.setNextResponder(nextResponder:)), with: otpTF2, afterDelay: 0)
//            }
//            else if textField.isEqual(otpTF2) {
//                self.perform(#selector(self.setNextResponder(nextResponder:)), with:otpTF3, afterDelay: 0)
//            }
//            else if textField.isEqual(otpTF3) {
//                self.perform(#selector(self.setNextResponder(nextResponder:)), with: otpTF4, afterDelay: 0)
//            }
//        }
//            //this goes to previous field as you backspace through them, so you don't have to tap into them individually
//        else if (oldLength > 0 && newLength == 0)||(replacementLength == 0) {
//            str = ""
////            checkOtpText()
//            if textField.isEqual(otpTF4) {
//                self.perform(#selector(self.setNextResponder(nextResponder:)), with: otpTF3, afterDelay: 0)
//            }
//            else if textField.isEqual(otpTF3) {
//                self.perform(#selector(self.setNextResponder(nextResponder:)), with: otpTF2, afterDelay: 0)
//            }
//            else if textField.isEqual(otpTF2) {
//                self.perform(#selector(self.setNextResponder(nextResponder:)), with:otpTF1, afterDelay: 0)
//            }
//        }
//
//        return newLength <= 1
//    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        checkOtpText(textField)
//        return true
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        checkOtpText()
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
//        checkOtpText()
//    }
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        checkOtpText()
//        return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == otpTF4{
//            verifyOtpAPI()
//        }
        return true
    }
    
    @objc func setNextResponder(nextResponder: UITextField) {
        nextResponder.becomeFirstResponder()
        if oldLength == 1 && replacementLength != 0 {
            nextResponder.text = str
        }
        switch nextResponder {
        case otpTF1:
            break
        case otpTF2:
            break
        case otpTF3:
            break
        case otpTF4:
            break
        default:
            break
        }
        
    }
    
     @objc func checkOtpText(_ textField: UITextField){
        if let otp1 = otpTF1.text, let otp2 = otpTF2.text, let otp3 = otpTF3.text, let otp4 = otpTF4.text,!otp1.isEmpty,!otp2.isEmpty,!otp3.isEmpty,!otp4.isEmpty{
            self.isEnableButton = true
            guard otp1.count == 1,otp2.count == 1,otp3.count == 1,otp4.count == 1 else{return}
            verifyOtpAPI()
        }else{
            self.isEnableButton = false
        }
    }
    
}
