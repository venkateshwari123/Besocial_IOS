//
//  VideoMessageViewModal.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 20/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import AVKit

class VideoMessageViewModal: NSObject {
    
    /// Message Instance for storing video Object.
    let message : Message
    var isGroup:Bool = false
    var groupMembers:[[String:Any]]?
    var gpImage:String?
    var groupName:String?
    /// Flag for maintaining the video status.
    var mediaState:MediaStates {
        return self.message.mediaStates
    }
    
    /// Initiaizing the message object with the Message object.
    ///
    /// - Parameter message: Message Object
    init(withMessage message: Message) {
        self.message = message
    }
    
    /// Have to add the video cache check here.
    func getVideo(withChatDocID chatDocID : String, Completion completion: @escaping (UIImage?, NSURL?) -> Void) {
        guard let uniqueID = self.message.uniquemessageId else { return }
        let videoName = "Do_Chat"+"\(uniqueID)"+".mp4"
        if let videoPath = self.fetchExistingVideo(withURL: videoName, andChatDocID: chatDocID, completion: completion) {
            let thumbnailImage = self.thumbnail(sourceURL: videoPath as URL)
            completion(thumbnailImage,videoPath as NSURL)
        } else {
            completion(nil,nil)
        }
    }
    
    private func thumbnail(sourceURL:URL) -> UIImage {
        let asset = AVAsset(url: sourceURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 2, preferredTimescale: 1)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return #imageLiteral(resourceName: "play")
        }
    }
    
    
    func deleteVideo() {
        // Have to delete locally
        // Have to delete data from cache also.
    }
    
    func fetchExistingVideo(withURL urlString: String, andChatDocID chatDocID : String, completion : @escaping (UIImage?, NSURL?) -> Void) -> URL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName = urlString as NSString
        let filePath = NSURL(fileURLWithPath:"\(documentsPath)/\(fileName.lastPathComponent)")
        let fileExists = FileManager.default.fileExists(atPath: filePath.path!)
        let videoURL = filePath
        if(fileExists) {
            // File is already downloaded
            print("Video Already Exist")
            return videoURL as URL
        } else {
            self.downloadVideo(withChatDocID: chatDocID, progress: {_ in }, completion: {(image) in
                completion(image, videoURL as NSURL)
            })
        }
        return nil
    }
    
    func createVideo(fromData data : Data, withVideoName videoName : String) -> NSURL? {
        let filePath = self.documentsPathForFileName(name: videoName)
        let videoAsData = NSData()
        if videoAsData.write(toFile: filePath, atomically:true) {
            return NSURL(fileURLWithPath: filePath)
        } else {
            return nil
        }
    }
    func documentsPathForFileName(name: String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsPath.appending(name)
    }
    
    /// Upload video to server and send the message to the receiver.
    ///
    /// - Parameters:
    ///   - uploadingBlock: Will return the message object with uploading states.
    ///   - completionBlock: Will return the message object with complete media states.
    func uploadVideos(withChatDocID chatDocId: String, isReplying : Bool?, replyMsg : Message?, progress : @escaping (Progress) -> Void, Uploadcompletion : @escaping(Bool) -> Void) {
        var existingVideo : NSURL!
        self.getVideo(withChatDocID: chatDocId, Completion: {(img, vid) in
            if let video = vid {
                existingVideo = video
                // Uplaoding started Show in the message.
                let msgCopy = self.message
                msgCopy.mediaStates = .uploading
                // After getting video from cache, changing the message status and starting upload.
                self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
                self.uploadVideo(existingVideo, progress: progress, completion: { (url) in
                    // Upload video to database message.
                    if let videoURL = url {
                        let msgCopy = self.message
                        do {
                            let videoName = "Do_Chat"+self.message.timeStamp!+".mp4"
                            let videoData = try Data(contentsOf: existingVideo as URL)
                            let SavedvideoURL = MediaDownloader().SaveMedia(withURL: videoName, andData: videoData)
                            if let vidLocalurl = SavedvideoURL?.absoluteString {
                                msgCopy.mediaURL = vidLocalurl
                                msgCopy.messagePayload = videoURL
                                msgCopy.mediaStates = .uploaded
                                self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
                                // Send video message to the receiver.
                                self.createVideoMessageObject(withVideo: videoURL, isReplying: isReplying, replyMsg: replyMsg)
                                Uploadcompletion(true)
                            }
                        } catch let error {
                            print(error.localizedDescription, "Error on creating data from URL")
                            let msgCopy = self.message
                            msgCopy.mediaStates = .notUploaded
                            self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
                            Uploadcompletion(false)
                        }
                    } else {
                        let msgCopy = self.message
                        msgCopy.mediaStates = .notUploaded
                        self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocId)
                        Uploadcompletion(false)
                    }
                })
            }
        })
    }
    
    /// This will create video object, with passed video.
    ///
    /// - Parameter video: Video you want to send to the receiver.
    fileprivate func createVideoMessageObject(withVideo video : String, isReplying : Bool?, replyMsg : Message?) {
        let userDocVMObject = UsersDocumentViewModel(couchbase: Couchbase.sharedInstance)
        // fetching user data from user doc.
        guard let userData = userDocVMObject.getUserData() else { return }
        /// Fetching video size.
        guard let videoSize = self.getVideoSize(withURL: NSURL(string :self.message.mediaURL!)!) else { return }
        var params = [String :Any]()
        params["from"] = self.message.messageFromID! as Any
        params["to"] = self.message.messageToID! as Any
        params["payload"] = video.toBase64() as Any
        params["toDocId"] = self.message.messageDocId! as Any
        params["timestamp"] = self.message.timeStamp! as Any
        params["id"] = self.message.timeStamp! as Any
        params["type"] = "2" as Any
        params["thumbnail"] = self.message.thumbnailData! as Any
        params["dataSize"] = videoSize as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["publicName"]! as Any
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        //Sending video to receiver.
        
        if self.isGroup {
            params["name"] = groupName
            params["userImage"] = gpImage
         }
        
        if  self.message.secretID  != "" {
            params["secretId"] = self.message.secretID!
            params["dTime"] = self.message.dTime
        }
        
        if  self.message.dTime != 0 {
            params["dTime"] = self.message.dTime
        }
        
        
        if isReplying == true, let replyMsg = replyMsg {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = replyMsg.messageType {
                params["previousPayload"] = pPload as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = "2" as Any
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
        self.sendVideoToReceiver(withData: params)
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
    
    /// Used for Uploading the video to server
    ///
    /// - Parameters:
    ///   - video: video you want to update it again.
    ///   - completion: If succeeded then will contain URL or nil.
    private func uploadVideo(_ video: NSURL, progress : @escaping (Progress) -> Void, completion: @escaping (String?) -> Void) {
        let name  = arc4random_uniform(900000) + 100000
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        AFWrapper.updload(withMedia: video, andName: "\(name)\(timeStamp)",withExtension:".mp4", progress: progress, success: {
            (mediaName) in
            let fileName = mediaName
            let url = "\(AppConstants.videoExtension)/\(fileName)"
            completion(url)
        }, failure: { (error) in
            completion(nil)
        })
    }
    
    fileprivate func getVideoSize(withURL resourceURL: NSURL) -> UInt64? {
        let asset = AVURLAsset(url: resourceURL as URL)
        print(asset.fileSize ?? 0)
        return UInt64(asset.fileSize!)
    }
    
    /// Send message to receiver.
    ///
    /// - Parameter data: Contains all the details of the message.
    fileprivate func sendVideoToReceiver(withData data: [String :Any]) {
        
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
    
    /// Used for re-uploading the video to server
    ///
    /// - Parameters:
    ///   - video: Video you want to update it again.
    ///   - completion: If succeeded then it will contain URL or nil.
    func retryUploadingVideo(withChatDocID chatDocId:String, andProgress progress: @escaping (Progress) -> Void, completion: @escaping (String?) -> Void) {
        self.getVideo(withChatDocID: chatDocId, Completion:{ (img, url) in
            if let videoUrl = url {
                self.uploadVideo(videoUrl, progress: progress, completion: completion)
            }
        })
    }
}


// MARK: - Downloading Video
extension VideoMessageViewModal {
    func downloadVideo(withChatDocID chatDocID : String, progress : @escaping (Progress) -> Void, completion : @escaping (UIImage) -> Void) {
        if wifiCheck() {
            if let thumbnailData = self.message.thumbnailData, let videoURL = message.messagePayload {
                DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    let tData = thumbnailData.replace(target: "\n", withString: "")
                    if let tImage = Image.convertBase64ToImage(base64String: tData) {
                        switch strongSelf.mediaState {
                        case .downloaded:
                            break
                        case .downloading:
                            break
                        case .downloadCancelledBeforeStarting:
                            break
                            
                        default :
                            if URL(string : videoURL) != nil {
                                strongSelf.downloadVideo(fromURL: URL(string : videoURL)!, withChatDocID: chatDocID, progress: progress)
                            }
                            
                        }
                        completion(tImage)
                    }
                }
            }
        }
    }
    
    private func downloadVideo(fromURL videoURL: URL, withChatDocID chatDocID : String, progress : @escaping (Progress) -> Void) {
        let msgCopy = self.message
        msgCopy.mediaStates = .downloading
        // After getting video from cache, changing the message status and starting upload.
        self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocID)
        let videoFetcher = VideoFetcher()
        let name  = arc4random_uniform(900000) + 100000
        let mediaName = "\(msgCopy.messageId)000\(name).mp4"
        
        videoFetcher.downloadAndSave(videoUrl: videoURL, fileName: mediaName, progress: progress, completionBlock: { (videoUrl) in
            let msgCopy = self.message
            msgCopy.mediaStates = .downloaded
            msgCopy.mediaURL = videoUrl?.absoluteString
            // After getting video from cache, changing the message status and starting upload.
            self.updateMediaStates(forMessage: msgCopy, andDocID: chatDocID)
        })
    }
    
    func wifiCheck() -> Bool{
        //Check current reachablity status
        //check network status given by user in Setting ..default is both
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let status = appdelegate.reachability.connection //Wifi or cell network
        guard let value = UserDefaults.standard.object(forKey: "Photos") as? Int else { return true }
        
        if value == 0 { // Never - 0
            return false
        }
        else if value == 1 { // WIFI - 1
            if status ==  .wifi {
                return true
            } else { return false }
        }
        else if value == 2 { // WIFI and Cell - 2
            if status == .none {
                return false
            } else {
                return true
            }
        }
        return false
    }
}
