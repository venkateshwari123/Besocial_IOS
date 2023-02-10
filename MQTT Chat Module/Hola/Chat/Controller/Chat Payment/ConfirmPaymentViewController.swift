//
//  ConfirmPaymentViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 10/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

protocol ConfirmPaymentViewControllerDelegate: class {
    func isViewDismissed(isPaymentDone: Bool)
}


class ConfirmPaymentViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var payToLabelOutlet: UILabel!
    @IBOutlet weak var amountLabelOutlet: UILabel!
    @IBOutlet weak var payNowButtonOutlet: UIButton!
    @IBOutlet weak var balanceLabelOutlet: UILabel!
    @IBOutlet weak var paymentTitleLabel: UILabel!
    
    @IBOutlet weak var receiverAmountDetailsMessage: UILabel!
    weak var delegate: ConfirmPaymentViewControllerDelegate?
    
    var confirmPaymentViewModel = ConfirmPaymentViewModel()
    var receiverUserId: String!
    var amount: String!
    var note: String?
    var receiverName: String!
    var receiverImage = ""
    var receiverCurrency = "INR"
    var receiverCurrencyCode = "₹"
    var receiverAmount:String = ""
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMainViewInitialUIAnDSetData()
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
    
    
    /// To set up intial view UI like corner radious view subviews
    func setupMainViewInitialUIAnDSetData(){
        self.balanceLabelOutlet.text = "Current Balance".localized + ": \(Utility.getWalletCurrenySymbol()) \(KeychainHelper.sharedInstance.getWalletBalance()) "
        self.payToLabelOutlet.text = "Pay to".localized + " \(self.receiverName ?? "")"
        self.paymentTitleLabel.text = "Payment".localized
        self.payNowButtonOutlet.setTitle("Pay Now".localized, for: .normal)
        self.amountLabelOutlet.text = "\(Utility.getWalletCurrenySymbol())  \(self.amount!)"
        self.mainContainerView.makeCornerRadious(readious: 7.0)
        self.payNowButtonOutlet.makeCornerRadious(readious: self.payNowButtonOutlet.frame.size.height / 2)
        self.receiverAmountDetailsMessage.text = "\(self.receiverName ?? "") " + "will receive".localized + " \(self.receiverCurrencyCode)\(receiverAmount)"
        
    }
    
    
    //MARK:- Service call
    /// transfer service call
    func transferMoneyServiceCall(){
        Helper.showPI()
        self.confirmPaymentViewModel.makePaymentServiceCall(receiverImage: receiverImage, receiverName: receiverName, receiverId: self.receiverUserId, note: self.note, amount: self.amount, receiverCurrency:receiverCurrency) { (success, error) in
            if success{
                Utility.updateWalletBalance(deductionAmount: self.amount)
                DispatchQueue.main.async{
                    self.dismiss(animated: true, completion: {
                        self.delegate?.isViewDismissed(isPaymentDone: true)
                    })
                }
            }else if let err = error{
                DispatchQueue.main.async{
                    Helper.showAlertViewOnWindow(err.localizedTitle, message: err.localizedDescription)
                }
            }
            Helper.hidePI()
        }
    }
    


    //MARK:- Buttons Action
    
    @IBAction func closeButtonAction(_ sender: Any) {
        if let dele = self.delegate{
            dele.isViewDismissed(isPaymentDone: false)
        }
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func balanceButtonAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
        let walletVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.walletVcId) as! WalletViewController
        walletVc.hidesBottomBarWhenPushed = true
//        walletVc.isPresented = true
        let navController = UINavigationController(rootViewController: walletVc)
        self.present(navController, animated:true, completion: nil)

    }
    
    
    @IBAction func payNowButtonAction(_ sender: Any) {
        self.transferMoneyServiceCall()
    }
}
