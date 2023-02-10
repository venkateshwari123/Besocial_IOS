//
//  MQTTModule.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 11/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import MQTTClient
import Foundation
import CocoaLumberjack

class MQTT : NSObject{
    
    struct Constants {
        static let mqttHost : String = {
            guard let mqttHost = Bundle.main.object(forInfoDictionaryKey: "MQTT_Host") as? String else {
                fatalError("Missing key")
            }
            return mqttHost
        }()
        
        static let mqttPort : String = {
            guard let mqttPort = Bundle.main.object(forInfoDictionaryKey: "MQTT_Host") as? String else {
                fatalError("Missing key")
            }
            return mqttPort
        }()
        
        static let mqttAuthUser : String = {
            guard let mqttAuthUser = Bundle.main.object(forInfoDictionaryKey: "MQTT_AUTH_USER") as? String else {
                fatalError("Missing key")
            }
            return mqttAuthUser
        }()
        
        static let mqttAuthPassWord : String = {
            guard let mqttAuthPassWord = Bundle.main.object(forInfoDictionaryKey: "MQTT_AUTH_PASSWORD") as? String else {
                fatalError("Missing key")
            }
            return mqttAuthPassWord
        }()
        
    }
    
    var userID: String? {
        get {
            return Utility.getUserid()
        }
    }
    
    /// Shared instance object for gettting the singleton object
    static let sharedInstance = MQTT()
    
    ///This flag will tell you that you are connected or not.
    var isConnected : Bool = false
    
    ///current session object will going to store in this.
    var manager : MQTTSessionManager!
    
    
    /// MQTT delegate object, its going to store the objects of the delegate receiver class.
    let mqttMessageDelegate = MQTTDelegate()
    
    /// Used for creating the initial connection.
    func createConnection() {
        
        /// Observer for app coming in foreground.
//        NotificationCenter.default.setObserver(self, selector: #selector(MQTT.reinstateBackgroundTask), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        ///creating connection with the proper client ID.
        if  !self.isConnected, let userId = self.userID {
            self.connect(withClientId: userId)
        }
    }
    
    func disconnectMQTTConnection() {
        if self.isConnected {
            self.isConnected = false
            manager.disconnect(disconnectHandler: nil)
        }
    }
    
    /// Used for subscribing the channel
    ///
    /// - Parameters:
    ///   - topic: name of the current topic (It should contain the name of the topic with saperators)
    ///
    /// eg- Message/UserName
    ///   - Delivering: Type of QOS // can be 0,1 or 2.
    fileprivate func subscribe(topic : String, withDelivering Delivering : MQTTQosLevel) {
        if (manager != nil) {
//            if (manager.subscriptions != nil) {
//                var subscribeDict = manager.subscriptions!
//                if (subscribeDict[topic] == nil) {
//                    subscribeDict[topic] = Delivering.rawValue as NSNumber
//                }
//                self.manager.subscriptions = subscribeDict
//            } else {
//                let subcription = [topic : Delivering.rawValue as NSNumber]
//                self.manager.subscriptions = subcription
//            }
//            self.manager.connect(toLast: { (error) in
//                if let error = error{
//                    print("error ",error.localizedDescription)
//                }
//            })
            self.manager.session.subscribe(toTopic: topic, at: .atMostOnce){ (error, gQoss) in
                if let error = error {
                    print("Subscription failed \(error.localizedDescription)")
                } else {
                    print("Subscription sucessfull! Granted Qos \(String(describing: gQoss))")
                }
            }
        }
       
    }

    
    /// Used for subscribing the channel
    ///
    /// - Parameter channelName: current channel which you want to subscribe.
    func subscribeTopic(withTopicName topicName : String,withDelivering delivering:MQTTQosLevel ) {
        let topicToSubscribe = topicName
        self.subscribe(topic: "\(topicToSubscribe)", withDelivering: delivering)
    }
    
    /// Used for Unsubscribing the channel
    ///
    /// - Parameter channelName: current channel which you want to Unsubscribing.
    func unsubscribeTopic(topic : String) {
        if manager != nil{
            var unsubscribeDict = manager.subscriptions
            if unsubscribeDict?[topic] != nil {
                unsubscribeDict?.removeValue(forKey:topic)
            }
            self.manager.subscriptions = unsubscribeDict
            self.manager.connect(toLast: { (error) in
                if let error = error{
                    print("error ",error.localizedDescription)
                }
            })
        }
    }
    
    /// Used for pubishing the data in between channels.
    ///
    /// - Parameters:
    ///   - jsonData: Data in JSON format.
    ///   - channel: current channel name to publish the data to.
    ///   - messageID: current message ID (this ID should be unique)
    ///   - Delivering: Type of QOS // can be 0,1 or 2.
    ///   - retain: true if you wanted to retain the messages or False if you don't
    ///   - completion: This will going to return MQTTSessionCompletionBlock.
    
    func publishData(wthData jsonData: Data, onTopic topic : String, retain : Bool, withDelivering delivering : MQTTQosLevel) {
        
        if (self.manager != nil) {
            manager.send(jsonData, topic: topic, qos: delivering, retain: retain)
        }
        else {
            guard let userID =  self.userID else { return }
            if (userID.count>1) {
                connect(withClientId: userID)
            }
        }
    }
    
    
    /// Used for connecting with the server.
    ///
    /// - Parameter clientId: current Client ID.
    func connect(withClientId clientId :String) {
        
        if (self.manager == nil) {
            self.manager = MQTTSessionManager()
            let host = Constants.mqttHost
            let port: Int = Constants.mqttPort.integerValue ?? 1883
            let mqttAuthUser = Constants.mqttAuthUser
            let mqttAuthPassword = Constants.mqttAuthPassWord
            manager.delegate = mqttMessageDelegate
    
         //   let cer = MQTTCFSocketTransport.clientCerts(fromP12: Bundle.main.url(forResource: "client", withExtension: "crt")?.absoluteString, passphrase: "")
            do{
                let jsonData = try JSONSerialization.data(withJSONObject:["_id":clientId,"status":0, "userId":clientId]  , options: .prettyPrinted)
                
                manager.connect(to: host, port: Int(port), tls: false, keepalive: 45, clean: false, auth: true, user: mqttAuthUser, pass: mqttAuthPassword, will: true, willTopic: "OnlineStatus/", willMsg: jsonData, willQos: .atMostOnce, willRetainFlag: false, withClientId: "Do_Chat_\(clientId)", securityPolicy: nil, certificates: [], protocolLevel: .version311) { (error) in
                    if let error = error{
                        print("error ",error.localizedDescription)
                    }
                }
            } catch {
            }
            
        } else {
            self.manager.connect(toLast: { (error) in
                if let error = error{
                    print("error ",error.localizedDescription)
                }
            })
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}



