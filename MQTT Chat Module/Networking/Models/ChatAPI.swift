//
//  ChatAPI.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 31/10/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import CocoaLumberjack
import RxSwift
import Alamofire
import RxCocoa

class ChatAPI: NSObject {
    
    func getChats(withPageNo pageNo : String,withCompletion:@escaping ([String : Any]) -> Void) {
        self.showTostOnce()
//        let params = ["pageNo":pageNo]
        let strURL =  AppConstants.getChats + "?pageNo=\(pageNo)"
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        let headers = ["authorization":token,"lang": "en"]

        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get , parameters:nil ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getChats.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            DDLogDebug("output here \(response)")
            Helper.hidePI()
            withCompletion(response)
        }, onError: {error in
            Helper.hidePI()
        })
    }
    
    func deleteChat(withSecretID secretID: String?, andRecipientID recipientID : String?, isGroupChat:Bool = false , success:@escaping ([String : Any]) -> Void, failure:@escaping (CustomErrorStruct) -> Void)  {
        var strURL = AppConstants.getChats
        if isGroupChat {
            if let recipientID = recipientID {
                strURL = AppConstants.deleteGroup + "?chatId=\(recipientID)"
            }
            if let recipientID = recipientID {
                if recipientID.count>0 {
                }else {
                    if secretID?.count == 0 {
                        let secret = "null"
                        strURL = strURL + "?" + "recipientId=\(recipientID)&secretId=\(secret)"
                    }
                }
            }
        }
        
        
        
        if !isGroupChat {
            if let secretID = secretID {
                if secretID.count>0 {
                    strURL = strURL+"?"+"recipientId=\(recipientID ?? "")&secretId=\(secretID)"
                }else {
                    //               strURL = strURL
                }
            }
        }
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        if token.count>1 {
            let headerParams = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": "en"]
            AFWrapper.requestDeleteURL(serviceName: strURL, params: nil, header: HTTPHeaders.init(headerParams),
                                       success: { (response) in
                                        Helper.hidePI()
                                        guard let responseData = response.dictionaryObject else { return }
                                        print("Response",responseData)
                                        success(responseData)
            },
                                       failure: { (customErrorStruct) in
                                        Helper.hidePI()
                                        print(Strings.error,customErrorStruct)
                                        failure(customErrorStruct)
            })
        }
    }
    
    func sendNotification(withText text: String, andTitle title: String, toTopic topic: String, andData data:[String : String] ) {
        let url = "https://fcm.googleapis.com/fcm/send"
        let header = ["Authorization":AppConstants.mGoogleLegaceyServerKey]
        guard let selfID = Utility.getUserid() else { return }
        
        let userID = ["senderID":selfID] as [String : String] // Yours ID
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
    
    func showTostOnce(){
        if  let isFirst =  UserDefaults.standard.object(forKey:"showLoadingChatListOnce")  as? Bool{
            if isFirst == true {
                Helper.showPI(_message: "Loading...")
                UserDefaults.standard.set(false, forKey: "showLoadingChatListOnce")
            }
        }
    }
}
