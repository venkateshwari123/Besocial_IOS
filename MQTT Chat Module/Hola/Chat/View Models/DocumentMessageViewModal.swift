//
//  DocumetnMessageViewModal.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 01/03/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import MobileCoreServices

class DocumentMessageViewModal: NSObject {
    
    /// Message Instance for storing document Object.
    let message : Message
    
    var isGroup:Bool = false
    var groupMembers:[[String:Any]]?
    var gpImage:String?
    
    /// Flag for maintaining the document status.
    var mediaState:MediaStates {
        return self.message.mediaStates
    }
    
    /// tells that user is replying for a message.
    var isReplying : Bool?
    
    /// If isReplying == true then this will be the message you are going to reply.
    var replyMsg : Message?
    
    var chatDocID : String! {
        didSet {
            if message.isSelfMessage {
                switch message.mediaStates! {
                case .notUploaded:
                    self.uploadDocument()
                default:
                    break
                }
            }
        }
    }
    
    func getFileURL() -> String? {
        if let mPload = message.messagePayload {
            return mPload
        }
        return nil
    }
    
    func getDocTypeText() -> String? {
        if let messageData = message.messageData {
            if let extensionType = messageData["extension"] as? String {
                switch extensionType {
                case "pdf":
                    return "PDF"
                    
                case "doc","docx","dot","dotx":
                    return "DOC"
                    
                case "ppt","pptx":
                    return "PPT"
                    
                case "xls","xlsx":
                    return "XLS"
                    
                case "txt":
                    return "TXT"
                    
                case "rtf":
                    return "RTF"
                    
                    
                default :
                    return extensionType
                }
            }
        }
        return nil
    }
    
    func getFileName() -> String? {
        if let messageData = message.messageData {
            return messageData["fileName"] as? String
        }
        return nil
    }
    
    func getDocTypeImage() -> UIImage {
        if let messageData = message.messageData {
            if let extensionType = messageData["extension"] as? String {
                switch extensionType {
                case "pdf":
                    return #imageLiteral(resourceName: "doc_pdf")
                    
                case "doc","docx","dot","dotx":
                    return #imageLiteral(resourceName: "doc_doc")
                    
                case "ppt","pptx":
                    return #imageLiteral(resourceName: "doc_ppt")
                    
                case "xls","xlsx":
                    return #imageLiteral(resourceName: "doc_xls")
                    
                case "txt":
                    return #imageLiteral(resourceName: "doc_txt")
                    
                case "rtf":
                    return #imageLiteral(resourceName: "doc_rtf")
                    
                default :
                    return #imageLiteral(resourceName: "doc_unknown")
                }
            }
        }
        return #imageLiteral(resourceName: "doc_unknown")
    }
    
    func uploadDocument() {
        self.uploadDocument(withChatDocID: self.chatDocID, isReplying: isReplying, replyingMsgObj: replyMsg, progress:{_ in }, Uploadcompletion: {_ in })
    }
    
    /// Initiaizing the message object with the Message object.
    ///
    /// - Parameter message: Message Object
    init(withMessage message: Message) {
        self.message = message
    }
    
    /// Upload Document to server and send the message to the receiver.
    ///
    /// - Parameters:
    ///   - uploadingBlock: Will return the message object with uploading states.
    ///   - completionBlock: Will return the message object with complete media states.
    func uploadDocument(withChatDocID chatDocId: String, isReplying: Bool?, replyingMsgObj: Message?, progress : @escaping (Progress) -> Void, Uploadcompletion : @escaping(Bool) -> Void) {
        var existingDocment : NSURL!
        let doc = self.message.mediaURL
        if let document = doc {
            existingDocment = NSURL(string :document)!
            // Uplaoding started Show in the message.
            let msgCopy = self.message
            msgCopy.mediaStates = .uploading
            // After getting document from cache, changing the message status and starting upload.
            self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
            self.uploadDocument(existingDocment, progress: progress, completion: { (url) in
                // Upload document to database message.
                if let uploadedURL = url {
                    let msgCopy = self.message
                    msgCopy.messagePayload = uploadedURL
                    msgCopy.mediaStates = .uploaded
                    self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
                    // Send document message to the receiver.
                    self.createDocumentMessageObject(withDocument: uploadedURL, isReplying: isReplying, replyingMsgObj: replyingMsgObj)
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
    
    /// Used for Uploading the document to server
    ///
    /// - Parameters:
    ///   - document: document you want to update it again.
    ///   - completion: If succeeded then will contain URL or nil.
    private func uploadDocument(_ document: NSURL, progress : @escaping (Progress) -> Void, completion: @escaping (String?) -> Void) {
        let name  = arc4random_uniform(900000) + 100000
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        AFWrapper.updload(withMedia: document, andName: "\(name)\(timeStamp)", withExtension:document.pathExtension!, progress: progress, success:
            { (mediaName) in
                let fileName = mediaName
                let url = "\(AppConstants.uploadedDocumetExtension)/\(fileName)"
                completion(url)
        }, failure: { (error) in
            completion(nil)
        })
    }
    
    /// This will create document object, with passed document.
    ///
    /// - Parameter document: document you want to send to the receiver.
    fileprivate func createDocumentMessageObject(withDocument document : String, isReplying : Bool?, replyingMsgObj : Message?) {
        
        let userDocVMObject = UsersDocumentViewModel(couchbase: Couchbase.sharedInstance)
        
        // fetching user data from user doc.
        guard let userData = userDocVMObject.getUserData() else { return }
        
        guard let docURL = URL(string:(self.message.mediaURL)!) else { return }
        /// Fetching document size.
        guard let documentSize = NSData(contentsOf: docURL)?.length else { return }
        var params = [String :Any]()
        params["from"] = self.message.messageFromID! as Any
        params["to"] = self.message.messageToID! as Any
        params["payload"] = document.toBase64() as Any
        params["toDocId"] = self.message.messageDocId! as Any
        params["timestamp"] = self.message.timeStamp! as Any
        params["id"] = self.message.timeStamp! as Any
        params["type"] = "9" as Any
        params["dataSize"] = documentSize as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["publicName"]! as Any
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        
        let fileTYpe = self.mimeTypeForPath(path: docURL.absoluteString)
        params["fileName"] = docURL.lastPathComponent
        params["mimeType"] = fileTYpe
        params["extension"] = docURL.pathExtension
        
        if  self.message.secretID  != "" {
            params["secretId"] = self.message.secretID!
        }
        
        if  self.message.dTime != 0 {
            params["dTime"] = self.message.dTime
        }
        
        if isReplying == true, let replyMsg = replyingMsgObj {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = replyMsg.messageType {
                params["previousPayload"] = pPload as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = "9" as Any
                params["type"] = "10" as Any
                params["previousReceiverIdentifier"] = prIdentifier as Any
                params["previousId"] = msgId as Any
               // params["previousType"] = "\(previousType.hashValue)" as Any
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
        
        //Sending document to receiver.
        self.sendDocumentToReceiver(withData: params)
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
    
    func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    /// Send message to receiver.
    ///
    /// - Parameter data: Contains all the details of the message.
    fileprivate func sendDocumentToReceiver(withData data: [String :Any]) {
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
    
    /// Used for re-uploading the Document to server
    ///
    /// - Parameters:
    ///   - Document: Document you want to update it again.
    ///   - completion: If succeeded then it will contain URL or nil.
    func retryUploadingDocument(withProgress progress: @escaping (Progress) -> Void, completion: @escaping (String?) -> Void) {
        self.uploadDocument()
    }
}

