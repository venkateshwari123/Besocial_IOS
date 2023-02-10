//
//  MQTTManager.swift
//  webRtc_module
//
//  Created by Imma Web Pvt Ltd on 04/09/17.
//  Copyright © 2017 3embed. All rights reserved.
//

import UIKit
import CocoaLumberjack
import AVFoundation





class MQTTCallManager: NSObject {
    
    
    //sendCallRequest to Other User
    //parameters:
    //callType          : String - call type audio = 0  / video = 1
    //callerName        : String - user 's Name
    //callerImage       : String - userImage Url
    //callerIdentifier  : String - user 's email or phoneNumber
    //topic             : String - channel name
    class  func sendCallRequest(callType: String ,callerName: String , callerImage: String,callerIdentifier: String,topic: String, callerID: String,callID: String)  {
        
        
        guard let userID = Utility.getUserid() else { return }
        
        
        var dict = ["callerId" : userID ,
                    "callId" :  callID,
                    "callerName" : callerName,
                    "callerImage" : callerImage,
                    "callerIdentifier" : callerIdentifier, ///your own number vybesClub registerNumber
                    "type": 0 ,
                    "callType" : callType
            ] as [String:Any]
        
        
        //NSLog("**********\n******\n sendCallRequest \(dict) *************\n\n")
        if let audioView = UIApplication.shared.keyWindow!.viewWithTag(15) as? AudioCallView{
            audioView.setMessageData(messageData: dict)}
        
