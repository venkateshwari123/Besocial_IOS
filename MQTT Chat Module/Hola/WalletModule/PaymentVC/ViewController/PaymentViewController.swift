//
//  PaymentViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 26/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit


class PaymentViewController: BaseViewController {

    
    @IBOutlet weak var amountTitle:UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var amountTopayLabel: UILabel!
    @IBOutlet weak var chooseOptionsStaticLabel: UILabel!
    
    let paymentVM = PaymentMethodVM()
    let cardsVM = CardsViewModel()
    var paymentCost:String?
    var payableAmount:Double?
    var isSelectedWallet:Bool = false
    var walletBalance:Double = 0.0
    var currencyCode:String = Utility.getWalletCurreny() // Utility.getCurreny() for dynamic // need to change based on country from login
    let cardVM = CardsViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PaymentMethodVM.callGetCard = false
        loadCardResponse()
        cardsVM.getAllCards()
        initialSetUp()
        edgesForExtendedLayout = []
        // Do any additional setup after loading the view.
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
    }
    
    @objc func addCardAction() {
        // navigation to add Card screen
        navigateToAddCardVC()
    }
    
    @objc func addMoneyAction() {
        /// navigation to recharge wallet
        navigateToRechargeVC()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func payButtonAction(_ sender: UIButton){
       navigateToSuccessVC()
    }
    
    func initialSetUp(){
         amountTitle.text = "Total amount to be paid:"
        titleLabel.text = "Payment Method"
        tableView.delegate = self
        tableView.dataSource = self
        
        amountTitle.font = Theme.getInstance().changePasswordButtonStyle.getFont()
        amountTitle.textColor = Theme.getInstance().changePasswordButtonStyle.getTextColor()
        
        payButton.layer.cornerRadius = payButton.frame.height/2
        payButton.titleLabel?.font = Theme.getInstance().promotionBuyButtonStyle.getFont()
        
        chooseOptionsStaticLabel.font = Theme.getInstance().sucessProductUploadTextStyle.getFont()
        chooseOptionsStaticLabel.textColor = Theme.getInstance().sucessProductUploadTextStyle.getTextColor()
    }
    
    
    func loadCardResponse(){
        cardsVM.isTableViewNeedReaload.subscribe(onNext: { success in
            if success{
                self.tableView.reloadData()
            }
        }, onError: { error in
            
        }, onCompleted: nil, onDisposed: nil).disposed(by: cardVM.disposeBag)
    }
    
    private func callGetCard(_ check:Bool){
//        addCardVM.cardAction()
    }
}

