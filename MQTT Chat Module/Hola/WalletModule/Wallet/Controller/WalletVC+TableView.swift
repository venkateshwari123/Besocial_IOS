//
//  WalletVC+TableView.swift
//  Yelo
//
//  Created by Rahul Sharma on 24/04/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

extension WalletViewController: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }
        else{
            if viewModel.iswalletApiCalled{
                if viewModel.transactionsArray.count > 0{
                    tableView.backgroundView = nil
                }
                else{
                    setTableViewOrCollectionViewBackground(tableView: tableView, collectionView: nil, image: #imageLiteral(resourceName: "transaction"), labelText: "", labelWithImage: true, yPosition: self.view.center.y)
                }
            }
            return viewModel.transactionsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceTVCell", for: indexPath) as? BalanceTVCell else {return UITableViewCell()}
            cell.delegate = self
            cell.configureCell()
            return cell
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTVCell", for: indexPath) as? TransactionTVCell else {return UITableViewCell()}
            cell.configutreCell(transaction: viewModel.transactionsArray[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            guard let detailsVC = UIStoryboard(name: "RechargeSuccess", bundle: nil).instantiateViewController(withIdentifier: "RechargeSuccessViewController") as? TransactionDetailViewController else { return }
            if viewModel.transactionsArray[indexPath.row].trigger == "Transfer"{
                detailsVC.viewModel.selectedTransactionType = .rechargeOrWithdrawlTransactionSuccess
                detailsVC.viewModel.transaction = viewModel.transactionsArray[indexPath.row]
                detailsVC.viewModel.pushedFromTableViewCell = true
                detailsVC.viewModel.selectedSuccessType = .recharge
            }
            else{
                detailsVC.viewModel.transaction = viewModel.transactionsArray[indexPath.row]
                detailsVC.viewModel.selectedTransactionType = .productTransactionScreen
                detailsVC.viewModel.pushedFromTableViewCell = true
                detailsVC.viewModel.selectedSuccessType = .withdrawl
            }
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTVCell") as? HeaderTVCell else { return nil }
            cell.configureCell(title: viewModel.selectedType.title)
            cell.delegate = self
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1{
            return 47.5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        
        //      indexPath.row == products.count - 3 && products.count > (limit * index) + (limit - 1 ) {
        let limitIndexMultiplier = viewModel.limit * viewModel.index
        let limitMinusOne = viewModel.limit - 1
        if indexPath.row == viewModel.transactionsArray.count - 2{
            if viewModel.transactionsArray.count > (limitIndexMultiplier + limitMinusOne){
                viewModel.index += 1
                viewModel.getTransaction { _ in
                    self.tableview.reloadData()
                }
            }
        }
    }
}
