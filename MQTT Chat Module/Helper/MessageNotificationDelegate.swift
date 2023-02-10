//
//  MessageNotificationDelegate.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 31/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import SwiftMQTT

class MQTTDelegate: NSObject, MQTTSessionDelegate {
    
    func mqttDidDisconnect(session: MQTTSession, reson: MQTTSessionDisconnect, error: Error?) {
        print("Session Disconnected.",error?.localizedDescription ?? "")
    }
    
    func mqttDidReceive(message: MQTTMessage, from session: MQTTSession) {
        if let data = message.payload.data {
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else { return }
                CouchbaseHelper.sharedInstance.getNewMessage(withData: json, in: message.topic)
            } catch let jsonError {
                print("Error !!!",jsonError)
            }
        }
    }
}
