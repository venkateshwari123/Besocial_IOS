//
//  MessageNotificationDelegate.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 31/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import MQTTClient
import CocoaLumberjack
import FirebaseMessaging
//
class MQTTDelegate: NSObject, MQTTSessionManagerDelegate {
    
    func handleMessage(_ data: Data!, onTopic topic: String!, retained: Bool) {
        // self.mqttHandler.gotResponeFromMqtt(responseData: data, topicChannel: topic)
        do {
            guard let dataObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else { return }
            if topic != "OnlineStatus/"{
                print(topic as Any)
                print(dataObj)
            }
            // After getting new message this method will respond.
            
            if topic.range(of:AppConstants.MQTT.messagesTopicName) != nil {
                MQTTChatManager.sharedInstance.getNewMessage(withData: dataObj, in: topic)
            }
                // After getting new acknowladgment this method will respond.
            else if topic.range(of:AppConstants.MQTT.acknowledgementTopicName) != nil {
                MQTTChatManager.sharedInstance.getNewAcknowladgment(withData: dataObj, in: topic)
            }
                // After getting Online Status this method will respond.
            else if topic.range(of:AppConstants.MQTT.onlineStatus) != nil {
                //if lastseen not enable retun it
//                if let isLastSeen  = dataObj["lastSeenEnabled"] as? Bool {
//                    if isLastSeen == false {
//                        return}
//                }
                MQTTChatManager.sharedInstance.gotOnlineStatus(withData: dataObj, withTopic:topic)
            }
                // After getting Typing status this method will respond.
            else if topic.range(of:AppConstants.MQTT.typing) != nil {
                MQTTChatManager.sharedInstance.gotTypingStatus(withData: dataObj, withTopic:topic)
            }
                // After getting new Chats this method will respond.
            else if (topic.range(of: AppConstants.MQTT.getChats) != nil ) {
                MQTTChatManager.sharedInstance.gotChats(withData: dataObj, in:topic)
            }
                // After Syncing new contacts this method will respond.
//            else if topic.range(of:AppConstants.MQTT.contactSync) != nil {
//                MQTTContactSyncManager.sharedInstance.gotUserContacts(withData: dataObj, withTopic: topic)
//            }
                // After getting the user updates this method will respond.
            else if topic.range(of: AppConstants.MQTT.userUpdates) != nil {
                MQTTContactSyncManager.sharedInstance.getupdateUserdetails(withData: dataObj, withTopic: topic)
            }
                // After getting the calls Availability this method will respond.
            else if (topic.range(of: AppConstants.MQTT.callsAvailability) != nil ) || (topic.range(of: AppConstants.MQTT.calls) != nil) {
                MQTTCallManager.didReceive(withMessage: dataObj, inTopic: topic)
            }
                // After getting the calls Availability this method will respond.
            else if (topic.range(of: AppConstants.MQTT.callsAvailability) != nil ) || (topic.range(of: AppConstants.MQTT.calls) != nil) {
                MQTTCallManager.didReceive(withMessage: dataObj, inTopic: topic)
            }
                // After getting the messages for a chat.
            else if (topic.range(of: AppConstants.MQTT.getMessages) != nil) {
                MQTTChatManager.sharedInstance.gotMessages(withData: dataObj, inTopic:topic)
            }
                // After getting the group details this method will respond.
            else if topic.range(of: AppConstants.MQTT.groupChats) != nil {
                print("group chat data: \(dataObj)")
                if let payload = dataObj["payload"] as? String {
                    if payload.count == 0 || payload == "" {
                        MQTTChatManager.sharedInstance.getGroupDetails(withData: dataObj, withTopic:topic)
                    }else {
                        MQTTChatManager.sharedInstance.getNewMessage(withData: dataObj, in: topic)
                    }
                }else {
                    MQTTChatManager.sharedInstance.getGroupDetails(withData: dataObj, withTopic:topic)
                }
            }
            ///If get subscribe data from MQTT
            else if topic.range(of: AppConstants.MQTT.streamNow) != nil{
                MQTTStreamManager.sharedInstance.getLiveUserData(data: dataObj)
            }
            ///If get subscribe data from MQTT
            else if topic.range(of: AppConstants.MQTT.subscribe) != nil{
                MQTTStreamManager.sharedInstance.getStreamSubscribeData(data: dataObj, topic: topic)
            }
            ///If get chat data from MQTT
            else if topic.range(of: AppConstants.MQTT.chat) != nil{
                MQTTStreamManager.sharedInstance.getChatData(data: dataObj, topic: topic)
            }
            ///If get like data from MQTT
            else if topic.range(of: AppConstants.MQTT.like) != nil{
                MQTTStreamManager.sharedInstance.getLikeData(data: dataObj, topic: topic)
            }
            ///If get gift data from MQTT
            else if topic.range(of: AppConstants.MQTT.gift) != nil{
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.walletUpdate)
                MQTTStreamManager.sharedInstance.getGiftData(data: dataObj, topic: topic)
            }
            ///got message on call/callid channel
            else if topic.range(of: "call/") != nil{
                MQTTManager.shared.newMessage(FromMQTT: (dataObj), onTopic: topic)
            }
            ///got call
            else if topic.range(of: Utility.getUserid()!) != nil{
                MQTTManager.shared.newMessage(FromMQTT: (dataObj), onTopic: topic)
            }
            
        } catch let jsonError {
            DDLogDebug("Error !!!\(jsonError)")
        }
    }
    
    func sessionManager(_ sessionManager: MQTTSessionManager!, didDeliverMessage msgID: UInt16) {
        print("Message delivered")
    }
    
    func messageDelivered(_ session: MQTTSession!, msgID: UInt16, topic: String!, data: Data!, qos: MQTTQosLevel, retainFlag: Bool) {
        DDLogDebug( "\(msgID)Message delivered")
        guard let userID = Utility.getUserid() else { return }
        session.persistence.deleteAllFlows(forClientId: userID)
    }
    
    func sessionManager(_ sessionManager: MQTTSessionManager!, didChange newState: MQTTSessionManagerState) {
        switch newState {
        case .connected:
            guard let userID = Utility.getUserid() else { return }
            let mqtt = MQTT.sharedInstance
            mqtt.subscribeTopic(withTopicName: userID, withDelivering: .atMostOnce)
            ///Subscribing Message Channel
            let msgTopic = AppConstants.MQTT.messagesTopicName+userID
            mqtt.subscribeTopic(withTopicName: msgTopic, withDelivering: .atLeastOnce)
            mqtt.subscribeTopic(withTopicName: "OnlineStatus/", withDelivering: .atLeastOnce)
            
            //Firebase connection establishment
            if let oneSignalId = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.oneSignalId) as? String {
                Utility.subscribeToOneSignal(externalUserId: oneSignalId)
            }

        
            ///Subscribing Message Channel
            let getGroupsTopic = AppConstants.MQTT.groupChats+userID
            mqtt.subscribeTopic(withTopicName: getGroupsTopic, withDelivering: .atLeastOnce)
            
            
            do{
                let jsonData = try JSONSerialization.data(withJSONObject:["_id":userID,"status":1]  , options: .prettyPrinted)
                mqtt.publishData(wthData:jsonData , onTopic: "OnlineStatus/", retain: false, withDelivering: .exactlyOnce)
            }catch{
                
            }
            
            
            ///Subscribing Acknowledgment Channel
            let ackTopic = AppConstants.MQTT.acknowledgementTopicName+userID
            mqtt.subscribeTopic(withTopicName: ackTopic, withDelivering: .exactlyOnce)
            
            let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
            if documentID !=  nil {
                //subscribe UserUpdate
                let updateSunc = AppConstants.MQTT.userUpdates + userID
                MQTT.sharedInstance.subscribeTopic(withTopicName: updateSunc, withDelivering: .atLeastOnce)
                MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                MQTT.sharedInstance.subscribeTopic(withTopicName:  AppConstants.MQTT.calls+userID, withDelivering: .atLeastOnce)
            } else {
                //subscribe ContactSync
//                DDLogDebug("************subscribe to contact sync channel here")
//                let contacSync = AppConstants.MQTT.contactSync+userID
//                DDLogDebug("************subscribe to contact sync channel here \(contacSync) ")
//                MQTT.sharedInstance.subscribeTopic(withTopicName: contacSync, withDelivering: .atLeastOnce)
            }
            let state = UIApplication.shared.applicationState
            if state == .active {
//                MQTTChatManager.sharedInstance.sendOnlineStatus(withOfflineStatus: false)
                self.setLastSeenStatus(withOfflineStatus: false)
            } else if state == .background {
               self.setLastSeenStatus(withOfflineStatus: true)
//                MQTTChatManager.sharedInstance.sendOnlineStatus(withOfflineStatus: true)
            }
        case .closed:
            DDLogDebug("disconnected")
            if let userID = Utility.getUserid() {
                if MQTT.sharedInstance.isConnected {
                    if userID.count>1 {
                        MQTT.sharedInstance.manager.session.connect()
                    }
                }
            }
            
        case .error: print("error \(sessionManager.lastErrorCode)")
            
        default:
            DDLogDebug("disconnected")
            
        }
    }
    
    /// To set last seen of user
    fileprivate func setLastSeenStatus(withOfflineStatus status: Bool){
        guard let selfID = Utility.getUserid() else { return }
        var lastStatus = true
        if (UserDefaults.standard.object(forKey:"\(selfID)+Last_Seen") as? Bool) != nil{
            lastStatus = false
        }
        MQTTChatManager.sharedInstance.sendOnlineStatus(withOfflineStatus: status , isLastSeenEnable: lastStatus)
    }
}
