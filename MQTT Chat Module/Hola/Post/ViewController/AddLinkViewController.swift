//
//  AddLinkViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
class AddLinkViewController: UIViewController {

    @IBOutlet weak var textViewOutlet: GrowingTextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    
    var businessLink = ""
    
    /// View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.textViewOutlet.becomeFirstResponder()
    }
    
     func uiDesign(){
         self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.addLink.localized)
         let doneBtn = UIBarButtonItem.init(title: Strings.save.localized, style: .done, target: self, action: #selector(saveAction))
        doneBtn.tintColor = .label
        self.navigationItem.rightBarButtonItem = doneBtn

        self.textViewOutlet.text = self.businessLink
    }
    
    @objc func saveAction(){
        if (businessLink.contains(" ")){
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterValidUrl.localized)
        }else {
            if let createPostVC = self.navigationController?.viewControllers.filter({$0.isKind(of: CreatePostViewController.self)}).first as? CreatePostViewController{
                createPostVC.businessLink = self.businessLink
                 self.navigationController?.popToViewController(createPostVC, animated: true)
            }
        }
     }
}
 extension AddLinkViewController:GrowingTextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
             return true
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        //        var txtAfterUpdate : String = ""
        //        if let text = textView.text as NSString? {
        //            txtAfterUpdate = text.replacingCharacters(in: range, with: text as String)
        //        }
//        if textView.text == ""{
//            self.navigationItem.rightBarButtonItem?.isEnabled = false
//        }else {
//            self.navigationItem.rightBarButtonItem?.isEnabled = true
//        }
        self.textViewHeightConstraint.constant = textView.text.height(withConstrainedWidth: textViewOutlet.frame.width, font: Utility.Font.Regular.ofSize(15.0))
         self.businessLink = textView.text
        
        
    }
}
