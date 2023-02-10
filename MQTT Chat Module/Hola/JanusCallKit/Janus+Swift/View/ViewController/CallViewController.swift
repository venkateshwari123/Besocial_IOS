//
//  CallViewController.swift
//  janus-gateway-ios
//
//  Created by Vengababu Maparthi on 11/02/19.
//  Copyright © 2019 MineWave. All rights reserved.
//

import UIKit
import CallKit
import PushKit
import RxSwift
import WebRTC
import CocoaLumberjack

class CallViewController: UIViewController  {
    
    var call : ConferenceView?
    var arrViews = [UIView]()
    var localView = UIView()
    var uuId : UUID?
    private lazy var isVideoCall: Bool = {
        arrViews.count > 0
    }()
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var lblVideoCallHeader: UILabel!
    @IBOutlet weak var lblOutGoingVideoCallStatus: UILabel!
    @IBOutlet weak var lblOutGoingVideoCallUserName: UILabel!
    @IBOutlet weak var btnVideoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var endButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var lblIncomingCallType: UILabel!
    @IBOutlet weak var lblAudioCallHeader: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var vwIncomingCall: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var turnCamera: UIButton!
    @IBOutlet weak var endCall: UIButton!
    @IBOutlet weak var addUsers: UIButton!
    @IBOutlet weak var vwAudioConfiguration: UIView!
    @IBOutlet weak var blackScreenView: UIView!
    
    @IBOutlet weak var videoButton: UIButton!
    
    @IBOutlet weak var view3: RTCEAGLVideoView!
    @IBOutlet weak var view2: RTCEAGLVideoView!
    @IBOutlet weak var view1: RTCEAGLVideoView!
    @IBOutlet weak var view4: UIView!
    
    //MARK: Audio Call Outlets
    @IBOutlet weak var lblAudioUserName: UILabel!
    @IBOutlet weak var lblAudioCallStatus: UILabel!
    @IBOutlet weak var imgAudioCallee: UIImageView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnAudioSpeaker: UIButton!
    @IBOutlet weak var btnAudioMute: UIButton!
    @IBOutlet weak var btnEndAudioCall: UIButton!
    @IBOutlet weak var vwAudioCall: UIView!
    
    @IBOutlet weak var imgIncomingBackground: UIImageView!
    
    //MARK: Group Call Views Constraints outlet
    @IBOutlet weak var firstViewWidth: NSLayoutConstraint!
    @IBOutlet weak var firstViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var secondViewHeight: NSLayoutConstraint!
    @IBOutlet weak var secondViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var thirdViewHeight: NSLayoutConstraint!
    @IBOutlet weak var thirdViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var localTrailing: NSLayoutConstraint!
    @IBOutlet weak var localbottom: NSLayoutConstraint!
    @IBOutlet weak var widthOfLocalView: NSLayoutConstraint!
    @IBOutlet weak var heightOfLocalView: NSLayoutConstraint!
    @IBOutlet weak var topSpaceOfLocalView: NSLayoutConstraint!
    
