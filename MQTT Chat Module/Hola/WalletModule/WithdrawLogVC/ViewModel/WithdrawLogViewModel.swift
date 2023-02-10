//
//  WithdrawLogViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 09/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class WithdrawLogViewModel{
    var transactionsArray = [Transaction]()
    var isWithdrawLogApiCalled = false //used for show empty placeholder
    var pageState = ""
    var index = 0
    var limit = 20
    
    func getWithdrawLogs(success:@escaping ()->()){
        ApiHelper.shared.getWithdrawLogs(pageState: pageState, fetchSize: String(limit)) { transactions,pageState in
            self.isWithdrawLogApiCalled = true
            if self.index == 0 {
                self.transactionsArray.removeAll()
            }
            for txn in transactions{
                self.transactionsArray.append(txn)
            }
            self.pageState = pageState
            success()
        }
    }
}
