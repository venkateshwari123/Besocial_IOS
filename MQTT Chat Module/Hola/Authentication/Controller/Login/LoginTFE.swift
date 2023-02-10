//
//  LoginTFE.swift
//  Shoppd
//
//  Created by Rahul Sharma on 25/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

extension LoginVC:UITextFieldDelegate{
    
    /*
     Bug Name:- phone number should restrict to 15 digits only
     Fix Date:- 09/04/21
     Fixed By:- Nikunj C
     Description of Fix- add condition whcih restrict digits more than 15
     */
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /*
         Bug Name:- email take only 15 characters
         Fix Date:- 17/04/21
         Fixed By:- Nikunj C
         Description of fix:- remove 15 character limit validation for emailTF
         */
        if textField != emailTF{
            let currentCharacterCount = textField.text?.count ?? 0
                if range.length + range.location > currentCharacterCount {
                    return false
                }
                let newLength = currentCharacterCount + string.count - range.length
                return newLength <= 15
        }
            return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        emailPlaceHolder = textField == emailTF
//        passwordPlaceHolder = textField == passwordTF
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == emailTF{
    //            emailPlaceHolder = !(emailTF.text ?? "").isEmpty
                guard let email = emailTF.text,!email.isEmpty,Helper.isValidEmail(emailText: email) else{return}
                loginViewModel.validateRegisteration(type:.email, emailAddress:email) { (isSuccess,err,errcode)  in
                    self.isvalidEmail = true
                    if isSuccess{
                        self.successCredentialAction()
                        self.isEmailRegister = true
                }
                    else{
//                        self.invalidCredentialActon()
                        self.isEmailRegister = false
                    }
    //                self.checkemailImageView.isHidden = false
                }
            }
            if textField == passwordTF{
    //            passwordPlaceHolder = !(passwordTF.text ?? "").isEmpty
            }
    }
    
    func successCredentialAction(){
//        self.emailBoarderView.backgroundColor = self.emailBoarderView.setColor(colors: Colors.rgba_Green)
        self.passwordTF.becomeFirstResponder()
       
    }
    
    func invalidCredentialActon(){
//        emailTF.textColor = emailTF.setColor(colors: Colors.rgba_red)
//        emailBoarderView.backgroundColor = emailBoarderView.setColor(colors: Colors.rgba_red)
        invalideCredentialMessage.text = "Email address is not registered".localized
       invalideCredentialMessage.isHidden = false
//        switch logineType {
//        case .Email:
////            loginStackViewHeightConstraint.constant =  180
//        default:
////            loginStackViewHeightConstraint.constant =   120
//        }
        
        loginButtonViewIsEnable = false
        isvalidEmail = false
       view.endEditing(true)
    }
    
    @objc func textFieldDidChangeText(_ textField:UITextField){
        if invalideCredentialMessage != nil {
            if !invalideCredentialMessage.isHidden{
                invalideCredentialMessage.isHidden = true
            }
        }
        switch textField{
        case emailTF:
            passwordTF.clear()
            if let text = emailTF.text,!text.isEmpty{
                //                emailBoarderView.backgroundColor = emailBoarderView.setColor(colors: Colors.rgba_Green)
//                checkemailImageView.isHidden = false
//                checkemailImageView.image = UIImage(named: Helper.isValidEmail(emailText: text) ? "Success_Check" : "cross")
                self.emailValidateButton.isHidden =  !Helper.isValidEmail(emailText: text)
//                clearemailButton.isHidden = Helper.isValidEmail(emailText: text)
            }else{
                self.emailValidateButton.isHidden = true
//                checkemailImageView.isHidden = true
//                clearemailButton.isHidden = true
//                emailBoarderView.backgroundColor  = emailBoarderView.setColor(colors: Colors.rgba_red)
            }
            if let text = emailTF.text,text.isEmpty{
//                emailBoarderView.backgroundColor = emailBoarderView.setColor(colors: Colors.rgba_lightGray17)
            }
        case passwordTF:
            if let text = passwordTF.text,text.length > 7{
//                loginBoarderView.backgroundColor = loginBoarderView.setColor(colors: Colors.rgba_Green)
            }else{
//                loginBoarderView.backgroundColor  = loginBoarderView.setColor(colors: Colors.rgba_red)
            }
            
            if let text = passwordTF.text,text.isEmpty{
//                loginBoarderView.backgroundColor = loginBoarderView.setColor(colors: Colors.rgba_lightGray17)
            }
            
        case phoneNumberTF:
            if let text = phoneNumberTF.text,let countryCode = countryCode.text,Helper.isPhoneNumValid(phoneNumber: text, code: countryCode){
//                phoneNumberBoarderView.backgroundColor = phoneNumberBoarderView.setColor(colors: Colors.rgba_Green)
            }else{
//                phoneNumberBoarderView.backgroundColor  = phoneNumberBoarderView.setColor(colors: Colors.rgba_red)
            }
            
            if let text = phoneNumberTF.text,text.isEmpty{
//                phoneNumberBoarderView.backgroundColor = phoneNumberBoarderView.setColor(colors: Colors.rgba_lightGray17)
            }
            
        default:
            break
        }
        
        if let text = emailTF.text,Helper.isValidEmail(emailText: text),let passworText = passwordTF.text,passworText.length > 7{ //isvalidEmail
            loginButtonViewIsEnable = true
        }else if let text = phoneNumberTF.text,Helper.isPhoneNumValid(phoneNumber: text, code: countryName){
            loginButtonViewIsEnable = true
        }else{
            loginButtonViewIsEnable = false
        }
        
    }
    
}
extension LoginVC: UITextViewDelegate {
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