    var showAnActiveCall : Bool = false
    var showIncomingCall : Bool = false
    let viewModel = CallViewModel()
    var callType : CallType? = .none
    var callDisplayTimer: Timer?
    var callNotAnsweredTimer : Timer?
    var returnTimer:Bool = false
    var seconds = 0
    var player: AVAudioPlayer?
    var testFrameWidth = UIScreen.main.bounds.width
    var testFrameHeight = UIScreen.main.bounds.height
    var layerFrameWidth = 720
    var layerFrameHeight = 1280
    var tapGester : UITapGestureRecognizer?
    var swipeGester : UISwipeGestureRecognizer?
    var panGester : UIPanGestureRecognizer?
    var isvideoSwiped = false
    var callManager: CallManager!
    var userData : [String : Any]! {
        didSet {
            if let room = userData["room"] as? String{
                viewModel.room = Int64(room)
            }
            if let callId = userData["callId"] as? String{
                viewModel.callId = callId
            }
            if let calltype = userData["type"] as? String{
                self.callType = calltype == "audio" ? .Audio : .Video
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(false, forKey: "IsDisconnected")
        self.lblVideoCallHeader.text = "\(AppConstants.AppName) " + "Video Call".localized
        self.lblAudioCallHeader.text = "\(AppConstants.AppName) " + "Voice Call".localized
        self.lblOutGoingVideoCallStatus.text = "Calling".localized
        self.lblAudioCallStatus.text = "Calling".localized
        call = ConferenceView()
        call?.delegate = self
        callManager = AppDelegate.shared.callManager
        callManager.callsChangedHandler = { [weak self] in
            //            guard let self = self else { return }
        }
        self.initialize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.reconnecting), name: NSNotification.Name(rawValue: "ReconnectingStatus"), object: nil)
        addRxObservers()
        let name = NSNotification.Name(rawValue: "toolBarHideAndShow")
        NotificationCenter.default.post(name: name, object: self, userInfo: ["hide": true])
        if AppConstants.appType == .picoadda {
            /*
             Bug Name:- while app is on background and call is receiving. on click of notification call screen is opening. bug : in background post sound is coming
             Fix Date:- 01/04/2021
             Fixed By:- jayaram G
             Discription of Fix:- Accessing tabbar object here , from tabbar getting postdetails viewcontroller and calling function pauseVideo()
             */
            if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                guard let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController else {
                    return
                }
                guard let homeVC = swipeNav.viewControllers.first as? SocialViewController else {return}
                homeVC.muteVideo()
            }
            
        }else{
            /*
             Bug Name:- while app is on background and call is receiving. on click of notification call screen is opening. bug : in background post sound is coming
             Fix Date:- 01/04/2021
             Fixed By:- jayaram G
             Discription of Fix:- Accessing tabbar object here , from tabbar getting postdetails viewcontroller and calling function pauseVideo()
             */
            if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                guard let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController else {
                    return
                }
                if let postVC = swipeNav.viewControllers.first(where: { postVC in
                    return postVC.isKind(of:PostDetailsViewController.self )
                }) as? PostDetailsViewController{
                    postVC.currentIJKPlayer?.pause()
                }
            }
            
        }
        
        
    }
    
    @objc func reconnecting(notification: NSNotification) {
        /*
         Bug Name :- when internet drops while on call can we change alert view to text on call screen like on WhatsApp
         Fix Date :- 22/03/2021
         Fixed By :- Jayaram G
         Description Of Fix :- added observer for this , changing status text if network down
         */
        if let userInfo = notification.userInfo as? [String: Any] {
            if let isHide =  userInfo["hide"] as? Bool {
                if isHide {
                    if let userName = userData["userName"] as? String {
                        DispatchQueue.main.async {
                            self.returnTimer = true
                        }
                    }
                }else{
                    if let userName = userData["userName"] as? String {
                        DispatchQueue.main.async {
                            self.returnTimer = false
                            self.lblAudioCallStatus.text = self.timeString(time: TimeInterval(self.seconds))
                        }
                    }
                }
                
            }
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Refactor Date:- 20/04/21
         Refactor By  :- Nikunj C
         Description of Refactor:- check connectivity and show popup for no internet
         */
        
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    deinit {
        print("Deinitialized CallVC")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        /*
         Bug Name :- On calling the user second time, it is displayed as recalling user
         Fix Date :- 23/08/2021
         Fixed By :- Jayaram G
         Description Of Fix :- showing toolbar when view dismissed
         */
        UserDefaults.standard.set(true, forKey: "iscallgoingOn")
        let name = NSNotification.Name(rawValue: "toolBarHideAndShow")
        NotificationCenter.default.post(name: name, object: self, userInfo: ["hide": false])
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func initialize(){
        
        tapGester = UITapGestureRecognizer.init(target: self, action: #selector(tapGesterCliked))
        tapGester?.numberOfTapsRequired = 1
        
        
        swipeGester = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeGesterCliked))
        swipeGester?.numberOfTouchesRequired = 1
        swipeGester?.direction = .down
        self.view.addGestureRecognizer(swipeGester!)
        
        panGester = UIPanGestureRecognizer.init(target: self, action: #selector(panGesterCliked))
        
        self.view.addGestureRecognizer(tapGester!)
        
        MQTTManager.shared.delegate = self
        if showAnActiveCall{
            self.setupActiveCall()
        }else{
            showIncomingCall ? setupIncomingCall() : setupOutgoingCall()
        }
        let appde = UIApplication.shared.delegate as! AppDelegate
        
        switch callType {
        case .Audio:
            self.btnAccept.setImage(#imageLiteral(resourceName: "incomig_accept"), for: .normal)
            self.vwAudioCall.isHidden = false
            break
        case .Video:
            self.vwAudioCall.isHidden = true
            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            /*
             Bug Name :- Video call: We are not able to connect to the Bluetooth device in video call
             Fix Date :- 31/03/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added options  .allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP for audio session , if user want to switch from bluetooth to speaker or microphone , user has to turn off bluetooth from mobile settings
             */
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,options: [.allowBluetooth,.allowBluetoothA2DP,.allowAirPlay,.defaultToSpeaker])
            break
        case .Group:
            self.vwAudioCall.isHidden = true
            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            /*
             Bug Name :- Video call: We are not able to connect to the Bluetooth device in video call
             Fix Date :- 31/03/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added options  .allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP for audio session , if user want to switch from bluetooth to speaker or microphone , user has to turn of bluetooth from mobile settings
             */
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,options: [.allowBluetooth,.allowBluetoothA2DP,.allowAirPlay,.defaultToSpeaker])
            break
        case .none:
            self.vwAudioCall.isHidden = true
            break
        }
    }
    
    @objc func tapGesterCliked() {
        if isvideoSwiped == false{
            UIView.animate(withDuration: 3 ,delay:5 , options: .showHideTransitionViews , animations: {
                //                    self.endBtnConstantY.constant =  -(self.endBtnConstantY.constant + self.endVcall_btn.frame.size.height)
            }) { (isCompl) in}
            
        }else{
            let name = NSNotification.Name(rawValue: "toolBarHideAndShow")
            NotificationCenter.default.post(name: name, object: self, userInfo: ["hide": true])
            isvideoSwiped = false
            if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                guard let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController else {
                    return
                }
                /*
                 Bug Name :- on my phone not able to click on pip to load full screen
                 Fix Date :- 18/05/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- Added check for picoadda app
                 */
                if AppConstants.appType == .picoadda {
                    guard let homeVC = swipeNav.viewControllers.first as? SocialViewController else {return}
                    homeVC.muteVideo()
                }
            }
            
            self.testFrameHeight = UIScreen.main.bounds.height
            self.testFrameWidth = UIScreen.main.bounds.width
            layerFrameWidth = 720
            layerFrameHeight = 1280
            self.view.frame = CGRect.init(x: 0, y: 0, width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.view.layer.cornerRadius = 0
            self.view.clipsToBounds = false
            self.vwAudioConfiguration.isHidden = false
            self.imgAudioCallee.isHidden = false
            self.endCall.isHidden = false
            self.btnEndAudioCall.isHidden = false
            self.turnCamera.isHidden = false
            self.micButton.isHidden = false
            self.videoButton.isHidden = false
            /*
             Bug Name :- Video call: on making the video call blank the video pop up of the caller also should be blank
             Fix Date :- 12/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added blackscreen view and handling
             */
            self.blackScreenView.isHidden = !self.videoButton.isSelected
            self.view4.isHidden = false
            self.btnAccept.isHidden = false
            self.btnReject.isHidden = false
            self.endButtonBottomConstraint.constant = 35
            self.btnVideoHeightConstraint.constant = 68
            getTheStreamData(views: self.arrViews)
            self.view.removeGestureRecognizer(panGester!)
        }
    }
    
    @objc func panGesterCliked(_ panGester: UIPanGestureRecognizer){
        
        if panGester.state == .began || panGester.state == .changed{
            
            let traslation = panGester.translation(in: UIApplication.shared.keyWindow)
            
            panGester.view?.center =  CGPoint(x: panGester.view!.center.x + traslation.x, y: panGester.view!.center.y + traslation.y)
            
            panGester.setTranslation(CGPoint.zero, in: UIApplication.shared.keyWindow)
        }
    }
    
    
    @objc func swipeGesterCliked(_ swipeGester: UISwipeGestureRecognizer){
        if isvideoSwiped == false{
            let name = NSNotification.Name(rawValue: "toolBarHideAndShow")
            NotificationCenter.default.post(name: name, object: self, userInfo: ["hide": false])
            testFrameWidth = 100
            testFrameHeight = 150
            layerFrameWidth = 100
            layerFrameHeight = 150
            
            self.view.frame = CGRect.init(x: 50, y: 300, width:100, height: 150)
            self.view.layer.cornerRadius = 15
            self.view.clipsToBounds = true
            self.vwAudioConfiguration.isHidden = true
            self.imgAudioCallee.isHidden = true
            self.turnCamera.isHidden = true
            self.endCall.isHidden = true
            self.micButton.isHidden = true
            self.videoButton.isHidden = true
            self.view4.isHidden = true
            /*
             Bug Name :- Video call: on making the video call blank the video pop up of the caller also should be blank
             Fix Date :- 12/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added blackscreen view and handling
             */
            self.blackScreenView.isHidden = true
            self.btnEndAudioCall.isHidden = true
            self.btnAccept.isHidden = true
            self.btnReject.isHidden = true
            self.endButtonBottomConstraint.constant = 0
            self.btnVideoHeightConstraint.constant = 0
            isvideoSwiped = true
            getTheStreamData(views: self.arrViews)
            self.view.addGestureRecognizer(panGester!)
        }else{
            
        }
        
    }
    
    
    func addRxObservers() {
        addCreateCallObserver()
        addDisconnectCallObserver()
        addJoinCallObserver()
    }
    
    func addCreateCallObserver() {
        if !viewModel.createCall.hasObservers {
            viewModel.createCall.subscribe(onNext: { (isCreated) in
                if isCreated {
                    self.callNotAnsweredTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.endCallAfterNotAnsweredFail(_:)), userInfo: nil, repeats: false)
                    // Handle call
                }else{
                    self.stopSound()
                    if self.viewModel.callState == .busy {
                        //                        self.player?.stop()
                        self.playSound("busy_tone_ios", loop: 1)
                        self.lblAudioCallStatus.text = "is busy on other call".localized
                        self.lblOutGoingVideoCallStatus.text = "is busy on other call".localized
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.7) {
                            self.call?.stopConnection()
                        }
                    }else{
                        self.call?.stopConnection()
                        self.dismiss(animated: false) {
                            
                        }
                    }
                }
            }, onError: { error in
                DDLogError("Error occurred on viewModel.createCall, error is  \(error.localizedDescription)")
            }, onDisposed: {
                DDLogInfo("viewModel.createCall disposed")
            }).disposed(by: disposeBag)
        }
    }
    
    func addDisconnectCallObserver() {
        if !viewModel.disconnectCall.hasObservers {
            viewModel.disconnectCall.subscribe(onNext: { (isDisconnected) in
                self.call?.stopConnection()
            }, onError: { error in
                DDLogError("Error occurred on viewModel.disconnectCall, error is  \(error.localizedDescription)")
            }, onDisposed: {
                DDLogInfo("viewModel.disconnectCall disposed")
            }).disposed(by: disposeBag)
        }
    }
    
    func addJoinCallObserver() {
        if !viewModel.joinCall.hasObservers {
            viewModel.joinCall.subscribe(onNext: { (isCreated) in
                if isCreated {
                    // Handle call
                }
            }, onError: { error in
                DDLogError("Error occurred on viewModel.createCall, error is  \(error.localizedDescription)")
            }, onDisposed: {
                DDLogInfo("viewModel.createCall disposed")
            }).disposed(by: disposeBag)
        }
    }
    
    func disconnectCall() {
        DispatchQueue.main.async {
            self.viewModel.disconnectingCall {
                
            }
        }
        
    }
    
    func setupJanusCallKit() {
        self.call?.delegate = self
        if let room = self.viewModel.getRoom() {
            self.call?.roomId = room
        }
        self.call?.callType = self.callType
        self.call?.initialUpdateTheView()
        self.endCall.isHidden = false
        self.addUsers.isHidden = true
        self.videoButton.isEnabled = true
    }
    
    @objc func endCallAfterNotAnsweredFail(_ timer: Timer){
        self.lblAudioCallStatus.text = "call not answered".localized
        self.lblOutGoingVideoCallStatus.text = "call not answered".localized
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.exitCall(self.endCall as Any)
        }
    }
}


