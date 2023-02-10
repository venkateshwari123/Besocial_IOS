//
//  WebRTCClient.swift
//  AntMediaSDK
//
//  Created by Oğulcan on 18/05/2018.
//  Copyright © 2018 AntMedia. All rights reserved.
//

import Foundation
import AVFoundation
import Starscream
import WebRTC

let TAG: String = "AntMedia_iOS: "

public enum AntMediaClientMode: Int {
    case join = 1
    case play = 2
    case publish = 3
    
    func getLeaveMessage() -> String {
        switch self {
            case .join:
                return "leave"
            case .publish, .play:
                return "stop"
        }
    }
    
    func getName() -> String {
        switch self {
            case .join:
                return "join"
            case .play:
                return "play"
            case .publish:
                return "publish"
        }
    }
}

open class AntMediaClient: NSObject {
    
    internal static var isDebug: Bool = false
    public var delegate: AntMediaClientDelegate!

    private var wsUrl: String!
    private var streamId: String!
    private var token: String!
    private var webSocket: WebSocket!
    private var mode: AntMediaClientMode!
    private var signalling: AntMediaSignalling?
    private var webRTCClient: WebRTCClient?
    private var localView: RTCVideoRenderer?
    private var remoteView: RTCVideoRenderer?
    
    private var videoContentMode: UIView.ContentMode?
    
    private let audioQueue = DispatchQueue(label: "audio")
    
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    
    private var localContainerBounds: CGRect?
    private var remoteContainerBounds: CGRect?
    
    private var cameraPosition: AVCaptureDevice.Position = .front
    
    private var targetWidth: Int = 1080
    private var targetHeight: Int = 1920
    
    public override init() {
        
     }
    
    public func setOptions(url: String, streamId: String, token: String = "", mode: AntMediaClientMode = .join) {
        self.wsUrl = url
        self.streamId = streamId
        self.token = token
        self.mode = mode
        
        if (token.isEmpty) {
            self.signalling = AntMediaSignalling(mode: mode, stream: streamId)
        } else {
            self.signalling = AntMediaSignalling(mode: mode, stream: streamId, token: token)
        }
    }
    
    // Force speaker
    public func speakerOn() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                AntMediaClient.printf("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    public func configureAudioSession() {
       
        if self.mode == .play  //if play mode change the mode
        {
            let webRTCConfiguration = RTCAudioSessionConfiguration.init()
           webRTCConfiguration.mode = AVAudioSession.Mode.default.rawValue
            webRTCConfiguration.categoryOptions = [.mixWithOthers, .duckOthers, .defaultToSpeaker]
            
            RTCAudioSessionConfiguration.setWebRTC(webRTCConfiguration)
            
        }
        debugPrint("ConfigureAudioSession")
        
        self.audioQueue.sync { [weak self] in
            guard let self = self else {
                 debugPrint("returning ConfigureAudioSession")
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            
            do {
                 let configuration = RTCAudioSessionConfiguration.init()
               
            configuration.mode = AVAudioSession.Mode.default.rawValue
            configuration.categoryOptions = [.mixWithOthers, .duckOthers, .defaultToSpeaker]
                
                if (self.rtcAudioSession.isActive) {
                    try self.rtcAudioSession.setConfiguration(configuration)
                }
                else {
                    try self.rtcAudioSession.setConfiguration(configuration, active:true)
                }
            }
            catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            
            self.rtcAudioSession.unlockForConfiguration()
        }
        
       
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    public func speakerOff() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }

    /*
     Connect to websocket
     */
    open func connectWebSocket() {
        AntMediaClient.printf("Will connect to: \(self.getWsUrl())")
        webSocket = WebSocket(request: self.getRequest())
        webSocket.delegate = self
        webSocket.connect()
    }
    
    open func setCameraPosition(position: AVCaptureDevice.Position) {
        self.cameraPosition = position
    }
    
    open func setTargetResolution(width: Int, height: Int) {
        self.targetWidth = width
        self.targetHeight = height
    }
    
    /*
     Stops everything,
     Disconnects from websocket and
     stop webrtc
     */
    open func stop() {
        if (self.webSocket!.isConnected) {
            let jsonString = self.signalling!.getLeaveMessage().json
            webSocket?.write(string: jsonString)
        }
        /*
         Bug Name:- The mike record button on the top is being displayed even after the live stream is ended
         Fix Date:- 21/06/2021
         Fixed By:- Jayaram G
         Description of Fix:- Disabling audio configuration
         */
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.rtcAudioSession.isAudioEnabled = false
            self.rtcAudioSession.lockForConfiguration()
            do {
                
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
                try self.rtcAudioSession.setActive(false)
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            } catch let error {
                AntMediaClient.printf("Couldn't force audio to speaker: \(error)")
            }
        }
        
        self.webSocket?.disconnect()
       // self.webRTCClient?.disconnect()
    }
    
