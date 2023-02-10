//
//  MessageAPI.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 08/01/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation
import Locksmith
import Alamofire

class MessageAPI : NSObject {
    
    func getMessages(withUrl messageUrl : String, param: [String : Any]) {
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        if token.count>1 {
            let headerParams = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": "en"]
            AFWrapper.requestGETURL(serviceName: messageUrl, params: param, withHeader: HTTPHeaders.init(headerParams),
                                    success: { (response) in
                                        guard let responseData = response.dictionaryObject else { return }
                                        print("Response",responseData)
            },
                                    failure: { (customErrorStruct) in
                                        print(Strings.error,customErrorStruct)
            })
        }
    }
    
    func sendNotification(withText text: String, andTitle title: String, toTopic topic: String, andData data:[String : String]) {
        guard let selfID = Utility.getUserid() else { return }
        let url = "https://fcm.googleapis.com/fcm/send"
        let header = ["Authorization":AppConstants.mGoogleLegaceyServerKey]
        guard let secretID = data["secretID"] else { return }
        let userID = ["receiverID":selfID,
                      "secretID":secretID] as [String : String]
        
        let notificationParams = [ "body" : "\(text)",
            "title" : "\(title)",
            "sound": "default"]
        let notificationData = ["body":userID]
        let params : [String : Any] = ["condition": "'\(topic)' in topics",
            "priority" : "high",
            "notification" : notificationParams,
            "data":notificationData
            ] as [String : Any]
        
        AFWrapper.requestPOSTURL(serviceName: url, params: params, header: HTTPHeaders.init(header), success:{ (response) in
            guard let responseData = response.dictionaryObject else { return }
            print("Response",responseData)
        },
                                 failure: { (customErrorStruct) in
                                    print(Strings.error,customErrorStruct)
        })
    }
    
    func transferAcceptOrRejectAction(isAccept: Bool, msgId: String){
        let transferApi = SocialAPI()
        let action: Double = isAccept ? 1.0 : 2.0
        let params: [String : Any] = ["messageId" : msgId,
                                      "action" : action]
        let strUrl = AppConstants.transferAction
        transferApi.postSocialData(with: strUrl, params: params) { (resopnse, error) in
            if error == nil{
                print("Action Successful")
            }else if let err = error{
                print("Action failed \(err.localizedDescription)")
            }
        }
    }
    
    func trnsferCancelActionService(msgId: String){
        let transferApi = SocialAPI()
        let strUrl = AppConstants.cancelTransfer
        let params: [String : Any] = ["messageId" : msgId]
        transferApi.postSocialData(with: strUrl, params: params) { (resopnse, error) in
            if error == nil{
                print("Action Successful")
            }else if let err = error{
                print("Action failed \(err.localizedDescription)")
            }
        }
    }
}
