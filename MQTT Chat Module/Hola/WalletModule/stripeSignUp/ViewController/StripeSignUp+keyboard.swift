//
//  StripeSignUp+keyboard.swift
//  Yelo
//
//  Created by Rahul Sharma on 04/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

//MARK:- UITextfield delegate
extension StripeSignUpViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == dateOfBirthTextField && viewModel.stripeSignUpModel.dateOfBirth == nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy"
                dateOfBirthTextField.text = dateFormatter.string(from: Date().adding(years: -18))
                viewModel.stripeSignUpModel.dateOfBirth = Date().adding(years: -18)
            }
        textField.setViewRadiusandShadow(cornerRadius: 5.0, viewBoaderColor: Colors.attributeBorderColor, viewBoaderWidth: 0.7, masksToBounds: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case addressTextField:
            let storyBoardObj = UIStoryboard.init(name: "AddAddress", bundle: nil)
            if #available(iOS 13.0, *) {
                let searchPlacesViewController = storyBoardObj.instantiateViewController(identifier: "SearchPlacesViewController") as! SearchPlacesViewController
                searchPlacesViewController.notifier = { search in
                    print(search)
                    self.fetchTheAddressPlaceDetails(selectedaddress: search)
                }
                self.present(searchPlacesViewController, animated: true, completion: {})
            } else {
                // Fallback on earlier versions
            }
                
            return false
        default:
            return true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setViewRadiusandShadow(cornerRadius: 5.0, viewBoaderColor: Colors.inactiveBorder, viewBoaderWidth: 0.7, masksToBounds: true )
        switch textField {
        case firstNameTextField:
            viewModel.stripeSignUpModel.firstName = textField.text ?? ""
            break
        case lastNameTextField:
            viewModel.stripeSignUpModel.lastName = textField.text ?? ""
            break
        case dateOfBirthTextField:
            
//            viewModel.stripeSignUpModel.dateOfBirth = textField.text ?? ""
            break
        case ssnTextField:
            viewModel.stripeSignUpModel.ssn = textField.text ?? ""
            break
        /*
         Bug Name:- Document id is missing in UI
         Fix Date:- 14/06/21
         Fix By  :- Jayaram G
         Description of Fix:- added document id field
         */
        case documentIdTextField:
            viewModel.stripeSignUpModel.documentId = textField.text ?? ""
            break
        case addressTextField:
            viewModel.stripeSignUpModel.address = textField.text ?? ""
            break
        case cityTextField:
            viewModel.stripeSignUpModel.city = textField.text ?? ""
            break
        case stateTextField:
            viewModel.stripeSignUpModel.state = textField.text ?? ""
            break
        case zipCodeTextField:
            viewModel.stripeSignUpModel.zipCode = textField.text ?? ""
            break
        case countryTextField:
            viewModel.stripeSignUpModel.country = textField.text ?? ""
            break
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
            break
        case lastNameTextField:
            dateOfBirthTextField.becomeFirstResponder()
            break
        case dateOfBirthTextField:
            ssnTextField.becomeFirstResponder()
            break
        case ssnTextField:
            documentIdTextField.becomeFirstResponder()
            break
        /*
         Bug Name:- Document id is missing in UI
         Fix Date:- 14/06/21
         Fix By  :- Jayaram G
         Description of Fix:- added document id field
         */
        case documentIdTextField:
            addressTextField.becomeFirstResponder()
            break
        case addressTextField:
            cityTextField.becomeFirstResponder()
            break
        case cityTextField:
            stateTextField.becomeFirstResponder()
            break
        case stateTextField:
            zipCodeTextField.becomeFirstResponder()
            break
        case zipCodeTextField:
            countryTextField.becomeFirstResponder()
            break
        case countryTextField:
            textField.resignFirstResponder()
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
}

// MARK:- Keyboard
extension StripeSignUpViewController {
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
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize!.height + 60 , right: 0)
            self.submitButtonBottomConstraint.constant = keyboardSize!.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillBeHidden(_ notification: Foundation.Notification){
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
            self.submitButtonBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}
