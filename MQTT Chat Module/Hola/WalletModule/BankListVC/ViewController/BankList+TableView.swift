//
//  BankList+TableView.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

//MARK:- UITableViewDelegate, UITableViewDataSource
extension BankListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = nil
        if viewModel.getBankAccountApiCalled  && viewModel.bankArray.count == 0{
            setTableViewOrCollectionViewBackground(tableView: tableView, collectionView: nil, image: #imageLiteral(resourceName: "NoBankAccount"), labelText: "No Bank Account", labelWithImage: true, yPosition: self.view.center.y - 200)
        }
                
        return viewModel.bankArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BankListTableViewCell", for: indexPath) as? BankListTableViewCell else {return UITableViewCell()}
        let tempBank = viewModel.bankArray[indexPath.row]
        cell.configureCell(bank: tempBank, isSelectd: viewModel.selectedBank.id == tempBank.id)
        cell.detailButton.addTarget(self, action: #selector(navigateToBankDetailVC(sender:)), for: .touchUpInside)
        cell.detailButton.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedBank = viewModel.bankArray[indexPath.row]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    @objc func navigateToBankDetailVC(sender:UIButton){
        let selectedBank = viewModel.bankArray[sender.tag]
        if let bankDetailVC = UIStoryboard(name: "BankDetail", bundle: nil).instantiateViewController(withIdentifier: "BankDetailViewController") as? BankDetailViewController {
            bankDetailVC.viewModel.selectedBank = selectedBank
            bankDetailVC.delegate = self
            self.navigationController?.pushViewController(bankDetailVC, animated: true)
        }
    }
}



