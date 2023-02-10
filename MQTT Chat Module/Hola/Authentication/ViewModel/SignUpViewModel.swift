//
//  SignUpViewModel.swift
//  Starchat
//
//  Created by 3Embed on 21/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class SignUpViewModel: NSObject {
    
    private let api: SignUpAPI = SignUpAPI()
    
    var didError: ((CustomErrorStruct) -> Void)?
    var didUpdateAny : (([String : Any]) -> Void)?
    var didUpdateUser : ((User) -> Void)?

    override init() { }
    
    var emailID:String = ""
    var passWord:String = ""
    var confirmPassWord:String = ""
    var userName:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var refCode:String = ""
    var number:String = ""
    var countryCode:String = ""
    var isPrivate:String = ""
//    var btnAcceptTerms:Bool = false
    
    
    func validateSignUp(withemailID emailID : String, andPassword password: String, andConfirmPassword confirmPassword : String, andUsername userName : String, andfirstName firstName : String, andlastName lastName : String,  andnumber number : String, andcountryCode countryCode : String, andisPrivate isPrivate : Bool,termsAndConditions:Bool) -> Bool{
        if number.count > 20{
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrPhoneNumber)
            return true
        }else if firstName.count == 0{
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrFirstName)
            return true
        }else if lastName.count == 0{
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrLastName)
            return true
        }else if userName.count == 0{
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrUserName)
            return true
        }else if emailID.count == 0{
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrEmail)
            return true
        }else if !Helper.isValidEmail(emailText: emailID){
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrValidEmail)
            return true
        }else if password.count == 0{
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrPassword)
            return true
        }else if confirmPassword.count == 0{
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrConfirmPassword)
            return true
        }else if password != confirmPassword{
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrPasswordDonotMatch)
            return true
            
//        }else if userReferralCode.count == 0{
//            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrRefCode)
//            return true
        }else if !termsAndConditions {
            Helper.showAlertViewOnWindow("", message: AppConstants.ErrorMessages.MsgErrTermsAndConditions)
            return true
        } else{
            return false
        }
    }
    
    
    func validateNextBtn() -> Bool{
        if countryCode+number != "" && firstName.count != 0 && userName.count != 0 && emailID != "" && passWord.count != 0 && confirmPassWord.count != 0{
            return true
        }else {
            return false
        }
    }
    
    func signUp(signUpData : [String : Any]) {
        self.api.signUpUser(signUpData: signUpData) { (obj, error) in
            if let loginObj = obj {
                if let didUpdate = self.didUpdateUser {
                    didUpdate(loginObj)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func verifySignupDetails(withemailID emailID : String, andUsername userName : String, andnumber number : String, andcountryCode countryCode : String){
        self.api.verifySignUpDetails(withemailID: emailID, andUsername: userName, andnumber: number, andcountryCode: countryCode) { (response, error) in
            if let data = response {
                if let didupdate = self.didUpdateAny{
                    didupdate(data)
                }
            }else{
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    
    func isValidmobileNumberOtp(number : String, andcountryCode countryCode : String) {
     
        self.api.checkingMobileNumberOTP(number: number, andcountryCode: countryCode) { (objLogin, error) in
            if let loginObj = objLogin {
                if let didUpdate = self.didUpdateAny {
                    didUpdate(loginObj)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func isValidEmail(email: String) {
     
        self.api.checkingEmailValidation(email: email) { (objLogin, error) in
            if let loginObj = objLogin {
                if let didUpdate = self.didUpdateAny {
                    didUpdate(loginObj)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    
}

