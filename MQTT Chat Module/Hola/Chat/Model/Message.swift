//
//  Message.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 11/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController

/// Used for getting the type of the message.
public enum MessageTypes:Int {
    
    /// For Messages of Text type.
    case text = 0
    
    ///Message type is image
    case image = 1
    
    ///Message type is video
    case video = 2
    
    ///Message type is Location
    case location = 3
    
    ///Message type is Contact
    case contact = 4
    
    ///Message type is audio
    case audio = 5
    
    ///Message type is sticker
    case sticker = 6
    
    ///Message type is doodle
    case doodle = 7
    
    ///Message type is gif
    case gif = 8
    
    ///Message type is document
    case document = 9
    
    ///Message type is reply
    case replied = 10
    
    /// Message type when deleted
    case deleted = 11
    
    /// Message type is post
    case post = 13
    
    /// Message type is transfer money
    case transfer = 15
    
    /// Missed call message type
    case missedCallMessage = 16
    
    ///Call message type
    case callMessage = 17
    
    
}

///The code of states which Media might encountered.
public enum MediaStates: Int {
    
    /// Not applicable on this message.
    case notApplicable = 0
    
    /// badData: The Uploaded data is not an media or the data is corrupted.
    case notUploaded = 1
    
    /// Media is Uploading: The media is getting uploaded.
    case uploading = 2
    
    /// Media is Uploaded.
    case uploaded = 3
    
    /// The downloading task is cancelled before started.
    case uploadCancelledBeforeStarting = 5
    
    /// badData: The downloaded data is not an media or the data is corrupted.
    case notDownloaded = 10
    
    /// Media is downloading: The media is getting downloaded.
    case downloading = 11
    
    /// Media is Downloaded.
    case downloaded = 12
    
    /// notCached: The media is not cached, there was some error when tried to cached but not succeed.
    case notCached = 13
    
    /// The downloading task is cancelled before started.
    case downloadCancelledBeforeStarting = 14
    
    /// If media is successfully sent After uploading.
    case mediaSent = 15
}

/*
    * -------------------------------------
    *       1        |   new              |
    *       2        |   confirm          |
    *       3        |   timeout          |
    *       4        |   denied           |
    *       5        |   canceled         |
*/
public enum TransferStatus: Int{
    
    case new = 1
    case confirm = 2
    case timout = 3
    case denied = 4
    case cenceled = 5
    
    
}

class Message: JSQMessage {
    
    /// Message key Constants are added here.
    struct KeyConstants {
        static let from = "from"
        /*
         Bug Name :- show user payments in chat
         Fix Date :- 03/06/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Handled mqtt data
         */
        static let senderId = "senderId"
        static let receiverId = "receiverId"
        static let to = "to"
        static let payload = "payload"
        static let docId = "toDocId"
        static let timeStamp = "timestamp"
        static let messageType = "type"
        static let messangerName = "name"
        static let messageID = "id"
        static let msgSentDate = "sentDate"
        static let msgStatus = "deliveryStatus"
        static let readTime = "readTime"
        static let deliveryTime = "deliveryTime"
        static let isSelfMessage = "isSelf"
        static let replyType = "replyType"
        static let previousPayload = "previousPayload"
        static let userImage = "userImage"
        static let receiverIdentifier = "receiverIdentifier"
        static let previousFrom = "previousFrom"
        static let previousReceiverIdentifier = "previousReceiverIdentifier"
        static let previousId = "previousId"
        static let previousType = "previousType"
    }
    
    /// ID of the sender.
    var messageFromID : String?
    
    /// ID of the receiver.
    var messageToID : String?
    
    /// Payload of the message.
    var messagePayload : String?
    
    /// Current message type see Message.swift for more details.
    var messageType : MessageTypes?
    
    /// Contains the message media state.
    var mediaStates : MediaStates!
    
    ///Message delivery time
    var deliveryTime: Double?
    
    ///Message read time
    var readTime: Double?
    
