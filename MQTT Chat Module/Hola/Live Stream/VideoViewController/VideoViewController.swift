//
//  VideoViewController.swift
//  AntMediaReferenceApplication
//
//  Created by Oğulcan on 14.06.2018.
//  Copyright © 2018 AntMedia. All rights reserved.
//

import UIKit
//import AntMediaSDK.Swift
//import AntMediaSDK
import WebRTC
import GLKit
import RxCocoa
import RxSwift
import Reachability
import RxReachability
import Locksmith
protocol VideoViewControllerDelegate: class {
    func streamDidFinish(streamName: String, streamTime : String)
    func dismissScreen()
}

class VideoViewController: UIViewController, /* RTCVideoViewDelegate */ RTCEAGLVideoViewDelegate {
    
    
    @IBOutlet weak var vwCheckingInternetConnection: UIVisualEffectView!
    
    @IBOutlet weak var btnEnd: DesignableButton!
    @IBOutlet weak var btnBack: DesignableButton!
    @IBOutlet weak var localVideoView: RTCEAGLVideoView!
    @IBOutlet weak var remoteVideoView: RTCEAGLVideoView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var containerOther: UIView!
    @IBOutlet weak var containerSelf: UIView!
    @IBOutlet weak var containerStreamEnded: UIView!
    
    @IBOutlet weak var modeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var lblCheckingConnection: UILabel!
    @IBOutlet weak var footerStatusLabel: UILabel!
    @IBOutlet weak var footerInfoLabel: UILabel!
    
    // Auto Layout Constraints used for animations
    //    @IBOutlet weak var remoteViewTopConstraint: NSLayoutConstraint?
    //    @IBOutlet weak var remoteViewRightConstraint: NSLayoutConstraint?
    //    @IBOutlet weak var remoteViewLeftConstraint: NSLayoutConstraint?
    //    @IBOutlet weak var remoteViewBottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerLeftConstraint: NSLayoutConstraint?
    @IBOutlet weak var footerViewBoomConstraint: NSLayoutConstraint?
    
    var liveOverLay : LiveOverlayViewController? = nil
    var client: AntMediaClient? = nil
    var clientUrl: String = AppConstants.StreamUrl
    var clientStreamId: String = ""
    var clientToken: String = ""
    var clientMode: AntMediaClientMode!
    
    var tapGesture: UITapGestureRecognizer!
    var varStreamTime : Int64 = 0
    var streamModel = StreamModel()
    var streamName : String = ""
    let disposebag = DisposeBag()
    let reachability = Reachability()!
    var streamId = ""
    var isDismissed : Bool = false
    var isDisconected: Bool = false
    var streamData : StreamData? = nil
    weak var delegate: VideoViewControllerDelegate?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        remoteVideoView.delegate = self
        localVideoView.delegate = self
        containerView.isHidden = true
        
        footerStatusLabel.text = "Connecting to".localized + ": ws://"
        footerInfoLabel.text = "Check for more details".localized + ": AntMedia.io"
        modeLabel.text = "Mode".localized + ": P2P"
        btnEnd.setTitle("End".localized, for: .normal)
        self.lblCheckingConnection.text = "Connecting to live stream".localized + "," + "Your broadcast will start soon".localized + "."
        self.localVideoView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.remoteVideoView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.client = AntMediaClient.init()
        self.client?.delegate = self
        if Utility.getDeviceHasSafeAreaStatus() {
            self.modeTopConstraint.constant = 54
        }else {
            self.modeTopConstraint.constant = 30
        }
        self.btnEnd.isHidden = true //clientMode == .play
        self.btnBack.isHidden = clientMode == .publish
        
        if clientMode == .play{
            self.lblCheckingConnection.text = "Connecting to live stream".localized
        }
        
