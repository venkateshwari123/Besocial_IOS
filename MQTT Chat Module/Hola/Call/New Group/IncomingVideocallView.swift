//
//  IncomingVideocallView.swift
//  webRtc_module
//
//  Created by Imma Web Pvt Ltd on 08/09/17.
//  Copyright © 2017 3embed. All rights reserved.
//

import UIKit
import AVFoundation
import CocoaLumberjack


class IncomingVideocallView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var userName: UILabel!
//    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    //    @IBOutlet weak var localView: RTCEAGLVideoView!
    
//    @IBOutlet weak var localCameraPerviewView: RTCCameraPreviewView!
    @IBOutlet weak var callEndBtn: UIButton!
    @IBOutlet weak var callAcceptBtn: UIButton!
    
    
    @IBOutlet weak var videoCallLbl: UILabel!
    @IBOutlet weak var videoCallIcon: UIImageView!
    @IBOutlet weak var incomingVidLbl: UILabel!
    @IBOutlet weak var declineLbl: UILabel!
    @IBOutlet weak var acceptlbl: UILabel!
    
    
    @IBOutlet weak var switch_btn: UIButton!
    @IBOutlet weak var endVcall_btn: UIButton!
    @IBOutlet weak var muteBtn: UIButton!
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var calling_userName: UILabel!
    @IBOutlet weak var calling_status: UILabel!
    
    @IBOutlet weak var localViewConstantY: NSLayoutConstraint!
    @IBOutlet weak var endBtnConstantY: NSLayoutConstraint!
    
    
    
    
