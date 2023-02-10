//
//  CameraViewController.swift
//  dub.ly
//
//  Created by Dinesh on 12/14/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import SCRecorder
import MobileCoreServices
import AVKit
import DeepAR
import AVFoundation

protocol CameraViewDelegate{
    func popAfterStoryUpdate()
}
protocol CameraPickingDelegate {
    func selectedImage(imageToSend: UIImage)
    func selectedVideo(video: URL)
}
class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate {

    var session = SCRecordSession()
    var recorder = SCRecorder()
    var isForStory = false
    var doSetupOnlyOnce = true
    var isAudioPermitted = false
    var isVideoPermitted = false
    var isFromStoryListVC = false
    var delegate:CameraViewDelegate?
    var isFromProfilePage:Bool = false
    var audioDenied = false
    var videoDenied = false
    var isFromChat:Bool = false
    var chatVcDelegateObj:CameraPickingDelegate?
    var selectedIndexPathRow = CameraOptions.ShortVideo.rawValue
    var isPhotoMode = false
    var isVideoStarted = false
    var isFromPostedByMusicScreen = false
    var customAudioPath : String?
    var customAudioUrl : String?
    var finalAudioUrl:URL?
    var isVideoFromLibrary:Bool = false
    var timerCount: Int = 0
    var timer = Timer()
    var counter = 0
    var isTimerCountOn = false

    fileprivate lazy var filter: SCFilter = SCFilter(ciFilterName: "CIMinimumComponent")
    
    fileprivate lazy var filterView: SCFilterImageView = SCFilterImageView(frame: CGRect(origin: .zero, size: self.previewView.frame.size))
    
    
    var isRequestedVideoPermisson:Bool {
        return UserDefaults.standard.bool(forKey:"isAppRequestedVideo")
    }
    
    var isRequestedAudioPermisson:Bool {
        return UserDefaults.standard.bool(forKey:"isAppRequestedAudio")
    }
    
    var dismissVC :((Bool)->())?
    
    @IBOutlet weak var muteOptionView: UIView!
    @IBOutlet weak var timerOptionView: UIView!
    @IBOutlet weak var arOptionView: UIView!
    @IBOutlet weak var arFiltersActionViewOutlet: UIView!
    @IBOutlet weak var viewForBottomTools: UIStackView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var muteLabel: UILabel!
    @IBOutlet weak var filtersLabel: UILabel!
    @IBOutlet weak var libraryBUtton: UIButton!
    @IBOutlet weak var switchDeepARButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var viewForRightSideTools: UIView!
    @IBOutlet weak var speedometerView: UIView!
    @IBOutlet weak var mainToolsView: UIView!
    @IBOutlet weak var addSoundButton: UIButton!
    @IBOutlet weak var gestureViewForVideo: UIView!
    @IBOutlet weak var viewForProgress: UIView!
    @IBOutlet weak var leadingConstraintForSelectedSpeed: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var removeLastButton: UIButton!
    @IBOutlet weak var selectedOptionView : UIView!
    @IBOutlet weak var shootAVideoLbl: UILabel!
    @IBOutlet weak var grantCameraAccessLbl: UILabel!
    
    // Timer
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var InitialTimerLabel: UILabel!
    @IBOutlet weak var endTimerLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var countDownButton: UIButton!
    @IBOutlet weak var timerHoldingView: UIView!
    @IBOutlet weak var timerValueLabel: UILabel!
    
    
    
    private var isRecordingInProcess: Bool = false
    var imagePickerController = UIImagePickerController()
    
    var zoomFactor:CGFloat = 1.0
    var lastSegmentTime = 0
    var lastSegementProgressViewTag = 1000
    var originalFrameOfRecordView:CGRect?
    @IBOutlet weak var viewForCameraPermisson: UIView!
    @IBOutlet weak var cameraPermissonBtn: UIButton!
    @IBOutlet weak var microPhnPermissonBtn: UIButton!
    var longGesture:UILongPressGestureRecognizer?
    var tapgesture:UITapGestureRecognizer?
    var tapgestureForPhoto:UITapGestureRecognizer?
    var lastSelectedSpeedButton:UIButton?
    var maxVideoSeconds = 15
    var minVideoSeconds = 5
    var audioPlayer: AVAudioPlayer?
    var selectedAudio:Audio?
    var focusView:SCRecorderToolsView?
    var filterImageView:SCFilterImageView?
    
    @IBOutlet weak var defaultVideoSpeed: UIButton!
    @IBOutlet weak var previewView: UIView!
    
    
    var shouldDismiss: Bool = false
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
     var indexOfCellBeforeDragging = 0

    static let deepARLicenseKey = "69dbf3e637de1af96d2dabafed6311367ae5441db1b1a3d8e8a2994458a99448d247e6ec074ce888"
    //DeepAR
    var deepAR: DeepAR!
    @IBOutlet weak var showAREffectsFiletrs: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var masksButton: UIButton!
    @IBOutlet weak var effectsButton: UIButton!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var arMaskSelectedView : UIView!
    @IBOutlet weak var arEffectsSelectedView : UIView!
    @IBOutlet weak var arFiltersSelectedView : UIView!
    @IBOutlet weak var arViewContainer: UIView!
    @IBOutlet weak var deepARCollectionView : UICollectionView!
    @IBOutlet weak var deepARFiltersView : UIView!
    private var cameraController: CameraController!
    private var arView: ARView!
    
     var maskIndex: Int = 0
    
    
    @IBOutlet weak var arPreViewButton: UIButton!
     var maskPaths: [String?] {
        return Masks.allCases.map { $0.rawValue.path }
    }
    
     var effectIndex: Int = 0
     var effectPaths: [String?] {
        return Effects.allCases.map { $0.rawValue.path }
    }
    
     var filterIndex: Int = 0
     var filterPaths: [String?] {
        return Filters.allCases.map { $0.rawValue.path }
    }
    
    private var buttonModePairs: [(UIButton, Mode)] = []
    var currentMode: Mode! {
        didSet {
        
            switch currentMode! {
            case .effects:
               
                self.arMaskSelectedView.isHidden = true
                self.arEffectsSelectedView.isHidden = false
                self.arFiltersSelectedView.isHidden = true
            case .masks:
                self.arMaskSelectedView.isHidden = false
                self.arEffectsSelectedView.isHidden = true
                self.arFiltersSelectedView.isHidden = true
  
            case .filters:
                self.arMaskSelectedView.isHidden = true
                self.arEffectsSelectedView.isHidden = true
                self.arFiltersSelectedView.isHidden = false
            }
        }
    }
    
    private var buttonRecordingModePairs: [(UIButton, RecordingMode)] = []
    var currentRecordingMode: RecordingMode! {
        didSet {
//            updateRecordingModeAppearance()
        }
    }
    
