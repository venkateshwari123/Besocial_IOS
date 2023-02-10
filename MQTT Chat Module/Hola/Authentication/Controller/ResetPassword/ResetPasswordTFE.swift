//
//  ResetPasswordTF.swift
//  Shoppd
//
//  Created by Rahul Sharma on 03/10/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

extension ResetPasswordVC:UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == newPasswordTF{
            repeatNewPasswordTF.becomeFirstResponder()
        }
    }
    
    @objc func textfieldChanged(_ textfield:UITextField){
        invalidMessage.isHidden = true
        switch textfield {
        case emailTF:
            if let email = emailTF.text,Helper.isValidEmail(emailText: email){
                isEnableButton = true
            }else{
                isEnableButton = false
            }
            if emailTF.text!.isEmpty{
                emailBoarderView.backgroundColor = emailBoarderView.setColor(colors: Colors.rgba_lightGray17)
            }
        case phoneNumberTF:
            if let phoneNumber = phoneNumberTF.text,Helper.isPhoneNumValid(phoneNumber: phoneNumber, code: countryName){
                isEnableButton = true
            }else{
                isEnableButton = false
            }
            if phoneNumberTF.text!.isEmpty{
                phoneNumberBoarderView.backgroundColor = phoneNumberBoarderView.setColor(colors: Colors.rgba_lightGray17)
            }
        case repeatNewPasswordTF:
            if let password = newPasswordTF.text, password.length > 7,let confirmPassword = repeatNewPasswordTF.text, password.length == confirmPassword.length {
                isEnableButton = true
            }else{
                isEnableButton = false
            }
            if let password = newPasswordTF.text,let confirmPassword = repeatNewPasswordTF.text,password.length == confirmPassword.length,password != confirmPassword{
                invalidMessage.text = "both passwords don't match"
            }

        default:
            break
        }
//
    }
    
}
