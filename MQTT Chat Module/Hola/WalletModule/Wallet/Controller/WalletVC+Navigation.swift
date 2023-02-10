//
//  WalletVC+Navigation.swift
//  Yelo
//
//  Created by Rahul Sharma on 03/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

//MARK:- navigation
extension WalletViewController{
    
    
    func navigateToRechargeVC(){
        if let rechargeVC = UIStoryboard(name: "Recharge", bundle: nil).instantiateViewController(withIdentifier: "RechargeViewController") as? RechargeViewController{
            self.navigationController?.pushViewController(rechargeVC, animated: true)
        }
    }
    
    func navigateToStripeSignUp(){
        if let rechargeVC = UIStoryboard(name: "StripeSignUp", bundle: nil).instantiateViewController(withIdentifier: "StripeSignUpViewController") as? StripeSignUpViewController{
            self.navigationController?.pushViewController(rechargeVC, animated: true)
        }
    }
    
    func navigateToCardVC(){
        if let cardVC = UIStoryboard(name: "Cards", bundle: nil).instantiateViewController(withIdentifier: "CardsViewController") as? CardsViewController{
            cardVC.delegate = self
            self.navigationController?.pushViewController(cardVC, animated: true)
        }
    }
    
    func showTransactionTypeSelectionVC(){
        guard let walletAlertVC = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "WalletAlertViewController") as? WalletAlertViewController else {return}
        walletAlertVC.modalPresentationStyle = .overCurrentContext
//        walletAlertVC.modalTransitionStyle = .crossDissolve
        walletAlertVC.alertVM.typeName = viewModel.types
        walletAlertVC.alertVM.selectedType = viewModel.selectedType.title
        walletAlertVC.delegate = self
        self.present(walletAlertVC, animated: true)
    }
    
    func navigateToWithdrawOptionsVC(){
        /*
         Bug Name:- KYC not submitting
         Fix Date:- 24/05/21
         Fix By  :- Jayaram G
         Description of Fix:- Handled navigations according to verification status
         */
        if socialViewModel.getStatus() == 0 {
            print("verification status is 0")
            print("verification status is different")
            let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.WalletKyc, bundle: nil)
            guard let resultViewController = storyBoard.instantiateViewController(withIdentifier: "WalletactivatedViewController") as? WalletActivatedViewController else {return}
            resultViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(resultViewController, animated: true)
        } else if socialViewModel.getStatus() == 1 {
            guard let withdrawVC = UIStoryboard(name: "WithdrawOptions", bundle: nil).instantiateViewController(withIdentifier: "WithdrawOptionsViewController") as? WithdrawOptionsViewController else {return}
            withdrawVC.delegate = self
            navigationController?.pushViewController(withdrawVC, animated: true)
        } else {
            let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.WalletKyc, bundle: nil)
            guard let kycVC = storyBoard.instantiateViewController(withIdentifier: String(describing: CompleteIdentificationViewController.self)) as? CompleteIdentificationViewController else {return}
            kycVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(kycVC, animated: true)
        }
        
    }
}
 
extension WalletViewController: CardsViewControllerDelegate, WithdrawOptionsViewControllerDelegate{
    
    func rechargeSuccess() {
        viewModel.index = 0
        viewModel.pageState = ""
        viewModel.getWalletDetails()
        viewModel.getTransaction { _ in
            self.tableview.reloadData()
        }
    }
    
    func withdrawSuccess() {
        viewModel.index = 0
        viewModel.pageState = ""
        viewModel.getWalletDetails()
        viewModel.getTransaction { _ in
            self.tableview.reloadData()
        }
    }
}
