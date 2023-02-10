//
//  BankListViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import Foundation

class BankListViewModel{
    
    var getBankAccountApiCalled = false
    var isStripAccountVerified :Bool {
        return stripeStatusText.lowercased() == "verified".localized
    }
    var stripeStatusText = ""
    var bankArray = [Bank]()
    var selectedBank = Bank(data: [:])
    var paymentGateWayId = ""
    
    var tempPGId = ""
    
    //get all linked account from stripe
    func getBankAccountFromStripe(success: @escaping ()->Void){
        ApiHelper.shared.getStripeConnectAccount { id,verificationStatus,banks  in
            self.paymentGateWayId = id
            self.getBankAccountApiCalled = true
            self.bankArray = banks
            if let firstBank = banks.first{
              self.selectedBank = firstBank
            }
            self.stripeStatusText = verificationStatus
            success()
        }
    }
}
