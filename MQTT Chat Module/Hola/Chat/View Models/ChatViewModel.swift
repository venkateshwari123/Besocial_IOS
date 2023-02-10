//
//  ChatViewModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 01/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Kingfisher
import AVKit

class ChatViewModel: NSObject {
    
    let chat : Chat
    let chatAPI = ChatAPI()
    let messageAPI = MessageAPI()
    fileprivate let favoriteViewModel = FavoriteViewModel.sharedInstance
    
    init(withChatData chat: Chat) {
        self.chat = chat
    }
    
    var messageArray : [String]? {
        return self.chat.messageArray
    }
    
    var hasNewMessage : Bool {
        return self.chat.hasNewMessage
    }
    
    var newMessage : String {
        return self.chat.newMessage
    }
    
    var newMessageTime : String {
        return self.chat.newMessageTime
    }
    
    var newMessageDateInString : String {
        return self.chat.newMessageDateInString
    }
    
    var lastMsgTimeInHours : String? {
        guard let date = self.chat.msgDate else { return ""}
        let hours = DateExtension().lastMessageInHours(date: date)
        return hours
    }
    
    var newMessageCount : String {
        return self.chat.newMessageCount
    }
    
    var lastMessageDate :String {
        return self.chat.lastMessageDate
    }
    
    var receiverUIDArray : [String]? {
        return self.chat.receiverUIDArray
    }
    
    var receiverDocIDArray : [String]? {
        return self.chat.receiverDocIDArray
    }
    
    var name : String {
        return self.chat.name
    }
    
    var imageURL : URL? {
        guard let imageURL = URL(string:self.chat.image) else { return nil }
        return imageURL
    }
    
    var secretID : String {
        return self.chat.secretID
    }
    
    var userID : String {
        return self.chat.userID
    }
    
    var chatID : String {
        return self.chat.chatID
    }
    
    var docID : String? {
        return self.chat.docID
    }
    
    var wasInvited : Bool {
        return self.chat.wasInvited
    }
    
    var destructionTime : Int {
        return self.chat.destructionTime
    }
    
    var isSecretInviteVisible : Bool{
        return self.chat.isSecretInviteVisible
    }
    
    var msgDate : Date? {
        return self.chat.msgDate
    }
    
    var groupName : String? {
        return self.chat.groupName
    }
    
    var initiatorIdentifier : String? {
        return self.chat.initiatorIdentifier
    }
    
    var number:String? {
        return self.chat.number
    }
    
    var isSelfChat:Bool {
        return self.chat.isSelfChat
    }
    
    var isGroupChat:Bool {
        return self.chat.isGroupChat
    }
    
    var isUserBlock:Bool{
        //        return self.chat.isUserBlock
        get {
            return self.chat.isUserBlock
        }
        set {
            self.chat.isUserBlock = newValue
        }
    }
    
    var initiatorId : String? {
        return self.chat.initiatorId
    }
    
    var gpMessageType: String? {
        return self.chat.gpMessagetype
    }
    var  receiverID : String?
    
    
    var isStar : Int? {
        return self.chat.isStar
    }
    
    let couchbaseObj = Couchbase.sharedInstance
    
    func getlastMessage(fromChatDocID docID : String) -> Message? {
        guard let chatData = couchbaseObj.getData(fromDocID: docID) else { return nil }
        guard let  msgArray:[Any] = chatData["messageArray"] as? [Any] else { return nil }
        if !msgArray.isEmpty {
            guard let msgObj = msgArray.last as? [String : Any] else { return nil }
            var mediaState : MediaStates = .notApplicable
            if let mState = msgObj["mediaState"] as? Int {
                if let mIntValue = MediaStates(rawValue: mState) {
                    mediaState = mIntValue
                }
            }
            var mediaUrl:String?
            if let mediaURL = msgObj["mediaURL"] as? String {
                mediaUrl = mediaURL
            }
            
            var isRepliedMsg = false
            var rIdentifier = ""
            
            if (msgObj["replyType"] as? String) != nil{
                isRepliedMsg = true
            }
            
            if let receiverIdentifier = msgObj["receiverIdentifier"] as? String {
                rIdentifier = receiverIdentifier
            }
            
            var gpMessageType = ""
            if let gpMessageTyp = msgObj["gpMessageType"] as? String{
                gpMessageType = gpMessageTyp
            }
            var readTime = 0.0
            var deliveryTime = 0.0
            if let readTm = msgObj["readTime"] as? Double{
                readTime = readTm
            }
            if let deliveryTm = msgObj["deliveryTime"] as? Double{
                deliveryTime = deliveryTm
            }
            var dTime = 0
            if let dtime = msgObj["dTime"] as? Int {
                dTime = dtime
            }
            
            let mesageObj = Message(forData: msgObj, withDocID: docID, andMessageobj: msgObj, isSelfMessage: true, mediaStates: mediaState, mediaURL: mediaUrl, thumbnailData: nil, secretID: nil, receiverIdentifier: rIdentifier, messageData: msgObj, isReplied: isRepliedMsg,gpMessageType:gpMessageType, dTime: dTime, readTime: readTime, deliveryTime: deliveryTime)
            print("callType \(mesageObj.callType ?? 0)")
            return mesageObj
        }
        return nil
    }
    
