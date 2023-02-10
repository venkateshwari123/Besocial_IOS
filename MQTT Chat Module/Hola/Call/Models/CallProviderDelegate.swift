//
//  CallProviderDelegate.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 12/10/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation
import Kingfisher
import CocoaLumberjack
import WebRTC
import Alamofire
import Locksmith

class CallProviderDelegate: NSObject,CXProviderDelegate {
    /// Called when the provider has been reset. Delegates must respond to this callback by cleaning up all internal call state (disconnecting communication channels, releasing network resources, etc.). This callback can be treated as a request to end all calls without the need to respond to any actions
    func providerDidReset(_ provider: CXProvider) {
        
        for call in callManager.calls {
            self.endCall(call: call.uuid )
        }
        callManager.removeAllCalls()
    }
    
    
    var provider : CXProvider
    var callID : String = ""
    var messageData:[String:Any]?
    var calleeName :String = ""
    var uuId : UUID?
    var callManager : CallManager
    var ringingTimer = Timer()
    var callStatusTimer = Timer()
    
    static var providerConfiguration: CXProviderConfiguration {
        
        let appde = UIApplication.shared.delegate as! AppDelegate
        let providerConfiguration: CXProviderConfiguration?
        providerConfiguration = CXProviderConfiguration.init(localizedName: appde.calleeName)
        providerConfiguration?.supportsVideo = false
        providerConfiguration?.maximumCallGroups = 1
        providerConfiguration?.maximumCallsPerCallGroup = 1
        
        if let iconmaskImg = UIImage.init(named: "video_call"){
            providerConfiguration?.iconTemplateImageData = iconmaskImg.pngData()
        }
        
        providerConfiguration?.ringtoneSound = "ringtone.wav"
        return providerConfiguration!
        
    }
    
    
    override init() {
        
        provider = CXProvider.init(configuration: CallProviderDelegate.providerConfiguration)
        let appde = UIApplication.shared.delegate as! AppDelegate
        callManager = appde.callManager
        super.init()
        provider.setDelegate(self, queue: nil)
        
    }
    
    
    
    func displayIncomingcall(uuid: UUID, handel : String, hasVideo:Bool = false, isUpdate : Bool = false){
        calleeName = handel
        uuId = uuid
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let call = Call(uuid: uuid, handle: handel)
        appDelegate.callManager.add(call: call)
        let update = CXCallUpdate()
        update.supportsDTMF = true
        update.supportsGrouping = false
        update.supportsHolding = false
        update.supportsUngrouping = false
        update.hasVideo = false
        update.remoteHandle  = CXHandle.init(type: .generic, value: calleeName)
        if isUpdate{
        provider.reportCall(with: uuid, updated: update)
        }else{
            provider.reportNewIncomingCall(with: uuid, update: update) { error in
                if error != nil {
                    self.reportEndCall(uuid)
                    return
                }
                self.startRingingTimer(for: call)
                self.checkCallStatusTimer(for: call)
            }
        }
    }
    
