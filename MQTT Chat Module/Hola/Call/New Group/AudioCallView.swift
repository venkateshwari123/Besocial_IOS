//
//  AudioCallView.swift
//  webRtc_module
//
//  Created by Imma Web Pvt Ltd on 05/09/17.
//  Copyright © 2017 3embed. All rights reserved.
//

import UIKit
import AVFoundation
import CocoaLumberjack


class AudioCallView: UIView {
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var callTypeLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var callTimerLbl: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var titleToNameConstant: NSLayoutConstraint!
    
    @IBOutlet weak var toplayOut: NSLayoutConstraint!
    
    @IBOutlet weak var backImageView: UIImageView!
//    var webRtc: webRTC?
    var callId : String?
    var messageDict : [String:Any]?
    var timer : Timer?
    var endCallTimer: Timer?
    var chatViewObj : ChatViewController? = nil
    var player: AVAudioPlayer?
    var callDisplayTimer: Timer?
    var secound = 0
    var isTimerRunning = false
    var resumeTapped = false
    var callerID: String? =  ""
    
    var isDisconnected: Bool = false
    
    //MARK:- init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    //set data here
    func setMessageData(messageData:[String : Any]) {
        messageDict = messageData
        callId = messageData["callId"] as? String
    }
    
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed("AudioCallView", owner: self, options: nil)
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        userImageView.clipsToBounds = true
        callTimerLbl.text = "connecting...".localized
        contentView.frame = bounds
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        addSubview(contentView)
        
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibility.isReduceTransparencyEnabled {
            backImageView.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = backImageView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backImageView.addSubview(blurEffectView)
        } else {
            backImageView.backgroundColor = .black
        }
        
        
        //start timer 60 sec for incoming calling screen
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timeoutRemoveScreen), userInfo: nil, repeats: false)
        
        if UIScreen.main.bounds.size.width == 320 {
            titleToNameConstant.constant = 10
        }
        
        
        if UIScreen.main.bounds.height == AppConstants.iphoneX.height.rawValue {
            toplayOut.constant = 50
            self.layoutIfNeeded()
        }
        
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    @objc func updateTimer(_ timer: Timer){
        DispatchQueue.main.async {
            self.secound += 1
            if !self.isDisconnected{
                self.callTimerLbl.text = self.timeString(time: TimeInterval(self.secound))
            }
        }
    }
    
    
    @objc func endCallAfterRconnectionFail(_ timer: Timer){
        if self.isDisconnected{
            self.endAudioCall()
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    
    
    //timeout remove audioScreen
    @objc func timeoutRemoveScreen() {
        
        timer?.invalidate()
        guard let userID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
        
        if  let id = messageDict?["callerId"] as? String{
            if userID != id {
                callerID = id
            }
            
            // sendTimeoutcallRequestt
            MQTTCallManager.sendTimeoutcallRequestt(callID: callId!, callerID: callerID!, type: 7, targetID: messageDict?["callerIdentifier"] as! String, callType: AppConstants.CallTypes.audioCall)
        }
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        if self.chatViewObj != nil {self.chatViewObj?.inputToolbar.isHidden = false}
        self.removeFromSuperview()
        if let player = player{
            player.stop()
        }
        NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
    }
    
    
    //init webRtc
    func initWebrtc(messageData: [String:Any])  {
        
        UserDefaults.standard.set(true, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
//        webRtc = webRTC.init(localView: nil, remoteView: nil, callID: messageData["callId"] as! String)
//        webRtc?.delegate = self
        //        webRtc?.client?.disableSpeaker()
        callId = messageData["callId"] as? String
        //messageDict = messageData
    }
    
    
    //mute button cliked..
    @IBAction func muteAction(_ sender: Any) {
        
        if muteButton.isSelected == true{
            //            webRtc?.client?.unmuteAudioIn()
//            webRtc?.unMuteCall()
            muteButton.isSelected = false
        }else{
            muteButton.isSelected = true
//            webRtc?.muteCall()
            //            webRtc?.client?.muteAudioIn()
        }
    }
    
    
    //speaker button cliked..
    @IBAction func speakerAction(_ sender: Any) {
        
        if speakerButton.isSelected == true{
            speakerButton.isSelected = false
            //            webRtc?.client?.enableSpeaker()
//            webRtc?.enableSpeaker()
        }else{
            speakerButton.isSelected = true
            //            webRtc?.client?.disableSpeaker()
//            webRtc?.disableSpeaker()
        }
        
    }
    
    
    //video button cliked..
    @IBAction func videoAction(_ sender: Any) {
        
        DDLogDebug("video button action")
        if videoCallButton.isSelected == true{
            videoCallButton.isSelected = false
            
        }else{
            
            videoCallButton.isSelected = true
        }
        
    }
    
    
    //end button cliked..
    @IBAction func endAction(_ sender: Any) {
        
        self.endAudioCall()
        
    }
    
    func endAudioCall(){
        
        if  let callProvider = UIApplication.shared.delegate as? AppDelegate{
//            callProvider.callProviderDelegate?.provider.reportCall(with: (callProvider.callProviderDelegate?.uuId)! , endedAt: nil, reason: .remoteEnded)
        }
        
        timer?.invalidate()
        //        webRtc?.disconnect()
        
        guard let userID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
        
        
        let id = messageDict?["callerId"] as! String ////end call crash here
        
        if userID != id {
            callerID = id
        }
        
        MQTTCallManager.sendEndcallRequest(callID: callId!, callerID: callerID!, targetID:messageDict?["callerIdentifier"] as! String , callType: AppConstants.CallTypes.audioCall)
        
        ///play endcall sound here
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        
        
        let when = DispatchTime.now() + 0.30
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
//            self.webRtc?.disconnect()
            if self.chatViewObj != nil {self.chatViewObj?.inputToolbar.isHidden = false}
            self.removeFromSuperview()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
    }
    
    func playSound(_ soundName: String,loop: Int){
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav")else{ return}
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            try AVAudioSession.sharedInstance().setActive(true)
            player  = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.numberOfLoops = loop
            guard let player = player else { return}
            player.play()
            
        }catch let error{
            DDLogDebug("error \(error.localizedDescription)")
        }
    }
    
}


extension AudioCallView: AVAudioPlayerDelegate{
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        
        DDLogDebug("sound finished here ...")
    }
}


//extension AudioCallView : webRTCdelegate{
//    
//    
//    func appClientStatus(_ client: ARDAppClient, status: ARDAppClientState) {
//        
//        DDLogDebug("webRTC status changed =\(status)")
//        
//        switch (status){
//            
//        case ARDAppClientState.connected :
//            
//            DispatchQueue.main.async {
//                self.isDisconnected = false
//                if let endTimer = self.endCallTimer{
//                    endTimer.invalidate()
//                    self.endCallTimer = nil
//                }
//                if self.callDisplayTimer == nil {
//                    self.callDisplayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(_:)) , userInfo: nil, repeats: true)
//                    self.callTimerLbl.text = self.timeString(time: TimeInterval(self.secound))
//                }
//            }
//            break
//            
//        case ARDAppClientState.connecting :
//            DispatchQueue.main.async {
//                self.callTimerLbl.text = "connecting...".localized
//            }
//            break
//            
//        case ARDAppClientState.disconnected:
//            DispatchQueue.main.async {
//                self.isDisconnected = true
//                self.callTimerLbl.text = "Reconnecting...".localized
//                self.endCallTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.endCallAfterRconnectionFail(_:)), userInfo: nil, repeats: false)
//            }
//            break
//        }
//        
//    }
//    
//}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