        initialize()
        setGesture()
    }
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- check connectivity and show popup for no internet
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.checkConnectionAvaibility(view: self.view)

    }
    
    func initialize(){
        
        if self.clientMode == AntMediaClientMode.publish {
            //            self.localVideoView.isHidden = true
            //            self.client?.setVideoViews(local: self.remoteVideoView, remote: self.localVideoView)
            self.containerSelf.isHidden = true
            self.containerOther.isHidden = false
            streamId = ""
//            if let id = Utility.getStreamId(){
//                streamId = id
//            }
            var userImage = "https://admin.loademup.xyz/pics/user.jpg"
            if let image = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.streamThumbnailImage) as? String{
                userImage = image
            }
            else if let image = Utility.getUserImage(){
                userImage = image
            }
            let param = BroadCastParams.init(streamID: streamId, streamType: "start", streamName: (Utility.getUserid()!)+streamName, streamThumbnail: userImage)
            
            streamModel.goToLiveStreaming(param: param) { (response) in
                guard let streamData = response else{return}
                self.streamId = streamData["streamId"] as! String
                print("Strem ID"+self.streamId)
                UserDefaults.standard.setValue(self.streamId, forKey: AppConstants.UserDefaults.activeStreamId)
                self.client?.delegate = self
                self.client?.setOptions(url: self.clientUrl, streamId: self.streamId, token: self.clientToken, mode: self.clientMode)
                //                self.client?.setVideoViews(local: self.remoteVideoView, remote: self.localVideoView)
                self.client?.setRemoteView(remoteContainer: self.remoteVideoView)
                self.client?.setLocalView(container: self.localVideoView)
                //                self.client?.connect()
                self.client?.connectWebSocket()
                self.checkReachbility()
            }
        } else if self.clientMode == AntMediaClientMode.play {
            self.remoteVideoView.isHidden = false
            //            self.localVideoView.isHidden = true
            self.containerSelf.isHidden = false
            self.containerOther.isHidden = true
            //            self.client?.setVideoViews(local: self.localVideoView, remote: self.remoteVideoView)
            
            self.client?.setRemoteView(remoteContainer: self.remoteVideoView)
            self.client?.setLocalView(container: self.localVideoView)
            self.client?.setOptions(url: self.clientUrl, streamId: clientStreamId, token: self.clientToken, mode: self.clientMode)
            //            self.client?.connect()
            self.client?.connectWebSocket()
            streamModel.subscribeToStream(type: "start", streamID: clientStreamId)
            print("Strem ID"+clientStreamId)
        }
        
    }
    
    deinit {
        self.streamId = ""
        self.remoteVideoView.delegate = nil
        self.client?.delegate = nil
        self.client = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let audienceVC : AudienceOverLayVC = segue.destination as? AudienceOverLayVC, self.clientMode == .play{
            audienceVC.audiStreamID = self.clientStreamId
            audienceVC.streamStartedTime = varStreamTime
            audienceVC.isActive = true
            audienceVC.receiverName = self.streamData?.userName ?? ""
            audienceVC.receiverId = self.streamData?.userID ?? ""
            audienceVC.delegate = self
        }else if let liveOverLay : LiveOverlayViewController = segue.destination as? LiveOverlayViewController, self.clientMode == .publish{
            liveOverLay.delegate = self
            liveOverLay.isActive = true
            liveOverLay.audiStreamID = self.streamId
            self.liveOverLay = liveOverLay
        }else if let streamEnded : LiveStreamEndedViewController = segue.destination as? LiveStreamEndedViewController {
            if clientMode == .play{
                streamEnded.streamData = self.streamData
            }
        }
    }
    
    
    @IBAction func checckingViewBackAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.isDismissed = true
                self.delegate?.dismissScreen()
            }
        }
    }
    
    
    
    
    //MARK:- Buttons Action
    @IBAction func btnBack_Tapped(_ sender: Any) {
        if clientMode == .publish{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "End Live Video".localized, style: .destructive , handler:{ (UIAlertAction)in
                if self.clientMode == .publish{
                    self.streamModel.endStream(streamID: self.streamId) { (response) in
                        print(response as! Any)
                        if self.client == nil {
                            self.dismiss(animated: true) {
                            }
                        }
                    }
                }
                self.isDismissed = true
                //                self.client?.disconnect()
                self.remoteVideoView.delegate = nil
                self.client?.stop()
            }))
            alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel , handler:{ (UIAlertAction)in }))
            self.present(alert, animated: true, completion: nil)
        }else{
            self.streamModel.subscribeToStream(type: "stop", streamID: self.clientStreamId)
            self.dismiss(animated: true) {
                self.isDismissed = true
                //                self.client?.disconnect()
                self.client?.stop()
                self.remoteVideoView.delegate = nil
            }
        }
    }
    
    @IBAction func audioTapped(_ sender: UIButton!) {
        self.client?.toggleAudio()
    }
    
    @IBAction func videoTapped(_ video: UIButton!) {
        video.isSelected = !video.isSelected
        self.localVideoView.transform = video.isSelected ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.remoteVideoView.transform = video.isSelected ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.client?.toggleVideo()
    }
    
    @IBAction func closeTapped(_ sender: UIButton!) {
        //        self.client?.disconnect()
        self.client?.stop()
        self.dismiss(animated: true) {
            self.remoteVideoView.delegate = nil
            self.client?.delegate = nil
            self.client = nil
        }
    }
    
    private func setGesture() {
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(VideoViewController.toggleContainer))
        self.tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        self.remoteVideoView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func toggleContainer() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            if (self.containerLeftConstraint!.constant <= -45.0) {
                self.containerLeftConstraint!.constant = 15.0
                self.containerView.alpha = 1.0
            } else {
                self.containerLeftConstraint!.constant = -45.0
                self.containerView.alpha = 0.0
            }
            self.view.layoutIfNeeded()
        })
    }
    
    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
        let defaultAspectRatio: CGSize = size
        let aspectRatio: CGSize = size.equalTo(CGSize.zero) ? defaultAspectRatio : size
        let maxFloat = CGFloat.maximum(self.view.frame.width, self.view.frame.height)
        let newAspectRatio = aspectRatio.width / aspectRatio.height
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        if (aspectRatio.width < aspectRatio.height) {
            frame.size.width = maxFloat;
            frame.size.height = frame.size.width / newAspectRatio;
        } else {
            frame.size.height = maxFloat;
            frame.size.width = frame.size.height * newAspectRatio;
        }
        frame.origin.x = (self.view.frame.width - frame.size.width) / 2
        frame.origin.y = (self.view.frame.height - frame.size.height) / 2
        
        self.remoteVideoView.frame = frame
        self.localVideoView.frame = frame
    }
    
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        let defaultAspectRatio: CGSize = size
        let aspectRatio: CGSize = size.equalTo(CGSize.zero) ? defaultAspectRatio : size
        let maxFloat = CGFloat.maximum(self.view.frame.width, self.view.frame.height)
        let newAspectRatio = aspectRatio.width / aspectRatio.height
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        if (aspectRatio.width < aspectRatio.height) {
            frame.size.width = maxFloat;
            frame.size.height = frame.size.width / newAspectRatio;
        } else {
            frame.size.height = maxFloat;
            frame.size.width = frame.size.height * newAspectRatio;
        }
        frame.origin.x = (self.view.frame.width - frame.size.width) / 2
        frame.origin.y = (self.view.frame.height - frame.size.height) / 2
        
        self.remoteVideoView.frame = frame
        self.localVideoView.frame = frame
    }
    
    
    func checkReachbility(){
        Reachability.rx.isReachable
            .subscribe(onNext: { [weak self] isReachable in
                guard let strongSelf = self else{return}
                if isReachable && strongSelf.isDisconected{
                    strongSelf.isDisconected = false
                    strongSelf.client = AntMediaClient.init()
                    strongSelf.client?.delegate = self
                    strongSelf.client?.setRemoteView(remoteContainer: strongSelf.remoteVideoView)
                    strongSelf.client?.setLocalView(container: strongSelf.localVideoView)
                    if strongSelf.clientMode == .play{
                        strongSelf.client!.setOptions(url: strongSelf.clientUrl, streamId: strongSelf.clientStreamId, token: strongSelf.clientToken, mode: strongSelf.clientMode)
                    }else{
                        strongSelf.client!.setOptions(url: strongSelf.clientUrl, streamId: strongSelf.streamId, token: strongSelf.clientToken, mode: strongSelf.clientMode)
                    }
                    strongSelf.client!.connectWebSocket()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                        let dict = ["streamID": strongSelf.streamId, "messageType" : "0"] as [String : Any]
                        do{
                            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                            print(jsonData)
                            MQTT.sharedInstance.publishData(wthData: jsonData, onTopic: AppConstants.MQTT.subscribe+strongSelf.streamId, retain: false, withDelivering: .exactlyOnce)
                        }catch{
                            
                        }
                    }

                }
            }).disposed(by: disposebag)
        
        do{
            try reachability.startNotifier()
        }catch{
        }
    }
    
}

