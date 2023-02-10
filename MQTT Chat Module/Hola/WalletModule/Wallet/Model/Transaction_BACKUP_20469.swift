//
//  Transaction.swift
//  Yelo
//
//  Created by Rahul Sharma on 04/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import Foundation

//struct Transaction {
//    var id: String
//    var name: String
//}

struct TransactionDetails:Codable{
    let data:TransactiondetailsData
}

struct TransactiondetailsData:Codable{
    let data:[WalletTransactions]
    let totalCount:String
}

struct WalletTransactions:Codable{
    let walletid:String
    let txntimestamp:String
    let txnid:String
    let amount:String
    let currency:String
    let description:String
    let txntype:Int
}
/*
{
    amount = "100.00";
    closingbal = "100.00";
    currency = USD;
    description = "";
    initiatedby = 5eb1268d23cfc10027a65184;
    notes = "";
    openingbal = "0.00";
    trigger = "wallet recharge";
    txnid = "093226b0-8ec3-11ea-8806-9b89c16b65a4";
    txnlogid = "<null>";
    txntimestamp = "2020-05-05T11:24:51.225Z";
    txntype = 1;
    txntypetext = CREDIT;
    walletid = "1ee9f670-8eac-11ea-8806-9b89c16b65a4";
}*/

/*
 {
            amount = 200;
            approvedby = "";
            approvedon = "<null>";
            autopayout = true;
            bankid = "ba_1Gg4GtJlgNRMlN892S9TIhn9";
            coins = 0;
            commontype = 1;
            createdat = "2020-05-08T12:01:52.265Z";
            currency = usd;
            email = "";
            notes = "for other";
            pgid = manual;
            pgname = bank;
            reason = "";
            status = NEW;
            transferredby = "";
            transferredon = "<null>";
            updatedat = "2020-05-08T12:01:52.265Z";
            userid = 5eb1268d23cfc10027a65184;
            username = "";
            usertype = user;
            withdrawid = "a4ae43bd-5117-4f4f-b1e9-625f20752b9e";
        }
 */

struct Transaction: Codable{
    var amount = ""
    var closingbal = ""
    var currency = ""
    var description = ""
    var initiatedby = ""
    var notes = ""
    var openingbal = ""
    var trigger = ""
    var txnid = ""
    var txnlogid = ""
    var txntimestamp = ""
    var txntype = ""
    var txntypetext = ""
    var walletid = ""
    var approvedby = ""
    var approvedon = ""
    var autopayout = false
    var bankid = ""
    var coins = ""
    var commontype = ""
    var createdate = ""
    var email = ""
    var pgid = ""
    var pgname = ""
    var reason = ""
    var status = ""
    var transferredby = ""
    var transferredon = ""
    var updatedate = ""
    var userid = ""
    var username = ""
    var usertype = ""
    var withdrawid = ""
    var rechargemode = ""
    var currencySymbol = ""
    var receiverImage = ""
    var withdrawalAmount = ""
    var bank = ""
<<<<<<< HEAD
=======
    var fee = ""
    var accountNumber = ""
    var userFrom = ""
    var userTo = ""
    var senderImage = ""
>>>>>>> 9d610039... refactored(Wallet):- Added more transaction details like android
    