    open func start() {
         configureAudioSession()
        AntMediaClient.printf("Has wsClient? (start) : \(String(describing: self.webRTCClient))")
        self.webRTCClient = WebRTCClient.init(remoteVideoView: remoteView, localVideoView: localView, delegate: self, mode: self.mode, cameraPosition: self.cameraPosition, targetWidth: self.targetWidth, targetHeight: self.targetHeight)
        self.webRTCClient!.setStreamId(streamId)
        self.webRTCClient!.setToken(self.token)
        self.onConnection()
    }
    
    /*
     * Set video scale mode
     * It's effective in arm architecture.
     */
    open func setScaleMode(mode: UIView.ContentMode) {
        self.videoContentMode = mode
    }
    
    open func setLocalView( container: UIView) {
       
//        #if arch(arm64)
//        let localRenderer = RTCMTLVideoView(frame: container.frame)
//        localRenderer.contentMode =  self.videoContentMode ?? .scaleAspectFill
//        #else
        let localRenderer = RTCEAGLVideoView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

        localRenderer.delegate = self
//        #endif
 
        localRenderer.frame = container.bounds
        
        self.localView = localRenderer
        
        self.localContainerBounds = container.bounds
        
        container.addSubview(self.localView! as! UIView)
    }
    
    open func setRemoteView(remoteContainer: UIView) {
       
//        #if arch(arm64)
//        let remoteRenderer = RTCMTLVideoView(frame: remoteContainer.frame)
//        remoteRenderer.contentMode = self.videoContentMode ?? .scaleAspectFill
//       #else
        let remoteRenderer = RTCEAGLVideoView(frame: UIScreen.main.bounds)
        remoteRenderer.delegate = self
        remoteRenderer.contentMode = .scaleAspectFill
//        #endif
        
        remoteRenderer.frame = remoteContainer.bounds
        
        self.remoteView = remoteRenderer
        self.remoteContainerBounds = remoteContainer.bounds
        
        remoteContainer.addSubview(self.remoteView! as! UIView)
    }
    
    open func isConnected() -> Bool {
        return self.webSocket?.isConnected ?? false
    }
    
    open func setDebug(_ value: Bool) {
        AntMediaClient.isDebug = value
    }
    
    open func toggleAudio() {
        self.webRTCClient?.toggleAudioEnabled()
    }
    
    open func toggleVideo() {
        self.webRTCClient?.toggleVideoEnabled()
    }
    
    open func getCurrentMode() -> AntMediaClientMode {
        return self.mode
    }
    
    open func getWsUrl() -> String {
        //return "ws://" + wsUrl + ":5080/WebRTCAppEE/websocket"
        if wsUrl.contains("wss") {
            return wsUrl + ":5443/WebRTCAppEE/websocket"
        } else {
            return wsUrl + ":5080/WebRTCAppEE/websocket"
        }
    }
    
    private func onConnection() {
        if (self.webSocket!.isConnected) {
            let jsonString = self.signalling!.getHandshakeMessage().json
            webSocket!.write(string: jsonString)
        }
    }
    
    private func onJoined() {

    }
    
    
    private func onTakeConfiguration(message: [String: Any]) {
        var rtcSessionDesc: RTCSessionDescription
        let type = message["type"] as! String
        let sdp = message["sdp"] as! String
        
        if type == "offer" {
            rtcSessionDesc = RTCSessionDescription.init(type: RTCSdpType.offer, sdp: sdp)
            self.webRTCClient?.setRemoteDescription(rtcSessionDesc)
            self.webRTCClient?.sendAnswer()
        } else if type == "answer" {
            rtcSessionDesc = RTCSessionDescription.init(type: RTCSdpType.answer, sdp: sdp)
            self.webRTCClient?.setRemoteDescription(rtcSessionDesc)
        }
    }
    
    private func onTakeCandidate(message: [String: Any]) {
        let mid = message["id"] as! String
        let index = message["label"] as! Int
        let sdp = message["candidate"] as! String
        let candidate: RTCIceCandidate = RTCIceCandidate.init(sdp: sdp, sdpMLineIndex: Int32(index), sdpMid: mid)
        self.webRTCClient?.addCandidate(candidate)
    }
    
    private func onMessage(_ msg: String) {
        if let message = msg.toJSON() {
            guard let command = message["command"] as? String else {
                return
            }
            self.onCommand(command, message: message)
        } else {
            print("WebSocket message JSON parsing error: " + msg)
        }
    }
    
