//
//  ClientView.swift
//  janus-gateway-ios
//
//  Created by Vengababu Maparthi on 11/02/19.
//  Copyright © 2019 MineWave. All rights reserved.
//

import Foundation
import WebRTC

protocol ConferenceDelegate {
    func getTheStreamData(views:[UIView])
    func getTheLocalView(view:UIView)
    func joinedRoom()
    func disConnectTheCall()
    
}

public enum CallType : Int{
    case Audio
    case Video
    case Group
    
    var description: String {
        switch self {
        case .Audio:  return "audio"
        case .Video:   return "video"
        case .Group:     return "video"
        }
    }
}

struct Constant {
    static let totalTime = 30.0
    static let elapsingTime = 1.0
}


private let kARDMediaStreamId = "ARDAMS"
private let kARDAudioTrackId = "ARDAMSa0"
private let kARDVideoTrackId = "ARDAMSv0"

class ConferenceView: NSObject {
    
    var factory: RTCPeerConnectionFactory?
    var localView: RTCCameraPreviewView?
    var videoViews: [UIView] = []
    var websocket: WebSocketChannel?
    var roomId: Int64?
    var peerConnectionDict: [NSNumber : Any] = [:]
    var publisherPeerConnection: RTCPeerConnection? = nil
    var localTrack: RTCVideoTrack?
    var localAudioTrack: RTCAudioTrack?
    var delegate:ConferenceDelegate!
    static var localStream : RTCAVFoundationVideoSource!
    var callType : CallType? = .none
    var timer:Timer!
    var remainingTime:Double!
    var didLeaveTheCall : (()->())?
    
    func initialUpdateTheView() {
        self.videoViews.removeAll()
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        self.localView = nil
        self.localView = RTCCameraPreviewView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        
        
        self.localView?.layer.contentsGravity = .center
        
        let url = URL(string: AppConstants.socketUrl)
        if let roomId = self.roomId {
            self.websocket = WebSocketChannel(url: url, roomId: NSNumber(value: roomId))
        }
        self.peerConnectionDict = [NSNumber : Any]()
        if self.factory == nil{
            self.factory = RTCPeerConnectionFactory.init()
        }
        if self.callType == .Video {
            DispatchQueue.main.async {
                self.localTrack = nil
                self.localTrack = self.createLocalVideoTrack()
                if let delegate = self.delegate {
                    delegate.getTheLocalView(view: self.localView!)
                }
            }
        }
        self.localAudioTrack = self.createLocalAudioTrack()
        self.websocket?.delegate = self
        
    }
    
    deinit {
        print("conferenceView deinit")
    }
    
    func stopConnection() {
        websocket?.disconnect()
        websocket?.delegate = nil;
    }
    
    func createLocalVideoTrack() -> RTCVideoTrack? {
        
        if let currentMediaConstraint = self.currentMediaConstraint() as? [String : String],
           let factory = self.factory,
           let localView = self.localView {
            let cameraConstraints = RTCMediaConstraints(mandatoryConstraints: currentMediaConstraint, optionalConstraints: nil)
            if ConferenceView.localStream != nil {
                ConferenceView.localStream!.captureSession.stopRunning()
                ConferenceView.localStream!.captureSession.resetInputs()
            }
            ConferenceView.localStream = nil
            ConferenceView.localStream = factory.avFoundationVideoSource(with: cameraConstraints)
            let source = ConferenceView.localStream!
            
            ConferenceView.localStream!.captureSession.startRunning()
            
            source.adaptOutputFormat(toWidth: 720, height: 1280, fps: 30)
            localView.captureSession = source.captureSession
            
            let localVideoTrack: RTCVideoTrack? = factory.videoTrack(with: source, trackId: kARDVideoTrackId)
            return localVideoTrack
        }
        return nil
    }
    
    
    func currentMediaConstraint() -> [String : Any]? {
        var mediaConstraintsDictionary: [String : Any]? = nil
        let widthConstraint = "1280"
        let heightConstraint = "720"
        let minwidthConstraint = "480"
        let minheightConstraint = "640"
        let frameRateConstrait =  "30"
        
        if widthConstraint != "" && heightConstraint != "" {
            mediaConstraintsDictionary = [kRTCMediaConstraintsMinWidth: minwidthConstraint,
                                          kRTCMediaConstraintsMaxWidth: widthConstraint,
                                         kRTCMediaConstraintsMinHeight: minheightConstraint,
                                         kRTCMediaConstraintsMaxHeight: heightConstraint,
                                      kRTCMediaConstraintsMaxFrameRate: frameRateConstrait]
        }
        return mediaConstraintsDictionary
    }
    
