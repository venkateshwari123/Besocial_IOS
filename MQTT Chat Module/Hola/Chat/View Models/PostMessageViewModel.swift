//
//  PostMessageViewModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 05/12/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import UICircularProgressRing

class PostMessageViewModel: NSObject {
    
    /// Message Instance for storing image Object.
    let message : Message
    
    /// Flag for maintaining the image status.
    var mediaState:MediaStates {
        return self.message.mediaStates
    }
    
    /// Current image message type, It can be image, gif, doodle, sticker.
    var msgType : String!
    var isGroup:Bool = false
    var groupMembers:[[String:Any]]?
    var gpImage:String?
    
    /// Initiaizing the message object with the Message object.
    ///
    /// - Parameter message: Message Object
    init(withMessage message: Message) {
        self.message = message
    }
    
    /// This will create image object, with passed image.
    ///
    /// - Parameter image: Image you want to send to the receiver.
    fileprivate func CreatePostMessageObject(withImage image : UIImage, replyingMsg : Message?, isReplyingMessage : Bool?) {
        let userDocVMObject = UsersDocumentViewModel(couchbase: Couchbase.sharedInstance)
        // fetching user data from user doc.
        guard let userData = userDocVMObject.getUserData() else { return }
        
        /// Creating data from image.
        let imgData: NSData = NSData(data: (image).jpegData(compressionQuality: 0.2)!)
        
        /// Fetching image size.
        let imageSize = imgData.length
        var params = [String :Any]()
        params["from"] = self.message.messageFromID! as Any
        params["to"] = self.message.messageToID! as Any
        params["payload"] = self.message.mediaURL! as Any
        params["toDocId"] = self.message.messageDocId! as Any
        params["timestamp"] = self.message.timeStamp! as Any
        params["id"] = self.message.timeStamp! as Any
        params["type"] = msgType as Any
        params["thumbnail"] = self.message.thumbnailData! as Any
        params["dataSize"] = imageSize as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["userName"]! as Any
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        
        params["postId"] = self.message.postId
        params["postTitle"] = self.message.postTitle
        params["postType"] = self.message.postType
        //Sending image to receiver.
        
        
        if  self.message.secretID  != "" {
            params["secretId"] = self.message.secretID!
        }
        
        if  self.message.dTime != 0 {
            params["dTime"] = self.message.dTime
        }
        
        
        
        if isReplyingMessage == true, let replyMsg = replyingMsg {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = replyMsg.messageType {
                params["previousPayload"] = pPload as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = msgType as Any
                params["type"] = "10" as Any
                params["previousReceiverIdentifier"] = prIdentifier as Any
                params["previousId"] = msgId as Any
              //  params["previousType"] = "\(previousType.hashValue)" as Any
                params["previousType"] = settingPreviousTypeParams(messageType: previousType)
                if previousType == .replied {
                    if let pType = replyMsg.repliedMessage?.replyMessageType {
                     //   params["previousType"] = "\(pType.hashValue)" as Any
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
        self.sendPostToReceiver(withData: params)
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
    fileprivate func sendPostToReceiver(withData data: [String :Any]) {
        //self.
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
    fileprivate func updateMediaStates(forMessage messageObj : Message, andDocID docID: String) {
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: Couchbase.sharedInstance)
        chatsDocVMObject.updateMediaStatesForMessage(inChatDocID: docID, withMessage: messageObj)
    }
    
    /// Upload image to server and send the message to the receiver.
    ///
    /// - Parameters:
    ///   - uploadingBlock: Will return the message object with uploading states.
    ///   - completionBlock: Will return the message object with complete media states.
    func uploadImage(withChatDocID chatDocId: String, replyingMsg: Message?, isReplyingMessage: Bool?, progress : @escaping (Progress) -> Void, Uploadcompletion : @escaping(Bool) -> Void ) {
        let msgCopy = self.message
        switch msgCopy.mediaStates! {
        case .uploaded:
            break
        case .downloaded:
            break
        case .uploading :
            break
        case .downloading :
            break
        case .uploadCancelledBeforeStarting:
            break
            
        default:
            var existingImage : UIImage!
            self.getPost { (image) in
                existingImage = image
                // Uplaoding started Show in the message.
                let msgCopy = self.message
                msgCopy.mediaStates = .uploading
                // After getting image from cache, changing the message status and starting upload.
                self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
                self.uploadImage(existingImage, progress: progress, completion: { (url) in
                    // Upload image to database message.
                    if let imgURl = url {
                        let msgCopy = self.message
                        msgCopy.mediaURL = imgURl.toBase64()
                        msgCopy.mediaStates = .uploaded
                        self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
                        // Send image message to the receiver.
                        self.CreatePostMessageObject(withImage: existingImage, replyingMsg: replyingMsg, isReplyingMessage: isReplyingMessage)
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
    }
    
    /// Used for Uploading the image to server
    ///
    /// - Parameters:
    ///   - image: Image you want to update it again.
    ///   - completion: If succeeded then will contain URL or nil.
    private func uploadImage(_ image: UIImage, progress : @escaping (Progress) -> Void, completion: @escaping (String?) -> Void) {
        let name  = arc4random_uniform(900000) + 100000
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        AFWrapper.updloadPhoto(withPhoto: image, andName: "\(name)\(timeStamp)", progress: progress, success: { (response) in
            let fileName = "\(name)\(timeStamp).jpeg"
            let url = "\(AppConstants.uploadImageURLExtension)/\(fileName)"
            completion(url)
        }, failure: { (error) in
            completion(nil)
        })
    }
    
    /// Used for re-uploading the image to server
    ///
    /// - Parameters:
    ///   - image: Image you want to update it again.
    ///   - completion: If succeeded then it will contain URL or nil.
    func retryUploadingimage(withProgress progress: @escaping (Progress) -> Void, completion: @escaping (String?) -> Void) {
        self.getPost { (img) in
            if let image = img {
                self.uploadImage(image, progress: progress, completion: completion)
            }
        }
    }
    
    func getRepliedPost(withCompletion completion: @escaping (UIImage?) -> Void) {
        guard let uniqueID = self.message.repliedMessage?.previousId else { return }
        var imageName = "Do_Chat"+"\(uniqueID)"+".jpg"
        if self.message.messageType == .gif || self.message.messageType == .sticker {
            imageName = "Do_Chat"+"\(uniqueID)"+".gif"
        }
        if self.message.messageType == .replied {
            if let repliedMsg = self.message.repliedMessage {
                if repliedMsg.replyMessageType == .gif || repliedMsg.replyMessageType == .sticker {
                    imageName = "Do_Chat"+"\(uniqueID)"+".gif"
                }
            }
        }
        
        if ImageCache.default.imageCachedType(forKey: imageName).cached {
            ImageCache.default.retrieveImage(forKey: imageName, options: nil, completionHandler: { image, _ in
                completion(image)
            })
        } else {
            completion(nil)
        }
    }
    
    func getPost(withCompletion completion: @escaping (UIImage?) -> Void) {
        guard let uniqueID = self.message.uniquemessageId else { return }
        var imageName = "Do_Chat"+"\(uniqueID)"+".jpg"
        if self.message.messageType == .gif || self.message.messageType == .sticker {
            imageName = "Do_Chat"+"\(uniqueID)"+".gif"
        }
        if self.message.messageType == .replied {
            if let repliedMsg = self.message.repliedMessage {
                if repliedMsg.replyMessageType == .gif || repliedMsg.replyMessageType == .sticker {
                    imageName = "Do_Chat"+"\(uniqueID)"+".gif"
                }
            }
        }
        
        if ImageCache.default.imageCachedType(forKey: imageName).cached {
            ImageCache.default.retrieveImage(forKey: imageName, options: nil, completionHandler: { image, _ in
                completion(image)
            })
        } else {
            completion(nil)
        }
    }
}
