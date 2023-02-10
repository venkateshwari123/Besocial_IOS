//
//  SendTipCoinsViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 16/12/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
protocol SendTipCoinsViewControllerDelegate {
    func moveToInSufficientVc()
    func moveToCoinWalletVc()
    func showSendTipSuccessScreen(userName : String)
}
class SendTipCoinsViewController: UIViewController {


    @IBOutlet weak var backViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var backViewOutlet: UIView!
    @IBOutlet weak var sendTipCoinsCollectionView: UICollectionView!

    @IBOutlet weak var sendTipTitleLabel: UILabel!
    @IBOutlet weak var amountTf: UITextField!
    
    @IBOutlet weak var getMoreBtnOutlet: UIButton!
    @IBOutlet weak var confirmBtnOutlet: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var tipAmountLabel: UILabel!
    var currencyViewModelObj = currencyViewModel()
    var socialModelData: SocialModel?
    var delegate: SendTipCoinsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendTipTitleLabel.font = Utility.Font.SemiBold.ofSize(16)
        self.getMoreBtnOutlet.titleLabel?.font = Utility.Font.SemiBold.ofSize(16)
        self.sendTipTitleLabel.text = "Send Tip".localized
        self.getMoreBtnOutlet.setTitle("Get More".localized, for: .normal)
        self.tipAmountLabel.text = "Tip Amount".localized
        self.confirmBtnOutlet.setTitle("Confirm".localized, for: .normal)
        self.balanceLabel.font = Utility.Font.SemiBold.ofSize(16)
        self.tipAmountLabel.font = Utility.Font.Regular.ofSize(16)
        self.amountTf.font = Utility.Font.SemiBold.ofSize(16)
        self.confirmBtnOutlet.titleLabel?.font = Utility.Font.SemiBold.ofSize(16)
        
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Send Tip")
        self.balanceLabel.text = KeychainHelper.sharedInstance.getCoinWalletBalance()
        getCoinsList()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    /// Adding ToolBar On Keyboard
//    func addDoneButtonOnKeyboard(){
//        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
//        doneToolbar.barStyle = .default
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let done: UIBarButtonItem = UIBarButtonItem(title: Strings.done.localized, style: .done, target: self, action: #selector(self.doneButtonAction))
//        let items = [flexSpace, done]
//        doneToolbar.items = items
//        doneToolbar.sizeToFit()
//        amountTf.inputAccessoryView = doneToolbar
//    }
    
    
    /// Done Button Action On toolBar
    @objc func doneButtonAction(){
        amountTf.resignFirstResponder()
    }
    
    @IBAction func getMoreBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.moveToCoinWalletVc()
        }
        
    }
    
    
    
    @IBAction func bgDismissAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getCoinsList() {
        let url = AppConstants.tipAmount
        self.currencyViewModelObj.getCoinsList(strUrl: url) { (success, error) in
            print(self.currencyViewModelObj.coinAmountsListArray)
            DispatchQueue.main.async {
            self.sendTipCoinsCollectionView.reloadData()
            }
        }
    }
    
    func sendCoinTipApi() {
        if Double(amountTf.text!) == 0{
            Helper.showAlert(head: "Message", message: "Please enter amount greater than 0.")
            return
        }
        var params = ["senderId":Utility.getUserid()!,
                      "senderName":Utility.getUserName(),
                      "postId":self.socialModelData?.postId ?? "",
                      "senderType":"user",
                      "coins":Double(amountTf.text!) ?? 0] as [String : Any]
        params["type"] = "Tip"
        params["description"] = "Enjoy"
        params["notes"] = "Enjoy"
        params["receiverName"] = self.socialModelData?.userName ?? ""
        params["receiverType"] = "user"
        params["receiverId"] = self.socialModelData?.userId ?? ""
        
        
        self.currencyViewModelObj.postSendingTipCall(params: params) { (success, error) in
            if success {
                Utility.updateWalletBalance()
                self.dismiss(animated: true, completion: {
                    self.delegate?.showSendTipSuccessScreen(userName: self.socialModelData?.userName ?? "")
                })
               
            }else {
                print(error)
            }
        }
    }
    
    // To manage view height according to keyboard height
    ///
    /// - Parameter notification: keyboard notification object
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        /*
         Bug Name:- thr view of send tip if I open to type value should show confirm button over keyboard
         Fix Date:- 09/04/21
         Fix By  :- Jayaram G
         Description of Fix:- Changing bottom constraint according to keyboard height
         */
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                self.backViewBottomConstraint.constant = keyboardHeight
            }, completion: nil)
            view.layoutIfNeeded()
        }
    }
   
    
    @IBAction func confirmBtnAction(_ sender: UIButton) {
        guard let textAmount = Double(amountTf.text!)  else {return}
        guard let walletAmount = Double(KeychainHelper.sharedInstance.getCoinWalletBalance()) else {return}
        if  textAmount > walletAmount{
            self.dismiss(animated: true) {
                self.delegate?.moveToInSufficientVc()
            }
        }else{
            sendCoinTipApi()
        }
    }
}


//MARK:- CollectionView DataSource
extension SendTipCoinsViewController:UICollectionViewDataSource{
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currencyViewModelObj.coinAmountsListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinsTipCollectionViewCell", for: indexPath) as! CoinsTipCollectionViewCell
        if amountTf.text! == "\(self.currencyViewModelObj.coinAmountsListArray[indexPath.row])"{
            cell.bgView.layer.borderColor = UIColor.hexStringToUIColor(hex: "#0C6F6D").cgColor
            cell.bgView.layer.borderWidth = 1
        }
        else{
            cell.bgView.layer.borderColor = #colorLiteral(red: 0.9386680722, green: 0.9387995601, blue: 0.9386265874, alpha: 1)
            cell.bgView.layer.borderWidth = 0
        }
        cell.lblAmount?.text = "\(self.currencyViewModelObj.coinAmountsListArray[indexPath.row])"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        amountTf.text = "\(self.currencyViewModelObj.coinAmountsListArray[indexPath.row])"
        sendTipCoinsCollectionView.reloadData()
    }
}

//MARK:- CollectionView Delegate FlowLayout
extension SendTipCoinsViewController:UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 4, height: 55)
       }
}