    var hideARFilters: Bool = true {
        didSet {
            deepARFiltersView.isHidden = hideARFilters
            
            /* Bug Name : DUET FEATURE Clicking on Filters, Filters option are displaying below or not
                                 Fix Date : 11-may-2021
                                 Fixed By : Vishal D
                                 Description Of Fix : removed tools getting hide
                                 */
            self.hideAllTheTools(ishide: !hideARFilters)
            self.closeButton.isHidden =  !hideARFilters
            self.viewForProgress.isHidden =  !hideARFilters
            self.gestureViewForVideo.isHidden = !hideARFilters
            self.collectionViewLayout.collectionView?.isHidden = !hideARFilters
            self.selectedOptionView.isHidden = !hideARFilters
        }
    }
 
    
 
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Refactor name:- disable swipe gesture in camera module
         refactor date:- 29th Oct 2021
         refactor by  :- nikunj c
         description of refactor:- we not need swipe to back as it make issues in some case
         */
         
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.arViewContainer.isHidden = true
        self.clearAllButton.layer.borderColor = UIColor.white.cgColor
        self.previewView.isHidden = false
        
        // timer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        self.timeSlider.addGestureRecognizer(tapGestureRecognizer)
        self.countDownButton.makeCornerRadious(readious: self.countDownButton.frame.size.height/2)
        
        self.addSoundButton.setTitle("Add a Sound".localized, for: .normal)
        self.shootAVideoLbl.text = "Shoot a video".localized
        self.grantCameraAccessLbl.text = "Grant Camera access to shoot".localized
        self.cameraPermissonBtn.setTitle("Allow access to camera".localized, for: .normal)
        self.microPhnPermissonBtn.setTitle("Allow access to microphone".localized, for: .normal)
        self.masksButton.setTitle("Masks".localized, for: .normal)
        self.effectsButton.setTitle("Effects".localized, for: .normal)
        self.filtersButton.setTitle("Filters".localized, for: .normal)
        self.clearAllButton.setTitle("Clear All".localized, for: .normal)
        self.cameraLabel.text = "AR Camera".localized
        self.timerLabel.text = "Timer".localized
        self.muteLabel.text = "Mute".localized
        self.filtersLabel.text = "Filters".localized
        
