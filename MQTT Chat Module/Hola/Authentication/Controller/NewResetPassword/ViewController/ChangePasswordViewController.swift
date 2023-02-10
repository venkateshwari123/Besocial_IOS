//
//  ResetPasswordViewController.swift
//  Do Chat
//
//  Created by rahul on 10/02/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    
    @IBOutlet weak var currentPasswordTextField     : UITextField!
    @IBOutlet weak var newPasswordTextField         : UITextField!
    @IBOutlet weak var reNewPasswordTextField       : UITextField!
    @IBOutlet weak var descriptionLbl               : UILabel!
    
    
    @IBOutlet weak var currentPasswordEyeButton: UIButton!
    
    @IBOutlet weak var newPasswordEyeButton: UIButton!

    @IBOutlet weak var reNewPasswordEyeButton: UIButton!
   
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    var isValidCurrentPassword : Bool = false
    var isValidNewPassword : Bool = false
    
    var isValidReenterNewPassword : Bool = false
    var isResetPassssowordButtonEnable : Bool = false
    {
        didSet {
             resetPasswordButton.alpha = isResetPassssowordButtonEnable ? 1 : 0.5
             resetPasswordButton.isEnabled = isResetPassssowordButtonEnable
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isResetPassssowordButtonEnable = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandel))
        view.addGestureRecognizer(tapGesture)
        navigationController?.navigationItem.title = "Reset Password".localized
        descriptionLbl.text = "Set new password for your account".localized + ". " + "The password you will set will be changed for your account".localized + ".".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_arrow"), style: .plain, target: self, action: #selector(backBarButtonAction))
        
        currentPasswordEyeButton.setImage(UIImage(named:"hide_paswrd" ), for: .normal)
        newPasswordEyeButton.setImage(UIImage(named:"hide_paswrd" ), for: .normal)
        reNewPasswordEyeButton.setImage(UIImage(named:"hide_paswrd" ), for: .normal)
        
        currentPasswordTextField.placeholder = "Current password".localized
        newPasswordTextField.placeholder = "New password".localized
        reNewPasswordTextField.placeholder = "Re-enter new password".localized
        resetPasswordButton.setTitle("Reset Password".localized, for: .normal)
        currentPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        newPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        reNewPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.title = "Reset Password".localized
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isHidden = false
        
     
    }
    
  
    
   @objc func tapGestureHandel( _ gesture : UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
    
    @objc func backBarButtonAction( _ sender : UIBarButtonItem)
     {
         navigationController?.popViewController(animated: true)
     }
    
    @IBAction func resetPasswordButtonAction( _ sender : UIButton)  {
        
        isResetPassssowordButtonEnable = false
        
        if newPasswordTextField.text != reNewPasswordTextField.text
        {
            Helper.showAlert(head: "", message: "The confirm password does not match the new password entered".localized + ".")
            isResetPassssowordButtonEnable = true
            return
        }
        
        if currentPasswordTextField.text == newPasswordTextField.text{
            Helper.showAlert(head: "", message: "Your new password cannot be the same as your current password".localized + ".")
            isResetPassssowordButtonEnable = true
            return
        }
        let validatePassword = CheckPasswordApi()
        let updateViewModel = UpdateViewModel()
        
        /*
         Bug Name :- Profile page>>edit profile>> We are able to change the password by entering the incorrect password.
         Fix Date :- 10/08/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Added isPassword api for validation
         */
        validatePassword.checkPasswordApi(password: currentPasswordTextField.text!) { response, error in
            if error == nil {
                updateViewModel.changePassword(oldPassword: self.currentPasswordTextField.text!, newPassword: self.newPasswordTextField.text!) { [self] (data, error) in
                    resetPasswordButton.isEnabled = true
                    
                    guard let  data = data , error == nil else {
                        Helper.showAlert(head: "", message: error!)
                        return
                    }
                    if data == "Ok"
                    {
        //                Helper.showAlert(head: "", message: "Your password has been reset successfully")
                        self.navigationController?.popViewController(animated: true)
                    }
                    else
                    {
                        Helper.toastViewForReachability(messsage: "Password changed successfully", view: self.view)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else if error?.code == 204 {
                Helper.showAlert(head: "", message: "Current password doesn't match.")
            }else{
                Helper.showAlert(head: "", message: error?.localizedDescription ?? "\(error?.code) server error.")
            }
        }

        
    }
    
    @IBAction func currentPasswrodEyeButtonAction(_ sender: UIButton) {
        
        currentPasswordTextField.isSecureTextEntry = !(sender.tag == 0)
        sender.setImage(UIImage(named: sender.tag == 0 ? "show_passwrd":"hide_paswrd"  ), for: .normal)
        sender.tag = sender.tag == 0 ? 1 : 0
    }
    
    @IBAction func newPasswordEyeButtonAction(_ sender: UIButton) {
        
        newPasswordTextField.isSecureTextEntry = !(sender.tag == 0)
        sender.setImage(UIImage(named: sender.tag == 0 ? "show_passwrd" :"hide_paswrd" ), for: .normal)
        sender.tag = sender.tag == 0 ? 1 : 0
    }
    
    @IBAction func reNewPasswordEyeButtonAction( _ sender : UIButton)  {
    
        reNewPasswordTextField.isSecureTextEntry = !(sender.tag == 0)
        sender.setImage(UIImage(named: sender.tag == 0 ? "show_passwrd" :"hide_paswrd" ), for: .normal)
        sender.tag = sender.tag == 0 ? 1 : 0
    }
    
    
   @objc func textFieldDidChange( _ textField : UITextField)
   {
       
       if textField == currentPasswordTextField
       {
           if (textField.text?.isEmpty ?? true) {
               isValidCurrentPassword = false
               return
           }
           if let passworText = currentPasswordTextField.text ,passworText.length > 7
           {
               isValidCurrentPassword = true
           }
           else
           {
               isValidCurrentPassword = false
           }
       }
       else if   textField == newPasswordTextField
       {
           if (textField.text?.isEmpty ?? true) {
               isValidNewPassword = false
               return
           }
             if let  passworText = newPasswordTextField.text ,passworText.length > 7
           {
               isValidNewPassword = true
           }
           else
           {
               isValidNewPassword = false
           }
       }
       else if textField == reNewPasswordTextField
       {
           if (textField.text?.isEmpty ?? true) {
               isValidReenterNewPassword = false
               return
           }
           if let  passworText = reNewPasswordTextField.text ,passworText.length > 7
           {
               isValidReenterNewPassword = true
           }
           else
           {
               isValidReenterNewPassword = false
           }
       }
      isResetPassssowordButtonEnable = false
       if isValidCurrentPassword && isValidNewPassword && isValidReenterNewPassword
       {
            if reNewPasswordTextField.text == newPasswordTextField.text {
               isResetPassssowordButtonEnable = true
            }else{
                Helper.toastViewForReachability(messsage: "The confirm password does not match.", view: self.view)
            }

       }
       
   }
    
}


