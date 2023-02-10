//
//  ConfirmPaymentViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 10/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation

class ConfirmPaymentViewModel{
    
    let ConfirmPaymentApi = SocialAPI()
    var tansferDetails: TransferValidateModel?
//    var receiverId: String!
//    var note: String?
//    var amount: String!
    var transactionDetails: Transaction!
    
    /// To make transfer service call
    ///
    /// - Parameters:
    ///   - receiverId: receiver id
    ///   - note: note of transfer money
    ///   - amount: amount of transfer money
    ///   - complication: complication handler
    func makePaymentServiceCall(receiverImage:String,receiverName:String,receiverId: String, note: String?, amount: String,receiverCurrency:String, complication: @escaping(Bool, CustomErrorStruct?)->Void){
        var senderImage = ""
        if let userImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String{
                   senderImage = userImage
               }
        let strUrl = AppConstants.transferMoney
        let reason = note != nil ? note! : ""
        var params = ["fromUserName":Utility.getUserName(),
                      "fromUserId":Utility.getUserid() ?? "",
        "fromUserType":"user",
        "toUserName":receiverName,
        "toUserId":receiverId,
        "toUserType":"user",
        "fromCurrency":Utility.getWalletCurreny(),
        "toCurrency":receiverCurrency,
        "amount":amount,
        "notes": note ?? ""] as [String : Any]
        
        if !senderImage.isEmpty {
            params["senderImage"] = senderImage
        }
        if !receiverImage.isEmpty {
            params["receiverImage"] = receiverImage
        }
        ConfirmPaymentApi.postSocialDataForIan(with: strUrl, params: params) { (respones, error) in
            if error == nil {
                if let responseData = respones as? [String:Any] {
                    if let data = responseData["data"] as? [String:Any] {
                        self.transactionDetails = Transaction(data: data)
                    }
                }
                complication(true, nil)
            }else{
                complication(false, error)
            }
        }
    }
    
    
    /// To make transfer service call
    ///
    /// - Parameters:
    ///   - receiverId: receiver id
    ///   - note: note of transfer money
    ///   - amount: amount of transfer money
    ///   - complication: complication handler
    func transferValidateServiceCall(params: [String:Any], complication: @escaping(Bool, CustomErrorStruct?)->Void){
        let strUrl = AppConstants.transferValidate
        ConfirmPaymentApi.postSocialDataForIan(with: strUrl, params: params) { (respones, error) in
            if error == nil {
                if let responseData = respones as? [String:Any] {
                    if let data = responseData["data"] as? [String:Any] {
                        guard let tranferInfo = TransferValidateModel(data: data) as? TransferValidateModel else {return}
                        self.tansferDetails = tranferInfo
                    }
                    complication(true, nil)
                }
            }else{
                complication(false, error)
            }
        }
    }
    

    
    
}

class TransferValidateModel {
    
    
    var appCommission = 0.0
    var finalAmount = 0.0
    var totalAmount = 0.0
    
    init(data: [String: Any]){
        if let appCommision = data["AppCommission"] as? Double {
            self.appCommission = appCommision
        }
        if let finalAmount = data["FinalAmount"] as? Double {
            self.finalAmount = finalAmount
        }
        if let totalAmount = data["TotalAmount"] as? Double {
            self.totalAmount = totalAmount
        }
        
        if let appCommision = data["AppCommission"] as? Int {
            self.appCommission = Double(appCommision)
        }
        if let finalAmount = data["FinalAmount"] as? Int {
            self.finalAmount = Double(finalAmount)
        }
        if let totalAmount = data["TotalAmount"] as? Int {
            self.totalAmount = Double(totalAmount)
        }
        
    }
}