        if doSetupOnlyOnce {
            doSetupOnlyOnce = false
            if isRequestedVideoPermisson && isRequestedAudioPermisson {
                DispatchQueue.main.async {
                    self.checkCameraPermissions()
//                    self.checkMicPermission()
                }
            } else {
                DispatchQueue.main.async {
                    self.viewForCameraPermisson.isHidden = false
                }
                if isRequestedVideoPermisson {
                    checkCameraPermissions()
                }
                
//                if isRequestedAudioPermisson {
//                    checkMicPermission()
//                }
                
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removingSegaments), name: NSNotification.Name(rawValue: "RemovingSegments"), object: nil)
          collectionViewLayout.minimumLineSpacing = 0

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        addZoomEffects()
        recorder.previewView = previewView
        //updateFilterToVideoOverLay()
        originalFrameOfRecordView = self.gestureViewForVideo.frame
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           configureCollectionViewLayoutItemSize()
       }
    
    @objc func removingSegaments(){
        self.recorder.session?.removeAllSegments()
        self.removeAllSegementsView()
    }
    
    
    func setupARView(){
        if self.arView != nil{
            return
        }
        self.deepAR = DeepAR()
        self.deepAR.delegate = self
        self.deepAR.setLicenseKey(CameraViewController.deepARLicenseKey)
        
        self.arView = (self.deepAR.createARView(withFrame: self.arViewContainer.frame) as! ARView)
        self.arView.translatesAutoresizingMaskIntoConstraints = false
        self.arViewContainer.addSubview(self.arView)
        self.arView.leftAnchor.constraint(equalTo: self.arViewContainer.leftAnchor, constant: 0).isActive = true
        self.arView.rightAnchor.constraint(equalTo: self.arViewContainer.rightAnchor, constant: 0).isActive = true
        self.arView.topAnchor.constraint(equalTo: self.arViewContainer.topAnchor, constant: 0).isActive = true
        self.arView.bottomAnchor.constraint(equalTo: self.arViewContainer.bottomAnchor, constant: 0).isActive = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        self.cameraController = CameraController()
        self.cameraController.deepAR = self.deepAR
        self.cameraController.startCamera()
        self.currentMode = .masks
        self.deepARCollectionView.dataSource = self
        self.deepARCollectionView.delegate = self
        }

    }
    
    func setupAudioPlayerForAudioMix(audioPath:String) {
        self.addSoundButton.setTitle("Custom Sound".localized, for:.normal)
        /*
         Bug Name :- Mute/Unmute button is working or not in the duet.
         Fix Date :- 30/04/2021
         Fixed By :- Jayaram G
         Description Of Fix :- hiding mute if user selected audio
         */
        self.muteOptionView.isHidden = true
        do {
            guard let path = URL.init(string: audioPath) else {
                return
            }
            finalAudioUrl = path
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default,options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: path, fileTypeHint: AVFileType.m4a.rawValue)
            audioPlayer?.enableRate = true
            audioPlayer?.prepareToPlay()
            maxVideoSeconds = Int(audioPlayer!.duration)
            updateMaxVideoSeconds()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    
    func setupAudioPlayerFromSelectedAudio() {
        if let audioUrl = URL(string: selectedAudio!.url) {
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            finalAudioUrl = destinationUrl
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default,options: .defaultToSpeaker)
                try AVAudioSession.sharedInstance().setActive(true)
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
    
    @objc
    private func didTapMasksButton() {
        currentMode = .masks
    }
    
    @objc
    private func didTapEffectsButton() {
        currentMode = .effects
    }
    
    @objc
    private func didTapFiltersButton() {
        currentMode = .filters
    }
    
    @IBAction func arClearAllAction(_ sender: Any) {
        if maskIndex == 0, effectIndex == 0, filterIndex == 0{
            return
        }
        deepAR.switchEffect(withSlot: Mode.effects.rawValue, path: Effects.none.rawValue)
        deepAR.switchEffect(withSlot: Mode.masks.rawValue, path: Masks.none.rawValue)
        deepAR.switchEffect(withSlot: Mode.filters.rawValue, path: Filters.none.rawValue)
        maskIndex = 0
        filterIndex = 0
        effectIndex = 0
        deepARCollectionView.reloadData()
    }
    @IBAction func arMasksButtonAction(_ sender: Any) {
        currentMode = .masks
        deepARCollectionView.reloadData()
    }
    @IBAction func arEffectsButtonAction(_ sender: Any) {
        currentMode = .effects
        deepARCollectionView.reloadData()
    }
    @IBAction func arFiltersButtonAction(_ sender: Any) {
        currentMode = .filters
        deepARCollectionView.reloadData()
    }
    
    /*
     Bug Name :- Please add a mute button in the create video post page similar to that of the android
     Fix Date :- 15/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Added muting button action, disabling audioConfiguration
     */
    @IBAction func muteAction(_ sender: Any) {
        self.recorder.audioConfiguration.enabled = self.muteButton.isSelected
        self.muteButton.isSelected = !self.muteButton.isSelected
    }
    
    @IBAction func videoSpeedAction(_ sender: Any) {
        let selectedButton = sender as! UIButton
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
            print("")
        }
        
        recorder.videoConfiguration.timeScale = CGFloat(speedOfVideo)
        updateButtonForVideoSpeed(selectedSpeed: selectedButton)
        audioPlayer?.rate = Float(speedOfVideo)
    }
    
    func updateButtonForVideoSpeed(selectedSpeed:UIButton) {
        
        self.leadingConstraintForSelectedSpeed.constant = self.lastSelectedSpeedButton!.frame.origin.x
        lastSelectedSpeedButton?.setTitleColor(UIColor.white, for: .normal)
        lastSelectedSpeedButton = selectedSpeed
        UIView.animate(withDuration: TimeInterval(0.2), animations: {
            self.leadingConstraintForSelectedSpeed.constant = self.lastSelectedSpeedButton!.frame.origin.x
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            self.lastSelectedSpeedButton?.setTitleColor(UIColor.darkGray, for: .normal)
        })
    }
    
    
    
    func removeAllSegementsView() {
        for eachview in  self.viewForProgress.subviews {
            //my year of birth as a tag for mimum duration indicator. :P
            if eachview.tag != 1994 {
                eachview.removeFromSuperview()
            }
        }
        self.gestureViewForVideo.isUserInteractionEnabled = true
    }
    
    func addNewSubView() {
        
        var currentSegmentIndex = 0
        if let alreadyCreatedSegements = self.recorder.session?.segments.count{
            currentSegmentIndex = alreadyCreatedSegements
        }
        
        for eachview in  self.viewForProgress.subviews {
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
            if let lastSegView = self.viewForProgress.viewWithTag(1000 + currentSegmentIndex-1) {
                
                let lastSegment = self.recorder.session?.segments[currentSegmentIndex-1] as! SCRecordSessionSegment
                let width  = Int(self.viewForProgress.frame.size.width)/maxVideoSeconds
                lastSegementhWidth = width*Int(lastSegment.duration.seconds)
                lastSegementhWidth = Int(lastSegView.frame.origin.x+lastSegView.frame.size.width)
            }
        }
        
        if self.recorder.session?.currentSegmentDuration.seconds != 0.0 {
            var width  = Int(self.viewForProgress.frame.size.width)/maxVideoSeconds
            width = width*Int((self.recorder.session?.currentSegmentDuration.seconds)!)
            let recordedView = UIView(frame: CGRect(x: lastSegementhWidth, y: 0, width:width, height:5))
            recordedView.backgroundColor = UIColor.white
            var recrdFrame = recordedView.frame
            recrdFrame.size.width = recrdFrame.size.width - 1
            recrdFrame.origin.x = 0
            let subView = UIView(frame:recrdFrame)
            subView.backgroundColor = Utility.appColor()
            recordedView.addSubview(subView)
            recordedView.tag = 1000 + currentSegmentIndex
            self.viewForProgress.addSubview(recordedView)
        }
        
        if recorder.session?.duration.seconds == 0.0 {
            self.addSoundButton.isEnabled = true
            self.removeLastButton.isEnabled = false
            self.hideLibraryButton(ishide:false)
        } else {
            self.removeLastButton.isEnabled = true
            /*
             Bug Name :- Create Post: We should be able to select the sound even after we have recorded the video for some time
             Fix Date :- 6/04/2021
             Fixed By :- Jayaram G
             Description Of Fix :- enabling add sound button everytime
             */
            self.addSoundButton.isEnabled = true
            self.hideLibraryButton(ishide:true)
        }
        
        if recorder.session!.duration.seconds > Double(minVideoSeconds) {
            self.nextButton.isEnabled = true
        } else {
            self.nextButton.isEnabled = false
        }
        
        
        
        
        if recorder.session!.duration.seconds >= Double(maxVideoSeconds) {
            self.gestureViewForVideo.isUserInteractionEnabled = false
        } else {
            self.gestureViewForVideo.isUserInteractionEnabled = true
        }
    }
    
    func updateProgress() {
        
    }
    
    
    func addSegementProgressForLibrary() {
        
        var currentSegmentIndex = 0
        if let alreadyCreatedSegements = self.recorder.session?.segments.count{
            currentSegmentIndex = alreadyCreatedSegements
        }
        
        for eachview in  self.viewForProgress.subviews {
            if eachview.tag == 1000 + currentSegmentIndex {
                eachview.removeFromSuperview()
            }
        }
        
        let lastSegementhWidth = 0
        
        var width  = Int(self.viewForProgress.frame.size.width)/maxVideoSeconds
        let lastSegment = self.recorder.session?.segments[currentSegmentIndex-1] as! SCRecordSessionSegment
        width = width*Int((lastSegment.duration.seconds))
        let recordedView = UIView(frame: CGRect(x: lastSegementhWidth, y: 0, width:width, height:5))
        recordedView.backgroundColor = UIColor.white
        var recrdFrame = recordedView.frame
        recrdFrame.size.width = recrdFrame.size.width - 1
        recrdFrame.origin.x = 0
        let subView = UIView(frame:recrdFrame)
        subView.backgroundColor = Utility.appColor()
        recordedView.addSubview(subView)
        recordedView.tag = 1995
        self.viewForProgress.addSubview(recordedView)
        
        
        
        self.removeLastButton.isEnabled = true
        /*
         Bug Name :- Create Post: We should be able to select the sound even after we have recorded the video for some time
         Fix Date :- 6/04/2021
         Fixed By :- Jayaram G
         Description Of Fix :- enabling add sound button everytime
         */
        self.addSoundButton.isEnabled = true
        self.hideLibraryButton(ishide:true)
        
        self.nextButton.isEnabled = true
        if recorder.session!.duration.seconds >= Double(maxVideoSeconds) {
            self.gestureViewForVideo.isUserInteractionEnabled = false
        } else {
            self.gestureViewForVideo.isUserInteractionEnabled = true
        }
        
//        self.moveToVideoPreviewScreen()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        self.isVideoFromLibrary = true
        if let videoURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)]as? URL {
            let newSegement = SCRecordSessionSegment(url: videoURL, info:nil)
            recorder.session?.addSegment(newSegement)
//            self.addSegementProgressForLibrary()
            //session.addSegment(newSegement)
            // self.moveToVideoPreviewScreen()
            DispatchQueue.main.async{ [weak self] in
                self?.dismiss(animated: false, completion: nil)
                self?.moveToVideoPreviewScreen()
            }
        } else if let image = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage) {
            DispatchQueue.main.async{ [weak self] in
                self?.dismiss(animated: true, completion: {
                    self?.moveToIMagePreviewScreen(photo: image, isFromGallery: true)
                })
            }
        }
    }
    
    @objc func capturePhoto(_ sender: UIGestureRecognizer){
        
        if !arViewContainer.isHidden {
            
            if (currentRecordingMode == RecordingMode.photo) {
                deepAR.takeScreenshot()
                return
            }
            
            if (isRecordingInProcess) {
                deepAR.finishVideoRecording()
                isRecordingInProcess = false
             //   isVideoStarted = false
                audioPlayer?.pause()
                self.hideAllTheTools(ishide:false)
//                recorder.pause({
//                    self.addNewSubView()
                      self.hideAllTheTools(ishide:false)
                    
//                })
                    
                return
            }
            
            let width: Int32 = Int32(deepAR.renderingResolution.width)
            let height: Int32 =  Int32(deepAR.renderingResolution.height)
            
            if (currentRecordingMode == RecordingMode.video) {
                deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height)
                isRecordingInProcess = true
                return
            }
            
            if (currentRecordingMode == RecordingMode.lowQualityVideo) {
                let videoQuality = 0.1
                let bitrate =  1250000
                let videoSettings:[AnyHashable : AnyObject] = [
                    AVVideoQualityKey : (videoQuality as AnyObject),
                    AVVideoAverageBitRateKey : (bitrate as AnyObject)
                ]
                
                let frame = CGRect(x: 0, y: 0, width: 1, height: 1)
                
                deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height, subframe: frame, videoCompressionProperties: videoSettings, recordAudio: true)
                if self.isTimerCountOn{
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(maxVideoSeconds)) {
                        self.deepAR.finishVideoRecording()
                        self.isRecordingInProcess = false
                        self.audioPlayer?.pause()
                        self.hideAllTheTools(ishide:false)
                    }
                }
                
                isRecordingInProcess = true
            }
           // isVideoStarted = true
          self.hideAllTheTools(ishide:true)
           self.hideLibraryButton(ishide:true)
            audioPlayer?.play()
           // recorder.record()
