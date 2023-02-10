//
//  PermissionView.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 08/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class PermissionView: UIView {

    @IBOutlet weak var cameraPermissonBtn: UIButton!
    @IBOutlet weak var microPhnPermissonBtn: UIButton!
    @IBOutlet weak var galleryPermissionBtn: UIButton!
    @IBOutlet weak var descriptionLbl1: UILabel!
    @IBOutlet weak var descriptionLbl2: UILabel!
    @IBOutlet weak var shootAVideoLbl: UILabel!
        
    
    var didDismissPermissionView: (()-> Void)?
    var allPermissionDone: (()-> Void)?
    
    var isCameraPermitted: Bool = false
    var isGalleryPermitted: Bool = false
    var isMicPermitted: Bool = false
    
    var isCameraDenied: Bool = false
    var isGalleryDenied: Bool = false
    var isMicDenied: Bool = false
    
    class func instanceFromNib() -> PermissionView {
        return UINib(nibName: "PermissionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PermissionView
    }

    override func awakeFromNib(){
        cameraPermissonBtn.setTitle("Allow access to camera".localized, for: .normal)
        galleryPermissionBtn.setTitle("Allow access to gallery".localized, for: .normal)
        descriptionLbl1.text = "Grant Camera access to shoot".localized
        descriptionLbl2.text = "Grant gallery access to pick photo and video".localized
        shootAVideoLbl.text = "Shoot a video".localized
        self.checkCameraPermissions()
        self.checkMicPermission()
        self.checkGalleryPermission()
    }
    
    private func updateUIForPermission(){
        if self.isCameraPermitted && self.isGalleryPermitted{
            if self.allPermissionDone != nil{
                self.allPermissionDone!()
            }
        }
    }
    
    func checkCameraPermissions() {
        UserDefaults.standard.set(true, forKey:"isAppRequestedVideo")
        UserDefaults.standard.synchronize()
        if AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            DispatchQueue.main.async {
                self.cameraPermissonBtn.isEnabled = false
                self.isCameraPermitted = true
                self.updateUIForPermission()
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isAppRequestedVideo)
            }
        } else if AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) ==  AVAuthorizationStatus.denied {
            // Already Authorized
            DispatchQueue.main.async {
                self.isCameraPermitted = false
                self.isCameraDenied = true
                self.updateUIForPermission()
                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isAppRequestedVideo)
            }
        }else {
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)), completionHandler: { (granted: Bool) -> Void in
                
                DispatchQueue.main.async {
                    if granted == true {
                        // User granted
                        self.cameraPermissonBtn.isEnabled = false
                        self.isCameraPermitted = true
                        self.updateUIForPermission()
                        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isAppRequestedVideo)
                    } else {
                        // User rejected.
                        self.isCameraPermitted = false
                        self.isCameraDenied = true
                        self.updateUIForPermission()
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isAppRequestedVideo)
                    }
                }
                
            })
        }
    }
    
    
    func checkMicPermission() {
        UserDefaults.standard.set(true, forKey:"isAppRequestedAudio")
        UserDefaults.standard.synchronize()
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            DispatchQueue.main.async {
                self.microPhnPermissonBtn.isEnabled = false
                self.isMicPermitted = true
                self.updateUIForPermission()
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isAppRequestedAudio)
            }
        case AVAudioSession.RecordPermission.denied: do {
            DispatchQueue.main.async {
                self.isMicPermitted = false
                self.isMicDenied = true
                self.updateUIForPermission()
                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isAppRequestedAudio)
            }
            }
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                
                DispatchQueue.main.async {
                    if granted {
                        self.microPhnPermissonBtn.isEnabled = false
                        self.isMicPermitted = true
                        self.updateUIForPermission()
                        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isAppRequestedAudio)
                    } else {
                        self.isMicPermitted = true
                        self.isMicDenied = true
                        self.updateUIForPermission()
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isAppRequestedAudio)
                    }
                }
            })
        default:
            break
        }
    }
    
    
    func checkGalleryPermission() {
        UserDefaults.standard.set(true, forKey:"isAppRequestedAudio")
        UserDefaults.standard.synchronize()
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //handle authorized status
            DispatchQueue.main.async {
                self.isGalleryPermitted = true
                self.galleryPermissionBtn.isEnabled = false
                self.updateUIForPermission()
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isAppRequestedGallery)
            }
            break
        case .denied, .restricted :
            //handle denied status
            DispatchQueue.main.async {
                self.isGalleryPermitted = false
                self.isGalleryDenied = true
                self.galleryPermissionBtn.isEnabled = true
                self.updateUIForPermission()
                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isAppRequestedGallery)
            }
            break
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self.isGalleryPermitted = true
                        self.galleryPermissionBtn.isEnabled = false
                        self.updateUIForPermission()
                        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isAppRequestedGallery)
                    }
                    break
                // as above
                case .denied, .restricted:
                    DispatchQueue.main.async {
                        self.isGalleryPermitted = false
                        self.isGalleryDenied = true
                        self.galleryPermissionBtn.isEnabled = true
                        self.updateUIForPermission()
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isAppRequestedGallery)
                    }
                    break
                // as above
                case .notDetermined:
                    UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isAppRequestedGallery)
                    break
                    // won't happen but still
                case .limited:
                    break
                }
            }
        case .limited:
            break
        }
    }
    
    //MARK:- Buttons Action
    @IBAction func dismissViewAction(_ sender: Any) {
        self.didDismissPermissionView!()
    }
    
    
    @IBAction func cameraAccessBtnAction(_ sender: Any) {
        if self.isCameraDenied{
            Utility.openSettingsPage(message: Strings.PermissionMessage.cameraPermission.localized)
        }else{
            self.checkCameraPermissions()
        }
    }
    
    @IBAction func microPhoneBtnAction(_ sender: Any) {
        if self.isMicDenied{
            Utility.openSettingsPage(message: Strings.PermissionMessage.micPermission.localized)
        }else{
            self.checkMicPermission()
        }
    }
    
    @IBAction func galleryBtnAction(_ sender: Any) {
        if self.isGalleryDenied{
            Utility.openSettingsPage(message: Strings.PermissionMessage.galleryPermission.localized)
        }else{
            self.checkGalleryPermission()
        }
    }
    

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}
