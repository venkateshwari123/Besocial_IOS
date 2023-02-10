//
//  PaymentMethodViewModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 26/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//


import UIKit

enum PaymentTypes:String{
    case wallet = "Wallet"
    case card = "Card"
    case cod = "Pay On Delivery"
}

class PaymentMethodVM: NSObject {

    static var callGetCard:Bool = false
    

    func getPaymentTypes()->[PaymentTypes]{
        return [.wallet,.card,.cod]
    }
}

 
