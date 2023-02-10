//
//  RegistrationTFE.swift
//  Shoppd
//
//  Created by Rahul Sharma on 30/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

extension RegistrationVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextResponder = view.viewWithTag(textField.tag + 1) as? UITextField{
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    /*
     Bug Name:- username should restrict to 15 characters only
     Fix Date:- 09/04/21
     Fixed By:- Nikunj C
     Description of Fix- add condition whcih restrict character more than 15
     */
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == userNameTF {
            
            var cs = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_.").inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if string == filtered {
                textField.tintColor = UIColor.blue
            } else {
                textField.tintColor = UIColor.red
            }
            let currentCharacterCount = textField.text?.count ?? 0
                if range.length + range.location > currentCharacterCount {
                    return false
                }
            let newLength = currentCharacterCount + string.count - range.length
            return (string == filtered) && newLength <= 15
        }else if textField == firstNameTF || textField == lastNameTF{
            var cs = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if string == filtered {
                textField.tintColor = UIColor.blue
            } else {
                textField.tintColor = UIColor.red
            }
            let currentCharacterCount = textField.text?.count ?? 0
                if range.length + range.location > currentCharacterCount {
                    return false
                }
            let newLength = currentCharacterCount + string.count - range.length
            return (string == filtered) && newLength <= 15
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        
        /*
         Bug Name:- validation not work properly
         Fix Date:- 03/04/21
         Fixed By:- Nikunj C
         Description of Fix:- add required logic for validation
         */
        
        
        /*
         Refactor Name:- remove firstname and lastname validation from signup screen
         Refactor Date:- 03/04/21
         Refactor By:- Nikunj C
         Description of Refactor:- refactor firstname and lastname validation
         */
        case  firstNameTF:
            firstNameErrorLabel.isHidden = true
            guard let name  = firstNameTF.text, !name.isEmpty  else {
                firstNameErrorLabel.isHidden = false
                firstNameErrorLabel.text = "Enter First Name"
                return}
            self.validateSignUpFields()
        
            
        case  lastNameTF:
            lastNameErrorLabel.isHidden = true
            guard let name  = lastNameTF.text,!name.isEmpty else {
//                lastNameErrorLabel.isHidden = false
//                lastNameErrorLabel.text = "Enter Last Name"
                return}
            self.validateSignUpFields()
            
            
        case userNameTF:
            guard let username = userNameTF.text,!username.isEmpty else{
                self.usernameInvalid.isHidden = true
                self.checkUsernameImageView.isHidden = true
                self.isValidUsername = false
                return}
            if !(username.count > 3) {
                self.isValidUsername = false
                self.checkUsernameImageView.isHidden = false
                self.usernameInvalid.text = "Username must be more than 3 characters."
                self.usernameInvalid.isHidden = false
                self.validateSignUpFields()
                return
                }
            else if (username.count > 14){
                self.isValidUsername = false
                self.checkUsernameImageView.isHidden = false
                self.usernameInvalid.text = "Username must be less than 15 characters."
                self.usernameInvalid.isHidden = false
                self.validateSignUpFields()
                return
            }
            self.checkUsernameImageView.isHidden = false
            loginViewModel.validateRegisteration(type:.username,userName: username) {(isSucces, erorr,errorCode) in
                if !isSucces{
                    self.usernameInvalid.isHidden = true
                    self.isValidUsername = true
                    //                    self.userNameBoarder.backgroundColor = self.userNameBoarder.setColor(colors: Colors.rgba_Green)
//
                    switch self.loginType {
                    case .Email:
                        self.phoneNumberTF.becomeFirstResponder()
                    default:
                         self.emailTF.becomeFirstResponder()
                    }
                }
                else{
                    self.isValidUsername = false
                    //                    self.userNameBoarder.backgroundColor = self.userNameBoarder.setColor(colors: Colors.rgba_red)
                    self.usernameInvalid.text = "Entered username already exists."
                    self.usernameInvalid.isHidden = false
                    self.userNameTF.resignFirstResponder()
                }
                self.validateSignUpFields()
                //               self.validUsernameView.isHidden = false
            }
        case emailTF:
                    var email1 = ""
            
            switch loginType {
            case .Email:
                email1 = self.emailId!
                
            default:
                email1 =  emailTF.text!
                
            }
            
            /*
             Bug Name:- email validation not work properly
             Fix date:- 03/04/21
             Fixed By:- Nikunj C
             Description of Fix:- for invalid email put isvalidEmail value false
             */
            guard !(email1.isEmpty) else{
                self.emailinvalid.isHidden = true
                self.checkemailImageView.isHidden = true
                self.isValidEmail = false
                return}
            guard Helper.isValidEmail(emailText: email1) else {
                self.emailinvalid.text = "Entered email address is invalid."
                self.emailinvalid.isHidden = false
                self.checkemailImageView.isHidden = false
                self.isValidEmail = false
                return }
            self.checkemailImageView.isHidden = false
            loginViewModel.validateRegisteration(type:.email, emailAddress:email1) {(isSucces, erorr,errorCode) in
                if !isSucces{
                    self.isValidEmail = true
                    //                    self.emailBoarder.backgroundColor = self.emailBoarder.setColor(colors: Colors.rgba_Green)
                    //                    self.phoneNumberTF.becomeFirstResponder()
                    self.emailinvalid.isHidden = true
                }
                else{
                    self.isValidEmail = false
                    //                    self?.emailTF.textColor = self?.emailTF.setColor(colors: Colors.rgba_red)
                    //                    self.emailBoarder.backgroundColor = self.emailBoarder.setColor(colors: Colors.rgba_red)
                    self.emailinvalid.text = "Entered email address is already registered."
                    self.emailinvalid.isHidden = false
                    self.passwordTF.resignFirstResponder()
                }
                self.validateSignUpFields()
                //               self.validEmailView.isHidden = false
            }
        case phoneNumberTF:
            
            var mobile = ""
            switch loginType {
            case .Email:
                mobile = self.phoneNumberTF.text!
            default:
                mobile = self.mobileNumber
            }
           
//            guard Helper.isPhoneNumValid(phoneNumber: mobile, code: countryName) else{return}
            
             /*
              Bug Name:- phone number validation not work when login with email
              Fix Date:- 09/04/21
              Fix By  :- Nikunj C
              Description of Fix:- put phone number validation
              */
             
            guard  Helper.isValidNumber("\(strCountryCode)" + (mobile)) else {
                self.isValidPhoneNumber = false
                self.validateSignUpFields()
                return }
            loginViewModel.validateRegisteration( type: .phonenumber, number:mobile,dialCode:strCountryCode) { (isSucces, erorr,errorCode) in
                if !isSucces{
                    self.isValidPhoneNumber = true
                    self.phoneNumberinvalid.isHidden = true
                    //                    self.phoneNumberBoarder.backgroundColor = self.phoneNumberBoarder.setColor(colors: Colors.rgba_Green)
                    self.passwordTF.becomeFirstResponder()
                }
                else{
                    self.isValidPhoneNumber = false
                    //                                        self.phoneNumberBoarder.backgroundColor = self.phoneNumberBoarder.setColor(colors: Colors.rgba_red)
                    self.phoneNumberinvalid.text = "Entered phone number is already registered."
                    self.phoneNumberinvalid.isHidden = false
                    self.passwordTF.resignFirstResponder()
                }
                self.validateSignUpFields()
                //                self.validPhoneView.isHidden = false
            }
        case passwordTF:
            passwordErrorLabel.isHidden = true
            guard let name  = passwordTF.text, !name.isEmpty  else {return}
            if !(name.count > 7) {
                self.passwordErrorLabel.text = "Password must be more than 7 characters."
                passwordErrorLabel.isHidden = false
                return
            }
            else{
                passwordErrorLabel.isHidden = true
            }
        default:
            if let nextResponder = view.viewWithTag(textField.tag + 1) as? UITextField{
                nextResponder.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField){
        
     
//
//        invalidMessage.isHidden = true
//        switch textfield{
//        case emailTF:
////
//
//            if let email = emailTF.text,Helper.isValidEmail(emailText: email),!email.isEmpty{
//
//            }else{
//                emailBoarder.backgroundColor = emailBoarder.setColor(colors: (emailTF.text ?? "").isEmpty ? Colors.rgba_lightGray17 : Colors.rgba_red)
//            }
//            emailinvalid.isHidden = true
//        case firstNameTF:
//            if let userName = userNameTF.text,Helper.isValidName(textName: userName),!userName.isEmpty,userName.length > 3{
//                userNameBoarder.backgroundColor = userNameBoarder.setColor(colors: Colors.rgba_Green)
//            }else{
//                userNameBoarder.backgroundColor = userNameBoarder.setColor(colors: (userNameTF.text ?? "").isEmpty ? Colors.rgba_lightGray17 : Colors.rgba_red)
//            }
//        case userNameTF:
//            self.validUsernameView.isHidden = true
//            if let user = userNameTF.text,!user.isEmpty{
//                userNameBoarder.backgroundColor = userNameBoarder.setColor(colors: Colors.rgba_Green)
//            }else{
//                userNameBoarder.backgroundColor = userNameBoarder.setColor(colors: (emailTF.text ?? "").isEmpty ? Colors.rgba_lightGray17 : Colors.rgba_red)
//            }
//            usernameInvalid.isHidden = true
//            break
//        case lastNameTF:
//            if let lastName = lastNameTF.text,Helper.isValidName(textName: lastName),!lastName.isEmpty{
//                lastNameBoarder.backgroundColor = userNameBoarder.setColor(colors: Colors.rgba_Green)
//            }else{
//                lastNameBoarder.backgroundColor = lastNameBoarder.setColor(colors: (lastNameTF.text ?? "").isEmpty ? Colors.rgba_lightGray17 : Colors.rgba_red)
//            }
//
//        case phoneNumberTF:
////            phoneNumberTF.textColor = phoneNumberTF.setColor(colors: Colors.rgba_black)
//            self.validPhoneView.isHidden = true
//            if let phoneNumber = phoneNumberTF.text,Helper.isPhoneNumValid(phoneNumber: phoneNumber, code: countryName),!phoneNumber.isEmpty{
//                phoneNumberBoarder.backgroundColor = phoneNumberBoarder.setColor(colors: Colors.rgba_Green)
//            }else{
//                isValidPhoneNumber = false
//                phoneNumberBoarder.backgroundColor = phoneNumberBoarder.setColor(colors: (phoneNumberTF.text ?? "").isEmpty ? Colors.rgba_lightGray17 : Colors.rgba_red)
//            }
//            phoneNumberinvalid.isHidden = true
//        case passwordTF:
//            if let password = passwordTF.text,!password.isEmpty,password.length > 5{
//                passwordBoarder.backgroundColor = passwordBoarder.setColor(colors: Colors.rgba_Green)
//            }else{
//                passwordBoarder.backgroundColor = passwordBoarder.setColor(colors: (passwordTF.text ?? "").isEmpty ? Colors.rgba_lightGray17 : Colors.rgba_red)
//            }
//        case confirmPasswordTF:
//            invalidMessage.isHidden = true
//            if let confirmPassword = confirmPasswordTF.text,!confirmPassword.isEmpty,confirmPassword.length == passwordTF.text?.length{
//                if confirmPassword == passwordTF.text{
//                    confirmPasswordBoarder.backgroundColor = confirmPasswordBoarder.setColor(colors: Colors.rgba_Green)
//                }else{
//                    confirmPasswordBoarder.backgroundColor = confirmPasswordBoarder.setColor(colors: Colors.rgba_red)
//                    invalidMessage.text = "both passwords doesn't match"
//                    invalidMessage.isHidden = false
//                }
//
//            }else{
//                confirmPasswordBoarder.backgroundColor = confirmPasswordBoarder.setColor(colors: (confirmPasswordTF.text ?? "").isEmpty ? Colors.rgba_lightGray17 : Colors.rgba_red)
//            }
//        default:
//            break
//        }
        validateSignUpFields()
    }
//
}

extension RegistrationVC: UITextViewDelegate {
    private func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if (URL.absoluteString == AppConstants.termsConditionUrl) {
       if  let webView =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DocumentViewerViewController") as? DocumentViewerViewController{
                  webView.isComingfromSetting = true
                  webView.webURL = AppConstants.termsConditionUrl
                  webView.titleName = "Terms of Service".localized
                  self.navigationController?.pushViewController(webView, animated: true)
                  self.navigationController?.navigationBar.isHidden = false
                  
              }
      } else if (URL.absoluteString == AppConstants.PrivacyPolicy) {
          if  let webView =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DocumentViewerViewController") as? DocumentViewerViewController{
                       webView.isComingfromSetting = true
                       webView.webURL = AppConstants.PrivacyPolicy
                       webView.titleName = "Privacy Policy".localized
                       self.navigationController?.pushViewController(webView, animated: true)
                       self.navigationController?.navigationBar.isHidden = false
                       
                   }
      }
      return false
    }
}
