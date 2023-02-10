//
//  VideoCallExtension.swift
//  janus-gateway-ios
//
//  Created by Vengababu Maparthi on 18/02/19.
//  Copyright © 2019 MineWave. All rights reserved.
//

import Foundation
import CallKit
import PushKit

extension CallViewController {
    
    @IBAction func switchCamera(_ sender: Any) {
        if let cameraVie = localView as? RTCCameraPreviewView {
            guard let session = cameraVie.captureSession,
                let currentCameraInput: AVCaptureInput = session.inputs.first else {
                return
            }
            session.removeInput(currentCameraInput)
            
            //Get new input
            var newCamera: AVCaptureDevice! = nil
            if let input = currentCameraInput as? AVCaptureDeviceInput {
                newCamera = cameraWithPosition(position: input.device.position == .back ? .front : .back)
            }
            
            //Add input to session
            var error: NSError?
            var newVideoInput: AVCaptureDeviceInput!
            do {
                newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            } catch let error1 as NSError {
                error = error1
                newVideoInput = nil
            }
            
            if newVideoInput == nil || error != nil {
                print("Error creating capture device input: \(error?.localizedDescription ?? "")")
            } else {
                session.addInput(newVideoInput)
            }
            //Commit all the configuration changes at once
            session.commitConfiguration()
        }
    }
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    @IBAction func enableVideo(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            call?.localTrack?.isEnabled = true
            /*
             Bug Name :- Video call: on making the video call blank the video pop up of the caller also should be blank
             Fix Date :- 12/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added blackscreen view and handling
             */
            self.blackScreenView.isHidden = true
        } else {
            sender.isSelected = true
            call?.localTrack?.isEnabled = false
            /*
             Bug Name :- Video call: on making the video call blank the video pop up of the caller also should be blank
             Fix Date :- 12/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added blackscreen view and handling
             */
            self.blackScreenView.isHidden = false
        }
    }
    
    @IBAction func addUser(_ sender: Any) {
        print("Add User")
    }
}