extension CallViewController: ConferenceDelegate {
    
    func getTheLocalView(view:UIView) {
        localView.backgroundColor = .black
        localView = view
        view4.addSubview(localView)
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        widthOfLocalView.constant = screenWidth
        heightOfLocalView.constant = screenHeight
        topSpaceOfLocalView.constant = 0
        
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            self.view.layoutIfNeeded()
        })
        //   updateTheViews(count: 0)
        if let previe = view4.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previe.videoGravity = .resizeAspectFill
            view4.layer.addSublayer(previe)
            previe.frame = view4.bounds
            self.view.backgroundColor = .black
            self.view.layoutIfNeeded()
        }
    }
    
    func getTheStreamData(views:[UIView]) {
        arrViews = views
        guard let remoteView = arrViews.first else{
            return
        }
        
        videoButton.isEnabled = arrViews.count > 0 ? true : false
        isVideoCall = true
        let aspectRatio: CGSize = CGSize.init(width: layerFrameWidth, height: layerFrameHeight)
        let maxFloat = CGFloat.maximum(self.view.frame.width, self.view.frame.height)
        let newAspectRatio = aspectRatio.height / aspectRatio.width
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        if (aspectRatio.width > aspectRatio.height) {
            frame.size.width = maxFloat;
            frame.size.height = frame.size.width / newAspectRatio;
        } else {
            frame.size.height = maxFloat;
            frame.size.width = frame.size.height / newAspectRatio;
        }
        frame.origin.x = (self.view.frame.width - frame.size.width) / 2
        frame.origin.y = (self.view.frame.height - frame.size.height) / 2
        
        remoteView.layer.frame = frame
        remoteView.layer.contentsGravity = .resizeAspect
        view1.contentMode = .scaleAspectFill
        view1.addSubview(remoteView)
        
        widthOfLocalView.constant = UIScreen.main.bounds.width/3
        heightOfLocalView.constant = UIScreen.main.bounds.height/3
        topSpaceOfLocalView.constant = 44
        firstViewWidth.constant = testFrameWidth
        firstViewHeight.constant = testFrameHeight
        
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.view.layoutIfNeeded()
        })
        if let previe = view4.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previe.videoGravity = .resizeAspectFill
            view4.layer.addSublayer(previe)
            previe.frame = view4.bounds
            self.view.layoutIfNeeded()
        }
    }
    
    func joinedRoom() {
        DDLogInfo("Joined Room Delegate called")
        if showIncomingCall {
            viewModel.joinACall()
            /*
             Bug Name :- Call duration not syncing on both sender and receiver side
             Fix Date :- 25/03/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Starting call duration after call conneted on bothsides
             */
            
            if callType == .Audio {
                self.callDisplayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(_:)) , userInfo: nil, repeats: true)
                self.lblAudioCallStatus.text = self.timeString(time: TimeInterval(self.seconds))
            }
        }else{
            viewModel.createNewCall(callType!.description)
        }
    }
    
    func disConnectTheCall() {
        let appde = UIApplication.shared.delegate as! AppDelegate
        appde.callProviderDelegate?.endCall(call:uuId ?? UUID())
        if let views = appde.window?.subviews, views.contains(where: {
            $0.parentViewController?.isKind(of: CallViewController.self) ?? false
        }){
        }
        MQTTManager.shared.isDisplayed = false
        self.view.removeFromSuperview()
        self.dismiss(animated: false) {
        }
    }
}