//                self.collectionViewLayout.collectionView?.isScrollEnabled = false
//                DispatchQueue.main.async {
//                self.collectionViewLayout?.collectionView?.reloadData()
//                }

        

        }else{
        
        if(self.recorder.session?.duration.seconds == 0.0 && isPhotoMode) {
            //there is no recording session so capture photo
            self.recorder.capturePhoto( { (error,capturedImage) in
                if error == nil {
                    //image captured successfully.
                    let shutterView = UIView(frame: self.view.frame)
                    shutterView.backgroundColor = UIColor.white
                    self.previewView.addSubview(shutterView)
                    UIView.animate(withDuration: 0.3, animations: {
                        shutterView.alpha = 0
                    }, completion: { (_) in
                        shutterView.removeFromSuperview()
                        var flippedImage = capturedImage
                        if self.recorder.device == AVCaptureDevice.Position.front {
                            flippedImage = UIImage(cgImage: capturedImage!.cgImage!, scale: UIScreen.main.scale, orientation: .leftMirrored)
                        }
                        self.moveToIMagePreviewScreen(photo: flippedImage!, isFromGallery: false)
                    })
                }
            })
        }
        else{
            if !isVideoStarted{
            isVideoStarted = true
            self.hideAllTheTools(ishide:true)
            self.hideLibraryButton(ishide:true)
            self.timerOptionView.isHidden = true
            gestureViewForVideo.backgroundColor = UIColor.red
            audioPlayer?.play()
            recorder.record()
                self.collectionViewLayout.collectionView?.isScrollEnabled = false
                DispatchQueue.main.async {
                self.collectionViewLayout?.collectionView?.reloadData()
                }

            }
            else{
            isVideoStarted = false
            audioPlayer?.pause()
            self.hideAllTheTools(ishide:false)
            recorder.pause({
                self.addNewSubView()
                  self.hideAllTheTools(ishide:false)
                
            })
                
            }
        }
        }
    }
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        let lastViewPosition = sender.view!.frame
        self.gestureViewForVideo.superview?.bringSubviewToFront(self.gestureViewForVideo)
        if sender.state == .ended {
            isVideoStarted = false
            gestureViewForVideo.backgroundColor = UIColor.red
            audioPlayer?.pause()
            recorder.pause({
                self.addNewSubView()
            })
            
            gestureViewForVideo.layer.removeAllAnimations()
            self.hideAllTheTools(ishide:false)
            guard let view = sender.view else {
                return
            }
            
            UIView.animate(withDuration: 0.1, animations: {
                if self.originalFrameOfRecordView != nil {
                    view.frame = self.originalFrameOfRecordView!
                }
                self.view.layoutIfNeeded()
            })
            zoomFactor = 1.0
            self.recorder.videoZoomFactor = 1.0
            
            print("****ENDED****")
            if !arViewContainer.isHidden{
                self.capturePhoto(UIGestureRecognizer.init())
            }
        }
        else if sender.state == .began {
            lastSegmentTime = 0
            self.hideAllTheTools(ishide:true)
            self.hideLibraryButton(ishide:true)
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
            gestureViewForVideo.layer.add(animationGroup, forKey: "pulse")
            gestureViewForVideo.backgroundColor = UIColor.yellow
            audioPlayer?.play()
            recorder.record()
            
            print("BEGIN")
            
            if !arViewContainer.isHidden{
                self.capturePhoto(UIGestureRecognizer.init())
            }
        } else if sender.state == .changed {
            
            print("CHANGED")
            guard let view = sender.view else {
                return
            }
            let location = sender.location(in: self.gestureViewForVideo.superview)
            view.center = CGPoint(x:view.center.x + (location.x - view.center.x),
                                  y:view.center.y + (location.y - view.center.y))
            
            if (lastViewPosition.origin.y < view.frame.origin.y) {
                zoomFactor =  zoomFactor - 0.3
                if(zoomFactor <= 1.0) {
                    zoomFactor = 1.0
                }
                
            } else if (lastViewPosition.origin.y > view.frame.origin.y) {
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
    
    func addLongGestureRecornizer() {
        longGesture = UILongPressGestureRecognizer(target: self, action:#selector(longTap(_:)))
        gestureViewForVideo.addGestureRecognizer(longGesture!)
        
    }
    
    
    
    
    
    @IBAction func libraryButtonAction(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.isEditing = false
        imagePickerController.allowsEditing = false
        imagePickerController.mediaTypes = ["public.image","public.movie"]
        imagePickerController.videoMaximumDuration = TimeInterval(60.0)
        imagePickerController.videoQuality = .typeMedium
        imagePickerController.modalPresentationStyle = .fullScreen
        if #available(iOS 11.0, *) {
            imagePickerController.videoExportPreset = AVAssetExportPresetPassthrough
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func nextButtonAction(_ sender: Any) {
        moveToVideoPreviewScreen()
    }
    
    @objc func doubleTap(_ sender: UIGestureRecognizer){
        switchCam()
    }
    
    @objc func recordViewMoved(_ sender: UIGestureRecognizer){
        let respGesture = sender as! UIPanGestureRecognizer
        let velocity = respGesture.velocity(in: respGesture.view)
        if velocity.y > 0 {
            zoomFactor =  zoomFactor + 0.2
            if(zoomFactor >= self.recorder.videoZoomFactor) {
                zoomFactor = self.recorder.videoZoomFactor
            }
        } else {
            zoomFactor =  zoomFactor - 0.2
            if(zoomFactor <= self.recorder.videoZoomFactor) {
                zoomFactor = self.recorder.videoZoomFactor
            }
        }
        self.recorder.videoZoomFactor = zoomFactor
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        
        if recorder.session == nil {
            if isForStory {
                self.dismiss(animated: true, completion:nil)
                return
            }else if isFromProfilePage {
                self.navigationController?.popViewController(animated: false)
                return
            }else if isFromChat {
                self.dismiss(animated: true, completion:nil)
                return
            }else {
                if let callBack = dismissVC{
                    callBack(true)
                }
                self.navigationController?.popViewController(animated: false)
                return
            }
            
        }
        
        if recorder.session?.duration.seconds == 0.0 {
            if isForStory {
                self.dismiss(animated: true, completion:nil)
                return
            }else if isFromProfilePage {
                self.navigationController?.popViewController(animated: false)
                return
            }else if isFromChat {
                self.dismiss(animated: true, completion:nil)
                return
            }else {
                if let callBack = dismissVC{
                    callBack(true)
                }
                self.navigationController?.popViewController(animated: false)
                return
            }
        }
        
        let alertController = UIAlertController(title:nil, message:nil, preferredStyle: UIAlertController.Style.actionSheet)
        let reShootAction = UIAlertAction(title: "Reshoot".localized, style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            self.resetVideo()
        }
        let exitAction = UIAlertAction(title: "Exit".localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            if self.isForStory {
                self.dismiss(animated: true, completion:nil)
            }else if self.isFromProfilePage {
                self.navigationController?.popToRootViewController(animated: false)
            }else if self.isFromChat {
                self.dismiss(animated: true, completion:nil)
            }else {
                self.recorder.session?.removeAllSegments()
                self.removeAllSegementsView()
                if let callBack = self.dismissVC{
                                callBack(true)
                            }
                self.navigationController?.popViewController(animated: false)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertAction.Style.cancel) {
            (result : UIAlertAction) -> Void in
            
        }
        
        alertController.addAction(reShootAction)
        alertController.addAction(exitAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func resetVideo() {
        self.isVideoFromLibrary = false
        self.audioPlayer = nil
        /*
         Bug Name :- Mute/Unmute button is working or not in the duet.
         Fix Date :- 30/04/2021
         Fixed By :- Jayaram G
         Description Of Fix :- showing mute view if user not selected audio
         */
        self.muteOptionView.isHidden = false
        self.selectedAudio = nil
        self.addSoundButton.setTitle("Add a Sound".localized, for:.normal)
        self.recorder.session?.removeAllSegments()
        self.removeAllSegementsView()
        self.addSoundButton.isEnabled = true
        self.hideLibraryButton(ishide: false)
        self.removeLastButton.isEnabled = false
        self.collectionViewLayout.collectionView?.isScrollEnabled = true
          DispatchQueue.main.async {
          self.collectionViewLayout?.collectionView?.reloadData()
        }
    }
    
    deinit {
        if  self.arView != nil{
          self.arView.shutdown()
        }
        print("controller deinitialzed")
    }
    
    
    func hideLibraryButton(ishide:Bool) {
        self.libraryBUtton.isHidden = true
    }
    
    
    private func moveToVideoPreviewScreen() {
        turnFlashOff()
        let videoPreview = VideoPreviewViewController.instantiate(storyBoardName: "Camera") as VideoPreviewViewController
        videoPreview.session = self.session
        videoPreview.selectedAudio = self.selectedAudio
        if isFromChat {
            videoPreview.chatVideoDelegateObj = self
            videoPreview.isFromChat = true
        }
        if isVideoFromLibrary {
            videoPreview.clearVideoDelObj = self
        }
        videoPreview.audioPath = finalAudioUrl
        videoPreview.isForStory = isForStory
        videoPreview.delegate = self
        
        if isForStory {
            let navVC = UINavigationController(rootViewController: videoPreview)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true, completion: nil)
        }else if isFromChat {
            let navVC = UINavigationController(rootViewController: videoPreview)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true, completion: nil)
        }else{
            videoPreview.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(videoPreview, animated: true)
        }
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
    
    @IBAction func removeLastSessionButtonAction(_ sender: Any) {
        
        let alertTitle = "Are you sure you want to delete last segment".localized + "?"
        let alertController = UIAlertController(title:alertTitle, message:nil, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Confirm".localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            self.recorder.session?.removeLastSegment()
            self.audioPlayer?.currentTime = TimeInterval(self.recorder.session!.duration.seconds)
            self.addNewSubView()
            if let session =  self.recorder.session, session.duration.seconds == 0.0{
            self.selectedAudio = nil
                /*
                 Bug Name :- Mute/Unmute button is working or not in the duet.
                 Fix Date :- 30/04/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- showing mute view if user not selected audio
                 */
                self.muteOptionView.isHidden = false
                self.addSoundButton.setTitle("Add a Sound".localized, for:.normal)
            self.collectionViewLayout.collectionView?.isScrollEnabled = true
            }
            DispatchQueue.main.async {
            self.collectionViewLayout?.collectionView?.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertAction.Style.cancel) {
            (result : UIAlertAction) -> Void in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func speedMeterButtonAction(_ sender: Any) {
        /*
         Bug Name :- Upload photo videos module : The timer pop up is being overlapped by the affects pop up
         Fix Date :- 31/03/2021
         Fixed By :- Jayaram G
         Description Of Fix :- before views not handled properly , hiding filters view when tap here
         */
        if !self.arViewContainer.isHidden && !self.deepARFiltersView.isHidden{
            self.deepARFiltersView.isHidden = true
            self.hideAllTheTools(ishide: false)
            self.viewForProgress.isHidden =  false
            self.gestureViewForVideo.isHidden = false
            self.collectionViewLayout.collectionView?.isHidden = false
            self.selectedOptionView.isHidden = false
            return
        }else{
            
        }
        
        if !isPhotoMode{
            self.speedometerView.isHidden = !self.speedometerView.isHidden
            self.timerHoldingView.isHidden = !self.timerHoldingView.isHidden
            }
    }
    
    @objc func sliderTapped(gestureRecognizer:UIGestureRecognizer){
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        
        let positionOfSlider: CGPoint = self.timeSlider.frame.origin
        let widthOfSlider: CGFloat = self.timeSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(self.timeSlider.maximumValue) / widthOfSlider)
        
        self.timeSlider.setValue(Float(newValue), animated: true)
        self.timerValueLabel.text = "\(Int(newValue))s"
        self.timerValueLabel.isHidden = false
        self.maxVideoSeconds = Int(newValue)
        if self.maxVideoSeconds > 0{
            self.countDownButton.isEnabled = true
            self.countDownButton.backgroundColor = Helper.hexStringToUIColor(hex: AppColourStr.appColor)
        }else{
            self.countDownButton.isEnabled = false
            self.countDownButton.backgroundColor = .gray
        }
        self.timerValueLabel.center = setUISliderThumbValueWithLabel(slider: self.timeSlider)
    }
    
    @IBAction func timerSliderAction(_ sender: UISlider) {
        timerCount = Int(CGFloat(sender.value))
        self.maxVideoSeconds = timerCount
        self.timerValueLabel.isHidden = false
        self.timerValueLabel.text = "\(timerCount)s"
        if timerCount < 5{
            self.InitialTimerLabel.isHidden = true
            self.endTimerLabel.isHidden = false
        }else if timerCount > 55{
            self.InitialTimerLabel.isHidden = false
            self.endTimerLabel.isHidden = true
        }else{
            self.InitialTimerLabel.isHidden = false
            self.endTimerLabel.isHidden = false
        }
        if self.maxVideoSeconds > 0{
            self.countDownButton.isEnabled = true
            self.countDownButton.backgroundColor = Helper.hexStringToUIColor(hex: AppColourStr.appColor)
        }else{
            self.countDownButton.isEnabled = false
            self.countDownButton.backgroundColor = .gray
        }
        self.timerValueLabel.center = setUISliderThumbValueWithLabel(slider: sender)
        
    }
    
    func setUISliderThumbValueWithLabel(slider: UISlider) -> CGPoint {
            let slidertTrack : CGRect = slider.trackRect(forBounds: slider.bounds)
            let sliderFrm : CGRect = slider .thumbRect(forBounds: slider.bounds, trackRect: slidertTrack, value: slider.value)
            return CGPoint(x: sliderFrm.origin.x + slider.frame.origin.x + 20, y: slider.frame.origin.y + 38)
        }
    
    @IBAction func countdownAction(_ sender: Any) {
        isTimerCountOn = true
        startCountDown()
        
    }
    
    
    func startCountDown(){
        self.timerHoldingView.isHidden = true
        self.countDownLabel.isHidden = false
        self.countDownLabel.text = String(1)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(increamentCounter), userInfo: nil, repeats: true)
    }
    
    func stopCountDown(){
        timer.invalidate()
        countDownLabel.isHidden = true
        self.countDownLabel.layer.removeAllAnimations()
        self.view.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
        startRecording()
    }
    
    func startRecording(){
        isPhotoMode = false
        isVideoStarted = false
        maxVideoSeconds = timerCount
        recorder.maxRecordDuration = CMTime(seconds: Double(maxVideoSeconds), preferredTimescale: 1)
        
        lastSegmentTime = 0
        self.gestureViewForVideo.superview?.bringSubviewToFront(self.gestureViewForVideo)
        self.capturePhoto(UIGestureRecognizer())
        
        audioPlayer?.play()
        recorder.record()
        
        
        
    }
    @objc func increamentCounter(){
        countDownLabel.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.countDownLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }, completion: {(_ finished: Bool) -> Void in
                    UIView.animate(withDuration: 0.5, animations: {() -> Void in
                        self.countDownLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                    })
                })
        counter += 1
        countDownLabel.text = "\(counter)"
        if counter > 3 {
            stopCountDown()
        }
    }
    
    @IBAction func switchDeepARCamera(_ sender: Any) {
        switchDeepARButton.isEnabled = false
        self.arViewContainer.isHidden = !self.arViewContainer.isHidden
        /*
         Bug Name :- Camera post: The buttons are overlapping: Click on post photo>>click ar camera>>click effects>>click normal camera
         Fix Date :- 22/07/2021
         Fixed By :- Jayaram G
         Description Of Fix :- added delay to update filter button to avoid messed.
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.arFiltersActionViewOutlet.isHidden = !self.arFiltersActionViewOutlet.isHidden
        }
        self.previewView.isHidden = !self.previewView.isHidden
              if arViewContainer.isHidden{
                cameraLabel.text = "AR Camera".localized
                hideARFilters = true
                 self.recorder.startRunning()
              }
              else{
                cameraLabel.text = "Normal Camera".localized
                  recorder.stopRunning()
                    self.setupARView()
      
              }
        switchDeepARButton.isEnabled = true
    }
    
    @IBAction func deepARfiltersButtonAction(_ sender: Any) {
          hideARFilters = !hideARFilters
        self.viewForBottomTools.isHidden = !self.viewForBottomTools.isHidden
        self.arPreViewButton.isHidden = false
    }
    
    
    @IBAction func arPreviewBtnAction(_ sender: Any) {
        hideARFilters = !hideARFilters
      self.viewForBottomTools.isHidden = !self.viewForBottomTools.isHidden
      self.gestureViewForVideo.superview?.bringSubviewToFront(self.gestureViewForVideo)
    }
    
    @IBAction func saveButtonPress(sender: AnyObject) {
        session.mergeSegments(usingPreset: AVAssetExportPresetHighestQuality) { (url, error) in
            if (error == nil) {
                
                let urlInNs:NSURL = NSURL(string: (url?.absoluteString)!)!
                urlInNs.saveToCameraRoll(completion: { (path, error) in
                    debugPrint(path, error ?? "")
                })
            } else {
                debugPrint(error ?? "")
            }
        }
    }
    
    
    @IBAction func switchCamera(_ sender: Any) {
        switchCam()
    }
    
    func switchCam() {
        // switchCamForNormalCamera()
        
        self.arViewContainer.isHidden ? switchCamForNormalCamera() : switchCamForDeepARCamera()
        
    }
    func switchCamForNormalCamera(){
        if recorder.device ==  AVCaptureDevice.Position.front {
                   recorder.device = AVCaptureDevice.Position.back
               } else {
                   turnFlashOff()
                   recorder.device = AVCaptureDevice.Position.front
               }
           
    }
    
    func switchCamForDeepARCamera(){
        cameraController.position = cameraController.position == .back ? .front : .back

    }
    
    
    @IBAction func addSoundButtonAction(_ sender: Any) {
        let audioVc = AudioListViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Main) as AudioListViewController
        audioVc.delegate = self
        let newNav = UINavigationController(rootViewController: audioVc)
        newNav.modalPresentationStyle = .fullScreen
        //  newNav.isNavigationBarHidden = true
        self.present(newNav, animated: false, completion:nil)
    }
    
    
    @IBAction func flashButtonAction(_ sender: Any) {
        toggleFlash()
    }
    
    func addMinimumDurationIndicator() {
        var width  = Int(self.viewForProgress.frame.size.width)/maxVideoSeconds
        width = width*Int(minVideoSeconds)
        let indicatorFrame = CGRect(x: CGFloat(width), y:0, width:2.0, height:viewForProgress.frame.size.height)
        let indicatorView = UIView(frame:indicatorFrame)
        indicatorView.tag = 1994
        indicatorView.backgroundColor = UIColor.white
        self.viewForProgress.addSubview(indicatorView)
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
    
    
    func toggleFlash() {
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        if selectedAudio == nil || selectedIndexPathRow == CameraOptions.Albums.rawValue || isFromPostedByMusicScreen{
        isFromPostedByMusicScreen = false
        self.setupUI()
        }else{
            /*
             Bug Name :- Mute/Unmute button is working or not in the duet.
             Fix Date :- 30/04/2021
             Fixed By :- Jayaram G
             Description Of Fix :- hiding mute option if user selected audio
             */
            self.muteOptionView.isHidden = true
        }
        if self.shouldDismiss{
            self.dismiss(animated: false, completion: {
                if self.isFromStoryListVC {
                    self.delegate?.popAfterStoryUpdate()
                }
            })
        }
        imagePickerController.navigationBar.tintColor = UIColor.black
    }
    
    func setupUI(){
        self.hideLibraryButton(ishide: true)
     
        switch CameraOptions.init(rawValue: selectedIndexPathRow) {
        case .Albums:
            isVideoStarted = false
            isPhotoMode = false
            self.hideAllTheTools(ishide:false)
            self.viewForProgress.isHidden = false
            if selectedIndexPathRow == CameraOptions.Albums.rawValue, let cell = collectionViewLayout.collectionView!.cellForItem(at: IndexPath.init(row: CameraOptions.Albums.rawValue, section: 0)) as? CameraBottomOptionsCVCell{
                cell.setUnSelected()
                                      }
                     DispatchQueue.main.async {
                     self.collectionViewLayout.collectionView!.scrollToItem(at:IndexPath.init(row: CameraOptions.ShortVideo.rawValue , section: 0), at: .centeredHorizontally, animated: false)
                     }
            selectedIndexPathRow = CameraOptions.ShortVideo.rawValue
            
        case .Photo:
            isVideoStarted = false
            isPhotoMode = true
            self.hideAllTheTools(ishide:true)
            self.closeButton.isHidden = false
            self.viewForProgress.isHidden = true
            currentRecordingMode = .photo
        case .ShortVideo:
            isPhotoMode = false
            isVideoStarted = false
            if selectedAudio == nil{
            maxVideoSeconds = 15
                /*
                 Bug Name :- Mute/Unmute button is working or not in the duet.
                 Fix Date :- 30/04/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- showing if user not selected audio
                 */
                self.muteOptionView.isHidden = false
            recorder.maxRecordDuration = CMTime(seconds: Double(maxVideoSeconds), preferredTimescale: 1)
            }else {
                self.muteOptionView.isHidden = true
            }
            self.viewForProgress.isHidden = false
            self.hideAllTheTools(ishide:false)
            currentRecordingMode = .lowQualityVideo
        case .LongVideo:
            isPhotoMode = false
             if selectedAudio == nil{
             maxVideoSeconds = 60
                /*
                 Bug Name :- Mute/Unmute button is working or not in the duet.
                 Fix Date :- 30/04/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- showing if user not selected audio
                 */
                self.muteOptionView.isHidden = false
            recorder.maxRecordDuration = CMTime(seconds: Double(maxVideoSeconds), preferredTimescale: 1)
             }else{
                /*
                 Bug Name :- Mute/Unmute button is working or not in the duet.
                 Fix Date :- 30/04/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- hiding mute if user selected audio
                 */
                self.muteOptionView.isHidden = true
             }
          self.viewForProgress.isHidden = false
          self.hideAllTheTools(ishide:false)
            currentRecordingMode = .lowQualityVideo
        case .none:
            print("No Action")
        }
    
            DispatchQueue.main.async {
                self.collectionViewLayout.collectionView!.scrollToItem(at:IndexPath.init(row: self.selectedIndexPathRow , section: 0), at: .centeredHorizontally, animated: false)
                }
            if let cell = collectionViewLayout.collectionView!.cellForItem(at: IndexPath.init(row: selectedIndexPathRow, section: 0)) as? CameraBottomOptionsCVCell{
                          cell.setSelected()
                      }
    }
    
    func checkCameraPermissions() {
        UserDefaults.standard.set(true, forKey:"isAppRequestedVideo")
        UserDefaults.standard.synchronize()
        if AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            DispatchQueue.main.async {
                self.cameraPermissonBtn.isEnabled = false
                self.cameraSetup()
                self.isVideoPermitted = true
                self.updateHideOnPermissonScreen()
            }
        } else if AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) ==  AVAuthorizationStatus.denied {
            // Already Authorized
            DispatchQueue.main.async {
                self.videoDenied = true
                self.isVideoPermitted = false
                self.updateHideOnPermissonScreen()
            }
        }
        else {
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)), completionHandler: { (granted: Bool) -> Void in
                
                DispatchQueue.main.async {
                    if granted == true {
                        // User granted
                        self.cameraSetup()
                        self.cameraPermissonBtn.isEnabled = false
                        self.isVideoPermitted = true
                        self.updateHideOnPermissonScreen()
                    } else {
                        // User rejected.
                        self.videoDenied = true
                        self.isVideoPermitted = false
                        self.updateHideOnPermissonScreen()
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
                self.recorder.audioConfiguration.enabled = true
                self.isAudioPermitted = true
                self.updateHideOnPermissonScreen()
            }
        case AVAudioSession.RecordPermission.denied: do {
            DispatchQueue.main.async {
                self.audioDenied = true
                self.isAudioPermitted = false
                self.updateHideOnPermissonScreen()
            }
            }
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                
                DispatchQueue.main.async {
                    if granted {
                        self.microPhnPermissonBtn.isEnabled = false
                        self.isAudioPermitted = true
                        self.recorder.audioConfiguration.enabled = true
                        self.updateHideOnPermissonScreen()
                    } else {
                        self.audioDenied = true
                        self.isAudioPermitted = false
                        self.updateHideOnPermissonScreen()
                    }
                }
                
            })
        default:
            break
        }
    }
    
    
    func cameraSetup() {
        //        recorder.audioConfiguration.enabled = false
        if (!recorder.startRunning()) {
            debugPrint("Recorder error: ", recorder.error ?? "")
        }
        //recorder.attemptTurnOffVideoStabilization()
        recorder.mirrorOnFrontCamera = true
        self.removeLastButton.isEnabled = false
        self.nextButton.isEnabled = false
        lastSelectedSpeedButton = self.defaultVideoSpeed
        updateMaxVideoSeconds()
        recorder.session = session
        recorder.captureSessionPreset = AVCaptureSession.Preset.high.rawValue
        //recorder.device = AVCaptureDevicePosition.front
        recorder.delegate = self
        recorder.initializeSessionLazily = false
        recorder.videoConfiguration.preset = SCPresetHighestQuality
        recorder.videoConfiguration.enabled = true
        recorder.videoConfiguration.scalingMode = AVVideoScalingModeResizeAspectFill
        recorder.videoConfiguration.bitrate = 2000000
        recorder.videoConfiguration.sizeAsSquare = false
        recorder.audioConfiguration.channelsCount = 0
        recorder.videoConfiguration.timeScale = 1
       // recorder.videoConfiguration.size =  CGSize(width: 1280, height: 720)
        addLongGestureRecornizer()
        updateSelectedAudio()
    }
    
    
    func updateMaxVideoSeconds() {
        recorder.maxRecordDuration = CMTime(seconds: Double(maxVideoSeconds), preferredTimescale: 1)
    }
    
    func updateFilterToVideoOverLay() {
        filterImageView = SCFilterImageView(frame: self.previewView.bounds)
        filterImageView!.filter = SCFilter(ciFilterName:"CIMinimumComponent");
        recorder.scImageView = filterImageView!
        recorder.scImageView?.backgroundColor  = UIColor.clear
        self.previewView.addSubview(filterImageView!)
        recorder.videoConfiguration.filter = filterImageView!.filter
    }
    
    func changeFilter() {
        filterImageView!.filter = SCFilter(ciFilterName:"CIMinimumComponent");
        recorder.scImageView = filterImageView!
        recorder.videoConfiguration.filter = filterImageView!.filter
    }
    
    @IBAction func cameraAccessBtnAction(_ sender: Any) {
        if videoDenied {
            // go to settings page.
            openSettingsPage()
        } else {
            checkCameraPermissions()
        }
    }
    
    func openSettingsPage() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
                // Handle
            })
        }
    }
    
    func updateHideOnPermissonScreen() {
        if self.isVideoPermitted {
            self.viewForCameraPermisson.isHidden = true
        } else {
            self.viewForCameraPermisson.isHidden = false
        }
    }
    
    
    @IBAction func microPhoneBtnAction(_ sender: Any) {
        if audioDenied {
            //take to settings page if denied.
            openSettingsPage()
        } else {
            checkMicPermission()
        }
    }
    
    func addZoomEffects() {
        focusView = SCRecorderToolsView(frame:self.view.bounds)
        focusView!.recorder = self.recorder
        self.focusView!.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleBottomMargin.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue | UIView.AutoresizingMask.flexibleLeftMargin.rawValue | UIView.AutoresizingMask.flexibleRightMargin.rawValue | UIView.AutoresizingMask.flexibleTopMargin.rawValue | UIView.AutoresizingMask.flexibleWidth.rawValue);
        self.mainToolsView.addSubview(focusView!)
        for eachView in self.mainToolsView.subviews {
            if eachView != self.focusView {
                self.mainToolsView.bringSubviewToFront(eachView)
            }
        }
        
        tapgesture = UITapGestureRecognizer(target: self, action:#selector(doubleTap(_:)))
        tapgesture?.numberOfTapsRequired = 2
        self.focusView!.addGestureRecognizer(tapgesture!)
        
        
        tapgestureForPhoto = UITapGestureRecognizer(target: self, action:#selector(capturePhoto(_:)))
        self.gestureViewForVideo!.addGestureRecognizer(tapgestureForPhoto!)
    }
    

    
    
    func moveToIMagePreviewScreen(photo:UIImage, isFromGallery: Bool) {
        turnFlashOff()
        if isFromChat {
            self.dismiss(animated: false) {
                self.chatVcDelegateObj?.selectedImage(imageToSend: photo)
            }
        }else {
            
            let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
            
            //PhotoEditorDelegate
            photoEditor.photoEditorDelegate = self
            //photoEditor.isForProfile = self.isForProfile
            photoEditor.image = photo
            photoEditor.isFromGallery = isFromGallery
            photoEditor.isForStory = isForStory
            photoEditor.isPresented = isForStory
            //Stickers that the user will choose from to add on the image
            //photoEditor.stickers.append(UIImage(named: "sticker" )!)
            
            //Optional: To hide controls - array of enum control
            photoEditor.hiddenControls = [ .share,.clear,.crop]
            //
            
            //Stickers that the user will choose from to add on the image
            for i in 0...10 {
                photoEditor.stickers.append(UIImage(named: i.description )!)
            }
            
            //Optional: Colors for drawing and Text, If not set default values will be used
            // photoEditor.colors = [.red,.blue,.green]
            
            //Present the View Controller
            if isForStory {
                
                photoEditor.modalPresentationStyle = .fullScreen
                self.present(photoEditor, animated: true, completion: nil)
            }else {
                photoEditor.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(photoEditor, animated: true)
            }
        }
        
        
    }
    
    func hideAllTheTools(ishide:Bool) {
        self.removeLastButton.isHidden = ishide
        self.nextButton.isHidden = ishide
        self.speedometerView.isHidden = ishide
        self.addSoundButton.isHidden = ishide
        self.closeButton.isHidden = ishide
        self.timerOptionView.isHidden = ishide
        self.muteOptionView.isHidden = ishide

    }
    
}