    init(data: [String:Any]) {
        if let amount = data["amount"] as? String{
            self.amount = amount
        }
        
        if let withdrawalAmount = data["withdrawalAmount"] as? String{
            self.withdrawalAmount = withdrawalAmount
        }
        
<<<<<<< HEAD
=======
        if let userFrom = data["user_from"] as? String {
            self.userFrom = userFrom
        }
        
        if let userTo = data["user_to"] as? String {
            self.userTo = userTo
        }
        
        if let accountNumber = data["accountNumber"] as? String{
            self.accountNumber = accountNumber
        }
        
>>>>>>> 9d610039... refactored(Wallet):- Added more transaction details like android
        if let currencySymbol = data["currencySymbol"] as? String{
            self.currencySymbol = currencySymbol
        }
        
        if let rechargemode = data["rechargemode"] as? String{
            self.rechargemode = rechargemode
        }
        if let receiverImage = data["receiverImage"] as? String{
            self.receiverImage = receiverImage
        }
        if let receiverImage = data["receiverimage"] as? String{
            self.receiverImage = receiverImage
        }
        if let senderImage = data["senderimage"] as? String{
            self.senderImage = senderImage
        }
        if let senderImage = data["senderImage"] as? String{
            self.senderImage = senderImage
        }
        
        if let amount = data["amount"] as? Int{
            self.amount = String(amount)
        }
        if let amount = data["amount"] as? Double{
            self.amount = String(amount)
        }
        
        
        if let closingbal = data["closingbal"] as? String{
            self.closingbal = closingbal
        }
        
        if let currency = data["currency"] as? String{
            self.currency = currency
        }
        
        if let description = data["description"] as? String{
            self.description = description
        }
        
        if let initiatedby = data["initiatedby"] as? String{
            self.initiatedby = initiatedby
        }
        
        if let notes = data["notes"] as? String{
            self.notes = notes
        }
        
        if let openingbal = data["openingbal"] as? String{
            self.openingbal = openingbal
        }
        
        if let trigger = data["trigger"] as? String{
            self.trigger = trigger
        }
        
        if let txnid = data["txnid"] as? String{
            self.txnid = txnid
        }
        
        if let txnId = data["txnId"] as? String{
            self.txnid = txnId
        }
        
        if let txnlogid = data["txnlogid"] as? String{
            self.txnlogid = txnlogid
        }
        
        if let txntimestamp = data["txntimestamp"] as? String{
            self.txntimestamp = txntimestamp
        }
        
        if let txnTimestamp = data["txnTimestamp"] as? Double{
            self.txntimestamp = String(txnTimestamp)
            let date = txnTimestamp.getDateStringFromUnixTime(dateStyle: .medium, timeStyle: .medium)
            self.txntimestamp = date.timeAgoSinceDate()
        }
        
        if let txntype = data["txntype"] as? Int{
            self.txntype = String(txntype)
        }
        
        if let txntypetext = data["txntypetext"] as? String{
            self.txntypetext = txntypetext
        }
        
        if let walletid = data["walletid"] as? String{
            self.walletid = walletid
        }
        
        if let approvedby = data["approvedby"] as? String{
            self.approvedby = approvedby
        }
        
        if let approvedon = data["approvedon"] as? String{
            self.approvedon = approvedon
        }
        
        if let autopayout = data["autopayout"] as? Bool{
            self.autopayout = autopayout
        }
        
        if let bankid = data["bankid"] as? String{
            self.bankid = bankid
        }
        
        if let bankId = data["bankId"] as? String{
            self.bankid = bankId
        }
        if let bank = data["bank"] as? String{
            self.bank = bank
        }
        
        if let coins = data["coins"] as? String{
            self.coins = coins
        }
        
        if let commontype = data["commontype"] as? String {
            self.commontype = commontype
        }
        
        if let createdat = data["createdat"] as? String{
            self.createdate = createdat
        }
        
        if let email = data["email"] as? String{
            self.email = email
        }
        
        if let pgid = data["pgid"] as? String {
            self.pgid = pgid
        }
        
        if let pgname = data["pgname"] as? String{
            self.pgname = pgname
        }
        
        if let pgName = data["pgName"] as? String{
            self.pgname = pgName
        }
        
        if let reason = data["reason"] as? String{
            self.reason = reason
        }
        
        if let status = data["status"] as? String{
            self.status = status
        }
        
        if let transferredby = data["transferredby"] as? String{
            self.transferredby = transferredby
        }
        
        if let transferredon = data["transferredon"] as? String{
            self.transferredon = transferredon
        }
        
        if let updatedat = data["updatedat"] as? String{
            self.updatedate = updatedat
        }
        
        if let userid = data["userid"] as? String{
            self.userid = userid
        }
        
        
        if let username = data["username"] as? String{
            self.username = username
        }
        if let usertype = data["usertype"] as? String{
            self.usertype = usertype
        }
        
        if let withdrawid = data["withdrawid"] as? String{
            self.withdrawid = withdrawid
        }
    }
}
