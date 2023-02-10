//
//  AddBank+KeyBoard.swift
//  Yelo
//
//  Created by Rahul Sharma on 07/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

//MARK:- UITextFieldDelegate
extension AddBankViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setViewRadiusandShadow(cornerRadius: 5.0, viewBoaderColor: Colors.attributeBorderColor , viewBoaderWidth: 0.7, masksToBounds: true )
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setViewRadiusandShadow(cornerRadius: 5.0, viewBoaderColor: Colors.inactiveBorder , viewBoaderWidth: 0.7, masksToBounds: true )
        switch textField{
        case routingNumberTextField :
            _ = validateBankCodeTextField()
            break
        case accountNumberTextfield :
            _ = validateAccountNoTextField()
            break
        case accountHolderNameTextField :
            _ = validateConfirmAccountTextfield()
            break
        default :
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == routingNumberTextField{
            accountNumberTextfield.becomeFirstResponder()
        }else if textField == accountNumberTextfield{
            accountHolderNameTextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
}


// MARK:- Keyboard
extension AddBankViewController {
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    @objc func keyboardWasShown(_ notification: Foundation.Notification){
        //Need to calculate keyboard exact size due to Apple suggestions
        let info : NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.bottomConstraintSaveButton.constant = -(keyboardSize!.height)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillBeHidden(_ notification: Foundation.Notification){
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.bottomConstraintSaveButton.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}
