//
//  BankDetailViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 11/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol BankDetailDelegate {
    func accountDeleted()
}

class BankDetailViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var accountNoStaticLabel: UILabel!
    @IBOutlet weak var accountNoLabel: UILabel!
    @IBOutlet weak var confirmAccountNoStaticLabel: UILabel!
    @IBOutlet weak var confirmAccountNoLabel: UILabel!
    
    let viewModel = BankDetailViewModel()
    var delegate: BankDetailDelegate?
   
    //Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @IBAction func deleteAccountButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete bank account?", preferredStyle: UIAlertController.Style.alert)
               alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: { (act:UIAlertAction) in
                   
                self.viewModel.deleteBank(){
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.accountDeleted()
                }
                   
               }))
               alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
               
               self.present(alert, animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func setUp(){
        hideNavBar()
        titleLabel.text = "Bank Details".localized
        titleLabel.font = Theme.getInstance().navBartitleStyle.getFont()
        //titleLabel.textColor = Theme.getInstance().navBartitleStyle.getTextColor()
        titleLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
        setNavigationLeftBarBackButton()
        
        accountNoStaticLabel.font = Theme.getInstance().commentTitleStyle.getFont()
        //accountNoStaticLabel.textColor = Theme.getInstance().commentTitleStyle.getTextColor()
        accountNoStaticLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
        
        accountNoLabel.font = Theme.getInstance().walletBankNoNoStyle.getFont()
        accountNoLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
            //Theme.getInstance().walletBankNoNoStyle.getTextColor()
        
        confirmAccountNoStaticLabel.font = Theme.getInstance().commentTitleStyle.getFont()
        confirmAccountNoStaticLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
        //Theme.getInstance().commentTitleStyle.getTextColor()
        
        confirmAccountNoLabel.font = Theme.getInstance().walletBankNoNoStyle.getFont()
        confirmAccountNoLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
        //Theme.getInstance().walletBankNoNoStyle.getTextColor()
        confirmAccountNoLabel.text =  "**** **** ****" + viewModel.selectedBank.last4
        
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
        deleteButton.titleLabel?.font = Theme.getInstance().addAddressButtonStyle.getFont()
    }
    

}
