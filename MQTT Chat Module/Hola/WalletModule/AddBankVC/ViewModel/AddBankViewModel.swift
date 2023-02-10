//
//  AddBankViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import Foundation

class AddBankViewModel{

    //routing - 110000000, currency - usd
    func addBankAccount(accountHolderName:String,routingNumber:String, accountNo: String,success: @escaping (Bool)-> Void){
        ApiHelper.shared.addBankAccountToStripe(accountHolderName: accountHolderName, routingNumber: routingNumber, account_number: accountNo) { (_) in
            success(true)
        }
    }
}