extension CameraViewController: SCRecorderDelegate {
    
    func recorder(_ recorder: SCRecorder, didAppendVideoSampleBufferIn session: SCRecordSession) {
        addNewSubView()
    }
    
    func recorder(_ recorder: SCRecorder, didComplete session: SCRecordSession) {
        longGesture?.state = .ended
        self.timerOptionView.isHidden = false
        self.isVideoFromLibrary = false
        moveToVideoPreviewScreen()
        self.gestureViewForVideo.isUserInteractionEnabled = false
    }
}

extension CameraViewController:AudioSelectedDelegate {
    func selectedAudio(selectedAudio: Audio) {
        self.selectedAudio = selectedAudio
        /*
         Bug Name :- Mute/Unmute button is working or not in the duet.
         Fix Date :- 30/04/2021
         Fixed By :- Jayaram G
         Description Of Fix :- hiding mute if user selected audio
         */
        self.muteOptionView.isHidden = true
        updateSelectedAudio()
    }
    
    func updateSelectedAudio() {
        if let customAudio = self.customAudioPath{
            selectedAudio = Audio.init(details: [:])
            selectedAudio?.url = customAudioUrl!
            self.setupAudioPlayerForAudioMix(audioPath: customAudio)
        }
        else if self.selectedAudio != nil {
            setupAudioPlayerFromSelectedAudio()
            saveSelectedAudio()
            // recorder.audioConfiguration.enabled = false
            self.addSoundButton.setTitle(self.selectedAudio!.name, for:.normal)
        }

    }
}


