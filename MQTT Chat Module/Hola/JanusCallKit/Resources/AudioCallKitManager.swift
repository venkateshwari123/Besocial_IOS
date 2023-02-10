//
//  AudioCallKitManager.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 12/10/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
import CallKit
import UIKit
class AudioCallKitManager:NSObject {
    
    let call = ConferenceView()
    let viewModel = CallViewModel()
    var uuid:UUID?
    static let sharedInstance = AudioCallKitManager()
    
    var callJoinedSuccessfully : (() -> ())?
    func initiateBackGroundCall(uuid: UUID,data: [String:Any]) {
        self.uuid = uuid
        if let room = data["room"] as? String, let callId = data["callId"] as? String
        {
            self.viewModel.callId = callId
            self.viewModel.room = Int64(room)
            self.setupJanusCallKit()
        }
    }
    
    
    func setupJanusCallKit() {
        self.call.delegate = self
        if let room = self.viewModel.getRoom() {
            self.call.roomId = room
        }
        self.call.callType = .Audio
        self.call.initialUpdateTheView()
    }
    
    
    
    func disConnectAudioCallFromJanus(uuid: UUID,data:[String:Any], completionHandler:@escaping()->Void){
        self.uuid = uuid
        if let room = data["room"] as? String, let callId = data["callId"] as? String, let action = data["action"] as? Int, action == 1{
            self.viewModel.callId = callId
            self.viewModel.room = Int64(room)
            completionHandler()
        }
        self.call.onLeaving(nil)
        self.viewModel.disconnectingCall {
            MQTTManager.shared.isDisplayed = false
            UserDefaults.standard.set(false, forKey: "iscallgoingOn")
            UserDefaults.standard.synchronize()
            let appdel = UIApplication.shared.delegate as! AppDelegate
            if let views = appdel.window?.subviews, let callView = views.first(where: {
                $0.parentViewController?.isKind(of: CallViewController.self) ?? false
            }){
                callView.removeFromSuperview()
            }
            
            MQTTManager.shared.isDisplayed = false
        }
    }
}

extension AudioCallKitManager : ConferenceDelegate{
    func getTheStreamData(views: [UIView]) {
        
    }
    
    func getTheLocalView(view: UIView) {
        
    }
    
    func joinedRoom() {
        callJoinedSuccessfully?()
        viewModel.joinACall()
        UserDefaults.standard.set(true, forKey: "iscallgoingOn")
        UserDefaults.standard.synchronize()
        
    }
    
    func disConnectTheCall() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.callProviderDelegate?.reportEndCall(uuid)
            if let views = appDelegate.window?.subviews, let view = views.first(where: {
                $0.parentViewController?.isKind(of: CallViewController.self) ?? false
            }){
                view.removeFromSuperview()
                view.parentViewController?.dismiss(animated: false, completion: nil)
            }
            UserDefaults.standard.set(false, forKey: "iscallgoingOn")
            UserDefaults.standard.synchronize()
    }
        
    }
