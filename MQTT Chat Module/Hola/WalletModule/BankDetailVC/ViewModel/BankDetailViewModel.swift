//
//  BankDetailViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 11/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class BankDetailViewModel{
    
    var selectedBank: Bank!
    
    func deleteBank(success: @escaping ()->()){
        ApiHelper.shared.deleteBank(bankId: selectedBank.id) { res in
            if res{
               success()
            }
        }
    }
    
}
