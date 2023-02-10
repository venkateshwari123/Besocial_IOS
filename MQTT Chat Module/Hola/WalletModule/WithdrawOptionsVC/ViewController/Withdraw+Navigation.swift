//
//  Withdraw+Navigation.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

//MARK:- Navigation
extension WithdrawOptionsViewController{
    
    func navigateToBankListVC(){
            guard let bankListVC = UIStoryboard(name: "BankList", bundle: nil).instantiateViewController(withIdentifier: "BankListViewController") as? BankListViewController else {return}
            bankListVC.delegate = self
            bankListVC.viewModel.tempPGId = viewModel.withdrawOptions.first?.id ?? "" // temp
            navigationController?.pushViewController(bankListVC, animated: true)
        }
    
    func navigateToWithdrawLogs(){
        guard let withdtrawLogsVC = UIStoryboard(name: "WithdrawLog", bundle: nil).instantiateViewController(withIdentifier: "WithdrawLogsViewController") as? WithdrawLogsViewController else {return}
        navigationController?.pushViewController(withdtrawLogsVC, animated: true)
    }
}

extension WithdrawOptionsViewController: BankListViewControllerDelegate{
    func withdrawSuccess() {
        delegate?.withdrawSuccess()
    }
}
