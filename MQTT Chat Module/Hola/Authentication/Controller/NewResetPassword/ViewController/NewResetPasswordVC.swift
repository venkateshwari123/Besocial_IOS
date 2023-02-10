//
//  NewResetPasswordVC.swift
//  Do Chat
//
//  Created by Rahul Sharma on 14/05/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class NewResetPasswordVC: UIViewController {

    @IBOutlet weak var backMainView: UIView!
    @IBOutlet weak var backBtnOutlet: UIButton!
    @IBOutlet weak var emailViewOutlet: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var confirmbtnView: UIView!
    @IBOutlet weak var confirmbtn: UIButton!
    @IBOutlet weak var forgotPasswordLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    var emailId:String = ""
    var loginViewModel : LoginViewModel = LoginViewModel.init(api: LoginAPI())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        confirmbtn.makeCornerRadious(readious: 16)
        emailTF.text = self.emailId
        let placehlderColor = #colorLiteral(red: 0.7764705882, green: 0.8196078431, blue: 0.8901960784, alpha: 1)
        
        let plaeholderDic  : [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "ProductSans-Bold", size: 16) as Any, NSAttributedString.Key.foregroundColor : placehlderColor]
        emailTF.attributedPlaceholder = NSAttributedString(string: "Email".localized, attributes: plaeholderDic)
        descriptionLbl.text = "Please enter the registered email address to which we can send you the verification code".localized + "."
        confirmbtn.setTitle("Confirm".localized, for: .normal)
        forgotPasswordLbl.text = "Forgot Password".localized + "?"
        Fonts.setFont(emailTF, fontFamiy: .custom("ProductSans-Bold"), size: .custom(16), color:  #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1))
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.emailTF.becomeFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        guard let email = emailTF.text, email.count > 0 else{return}
        loginViewModel.isValidEmailOtp(mail: email , userName: Utility.getUserName() ?? "", number: "", andcountryCode: "")
        loginViewModel.didUpdateAny = { userObj in
           print("email available")
            self.loginViewModel.sendForgotPasswordLink(email: email, mobile: nil, dialCode: nil, type: 1) { (success, erroCode) in
                if success {
                    print("Email sent successfully")
                    let vc = EmailSentVC.instantiate(storyBoardName: "Authentication") as EmailSentVC
                    vc.delegateObj = self
                    vc.definesPresentationContext = true
                    vc.modalPresentationStyle = .overCurrentContext
                    var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
                    while ((topRootViewController?.presentedViewController) != nil) {
                        topRootViewController = topRootViewController?.presentedViewController
                    }
                    DispatchQueue.main.async {
                        topRootViewController?.present(vc, animated: true, completion: {
                        })
                        
                        self.navigationController?.popToRootViewController(animated: false)
                    }
                }else{
                    print("Error")
                }
            }
        }
        loginViewModel.didError = { error in
            if error.code == 204 {
                // not registered
                Helper.toastView(messsage: "This email id is not linked with any".localized + " \(AppConstants.AppName) " + "account".localized + " , " + "please".localized + " " + "try again".localized + " " + "with a new email id or register as a new user".localized, view: self.view)
            }
        }
    }
}


extension NewResetPasswordVC: EmailSentVCDelegate {
    func navigateToLoginVc() {
        self.navigationController?.popViewController(animated: true)
    }
}