//MARK:- AntMediaClient Delegate
extension VideoViewController: AntMediaClientDelegate {
    func playStarted() {
        print("Play Started : VideoViewController")
    }
    
    func playFinished() {
        print("Play finished : VideoViewController")
    }
    
    func publishStarted() {
        print("Publish Started : VideoViewController")
    }
    
    func publishFinished() {
        print("Publish Finished : VideoViewController")
    }
    
    func disconnected() {
        if self.clientMode == .play {
            DispatchQueue.main.async{
//                self.containerStreamEnded.isHidden = false
            }
        }
        print("Disconnected : VideoViewController")
    }
    
    
    func clientDidConnect(_ client: AntMediaClient) {
        DispatchQueue.main.async {
            self.client?.start()
        }
        
        print("Client did connect : VideoViewController")
    }
    
    func clientDidDisconnect(_ message: String) {
        if isDismissed{
            self.delegate?.streamDidFinish(streamName: self.streamName,streamTime: liveOverLay!.streamTime.text!)
            self.dismiss(animated: true) {
                self.remoteVideoView.delegate = nil
                self.client?.delegate = nil
                self.client = nil
            }
        }else{
            self.isDisconected = true
            self.client?.delegate = nil
            self.client = nil
        }
        print("Client did disconnect : VideoViewController")
    }
    
