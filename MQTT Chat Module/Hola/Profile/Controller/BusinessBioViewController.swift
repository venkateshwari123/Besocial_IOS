//
//  BusinessBioViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 20/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class BusinessBioViewController: UIViewController {
 
    /// Variables and Declaratoins
    var businessBio = ""
    var isFromCreateBusinessVc:Bool = false
    
    /// All Outlets
    
    
    @IBOutlet weak var businessBioTextView: GrowingTextView!
    @IBOutlet weak var removeBusinessBioOutlet: UIButton!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    /// View life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title:  Strings.bio.localized)
        if isFromCreateBusinessVc {
            self.businessBioTextView.text = businessBio
        }else {
            self.businessBioTextView.text = businessBio
        }
      
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: Strings.done.localized, style: .done, target: self, action: #selector(doneAction))
        if businessBio == "" {
            removeBusinessBioOutlet.isHidden = true
        }else {
            removeBusinessBioOutlet.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.businessBioTextView.becomeFirstResponder()
    }

    /// Done Button action
    @objc func doneAction() {
        if businessBio == "" {
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.businessBioCannotBeEmpty.localized)
        }else {
            if isFromCreateBusinessVc {
                if let businessContactVc = self.navigationController?.viewControllers.filter({$0.isKind(of: BusinessContactInfoViewController.self)}).first as? BusinessContactInfoViewController{
                    businessContactVc.businessBio = businessBio
                    self.navigationController?.popToViewController(businessContactVc, animated: true)
                }
             }else {
                guard let editVc = self.navigationController?.viewControllers[0] as? NewEditProfileViewController else {return}
                editVc.businessBio = self.businessBio
                self.navigationController?.popToViewController(editVc, animated: true)
            }
            
        }
    }
    
    @IBAction func removeBioAction(_ sender: UIButton) {
        self.businessBio = ""
        self.businessBioTextView.text = ""
    }
}
extension BusinessBioViewController: GrowingTextViewDelegate {

    
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
////        var txtAfterUpdate : String = ""
////        if let text = textView.text as NSString? {
////            txtAfterUpdate = text.replacingCharacters(in: range, with: text as String)
////        }
//        self.textViewHeightConstraint.constant = txtAfterUpdate.height(withConstrainedWidth: businessBioTextView.frame.width, font: Utility.Font.Regular.ofSize(15.0))
//        if txtAfterUpdate == "" {
//            removeBusinessBioOutlet.isHidden = true
//        }else {
//            removeBusinessBioOutlet.isHidden = false
//        }
//        self.businessBio = txtAfterUpdate
//
//        return true
//    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        //        var txtAfterUpdate : String = ""
        //        if let text = textView.text as NSString? {
        //            txtAfterUpdate = text.replacingCharacters(in: range, with: text as String)
        //        }
        self.textViewHeightConstraint.constant = textView.text.height(withConstrainedWidth: businessBioTextView.frame.width, font: Utility.Font.Regular.ofSize(15.0))
        if textView.text == "" {
            removeBusinessBioOutlet.isHidden = true
        }else {
            removeBusinessBioOutlet.isHidden = false
        }
        self.businessBio = textView.text
        
        
    }
    
    
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        var txtAfterUpdate : String = ""
//        if let text = textField.text as NSString? {
//            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
//        }
//        self.textViewHeightConstraint.constant = txtAfterUpdate.height(withConstrainedWidth: businessBioTextView.frame.width, font: Utility.Font.Regular.ofSize(15.0))
//        if txtAfterUpdate == "" {
//            removeBusinessBioOutlet.isHidden = true
//        }else {
//            removeBusinessBioOutlet.isHidden = false
//        }
//        self.businessBio = txtAfterUpdate
//
//        return true
//    }
}