    /// Current Chat Doc ID inside Message.
    var messageDocId : String?
    
    /// Current timestamp for the message
    var timeStamp : String?
    
    /// Current messenger name.
    var messangerName : String?
    
    /// Date of the message in the day format.
    var messageSentDate : Date?
    
    /// message delivery Status.
    var messageStatus : String?
    
    var messageIdObj:String?
    
    /// If message is self then true else false.
    var isSelfMessage : Bool!
    
    /// unique message Id
    var uniquemessageId : Int64?
    
    /// if it is Self Message
    var isMediaAvailable : Bool!
    
    /// Current chat secret ID.
    var secretID : String?
    
    /// user's receiver Identifier
    var receiverIdentifier : String?
    
    /// Message media with the media data
    var mediaURL : String?
    
    /// This will contain all the message data.
    var messageData : [String : Any]?
    
    /// If the message is replied then this will be true
    var isReplied : Bool!
    
    /// Replied message object with its property
    var repliedMessage : RepliedMessage?
    
    /// Contains message size if media then media size else 0.
    //    var messageSize : Double?
    
    /// Data for thumbnail in the format of encoded string
    var thumbnailData : String?
    
    var gpMessageType :String?
    
    var dTime:Int = 0
    
    ///Post related data
    //Id of that post which is shared
    var postId: String?
    
    //Title of that post which is shared
    var postTitle: String?
    
    //Type of post whsich is shared(0: Photo & 1: Video)
    var postType: Int = 0
    
    
    /// this value come in role if message is for payment(type 15)
    var amount: Double?
    
    /// status of transfer amount
    var transferStatus: TransferStatus?
    
    /// transfer status text
    var transferStatusText: String?
        
    var txnId:String = ""
    
    var txnNotes: String = ""
    
    var callType : Int?
    
    var callDuration:Double?
    
    
    init(withSenderID messageFromID : String, andreceiverID messageToID : String?, withPayload messagePayload : String ,messageDocId : String?, timeStamp : String? , messageType : MessageTypes?, mediaStates : MediaStates, messangerName : String, messageSentDate : Date,messageId: String, media: JSQMessageMediaData?, isMediaAvailable : Bool?, messageStatus : String, isSelfMessage : Bool, mediaURL : String?, thumbnailData : String?, secretID : String, receiverIdentifier: String?, messageData : [String : Any]?, isReplied : Bool, repliedMessage : RepliedMessage? ,gpMessageType : String? ,dTime:Int = 0, postId: String?, postTitle: String?, postType: Int, readTime: Double?, deliveryTime: Double?, amount: Double?, transferStatus: TransferStatus?, transferStatusText: String?, callType: Int?,callDuration: Double?,txnId:String,txnNotes: String) {
        
        if isMediaAvailable == true {
            super.init(senderId: messageFromID, senderDisplayName: messangerName, date: messageSentDate, media: media!, messageId: messageId)
        } else {
            super.init(senderId: messageFromID, senderDisplayName: messangerName, date: messageSentDate, text: messagePayload, messageId: messageId)
        }
        
        self.messageFromID = messageFromID
        self.messageToID = messageToID
        self.messagePayload = messagePayload
        self.messageDocId = messageDocId
        self.timeStamp = timeStamp
        self.messageType = messageType
        self.mediaStates = mediaStates
        self.messangerName = messangerName
        self.messageSentDate = messageSentDate
        self.messageIdObj = messageId
        if let uniquemessageId = timeStamp{
            self.uniquemessageId = Int64(uniquemessageId)
        }
        self.messageStatus = messageStatus
        self.isSelfMessage = isSelfMessage
        self.mediaURL = mediaURL
        self.thumbnailData = thumbnailData
        self.secretID = secretID
        self.receiverIdentifier = receiverIdentifier
        self.isReplied = isReplied
        self.repliedMessage = repliedMessage
        self.gpMessageType = gpMessageType
        self.dTime = dTime
        self.messageData = messageData
        
        self.postType = postType
        self.postTitle = postTitle
        self.postId = postId
        self.deliveryTime = deliveryTime
        self.readTime = readTime
        
        self.amount = amount
        self.transferStatus = transferStatus
        self.transferStatusText = transferStatusText
        self.txnId = txnId
        self.txnNotes = txnNotes
        self.callType = callType
        self.callDuration = callDuration

    }
    
