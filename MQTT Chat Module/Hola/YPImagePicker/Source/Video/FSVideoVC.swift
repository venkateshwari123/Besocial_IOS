//
//  FSVideoVC.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import AVFoundation
import SCRecorder
import MobileCoreServices
import AVKit

class FSVideoVC: UIViewController {
    
    var session = SCRecordSession()
    var recorder = SCRecorder()
    
    var maxVideoSeconds = 60
    var minVideoSeconds = 5
    
    var zoomFactor:CGFloat = 1.0
    var lastSegmentTime = 0
    var lastSegementProgressViewTag = 1000
    var originalFrameOfRecordView:CGRect?
    var longGesture:UILongPressGestureRecognizer?
    var tapgesture:UITapGestureRecognizer?

    var focusView:SCRecorderToolsView?

    var audioPlayer: AVAudioPlayer?
    var selectedAudio:Audio?
    var isCameraSet: Bool = false
    
    var enableNextButton:((Bool) -> Void)?
    
    public var didCaptureVideo: ((URL) -> Void)?
    //private let sessionQueue = DispatchQueue(label: "FSVideoVCSerialQueue")
    //    let session = AVCaptureSession()
    
    var device: AVCaptureDevice? {
        return videoInput?.device
    }
    fileprivate var videoInput: AVCaptureDeviceInput!
    //    fileprivate var videoOutput = AVCaptureMovieFileOutput()
//    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    fileprivate var timer = Timer()
    fileprivate var dateVideoStarted = Date()
    fileprivate var v = FSCameraView()
    fileprivate var lastSelectedSpeedButton:UIButton?
    var isPreviewSetup = false
    
    var isCapturing: Bool = false
    
    override public func loadView() { view = v }
    