extension CameraViewController:PhotoEditorDelegate {
    func doneEditing(image: UIImage) {
        self.shouldDismiss = true
    }
    
    func canceledEditing() {
        print("canceeled captured image")
    }
}

extension CameraViewController: VideoPreviewViewControllerDelegate{
    
    func storyPostingDone(){
        //        self.shouldDismiss = true
        self.dismiss(animated: false, completion: {
            if self.isFromStoryListVC {
                self.delegate?.popAfterStoryUpdate()
            }
        })
    }
}

extension CameraViewController: ChatVideoDelegate {
    func selectedVideo(video: URL) {
        self.dismiss(animated: false) {
        self.chatVcDelegateObj?.selectedVideo(video: video)
        }
    }
    
    
}

extension CameraViewController: ClearVideoSegments {
    func resetVideoRecorder() {
        self.resetVideo()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension CameraViewController: DeepARDelegate {
    func didFinishPreparingForVideoRecording() { }
    
    func didStartVideoRecording() { }
    
    func didFinishVideoRecording(_ videoFilePath: String!) {

        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let components = videoFilePath.components(separatedBy: "/")
        guard let last = components.last else { return }
        let destination = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory, last))
    
                let newSegement = SCRecordSessionSegment(url: destination, info:nil)
            self.isVideoFromLibrary = false
            recorder.session?.addSegment(newSegement)
            self.addSegementProgressForLibrary()
        if self.isTimerCountOn{
            self.timerOptionView.isHidden = false
            moveToVideoPreviewScreen()
        }
            

    }
    