    convenience init(forData data : [String:Any], withDocID docID : String, andMessageobj messageObj : [String:Any], isSelfMessage isSelf : Bool, mediaStates : MediaStates, mediaURL : String?, thumbnailData : String?, secretID : String?, receiverIdentifier : String?, messageData : [String : Any]?, isReplied : Bool ,gpMessageType: String?,dTime:Int = 0, readTime: Double?, deliveryTime: Double?) {
        var payload = ""
        var timeStamp = "\(DateExtension().sendTimeStamp(fromDate:Date())!)"
        var type = ""
        var isMediaAvailable : Bool = false
        var secretID = ""
        var msgStatus = "0"
        var msgData = [String : Any]()
        var messageID = ""
        var gpMessageType = ""
        var messengerName = ""
        var repliedMsg : RepliedMessage?
        var media: JSQMessageMediaData?
        var receiverIdentifier = receiverIdentifier
        /*
         Bug Name :- show user payments in chat
         Fix Date :- 03/06/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Handled mqtt data
         */
        var senderID = data[KeyConstants.from] as? String
        var receiverId = data[KeyConstants.to] as? String
        
        if let senderId = data[KeyConstants.senderId] as? String {
        senderID = senderId
        }
        if let id = data[KeyConstants.receiverId] as? String {
            receiverId = id
        }
        var dTimee = 0
        
        var postId = ""
        var postTitle = ""
        var postType: Int = 0
        
        var amount : Double?
        var transferStatus : TransferStatus?
        var transferStatusText : String?
        var txnId : String = ""
        var txnNotes: String = ""
        var callType : Int?
        var callduration:Double?
        
        if let msgDict = messageData {
            msgData = msgDict
        }
        
        
        if let mName = messageObj[KeyConstants.messangerName] as? String {
            messengerName = mName
        }
        if let msgID = data[KeyConstants.messageID] as? String {
            messageID = msgID
        } else if let  msgID = data[KeyConstants.messageID] as? Int{
            messageID = "\(msgID)"
        }
        
        if let messageStatus = data[KeyConstants.msgStatus] as? String {
            msgStatus = messageStatus
        }
        
        var isSelfMessage : Bool = isSelf
        if let isSelfMessageFlag = data[KeyConstants.isSelfMessage] as? Bool {
            isSelfMessage = isSelfMessageFlag
        }
        
        if let message = messageObj[KeyConstants.payload] as? String {
            payload = message.replace(target: "\n", withString: "")
        } else if let message = messageObj["message"] as? String {
            payload = message.replace(target: "\n", withString: "")
        }
        if payload == "" {
            payload = ""
        }
        
        if let ts = messageObj[KeyConstants.timeStamp] as? String{
            timeStamp = ts
        } else if let ts = messageObj["timestamp"] as? String {
            timeStamp = ts
        } else if let ts = messageObj[KeyConstants.timeStamp] as? Int64 {
            timeStamp = "\(ts)"
        }
        
        if let messageType = messageObj[KeyConstants.messageType] as? String {
            type = messageType
        } else if let messageType = messageObj["messageType"] as? String {
            type = messageType
        } else if let messageType = messageObj[KeyConstants.messageType] as? Int {
            type = "\(messageType)"
        }
        
        if let gpMessageTyp = messageObj["gpMessageType"] as? String{
            gpMessageType = gpMessageTyp
        }
        
        
        
        
        // Replied Message
        if type == "10" && isReplied == true {
            if let previousPload = messageObj[KeyConstants.previousPayload] as? String,
                let previousFrom = messageObj[KeyConstants.previousFrom] as? String,
                let previousReceiverIdentifier = messageObj[KeyConstants.previousReceiverIdentifier] as? String,
                let previousId = messageObj[KeyConstants.previousId] as? String,
                let previousType = messageObj[KeyConstants.previousType] as? String,
                let replyType = messageObj[KeyConstants.replyType] as? String {
                
                var pload = previousPload
                
                var previousMessageType : MessageTypes = MessageTypes.text
                
                if Int(previousType)! < 0 ||  Int(previousType)! > 13{
                    previousMessageType = MessageTypes.text
                }else{
                    previousMessageType = MessageTypes(rawValue: Int(previousType)!)!
                }
                let repliedMsgType : MessageTypes = MessageTypes(rawValue: Int(replyType)!)!
                
                let encodedPload = previousPload.replace(target: "\n", withString: "")
                if let repliedPload = encodedPload.fromBase64() {
                    pload = repliedPload
                }
                
                let replyMsgObj = RepliedMessage(previousPayload: pload, previousFrom: previousFrom, previousReceiverIdentifier: previousReceiverIdentifier, previousId: previousId, previousType: previousMessageType, replyMessageType: repliedMsgType)
                repliedMsg = replyMsgObj
            }
        }
        /*
         Bug Name :- Not showing payload in transaction cell
         Fix Date :- 8/06/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Assigning payload if decode msg is nil
         */
        var decodedMsg = payload.fromBase64()
        if decodedMsg == nil {
            decodedMsg = payload
        }
        
        switch type {
        case "0": // for text messages.
            isMediaAvailable = false
            break
            
        case "1" : //For Image
            isMediaAvailable = true
            if isSelfMessage {
                media = SentImageMediaItem()
            } else {
                media = ReceivedImageMediaItem()
            }
            break
            
        case "2" : // For videos
            isMediaAvailable = true
            if isSelfMessage {
                media = SentVideoMediaItem()
            } else {
                media = ReceivedVideoMediaItem()
            }
            break
            
        case "3" : //Location
            isMediaAvailable = true
            if isSelfMessage {
                media = SentLocationMediaItem()
            } else {
                media = ReceivedLocationMediaItem()
            }
            break
            
        case "4": // Contact
            isMediaAvailable = true
            if isSelfMessage {
                media = SentContactMediaItem()
            } else {
                media = ReceivedContactMediaItem()
            }
            break
            
        case "5": //Audio
            isMediaAvailable = true
            if isSelfMessage {
                media = SentAudioMediaItem()
            } else {
                media = ReceivedAudioMediaItem()
            }
            break
            
        case "6": //Sticker
            isMediaAvailable = true
            if isSelfMessage {
                media = StickerSentMediaItem()
            } else {
                media = StickerReceivedMediaItem()
            }
            break
            
        case "7": //Doodles.
            isMediaAvailable = true
            if isSelfMessage {
                media = SentImageMediaItem()
            } else {
                media = ReceivedImageMediaItem()
            }
            break
            
        case "8": //gif
            isMediaAvailable = true
            if isSelfMessage {
                media = StickerSentMediaItem()
            } else {
                media = StickerReceivedMediaItem()
            }
            break
            
        case "9": //document
            isMediaAvailable = true
            if isSelfMessage {
                media = SentDocumentMediaItem()
            } else {
                media = ReceivedDocumentMediaItem()
            }
            break
            
        case "11": //Deleted
            isMediaAvailable = true
            media = DeletedMessageMediaItem()
            break
            
        case "10": // Replyed for message
            if let repliedMessage = repliedMsg {
                switch repliedMessage.replyMessageType!  {
                case .text:
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedTextReceivedMessageMediaItem()
                    } else {
                        media = RepliedTextSentMessageMediaItem()
                    }
                    break
                    
                case .image : //For Image
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedSentImageMediaItem()
                    } else {
                        media = RepliedReceivedImageMediaItem()
                    }
                    break
                    
                case .video : // For videos
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedSentVideoMediaItem()
                    } else {
                        media = RepliedReceivedVideoMediaItem()
                    }
                    break
                    
                case .location : //Location
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedSentLocationMediaItem()
                    } else {
                        media = RepliedReceivedLocationMediaItem()
                    }
                    break
                    
