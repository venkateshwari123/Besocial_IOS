//
//  ResetPasswordUIE.swift
//  Shoppd
//
//  Created by Rahul Sharma on 26/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

extension ResetPasswordVC{
    func initialSetUp(){
        navigationController?.navigationBar.isHidden = true
        loginButtonView.backgroundColor = loginButtonView.setColor(colors:Colors.rgba_red)
        Fonts.setFont(loginTitle, fontFamiy: .primary(.SemiBold), size: .standard(.h12), color: .white)
        Fonts.setFont(phoneNumberPlaceholder, fontFamiy: .primary(.Medium), size: .standard(.h12), color: view.setColor(colors: Colors.rgba_dark).withAlphaComponent(0.59))
        Fonts.setFont(phoneNumberTF, fontFamiy: .primary(.Medium), size: .custom(15), color: phoneNumberTF.setColor(colors: Colors.rgba_black))
        Fonts.setFont(resetTitle, fontFamiy: .primary(.Medium), size: .custom(24), color: view.setColor(colors: Colors.rgba_dark))
        Fonts.setFont(resetTitleDescription, fontFamiy: .primary(.Regular), size: .standard(.h12), color: view.setColor(colors: Colors.rgba_dark).withAlphaComponent(0.59))
        Fonts.setFont(countryCode, fontFamiy: .primary(.Medium), size: .custom(15), color: view.setColor(colors: Colors.rgba_dark))
        Fonts.setFont(emailTF, fontFamiy: .primary(.Medium), size: .custom(15), color: emailTF.setColor(colors: Colors.rgba_black))
//        emailTF.placeholderColor = emailTF.setColor(colors: Colors.rgba_dark).withAlphaComponent(0.59)
        Fonts.setFont(newPasswordTF, fontFamiy: .primary(.Medium), size: .custom(15), color: newPasswordTF.setColor(colors: Colors.rgba_black))
//        newPasswordTF.placeholderColor = newPasswordTF.setColor(colors: Colors.rgba_dark).withAlphaComponent(0.59)
        Fonts.setFont(repeatNewPasswordTF, fontFamiy: .primary(.Medium), size: .custom(15), color: repeatNewPasswordTF.setColor(colors: Colors.rgba_black))
//        repeatNewPasswordTF.placeholderColor = repeatNewPasswordTF.setColor(colors: Colors.rgba_dark).withAlphaComponent(0.59)
        newPasswordTF.delegate = self
        repeatNewPasswordTF.delegate = self
        invalidMessage.isHidden = true
        phoneNumberTF.addAccessoryView()
        emailTF.addAccessoryView()
        newPasswordTF.addAccessoryView()
        repeatNewPasswordTF.addAccessoryView()
        Fonts.setFont(invalidMessage, fontFamiy: .primary(.Regular), size: .standard(.h12), color: view.setColor(colors: Colors.rgba_red))
    }
    
    func handleSuccessResponse( otpId:String? = nil){
        switch resetType{
        case .Email(let type):
            if type == .setPassword {
                addSuccessView()
            }else{
                emailSentPrompt = UINib(nibName: "EmailSentPrompt", bundle: .main).instantiate(withOwner: nil, options: nil).first as? EmailSentPrompt ?? EmailSentPrompt()
                emailSentPrompt?.okButonPressed = closeEmailPrompt
                emailSentPrompt?.mailId.text = emailTF.text!
                emailSentPrompt?.frame = view.bounds
                view.addSubview(emailSentPrompt!)
            }
        case .Phone(let type):
            if type == .loginPassword{
                let vc = VerificationVC.instantiate(storyBoardName: "Authentication") as VerificationVC
                vc.verificationData = VerificationData(countryCode: countryCode.text!, phoneNumber: phoneNumberTF.text!, otpId: otpId!)
                vc.verificationType = .resetPassword
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                addSuccessView()
            }
        }
    }
    