    func checkIncomingCallIsActive(){
        guard let data = messageData, let callId = data["callId"] as? String,let token = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.token) as? String else {return}
        let header = ["authorization":token,"lan": "en"]
        let urlName = "https://api.besocial.app/call?callId=\(callId)"
        Alamofire.Session.default
            .request(urlName, method: .get, parameters: nil , encoding: JSONEncoding.default, headers: HTTPHeaders.init(header)).responseJSON { (response) in
                if response.response?.statusCode == 404{
                    self.reportEndCall(self.uuId ?? UUID())
                    if let data = self.messageData{
                    let audioCallKitManager = AudioCallKitManager.sharedInstance
                        audioCallKitManager.disConnectAudioCallFromJanus(uuid:self.uuId!,data: data) {
                    }
                    }
                }
            }
    }
    
    private func startRingingTimer(for call: Call)
    {
        let vTimer = Timer(
            timeInterval: 60,
            repeats: false,
            block: { [weak self] _ in
                self?.ringingDidTimeout(for: call)
            })
        vTimer.tolerance = 0.5
        RunLoop.current.add(vTimer, forMode: .common)
        ringingTimer = vTimer
    }
    
    private func checkCallStatusTimer(for call: Call)
    {
        let vTimer = Timer(
            timeInterval: 3,
            repeats: true,
            block: { [weak self] _ in
                self?.checkIncomingCallIsActive()
            })
        vTimer.tolerance = 0.5
        RunLoop.current.add(vTimer, forMode: .common)
        callStatusTimer = vTimer
    }


    private func ringingDidTimeout(for call: Call)
    {
        self.provider.reportCall(with: call.uuid, endedAt: nil, reason: .unanswered)
        self.callStatusTimer.invalidate()
        self.ringingTimer.invalidate()
    }
    
    
    func reportEndCall(_ uuid :UUID? ){
        self.provider.reportCall(with:uuid ?? UUID(), endedAt: Date(), reason: .remoteEnded)
        DispatchQueue.main.async{
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.roomIdForVoip = nil
         //   self.provider.invalidate()
        }
    }
    
    func endCall(call: UUID) {
        let cxCallController = CXCallController()
        let endCallAction = CXEndCallAction(call: call)
        let transaction = CXTransaction(action: endCallAction)
        cxCallController.request(transaction) { error in
            if let error = error {
                print("EndCallAction transaction request failed: \(error.localizedDescription).")
                self.reportEndCall(call)
            }else{
            print("EndCallAction transaction request successful")
            }
            DispatchQueue.main.async{
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.roomIdForVoip = nil
            }
        }
    }

    
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now()) {
            self.checkIncomingCallIsActive()
        }
        ringingTimer.invalidate()
        callStatusTimer.invalidate()
            if let data = self.messageData{
                self.configureAudioSession()
                let audioCallKitManager = AudioCallKitManager.sharedInstance
                audioCallKitManager.initiateBackGroundCall(uuid:self.uuId ?? UUID(), data: data)
                
                DispatchQueue.main.async {
                    let appdel = UIApplication.shared.delegate as! AppDelegate
                    if let views = appdel.window?.subviews, views.contains(where: {
                        $0.parentViewController?.isKind(of: CallViewController.self) ?? false
                    }){
                        
                        // No need to present the duplicate Call kit view
                        return
                    }
                    let storyboard = UIStoryboard(name: "CallKit", bundle: nil)
                    guard  let room = data["room"] as? String, let callId = data["callId"] as? String, let calltype = data["type"] as? String,let callVC = storyboard.instantiateViewController(withIdentifier: String(describing:CallViewController.self)) as? CallViewController else { return }
                    callVC.viewModel.room = Int64(room)
                    callVC.viewModel.callId = callId
                    callVC.showAnActiveCall = true
                    callVC.userData = data
                    UserDefaults.standard.set(true, forKey: "iscallgoingOn")
                    callVC.callType = calltype == "audio" ? .Audio : .Video
                    callVC.hidesBottomBarWhenPushed = true
                    appdel.window!.addSubview(callVC.view)
                }
               
            }
        action.fulfill()
    }
    
    func configureAudioSession() {
        RTCDispatcher.dispatchAsync(on: RTCDispatcherQueueType.typeAudioSession) {
               let audioSession = RTCAudioSession.sharedInstance()
               audioSession.lockForConfiguration()
            let configuration = RTCAudioSessionConfiguration.webRTC()
            configuration.category = AVAudioSession.Category.playAndRecord.rawValue
            configuration.mode = AVAudioSession.Mode.voiceChat.rawValue
            configuration.categoryOptions = [AVAudioSession.CategoryOptions.allowBluetoothA2DP,AVAudioSession.CategoryOptions.duckOthers,AVAudioSession.CategoryOptions.allowBluetooth]
               try? audioSession.setConfiguration(configuration)
               audioSession.unlockForConfiguration()
           }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction){
        ringingTimer.invalidate()
        callStatusTimer.invalidate()
        self.endCall(call: uuId ?? UUID())
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.roomIdForVoip = nil
        if let data = messageData{
            let audioCallKitManager = AudioCallKitManager.sharedInstance
            audioCallKitManager.disConnectAudioCallFromJanus(uuid:uuId!,data: data) {
            }
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        ringingTimer.invalidate()
        callStatusTimer.invalidate()
        self.reportEndCall(nil)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction){
        DDLogDebug("mute called here")
        print("mute called here")
        if action.isMuted {
            let audioCallKitManager = AudioCallKitManager.sharedInstance
            audioCallKitManager.call.localAudioTrack?.isEnabled = false
        }else{
            let audioCallKitManager = AudioCallKitManager.sharedInstance
            audioCallKitManager.call.localAudioTrack?.isEnabled = true
        }
        action.fulfill()
    }
    

    /// Called when the provider's audio session activation state changes.
    
    internal func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession){
        
        DDLogDebug("Audio session didActive")
        
    }
    
    
    internal func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession){
        
        DDLogDebug("Audio session didDeactivate")
        
    }
    
}



