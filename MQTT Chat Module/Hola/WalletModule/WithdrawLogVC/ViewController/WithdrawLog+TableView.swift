//
//  WithdrawLog+TableView.swift
//  Yelo
//
//  Created by Rahul Sharma on 09/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

extension WithdrawLogsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isWithdrawLogApiCalled{
            if viewModel.transactionsArray.count > 0 {
                tableView.backgroundView = nil
            }else{
                setTableViewOrCollectionViewBackground(tableView: tableView, collectionView: nil, image: #imageLiteral(resourceName: "transaction"), labelText: "No transactions yet".localized, labelWithImage: true, yPosition: self.view.center.y)
            }
        }
        
        return viewModel.transactionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WithdrawLogTableViewCell", for: indexPath) as? WithdrawLogTableViewCell else {return UITableViewCell()}
        cell.configureCell(txn: viewModel.transactionsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let TransactionStatusVC = UIStoryboard(name: "TransactionStatus", bundle: nil).instantiateViewController(withIdentifier: "TransactionStatusViewController") as? TransactionStatusViewController else { return }
            TransactionStatusVC.viewModel.withdrawID = viewModel.transactionsArray[indexPath.row].withdrawid
            self.navigationController?.pushViewController(TransactionStatusVC, animated: true)
        }
}
