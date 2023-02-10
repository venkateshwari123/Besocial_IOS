//
//  webRTC.swift
//  webRtc_module
//
//  Created by Imma Web Pvt Ltd on 01/09/17.
//  Copyright © 2017 3embed. All rights reserved.
//

import UIKit
import AVFoundation
import CocoaLumberjack


//@objc protocol webRTCdelegate {
//
//    @objc optional func appClientStatus(_ client:WebRTCClient , status: ARDAppClientState)
//
//}

//class webRTC: NSObject,/* RTCVideoViewDelegate*/RTCEAGLVideoViewDelegate{
//
//    var client: WebRTCClient?
//    var captureController: RTCVideoCapturer?
//    //    var localVideoTrack: RTCVideoTrack?
//    var remoteVideoTrack: RTCVideoTrack?
//    let settingModel = ARDSettingsModel()
//
//    //    var localView: RTCEAGLVideoView?
//    var remoteView : RTCEAGLVideoView?
//    var localCaptureView: RTCCameraPreviewView?
//
//    var delegate : webRTCdelegate?
//
//    //init
//    init(localView: RTCCameraPreviewView! ,remoteView : RTCEAGLVideoView! ,callID: String) {
//
//        super.init()
//        // Do any additional setup after loading the view.
//        self.initialize()
//        //        self.localView = localView
//        self.localCaptureView = localView
//        self.remoteView = remoteView
//        connectToChatRoom(callID: callID)
//    }
//
//
//    func initialize(){
//        disconnect()
//        //Initializes the ARDAppClient with the delegate assignment
//        client = ARDAppClient.init(delegate: self)
//
//        //RTCEAGLVideoViewDelegate provides notifications on video frame dimensions
//        self.remoteView?.delegate = self
//        //        self.localView?.delegate = self
//        settingModel.storeVideoResolutionSetting("1024x768")
//    }
//
//
//    //connect to Room
//    func connectToChatRoom(callID: String){
//
//        let callId  = callID.replacingOccurrences(of: " ", with: "")
//        client?.connectToRoom(withId: callId, settings: settingModel, isLoopback: false)  //channelName!
//    }
//
//    func switchLocalRemoteView(_localView : RTCEAGLVideoView!, _remoteView: RTCEAGLVideoView!)  {
//
//
//        //        if(localVideoTrack != nil){
//        //            localVideoTrack?.remove(localView!)
//        //        }
//
//        if(remoteVideoTrack != nil){
//            remoteVideoTrack?.remove(remoteView!)
//        }
//
//        // self.remoteVideoTrack?.remove(self.remoteView)
//
//        //        self.localVideoTrack?.add(_localView)
//        self.remoteVideoTrack?.add(_remoteView)
//
//        //        self.localView = _localView
//        self.remoteView = _remoteView
//    }
//
//
//
//    //disconnect from webrtc
//    func disconnect(){
//        if(client != nil){
//            //            if(localVideoTrack != nil && localView != nil){
//            //                localVideoTrack?.remove(localView!)
//            //            }
//
//            if(remoteVideoTrack != nil && remoteView != nil){
//                remoteVideoTrack?.remove(remoteView!)
//            }
//
//            //            localVideoTrack = nil
//            localCaptureView?.captureSession = nil
//            remoteVideoTrack = nil
//            captureController?.stopCapture()
//            captureController = nil
//            client?.disconnect()
//            let session = AVAudioSession.sharedInstance()
//            do {
//                try session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode(rawValue: convertFromAVAudioSessionMode(AVAudioSession.Mode.default)), options: [])
//                try session.setActive(false)
//            } catch let error as NSError {
//                print("Unable to activate audio session:  \(error.localizedDescription)")
//            }
//        }
//    }
//
//    /// To end call if call disconnect from another user on swiping
//    func removeCallingUIAndSetUserStatus(){
//        //End call
//        //        let callID = message["callId"] as! String
//        guard let userID = Utility.getUserid() else { return }
//
//        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
//        UserDefaults.standard.synchronize()
//        let window = UIApplication.shared.keyWindow!
//        if  let  audioView = window.viewWithTag(15) as? AudioCallView{
//
//            //            if callID == audioView.callId{
//            audioView.timer?.invalidate()
//            MQTTCallManager.cxProviderCallEnd()
//            audioView.playSound("end_of_call", loop: 0)
//            let when = DispatchTime.now() + 0.30
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                if audioView.chatViewObj != nil {audioView.chatViewObj?.inputToolbar.isHidden = false}
//                audioView.removeFromSuperview()
//            }
//            MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
//        }
//
//        if let incomingView = window.viewWithTag(16) as? IncomingAudiocallView{
//            incomingView.player?.stop()
//            incomingView.timer?.invalidate()
//            incomingView.playSound("end_of_call", loop: 0)
//            let when = DispatchTime.now() + 0.30
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                if incomingView.chatViewObj != nil {incomingView.chatViewObj?.inputToolbar.isHidden = false}
//                incomingView.removeFromSuperview()
//            }
//
//            MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
//        }
//
//
//        if let videoView = appDelegetConstant.window.viewWithTag(17) as? IncomingVideocallView{
//            if(client != nil){
//                //                if(localVideoTrack != nil){
//                //                    localVideoTrack?.remove(localView!)
//                //                }
//
//                if(remoteVideoTrack != nil){
//                    remoteVideoTrack?.remove(remoteView!)
//                }
//
//                //                localVideoTrack = nil
//                remoteVideoTrack = nil
//            }
//            videoView.timer?.invalidate()
//            videoView.playSound("end_of_call", loop: 0)
//            let when = DispatchTime.now() + 0.30
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                if videoView.chatViewObj != nil {videoView.chatViewObj?.inputToolbar.isHidden = false}
//                videoView.removeFromSuperview()
//            }
//
//            MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
//        }
//
//        //check cxprovider object
//        let appdele = UIApplication.shared.delegate as? AppDelegate
//        if ((appdele?.callProviderDelegate) != nil){
//
//            do {
//                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
//                try AVAudioSession.sharedInstance().setActive(false)
//            } catch _ {
//            }
//
//            appdele?.callProviderDelegate?.provider.reportCall(with: (appdele?.callProviderDelegate?.uuId)!, endedAt: nil, reason: .remoteEnded)
//            MQTTCallManager.sendcallAvilibilityStatus(status: 1, topic: AppConstants.MQTT.callsAvailability + userID)
//        }
//
//        NotificationCenter.default.post(name: NSNotification.Name(AppConstants.refreshHistoryNotification), object: nil)
//
//    }
//
//
//    func remoteDisconnected(){
//        if(remoteVideoTrack != nil){
//            remoteVideoTrack?.remove(remoteView!)
//        }
//        remoteVideoTrack = nil
//    }
//
//
//
//    //   MARK:-  RTCEAGLVideoViewDelegate
//    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
//        switch state{
//        case ARDAppClientState.connected:
//
//            DDLogDebug("Client Connected")
//
//            DDLogDebug("AppRTC CallConnected********************************")
//
//            break
//        case ARDAppClientState.connecting:
//            print("\n\n**************************channel connectiong status**************************\n\n")
//            if (delegate != nil){
//                delegate?.appClientStatus!(client, status: ARDAppClientState.connecting)
//            }
//
//            DDLogDebug("AppRTC CallConnecting*****************************")
//            DDLogDebug("Client Connecting")
//
//            break
//        case ARDAppClientState.disconnected:
//            DDLogDebug("Client Disconnected")
//            DDLogDebug("AppRTC CallDisconnected********************************")
//            //            remoteDisconnected()
//            break
//        }
//    }
//
//    func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
//        switch state {
//        case .connected:
//            print("\n\n**************ICE connected************************\n\n")
//
//            if (delegate != nil){
//                delegate?.appClientStatus!(client, status: .connected)
//            }
//            captureController?.startCapture()
//            do{
//                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
//            }catch let error{
//                print(error.localizedDescription)
//            }
//
//            break
//        case .disconnected:
//            if (delegate != nil){
//                delegate?.appClientStatus!(client, status: ARDAppClientState.disconnected)
//            }
//            print("disconnected ICE")
//            break
//        default:
//            break
//        }
//    }
//
//    func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
//        print("*********\n\n ***start capture video *******\n\n")
//        self.localCaptureView?.captureSession = localCapturer.captureSession
//        captureController = ARDCaptureController(capturer: localCapturer, settings: settingModel)
//        //        captureController?.startCapture()
//    }
//
//    func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
//
//    }
//
//    func appClient(_ client: ARDAppClient!, didCreateLocalFileCapturer fileCapturer: RTCFileVideoCapturer!) {
//
//    }
//
//
//    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
//        print("*********\n\n ***Local video render *******\n\n")
//        DDLogDebug("*********\n\n ***local video render *******\n\n")
//        //        self.localVideoTrack = localVideoTrack
//        //        if let view = localView{
//        //            self.localVideoTrack?.add(view)
//        //        }
//        if (delegate != nil){
//            delegate?.appClientStatus!(client, status: ARDAppClientState.connecting)
//        }
//    }
//
//    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
//        print("*********\n\n ***Remote video render *******\n\n")
//        DDLogDebug("*********\n\n ***Remote video render *******\n\n")
//        self.remoteVideoTrack = remoteVideoTrack
//
//        if let view = remoteView{
//            self.remoteVideoTrack?.add(view)
//        }
//    }
//
//    func appClient(_ client: ARDAppClient!, didError error: Error!) {
//        // Handle the error
//        disconnect()
//        showAlertWithMessage(error.localizedDescription)
//    }
//
//    /// To end call when call status changed to disconnected, error, fail or unregistred from room
//    func appClientCloseConnection() {
//        self.removeCallingUIAndSetUserStatus()
//
//    }
//
//    //    MARK: RTCEAGLVideoViewDelegate
//
//    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
//
//    }
//
//
//    //show alertView
//    func showAlertWithMessage(_ message: String){
//        let alertView: UIAlertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
//        let alertAction: UIAlertAction = UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.cancel, handler: nil)
//        alertView.addAction(alertAction)
//        DispatchQueue.main.async {
//            UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
//        }
//    }
//
//    //MARK:- phone call action
//
//    /// To enable speaker in audio and video call
//    func enableSpeaker(){
//        do{
//            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
//        }catch let error{
//            print(error.localizedDescription)
//        }
//    }
//
//    /// To disable speaker in audio and video call
//    func disableSpeaker(){
//        do{
//            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
//        }catch let error{
//            print(error.localizedDescription)
//        }
//    }
//
//
//    /// To switch camera in video call if front camera is active then switch to back and if back camera is active then switch to front camera
//    func switchCamera(){
//        captureController?.switchCamera()
//    }
//
//    /// To mute call in audio and video call
//    func muteCall(){
//        self.client?.muteAudioIn()
//    }
//    /// To unmute call in audio and video call
//    func unMuteCall(){
//        self.client?.unmuteAudioIn()
//    }
//
//    //    - (RTCVideoTrack *)createLocalVideoTrack {
//    //    if ([_settings currentAudioOnlySettingFromStore]) {
//    //    return nil;
//    //    }
//    func createLocalViewTrack(){
//        if settingModel.currentAudioOnlySettingFromStore(){
//            print("failed")
//            return
//        }
//        //        s
//    }
//}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionMode(_ input: AVAudioSession.Mode) -> String {
	return input.rawValue
}
