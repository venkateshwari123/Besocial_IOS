//
//  FSCameraVC.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import AVFoundation
import SCRecorder
import MobileCoreServices
import AVKit

public class FSCameraVC: UIViewController, UIGestureRecognizerDelegate {
    
    var session = SCRecordSession()
    var recorder = SCRecorder()
    
    public var usesFrontCamera = false
    public var didCapturePhoto: ((UIImage) -> Void)?
  //  private let sessionQueue = DispatchQueue(label: "FSCameraVCSerialQueue")

//    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    var v = FSCameraView()
    var isPreviewSetup = false
    
    //MARK:- View life cycle
    override public func loadView() { view = v }
    
    convenience init(shouldUseFrontCamera: Bool) {
        self.init(nibName:nil, bundle:nil)
        usesFrontCamera = shouldUseFrontCamera
        title = "Photo".localized
//        sessionQueue.async { [unowned self] in
//            self.cameraSetup()
//        }
        DispatchQueue.main.async {
              self.cameraSetup()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        v.flashButton.isHidden = true
        v.flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        v.shotButton.addTarget(self, action: #selector(shotButtonTapped), for: .touchUpInside)
        v.flipButton.addTarget(self, action: #selector(flipButtonTapped), for: .touchUpInside)
        v.videoSpeedView.isHidden = true
        v.removeLastButton.isHidden = true
        v.addAudioButton.isHidden = true
        let shotImage = imageFromBundle("camera_btn")
        v.shotButton.setImage(shotImage, for: .normal)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isPreviewSetup {
            isPreviewSetup = true
            setupPreview()
            self.checkCameraPermission()
        }
        refreshFlashButton()
    }
    
    func checkCameraPermission(){
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
            if granted == true {
                self.startCamera()
            } else {
                // User rejected
            }
        })
    }
    
    func setupPreview() {
        recorder.previewView = v.previewViewContainer
    }
    
    
    func cameraSetup() {
        //        recorder.audioConfiguration.enabled = false
        if (!recorder.startRunning()) {
            debugPrint("Recorder error: ", recorder.error ?? "")
        }
        
        recorder.mirrorOnFrontCamera = true
        DispatchQueue.main.async {
            self.v.removeLastButton.isEnabled = false
        }
        recorder.session = session
        recorder.initializeSessionLazily = false
        
        // Whether the output video size should be infered so it creates a square video
        recorder.videoConfiguration.scalingMode = AVVideoScalingModeResizeAspectFill;
        recorder.videoConfiguration.sizeAsSquare = true
    }
    
//    func focus(_ recognizer: UITapGestureRecognizer) {
//        let point = recognizer.location(in: v.previewViewContainer)
//        let viewsize = v.previewViewContainer.bounds.size
//        let newPoint = CGPoint(x:point.x/viewsize.width, y:point.y/viewsize.height)
//        setFocusPointOnDevice(device: device!, point: newPoint)
//        focusView.center = point
//        configureFocusView(focusView)
//        v.addSubview(focusView)
//        animateFocusView(focusView)
//    }
    
    func startCamera() {
         if !recorder.isRecording{
           // sessionQueue.async { [unowned self] in
                // Re-apply session preset
                       DispatchQueue.main.async {
                let status = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
                switch status{
                case .notDetermined, .restricted, .denied:
                    self.recorder.stopRunning()
                    break
                case .authorized:
                    self.recorder.startRunning()
                }
            }
        }
    }
    
    func stopCamera() {
//        sessionQueue.async { [weak self] in
//            if let this = self, this.recorder.captureSession != nil{
//                this.recorder.stopRunning()
//            }
//        }
           DispatchQueue.main.async {
                        if self.recorder.captureSession != nil{
                            self.recorder.stopRunning()
                        }
        }
    }
    
    //MARK:- Button action
    @objc func flipButtonTapped() {
//        sessionQueue.async { [unowned self] in
            DispatchQueue.main.async {
            if self.recorder.device ==  AVCaptureDevice.Position.front {
                self.recorder.device = AVCaptureDevice.Position.back
            } else {
//                turnFlashOff()
                self.recorder.device = AVCaptureDevice.Position.front
                self.recorder.device = AVCaptureDevice.Position.front
            }
        }
    }
    
    @objc func shotButtonTapped() {
        
        
        self.recorder.capturePhoto( { (error,capturedImage) in
            if error == nil {
                //image captured successfully.
                print("")
                
                let shutterView = UIView(frame: self.self.v.previewViewContainer.frame)
                shutterView.backgroundColor = UIColor.white
                self.v.previewViewContainer.addSubview(shutterView)
                Helper.showPI(_message: " " + "Loading filters".localized + " ")
                UIView.animate(withDuration: 0.3, animations: {
                     shutterView.alpha = 0
                }, completion: { (_) in
                    
                    shutterView.removeFromSuperview()
                    var flippedImage = capturedImage
                    let iw = flippedImage!.size.width
                    let ih = flippedImage!.size.height
                    // Frame size
                    let sw = self.v.previewViewContainer.frame.width
                    // The center coordinate along Y axis
                    let rcy = ih * 0.5
                    let imageRef = flippedImage!.cgImage?.cropping(to: CGRect(x: rcy-iw*0.5, y: 0, width: iw, height: iw))
                    DispatchQueue.main.async {
                        var resizedImage = UIImage(cgImage: imageRef!, scale: 1.0, orientation: flippedImage!.imageOrientation)
                        if let cgImg =  resizedImage.cgImage, self.recorder.device == AVCaptureDevice.Position.front {
                            func flipImage(image: UIImage!) -> UIImage! {
                                let imageSize: CGSize = image.size
                                UIGraphicsBeginImageContextWithOptions(imageSize, true, 1.0)
                                let ctx = UIGraphicsGetCurrentContext()!
                                ctx.rotate(by: CGFloat(Double.pi/2.0))
                                ctx.translateBy(x: 0, y: -imageSize.width)
                                ctx.scaleBy(x: imageSize.height/imageSize.width, y: imageSize.width/imageSize.height)
                                ctx.draw(image.cgImage!, in: CGRect(x:0.0,
                                                                    y:0.0,
                                                                    width:imageSize.width,
                                                                    height:imageSize.height))
                                let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                                UIGraphicsEndImageContext()
                                return newImage
                            }
                            resizedImage = flipImage(image: resizedImage)
                        }
                        self.didCapturePhoto?(resizedImage)
                    }
                })
            }
        })
    }
    
    @objc func flashButtonTapped() {
        if recorder.device == AVCaptureDevice.Position.front {
            return
        }
        
        guard let device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    
    func refreshFlashButton() {
        guard let device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) else { return }
        guard device.hasTorch else { return }
        v.flashButton.setImage(flashImage(forAVCaptureFlashMode:device.flashMode), for: .normal)
        v.flashButton.isHidden = !device.hasFlash
    }
    
    func flashImage(forAVCaptureFlashMode: AVCaptureDevice.FlashMode) -> UIImage {
        switch forAVCaptureFlashMode {
        case .on: return flashOnImage!
        case .off: return flashOffImage!
        default: return flashOffImage!
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}