                case .contact : // Contact
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedSentContactMediaItem()
                    } else {
                        media = RepliedReceivedContactMediaItem()
                    }
                    break
                    
                case .audio : //Audio
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedSentAudioMediaItem()
                    } else {
                        media = RepliedReceivedAudioMediaItem()
                    }
                    break
                    
                case .sticker : //Sticker
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedStickerSentMediaItem()
                    } else {
                        media = RepliedStickerReceivedMediaItem()
                    }
                    break
                    
                case .doodle : //Doodles.
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedSentImageMediaItem()
                    } else {
                        media = RepliedReceivedImageMediaItem()
                    }
                    break
                    
                case .gif : //gif
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedStickerSentMediaItem()
                    } else {
                        media = RepliedStickerReceivedMediaItem()
                    }
                    break
                    
                case .document : //document
                    isMediaAvailable = true
                    if isSelfMessage {
                        media = RepliedSentDocumentMediaItem()
                    } else {
                        media = RepliedReceivedDocumentMediaItem()
                    }
                    break
                    
                default:
                    break
                }
            }
        case "13" : //For Post
            isMediaAvailable = true
            if isSelfMessage {
                media = SentPostMediaItem()
            } else {
                media = ReceivedPostMediaItem()
            }
            break
            
        case "15":
            isMediaAvailable = true
            print(data)
            var status: Bool = true
            if data["transferStatus"] as? String != "1"{
                status = false
            }
            if isSelfMessage {
                media = TransferSentMediaItem(isPending: status, payload: payload.count > 0 ? true : false )
            } else {
                media = TransferReceivedMediaItem(isPending: status, payload: payload.count > 0 ? true : false )
            }
        break
            // Missed Call
        case "16":
            isMediaAvailable = false
            break
            // call message
        case "17":
            isMediaAvailable = false
            break
        default:
            isMediaAvailable = false
        }
        
        if let secretidd = secretID as? String  {
            secretID = secretidd
        }
        if type == ""{
            type = "0"
        }
        
        
        var  msgType: Int = 0
        if let hasType = type as? String {
            if let hasNumber =  Int(hasType) as? Int,hasNumber <= 17 {
                msgType = hasNumber
            }
        }
        
        var messageTypeObj:MessageTypes?
        
        if let messageTypeObjData:MessageTypes = MessageTypes(rawValue: msgType)  {
            messageTypeObj = messageTypeObjData
        }
        let messageSendDate : Date = DateExtension().getDateObj(fromTimeStamp: timeStamp)
        if let secretid = messageObj["secretId"] as? String {
            secretID = secretid
        }
        
        if let rIdentifier = messageObj[KeyConstants.receiverIdentifier] as? String {
            receiverIdentifier = rIdentifier
        }
        
        dTimee = dTime
        
        if let posID = messageObj["postId"] as? String {
            postId = posID
        }
        if let postTy = messageObj["postType"] as? Int {
            postType = postTy
        }
        if let postTitl = messageObj["postTitle"] as? String {
            postTitle = postTitl
        }
        if let notes = messageObj["txnNotes"] as? String {
            txnNotes = notes
        }
        print("Message \(messageObj)")
        if let amu = messageObj["amount"] as? Double{
            amount = amu
        }
        
        if let amu = messageObj["amount"] as? String{
            amount = Double(amu)
        }
        
        var status = 1
        if let transStatus = messageObj["transferStatus"] as? String{
            status = Int(transStatus) ?? 1
        }
        transferStatus = TransferStatus(rawValue: status)
        if let text = messageObj["transferStatusText"] as? String{
            transferStatusText = text
        }
        
        print("transactionId \(messageObj["fromTxnId"])")
        if let txnid = messageObj["fromTxnId"] as? String{
            txnId = txnid
        }
        
        
        if let txnid = messageObj["fromTxnId"] as? Double{
            txnId = "\(Int(txnid))"
        }
        
        if let callTyp = messageObj["typeOfCall"] as? String{
            callType = Int(callTyp)
        }
        if let duration = messageObj["duration"] as? Double {
         callduration = duration
        }
        
        
        
        self.init(withSenderID: senderID!, andreceiverID: receiverId, withPayload: decodedMsg!, messageDocId: docID, timeStamp: timeStamp, messageType: messageTypeObj, mediaStates:mediaStates, messangerName: messengerName, messageSentDate: messageSendDate, messageId: messageID, media: media, isMediaAvailable: isMediaAvailable, messageStatus: msgStatus, isSelfMessage: isSelfMessage, mediaURL : mediaURL, thumbnailData: thumbnailData, secretID: secretID, receiverIdentifier: receiverIdentifier, messageData : msgData, isReplied : isReplied, repliedMessage : repliedMsg ,gpMessageType: gpMessageType ,dTime : dTimee, postId: postId, postTitle: postTitle, postType: postType, readTime: readTime, deliveryTime: deliveryTime, amount: amount, transferStatus: transferStatus, transferStatusText: transferStatusText, callType: callType,callDuration: callduration,txnId: txnId, txnNotes: txnNotes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(withMsgObject msgObj: Message, andMediaItem media: JSQMessageMediaData) {
        self.init(withSenderID: msgObj.senderId,
                  andreceiverID: msgObj.messageToID,
                  withPayload: msgObj.messagePayload!,
                  messageDocId: msgObj.messageDocId!,
                  timeStamp: msgObj.timeStamp,
                  messageType: msgObj.messageType,
                  mediaStates: msgObj.mediaStates,
                  messangerName: msgObj.messangerName!,
                  messageSentDate: msgObj.messageSentDate!,
                  messageId: msgObj.messageId,
                  media:media,
                  isMediaAvailable: msgObj.isMediaAvailable,
                  messageStatus: msgObj.messageStatus!,
                  isSelfMessage: msgObj.isSelfMessage,
                  mediaURL: msgObj.mediaURL,
                  thumbnailData: msgObj.thumbnailData,
                  secretID: msgObj.secretID!,
                  receiverIdentifier :msgObj.receiverIdentifier,
                  messageData: msgObj.messageData,
                  isReplied : msgObj.isReplied,
                  repliedMessage : msgObj.repliedMessage,
                  gpMessageType : msgObj.gpMessageType,
                  dTime : msgObj.dTime,
                  postId: msgObj.postId,
                  postTitle: msgObj.postTitle,
                  postType: msgObj.postType,
                  readTime: msgObj.readTime,
                  deliveryTime: msgObj.deliveryTime,
                  amount: msgObj.amount,
                  transferStatus: msgObj.transferStatus,
                  transferStatusText: msgObj.transferStatusText,
                  callType : msgObj.callType,
                  callDuration: msgObj.callDuration, txnId: msgObj.txnId, txnNotes: msgObj.txnNotes
        )
    }
}

extension Message {
    
    func getFilePath() -> String? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        if let mediaURL = self.mediaURL {
            if let fileName = URL(string: mediaURL)?.lastPathComponent {
                let mediaName = "\(documentsPath)/\(fileName)"
                return mediaName
            }
        }
        return nil
    }
    
    func getVideoFileName() -> String? {
        if let mediaURL = self.mediaURL {
            if mediaURL.count>0 {
                return mediaURL
            }
            else if let imgUrl = self.messagePayload {
                return imgUrl
            }
        }
        else if let mediaUrl = self.messagePayload {
            return mediaUrl
        }
        return nil
    }
}
