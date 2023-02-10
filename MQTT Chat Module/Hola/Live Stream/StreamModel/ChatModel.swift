//
//  ChatModel.swift
//  Live
//
//  Created by Vengababu Maparthi on 27/11/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import Foundation

class ChatModel {
    
    var chatData:[ChatData] = []
    var viewerList = [Viewers]()
    
    func getChatData(streamID:String, completionHandler:@escaping([ChatData] , Bool) -> ()) {
        
        let streamApi = StreamingAPI()
        let timeStamp = Helper.currentTimeStamp
        let param: [String : Any] = ["streamId" : streamID,
                     "timestamp" : timeStamp,
                     "offset" : 0,
                     "limit" : 20
        ]
        let url = AppConstants.getCommentsHistory
        streamApi.streamGetServiceCall(withURL: url, param: param) { (resposne, error) in
            if error == nil, let result = resposne as? [String : Any]{
                self.chatData = [ChatData]()
                if let chat = result["data"] as? [[String:Any]]{
                    if chat.count > 0{
                        self.chatData = chat.map{
                            ChatData.init(data: $0)
                        }
                        completionHandler(self.chatData, true)
                    }else{
                        completionHandler(self.chatData, false)
                    }
                }
//                print(response)
            }else{
                completionHandler(self.chatData, false)
            }
        }
    }
    
    func postTheChat(message:String,streamID:String,completionHandler:@escaping(Bool) -> ()) {
        let dict:[String:Any] = ["message":message,
                                 "streamId": streamID]

        let streamApi = StreamingAPI()
        
        let url = AppConstants.PostcommentStream
        streamApi.sereamPostServiceCall(withURL: url, params: dict) { (response, error) in
            if error == nil{
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        }
    }
    
    
    func getSubscriberUserList(stramId: String, userId: String, completionHandler:@escaping(Bool) -> Void){
        
        let streamApi = StreamingAPI()
        let url = AppConstants.getSubscribers + "?streamId=\(stramId)&userId=\(userId)&offset=0&limit=20"
        streamApi.streamGetServiceCall(withURL: url, param: nil) { (resposne, error) in
            if error == nil, let result = resposne as? [String : Any]{
                print(result)
                self.setDataInViewersModel(response: result)
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        }
    }
    
    func setDataInViewersModel(response: [String : Any]){
        guard let subscribers = response["subscribers"] as? [[String : Any]] else{return}
        self.viewerList = subscribers.map({ (data) -> Viewers in
            Viewers(dict: data)
        })
    }
    
    
    func followAndUnFollowUserService(index: Int){
        var data = self.viewerList[index]
        var isSelected: Bool = false
        if data.following == 0{
            isSelected = true
            data.following = 1
        }else{
            data.following = 0
        }
        self.viewerList[index] = data
        let peopleId = data.id
        ContactAPI.followAndUnfollowService(with: isSelected, followingId: peopleId, privicy: 0)
    }

    
}

struct ChatData {
    var name = ""
    var message = ""
    var userImage = ""
    
    init(data:[String:Any]) {
        if let senderName = data["userName"] as? String{
           self.name = senderName
        }
        if let sendermessage = data["message"] as? String{
            self.message = sendermessage
        }
        if let userImage = data["userImage"] as? String{
            self.userImage = userImage
        }
        
    }
}

struct EmojiData {
    static let data = ["hello".localized, "😂" , "😍" , "👋" , "👍" , "😂😂😂" , "😍😍😍" , "😘" , "😊" , "👀" ]
}
