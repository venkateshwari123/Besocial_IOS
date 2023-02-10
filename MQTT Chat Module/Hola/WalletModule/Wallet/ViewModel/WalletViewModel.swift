//
//  WalletViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 24/04/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class WalletViewModel {

//    let rows = [["top"],["row1","row2","row3","row4","row5",]]
    var iswalletApiCalled = false
    enum type {
        case All
        case Pending
        case Debit
        case Credit
        
        var title : String {
            switch self {
            case .All:
                return "All Transactions".localized
            case .Pending:
                return "Pending Transactions".localized
            case .Debit:
                return "Debit Transactions".localized
            case .Credit:
                return "Credit Transactions".localized
            }
        }
    }
    
    var types = [type.All,type.Pending,type.Debit,type.Credit]
    var selectedType = type.All
    var transactionsArray = [Transaction]()
    var index = 0
    var limit = 20
    var pageState = ""
    var stripeAccountVerified = false
    
    //txn type 1-CREDIT,2-DEBIT,0-ALL
    func getTransaction(success: @escaping (Bool) -> Void ){
        
        var txnType = 0
        switch self.selectedType {
        case .All: txnType = 0
        case .Credit: txnType = 1
        case .Debit: txnType = 2
        case .Pending: txnType = 3
        }
        self.iswalletApiCalled = false
        ApiHelper.shared.geTransactions(walletId: KeychainHelper.sharedInstance.getWalletId(),txnType: String(txnType), pageState: pageState, fetchSize: String(limit), success: {  txn,pageState in
            self.iswalletApiCalled = true
            self.pageState = pageState
            if self.index == 0 {
                self.transactionsArray.removeAll()
            }
            for transaction in txn{
                self.transactionsArray.append(transaction)
            }
             success(true)
        })
    }
    
    func getWalletDetails(){
        ApiHelper.shared.getWallet(userId: Utility.getUserid() ?? "") { _ in
            
        }
    }
    
//    func getConnectAccount(){
//        ApiHelper.shared.getStripeConnectAccount { success,banks  in
//            self.stripeAccountVerified = success
//        }
//    }
}