extension CallViewController : MQTTManagerDelegate{
    func receivedMessage(_ message: [AnyHashable : Any], andChannel channel: String!) {
        let appde = UIApplication.shared.delegate as! AppDelegate
        if let data = message["data"] as? [String : Any]{
            if let action = data["action"] as? Int, action == 4{
                if uuId != nil {
                    appde.callProviderDelegate?.endCall(call: uuId ?? UUID())
                }
                /*
                 Bug Name :- if user rejects the call Give message to "User is busy, please try again after sometime"
                 Fix Date :- 31/03/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- handled message from mqtt and showing toast message on top of the calling screen
                 */
                if let message = data["message"] as? String {
                    DispatchQueue.main.async {
                        Helper.toastView(messsage: message, view: self.view)
                    }
                }
                if let userId = data["userId"] as? String, Utility.getUserid() == userId {
                    
                }else{
                    DispatchQueue.main.async {
                        self.exitCall(self.endCall)
                    }
                }
                
            }else if let action = data["action"] as? Int, action == 3{
                self.stopSound()
                if self.callDisplayTimer == nil {
                    self.callNotAnsweredTimer?.invalidate()
                    self.callDisplayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(_:)) , userInfo: nil, repeats: true)
                    self.lblAudioCallStatus.text = self.timeString(time: TimeInterval(self.seconds))
                    UserDefaults.standard.set(true, forKey: "iscallgoingOn")
                    UserDefaults.standard.synchronize()
                }
                lblVideoCallHeader.isHidden = true
                lblOutGoingVideoCallStatus.isHidden = true
                lblOutGoingVideoCallUserName.isHidden = true
            }else if let action = data["action"] as? Int, action == 5{
                
            }
        }else if message[AnyHashable("type")] as? String == "16" || message[AnyHashable("type")] as? String == "15" {
            appde.callProviderDelegate?.endCall(call: uuId ?? UUID())
        }
    }
    
    
    
    @objc func updateTimer(_ timer: Timer){
        DispatchQueue.main.async {
            self.seconds += 1
            if self.returnTimer {
                return
            }
            self.lblAudioCallStatus.text = self.timeString(time: TimeInterval(self.seconds))
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}
