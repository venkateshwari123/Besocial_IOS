//
//  WithdrawMoneyViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 08/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import Foundation

class WithdrawMoneyViewModel{
    
    var selectedBank: Bank!
    var estimatedAmount = ""
    var transaction: Transaction!
    var paymentGateWayId = ""
    var withDrawDetails:WithdrawAmountDetails!
    var tempPGId = ""
    var userType = ""
    var userId = Utility.getUserid()
    var withDrawCurrency = Utility.getWalletCurreny()
    
    func getEstimateAmount(fromCurrency: String,toCurrency: String, amount: String,success: @escaping ()->Void){
        var params = [String:Any]()
        params["fromCurrency"] = fromCurrency
        params["toCurrency"] = toCurrency
        params["amount"] = amount
        
        ApiHelper.shared.getEstimateAmount(params: params) { (amount) in
            self.estimatedAmount = amount
            success()
        }
    }
    
    func withdrawMoney(amount: String, success: @escaping ()->()){
        /*
         Bug Name:- Withdraw not working
         Fix Date:- 24/05/21
         Fix By  :- Jayaram G
         Description of Fix:- Added required fields
         */
        var params = [String:Any]()
        params["pgId"] =  tempPGId// "manual"  staitc
        params["bankId"] = paymentGateWayId
        params["amount"] = amount//self.withDrawDetails.totalAmount
        params["pgName"] = "Stripe" //temp Static.
        params["autoPayout"] = true // temp Static
        params["walletId"] = KeychainHelper.sharedInstance.getWalletId()
        params["withdrawAmount"] = self.withDrawDetails.withdrawAmount
//        params["withdrawCurrency"] = self.withDrawCurrency
        params["userId"] = self.userId
        params["userType"] = "user"
        params["currency"] = "INR"
        
        ApiHelper.shared.withdrawMoney(params: params) { (details) in
            self.transaction = details
            ApiHelper.shared.getWallet(userId: Utility.getUserid() ?? "") { _ in
             //   self.estimatedAmount = amount
            }
            success()
        }
    }
    
    
    func withdrawAmount(amount: String,success: @escaping ()->()){
        /*
         Bug Name:- Withdraw not working
         Fix Date:- 24/05/21
         Fix By  :- Jayaram G
         Description of Fix:- Added required fields
         */
        var params = [String:String]()
        params["walletId"] = KeychainHelper.sharedInstance.getWalletId()
        params["withdrawCurrency"] = self.withDrawCurrency
        params["type"] = "1"
        params["amount"] = amount
        ApiHelper.shared.withDrawAmount(params: params, success: { (details) in
            self.withDrawDetails = details
            success()
        })
    }
    
    
}