    func getAtributeString(withMessageStatus messageStatus : String) -> NSMutableAttributedString? {
        let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]
        var str = NSMutableAttributedString(string: "✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
        if messageStatus == "2" {
            let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.gray]
            str = NSMutableAttributedString(string: "✔︎✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            return str
        }
        if messageStatus == "3" {
            let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.blue]
            str = NSMutableAttributedString(string: "✔︎✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            return str
        }
        return str
    }
    
    /// Delete chat action on this perticular chat.
    ///
    /// - Parameters:
    ///   - success: If it got succeeded then return here.
    ///   - failure: If it got failed then return here.
    func deleteChat(success:@escaping ([String : Any]) -> Void, failure:@escaping (CustomErrorStruct) -> Void) {
        self.deleteChatFromServer(success: { response in
            print("chat deleted")
            success(response)
            self.deleteChatLocally()
            
        }) { error in
            print("chat delete failed")
            failure(error)
        }
    }
    
    func getMessages(withTimeStamp timeStamp: String, andPageSize pageSize : String) {
        var msgUrl = "Messages?chatId=\(self.chatID)&timestamp=\(timeStamp)&pageSize=\(pageSize)"
        //        var params = ["chatId" : "\(self.chatID)",
        //            "timestamp" : "\(timeStamp)",
        //            "pageSize" : "\(pageSize)",
        //        ]
        if self.isGroupChat == true{
            guard let reciverID = self.receiverID else {return}
            msgUrl = "GroupChat/Messages?chatId=\(String(describing: reciverID))&timestamp=\(timeStamp)&pageSize=\(pageSize)"
            //   params["chatId"] = "\(String(describing: reciverID))"
        }
        self.messageAPI.getMessages(withUrl: msgUrl, param: [:])
    }
    
    func deleteChatLocally() {
        if let docID = self.docID {
            let individualChatVMObj = IndividualChatViewModel(couchbase: self.couchbaseObj)
            individualChatVMObj.deleteDocIDData(fromChatDocID: docID)
            favoriteViewModel.updateContactDoc(withUserID: userID, andChatDocId: nil)
            if self.isGroupChat{
                self.deleteGroupDocFromUserDefaults(groupId: self.chat.userID)
            }
        }
    }
    
