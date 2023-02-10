//
//  BankListViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol BankListViewControllerDelegate {
    func withdrawSuccess()
}

class BankListViewController: BaseViewController {
    
    @IBOutlet weak var addBankButton: UIButton!
    @IBOutlet weak var stripeStatusImageView: UIImageView!
    @IBOutlet weak var stripeImageView: UIImageView!
    @IBOutlet weak var stripeAccountStaticLabel: UILabel!
    @IBOutlet weak var StripeStatusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightConstraintAddBankButton: NSLayoutConstraint!
    @IBOutlet weak var bankAccountsStaticLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var connectStripeButton: UIButton!
    
    let viewModel = BankListViewModel()
    var delegate: BankListViewControllerDelegate?

    //Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getBankAccountFromStripe{
            self.setStripeUI()
            self.handleNextButton()
            self.tableView.reloadData()
        }
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unHideNavBar()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBankButton.layer.cornerRadius = addBankButton.frame.height/2
    }
    
    func handleNextButton() {
        if self.viewModel.bankArray.count == 0 {
            self.nextButton.isHidden = true
        }else{
            self.nextButton.isHidden = false
        }
    }
    
    func setStripeUI(){
        UIView.animate(withDuration: 0.3) {
            self.addBankButton.superview?.superview?.alpha = 1
            self.bankAccountsStaticLabel.alpha = 1
            self.tableView.alpha = 1
            self.heightConstraintAddBankButton.constant = self.viewModel.isStripAccountVerified ? 60 : 0
             self.stripeStatusImageView.image = self.viewModel.isStripAccountVerified ? #imageLiteral(resourceName: "stripeVerified") : #imageLiteral(resourceName: "stripeNotVerified")
             self.StripeStatusLabel.textColor = self.viewModel.isStripAccountVerified ? #colorLiteral(red: 0.2706157565, green: 0.6567590833, blue: 0.3188629448, alpha: 1) : #colorLiteral(red: 0.9256283641, green: 0.1703213453, blue: 0, alpha: 1)
            self.StripeStatusLabel.text = self.viewModel.stripeStatusText.localized
            self.addBankButton.isHidden = self.viewModel.isStripAccountVerified ? false : true
            self.view.layoutIfNeeded()
        }
    }
    
    func setUp(){
        title = "Bank Details".localized
        addBankButton.superview?.superview?.alpha = 0
        bankAccountsStaticLabel.alpha = 0
        self.tableView.alpha = 0
        setNavigationLeftBarBackButton()
      
        
        stripeAccountStaticLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
        stripeAccountStaticLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
        stripeAccountStaticLabel.text = "Stripe Account".localized
        Theme.getInstance().rechargeSuccessDetailStyle.getTextColor()
        
        StripeStatusLabel.font = Theme.getInstance().noItemDescLabelStyle.getFont()
        heightConstraintAddBankButton.constant = 0
        
        addBankButton.setTitleColor(Theme.getInstance().withdrawLogButtonStyle.getTextColor(), for: .normal)
        addBankButton.setTitle("Add Account".localized, for: .normal)
        addBankButton.titleLabel?.font = Theme.getInstance().withdrawLogButtonStyle.getFont()
        addBankButton.layer.borderColor = #colorLiteral(red: 0.2862745098, green: 0.6705882353, blue: 0.9529411765, alpha: 1)
        addBankButton.layer.cornerRadius = addBankButton.frame.height/2
        addBankButton.layer.borderWidth = 1
        
        bankAccountsStaticLabel.font = Theme.getInstance().withdrawMethodsLabelStyle.getFont()
        bankAccountsStaticLabel.textColor = Theme.getInstance().withdrawMethodsLabelStyle.getTextColor()
        bankAccountsStaticLabel.text = "Bank Accounts".localized
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
       
        nextButton.setTitle(Strings.next.localized, for: .normal)
        nextButton.titleLabel?.font = Theme.getInstance().productEditButton.getFont()
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = nextButton.frame.height/2
    }
    
    @IBAction func addBankAccountButtonAction(_ sender: UIButton){
        navigateToAddBankVC()
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton){
        if viewModel.bankArray.count > 0 {
            navigateToWithdrawMoneyVC()
        }else{
            Helper.showAlert(head: "Oops!", message: "Please add bank account")
        }
    }
    
    @IBAction func connectStripeButtonAction(_ sender: UIButton){
        if !viewModel.isStripAccountVerified{
            navigateToConnectStripeVC()
        }
    }
}

extension BankListViewController :stripeSignUpVCDelegate{
    func stripeSignUpSuccess(){
        viewModel.getBankAccountFromStripe{
            self.setStripeUI()
            self.handleNextButton()
            self.tableView.reloadData()
        }
    }
}

extension BankListViewController :AddBankVCDelegate{
    func bankAccountAdded() {
        viewModel.getBankAccountFromStripe{
            self.setStripeUI()
            self.handleNextButton()
            self.tableView.reloadData()
        }
    }
}


extension BankListViewController: BankDetailDelegate{
    func accountDeleted(){
        viewModel.getBankAccountFromStripe{
            self.handleNextButton()
            self.tableView.reloadData()
        }
    }
}


