//
//  ViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 03/06/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class TransactionStatusViewModel {
    
    var withdrawID = ""
    var isWithdrawApiCalled = false
    var transactionDetails: Transaction!
    var transactionTitle = ["Pending","Approved","Payment Initiated","Payment Completed"]
    var isFailed = false
    let failedStatus = ["REJECTED","FAILED","CANCELLED"]
    
    func getWithdrawDetails(success: @escaping (Bool)->Void ) {
        ApiHelper.shared.getWithdrawDetails(withdrawId: withdrawID) { (transaction) in
            self.transactionDetails = transaction
            
            if self.failedStatus.contains(transaction.status.uppercased()){
                self.isFailed = true
            }
            self.isWithdrawApiCalled = true
            success(true)
        }
    }
}