//    var webRtc: webRTC?
    var callId : String?
    var messageDict : [String:Any]?
    var timer : Timer?
    var endCallTimer: Timer?
    var callerId : String?
    var isSwitch : Bool?
    var chatViewObj : ChatViewController? = nil
    var player: AVAudioPlayer?
    
    var tapGester : UITapGestureRecognizer?
    var swipeGester : UISwipeGestureRecognizer?
    var panGester : UIPanGestureRecognizer?
    var isvideoSwiped = false
    var otherCallerId : String?  = ""
    
    
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var isDisconnected: Bool = false
    var localViewFrame = CGRect.zero
    
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
        callerId = messageData["callerId"] as? String
    }
    
    private func commonInit(){
        
        
        Bundle.main.loadNibNamed("IncomingVideocallView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        addSubview(contentView)
        
        //        localView.isHidden = true
//        self.localCameraPerviewView.isHidden = true
        switch_btn.isHidden = true
        endVcall_btn.isHidden = true
        muteBtn.isHidden = true
        isSwitch = false
        userImageView.isHidden = true
        calling_userName.isHidden = true
        calling_status.isHidden = true
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width/2
        userImageView.clipsToBounds = true
        
        //start timer 60 sec for incoming calling screen
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timeoutRemoveScreen), userInfo: nil, repeats: false)
        
        
        tapGester = UITapGestureRecognizer.init(target: self, action: #selector(tapGesterCliked))
        tapGester?.numberOfTapsRequired = 1
        
        
        swipeGester = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeGesterCliked))
        swipeGester?.numberOfTouchesRequired = 1
        swipeGester?.direction = .down
        
        panGester = UIPanGestureRecognizer.init(target: self, action: #selector(panGesterCliked))
        
//        remoteView.contentMode = UIView.ContentMode.scaleAspectFill
        
    }
    
    
    
    @objc func panGesterCliked(_ panGester: UIPanGestureRecognizer){
        
        if panGester.state == .began || panGester.state == .changed{
            
            let traslation = panGester.translation(in: UIApplication.shared.keyWindow)
            
            panGester.view?.center =  CGPoint(x: panGester.view!.center.x + traslation.x, y: panGester.view!.center.y + traslation.y)
            
            panGester.setTranslation(CGPoint.zero, in: UIApplication.shared.keyWindow)
        }
    }
    
    
    @objc func swipeGesterCliked(_ swipeGester: UISwipeGestureRecognizer){
        
        
        if isvideoSwiped == false{
            
            self.frame = CGRect.init(x: 50, y: 300, width:150, height: 150)
            self.layer.cornerRadius = self.frame.size.width/2
            self.clipsToBounds = true
            //        self.localView.isHidden = true
//            self.localCameraPerviewView.isHidden = true
            self.switch_btn.isHidden = true
            self.endVcall_btn.isHidden = true
            self.muteBtn.isHidden = true
            isvideoSwiped = true
            if self.chatViewObj != nil {self.chatViewObj?.inputToolbar.isHidden = false}
            self.addGestureRecognizer(panGester!)
            
        }else{
            
        }
        
    }
    
    @objc func tapGesterCliked() {
        if isvideoSwiped == false{
            UIView.animate(withDuration: 3 ,delay:5 , options: .showHideTransitionViews , animations: {
                //                self.localViewConstantY.constant = -(self.localViewConstantY.constant + self.localView.frame.size.height)
                self.endBtnConstantY.constant =  -(self.endBtnConstantY.constant + self.endVcall_btn.frame.size.height)
            }) { (isCompl) in}
            
        }else{
            isvideoSwiped = false
            self.frame = CGRect.init(x: 0, y: 0, width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.layer.cornerRadius = 0
            self.clipsToBounds = false
            //            self.localView.isHidden = false
//            self.localCameraPerviewView.isHidden = false
            self.switch_btn.isHidden = false
            self.endVcall_btn.isHidden = false
            self.muteBtn.isHidden = false
            if self.chatViewObj != nil {
                self.chatViewObj?.inputToolbar.contentView?.textView?.resignFirstResponder()
                self.chatViewObj?.inputToolbar.isHidden = true}
            self.removeGestureRecognizer(panGester!)
        }
    }
    
    
    
    //timeout remove audioScreen
    @objc func timeoutRemoveScreen() {
        
        timer?.invalidate()
        player?.stop()
//        webRtc?.disconnect()
        DDLogDebug("***\n\n**********time out called ***************\n*****")
        guard let userID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: "CallsAvailability/" + userID)
        
        if  var callerID = messageDict?["callerIdentifier"] as? String {
            
            if userID == callerID {
                callerID = messageDict?["callerId"] as! String
            }
            // sendTimeoutcallRequestt
            MQTTCallManager.sendTimeoutcallRequestt(callID: callId!, callerID: callerId!, type: 7, targetID: messageDict?["callerIdentifier"] as! String, callType: AppConstants.CallTypes.videoCall) //userID
        }
        
        if self.chatViewObj != nil {self.chatViewObj?.inputToolbar.isHidden = false}
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        self.removeFromSuperview()
        NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
        
    }
    
    
    
    
    //init webRtc
    func initWebrtc(messageData: [String:Any])  {
        UserDefaults.standard.set(true, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        
//        webRtc = webRTC.init(localView: self.localCameraPerviewView, remoteView: self.remoteView, callID: messageData["callId"] as! String)
//        webRtc?.delegate = self
        callId = messageData["callId"] as? String
        messageDict = messageData
        
        contentView.addGestureRecognizer(tapGester!)
        contentView.addGestureRecognizer(swipeGester!)
        
    }
    
    
    @IBAction func endBtncliked(_ sender: Any) {
        
        timer?.invalidate()
//        webRtc?.disconnect()
        guard let userID = Utility.getUserid() else { return }
        
        MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
        MQTTCallManager.sendEndcallRequest(callID: callId!, callerID: callerId!, targetID: userID, callType: AppConstants.CallTypes.videoCall)
        
        
        ///play endcall sound here
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        
        let when = DispatchTime.now() + 0.30
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            if self.chatViewObj != nil {self.chatViewObj?.inputToolbar.isHidden = false}
            self.removeFromSuperview()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
    }
    
    
    @IBAction func acceptBtnCliked(_ sender: Any) {
        
        hideSubviews()
        player?.stop()
        timer?.invalidate()
        
        MQTTCallManager.sendAcceptCallStatus(messageData: messageDict!)
        //        self.removeCameraLayer()
        self.initWebrtc(messageData:messageDict! )
        
        // webRtc?.switchLocalRemoteView(_localView: self.localView, _remoteView: self.remoteView)
        
    }
    
    
    func switchViews() {
        
//        webRtc?.switchLocalRemoteView(_localView: nil, _remoteView: self.remoteView)
        //        localView.isHidden = false
//        self.localCameraPerviewView.isHidden = false
        userImageView.isHidden = true
        calling_userName.isHidden = true
        calling_status.isHidden = true
        
    }
    
    
    
    func hideSubviews() {
        //        localView.isHidden = false
//        self.localCameraPerviewView.isHidden = false
        userName.isHidden = true
        videoCallLbl.isHidden = true
        videoCallIcon.isHidden = true
        incomingVidLbl.isHidden = true
        callEndBtn.isHidden = true
        callAcceptBtn.isHidden = true
        declineLbl.isHidden = true
        acceptlbl.isHidden = true
        
        switch_btn.isHidden = false
        endVcall_btn.isHidden = false
        muteBtn.isHidden = false
        
        userImageView.isHidden = true
        calling_userName.isHidden = true
        calling_status.isHidden = true
    }
    
    
    /*methodes after pick call*/
    
    
    //switch camera button action//
    @IBAction func switchBtnCliked(_ sender: Any) {
        
//        webRtc?.switchCamera()
        if isSwitch == false{
            isSwitch = true
            //            webRtc?.client?.swapCameraToBack()
        }else{
            isSwitch = false
            //            webRtc?.client?.swapCameraToFront()
            //            webRtc?.switchCamera()
        }
        
    }
    
    
    
    
    //end video button action//
    @IBAction func endVideocallCliked(_ sender: Any) {
        
        self.endVideoCall()
    }
    
    
    func endVideoCall(){
        player?.stop()
        timer?.invalidate()
        
        guard let userID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
        
        if let uuid = messageDict?["userId"] as? String{
            messageDict?["callerId"] = uuid
            messageDict?["callerIdentifier"] = userID
        }
        
        if  let callerID = messageDict?["callerId"] as? String {
            
            if userID != callerID {
                otherCallerId = callerID
            }
            MQTTCallManager.sendEndcallRequest(callID: callId!, callerID: otherCallerId!, targetID: messageDict?["callerIdentifier"] as! String, callType: AppConstants.CallTypes.videoCall)
            
        }
        
        
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
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)))
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
    
    
    
    //mute button action//
    @IBAction func muteBtnCliked(_ sender: Any) {
        if muteBtn.isSelected == true{
            //            webRtc?.client?.muteAudioIn()
//            webRtc?.muteCall()
            muteBtn.isSelected = false
        }else{
            muteBtn.isSelected = true
//            webRtc?.unMuteCall()
            //            webRtc?.client?.unmuteAudioIn()
        }
    }
    
    
    func setCallId() {
        callId = randomString(length: 100)
        hideSubviews()
        //        localView.isHidden = true
//        self.localCameraPerviewView.isHidden = true
        userImageView.isHidden = false
        calling_userName.isHidden = false
        calling_status.isHidden = false
    }
    
    
    
    
    //Add camera layer
    func addCameraView(){
        
        let device  = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)), position: AVCaptureDevice.Position.front)
        
        do {
            
            if device != nil{
                let input = try AVCaptureDeviceInput.init(device: device!)
                if captureSession.canAddInput(input){
                    captureSession.addInput(input)
                    sessionOutput.outputSettings = [AVVideoCodecKey  : AVVideoCodecJPEG]
                    
                    if captureSession.canAddOutput(sessionOutput){
                        captureSession.addOutput(sessionOutput)
                        captureSession.startRunning()
                        previewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
                        previewLayer.videoGravity = AVLayerVideoGravity(rawValue: convertFromAVLayerVideoGravity(AVLayerVideoGravity.resizeAspectFill))
                        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                        
                        self.contentView.layer.addSublayer(previewLayer)
                        previewLayer.position = CGPoint.init(x: self.frame.width/2, y: self.frame.height/2)
                        previewLayer.bounds = self.frame
                        
                        
                        self.contentView.bringSubviewToFront(callEndBtn)
                        self.contentView.bringSubviewToFront(acceptlbl)
                        self.contentView.bringSubviewToFront(declineLbl)
                        self.contentView.bringSubviewToFront(callAcceptBtn)
                        self.contentView.bringSubviewToFront(videoCallLbl)
                        self.contentView.bringSubviewToFront(videoCallIcon)
                        self.contentView.bringSubviewToFront(userName)
                        self.contentView.bringSubviewToFront(incomingVidLbl)
                        self.contentView.bringSubviewToFront(switch_btn)
                        self.contentView.bringSubviewToFront(endVcall_btn)
                        self.contentView.bringSubviewToFront(muteBtn)
                        self.contentView.bringSubviewToFront(userImageView)
                        self.contentView.bringSubviewToFront(calling_status)
                        self.contentView.bringSubviewToFront(calling_userName)
                        
                    }
                }
                
            }
        }
        catch{
            
            DDLogDebug("print error")
        }
    }
    
    
    
    
    //remove camera layer
    func removeCameraLayer(){
        self.contentView.layer.addSublayer(previewLayer)
        captureSession.stopRunning()
        previewLayer.removeFromSuperlayer()
    }
    
    
    /// Time action after trying to reconnect call
    ///
    /// - Parameter timer: timer objec
    @objc func endCallAfterRconnectionFail(_ timer: Timer){
        if self.isDisconnected{
            self.endVideoCall()
        }
    }
    
    
}







