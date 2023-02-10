//
//  MQTTManager.swift
//  Karru
//
//  Created by Hari Krushna Sahu on 15/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import CocoaLumberjack

protocol MQTTManagerDelegate {
    func receivedMessage(_ message:[AnyHashable : Any], andChannel channel: String!)
}

class MQTTManager {
    
    private static var obj: MQTTManager? = nil
    var isDisConnect:Bool = false
    var roomID:String = ""
    static var shared: MQTTManager {
        if obj == nil {
            obj = MQTTManager()
        }
        return obj!
    }
    var delegate : MQTTManagerDelegate? = nil
    var isDisplayed : Bool = false
    let callProviderDelegate = CallProviderDelegate.init()
    var ringToneCount:Int = 0
    var ringToneTimer  = Timer()
    var player: AVAudioPlayer?
    var countDown:Int = 5
    
    func subscribeToTopic(topic:String) {
        MQTT.sharedInstance.subscribeTopic(withTopicName: topic, withDelivering: .atLeastOnce)
    }
    
    /// Method to subscribe trip MQTT topics
    func subscribeTopics() {
        if let userId = Utility.getUserid() {
            MQTT.sharedInstance.subscribeTopic(withTopicName: userId, withDelivering: .atLeastOnce)
        }
    }
    
    func unsubscribeToTopic(topic:String) {
        MQTT.sharedInstance.unsubscribeTopic(topic: topic)
    }
    
    /// Method to unsubscribe trip MQTT Topics
    func unsubscribeTopics() {
        if let userId = Utility.getUserid() {
            MQTT.sharedInstance.unsubscribeTopic(topic: userId)
        }
    }
    
    func newMessage(FromMQTT message:[String:Any], onTopic topic:String) {
        if UIApplication.shared.applicationState == .active{
            self.delegate?.receivedMessage(message, andChannel: topic)
            let storyboard = UIStoryboard(name: "CallKit", bundle: nil)
            if let data = message["data"] as? [String : Any]{
                if let action = data["action"] as? Int,let room = data["room"] as? String {
                    self.roomID = room
                    if action == 4 {
                        isDisConnect = true
                    }else {
                        isDisConnect = false
                    }
                }
                if let room = data["room"] as? String, let callId = data["callId"] as? String, let action = data["action"] as? Int, let calltype = data["type"] as? String{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if self.isDisConnect && room == self.roomID{
                            return
                        }else {
                            
                            let appdel = UIApplication.shared.delegate as! AppDelegate
                            if let views = appdel.window?.subviews, views.contains(where: {
                                $0.parentViewController?.isKind(of: CallViewController.self) ?? false
                            }){
                                
                                // No need to present the duplicate Call kit view
                                return
                            }
                            guard let callVC = storyboard.instantiateViewController(withIdentifier: String(describing:CallViewController.self)) as? CallViewController else { return }
                            self.player?.stop()
                            self.player = nil
                            if room == appdel.roomId {
                                return
                            }else if room == appdel.roomIdForVoip {
                                return
                            }else {
                                callVC.viewModel.room = Int64(room)
                                if !self.isDisplayed{
                                    self.isDisplayed = true
                                    callVC.viewModel.callId = callId
                                    callVC.showIncomingCall = true
                                    UserDefaults.standard.set(true, forKey: "iscallgoingOn")
                                    callVC.userData = data
                                    callVC.callType = calltype == "audio" ? .Audio : .Video
                                    callVC.hidesBottomBarWhenPushed = true
                                    appdel.window!.addSubview(callVC.view)
                                }
                            }
                        }
                    }
                }
            }
        }else   if let data = message["data"] as? [String : Any], let action = data["action"] as? Int,let room = data["room"] as? String, let calltype = data["type"] as? String {
            self.roomID = room
            
            if action == 1 && calltype == "video" {
                DispatchQueue.main.async {
                    //                            self.playSound()
                }
            }else if action == 4{
                self.player?.stop()
                self.player = nil
            }
            //                    if action == 4 && calltype == "audio" {
            //                        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            //                        if let uuid = appDelegate.callUuId {
            //                            self.delegate?.receivedMessage(message, andChannel: topic)
            //                            appDelegate.callProviderDelegate?.reportEndCall(uuid)
            //                            
            //                        }
            //                    }
        }
    }
    
    func playSound() {
        player?.stop()
        ringToneCount = 0
        guard let url = Bundle.main.url(forResource: "ringtone", withExtension: "wav") else {
            print("error")
            return
        }
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.soloAmbient, mode: .moviePlayback, options: [])
            
            
            try audioSession.setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.play()
            
            
            player.numberOfLoops = 40
        } catch let error {
            print(" Audios LOGS\(error.localizedDescription)")
        }
        
        self.ringToneTimer = Timer.scheduledTimer(timeInterval:1,
                                                  target: self,
                                                  selector: #selector(updateRingToneCount),
                                                  userInfo: nil,
                                                  repeats: true)
    }
    
    //Stops playing sound when the countdown over
    @objc func updateRingToneCount(){
        
        if ringToneCount >= 25{
            self.ringToneTimer.invalidate()
            player?.stop()
            player = nil
        }else{
            ringToneCount = ringToneCount + 1
        }
    }
}
