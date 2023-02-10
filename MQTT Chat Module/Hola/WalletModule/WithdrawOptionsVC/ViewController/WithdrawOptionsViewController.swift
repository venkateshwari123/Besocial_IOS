//
//  WithdrawOptionsViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol WithdrawOptionsViewControllerDelegate {
    func withdrawSuccess()
}

class WithdrawOptionsViewController: BaseViewController {
    
    @IBOutlet weak var balanceAmountLabel:UILabel!
    @IBOutlet weak var balanceAmountStaticLabel: UILabel!
    @IBOutlet weak var withdrawLogButton: UIButton!
    @IBOutlet weak var withdrawMethodStaticLabel: UILabel!
    @IBOutlet weak var withdrawDesctiptionStaticLabel: UILabel!
    @IBOutlet weak var bankAccountsStaticLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = WithdrawViewModel()
    var delegate: WithdrawOptionsViewControllerDelegate?
    //Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        viewModel.getPaymentMethods {
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
    
    func setUp(){
        title = "Withdraw".localized
        setNavigationLeftBarBackButton()
        balanceAmountStaticLabel.font = Theme.getInstance().withdrawLabelStyle.getFont()
        balanceAmountStaticLabel.textColor = UIColor.setColor(lightMode: AppColourStr.descriptionLabel, darkMode: "#F2F2F2")
        balanceAmountStaticLabel.text = "Balance Amount".localized
        //Theme.getInstance().withdrawLabelStyle.getTextColor()
        
        balanceAmountLabel.font = Theme.getInstance().withdrawAmountLabelStyle.getFont()
        balanceAmountLabel.textColor = UIColor.setColor(lightMode: AppColourStr.descriptionLabel, darkMode: "#F2F2F2")
        //Theme.getInstance().withdrawAmountLabelStyle.getTextColor()
        balanceAmountLabel.text = KeychainHelper.sharedInstance.getWalletBalance()
        
        withdrawLogButton.setTitle("Withdrawal Logs".localized, for: .normal)
        withdrawLogButton.titleLabel?.font = Theme.getInstance().withdrawLogButtonStyle.getFont()
        withdrawLogButton.setTitleColor(Theme.getInstance().withdrawLogButtonStyle.getTextColor(), for: .normal)
        withdrawLogButton.layer.cornerRadius = withdrawLogButton.frame.height/2
        withdrawLogButton.layer.borderWidth = 1
        withdrawLogButton.layer.borderColor = #colorLiteral(red: 0.2862745098, green: 0.6705882353, blue: 0.9529411765, alpha: 1)
       // withdrawLogButton.backgroundColor = .white
        if #available(iOS 13.0, *) {
            withdrawLogButton.backgroundColor = .systemBackground
        }

        withdrawMethodStaticLabel.font = Theme.getInstance().withdrawMethodsLabelStyle.getFont()
        withdrawMethodStaticLabel.textColor = UIColor.setColor(lightMode: AppColourStr.descriptionLabel, darkMode: "#F2F2F2")
        withdrawMethodStaticLabel.text = "Withdraw Methods".localized
        //Theme.getInstance().withdrawMethodsLabelStyle.getTextColor()
        
        withdrawDesctiptionStaticLabel.font = Theme.getInstance().withdrawLabelStyle.getFont()
        withdrawDesctiptionStaticLabel.textColor = UIColor.setColor(lightMode: AppColourStr.descriptionLabel, darkMode: "#F2F2F2")
        withdrawDesctiptionStaticLabel.text = "Select any of the payment receiving method to withdraw the money.".localized
        //Theme.getInstance().withdrawLabelStyle.getTextColor()
        
        bankAccountsStaticLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
            //Theme.getInstance().rechargeSuccessDetailStyle.getTextColor()
        
        balanceAmountLabel.text = "\(Utility.getWalletCurrenySymbol()) " + KeychainHelper.sharedInstance.getWalletBalance() // Utility.getCurrenySymbol()
    }
    
    
    @IBAction func bankAccountsButtonAction(_ sender: UIButton){
        navigateToBankListVC()
    }
    
    @IBAction func withdrawButtonAction(_ sender: UIButton){
        navigateToWithdrawLogs()
    }
}

//MARK:- table view delegate, dataSource
extension WithdrawOptionsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.withdrawOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WithdrawOptionTableViewCell", for: indexPath) as? WithdrawOptionTableViewCell else {return UITableViewCell()}
        cell.configureCell(option: viewModel.withdrawOptions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateToBankListVC()
    }
}