    func countryPickerAction(){
        phoneNumberTF.clear()
        phoneNumberBoarderView.backgroundColor = phoneNumberBoarderView.setColor(colors: Colors.rgba_lightGray17)
        isEnableButton = false
    }
    
    func addSuccessView(){
        successResetPassword = UINib(nibName: "SuccessResetPassword", bundle: .main).instantiate(withOwner: nil, options: nil).first as? SuccessResetPassword ?? SuccessResetPassword()
        successResetPassword?.gotoHomeAction = gotToHomeAction
        successResetPassword?.frame = view.bounds
        view.addSubview(successResetPassword!)
    }
    
    func gotToHomeAction(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    func handleErrorResponse(){
        switch resetType {
        case .Email:
            invalidMessage.text = "Entered".localized + " " + "email address".localized + " " + "is not".localized + " " + "registered on".localized + " " + "\(AppConstants.AppName)" + "."
        case .Phone(let type):
            if type == .loginPassword{
                invalidMessage.text =  "Entered".localized + " " + "phone number".localized + " " + "is not".localized + " " + "registered on".localized + " " + "\(AppConstants.AppName)" + "."
            }else{
                invalidMessage.text = "invalid".localized + " " + "password".localized
            }
            
        }
        self.invalidMessage.isHidden = false
    }
    
    func addTextFieldAction(){
        emailTF.addTarget(self, action: #selector(textfieldChanged(_:)), for: .editingChanged)
        phoneNumberTF.addTarget(self, action: #selector(textfieldChanged(_:)), for: .editingChanged)
        newPasswordTF.addTarget(self, action: #selector(textfieldChanged(_:)), for: .editingChanged)
        repeatNewPasswordTF.addTarget(self, action: #selector(textfieldChanged(_:)), for: .editingChanged)
    }
    
    func configureVC(){
        switch resetType {
        case .Email(let type):
            let condition = type == .setPassword
            resetTitle.text = "Reset Password".localized
            loginTitle.text = !condition ? "Send Code".localized : "Reset".localized + " " + "&" + "Login".localized
            resetTitleDescription.text = "Enter the email address you registered with and we shall send you the  instructions to reset your password".localized + "."
            emailStackView.isHidden = condition
            phoneNumberStackView.isHidden = true
            resetPasswordStackView.isHidden = !condition
            countryPickerButton.isHidden = true
        case .Phone(let type):
            let condition = type == .loginPassword
            resetTitle.text = condition ? "Reset Password".localized : "Enter New Password".localized
            resetTitleDescription.text = condition ? "Enter the phone number you registered with and we shall send you a verification code to reset your password".localized + "." : "Set new password for your account".localized + "." + "The password you will set will be changed for your account".localized + "."
            loginTitle.text = condition ? "Send Code".localized : "Reset".localized + " " + "&" + "Login".localized
            emailStackView.isHidden = true
            phoneNumberStackView.isHidden = !condition
            userIdStackView.isHidden = !condition
            resetPasswordStackView.isHidden = condition
            countryPickerButton.isHidden = !condition
        }
    }
    
    override func keyboardDidShow(_ notification: Notification) {
        guard let keyboardFrame = notification.keyboardFrame else{return}
        let remainingHeight = view.frame.height - keyboardFrame.height
        let viewPosition = loginButtonView.frame.origin.y + loginButtonView.frame.height + 25
        if remainingHeight < viewPosition{
            UIView.animate(withDuration: 0.25) {
                self.mainScrollView.setContentOffset(CGPoint(x: 0, y: viewPosition - remainingHeight), animated: true)
            }
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        //print("Keyboard Hode")
        UIView.animate(withDuration: 0.25) {
            self.mainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
    }
    
}

extension ResetPasswordVC:CountryDataDelegate{
    
    func countryData(countryName: String, phoneCode: String, countryCode: String, countryFlag: UIImage) {
        self.countryCode.text = phoneCode
        self.countryFlag.image = countryFlag
        currentCountryCode = phoneCode
        self.countryName = countryCode
    }
}
