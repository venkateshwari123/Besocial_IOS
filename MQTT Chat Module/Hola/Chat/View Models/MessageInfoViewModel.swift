//
//  MessageInfoViewModel.swift
//  Infra.Market Messenger
//
//  Created by 3Embed Software Tech Pvt Ltd on 30/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire

class MessageInfoViewModel: NSObject{
    
    var deliverdToArr = [MessageDeliveryStatus]()
    var readByArr = [MessageDeliveryStatus]()
    var isApiDone: Bool = false
    var totalMember: Int = 1
    
    func getMessageDetails(message: Message, chatId: String, onComplication: @escaping (Bool, Error?) -> Void){
        
//        let strUrl = AppConstants.GroupMessageStatus + "/\(chatId)/" + "Message" + "/\(message.messageId)/" + "Status"
        let strUrl = AppConstants.GroupMessageStatus + "/Message/Status" + "?chatId=\(chatId)&messageId=\(message.messageId)"
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headerParams = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strUrl, requestType: .get, parameters: nil,headerParams:HTTPHeaders.init(headerParams), responseType: AppConstants.resposeType.groupMessageStatus.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.groupMessageStatus.rawValue {
                    print(dict)
                    print(dict["code"])
                    guard  let data = dict["data"] as? [String:Any] else {return}
                    guard let delArr = data["deliveredTo"] as? [[String : Any]] else{return}
                    guard let readArr = data["readBy"] as? [[String : Any]] else {return}
                    self.deliverdToArr = delArr.map{ MessageDeliveryStatus(modelData: $0)}
                    self.readByArr = readArr.map{MessageDeliveryStatus(modelData: $0)}
                    self.isApiDone = true
                    onComplication(true, nil)
                }
            }, onError: {error in
                Helper.hidePI()
                onComplication(false, error)
            })
    }
    
    
    /// To get number of row for gorup message status
    ///
    /// - Returns: number fo rows 0 if api is not done
    func numberOfRowInGroupMessageStatus() -> Int{
        if self.isApiDone{
            if self.deliverdToArr.count > 0 && self.readByArr.count > 0{
                return 3
            }else{
                return 2
            }
        }else{
            return 0
        }
    }
    
    
    func getDataToAssignInCell(index: Int) ->([MessageDeliveryStatus], Bool, Int){
        switch index {
        case 1:
            if self.readByArr.count > 0{
                let remaining = self.totalMember - self.readByArr.count - 1
                return (self.readByArr, true, remaining)
            }else{
                let remaining = self.totalMember - self.deliverdToArr.count - self.readByArr.count - 1
                return (self.deliverdToArr, false, remaining)
            }
        case 2:
            let remaining = self.totalMember - self.deliverdToArr.count - self.readByArr.count - 1
            return (self.deliverdToArr, false, remaining)
        default:
            return (self.deliverdToArr, false, 0)
        }
    }
    
    /// To get height of the row
    ///
    /// - Parameter index: inde of the row
    /// - Returns: height of the row
    func heightOfRowAtIndex(index: Int) ->CGFloat{
        switch index {
        case 1:
            if self.readByArr.count > 0{
                return CGFloat(self.readByArr.count * 80 + 50 + 40)
            }else{
                return CGFloat(self.deliverdToArr.count * 80 + 50 + 40)
            }
        case 2:
            return CGFloat(self.deliverdToArr.count * 80 + 50 + 40)
        default:
            return 100.0
        }
    }
}