    func createLocalAudioTrack() -> RTCAudioTrack? {
        if let factory = factory,
           let constraints = defaultMediaAudioConstraints() {
            let source = factory.audioSource(with: constraints)
            let track = factory.audioTrack(with: source, trackId: kARDAudioTrackId)
            let audioSession = AVAudioSession.sharedInstance()
            var volume: Float?
            do {
                try audioSession.setActive(true)
                source.volume = Double(audioSession.outputVolume)
            } catch {
                print("Error Setting Up Audio Session")
            }
            
            return track
        }
        return nil
    }
    
    func defaultMediaAudioConstraints() -> RTCMediaConstraints? {
        let mandatoryConstraints = ["kRTCMediaConstraintsLevelControl": kRTCMediaConstraintsValueFalse]
        let constraints = RTCMediaConstraints(mandatoryConstraints: mandatoryConstraints, optionalConstraints: nil)
        return constraints
    }
    
    func createRemoteView() -> RTCEAGLVideoView? {
        let remoteView = RTCEAGLVideoView()
        remoteView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        videoViews.append(remoteView)
        if delegate != nil {
            delegate.getTheStreamData(views: self.videoViews)
        }
        return remoteView
    }
    
    func defaultSTUNServer() -> RTCIceServer? {
        if let arrIceServer = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.iceServers) as? [String],let iceUserName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.iceServerUserName) as? String,let credentials = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.iceServerCreds) as? String {
            return RTCIceServer(urlStrings: arrIceServer, username: iceUserName, credential: credentials)
        }
        return RTCIceServer(urlStrings: [], username: "", credential: "")
    }
    
    func defaultPeerConnectionConstraints() -> RTCMediaConstraints? {
        let optionalConstraints = ["DtlsSrtpKeyAgreement": "true"]
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: optionalConstraints)
        return constraints
    }
    
    func createPeerConnection() -> RTCPeerConnection? {
        let constraints: RTCMediaConstraints? = defaultPeerConnectionConstraints()
        let config = RTCConfiguration()
        let iceServers = [defaultSTUNServer()]
        config.iceServers = iceServers as! [RTCIceServer]
        config.iceTransportPolicy = .all //RTCIceTransportPolicyRelay;
        guard let constraintsObj = constraints else {return nil}
        let peerConnection: RTCPeerConnection? = factory?.peerConnection(with: config, constraints: constraintsObj, delegate: self)
        return peerConnection
    }
    
    func createAudioSender(_ peerConnection: RTCPeerConnection?) -> RTCRtpSender? {
        let sender: RTCRtpSender? = peerConnection?.sender(withKind: kRTCMediaStreamTrackKindAudio, streamId: kARDMediaStreamId)
        if let localAudioTrack = localAudioTrack {
            sender?.track = localAudioTrack
        }
        return sender
    }
    
    func createVideoSender(_ peerConnection: RTCPeerConnection?) -> RTCRtpSender? {
        let sender: RTCRtpSender? = peerConnection?.sender(withKind: kRTCMediaStreamTrackKindVideo, streamId: kARDMediaStreamId)
        if let localTrack = localTrack {
            sender?.track = localTrack
        }
        return sender
    }
    
    func createPublisherPeerConnection() {
        publisherPeerConnection = createPeerConnection()
        _ = self.createAudioSender(publisherPeerConnection)
        if callType == .Video {
            _ = self.createVideoSender(publisherPeerConnection)
        }
    }
    
    func offerPeerConnection(_ handleId: NSNumber?) {
        createPublisherPeerConnection()
        let jc = JanusConnection()
        jc.connection = publisherPeerConnection
        jc.handleId = handleId
        UserDefaults.standard.set(handleId, forKey: "LEAVEID")
        UserDefaults.standard.synchronize()
        if let handleId = handleId {
            peerConnectionDict[handleId] = jc
        }
        if publisherPeerConnection != nil {
            publisherPeerConnection!.offer(for: defaultOfferConstraints()!, completionHandler: { [weak self] sdp, error in
                guard let self = self else {return}
                self.publisherPeerConnection!.setLocalDescription(sdp!, completionHandler: { error in
                    self.websocket!.publisherCreateOffer(handleId, sdp: sdp)
                })
            })
        }
    }
    
    func defaultOfferConstraints() -> RTCMediaConstraints? {
        let mandatoryConstraints = [ "OfferToReceiveAudio": "false",
                                     "OfferToReceiveVideo": "false"]
        let constraints = RTCMediaConstraints(mandatoryConstraints: mandatoryConstraints, optionalConstraints: nil)
        return constraints
    }
    
}

