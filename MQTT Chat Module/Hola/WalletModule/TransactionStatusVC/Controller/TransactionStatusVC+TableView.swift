//
//  TransactionStatusVC+TableView.swift
//  Yelo
//
//  Created by Rahul Sharma on 03/06/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

extension TransactionStatusViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !viewModel.isWithdrawApiCalled {return 0}
        return viewModel.transactionDetails.historyTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionStatusTableViewCell", for: indexPath) as? TransactionStatusTableViewCell else { return UITableViewCell() }
        
        cell.configure(title:viewModel.transactionDetails.historyTitles[indexPath.row], value: viewModel.transactionDetails.historyTitleValues[indexPath.row])
        return cell
    }
}