    //MARK:- View life cycle
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        title = "Video".localized
        //        sessionQueue.async { [unowned self] in
        //            self.setupCaptureSession()
        //            self.cameraSetup()
        //        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        /*
         Bug Name:- Audio not playing on speaker
         Fix Date:- 02/06/21
         Fix By  :- jayaram G
         Description of Fix:- Added defaultToSpeaker option
         */
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP,.defaultToSpeaker])
        
        v.flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        v.flashButton.isHidden = false
        v.timeElapsedLabel.isHidden = false
        //        v.shotButton.addTarget(self, action: #selector(shotButtonTapped), for: .touchUpInside)
        self.addLongGestureRecornizer()
        v.addAudioButton.addTarget(self, action: #selector(selectAudio), for: .touchUpInside)
        v.addAudioButton.isHidden = false
        v.flipButton.addTarget(self, action: #selector(switchCam), for: .touchUpInside)
        v.videoSpeedView.speedPoint1Button.addTarget(self, action: #selector(videoSpeedAction), for: .touchUpInside)
        v.videoSpeedView.speedPoint5Button.addTarget(self, action: #selector(videoSpeedAction), for: .touchUpInside)
        v.videoSpeedView.speed1Button.addTarget(self, action: #selector(videoSpeedAction), for: .touchUpInside)
        v.videoSpeedView.speed2Button.addTarget(self, action: #selector(videoSpeedAction), for: .touchUpInside)
        v.videoSpeedView.speed3Button.addTarget(self, action: #selector(videoSpeedAction), for: .touchUpInside)
        self.lastSelectedSpeedButton = v.videoSpeedView.speed1Button
        v.removeLastButton.addTarget(self, action: #selector(removeLastSessionButtonAction), for: .touchUpInside)
        v.videoSpeedView.isHidden = false
        v.removeLastButton.isHidden = false
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.v.shotButton.isUserInteractionEnabled = true
        self.v.addAudioButton.isEnabled = true
        
        
        if self.recorder.session != nil{
            self.recorder.session?.removeAllSegments()
            self.removeAllSegementsView()
            v.timeElapsedLabel.text = "00:00"
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isPreviewSetup {
            isPreviewSetup = true
            setupPreview()
            originalFrameOfRecordView = self.v.shotButton.frame
        }
        refreshFlashButton()
        // Become active event
        NotificationCenter.default.addObserver(self, selector: #selector(stopRecording), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //Remove become active observer
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    
    /// To stop recording if recording was running when app enter in background
    @objc func stopRecording(){
        DispatchQueue.main.async{
//            if self.isCapturing{
//                self.recorder.pause({
//                    self.addNewSubView()
//                })
//            }
            self.longGesture?.state = .ended
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.addZoomEffects()
        self.v.shotButton.backgroundColor = UIColor.red
        self.v.shotButton.makeCornerRadious(readious: self.v.shotButton.frame.size.width / 2)
//        originalFrameOfRecordView = self.v.shotButton.frame
    }
    
    func setupPreview() {
        //        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        //        videoLayer?.frame = v.previewViewContainer.bounds
        //        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        //        v.previewViewContainer.layer.addSublayer(videoLayer!)
        recorder.previewView = v.previewViewContainer
        //        let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(focus(_:)))
        //        v.previewViewContainer.addGestureRecognizer(tapRecognizer)
        
    }
    
    func setupButtons() {
        let flipImage = imageFromBundle("Flip")
        videoStartImage = imageFromBundle("camera_btn")
        videoStopImage = imageFromBundle("camera_btn")
        v.flashButton.setImage(flashOffImage, for: .normal)
        v.flipButton.setImage(flipImage, for: .normal)
//        v.shotButton.setImage(videoStartImage, for: .normal)
    }
    
    fileprivate var isRecording = false
    
    //    private func setupCaptureSession() {
    //        session.beginConfiguration()
    //        let aDevice = deviceForPosition(.back)
    //        videoInput = try? AVCaptureDeviceInput(device: aDevice)
    //        if session.canAddInput(videoInput) {
    //            session.addInput(videoInput)
    //        }
    //
    //        // Add audio recording
    //        for device in AVCaptureDevice.devices(withMediaType:AVMediaTypeAudio) {
    //            if let device = device as? AVCaptureDevice, let audioInput = try? AVCaptureDeviceInput(device: device) {
    //                if session.canAddInput(audioInput) {
    //                    session.addInput(audioInput)
    //                }
    //            }
    //        }
    //
    //        let totalSeconds = 15.0 //Total Seconds of capture time
    //        let timeScale: Int32 = 30 //FPS
    //        let maxDuration = CMTimeMakeWithSeconds(totalSeconds, timeScale)
    //        videoOutput.maxRecordedDuration = maxDuration
    //        videoOutput.minFreeDiskSpaceLimit = 1024 * 1024
    //        if session.canAddOutput(videoOutput) {
    //            session.addOutput(videoOutput)
    //        }
    //        session.sessionPreset = AVCaptureSessionPresetHigh
    //        session.commitConfiguration()
    //    }
    
    func cameraSetup() {
        //        recorder.audioConfiguration.enabled = false
        if (!recorder.startRunning()) {
            debugPrint("Recorder error: ", recorder.error ?? "")
        }
        
        //recorder.attemptTurnOffVideoStabilization()
        recorder.mirrorOnFrontCamera = true
        DispatchQueue.main.async {
            self.v.removeLastButton.isEnabled = false
        }
        //        self.nextButton.isEnabled = false
        
        lastSelectedSpeedButton = self.v.videoSpeedView.speed1Button
        
        updateMaxVideoSeconds()
        recorder.session = session
        
        //recorder.device = AVCaptureDevicePosition.front
        recorder.delegate = self
        recorder.initializeSessionLazily = false
        
        // Whether the output video size should be infered so it creates a square video
        recorder.videoConfiguration.scalingMode = AVVideoScalingModeResizeAspectFill;
        recorder.videoConfiguration.sizeAsSquare = true
        //        addLongGestureRecornizer()
        //        updateSelectedAudio()
    }
    
    func updateMaxVideoSeconds() {
        recorder.maxRecordDuration = CMTime(seconds: Double(maxVideoSeconds), preferredTimescale: 1)
    }
    
    
    //    func addLongGestureRecornizer() {
    //        longGesture = UILongPressGestureRecognizer(target: self, action:#selector(longTap(_:)))
    //        gestureViewForVideo.addGestureRecognizer(longGesture!)
    //
    //    }
    
    
    func startCamera() {
        if !recorder.isRecording{
//            sessionQueue.async { [unowned self] in
            DispatchQueue.main.async{
                // Re-apply session preset
                let status = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
                switch status{
                case .notDetermined, .restricted, .denied:
                    self.recorder.stopRunning()
                    break
                case .authorized:
                    if !self.isCameraSet{
                        self.isCameraSet = true
                        self.cameraSetup()
                    }
                    self.recorder.startRunning()
                }
            }
        }
    }
    
    func stopCamera() {
        
        //        if isRecording{
//        sessionQueue.async { [unowned self] in
              DispatchQueue.main.async{
            self.recorder.stopRunning()
            //            }
        }
    }
    
    func removeAllSegementsView() {
        for eachview in  self.v.progressBar.subviews {
            //my year of birth as a tag for mimum duration indicator. :P
            if eachview.tag != 1994 {
                eachview.removeFromSuperview()
            }
        }
    }
    
    //MARK:- Camera long press gesture
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        
        let lastViewPosition = sender.view!.frame
        self.v.shotButton.superview?.bringSubviewToFront(self.v.shotButton)
        if sender.state == .ended {
            self.isCapturing = false
            print("long tap recording ended")
            v.shotButton.backgroundColor = UIColor.red
            audioPlayer?.pause()
            recorder.pause({
                self.addNewSubView()
            })
            v.shotButton.layer.removeAllAnimations()
            self.v.videoSpeedView.isHidden = false
            guard let view = sender.view else {
                return
            }
            
            UIView.animate(withDuration: 0.1, animations: {
                view.frame = self.originalFrameOfRecordView!
                self.view.layoutIfNeeded()
            })
            
        }
        else if sender.state == .began {
            self.isCapturing = true
            print("long tap recording begain")
            lastSegmentTime = 0
            self.v.videoSpeedView.isHidden = true
//            self.hideAllTheTools(ishide:true)
//            self.hideLibraryButton(ishide:true)
            let pulse1 = CASpringAnimation(keyPath: "transform.scale")
            pulse1.duration = 0.5
            pulse1.fromValue = 1.0
            pulse1.toValue = 2.0
            pulse1.autoreverses = true
            pulse1.repeatCount = Float.infinity
            pulse1.initialVelocity = 0.5
            pulse1.damping = 0.8
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 30
            animationGroup.repeatCount = Float.infinity
            animationGroup.animations = [pulse1]
            
            v.shotButton.layer.add(animationGroup, forKey: "pulse")
            
            v.shotButton.backgroundColor = UIColor.yellow
            audioPlayer?.play()
            recorder.record()
            
        } else if sender.state == .changed {
            self.isCapturing = true
            print("long tap recording changing")
            guard let view = sender.view else {
                return
            }
            let location = sender.location(in: self.v.shotButton.superview)
            view.center = CGPoint(x:view.center.x + (location.x - view.center.x),
                                  y:view.center.y + (location.y - view.center.y))
            
            if (lastViewPosition.origin.y < view.frame.origin.y) {
                // moved to top
                print("panning up")
                zoomFactor =  zoomFactor - 0.3
                if(zoomFactor <= 1.0) {
                    zoomFactor = 1.0
                }
                
                print("moving view frame: \(lastViewPosition)")
                
            } else if (lastViewPosition.origin.y > view.frame.origin.y) {
                // moved to bottom
                print("panning down")
                // print("original view frame: \(String(describing: originalFrameOfRecordView))")
                print("moving view frame: \(lastViewPosition)")
                if(lastViewPosition.origin.y <= -50){
                    zoomFactor =  zoomFactor + 0.1
                    if(zoomFactor >= self.recorder.maxVideoZoomFactor) {
                        zoomFactor = self.recorder.maxVideoZoomFactor
                    }
                }
            }
            self.recorder.videoZoomFactor = zoomFactor
        }
    }

    
    func addZoomEffects() {
        focusView = SCRecorderToolsView(frame:self.view.bounds)
        focusView!.recorder = self.recorder
        self.focusView!.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleBottomMargin.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue | UIView.AutoresizingMask.flexibleLeftMargin.rawValue | UIView.AutoresizingMask.flexibleRightMargin.rawValue | UIView.AutoresizingMask.flexibleTopMargin.rawValue | UIView.AutoresizingMask.flexibleWidth.rawValue);
//        self.mainToolsView.addSubview(focusView!)
//        for eachView in self.mainToolsView.subviews {
//            if eachView != self.focusView {
//                self.mainToolsView.bringSubview(toFront:eachView)
//            }
//        }
        
        tapgesture = UITapGestureRecognizer(target: self, action:#selector(switchCam))
        tapgesture?.numberOfTapsRequired = 2
        self.focusView!.addGestureRecognizer(tapgesture!)
    }
    
    
    //MARK:- Buttons Action
    
    func addLongGestureRecornizer() {
        longGesture = UILongPressGestureRecognizer(target: self, action:#selector(longTap(_:)))
        self.v.shotButton.addGestureRecognizer(longGesture!)
        
    }
    
    @objc func selectAudio() {
        let audioVc = AudioListViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Main) as AudioListViewController
        audioVc.delegate = self
        let newNav = UINavigationController(rootViewController: audioVc)
//        newNav.isNavigationBarHidden = true
        audioVc.selectedAudioName = self.selectedAudio?.name ?? ""
        self.navigationController?.present(newNav, animated: true, completion:nil)
    }
    
    //    func flipButtonTapped() {
    //        sessionQueue.async { [unowned self] in
    //            self.session.beginConfiguration()
    //            self.session.resetInputs()
    //            self.videoInput = flippedDeviceInputForInput(self.videoInput)
    //            if self.session.canAddInput(self.videoInput) {
    //                self.session.addInput(self.videoInput)
    //            }
    //
    //            // Re Add audio recording
    //            for device in AVCaptureDevice.devices(withMediaType:AVMediaTypeAudio) {
    //                if let device = device as? AVCaptureDevice, let audioInput = try? AVCaptureDeviceInput(device: device) {
    //                    if self.session.canAddInput(audioInput) {
    //                        self.session.addInput(audioInput)
    //                    }
    //                }
    //            }
    //            self.session.commitConfiguration()
    //            DispatchQueue.main.async {
    //                self.refreshFlashButton()
    //            }
    //        }
    //    }
    
    @objc func switchCam() {
        if recorder.device ==  AVCaptureDevice.Position.front {
            recorder.device = AVCaptureDevice.Position.back
        } else {
            turnFlashOff()
            recorder.device = AVCaptureDevice.Position.front
            recorder.device = AVCaptureDevice.Position.front
        }
    }
    
    
    func turnFlashOff() {
        guard let device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
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
    
        
//        device.tryToggleFlash()
        
    }
    
    @objc func videoSpeedAction(_ sender: Any){
        guard let selectedButton = sender as? UIButton else {return}
        var speedOfVideo = 2.0
        switch selectedButton.tag {
        case 1:
            speedOfVideo = 2.0
        case 2:
            speedOfVideo = 1.5
        case 3:
            speedOfVideo = 1.0
        case 4:
            speedOfVideo = 0.8
        case 5:
            speedOfVideo = 0.6
        default:
            print("hello dinesh")
        }
        
        recorder.videoConfiguration.timeScale = CGFloat(speedOfVideo)
        self.updateButtonForVideoSpeed(selectedSpeed: selectedButton)
        audioPlayer?.rate = Float(speedOfVideo)
    }
    
    func updateButtonForVideoSpeed(selectedSpeed:UIButton) {
        
        v.videoSpeedView.selectedViewLeadingConstraint.constant = self.lastSelectedSpeedButton!.frame.origin.x
        lastSelectedSpeedButton?.setTitleColor(UIColor.white, for: .normal)
        lastSelectedSpeedButton = selectedSpeed
        UIView.animate(withDuration: TimeInterval(0.2), animations: {
            self.v.videoSpeedView.selectedViewLeadingConstraint.constant = self.lastSelectedSpeedButton!.frame.origin.x
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            self.lastSelectedSpeedButton?.setTitleColor(UIColor.darkGray, for: .normal)
        })
    }
    
    func flashImage(forAVCaptureFlashMode: AVCaptureDevice.FlashMode) -> UIImage {
        switch forAVCaptureFlashMode {
        case .on: return flashOnImage!
        case .off: return flashOffImage!
        default: return flashOffImage!
        }
    }
    
    @objc func removeLastSessionButtonAction(_ sender: Any) {
        let alertTitle = "Are you sure you want to delete last segment".localized + "?"
        let alertController = UIAlertController(title:alertTitle, message:nil, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Confirm".localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            self.recorder.session?.removeLastSegment()
            self.audioPlayer?.currentTime = TimeInterval(self.recorder.session!.duration.seconds)
            let time = Int(self.recorder.session!.duration.seconds)
            self.v.timeElapsedLabel.text = self.timeString(time: TimeInterval(time))
                // "00:" + String(format: "%02d", time)
            self.addNewSubView()
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertAction.Style.cancel) {
            (result : UIAlertAction) -> Void in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
}


extension FSVideoVC {
    
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
    
    func refreshFlashButton() {
        guard let device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) else { return }
        guard device.hasTorch else { return }
        v.flashButton.setImage(flashImage(forAVCaptureFlashMode:device.flashMode), for: .normal)
        v.flashButton.isHidden = !device.hasFlash
    }
}

//MARK:- Audio selected delegate
extension FSVideoVC:AudioSelectedDelegate {
    func selectedAudio(selectedAudio: Audio) {
        self.selectedAudio = selectedAudio
        updateSelectedAudio()
    }
    
    func saveSelectedAudio() {
        if let audioUrl = URL(string: selectedAudio!.url) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    func updateSelectedAudio() {
        if self.selectedAudio != nil {
            setupAudioPlayerFromSelectedAudio()
            saveSelectedAudio()
           // recorder.audioConfiguration.enabled = false
            self.v.addAudioButton.setTitle(self.selectedAudio!.name, for:.normal)
        }
    }
    
    
    func setupAudioPlayerFromSelectedAudio() {
        if let audioUrl = URL(string: selectedAudio!.url) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                audioPlayer?.enableRate = true
                audioPlayer?.prepareToPlay()
                maxVideoSeconds = Int(audioPlayer!.duration)
                updateMaxVideoSeconds()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
}


extension FSVideoVC: SCRecorderDelegate {
    
    func recorder(_ recorder: SCRecorder, didAppendVideoSampleBufferIn session: SCRecordSession) {
        let time = Int(self.recorder.session!.duration.seconds)
        v.timeElapsedLabel.text = self.timeString(time: TimeInterval(time))
            //"00:" + String(format: "%02d", time)
        addNewSubView()
    }
    
    
    func recorder(_ recorder: SCRecorder, didComplete session: SCRecordSession) {
                longGesture?.state = .ended
        //        moveToVideoPreviewScreen()
        //        self.gestureViewForVideo.isUserInteractionEnabled = false
        //        self.moveToVideoPreviewScreen(videoPath: outputFileURL.absoluteString)
        moveToVideoPreviewScreen()
        self.v.shotButton.isUserInteractionEnabled = false
    }
    
    func addNewSubView() {
        
        guard let sess = self.recorder.session else {
            return
        }
        var currentSegmentIndex = 0
        if let alreadyCreatedSegements = self.recorder.session?.segments.count{
            currentSegmentIndex = alreadyCreatedSegements
        }
        
        for eachview in  self.v.progressBar.subviews {
            //my year of birth as a tag for mimum duration indicator. :P
            if eachview.tag == 1000 + currentSegmentIndex {
                eachview.removeFromSuperview()
            }
            
            if eachview.tag == 1995 {
                eachview.removeFromSuperview()
            }
        }
        
        var lastSegementhWidth = 0
        if currentSegmentIndex != 0 {
            if let lastSegView = self.v.progressBar.viewWithTag(1000 + currentSegmentIndex-1) {
                
                let lastSegment = sess.segments[currentSegmentIndex-1] as! SCRecordSessionSegment
                let width  = Int(self.v.progressBar.frame.size.width)/maxVideoSeconds
                lastSegementhWidth = width*Int(lastSegment.duration.seconds)
                lastSegementhWidth = Int(lastSegView.frame.origin.x+lastSegView.frame.size.width)
            }
        }
        
        if sess.currentSegmentDuration.seconds != 0.0 {
            var width  = Int(self.v.progressBar.frame.size.width)/maxVideoSeconds + 1
        
            width = width*Int((sess.currentSegmentDuration.seconds))
            let recordedView = UIView(frame: CGRect(x: lastSegementhWidth, y: 0, width:width, height:5))
            recordedView.backgroundColor = UIColor.white
            var recrdFrame = recordedView.frame
            recrdFrame.size.width = recrdFrame.size.width-1.0
            recrdFrame.origin.x = 0
            let subView = UIView(frame:recrdFrame)
            subView.backgroundColor = Utility.appColor()
            recordedView.addSubview(subView)
            recordedView.tag = 1000 + currentSegmentIndex
            self.v.progressBar.addSubview(recordedView)
        }
        
        if sess.duration.seconds == 0.0 {
            self.v.addAudioButton.isEnabled = true//self.addSoundButton.isEnabled = true
            self.v.removeLastButton.isEnabled = false
            //            self.hideLibraryButton(ishide:false)
        } else {
            self.v.removeLastButton.isEnabled = true
            self.v.addAudioButton.isEnabled = false//self.addSoundButton.isEnabled = false
            //            self.hideLibraryButton(ishide:true)
        }
        if enableNextButton != nil {
            if sess.duration.seconds > Double(minVideoSeconds) {
                //            self.nextButton.isEnabled = true
                self.enableNextButton!(true)
            } else {
                //            self.nextButton.isEnabled = false
                self.enableNextButton!(false)
            }
        }
        
        
        if recorder.session!.duration.seconds >= Double(maxVideoSeconds) {
            self.v.shotButton.isUserInteractionEnabled = false
        } else {
            self.v.shotButton.isUserInteractionEnabled = true
        }
    }
    
    
    func moveToVideoPreviewScreen() {
        //turnFlashOff()
        let videoPreview = VideoPreviewViewController.instantiate(storyBoardName: "Camera") as VideoPreviewViewController
        videoPreview.session = self.session
        videoPreview.selectedAudio = self.selectedAudio
        videoPreview.isForStory = false
        videoPreview.isFromRecording = true
        self.navigationController?.pushViewController(videoPreview, animated:true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}
