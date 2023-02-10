//
//  WithdrawViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class WithdrawViewModel{

    var page = 0
    var limit = 20
    var withdrawOptions = [WithdrawOption]()
    var firstPGId = ""
    var pgLinkId = ""
    
    func getPaymentMethods(success: @escaping ()->()){
//        let countryCode = UserDefaultConstants.getInstance().getCurrentCountryCode()
        let countryCode = Utility.getWalletCurrenyName() //"US" //For Static Utility.getWalletCurrenyName()
        ApiHelper.shared.getWithdrowMethods(countryCode: countryCode, offset: String(page), limit: String(limit)){ withdrawOptions in
            if self.page == 1 {
                self.withdrawOptions.removeAll()
            }
            for option in withdrawOptions{
                self.withdrawOptions.append(option)
            }
            self.pgLinkId = withdrawOptions.first?._id ?? ""
            self.firstPGId = withdrawOptions.first?.id ?? ""
            success()
        }
    }
    
}
