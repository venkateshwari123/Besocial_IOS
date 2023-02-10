//
//  TransferInfoModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 12/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation

struct TransferInfoModel {

    var fromAmount:String?
    var toAmount:String?
    var messageCreatedDate: Double?
    var description:String?
    var messageId: String
    var transactionId: String
    var transferStatus: TransferStatus
    var noteText: String?
    var receiverImage:String?
    var toUserId:String?
    var fromUserId:String?
    var senderImage:String?
    var receiverUserName:String?
    var senderUserName:String?
    var commissionAmount:String?
    var fromCurrency:String?
    var toCurrency:String?
    var fromCurrencyCode:String?
    var toCurrencyCode:String?
    var receiverFirstName = ""
    var receiverLastName = ""

    
    init(data: [String : Any]) {
        var messageId: String = ""
        var transactionId: String = ""
        var status = TransferStatus(rawValue: 1)
       
        if let date = data["txntimestamp"] as? Double{
            self.messageCreatedDate = date
        }
        
        if let receiverFirstName = data["receiverFirstName"] as? String {
            self.receiverFirstName = receiverFirstName
        }
        if let receiverLastName = data["receiverLastName"] as? String {
            self.receiverLastName = receiverLastName
        }
        if let descrip = data["description"] as? String{
            self.description = descrip
        }
        
        if let amt = data["toAmount"] as? Double{
            self.toAmount = "\(amt)"
        }
        
        if let amt = data["toAmount"] as? String{
            self.toAmount = amt
        }
        
        if let amount = data["fromAmount"] as? String{
            self.fromAmount = amount
        }
        
        if let amount = data["fromAmount"] as? Double{
            self.fromAmount = "\(amount)"
        }
        
        if let id = data["messageId"] as? String{
            messageId = id
        }
        if let id = data["transactionId"] as? String{
            transactionId = id
        }
        if let id = data["transactionId"] as? Double{
            transactionId = "\(Int(id))"
        }
        if let stauts = data["transferStatus"] as? Int{
            status = TransferStatus(rawValue: stauts)
        }
        if let noteMsg = data["notes"] as? String{
            self.noteText = noteMsg
        }
        
        if let receiverImage = data["receiverImage"] as? String{
            self.receiverImage = receiverImage
        }
        
        if let fromUserId = data["fromUserId"] as? String{
            self.fromUserId = fromUserId
        }
        
        if let toUserId = data["toUserId"] as? String{
            self.toUserId = toUserId
        }
        
        if let receiverUserName = data["receiverUserName"] as? String{
            self.receiverUserName = receiverUserName
        }
        
        if let senderUserName = data["senderUserName"] as? String{
            self.senderUserName = senderUserName
        }
        
        if let commissionAmt = data["transferCommission"] as? String{
            self.commissionAmount = commissionAmt
        }
        if let commissionAmt = data["transferCommission"] as? Double{
            self.commissionAmount = "\(commissionAmt)"
        }
        
        if let fromCurrency = data["fromCurrency"] as? String{
            self.fromCurrency = fromCurrency
        }
        
        
        if let toCurrencySymbol = data["toCurrencySymbol"] as? String{
            self.toCurrencyCode = toCurrencySymbol
        }
        
        if let fromCurrencySymbol = data["fromCurrencySymbol"] as? String{
            self.fromCurrencyCode = fromCurrencySymbol
        }
        
        if let toCurrency = data["toCurrency"] as? String{
            self.toCurrency = toCurrency
        }
        
        self.messageId = messageId
        self.transactionId = transactionId
        self.transferStatus = status!
    }
}