extension ConferenceView {
    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
        var rect: CGRect = videoView.frame
        //  rect.size = size
        let multiplier: CGFloat = videoViews.count > 1 ? 1 : 1/2
        rect.size = CGSize(width: UIScreen.main.bounds.size.width * multiplier, height: UIScreen.main.bounds.size.height * multiplier)
        videoView.contentMode = .scaleAspectFill
        print(String(format: "========didChangeVideSize %fx%f", size.width, size.height))
        videoView.frame = rect
    }
    
    func activateTimer()
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 20) {
            DispatchQueue.main.async {
                self.stopConnection()
                if self.delegate != nil {
                    self.delegate.disConnectTheCall()
                }
            }
        }
    }
    
    @objc func countDown(){
        if remainingTime > 0{
            
            remainingTime = remainingTime - Constant.elapsingTime
        }else {
            
            timer.invalidate()
        }
    }
}

extension ConferenceView: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("=========didAddStream")
        var janusConnection: JanusConnection?
        for key in peerConnectionDict.keys {
            let jc: JanusConnection = peerConnectionDict[key] as! JanusConnection
            if peerConnection == jc.connection {
                janusConnection = jc
                break
            }
        }
        
        DispatchQueue.main.async(execute: {
            if stream.videoTracks.count != 0 {
                let remoteVideoTrack = stream.videoTracks[0]
                let remoteView: RTCEAGLVideoView? = self.createRemoteView()
                if let remoteView = remoteView {
                    remoteVideoTrack.add(remoteView)
                }
                janusConnection?.videoTrack = remoteVideoTrack
                janusConnection?.videoView = remoteView
                try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                /*
                 Bug Name :- We are not able to connect to the Bluetooth device
                 Fix Date :- 31/03/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- Added options  .allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP for audio session
                 */
                try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP,.defaultToSpeaker])
            }
        })
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("=========didRemoveStream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("=========peerConnectionShouldNegotiate==\(peerConnection)")
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("=========didChange==\(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("=========didChange=RTCIceGatheringState=\(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("=========didGenerateIceCandidate==\(candidate.sdp)")
        var handleId: NSNumber?
        for key in peerConnectionDict.keys {
            let jc: JanusConnection? = peerConnectionDict[key] as? JanusConnection
            if peerConnection == jc?.connection {
                handleId = jc?.handleId
                break
            }
        }
        
        if candidate != nil {
            websocket?.trickleCandidate(handleId, candidate: candidate)
        } else {
            websocket?.trickleCandidateComplete(handleId)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("=========didRemoveIceCandidates")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("=========didOpen======\(dataChannel)")
    }
}

extension ConferenceView: WebSocketDelegateJanus {
    func onCreatedRoom(_ handleId: NSNumber?) {
        if let delegate = delegate {
            delegate.joinedRoom()
        }
    }
    
    func onPublisherJoined(_ handleId: NSNumber?) {
        offerPeerConnection(handleId)
    }
    
    func onPublisherRemoteJsep(_ handleId: NSNumber!, dict jsep: [AnyHashable : Any]!) {
        guard let handleId = handleId,
              let jc = peerConnectionDict[handleId] as? JanusConnection,
              let answerDescription = RTCSessionDescription(fromJSONDictionary: jsep) else { return }
        jc.connection.setRemoteDescription(answerDescription, completionHandler: { error in })
    }
    
    func subscriberHandleRemoteJsep(_ handleId: NSNumber!, dict jsep: [AnyHashable : Any]!) {
        guard let handleId = handleId, let jsep = jsep else { return }
        let peerConnection: RTCPeerConnection? = createPeerConnection()
        let jc = JanusConnection()
        jc.connection = peerConnection
        jc.handleId = handleId
        peerConnectionDict[handleId] = jc
        
        guard let answerDescription = RTCSessionDescription(fromJSONDictionary: jsep) else { return }
        peerConnection?.setRemoteDescription(answerDescription, completionHandler: { error in })
        let mandatoryConstraints = ["OfferToReceiveAudio": "true",
                                    "OfferToReceiveVideo": "true"]
        
        let constraints = RTCMediaConstraints(mandatoryConstraints: mandatoryConstraints, optionalConstraints: nil)
        
        peerConnection?.answer(for: constraints, completionHandler: { [weak self] sdp, error in
            guard let self = self, let sdp = sdp else { return }
            peerConnection?.setLocalDescription(sdp, completionHandler: { error in })
            self.websocket?.subscriberCreateAnswer(handleId, sdp: sdp)
        })
    }
    
    
    
    func onLeaving(_ handleId: NSNumber?) {
        
        for key in peerConnectionDict.keys {
            if let jc = peerConnectionDict[key] as? JanusConnection, jc.connection != nil {
                jc.connection.close()
                if callType == .Video {
                    var videoTrack: RTCVideoTrack? = jc.videoTrack
                    videoTrack?.remove((jc.videoView)!)
                    
                    videoTrack = nil
                    jc.videoTrack = nil
                    if let delegate = delegate,
                       let index = self.videoViews.firstIndex(where: { $0 == jc.videoView }) {
                        self.videoViews.remove(at: index)
                        delegate.getTheStreamData(views: self.videoViews)
                    }
                }
                self.stopConnection()
                self.delegate.disConnectTheCall()
                peerConnectionDict.removeValue(forKey: key)
                UserDefaults.standard.set(false, forKey: "iscallgoingOn")
                UserDefaults.standard.synchronize()
                self.websocket?.delegate = nil
                localView = nil
                self.websocket = nil
                roomId = nil
                localTrack = nil
                localAudioTrack = nil
                callType = .none
            }
        }
        
        if didLeaveTheCall != nil{
            didLeaveTheCall!()
        }
    }
    
    
}
    
    
    
    extension AVCaptureDevice {
        func availableFormatsFor(preferredFps: Float64) -> [AVCaptureDevice.Format] {
            var availableFormats: [AVCaptureDevice.Format] = []
            for format in formats
            {
                let ranges = format.videoSupportedFrameRateRanges
                for range in ranges where range.minFrameRate <= preferredFps && preferredFps <= range.maxFrameRate
                {
                    availableFormats.append(format)
                }
            }
            return availableFormats
        }
    }
