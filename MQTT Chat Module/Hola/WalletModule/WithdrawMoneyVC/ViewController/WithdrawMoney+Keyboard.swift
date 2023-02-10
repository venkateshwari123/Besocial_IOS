//
//  WithdrawMoney+Keyboard.swift
//  Yelo
//
//  Created by Rahul Sharma on 08/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

//MARK:- keyboard
extension WithdrawMoneyViewController{
    func registerForKeyboardNotifications(){
            //Adding notifies on keyboard appearing
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
                 
              self.bottomConstraintConfirmButton.constant = (keyboardSize?.height ?? 0 ) + 15
                self.view.layoutIfNeeded()
            }
        }
        
        @objc func keyboardWillBeHidden(_ notification: Foundation.Notification){
            UIView.animate(withDuration: 0.3) {
              self.bottomConstraintConfirmButton.constant = 15
                self.view.layoutIfNeeded()
            }
        }
}