extension IncomingVideocallView: AVAudioPlayerDelegate{
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        
        DDLogDebug("sound finished here ...")
        
    }
    
    
    
}

//extension IncomingVideocallView : webRTCdelegate{
//
//
//    func appClientStatus(_ client: ARDAppClient, status: ARDAppClientState) {
//
//        DDLogDebug("webRTC status changed =\(status)")
//
//        switch (status){
//        case ARDAppClientState.connected :
//            DispatchQueue.main.async {
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.localCameraPerviewView.frame = self.localViewFrame
//                    self.layoutIfNeeded()
//                    self.removeCameraLayer()
//                })
//                self.timer?.invalidate()
//                self.isDisconnected = false
//                if let endTimer = self.endCallTimer{
//                    endTimer.invalidate()
//                    self.endCallTimer = nil
//                    self.calling_status.isHidden = true
//                }
//            }
//            break
//        case ARDAppClientState.connecting :
//            DispatchQueue.main.async {
//                self.localViewFrame = self.localCameraPerviewView.frame
//                self.localCameraPerviewView.frame = self.frame
//                self.layoutIfNeeded()
//                self.switchViews()
//            }
//            break
//        case ARDAppClientState.disconnected:
//            DispatchQueue.main.async {
//                self.isDisconnected = true
//                self.calling_status.isHidden = false
//                self.calling_status.text = "Reconnecting...".localized
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVLayerVideoGravity(_ input: AVLayerVideoGravity) -> String {
    return input.rawValue
}
