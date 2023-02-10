//
//  EditBioViewController.swift
//  Do Chat
//
//  Created by rahul on 20/02/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit


protocol EditBioViewControllerDelegate : NSObjectProtocol {
    func done(value : String,isBusinessProfile: Bool)
}


class EditBioViewController: UIViewController {

    @IBOutlet weak var nextButton : UIButton!
    @IBOutlet weak var textView : UITextView!
    
    @IBOutlet weak var nextButtonBottomConstraint : NSLayoutConstraint!
    
    var value : String?
    var isFromBusiness: Bool = false
    var isFromCreateBusiness : Bool = false
    var updateEmailPhoneVMObject = UpdateEmailPhoneViewModel()
    weak var delegate : EditBioViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromBusiness || isFromCreateBusiness{
            self.navigationItem.title = "About The Business".localized
        }else{
            self.navigationItem.title = "Edit Bio".localized
        }
        nextButton.setTitle("Save".localized, for: .normal)
        textView.text = value
        
        nextButton.layer.cornerRadius = 16
        textView.layer.borderWidth = 1
        /*
        Bug Name : change font color
        Fix Date : 28-apr-2021
        Fixed By : Jayaram G
        Description Of Fix : changed textcolor from appcolor to black color
      */
        if #available(iOS 13.0, *) {
            textView.textColor = .label
        } else {
            textView.textColor = .black
            // Fallback on earlier versions
        }
        textView.layer.borderColor = Utility.appColor().cgColor
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_arrow"), style: .plain, target: self, action: #selector(backBarButtonAction))
        nextButton.isEnabled =  false
        nextButton.backgroundColor = .lightGray
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // To manage view height according to keyboard height
    ///
    /// - Parameter notification: keyboard notification object
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y + 20
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                self.nextButtonBottomConstraint.constant = keyboardHeight
            }, completion: nil)
            view.layoutIfNeeded()
        }
    }
    
    @objc func backBarButtonAction( _ sender : UIBarButtonItem)
     {
         navigationController?.popViewController(animated: true)
     }
    
    /*
     Refactor Name:- update profile while save value
     Refactor Date:- 19/05/21
     Refactor By  :- Nikunj C
     Description of Refactor:- call profile api to update value
     */
   @IBAction func nextButtonAction( _ sender : UIButton)  {
    if isFromCreateBusiness {
        self.delegate?.done(value: self.textView.text, isBusinessProfile: self.isFromBusiness)
        self.navigationController?.popViewController(animated: true)
        return
    }
    
    var params = ["":""]
    if self.isFromBusiness{
        let  businessUniqueId  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessUniqueId) as? String ?? ""
        params = [Strings.businessBioKey:textView.text,
                  "businessUniqueId" : businessUniqueId]
    }else{
        params = [Strings.status:textView.text]
    }
    
    self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
        self.delegate?.done(value: self.textView.text, isBusinessProfile: self.isFromBusiness)
        self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    
}


extension EditBioViewController : UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == value
        {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightGray
        }
        else
        {
            nextButton.isEnabled =  !textView.text.isEmpty
            nextButton.backgroundColor = textView.text.isEmpty ? .lightGray : Utility.appColor()
            
        }
    }
}
