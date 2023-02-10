//
//  MQTTChatManager.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 30/08/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import MQTTClient
import UserNotifications
import CocoaLumberjack

class MQTTChatManager: NSObject {
    
    struct Constants {
        fileprivate static let timeInterval:TimeInterval = 1
        
        fileprivate static let payloadKey = "payload"
        fileprivate static let nameKey = "name"
        fileprivate static let messageDataKey = "messageData"
        fileprivate static let channelNameKey = "channelName"
        fileprivate static let messageIDKey = "messageID"
        
        fileprivate static let unsentMessagesDocumentKey = "unsentMessagesDocument"
        fileprivate static let unsentMessagesArrayKey = "unsentMessagesArray"
        
        fileprivate static let mqttLocalNotification = "MQTTLocalNotification"
    }
    
    let mqttModel = MQTT.sharedInstance
    let couchbaseObj = Couchbase.sharedInstance
    static let sharedInstance = MQTTChatManager()
    
    /// Used only for sending the acknowladgment to the other user about the message delivery.
    ///
    /// - Parameters:
    ///   - channel: Acknowledgement + user ID whom you wanted tosend the acknowladgment
    ///   - message: Current message with acknowladgment format (check Docs).
    ///   - delivering: Delivering with current QOS. // i.e. 2
    func sendAcknowledgment(toChannel channel:String?, withMessage message :[String:Any], withQOS delivering : MQTTQosLevel ) {
        
        print("read Status senttttttttttttttttttt gooooooooooooooooooooo")
        guard let channel = channel, !channel.isEmpty
            else { return }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            mqttModel.publishData(wthData: jsonData, onTopic: channel, retain: false, withDelivering: delivering)
        }
        catch let error {
            DDLogDebug("\(error.localizedDescription)")
        }
    }
    
    /// Used only for sending the message to the other user about the message delivery.
    ///
    /// - Parameters:
    ///   - channel: Message + user ID whom you wanted tosend the message
    ///   - message: Current message with message format (check Docs).
    ///   - delivering: Delivering with current QOS. //i.e. 1
    func sendMessage(toChannel channel:String?, withMessage message :[String:Any], withQOS delivering : MQTTQosLevel ) {
        guard let channel = channel, !channel.isEmpty else { return }
        let msgChannel = "\(AppConstants.MQTT.messagesTopicName)\(channel)"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            mqttModel.publishData(wthData: jsonData, onTopic: msgChannel, retain: false, withDelivering: delivering)
//            self.sendMessageThroughPushNotification(withMessageData: message, toTopic: channel)
            
        }
        catch  {
            DDLogDebug("\(error.localizedDescription)")
        }
    }
    
    func publishUnsentMessage(withData jsonData : Data, in channel : String, withMsgID msgID: UInt16, delivering: MQTTQosLevel, withunsentDocID unsentDocID :String) {
        mqttModel.publishData(wthData: jsonData, onTopic: channel, retain: false, withDelivering: delivering)
    }
    
    func sendUnsentMessages() {
        let usersDocVMObject = UsersDocumentViewModel(couchbase: couchbaseObj)
        guard let userDocID = usersDocVMObject.getCurrentUserDocID() else { return }
        guard let userDocData = couchbaseObj.getData(fromDocID: userDocID) else { return }
        guard let unsentDocID = userDocData[Constants.unsentMessagesDocumentKey]  as? String else { return }
        guard let unsentMessagesDocumentData = couchbaseObj.getData(fromDocID: unsentDocID) else { return }
        guard let unsentMessagesArray = unsentMessagesDocumentData[Constants.unsentMessagesArrayKey] as? [Any] else {return }
        self.sendUnsentMsgsAgainAfterConnection(withMsgArray: unsentMessagesArray, withUnsentMsgsDocID: unsentDocID)
    }
    
    func sendUnsentMsgsAgainAfterConnection(withMsgArray msgArray : [Any], withUnsentMsgsDocID unsentMsgDocID : String) {
        for msg in msgArray {
            guard let message = msg as? [String : Any] else { return }
            guard let jsonData = message[Constants.messageDataKey] as? String, let channelName = message[Constants.channelNameKey] as? String,  let msgID = message[Constants.messageIDKey] as? UInt16 else { return }
            if let data = Data(base64Encoded: jsonData) {
                self.publishUnsentMessage(withData: data, in: channelName, withMsgID: msgID, delivering: .atLeastOnce, withunsentDocID: unsentMsgDocID)
            }
        }
    }
    
    func getNewAcknowladgment(withData data: [String: Any],in topic: String) {
        if topic.range(of:AppConstants.MQTT.acknowledgementTopicName) != nil {
            
            print("Got ack kkkkkkkkkkk \(data)")
            
            guard let deliveryStatus = data["status"] as? String else { return }
            let chatdocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
            if deliveryStatus == "2" {
                chatdocVMObject.updateDocumentForMessageDelivered(withMessageData: data)
            } else if deliveryStatus == "3" {
                chatdocVMObject.updateDocumentForMessageRead(withMessageData: data)
            }
        }
    }
    
    func subscribeToGetMessageTopic(withUserID userID : String) {
        let getMessagesTopic = AppConstants.MQTT.getMessages+userID
        mqttModel.subscribeTopic(withTopicName: getMessagesTopic, withDelivering: .atLeastOnce)
    }
    
    func gotOnlineStatus(withData data: [String:Any], withTopic topic : String) {
        let name = NSNotification.Name(rawValue: "LastSeen")
        NotificationCenter.default.post(name: name, object: self, userInfo: ["message": data, "topic": topic])
    }
    
    func gotTypingStatus(withData data: [String : Any], withTopic topic : String) {
        let name = NSNotification.Name(rawValue: "Typing")
        NotificationCenter.default.post(name: name, object: self, userInfo: ["message": data, "topic": topic])
    }
    
    func gotChats(withData data: [String: Any],in topic: String) {
        let chatdocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        if let selfID = Utility.getUserid() {
            if topic.range(of:selfID) != nil {
                chatdocVMObject.updateDocumentForChatReceived(withChatData: data, atTopic: topic, isGroupChat: false)
            }
        }
    }
    
    func gotMessages(withData data : [String : Any], inTopic topic : String) {
        let chatdocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        if topic.range(of:AppConstants.MQTT.getMessages) != nil {
            
            if let chatID = data["chatId"] as? String, let secretID = data["secretId"] as? String, let receiverID = data["opponentUid"] as? String, let messages = data["messages"] as? [[String : Any]] {
                if receiverID.count>0 {
                    guard let selfID = Utility.getUserid() else { return }
                    var oponentID = receiverID
                    if receiverID == selfID {
                        guard let opntID = self.getOponentID(withMessages: messages) else { return }
                        oponentID = opntID
                    }
                    chatdocVMObject.updateMessages(withMessage: messages, byChatID: chatID, receiverID: oponentID, secretId: secretID)
                    let name = NSNotification.Name(rawValue: "PullToRefresh")
                    NotificationCenter.default.post(name: name, object: self, userInfo: ["chatId": chatID, "secretId": secretID])
                }else {
                    
                     guard let selfID = Utility.getUserid() else { return }
                     var oponentID = receiverID
                     if receiverID == selfID {
                      guard let opntID = self.getOponentID(withMessages: messages) else { return }
                       oponentID = opntID
                     }
                    
                    chatdocVMObject.updateMessages(withMessage: messages, byChatID: chatID, receiverID: chatID, secretId: secretID)
                    let name = NSNotification.Name(rawValue: "PullToRefresh")
                    NotificationCenter.default.post(name: name, object: self, userInfo: ["chatId": chatID, "secretId": secretID])
                    
                }
            }
        }
    }
    
    fileprivate func getOponentID(withMessages messaegs: [[String:Any]]) -> String? {
        if let message = messaegs.first {
            guard let receiverId = message["receiverId"] as? String, let senderID = message["senderId"] as? String else { return nil }
            guard let selfID = Utility.getUserid() else { return nil }
            if receiverId == selfID {
                return senderID
            } else {
                return receiverId
            }
        }
        return nil
    }
    
    fileprivate  func sendMessageThroughPushNotification(withMessageData msgData: [String:Any], toTopic topic : String) {
        
        return
        
        guard let type = msgData["type"] as? String else { return }
        guard let messageTypeObj:MessageTypes = MessageTypes(rawValue: Int(type)!) else { return }
        guard let msgText = (msgData["payload"] as? String)?.fromBase64() else { return }
        guard let userName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else { return }
        guard let receiverID = Utility.getUserid() else { return }
        
        let data:[String : String] = ["receiverID":receiverID]
        
        switch messageTypeObj {
        case .text: //0
            ChatAPI().sendNotification(withText: msgText, andTitle: userName, toTopic: topic, andData: data)
        case .image: //1
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has sent you an image", toTopic: topic, andData: data)
        case .video: //2
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has sent you a video", toTopic: topic, andData: data)
        case .location: //3
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has shared the location with you", toTopic: topic, andData: data)
        case .contact: //4
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has shared a contact with you", toTopic: topic, andData: data)
        case .audio: //5
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has sent you an Audio", toTopic: topic, andData: data)
        case .sticker: //6
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has sent you a Sticker", toTopic: topic, andData: data)
        case .doodle: //7
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has sent you a doodle", toTopic: topic, andData: data)
        case .gif: //8
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has sent you a gif", toTopic: topic, andData: data)
        case .document: //8
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has sent you a document", toTopic: topic, andData: data)
            
        case .deleted :
            break
            
        default:
            ChatAPI().sendNotification(withText: " ", andTitle: "\(userName) has sent you a message", toTopic: topic, andData: data)
        }
    }
    
    func getNewMessage(withData data: [String: Any],in topic: String) {
        /*
         Bug Name :- show user payments in chat
         Fix Date :- 03/06/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Handled mqtt data
         */
        var toID = ""
        if let receiverId = data["to"] as? String {
            toID = receiverId
        }else if let toId = data["receiverId"] as? String{
            toID = toId
        }else {
            return
        }
        let chatdocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        if topic.range(of:AppConstants.MQTT.messagesTopicName) != nil {
            guard let selfID = Utility.getUserid() else { return }
            var msgObj = data
            msgObj["isSelf"] = (selfID == toID) ? false : true
            if let messageId = msgObj["messageId"] as? String, msgObj["id"] == nil {
                msgObj["id"] = messageId
            }

            if let messageId = msgObj["id"] as? String{
                msgObj["id"] = messageId
            }
            if selfID == toID { // This message ment for the current user, save it as a received message.
                chatdocVMObject.updateDocumentForMessageReceived(withMessageData: msgObj, atTopic: topic)
            }else {
                chatdocVMObject.updateDocumentForMessageReceived(withMessageData: msgObj, atTopic: topic)
            }
        }else if topic.range(of: AppConstants.MQTT.groupChats) != nil{
            guard let selfID = Utility.getUserid() else { return }
            // if selfID == toID { // This message ment for the current user, save it as a received message.
            guard let fromId = data["from"] as? String else{return}
            var messageData = data
            messageData["isSelf"] = (selfID == fromId) ? true : false
            messageData["from"] = data["to"]
            chatdocVMObject.updateDocumentForMessageReceived(withMessageData: messageData, atTopic: topic)
            //}
        }
    }
    
    func sendOnlineStatus(withOfflineStatus status : Bool , isLastSeenEnable: Bool = true) { //true for offline and false for online
        guard let selfID = Utility.getUserid() else { return }
        let lastSeenTopic = AppConstants.MQTT.onlineStatus+selfID
        var params = [String : Any]()
        guard let timeStamp = DateExtension().sendTimeStamp(fromDate:Date()) else { return }
        if !status { // for online
            params = ["status":1,
                      "userId":selfID,
                      "lastSeenEnabled":isLastSeenEnable]
        }
        else { // for offline
            params = ["status":0,
                      "userId":selfID,
                      "timestamp":timeStamp,
                      "lastSeenEnabled":isLastSeenEnable]
        }
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        mqttModel.publishData(wthData: jsonData!, onTopic: lastSeenTopic, retain: true, withDelivering: .atMostOnce)
    }
    

    
    func subscribeTypingChannel(withUserID userID : String) {
        let typingTopic = AppConstants.MQTT.typing+userID
        mqttModel.subscribeTopic(withTopicName: typingTopic, withDelivering: .atMostOnce)
    }
    
    func subscribeGetChatTopic(withUserID userID : String) {
        let getChatsTopic = AppConstants.MQTT.getChats+userID
        mqttModel.subscribeTopic(withTopicName: getChatsTopic, withDelivering: .atLeastOnce)
    }
    
    func unsubscribeTypingChannel(withUserID userID : String) {
        let typingTopic = AppConstants.MQTT.typing+userID
        mqttModel.unsubscribeTopic(topic: typingTopic)
    }
    
    func subscibeToLastSeenChannel(withUserID userID : String) {
        let lastSeenTopic = AppConstants.MQTT.onlineStatus+userID
        mqttModel.subscribeTopic(withTopicName: lastSeenTopic, withDelivering: .atLeastOnce) //atMostOnce
    }
    
   func unsubscibeToLastSeenChannel(withUserID userID : String) {
        if let mqttModelManager = mqttModel.manager {
            guard let subscribeDict = mqttModelManager.subscriptions else { return }
            let keys = subscribeDict.keys
            for key in keys {
                if key.hasPrefix("\(AppConstants.MQTT.onlineStatus)") {
                    mqttModel.unsubscribeTopic(topic: key)
                }
            }
        }
    }
    
    func sendTyping(toUser userID : String) {
        let typingTopic = AppConstants.MQTT.typing+userID
        guard let selfID = Utility.getUserid() else { return }
//        let params = ["from" : selfID]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: [:], options: .prettyPrinted)
            mqttModel.publishData(wthData: jsonData, onTopic: typingTopic, retain: false, withDelivering: .atMostOnce)
        }
        catch  {
            DDLogDebug("\(error.localizedDescription)")
        }
    }
    
    func getGroupDetails(withData data: [String:Any], withTopic topic : String) {
        let chatdocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        if let selfID = Utility.getUserid() {
            if topic.range(of:selfID) != nil {
                chatdocVMObject.updateDocumentForChatReceived(withChatData: data, atTopic: topic, isGroupChat : true)
            }
        }
    }
    
    
    //MARK: - Group Chat Methodss
    
    func sendGroupMessage(toChannel channel: String? ,withMessage message: [String:Any] , withQsos delivering : MQTTQosLevel){
        guard let groupID = channel else {return}
        let grpChannel = "\(AppConstants.MQTT.groupChats)" + "\(groupID)"
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            
            mqttModel.publishData(wthData: jsonData, onTopic: grpChannel, retain: false, withDelivering: delivering)
            //To do :->  self.sendMessageThroughPushNotification
        }
        catch {
            DDLogDebug("\(error.localizedDescription)")
        }
    }
    
    func sendGroupMessageToServer(toChannel channel: String? ,withMessage message: [String:Any] , withQsos delivering : MQTTQosLevel){
        guard let groupID = channel else {return}
        let grpChannel = "\(AppConstants.MQTT.groupChat)" + "\(groupID)"
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            
            mqttModel.publishData(wthData: jsonData, onTopic: grpChannel, retain: false, withDelivering: delivering)
            //To do :->  self.sendMessageThroughPushNotification
        }
        catch {
            DDLogDebug("\(error.localizedDescription)")
        }
    }
    
    
    
    
}

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