    func recordingFailedWithError(_ error: Error!) {}
    
    func didTakeScreenshot(_ screenshot: UIImage!) {
        
//        //image captured successfully.
//        let shutterView = UIView(frame: self.view.frame)
//        shutterView.backgroundColor = UIColor.white
//        self.previewView.addSubview(shutterView)
//        UIView.animate(withDuration: 0.3, animations: {
//            shutterView.alpha = 0
//        }, completion: { (_) in
//            shutterView.removeFromSuperview()
//            var flippedImage = capturedImage
//            if self.recorder.device == AVCaptureDevice.Position.front {
//                flippedImage = UIImage(cgImage: capturedImage!.cgImage!, scale: UIScreen.main.scale, orientation: .leftMirrored)
//            }
//            self.moveToIMagePreviewScreen(photo: flippedImage!, isFromGallery: false)
//        })
        
        
        let imageView = UIImageView(image: screenshot)
        imageView.frame = view.frame
        view.insertSubview(imageView, aboveSubview: arView)
        
        let flashView = UIView(frame: view.frame)
        flashView.alpha = 0
        flashView.backgroundColor = .black
        view.insertSubview(flashView, aboveSubview: imageView)
        
        UIView.animate(withDuration: 0.3, animations: {
            flashView.alpha = 1
        }) { _ in
            flashView.removeFromSuperview()
            imageView.removeFromSuperview()
            self.moveToIMagePreviewScreen(photo: screenshot, isFromGallery: false)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
           
//            }
        }
    }
    
    func didInitialize() {}
    
    func faceVisiblityDidChange(_ faceVisible: Bool) {}
}

