//
//  CoinWalletModel.swift
//  Do Chat
//
//  Created by 3Embed on 05/11/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation


enum TransType: String {
    case All = "0"
    case Out = "1"
    case In = "2"
}

class CoinWalletModel: NSObject {
    
    var amount:String?
    var bank:String?
      var closingbal : String?
      var currency : String?
      var currencySymbol : String?
      var currency_symbol : String?
      var descc : String?
      var doc_type : String?
      var initiatedby : String?
      var notes : String?
      var openingbal : String?
      var receiverImage : String?
      var receiverimage : String?
      var rechargemode : String?
      var senderImage : String?
      var senderimage : String?
      var timestamp : String?
      var trigger : String?
      var txn_fee : String?
      var txnid : String?
      var txnlogid : String?
      var txntimestamp : String?
      var txntype : Int?
      var txntypetext : String?
      var user_from : String?
      var user_to : String?
      var walletid : String?
      var postId:String?
    
    
    override init(){
    }
    
    init(modelData: [String : Any]){
        
        if let amount = modelData["amount"] as? String{
            self.amount = amount
        }
        
        if let amount = modelData["amount"] as? Double{
            self.amount = "\(amount)"
        }
        
        if let bank = modelData["bank"] as? String{
            self.bank = bank
        }
        if let closingbal = modelData["closingbal"] as? String{
            self.closingbal = closingbal
        }
        if let currency = modelData["currency"] as? String{
            self.currency = currency
        }
        if let currencySymbol = modelData["currencySymbol"] as? String{
            self.currencySymbol = currencySymbol
        }
        if let currency_symbol = modelData["currency_symbol"] as? String{
            self.currency_symbol = currency_symbol
        }
        
        if let posId = modelData["postid"] as? String{
            self.postId = posId
        }
        if let descc = modelData["description"] as? String{
            self.descc = descc
        }

        if let doc_type = modelData["doc_type"] as? String{
            self.doc_type = doc_type
        }
        if let initiatedby = modelData["initiatedby"] as? String{
            self.initiatedby = initiatedby
        }
        if let notes = modelData["notes"] as? String{
            self.notes = notes
        }
        if let openingbal = modelData["openingbal"] as? String{
            self.openingbal = openingbal
        }
        if let receiverImage = modelData["receiverImage"] as? String{
            self.receiverImage = receiverImage
        }
        if let receiverimage = modelData["receiverimage"] as? String{
            self.receiverimage = receiverimage
        }
        if let rechargemode = modelData["rechargemode"] as? String{
            self.rechargemode = rechargemode
        }
        if let senderImage = modelData["senderImage"] as? String{
            self.senderImage = senderImage
        }
        if let senderimage = modelData["senderimage"] as? String{
            self.senderimage = senderimage
        }
        if let timestamp = modelData["timestamp"] as? String{
            self.timestamp = timestamp
        }
        if let trigger = modelData["trigger"] as? String{
            self.trigger = trigger
        }
        if let txn_fee = modelData["txn_fee"] as? String{
            self.txn_fee = txn_fee
        }
        if let txnid = modelData["txnid"] as? String{
            self.txnid = txnid
        }
        if let txnlogid = modelData["txnlogid"] as? String{
            self.txnlogid = txnlogid
        }
        if let txntimestamp = modelData["txntimestamp"] as? String{
            self.txntimestamp = txntimestamp
        }
        if let txntype = modelData["txntype"] as? Int{
            self.txntype = txntype
        }
        if let txntypetext = modelData["txntypetext"] as? String{
            self.txntypetext = txntypetext
        }
        if let user_from = modelData["user_from"] as? String{
            self.user_from = user_from
        }
        if let user_to = modelData["user_to"] as? String{
            self.user_to = user_to
        }
        if let walletid = modelData["walletid"] as? String{
            self.walletid = walletid
        }
    }
    
}
