//
//  RechargeViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 07/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class RechargeViewModel {
    
    var selectedCard: Card!
    var transaction: Transaction!
    var pgLinkId = "60b0d342c105831daaea3be1"
    func rechargeWallet(amount: String, success: @escaping (Bool)->Void){
        
        var params = [String: Any]()
        params["currency"] = Utility.getWalletCurreny() // Utility.getCurreny() for dynamic // temp static
        params["amount"] = amount
        params["pgLinkId"] = self.pgLinkId
//        params["capture"] = false
        params["paymentMethod"] = selectedCard.id ?? ""
        params["type"] =  "1" // 1 card, 2 apple pay
        params["postal_code"] = "30025" // temp static
        ApiHelper.shared.rechargeWallet(params: params) { details in
            self.transaction = details
            ApiHelper.shared.getWallet(userId: Utility.getUserid() ?? "") {  _  in
                
            }
            if details != nil{
                 success(true)
            }else{
                success(false)
            }
        }
    }
}