        if let videoView = UIApplication.shared.keyWindow!.viewWithTag(17) as? IncomingVideocallView{
            dict["callId"] = videoView.callId
            videoView.setMessageData(messageData: dict)
        }
        
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            MQTT.sharedInstance.publishData(wthData: jsonData , onTopic: topic, retain: false, withDelivering: .atMostOnce)
            
        }catch  {
            DDLogDebug(error.localizedDescription)
            
        }
    }
    
    
    
    
    
    //sendCall Accept Request
    //params:-
    //messageData : dict [String: Any]
    class func sendAcceptCallStatus(messageData:[String: Any]){
        
        guard let userID = Utility.getUserid() else { return }
        var targetID = ""
        
       if let targetId = messageData["callerId"]  as? String{
               targetID = targetId
        }
        
        
        let dict  = ["callerId" : messageData["callerId"]  as! String,
                     "callId" : messageData["callId"] as! String,
                     "callerIdentifier": messageData["callerIdentifier"] as! String,
                     "targetID":targetID,
                     "type" : 1 as Int
            
            ] as [String:Any]
        
        let topic = AppConstants.MQTT.calls + (dict["callerId"] as! String)
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            MQTT.sharedInstance.publishData(wthData: jsonData , onTopic: topic, retain: false, withDelivering: .atMostOnce)
        }catch  {
            DDLogDebug(error.localizedDescription)
        }
    }
    
    //send call Avilibility status
    //paramas: -
    //status : Int 0 = busy 1 = avilable
    //topic: String - channel name
    class  func sendcallAvilibilityStatus(status:Int ,topic: String) {
        
        let dict = ["status": status ] as [String: Any]
        
        //NSLog("***************\n\n *******send call Availibilite =\(dict) ***********\n\n")
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            MQTT.sharedInstance.publishData(wthData: jsonData, onTopic: topic, retain: true, withDelivering: .atMostOnce)
            
        }catch{
            DDLogDebug(error.localizedDescription)
            
        }
    }
    
    
    
    
    
    
    //Receive Message from Mqtt
    //parameters:
    //message           : [String : Any] - json response
    //topic             : String - channel name
    class func didReceive(withMessage message: [String : Any], inTopic topic: String) {
        
        
        DDLogDebug("******didrecive call message statussss topic:\(topic) and data here *********\(message)")
        
        guard let userID = Utility.getUserid() else { return }
        var callType = ""
        var otherUserId = ""
        var callID = ""
        guard let registerNum = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String else { return }
        
        
        if let dict = UserDefaults.standard.object(forKey: "storeIndexPath") as? [String:Any]{
            callType = dict["callType"] as! String
            otherUserId = dict["callerId"] as! String
            callID = dict["callId"] as! String
        }
        
        let selectedTopic = AppConstants.MQTT.callsAvailability + otherUserId
        
        if topic == selectedTopic{
            
            //unsubscribeTopic callavlibility
            MQTT.sharedInstance.unsubscribeTopic(topic: topic)
            
            
            if  UserDefaults.standard.bool(forKey:"iscallBtnCliked") {
                
                UserDefaults.standard.set(false, forKey: "iscallBtnCliked")
                DDLogDebug("***********+++++++++unsubscirbe called++++++++++++++*****************")
                
                //check call Avalible or not//
                if message["status"] as! Int == 1{
                    
                    let userName = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.userName)
                    var userImage = ""
                    if UserDefaults.standard.object(forKey: AppConstants.UserDefaults.userImageForChats) != nil{
                        userImage = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.userImageForChats) as! String
                    }else{  userImage = ""}
                    
                    guard let userID = Utility.getUserid() else { return }
                    let callChannel =  AppConstants.MQTT.calls + otherUserId
                    
                    self.sendCallRequest(callType:callType , callerName: userName as! String , callerImage:userImage, callerIdentifier: registerNum ,topic: callChannel, callerID: otherUserId,callID: callID)
                    self.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + userID)
                }else{
                    
                    if let audioView = appDelegetConstant.window.viewWithTag(15) as? AudioCallView{
                        audioView.callTimerLbl.text = "User is on other call"}
                    if let videoView = appDelegetConstant.window.viewWithTag(17) as? IncomingVideocallView{
                        videoView.calling_status.text = "User is on other call"
                    }
                }
                
            }
            
            
        }else if (topic == (AppConstants.MQTT.calls + userID) ){
            
            
            if (message["type"] as! Int == 0){
                //getting call
                guard let userID = Utility.getUserid() else { return }
                //set busy status
                self.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + userID)
                
                
                //show incoming calling screen here//
                let appdelete = UIApplication.shared.delegate as! AppDelegate
                
//                if  let isCallgoingOn = UserDefaults.standard.object(forKey: "iscallgoingOn") as? Bool {
//                    if isCallgoingOn == false {
//                        UserDefaults.standard.set(true, forKey: "iscallgoingOn")
//                        UserDefaults.standard.synchronize()
//                        appdelete.showIncomingCallingScreen(callData: message)
//                    }
//                }
            }
            else if (message["type"] as! Int == 2){
                
                //End call
                let callID = message["callId"] as! String
                guard let userID = Utility.getUserid() else { return }

                UserDefaults.standard.set(false, forKey: "iscallgoingOn")
                 UserDefaults.standard.synchronize()
                let window = UIApplication.shared.keyWindow!
                if  let  audioView = window.viewWithTag(15) as? AudioCallView{
                    
                    if callID == audioView.callId{
                        audioView.timer?.invalidate()
//                        audioView.webRtc?.disconnect()
                        MQTTCallManager.cxProviderCallEnd()

                        let when = DispatchTime.now() + 0.30
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if audioView.chatViewObj != nil {audioView.chatViewObj?.inputToolbar.isHidden = false}
                            audioView.removeFromSuperview()
                        }
                        self.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                    }
                    
                }
                
                if let incomingView = window.viewWithTag(16) as? IncomingAudiocallView{
                    if callID == incomingView.callID{
                        incomingView.player?.stop()
                        incomingView.timer?.invalidate()
                        let when = DispatchTime.now() + 0.30
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if incomingView.chatViewObj != nil {incomingView.chatViewObj?.inputToolbar.isHidden = false}
                            incomingView.removeFromSuperview()
                        }
                        
                        self.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                    }
                    
                }
                
                
                if let videoView = appDelegetConstant.window.viewWithTag(17) as? IncomingVideocallView{
                    if callID == videoView.callId{
//                        videoView.webRtc?.disconnect()
                        videoView.timer?.invalidate()
                        let when = DispatchTime.now() + 0.30
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if videoView.chatViewObj != nil {videoView.chatViewObj?.inputToolbar.isHidden = false}
                            videoView.removeFromSuperview()
                        }
                        
                        self.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                    }
                }
                
                //check cxprovider object
                let appdele = UIApplication.shared.delegate as? AppDelegate
                if ((appdele?.callProviderDelegate) != nil){
                    
                    do {
                        try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                        try AVAudioSession.sharedInstance().setActive(false)
                    } catch _ {
                    }
                    
                    appdele?.callProviderDelegate?.provider.reportCall(with: (appdele?.callProviderDelegate?.uuId)!, endedAt: nil, reason: .remoteEnded)
                    self.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
                
            }else if (message["type"] as! Int == 1){
                
                
                //init webRTC here with callId ..accept call
                
                
                //For Audio call
                if let audioView = appDelegetConstant.window.viewWithTag(15) as? AudioCallView{
                    audioView.timer?.invalidate()
                    if let player = audioView.player{
                        player.stop()}
                    audioView.initWebrtc(messageData: message )
                }
                
                //For Video call
                if let videoView = appDelegetConstant.window.viewWithTag(17) as? IncomingVideocallView{
                    if let player = videoView.player{
                        player.stop()}
                    videoView.initWebrtc(messageData: message)
//                    videoView.removeCameraLayer()
//                    videoView.timer?.invalidate()
//                    videoView.switchViews()
                }
                
                
            }else if (message["type"] as! Int == 3){
                
                UserDefaults.standard.set(false, forKey: "iscallgoingOn")
                 UserDefaults.standard.synchronize()
                //No answer by reciver after 1 min
                let callID = message["callId"] as! String
                if  let  audioView = UIApplication.shared.keyWindow!.viewWithTag(15) as? AudioCallView{
                    if callID == audioView.callId{
//                        audioView.webRtc?.disconnect()
                        audioView.timer?.invalidate()
                        MQTTCallManager.cxProviderCallEnd()
                        let when = DispatchTime.now() + 0.30
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if audioView.chatViewObj != nil {audioView.chatViewObj?.inputToolbar.isHidden = false}
                            audioView.removeFromSuperview()
                        }
                        
                    }
                }
                
                if let incomingView = UIApplication.shared.keyWindow!.viewWithTag(16) as? IncomingAudiocallView{
                    if callID == incomingView.callID{
                        
                        incomingView.timer?.invalidate()
                        let when = DispatchTime.now() + 0.30
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if incomingView.chatViewObj != nil {incomingView.chatViewObj?.inputToolbar.isHidden = false}
                            incomingView.removeFromSuperview()
                        }
                        
                    }
                }
                
                if let videoView = appDelegetConstant.window.viewWithTag(17) as? IncomingVideocallView{
                    if callID == videoView.callId {
//                        videoView.webRtc?.disconnect()
                        videoView.timer?.invalidate()
                        let when = DispatchTime.now() + 0.30
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if videoView.chatViewObj != nil {videoView.chatViewObj?.inputToolbar.isHidden = false}
                            videoView.removeFromSuperview()
                        }
                    }
                }
                
                guard let userID = Utility.getUserid() else { return }
                self.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                
                NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
                
            }else if (message["type"] as! Int == 5){
                
                //Start video call on ui button
                
            }else if (message["type"] as! Int == 6){
                
                //stop video call on UI button
                
                
            }else if (message["type"] as! Int == 7){
                UserDefaults.standard.set(false, forKey: "iscallgoingOn")
                 UserDefaults.standard.synchronize()
                 guard let userID = Utility.getUserid() else { return }
                // timeout on caller side(no response within 60 sec)
                let callID = message["callId"] as! String
                
                let window = UIApplication.shared.keyWindow!
                if  let  audioView = window.viewWithTag(15) as? AudioCallView{
                    if callID == audioView.callId {
                        audioView.timer?.invalidate()
//                        audioView.webRtc?.disconnect()
                        MQTTCallManager.cxProviderCallEnd()
                        let when = DispatchTime.now() + 0.30
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if audioView.chatViewObj != nil {audioView.chatViewObj?.inputToolbar.isHidden = false}
                            audioView.removeFromSuperview()
                        }
                    }
                    
                    self.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                }
                
                if let incomingView = window.viewWithTag(16) as? IncomingAudiocallView{
                    if callID == incomingView.callID{
                        incomingView.timer?.invalidate()
                        let when = DispatchTime.now() + 0.30
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if incomingView.chatViewObj != nil {incomingView.chatViewObj?.inputToolbar.isHidden = false}
                            incomingView.removeFromSuperview()
                        }
                        
                        self.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                    }
                }
                
                if let videoView = appDelegetConstant.window.viewWithTag(17) as? IncomingVideocallView{
                    
                    if callID == videoView.callId{
                        videoView.timer?.invalidate()
//                        videoView.webRtc?.disconnect()
                        let when = DispatchTime.now() + 0.30
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if videoView.chatViewObj != nil {videoView.chatViewObj?.inputToolbar.isHidden = false}
                            videoView.removeFromSuperview()
                        }
                        
                        self.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                    }
                }
               
                
                //check cxprovider object
                let appdele = UIApplication.shared.delegate as? AppDelegate
                if ((appdele?.callProviderDelegate) != nil){
                    
                    do {
                        try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                        try AVAudioSession.sharedInstance().setActive(false)
                    } catch _ {
                    }
                    appdele?.callProviderDelegate?.provider.reportCall(with: (appdele?.callProviderDelegate?.uuId)!, endedAt: nil, reason: .remoteEnded)
                    self.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
                }
                NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
            }
        }
    }
    
    
    
    //sendEndCall Request
    //paramas : -
    //callID : String - callId
    //callerID : String - callerID
    class func sendEndcallRequest(callID:String, callerID: String, targetID: String,callType: String){
        
         guard let userID = Utility.getUserid() else { return }
        
        let dict = ["type": 2,
                    "callId": callID,
                    "targetId" : targetID,
                    "callerId": callerID,
                    "callType":callType,
                    "userId":userID
        ] as [String:Any]
        
        let topic = AppConstants.MQTT.calls + callerID
        
        //NSLog("***********\n************\n send end call req \(dict)  .. topic ..\(topic) \n\n*****************")
        
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            MQTT.sharedInstance.publishData(wthData: jsonData , onTopic: topic, retain: false, withDelivering: .atMostOnce)
            
        }catch  {
            DDLogDebug(error.localizedDescription)
        }
    }
    
    
    
    //send timeout call Request
    //paramas:
    //callID : String - callId
    //callerID : String - callerID
    class func sendTimeoutcallRequest(callID: String , callerID: String ,type: Int ){
        
        let dict  = ["type" : type,
                     "callId": callID
            ]as [String :Any]
        
        let topic = AppConstants.MQTT.calls + callerID
        
        //NSLog("***********\n************\n send timeout call req \(dict)  .. topic ..\(topic) \n\n*****************")
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            MQTT.sharedInstance.publishData(wthData: jsonData , onTopic: topic, retain: false, withDelivering: .atMostOnce)
            
        }catch  {
            DDLogDebug(error.localizedDescription)
            
        }
    }
    
    
    class func sendTimeoutcallRequestt(callID: String , callerID: String ,type: Int, targetID:String,callType:String ){
        
       
        guard let userID = Utility.getUserid() else { return }
        let dict = ["type": type,
                    "callId": callID,
                    "targetId" : targetID,
                    "callerId": userID,
                    "callType":callType,
                    "userId":userID
            ] as [String:Any]
        
        let topic = AppConstants.MQTT.calls + callerID
        
       // NSLog("***********\n************\n send timeout call req \(dict)  .. topic ..\(topic) \n\n*****************")
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            MQTT.sharedInstance.publishData(wthData: jsonData , onTopic: topic, retain: false, withDelivering: .atMostOnce)
        }catch  {
            DDLogDebug(error.localizedDescription)
        }
    }
    
    
    
    
    class func cxProviderCallEnd(){
    if  let callProvider = UIApplication.shared.delegate as? AppDelegate{
    callProvider.callProviderDelegate?.provider.reportCall(with: (callProvider.callProviderDelegate?.uuId)! , endedAt: nil, reason: .remoteEnded)
    }
    
    }
}








//generate random number
//params :-
//length : Int -
func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}








