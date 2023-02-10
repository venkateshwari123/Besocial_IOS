//
//  BankList+Navigation.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit


//MARK:- Navigation
extension BankListViewController{
    func navigateToAddBankVC(){
        if let addBankVC = UIStoryboard(name: "AddBank", bundle: nil).instantiateViewController(withIdentifier: "AddBankViewController") as? AddBankViewController{
            addBankVC.delegate = self
            self.navigationController?.pushViewController(addBankVC, animated: true)
        }
    }
    
    
    func navigateToConnectStripeVC(){
       if let stripeSignUpVC = UIStoryboard(name: "StripeSignUp", bundle: nil).instantiateViewController(withIdentifier: "StripeSignUpViewController") as? StripeSignUpViewController{
            stripeSignUpVC.delegate = self
            self.navigationController?.pushViewController(stripeSignUpVC, animated: true)
        }
    }
    
    
    func navigateToWithdrawMoneyVC(){
               guard let withdrawMoneyVC = UIStoryboard(name: "WithdrawMoney", bundle: nil).instantiateViewController(withIdentifier: "WithdrawMoneyViewController") as? WithdrawMoneyViewController else {return}
            withdrawMoneyVC.viewModel.selectedBank = viewModel.selectedBank
            withdrawMoneyVC.delegate = self
            withdrawMoneyVC.viewModel.tempPGId = viewModel.tempPGId
            withdrawMoneyVC.viewModel.paymentGateWayId = viewModel.paymentGateWayId
               navigationController?.pushViewController(withdrawMoneyVC, animated: true)
           }}

extension BankListViewController: WithdrawMoneyViewControllerDelegate{
    func withdrawSuccess() {
        self.delegate?.withdrawSuccess()
    }
}
