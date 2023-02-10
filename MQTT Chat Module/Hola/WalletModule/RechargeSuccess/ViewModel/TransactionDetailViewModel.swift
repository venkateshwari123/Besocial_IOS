//
//  RechargeSuccessViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 04/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class TransactionDetailViewModel{
    
    enum transactionType {
        case productTransactionScreen
        case rechargeOrWithdrawlTransactionSuccess
    }
    
    enum successType {
        case recharge
        case withdrawl
    }
    
    var selectedTransactionType = transactionType.productTransactionScreen
    var selectedSuccessType = successType.recharge
    var transaction : Transaction!
    var needToCallApi = false
    var pushedFromTableViewCell = false
    
    func getWithdrawDetails(success: @escaping (Bool)->Void){
        ApiHelper.shared.getWithdrawDetails(withdrawId: transaction.walletid) { (resp) in
            print(resp)
        }
    }
}
