//
//  IncomingCallExtension.swift
//  GroupCalling
//
//  Created by 3Embed on 18/12/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
import Kingfisher
import CocoaLumberjack

extension CallViewController{
    
    func showUserInformation() {
        if let usrData = userData , userData != nil{
            if let callType = usrData["type"] as? String{
                print(callType)
                if callType.lowercased() == "video" {
                    lblIncomingCallType.text = "Incoming Video Call"
                }else{
                    lblIncomingCallType.text = "Incoming Audio Call"
                }
            }
            if let username = userData["userName"] as? String{
                lblUserName.text = username
                lblAudioUserName.text = username
                lblOutGoingVideoCallUserName.text = username
            }
            if let imageUrl = userData["userImage"] as? String, let url = URL(string: imageUrl) {
                let processor = RoundCornerImageProcessor(cornerRadius: userImage.bounds.size.height/2)
                userImage.kf.indicatorType = .activity
                
                /*
                 Bug Name :- Call Module: The user profile pic is not being displayed to the caller on calling an user
                 Fix Date :- 06/04/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- Before the place holder asset was not available. We changed default placeholder
                 */
                userImage.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "voice_call_profile_default_image"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                {
                    result in
                    switch result {
                    case .success(_): break
                    case .failure(let error): DDLogError("Image not downloaded and error is \(error.localizedDescription)")
                    }
                }
                /*
                 Bug Name :- Call Module: The user profile pic is not being displayed to the caller on calling an user
                 Fix Date :- 06/04/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- changed default placeholder , before place holder asset not available
                 */
                imgAudioCallee.kf.indicatorType = .activity
                imgAudioCallee.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "voice_call_profile_default_image"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                {
                    result in
                    switch result {
                    case .success(_): break
                    case .failure(let error): DDLogError("Image not downloaded and error is \(error.localizedDescription)")
                    }
                }
                
                imgBackground.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "giphyDefaultlogo"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                {
                    result in
                    switch result {
                    case .success(_): break
                    case .failure(let error): DDLogError("Image not downloaded and error is \(error.localizedDescription)")
                    }
                }
                
                imgIncomingBackground.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "giphyDefaultlogo"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                {
                    result in
                    switch result {
                    case .success(_): break
                    case .failure(let error): DDLogError("Image not downloaded and error is \(error.localizedDescription)")
                    }
                }
            }
        }

    }
    func setupActiveCall() {
        vwIncomingCall.isHidden = true
        vwIncomingCall.isHidden = true
        lblVideoCallHeader.isHidden = true
        lblOutGoingVideoCallStatus.isHidden = true
        lblOutGoingVideoCallUserName.isHidden = true
        showUserInformation()
        if callType == .Audio {
            self.callDisplayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(_:)) , userInfo: nil, repeats: true)
            self.lblAudioCallStatus.text = self.timeString(time: TimeInterval(self.seconds))
        }
    }
    
    func setupIncomingCall() {
        vwIncomingCall.isHidden = false
        showUserInformation()
        playSound("ringtone", loop: 2,overRide: .speaker)
        lblVideoCallHeader.isHidden = true
        lblOutGoingVideoCallStatus.isHidden = true
        lblOutGoingVideoCallUserName.isHidden = true
    }
    
    func setupOutgoingCall() {
        self.showUserInformation()
        setupJanusCallKit()
        
        /*
         Bug Name :- iOS: When calling from an iOS device that has a SIM, the calls rings twice and stops. But user 2 is able to hear the ring.
         Fix Date :- 23/03/2021
         Fixed By :- Jayaram G
         Description Of Fix :- increase audio loop count and added proximityState for speaker and microphone
         */
        DispatchQueue.main.async {
            if self.callType == .Audio {
                    self.playSound("calling", loop: 40)
            }else{
                self.lblVideoCallHeader.isHidden = false
                self.lblOutGoingVideoCallStatus.isHidden = false
                self.lblOutGoingVideoCallUserName.isHidden = false
                self.playSound("calling", loop: 40, overRide: .speaker)
            }
        }
    }
    

    
    func hideIncomingCallView() {
        vwIncomingCall.isHidden = true
    }
    
    @IBAction func btnRejectIncomingCall_Tapped(sender: UIButton){
        self.stopSound()
        viewModel.disconnectingCall(CallState.request.description) {
            self.view.removeFromSuperview()
            self.dismiss(animated: false) {
            }
        }
        MQTTManager.shared.isDisplayed = false
    }
    
    @IBAction func btnAcceptIncomingCall_Tapped(sender: UIButton?){
            self.setupJanusCallKit()
            self.hideIncomingCallView()
            if self.callType == .Audio {
                /*
                 Bug Name :- Call duration not syncing on both sender and receiver side
                 Fix Date :- 25/03/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- removed call duration here , because we are starting timer after call connected on both sides only
                 */
//                self.callDisplayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(_:)) , userInfo: nil, repeats: true)
//                self.lblAudioCallStatus.text = self.timeString(time: TimeInterval(self.seconds))
            }
            self.stopSound()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                /*
                 Bug Name :- Video call: We are not able to connect to the Bluetooth device in video call
                 Fix Date :- 31/03/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- Added options  .allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP for audio session , if user want to switch from bluetooth to speaker or microphone , user has to turn of bluetooth from mobile settings
                 */
                try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP,.allowAirPlay,.defaultToSpeaker])
            }
            UserDefaults.standard.set(true, forKey: "iscallgoingOn")
            UserDefaults.standard.synchronize()
        }
}


extension CallViewController : AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        print("sound finished here ...")
    }
}
