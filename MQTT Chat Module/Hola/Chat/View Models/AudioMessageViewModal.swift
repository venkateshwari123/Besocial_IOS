//
//  AudioMessageViewModal.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 23/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import AVKit

class AudioMessageViewModal: NSObject {
    
    /// Message Instance for storing audio Object.
    let message : Message
    
    /// Flag for maintaining the audio status.
    var mediaState:MediaStates {
        return self.message.mediaStates
    }
    
    /// tells that user is replying for a message.
    var isReplying : Bool?
    var isGroup:Bool = false
    var groupMembers:[[String:Any]]?
    var gpImage:String?
    
    /// If isReplying == true then this will be the message you are going to reply.
    var replyMsg : Message?
    
    var currentIndexPath : IndexPath!
    
    var chatDocID : String! {
        didSet {
            if message.isSelfMessage {
                switch message.mediaStates! {
                case .notUploaded:
                    self.uploadAudio()
                case .notApplicable:
                    self.uploadAudio()
                default:
                    break
                }
            }
        }
    }
    
    func uploadAudio() {
        self.uploadAudio(withChatDocID: self.chatDocID, isReplying: isReplying, replyingMsgObj : replyMsg, progress:{_ in }, Uploadcompletion: {_ in })
    }
    
    /// Initiaizing the message object with the Message object.
    ///
    /// - Parameter message: Message Object
    init(withMessage message: Message) {
        self.message = message
    }
    
    /// Upload Audio to server and send the message to the receiver.
    ///
    /// - Parameters:
    ///   - uploadingBlock: Will return the message object with uploading states.
    ///   - completionBlock: Will return the message object with complete media states.
    func uploadAudio(withChatDocID chatDocId: String, isReplying: Bool?, replyingMsgObj : Message?, progress : @escaping (Progress) -> Void, Uploadcompletion : @escaping(Bool) -> Void) {
        var existingAudio : NSURL!
        let aud = self.message.mediaURL
        if let audio = aud {
            existingAudio = NSURL(string :audio)!
            // Uplaoding started Show in the message.
            let msgCopy = self.message
            msgCopy.mediaStates = .uploading
            // After getting audio from cache, changing the message status and starting upload.
            self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
            self.uploadAudio(existingAudio, progress: progress, completion: { (url) in
                // Upload video to database message.
                if let uploadedURL = url {
                    let msgCopy = self.message
                    msgCopy.messagePayload = uploadedURL
                    msgCopy.mediaStates = .uploaded
                    self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
                    // Send audio message to the receiver.
                    self.createAudioMessageObject(withAudio: uploadedURL, isReplying: isReplying, replyingMsgObj: replyingMsgObj)
                    Uploadcompletion(true)
                } else {
                    let msgCopy = self.message
                    msgCopy.mediaStates = .notUploaded
                    self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
                    Uploadcompletion(false)
                }
            })
        }
    }
    
    /// Used for Uploading the audio to server
    ///
    /// - Parameters:
    ///   - audio: audio you want to update it again.
    ///   - completion: If succeeded then will contain URL or nil.
    private func uploadAudio(_ audio: NSURL, progress : @escaping (Progress) -> Void, completion: @escaping (String?) -> Void) {
        let name  = arc4random_uniform(900000) + 100000
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        AFWrapper.updload(withMedia: audio, andName: "\(name)\(timeStamp)", withExtension: ".m4a", progress: progress, success:
            { (mediaName) in
                let fileName = mediaName
                let url = "\(AppConstants.uploadedAudioExtension)/\(fileName)"
                completion(url)
        }, failure: { (error) in
            completion(nil)
        })
    }
    
