//
//  SubscriptionPopup.swift
//  PicoAdda
//
//  Created by 3Embed on 21/10/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
class SubscriptionPopup: UIViewController {
    
    @IBOutlet weak var lblyouwillget: UILabel!
    @IBOutlet weak var lblAppwillget: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var subscriptionSettingsLabel: UILabel!
    @IBOutlet weak var instructionlabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var youWillGetLabel: UILabel!
    @IBOutlet weak var appWillLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    
    
    
    let subscriptionPopVmObj = SubscriptionPopupViewModel()
    var coinValue:Double = 0
    var textAmount:Double = 0
    var appWillGet:Double = 0
    var userget:Double = 0
    var subscriptionCostChanged:Bool = false
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setlocalizeString()
        subscriptionSettingsLabel.font = Utility.Font.Bold.ofSize(16)
        lblyouwillget.font = Utility.Font.SemiBold.ofSize(14)
        lblAppwillget.font = Utility.Font.SemiBold.ofSize(14)
        instructionlabel.font = Utility.Font.Regular.ofSize(14)
        headerLabel.font = Utility.Font.Regular.ofSize(14)
        txtAmount.font = Utility.Font.Bold.ofSize(16)
        confirmBtn.titleLabel?.font = Utility.Font.Bold.ofSize(15)
        
        if let coinV = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.coinValue) as? String {
            self.coinValue = Double(coinV) ?? 0
        }
        if let userSubscriptionDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.subscriptionDetails) as? [String:Any] {
            if let amount = userSubscriptionDetails["amount"]  as? Double{
                txtAmount.text = "\(amount)"
            }
            if let appWillGet = userSubscriptionDetails["appWillGet"]  as? Double{
                lblAppwillget.text = "\(appWillGet) (\(Utility.getWalletCurrenySymbol())\(self.coinValue * appWillGet))"
            }
            if let userWillGet = userSubscriptionDetails["userWillGet"]  as? Double{
                lblyouwillget.text = "\(userWillGet) (\(Utility.getWalletCurrenySymbol())\(self.coinValue * userWillGet))"
            }
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
 
    
//    @objc func keyboardWillShow(notification:NSNotification) {
//
//        guard let userInfo = notification.userInfo else { return }
//        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
//
//        var contentInset:UIEdgeInsets = self.scrollViewOutlet.contentInset
//        contentInset.bottom = keyboardFrame.size.height + 20
//        scrollViewOutlet.contentInset = contentInset
//        scrollViewOutlet.contentOffset = CGPoint(x: 0, y: keyboardFrame.size.height)
//        self.reloadInputViews()
//    }
//
//    @objc func keyboardWillHide(notification:NSNotification) {
//        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
//        scrollViewOutlet.contentInset = contentInset
//        scrollViewOutlet.contentOffset = CGPoint(x: 0, y: 0)
//    }
    
    func setlocalizeString(){
        self.subscriptionSettingsLabel.text = "Subscription Settings".localized
        self.instructionlabel.text = "Please enter".localized + " " + "the monthly subscription cost".localized
        self.headerLabel.text = "Set monthly value".localized
        self.youWillGetLabel.text = "You will get".localized
        self.appWillLabel.text = "App will get".localized
        self.confirmBtn.setTitle("Confirm".localized, for: .normal)
    }
    
    @IBAction func bgTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func confirmTap(_ sender: Any) {
        if !subscriptionCostChanged {
            self.dismiss(animated: true, completion: nil)
            return
        }
        postSubscriptionDetails()
    }
    
    func postSubscriptionDetails() {
        let params = ["amount":textAmount,
                      "appWillGet":appWillGet,
                      "userWillGet":userget]
        subscriptionPopVmObj.postSubscriptionDetailsCall(params: params) { (success, error) in
            if success {
                    UserDefaults.standard.set(params, forKey: AppConstants.UserDefaults.subscriptionDetails)
                self.dismiss(animated: true, completion: nil)
                print("Successfully updated")
            }else {
                print(error)
            }
        }
    }
}
extension SubscriptionPopup: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        subscriptionCostChanged = true
        var txtAfterUpdate : String = ""
        if let text = txtAmount.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        if txtAfterUpdate != "" {
            if let val =  Double(txtAfterUpdate) {
                lblyouwillget.text =  "\(val/2) (\(Utility.getWalletCurrenySymbol())\(self.coinValue * (val/2)))"
                lblAppwillget.text = "\(val/2) (\(Utility.getWalletCurrenySymbol())\(self.coinValue * (val/2)))"
                switch textField {
                case txtAmount:
                    self.textAmount = val
                    self.appWillGet = val/2
                    self.userget = val/2
                default:
                    break
                }
            }
        }else {
            lblyouwillget.text =  "0.0 (\(Utility.getWalletCurrenySymbol())0.0)"
            lblAppwillget.text =  "0.0 (\(Utility.getWalletCurrenySymbol())0.0)"
            switch textField {
            case txtAmount:
                self.textAmount = 0
            case lblAppwillget:
                self.appWillGet = 0
            case lblyouwillget:
                self.userget = 0
            default:
                break
            }
        }
        
        
        return true
    }
}
