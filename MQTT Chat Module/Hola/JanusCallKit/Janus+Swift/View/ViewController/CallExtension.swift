//
//  CallExtension.swift
//  janus-gateway-ios
//
//  Created by Vengababu Maparthi on 19/02/19.
//  Copyright © 2019 MineWave. All rights reserved.
//

import Foundation
import CallKit
import PushKit

extension CallViewController {
    
    @IBAction func exitCall(_ sender: Any?) {
        if self.callType == .Audio{
            self.lblAudioCallStatus.text = "Call ended"
            let appde = UIApplication.shared.delegate as! AppDelegate
            appde.callProviderDelegate?.endCall(call: self.callManager.calls.first?.uuid ?? UUID())
            
        }else{
            self.lblOutGoingVideoCallStatus.isHidden = false
            self.lblOutGoingVideoCallStatus.text = "Call ended"
        }
        self.stopSound()
        self.call?.didLeaveTheCall = {
            
        }
        if let id = UserDefaults.standard.value(forKey:"LEAVEID" ) as? Int{
            self.call?.onLeaving(id as NSNumber)
        }
        self.exitCall()
    }
    
    
    
    func exitCall(){
        UserDefaults.standard.setValue(true, forKey: "IsDisconnected")
        self.callNotAnsweredTimer?.invalidate()
        disconnectTheCall()
    }

    
    func disconnectTheCall(){
        self.viewModel.disconnectingCall {
            let appdel = UIApplication.shared.delegate as! AppDelegate
            if let views = appdel.window?.subviews, views.contains(where: {
                $0.parentViewController?.isKind(of: CallViewController.self) ?? false
            }){
                self.playSound("end_of_call", loop: 0,overRide: .speaker)
            }
            
            MQTTManager.shared.isDisplayed = false
            self.view.removeFromSuperview()
            self.dismiss(animated: false) {
            }
        }
        UserDefaults.standard.set(false, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func mikeConfigure(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            if call == nil || call?.localAudioTrack == nil {
                let audioCallKitManager = AudioCallKitManager.sharedInstance
                audioCallKitManager.call.localAudioTrack?.isEnabled = true
            }else{
                call?.localAudioTrack?.isEnabled = true
            }
        } else {
            sender.isSelected = true
            if call == nil || call?.localAudioTrack == nil {
                let audioCallKitManager = AudioCallKitManager.sharedInstance
                audioCallKitManager.call.localAudioTrack?.isEnabled = false
            }else{
                call?.localAudioTrack?.isEnabled = false
            }
        }
    }
    
    @IBAction func speakerConfigure(_ sender: UIButton){
        if sender.isSelected {
            sender.isSelected = false
            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,options: [.allowBluetooth,.allowBluetoothA2DP])
        } else {
            sender.isSelected = true
            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,options: [.allowBluetooth,.allowBluetoothA2DP,.defaultToSpeaker])
        }
    }
    
    func playSound(_ soundName: String,loop: Int, overRide : AVAudioSession.PortOverride = .none){
        if soundName == "end_of_call" {
            print("----end call log")
        }
        if UIApplication.shared.applicationState == .active {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav")else{ return}
            do {
                
                /*
                 Bug Name :- Video call: We are not able to connect to the Bluetooth device in video call
                 Fix Date :- 31/03/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- Added options  .allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP for audio session , if user want to switch from bluetooth to speaker or microphone , user has to turn of bluetooth from mobile settings
                 */
                if overRide == .none {
                    try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP,.allowAirPlay])
                }else{
                    try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP,.allowAirPlay,.defaultToSpeaker])
                }
                
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(overRide)
                try AVAudioSession.sharedInstance().setActive(true)
                self.player  = try AVAudioPlayer(contentsOf: url)
                self.player?.delegate = self
                self.player?.numberOfLoops = loop
                guard let playerObj = self.player else { return }
                playerObj.play()
                /*
                 Bug Name :- Call: The ringing is not appropriate for the caller
                 Fix Date :- 03/04/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- Added timer for making sound to speaker if mobile is away from head
                 */
                
            }catch let error{
                print("error \(error.localizedDescription)")
            }
        }
    }
    
    func stopSound(){
        guard let player = self.player else { return }
        player.stop()
    }
    
}
