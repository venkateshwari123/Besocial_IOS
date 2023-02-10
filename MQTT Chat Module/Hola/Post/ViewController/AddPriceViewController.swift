
//
//  AddPriceViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class AddPriceViewController: UIViewController {
    
    @IBOutlet weak var currencyButtonOutlet: UIButton!
    @IBOutlet weak var priceTextView: GrowingTextView!
    
    @IBOutlet weak var currencyLabel: UILabel!
    var currency:String?
    var currencySymbol:String?
    
    var businessPrice:Double = 0.0
    var local = Locale.current
     //    var businessPriceString
    
    override func viewDidLoad() {
        super.viewDidLoad()
         uiDesign()
        
     }
   
    override func viewDidAppear(_ animated: Bool) {
          priceTextView.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.currencyLabel.text = self.currency
    }
     func uiDesign(){
        if businessPrice != 0.0 {
        self.priceTextView.text = "\(businessPrice)"
        }
        
         self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.addPrice.localized)
         let doneBtn = UIBarButtonItem.init(title: Strings.save.localized, style: .done, target: self, action: #selector(saveAction))
         doneBtn.tintColor = .label
        self.navigationItem.rightBarButtonItem = doneBtn
        
         // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    
    @objc func saveAction(){
        if self.currency == nil {
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: "Please".localized + " " + "Choose Currency".localized)
        }else {
             if let createPostVC = self.navigationController?.viewControllers.filter({$0.isKind(of: CreatePostViewController.self)}).first as? CreatePostViewController{
                createPostVC.productPrice = businessPrice
                createPostVC.currencySymbol = self.currencySymbol
                createPostVC.businessCurrency = currency ?? ""
                self.navigationController?.popToViewController(createPostVC, animated: true)
            }
        }
    }

    @IBAction func currencyBtnAction(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
        let currencyVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.currencyViewControllerVcId) as! CurrencyViewController
        self.navigationController?.pushViewController(currencyVc, animated: true)
        
    }
}

extension AddPriceViewController:GrowingTextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return true
        }
        let fullText = textView.text + text
        let textViewStringArray  =  fullText.components(separatedBy: ".")
        if textViewStringArray.count > 2 {
            return false
        }else {
            if textViewStringArray.count > 1{
                if textViewStringArray[1].count > 2{
                    return false
                }
            }
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
//          guard let value = Double(textView.text) else {
//            return
//        }
        self.businessPrice = Double(textView.text) ?? 0.0
    }
}