    func clientHasError(_ message: String) {
        if !isDisconected{
            if presentedViewController == self {
                AlertHelper.getInstance().show("".localized, message: message, cancelButtonText: "OK".localized, cancelAction: {
                    self.dismiss(animated: true, completion: nil)
                })
            }else {
                presentedViewController?.dismiss(animated: true, completion: {
                    AlertHelper.getInstance().show("".localized, message: message, cancelButtonText: "OK".localized, cancelAction: {
                        self.dismiss(animated: true, completion: nil)
                    })
                })
            }
        }
        print("Client has Error : VideoViewController")
    }
    
    func remoteStreamStarted() {
        Run.onMainThread {
            if self.client?.getCurrentMode() == .play {
                self.localVideoView.bringSubviewToFront(self.remoteVideoView)
                self.remoteVideoView.isHidden = false
                self.localVideoView.isHidden = true
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                } catch _ {
                }
            }
            
            Run.afterDelay(1, block: {
                Run.onMainThread {
                    self.vwCheckingInternetConnection.isHidden = true
                }
            })
        }
    }
    
    func remoteStreamRemoved() {
        print("Remote stream removed")
        if (self.client?.getCurrentMode() == .play) {
            //            self.client = nil
            if self.isDismissed{
                self.dismiss(animated: true, completion: {
                    self.client?.delegate = nil
                    self.client = nil
                    self.remoteVideoView.delegate = nil
                })
            }else{
                AlertHelper.getInstance().show("Alert".localized, message: "Remote stream is no longer available".localized, cancelButtonText: "OK".localized, cancelAction: {
                    self.isDismissed = true
                    self.client?.stop()
                    self.remoteVideoView.delegate = nil
                    self.dismiss(animated: true, completion: {
                        //self.client?.delegate = nil
                    })
                })
            }
        } else {
            AlertHelper.getInstance().show("Caution".localized + "!", message: "Remote stream is no longer available".localized, cancelButtonText: "OK".localized, cancelAction: {
            })
        }
        print("Remote stream Removed : VideoViewController")
    }
    
    func localStreamStarted() {
        Run.onMainThread {
            if self.client?.getCurrentMode() == .publish {
                self.lblCheckingConnection.text = "You are live now".localized + "!"
                self.remoteVideoView.isHidden = true
                self.localVideoView.isHidden = false
            }
            
            Run.afterDelay(1, block: {
                Run.onMainThread {
                    self.vwCheckingInternetConnection.isHidden = true
                }
            })
        }
    }
    
}

extension VideoViewController:BackToVCDelegate{
    func endButtonHandle() {
        self.btnBack_Tapped(btnEnd)
    }
    
    func streamHasEnded() {
        
    }
    
    
    func streamHasEnded(streamId : String) {
        if streamId == self.clientStreamId {
            self.containerStreamEnded.isHidden = false
        }
        
//        let streamId = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.streamID)
//        let dict = ["streamID": streamId]
//        do{
//            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
//            print(jsonData)
//            MQTT.sharedInstance.publishData(wthData: jsonData, onTopic: AppConstants.MQTT.lastWill, retain: false, withDelivering: .exactlyOnce)
//        }catch{
//
//        }
    }
    
    func changeCameraAudio(type: Int, button : UIButton) {
        if type == 1{
            self.audioTapped(nil)
        }else{
            self.videoTapped(button)
        }
    }
}

extension VideoViewController:AudienceDelegate{
    func streamReconnected(streamId: String) {
        self.client = AntMediaClient.init()
        self.client?.delegate = self
        self.client?.setRemoteView(remoteContainer: self.remoteVideoView)
        self.client?.setLocalView(container: self.localVideoView)
        self.client?.setOptions(url: self.clientUrl, streamId: clientStreamId, token: self.clientToken, mode: self.clientMode)
        self.client?.connectWebSocket()
    }
}