    func deleteGroupDocFromUserDefaults(groupId: String){
        if let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument) {
            if  let document = couchbaseObj.getDocumentObject(fromDocID: documentID as! String){
                let maindict = document.properties
                var dict = maindict!["GroupChatsDocument"] as! [String:Any]
                dict.removeValue(forKey: groupId)
                do{
                    try document.update { (newRev) -> Bool in
                        newRev["GroupChatsDocument"] = dict
                        return true
                    }
                }
                catch let error {
                    print(error.localizedDescription )
                }
            }
        }
    }
    
    func deleteChatFromServer(success:@escaping ([String : Any]) -> Void, failure:@escaping (CustomErrorStruct) -> Void)  {
        chatAPI.deleteChat(withSecretID: self.secretID, andRecipientID: self.userID ,isGroupChat:self.isGroupChat, success: { response in
            success(response)
        }) { error in
            print("got an error")
            failure(error)
        }
    }
    
    func thumbnail(sourceURL:NSURL) -> UIImage {
        let asset = AVAsset(url: sourceURL as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 1)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            let imgData = NSData(data: (image).jpegData(compressionQuality: 1)!)
            let compressedImage = UIImage(data: imgData as Data)
            print(imgData.length/1024)
            return compressedImage!
        } catch {
            return #imageLiteral(resourceName: "play")
        }
    }
    
    func createThumbnail(forImage image : UIImage) -> String? {
        // Define thumbnail size
        let size = CGSize(width: 70, height: 70)
        // Define rect for thumbnail
        let scale = max(size.width/image.size.width, size.height/image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale
        let x = (size.width - width) / CGFloat(2)
        let y = (size.height - height) / CGFloat(2)
        let thumbnailRect = CGRect(x: x, y: y, width: width, height: height)
        
        // Generate thumbnail from image
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: thumbnailRect)
        guard let thumbnail = UIGraphicsGetImageFromCurrentImageContext() else { return  nil }
        UIGraphicsEndImageContext()
        let imageData = Image.convertImageToBase64(image: thumbnail)
        return imageData
    }
    
    func updateExistingMessage(withMessage msgObj : Message, withMediaState mediaState : MediaStates) {
        guard let chatDocID = self.docID else { return }
        guard let chatData = couchbaseObj.getData(fromDocID: chatDocID) else { return }
        var chatDta = chatData
        var msgArray = chatDta["messageArray"] as! [[String:Any]]
        for (idx, dic) in msgArray.enumerated() {
            if let tStamp = dic["timestamp"] as? String {
                if (Int64(tStamp) == msgObj.uniquemessageId) {
                    var msgData = dic
                    msgData["mediaState"] = mediaState.rawValue
                    msgArray[idx] = msgData
                }
            } else if let tStamp = dic["timestamp"] as? Int {
                if (Int64(tStamp) == msgObj.uniquemessageId) {
                    var msgData = dic
                    msgData["mediaState"] = mediaState.rawValue
                    msgArray[idx] = msgData
                }
            }
        }
        chatDta["messageArray"] = msgArray
        self.couchbaseObj.updateData(data: chatDta, toDocID: chatDocID)
    }
    
    func deleteMessage(withMessageObj msgObj : Message) {
        guard let chatDocID = self.docID else { return }
        guard let chatData = couchbaseObj.getData(fromDocID: chatDocID) else { return }
        var chatDta = chatData
        let msgArray = chatDta["messageArray"] as! [[String:Any]]
        var tempMsgArray = msgArray
        for (idx, dic) in msgArray.enumerated() {
            if let tStamp = dic["timestamp"] as? String {
                if (Int64(tStamp) == msgObj.uniquemessageId) {
                    tempMsgArray.remove(at: idx)
                }
            } else if let tStamp = dic["timestamp"] as? Int {
                if (Int64(tStamp) == msgObj.uniquemessageId) {
                    /*
                     Bug Name:- Crash
                     Fix Date:- 10/01/22
                     Fix By  :- Jayaram G
                     Description of Fix:- Crashing due to Index range , checking array count and removing index
                     */
                    if tempMsgArray.count > idx {
                        tempMsgArray.remove(at: idx)
                    }
                }
            }
        }
        chatDta["messageArray"] = tempMsgArray
        self.couchbaseObj.updateData(data: chatDta, toDocID: chatDocID)
    }
    
    func updateMessageToDeletedState(withMsgObj msgObj : Message) -> Message? {
        guard let chatDocID = self.docID else { return nil }
        guard let chatData = couchbaseObj.getData(fromDocID: chatDocID) else { return nil }
        var chatDta = chatData
        var msgArray = chatDta["messageArray"] as! [[String:Any]]
        for (idx, dic) in msgArray.enumerated() {
            if let tStamp = dic["timestamp"] as? String {
                if (Int64(tStamp) == msgObj.uniquemessageId) {
                    var msgData = dic
                    msgData["messageType"] = "11"
                    msgData["type"] = "11"
                    msgArray[idx] = msgData
                }
            } else if let tStamp = dic["timestamp"] as? Int {
                if (Int64(tStamp) == msgObj.uniquemessageId) {
                    var msgData = dic
                    msgData["messageType"] = "11"
                    msgData["type"] = "11"
                    msgArray[idx] = msgData
                }
            }
        }
        chatDta["messageArray"] = msgArray
        msgObj.messageType = .deleted
        let msgObject = Message(withMsgObject: msgObj, andMediaItem: DeletedMessageMediaItem())
        self.couchbaseObj.updateData(data: chatDta, toDocID: chatDocID)
        return msgObject
    }
    
    //MARK:- Transfer related service call
    func updateTransferStatus(isAccepted: Bool, msgId: String){
        self.messageAPI.transferAcceptOrRejectAction(isAccept: isAccepted, msgId: msgId)
    }
    
    func cancelTransferMoney(msgId: String){
        self.messageAPI.trnsferCancelActionService(msgId: msgId)
    }
}

extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)
        
        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
