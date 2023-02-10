 //
 //  IncomingCallView.swift
 //  webRtc_module
 //
 //  Created by Imma Web Pvt Ltd on 05/09/17.
 //  Copyright © 2017 3embed. All rights reserved.
 //
 
 import UIKit
 import AVFoundation
 import Kingfisher
 import CocoaLumberjack
 
 class IncomingAudiocallView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var callTypelbl: UILabel!
    
    @IBOutlet weak var acceptCall: UIButton!
    
    @IBOutlet weak var rejectCall: UIButton!
    
    
    @IBOutlet weak var userName: UILabel!
    
    var callID:String?
    var callerID : String?
    var messageDict : [String:Any]?
    var timer : Timer?
    var chatViewObj : ChatViewController? = nil
    var player: AVAudioPlayer?
    
    
    //MARK:- init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed("IncomingAudiocallView", owner: self, options: nil)
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        userImageView.clipsToBounds = true
        
        contentView.frame = bounds
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        addSubview(contentView)
        
        //start timer 60 sec for incoming calling screen
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timeoutRemoveScreen), userInfo: nil, repeats: false)
    }
    
    
    //time out remove incomingscreen
    @objc func timeoutRemoveScreen() {
        
        player?.stop()
        timer?.invalidate()
        
        guard let userID = Utility.getUserid() else { return }
        
        MQTTCallManager.sendTimeoutcallRequestt(callID: callID!, callerID: callerID!, type: 3, targetID: messageDict?["callerIdentifier"] as! String, callType: AppConstants.CallTypes.audioCall) //userID
        
        MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        if self.chatViewObj != nil {self.chatViewObj?.inputToolbar.isHidden = false}
        self.removeFromSuperview()
        NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
    }
    
    
    //accept button cliked..
    @IBAction func acceptCallAction(_ sender: Any) {
        
        timer?.invalidate()
        player?.stop()
        self.removeFromSuperview()
        MQTTCallManager.sendAcceptCallStatus(messageData: messageDict!)
        
        let window = UIApplication.shared.keyWindow!
        let audioView = AudioCallView(frame: CGRect(x:0, y:0, width: window.frame.width, height: window.frame.height))
        audioView.tag = 15
        audioView.userImageView.kf.setImage(with: URL(string:messageDict?["callerImage"] as! String ), placeholder: #imageLiteral(resourceName: "defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
        })
        
        audioView.userNameLbl.text = userName.text
        audioView.initWebrtc(messageData: messageDict!)
        audioView.messageDict = messageDict!
        if self.chatViewObj != nil {audioView.chatViewObj = self.chatViewObj}
        window.addSubview(audioView);
        audioView.stopTimer()
    }
    
    //reject button cliked..
    @IBAction func rejectCallAction(_ sender: Any) {
        
        player?.stop()
        timer?.invalidate()
        guard let userID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
        MQTTCallManager.sendEndcallRequest(callID: callID!, callerID: callerID!, targetID:userID , callType: AppConstants.CallTypes.audioCall)
        
        
        ///play endcall sound here
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        let when = DispatchTime.now() + 0.30
        DispatchQueue.main.asyncAfter(deadline: when) {
            if self.chatViewObj != nil {self.chatViewObj?.inputToolbar.isHidden = false}
            self.removeFromSuperview()
        }
        NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
    }
    
    
    //set data here
    func setCallId(messageData: [String:Any]) {
        
        callID = messageData["callId"] as? String
        callerID  = messageData["callerId"] as? String
        messageDict = messageData
        
    }
    
    
    func playSound(_ soundName: String ,loop: Int){
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav")else{ return}
        do {
            
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            //            try? AVAudioSession.sharedInstance().setMode(AVAudioSessionModeMoviePlayback)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
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
 
 
 extension IncomingAudiocallView: AVAudioPlayerDelegate{
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        
        DDLogDebug("sound finished here ...")
        
        
    }
    
    
    
 }

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