    private func onCommand(_ command: String, message: [String: Any]) {
        AntMediaClient.printf("Command: " + command)
        switch command {
            case "start":
                self.webRTCClient?.createOffer()
                break
            case "stop":
                self.webRTCClient?.stop()
                self.delegate.remoteStreamRemoved()
                break
            case "takeConfiguration":
                self.onTakeConfiguration(message: message)
                break
            case "takeCandidate":
                self.onTakeCandidate(message: message)
                break
            case "notification":
                guard let definition = message["definition"] as? String else {
                    return
                }
                
                if definition == "joined" {
                    AntMediaClient.printf("Joined: Let's go")
                    self.onJoined()
                    self.speakerOn()
                }
                else if definition == "play_started" {
                    AntMediaClient.printf("Play started: Let's go")
                    self.delegate.playStarted()
                    self.speakerOn()
                }
                else if definition == "play_finished" {
                    AntMediaClient.printf("Playing has finished")
                    self.delegate.playFinished()
                }
                else if definition == "publish_started" {
                    AntMediaClient.printf("Publish started: Let's go")
                    self.delegate.publishStarted()
                }
                else if definition == "publish_finished" {
                    AntMediaClient.printf("Play finished: Let's close")
                    self.delegate.publishFinished()
                }
                break
            case "error":
                guard let definition = message["definition"] as? String else {
                    self.delegate.clientHasError("An error occured, please try again")
                    return
                }
                
                self.delegate.clientHasError(AntMediaError.localized(definition))
                break
            default:
                break
        }
    }
    
    private func getRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: self.getWsUrl())!)
        request.timeoutInterval = 5
        return request
    }
    
    static func printf(_ msg: String) {
        if (AntMediaClient.isDebug) {
            debugPrint("--> AntMediaSDK: " + msg)
        }
    }
}

extension AntMediaClient: WebRTCClientDelegate {

    public func sendMessage(_ message: [String : Any]) {
        self.webSocket?.write(string: message.json)
    }
    
    public func addLocalStream() {
        self.delegate.localStreamStarted()
    }
    
    public func addRemoteStream() {
        self.delegate.remoteStreamStarted()
    }
    
    public func connectionStateChanged(newState: RTCIceConnectionState) {
        if newState == RTCIceConnectionState.closed ||
            newState == RTCIceConnectionState.disconnected ||
            newState == RTCIceConnectionState.failed
        {
            if self.delegate != nil {
                self.delegate.disconnected();
            }
            
            if let del = self.delegate{
                del.disconnected();
                }
            self.stop()
        }
    }
    
}

extension AntMediaClient: WebSocketDelegate {
    
    public func websocketDidConnect(socket: WebSocketClient) {
        AntMediaClient.printf("WebSocketDelegate->Connected: \(socket.isConnected)")
        DispatchQueue.main.async {
            self.delegate?.clientDidConnect(self)
        }
        
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        AntMediaClient.printf("WebSocketDelegate->Disconnected")
        if let e = error as? WSError {
            self.delegate?.clientDidDisconnect(e.message)
        } else if let e = error {
            self.delegate?.clientDidDisconnect(e.localizedDescription)
        } else {
            self.delegate?.clientDidDisconnect("Disconnected")
        }
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        AntMediaClient.printf("Receive Message: \(text)")
        self.onMessage(text)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        //AntMediaClient.printf("Receive Data: " + String(data: data, encoding: .utf8)!)
    }
}

extension AntMediaClient: RTCEAGLVideoViewDelegate {
    
    private func resizeVideoFrame(bounds: CGRect, size: CGSize, videoView: UIView) {
        let ratio = size.height / size.width
        let frame = CGRect.init(x: 0, y: 0, width: bounds.height/ratio, height: bounds.height)
        videoView.bounds = frame

    }
    
    public func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
        AntMediaClient.printf("Video size changed to " + String(Int(size.width)) + "x" + String(Int(size.height)))
         
         var bounds: CGRect?
         if videoView.isEqual(localView)
         {
             bounds = self.localContainerBounds ?? nil
         }
         else if videoView.isEqual(remoteView)
         {
             bounds = self.remoteContainerBounds ?? nil
         }
        
         if (bounds != nil)
         {
             resizeVideoFrame(bounds: bounds!, size: size, videoView: (videoView as? UIView)!)
         }
         
    }
    
    public func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        
        var bounds: CGRect?
         if videoView.isEqual(localView)
         {
             bounds = self.localContainerBounds ?? nil
         }
         else if videoView.isEqual(remoteView)
         {
             bounds = self.remoteContainerBounds ?? nil
         }
        
         if (bounds != nil)
         {
             resizeVideoFrame(bounds: bounds!, size: size, videoView: (videoView as? UIView)!)
         }
        
    }
}