    /// This will create audio object, with passed audio.
    ///
    /// - Parameter audio: Audio you want to send to the receiver.
    fileprivate func createAudioMessageObject(withAudio audio : String, isReplying : Bool?, replyingMsgObj : Message?) {
        
        let userDocVMObject = UsersDocumentViewModel(couchbase: Couchbase.sharedInstance)
        
        // fetching user data from user doc.
        guard let userData = userDocVMObject.getUserData() else { return }
        
        /// Fetching video size.
        guard let audioSize = NSData(contentsOf: URL(string:(self.message.mediaURL)!)!)?.length else { return }
        var params = [String :Any]()
        params["from"] = self.message.messageFromID! as Any
        params["to"] = self.message.messageToID! as Any
        params["payload"] = audio.toBase64() as Any
        params["toDocId"] = self.message.messageDocId! as Any
        params["timestamp"] = self.message.timeStamp! as Any
        params["id"] = self.message.timeStamp! as Any
        params["type"] = "5" as Any
        params["dataSize"] = audioSize as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["publicName"]! as Any
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        //Sending video to receiver.
        
        
        if  self.message.secretID  != "" {
            params["secretId"] = self.message.secretID!
             params["dTime"] = self.message.dTime
            
        }
        
        
        
           
        
        
        if isReplying == true, let replyMsg = replyMsg {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = replyMsg.messageType {
                params["previousPayload"] = pPload as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = "5" as Any
                params["type"] = "10" as Any
                params["previousReceiverIdentifier"] = prIdentifier as Any
                params["previousId"] = msgId as Any
//                params["previousType"] = "\(previousType.hashValue)" as Any
                params["previousType"] = settingPreviousTypeParams(messageType: previousType)
                if previousType == .replied {
                    if let pType = replyMsg.repliedMessage?.replyMessageType {
//                        params["previousType"] = "\(pType.hashValue)" as Any
                        params["previousType"] = settingPreviousTypeParams(messageType: pType)
                    }
                }
                if previousType == .image || previousType == .doodle || previousType == .video {
                    if let tData = replyMsg.thumbnailData {
                        params["previousPayload"] = tData
                    }
                } else if previousType == .location {
                    params["previousPayload"] = "Location"
                }
                else if previousType == .replied {
                    if let repliedMsg = replyMsg.repliedMessage {
                        if repliedMsg.replyMessageType == .image || repliedMsg.replyMessageType == .doodle || repliedMsg.replyMessageType == .video {
                            if let tData = replyMsg.thumbnailData {
                                params["previousPayload"] = tData
                            }
                        } else if repliedMsg.replyMessageType == .location {
                            params["previousPayload"] = "Location"
                        }
                    }
                }
            }
        }
         self.sendAudioToReceiver(withData: params)
    }
    
    
    /// Checking replying message type
    /// - Parameter messageType: image, text, location , video etc
    func settingPreviousTypeParams(messageType: MessageTypes) -> String{
        switch messageType {
        case .text :
            return "0"
        case .image:
            return "1"
        case .video:
            return "2"
        case .location:
            return "3"
        case .contact:
            return "4"
        case .audio:
            return "5"
        case .sticker:
            return "6"
        case .doodle:
            return "7"
        case .gif:
            return "8"
        case .document:
            return "9"
        case .replied:
            return "10"
        case .deleted:
            return "11"
        case .post:
            return "13"
        case .transfer:
            return "15"
        case .missedCallMessage:
            return "16"
        case .callMessage:
            return "17"
        }
    }
    
    /// Send message to receiver.
    ///
    /// - Parameter data: Contains all the details of the message.
    fileprivate func sendAudioToReceiver(withData data: [String :Any]) {
        
        
        if isGroup == false{
            MQTTChatManager.sharedInstance.sendMessage(toChannel: "\(self.message.messageToID!)", withMessage: data, withQOS: .atLeastOnce)
        }else {
            
            DispatchQueue.global().async {
                
                guard let userID = Utility.getUserid() else { return }
                guard let groupMems = self.groupMembers else {return}
                var msg = data
                msg["userImage"] = self.gpImage ?? ""
                for member in  groupMems {
                    if member["memberId"] as? String   == userID{} else {
                        guard   let reciverID = member["memberId"] as? String else {return}
                        
                        MQTTChatManager.sharedInstance.sendGroupMessage(toChannel:"\(reciverID)" , withMessage: msg, withQsos: .atLeastOnce)
                    }
                }
                
                MQTTChatManager.sharedInstance.sendGroupMessageToServer(toChannel: "\(self.message.messageToID!)", withMessage: msg, withQsos: .atLeastOnce)
            }
        }
    }
    
    /// Update media state for message to the chat Document.
    ///
    /// - Parameters:
    ///   - messageObj: Modified message object.
    ///   - docID: Document ID.
    func updateMediaStates(forMessage messageObj : Message, andDocID docID: String) {
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: Couchbase.sharedInstance)
        DispatchQueue.main.async {
            chatsDocVMObject.updateMediaStatesForMessage(inChatDocID: docID, withMessage: messageObj)
        }
    }
    
    /// Used for re-uploading the Audio to server
    ///
    /// - Parameters:
    ///   - Audio: Audio you want to update it again.
    ///   - completion: If succeeded then it will contain URL or nil.
    func retryUploadingAudio(withProgress progress: @escaping (Progress) -> Void, completion: @escaping (String?) -> Void) {
            self.uploadAudio()
    }
}
