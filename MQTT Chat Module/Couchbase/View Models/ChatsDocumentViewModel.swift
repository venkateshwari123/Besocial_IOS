//
//  ChatsDocumentViewModel.Swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 01/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

class ChatsDocumentViewModel: NSObject {
    
    public let couchbase: Couchbase
    
    init(couchbase: Couchbase) {
        self.couchbase = couchbase
    }
    
    let selfID = Utility.getUserid()
    
    /// Used for creating a document when there is no doc Available
    ///
    /// - Returns: string of chat doc ID.
    func createChatDoc(withReceiverName receiverName : String?, secretID : String?, receiverImage : String?, message : [String : Any]?, receiverID:String?, destrcutionTime : Int?, isCreatingChat : Bool, contact: Contacts? = nil) -> String? {
        if receiverID == Utility.getUserid() {
            return nil
        }
        var image = ""
        let timeStamp = Int64(floor(Date().timeIntervalSince1970 * 1000))
        guard let receiverName = receiverName, let receiverID = receiverID, let secretID = secretID else { return nil }
        var chatID = "\(timeStamp)"
        if let receiverImage = receiverImage {
            image = receiverImage
        }
        var dTime = -1
        if let distTime = destrcutionTime {
            dTime = distTime
        }
        // group chat
        var groupName = "", isGroupChat = false, groupChatInitiatorID = "", groupInitiatorIdentifier = "", name = "", userImage = "", number = ""
        
        if let cont = contact{
            name = "\(cont.firstName ?? "")" + " " + "\(cont.lastName ?? "")"
            number = cont.registerNum ?? ""
        }else{
            if let nmber = message?["number"] as? String {
                name = nmber
                number = nmber
            }
            name = receiverName
            if let contactObj = FavoriteViewModel.sharedInstance.getContactObject(forUserID: receiverID) {
                if let contactName = contactObj.fullName {
                    name = contactName
                }
                if let contactImage = contactObj.profilePic {
                    userImage = contactImage
                }
                if let numbr = contactObj.registerNum {
                    number = numbr
                }
            }
            
            if name.count == 0 || name.count == 1 {
                name = number
            }
        }
        var isStar = 0
        if let isStarObj = contact?.isStar {
            isStar = isStarObj
        }
        
        
        if let message = message {
            var wasInvited = false
            
            print("isStar 4 log  \(message["isStar"])")
            if let userWasInvited = message["wasInvited"] as? Bool {
                wasInvited = userWasInvited
            } else if let userWasInvited = message["wasInvited"] as? Int {
                wasInvited = (userWasInvited as NSNumber).boolValue
            }
            if let isStarObj = message["isStar"] as? Int{
                isStar = isStarObj
            }
            if let uImage = message["userImage"] as? String {
                userImage = uImage
            } else if let uImage = message["profilePic"] as? String {
                userImage = uImage
            }
            var totalUnread = 0
            var newMessage = false
            if let unreadCount =  message["totalUnread"] as? Int {
                totalUnread = unreadCount
            } else if let unreadCount =  message["totalUnread"] as? String {
                if let count = Int(unreadCount) {
                    totalUnread = count
                }
            }
            if totalUnread>0 {
                newMessage = true
            }
            if let dtime = message["dTime"] as? Int {
                dTime = dtime
            }
            if let chatId = message["chatId"] as? String{
                  chatID = chatId
            }
            
            var type = "", initiated = false, msgStatus = "", messageStr = "", timestamp = ""
            if let msgType = message["messageType"] as? String, let inititatedBy = message["initiated"] as? Bool, let userNumber = message["number"] as? String {
                type = msgType
                initiated = inititatedBy
                number = userNumber
            }
            
            if let tStamp = message["timestamp"] as? String {
                timestamp = tStamp
            } else if let tStamp = message["timestamp"] as? Int {
                timestamp = "\(tStamp)"
            }
            
            let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: timestamp)
            let newMessageTime = DateExtension().lastMessageInHours(date: lastmsgDate)
            let newMessageDateInString = DateExtension().getDateString(fromTimeStamp: timestamp)
            if let status = message["status"] as? Int{
                msgStatus = "\(status)"
            } else if let msgStats = message["status"] as? String {
                msgStatus = msgStats
            } else if let msgStats = message["deliveryStatus"] as? String {
                msgStatus = msgStats
            }
            
            if let msg = message["payload"] as? String {
                messageStr = msg
            }
            
            // For group Chat
            if let gName = message["groupSubject"] as? String, let groupInitiatorID = message["initiatorId"] as? String, let groupChatinitiatorIdentifier = message["initiatorIdentifier"] as? String {
                groupName = gName
                isGroupChat = true
                groupChatInitiatorID = groupInitiatorID
                groupInitiatorIdentifier = groupChatinitiatorIdentifier
                ///check for groupID alredy there
                //Add groupId and groupId in GroupChatsDocument
                self.updateGroupChatsDocument(groupID: receiverID, groupData: message)
            }
            
            if let gImage = message["groupImageUrl"] as? String {
                userImage = gImage
            }
            
            if let isMemberInitiator = message["memberIsAdmin"] as? Bool {
                initiated = isMemberInitiator
            }
            var chatdocID = ""
            if !isCreatingChat {
                guard let chatDocID = self.createChatDocument(withMessageArray: [message], hasNewMessage: newMessage, newMessage: messageStr, newMessageTime: newMessageTime, newMessageDateInString: newMessageDateInString, newMessageCount: "\(totalUnread)", lastMessageDate: timestamp, receiverUIDArray: [], receiverDocIDArray: [], receiverName: name, receiverImage: userImage, selfDocID: "", receiverID: receiverID, wasInvited: wasInvited, secretID: secretID, dTime: dTime, isSecretInviteVisibile: false, type: type, isSelfLastMessage: initiated, messageDeliveryStatus: msgStatus, chatID: chatID, isGroupChat: isGroupChat, groupName: groupName, groupChatInitiatorID: groupChatInitiatorID, initiatorIdentifier: groupInitiatorIdentifier, number: number, isUserBlocked: false,isStar: isStar) else { return nil }
                chatdocID = chatDocID
            } else {
                guard let chatDocID = self.createChatDocument(withMessageArray: [], hasNewMessage: newMessage, newMessage: messageStr, newMessageTime: newMessageTime, newMessageDateInString: newMessageDateInString, newMessageCount: "\(totalUnread)", lastMessageDate: timestamp, receiverUIDArray: [], receiverDocIDArray: [], receiverName: name, receiverImage: userImage, selfDocID: "", receiverID: receiverID, wasInvited: wasInvited, secretID: secretID, dTime: dTime, isSecretInviteVisibile: false, type: type, isSelfLastMessage: initiated, messageDeliveryStatus: msgStatus, chatID: chatID, isGroupChat: isGroupChat, groupName: groupName, groupChatInitiatorID: groupChatInitiatorID, initiatorIdentifier: groupInitiatorIdentifier, number: number, isUserBlocked: false,isStar: isStar) else { return nil }
                chatdocID = chatDocID
            }
            return chatdocID
        } else {
            guard let chatDocID = self.createChatDocument(withMessageArray: [], hasNewMessage: false, newMessage: "", newMessageTime: "", newMessageDateInString: "", newMessageCount: "0", lastMessageDate: "", receiverUIDArray: [], receiverDocIDArray: [], receiverName: receiverName, receiverImage: image, selfDocID: "", receiverID: receiverID, wasInvited: false, secretID: secretID, dTime: dTime, isSecretInviteVisibile: false, type: "0", isSelfLastMessage: false, messageDeliveryStatus: "0", chatID: chatID, isGroupChat: isGroupChat, groupName: "", groupChatInitiatorID: "", initiatorIdentifier: "", number: number, isUserBlocked: false,isStar: isStar) else { return nil }
            return chatDocID
        }
    }
    
    
    
    //update groupId and groupId in GroupChatsDocument
    func updateGroupChatsDocument(groupID: String ,groupData:[String:Any]) {
        
        if let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument) {
            if  let document = self.couchbase.getDocumentObject(fromDocID: documentID as! String){
                let maindict = document.properties
                var dict = maindict!["GroupChatsDocument"] as? [String:Any]
                if  let id =  dict?[groupID] {
                    print("id present in Dict\(id)")
                    return
                } else {
                    if groupData["messageType"] as! Int == AppConstants.groupType.creatGroup.rawValue {
                        guard let userNum = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String else {return}
                        guard let arr1 = groupData["members"] as? NSArray else {return}
                        let arr:NSMutableArray = arr1.mutableCopy() as! NSMutableArray
                        var dictt:[String:Any]?
                        
                        for i in arr {
                            let dict = i as! [String:Any]
                            if userNum == dict["memberIdentifier"] as! String {
                                dictt = dict
                                arr.remove(dict)
                                break
                            }
                        }
                        var sortArr = [Any]()
                        sortArr.append(dictt)
                        for i in arr {
                            sortArr.append(i)
                        }
                        
                        var creataAt = ""
                        if let creatAtt  = groupData["createdAt"]{
                            creataAt = "\(creatAtt)"
                        }
                        let storedict = ["groupMembersArray":sortArr as NSArray,
                                         "createdByMemberId":groupData["createdByMemberId"] as! String,
                                         "createdByMemberIdentifier":groupData["createdByMemberIdentifier"] as! String,
                                         "createdAt":creataAt,
                                         "isActive":true as Bool
                            ] as [String:Any]
                        
                        let groupDocID = self.couchbase.createDocument(withProperties: ["groupMembersDocId":storedict] as [String : Any])
                        dict?[groupID] = groupDocID
                        
                        do{
                            try document.update { (newRev) -> Bool in
                                newRev["GroupChatsDocument"] = dict
                                return true
                            }
                        }
                        catch let error {
                            print("cdkvndkv\(error)")
                        }
                    } else {
                        print("failed to get documet from provided DocID")
                        return
                    }
                }
            }
        }
    }
    
    /// This method will create individual Chats Document where all the details are going to be stored related to the message and chat.
    ///
    /// - Parameters:
    ///   - messageArray: All messages are going to be stored here with Any type
    ///   - hasNewMessage: Bool flag which will state that is there any new message available or not.
    ///   - newMessage: This is a string which will store the last new message.
    ///   - newMessageTime: String for time when the last message was received.
    ///   - newMessageDateInString: String for date when last mesage was received eg - Yesterday, today or local format when the message is received.
    ///   - newMessageCount: Integer format of unread messages count.
    ///   - lastMessageDate: String format of time in GMT when the last message is received.
    ///   - receiverUIDArray: Array of string with the list of users IDs.
    ///   - receiverDocIDArray: Array of string with all the Documents as respect to the UserID.
    ///   - receiverName: Username of the receiver in String.
    ///   - receiverImage: receiving users image url in string.
    ///   - selfDocID: Senders own document ID for the current chat. Used for showing the last message.
    ///   - selfUID: senders UID for the current chat.
    ///   - wasInvited: Boolean flag for Whether invited or has invited someone else for secret chat.
    ///   - secretID: String ID for idnetifing each secret chat individually.
    ///   - dTime: destruction time in string for current message. By default it will be -1.
    ///   - isSecretInviteVisibile: Boolean flag for showing the pop up for secret invite.
    /// - Returns: Object of CBLDocument / Document
    func createChatDocument(withMessageArray messageArray: [Any], hasNewMessage : Bool, newMessage : String, newMessageTime : String, newMessageDateInString : String, newMessageCount : String, lastMessageDate : String, receiverUIDArray : [String], receiverDocIDArray : [String], receiverName : String,receiverImage : String, selfDocID : String, receiverID : String, wasInvited : Bool, secretID :String, dTime : Int, isSecretInviteVisibile : Bool, type : String, isSelfLastMessage : Bool, messageDeliveryStatus : String, chatID : String, isGroupChat : Bool, groupName : String, groupChatInitiatorID : String, initiatorIdentifier:String, number : String, isUserBlocked : Bool,isStar: Int) -> String? {
        print("create chat receiverName \(receiverName)")
        let params = ["messageArray":messageArray,
                      "hasNewMessage":hasNewMessage,
                      "newMessage":newMessage,
                      "isSelf":isSelfLastMessage,
                      "deliveryStatus":messageDeliveryStatus,
                      "newMessageTime":newMessageTime,
                      "newMessageDateInString":newMessageDateInString,
                      "newMessageCount":newMessageCount,
                      "lastMessageDate":lastMessageDate,
                      "receiver_uid_array":receiverUIDArray,
                      "receiver_docid_array":receiverDocIDArray,
                      "receiverName":receiverName,
                      "receiverImage":receiverImage,
                      "selfDocId":selfDocID,
                      "receiverID":receiverID,
                      "wasInvited":wasInvited,
                      "dTime":dTime,
                      "chatId": chatID,
                      "messageType":type as Any,
                      "number":number,
                      "isUserBlocked":isUserBlocked,
                      "isStar": isStar,
                      //// for group chat
            "isGroupChat":isGroupChat,
            "groupName":groupName,
            "initiatorId":groupChatInitiatorID,
            "initiatorIdentifier":initiatorIdentifier,
            /// For secret chat
            "secretId":secretID,
            "secretInviteVisibility":isSecretInviteVisibile] as [String:Any]
        let chatDocID = couchbase.createDocument(withProperties: params)
        return chatDocID
    }
    
    /// Used for updating chat whenever a message is received.
    ///
    /// - Parameters:
    ///   - data: Message data which will contains all the data
    ///   - msgObject: current message which is going to be added to the document.
    ///   - docID: current doc id where you wanted to update the data
    func updateChatData(withData data: [String: Any], msgObject : Any,inDocID docID : String, isCreatingChat: Bool) {
        var chatData = data
        print("isStar 2 Log \(chatData["isStar"])")
        var msgArray:[Any] = chatData["messageArray"] as! [Any]
        guard let msgobject = msgObject as? [String : Any] else { return }
        var msgCount = 0, newMessage = "", msgType = "", receiverName = ""
        var newMSgCount = "0", lastMsgDate = ""
        if let hasNewMessage = msgobject["hasNewMessage"] as? Bool {
            chatData["hasNewMessage"] = hasNewMessage
        }
        if let tStamp = msgobject["timestamp"] as? String {
            lastMsgDate = tStamp
        } else if let tStamp = msgobject["timestamp"] as? Int {
            lastMsgDate = "\(tStamp)"
        }
        
        if let wasInvited = data["wasInvited"] as? Bool {
            if !wasInvited {
                chatData["wasInvited"] = true
            }
        }
        
        if let newMessageCount = data["newMessageCount"] as? String {
            newMSgCount = newMessageCount
        }
        
        if let lastMessageDate = msgobject["lastMessageDate"] as? String {
            if lastMessageDate != ""{
                lastMsgDate = lastMessageDate
            }
        }
        
        if let type = msgobject["type"] as? String {
            msgType = type
        } else if let type = msgobject["messageType"] as? String {
            msgType = type
        }
        
        /*
         Bug Name:- Group chat-> Outside showing the notification but not in chat
         Fix Date:- 22nd Feb 2022
         Fixed By:- Nikunj C
         Description of Fix:- type key come as Int instead of string. added required condition
         */
        
        if let type = msgobject["type"] as? Int {
            msgType = String(type)
        } else if let type = msgobject["messageType"] as? Int {
            msgType = String(type)
        }
        
        if let nMessage = msgobject["payload"] as? String {
            newMessage = nMessage
        } else if let nMessage = msgobject["message"] as? String {
            newMessage = nMessage
        }
        
        if !isCreatingChat {
            if msgType == "16" || msgType == "17"{
                if checkMsgExistOrNot(withMessage: msgObject, andMessageArray: msgArray) {
                    msgArray.append(msgObject as Any)
                }
                if let isSelf = msgobject["isSelf"] as? Bool, !isSelf{
                    msgCount = Int(newMSgCount)!+1
                    chatData["hasNewMessage"] = true
                }
                
            }
            else if msgType != "11" {
                if checkMsgExistOrNot(withMessage: msgObject, andMessageArray: msgArray){
                    msgArray.append(msgObject as Any)
                }else if msgType == "15"{
                    if let index = msgArray.firstIndex(where: { (data) -> Bool in
                        guard let msg = msgObject as? [String : Any] else{return false}
                        guard let arrData = data as? [String : Any] else{return false}
                        return arrData["id"] as? String == msg["id"] as? String
                    }){
                        msgArray[index] = msgObject
                    }
                }
                if let isSelf = msgobject["isSelf"] as? Bool, !isSelf{
                    msgCount = Int(newMSgCount)!+1
                    chatData["hasNewMessage"] = true
                }
            } else {
                self.updateMessageForDeletion(withMessageObj: msgobject, andDocID: docID)
            }
        }
        
        /// Upadting last message count.
        if let unreadMsgCount = msgobject["newMessageCount"] as? String {
            msgCount = Int(unreadMsgCount)!
            if msgCount>0 {
                chatData["hasNewMessage"] = true
            } else {
                chatData["totalUnread"] = 0
                chatData["hasNewMessage"] = false
            }
        }
        
        /// For maintaining delivery Status.
        if let deliveryStatus = msgobject["deliveryStatus"] as? String{
            chatData["deliveryStatus"] = deliveryStatus
        }
        
        /// For showing the number if the user name is not available.
        var numberIdentifier = ""
        if let number = msgobject["number"] as? String {
            chatData["number"] = number
            numberIdentifier = number
        } else if let number = msgobject["receiverIdentifier"] as? String{
            chatData["number"] = number
            numberIdentifier = number
        }
        
        /// For last message.
        if let newMessage = msgobject["newMessage"] as? String {
            chatData["newMessage"] = newMessage
        }
        
        /// For current chat id if its available.
        if let chatID = msgobject["chatID"] as? String {
            chatData["chatId"] = chatID
        }
        if let chatID = msgobject["chatId"] as? String {
            chatData["chatId"] = chatID
        }
        print("********Message Type \(msgType)")
        if !isCreatingChat {
            if msgType == "16" || msgType == "17"{
               print("Dont update ")
                DispatchQueue.main.async {
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    appdelegate.callProviderDelegate?.reportEndCall(nil)
                }
            }else {
                if let image = msgobject["userImage"] as? String {
                    if let isSelf = msgobject["isSelf"] as? Bool, isSelf == true{
                        if let userData = couchbase.getData(fromDocID: docID){
                            chatData["receiverImage"] = userData["receiverImage"]
                        }
                    }else{
                        chatData["receiverImage"] = image
                    }
                }
                
                if let name = msgobject["name"] as? String{
                    if let isSelf = msgobject["isSelf"] as? Bool, isSelf == true{
                        if let userData = couchbase.getData(fromDocID: docID){
                            receiverName = userData["receiverName"] as! String
                        }
                    }else{
                        receiverName  = name
                    }
                }else if let name = msgobject["receiverName"] as? String{
                    receiverName  = name
                }else if let rName = chatData["receiverName"] as? String {
                    if rName.count>0 {
                        receiverName = rName
                    } else {
                        receiverName = numberIdentifier
                    }
                }
                print("message receiverName \(receiverName)")
                chatData["receiverName"] = receiverName
            }
        }else{
            if let image = msgobject["userImage"] as? String {
                    if let isSelf = msgobject["isSelf"] as? Bool, isSelf == true{
                        if let userData = couchbase.getData(fromDocID: docID){
                            chatData["receiverImage"] = userData["receiverImage"]
                        }
                    }else{
                        chatData["receiverImage"] = image
                    }
                }
                
                if let name = msgobject["name"] as? String{
                    if let isSelf = msgobject["isSelf"] as? Bool, isSelf == true{
                        if let userData = couchbase.getData(fromDocID: docID){
                            receiverName = userData["receiverName"] as! String
                        }
                    }else{
                        
                        receiverName  = name
                    }
                }else if let name = msgobject["receiverName"] as? String{
                    receiverName  = name
                }else if let rName = chatData["receiverName"] as? String {
                    if rName.count>0 {
                        receiverName = rName
                    } else {
                        receiverName = numberIdentifier
                    }
                }
            print("message 468 receiverName \(receiverName)")
                chatData["receiverName"] = receiverName
            
        }
        
        chatData["newMessage"] = newMessage
        chatData["newMessageCount"] = "\(msgCount)"
        chatData["lastMessageDate"] = lastMsgDate
        chatData["selfDocId"] = docID
        chatData["newMessageDateInString"] =  DateExtension().getDateString(fromTimeStamp: lastMsgDate)
        let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: lastMsgDate)
        chatData["newMessageTime"] = DateExtension().lastMessageInHours(date: lastmsgDate)
        chatData["messageArray"] = msgArray
        chatData["messageType"] = msgType
        
        /// Updating Group Details to chat
        if let initiatorId = msgobject["initiatorId"] as? String, let groupName = msgobject["groupName"] as? String, let initiatorIdentifier = msgobject["initiatorIdentifier"] as? String, let isGroupChat = msgobject["isGroupChat"] as? Bool {
            chatData["initiatorId"] = initiatorId
            chatData["groupName"] = groupName
            chatData["initiatorIdentifier"] = initiatorIdentifier
            chatData["isGroupChat"] = isGroupChat
        }
        
        if let isSelf = msgobject["isSelf"] as? Bool {
            chatData["isSelf"] = isSelf
        }
        
        if let gpMessageTyp = msgobject["gpMessageType"] as? String{
            chatData["gpMessageType"] = gpMessageTyp
        }
        
        if let groupMem = msgobject["members"] as? [[String:Any]]{
            chatData["groupMembersArray"] = groupMem
        }
        
        ///Updating Secret Chat details to chat.
        if let secretId = msgobject["secretId"] as? String  {
            chatData["secretId"] = secretId
            
        }
        if let dTime = msgobject["dTime"] as? Int {
            chatData["dTime"] = dTime
        }
        
        ///Updating Post details if it has
        if let postId = msgobject["postId"] as? String{
            chatData["postId"] = postId
        }
        if let postTitle = msgobject["postTitle"] as? String{
            chatData["postTitle"] = postTitle
        }
        if let postType = msgobject["postType"] as? String{
            chatData["postType"] = postType
        }
        if let postType = msgobject["postType"] as? Int{
            chatData["postType"] = postType
        }
        
        if let amount = msgobject["amount"] as? String{
            chatData["amount"] = amount
        }
        if let transferStatus = msgobject["transferStatus"] as? String{
            chatData["transferStatus"] = transferStatus
        }
        
        if let txnid = msgobject["fromTxnId"] as? String {
            chatData["fromTxnId"] = txnid
        }
        if let notes = msgobject["notes"] as? String {
            chatData["notes"] = notes
        }
        if let transferStatusText = msgobject["transferStatusText"] as? String{
            chatData["transferStatusText"] = transferStatusText
        }
        
        if let isVerified = msgobject["isStar"] as? Int{
            chatData["isStar"] = isVerified
        }
        
        couchbase.updateData(data: chatData, toDocID: docID)
        
        
    }
    
    /// Update document for chats getting from MQTT server.
    ///
    /// - Parameters:
    ///   - data: data fetched from MQTT server
    ///   - topic: current topic name.
    func updateDocumentForChatReceived(withChatData data : [String:Any], atTopic topic : String, isGroupChat : Bool) {
        let name = NSNotification.Name(rawValue: "ChatUpdatedNotification")
        if isGroupChat {
            let groupChats = ["chats":[data]]
            self.updateChatsToCouchbase(withData: groupChats, isGroupChat : isGroupChat)
        } else {
            self.updateChatsToCouchbase(withData: data, isGroupChat : isGroupChat)
        }
        NotificationCenter.default.post(name: name, object: self, userInfo: nil)
    }
    
    /// update messages with messages by chatID, receiverID and secretId
    ///
    /// - Parameters:
    ///   - messages: array of messages
    ///   - chatID: current chatID
    ///   - receiverID: receiverID
    ///   - secretId: secret ID/Product ID
    func updateMessages(withMessage messages : [[String :Any]]?, byChatID chatID : String?, receiverID : String?, secretId : String?) {
        guard let chatID = chatID, let receiverID = receiverID, let secretId = secretId, let messages = messages, messages.count > 0 else { return }
        let individualChatVMObject = IndividualChatViewModel(couchbase: couchbase)
        guard let chatDocID = individualChatVMObject.getChatDocID(withreceiverID: receiverID, andSecretID: secretId, withContactObj: nil, messageData: nil, destructionTime: nil, isCreatingChat: false) else { return }
        guard let data = couchbase.getData(fromDocID: chatDocID) else { return }
        var chatData = data
        if (chatData["chatId"] as? String) == chatID  || (chatData["chatId"] as? String) == chatID{
            guard let messagesArray = chatData["messageArray"] as? [[String : Any]] else { return }
            var messageArray = messagesArray
            guard let formatedMessages = self.getFormatedMessages(from: messages) else { return }
            messageArray.append(contentsOf:formatedMessages)
            let sortedThings = messageArray.sorted { msg1,msg2 in
                if let time0 = msg1["timestamp"] as? Int64, let time1 = msg2["timestamp"] as? Int64 {
                    return time0 < time1
                } else if let time0 = msg1["timestamp"] as? String, let time1 = msg2["timestamp"] as? String {
                    if let ts1 = Float(time0), let ts2 = Float(time1) {
                        return  ts1 < ts2
                    }
                }
                return false
            }
            chatData["messageArray"] = sortedThings
            couchbase.updateData(data: chatData, toDocID: chatDocID)
        }
    }
    
    /// get formated messages from messages
    ///
    /// - Parameter messages: array of messages
    /// - Returns: array of formated messages
    fileprivate func getFormatedMessages(from messages: [[String : Any]]) -> [[String : Any]]? {
        var formatedMessages = [[String : Any]]()
        for message in messages {
            var msg = message
            msg["message"] = message["payload"]
            msg["isSelf"] = false
            msg["from"] = message["senderId"]
            msg["to"] = message["receiverId"]
            msg["deliveryStatus"] = message["status"]
            msg["id"] = message["messageId"]
            msg["mediaState"] = 0
            msg["name"] = message["name"]
            
            guard let selfID = selfID, let senderId = message["senderId"] as? String else { return nil }
            if selfID == senderId {
                msg["isSelf"] = true
            }
            
            
            //for group Tost Msgs
            if message["payload"] == nil {
                msg["gpMessageType"] = message["messageType"]
                if  let gpMessType = message["messageType"] as? String {
                    
                    switch (gpMessType) {
                        
                    case "0" :
                        if let mess = message["initiatorIdentifier"] as? String , let groupName = message["groupSubject"] as? String{
                            let tostMsg = "\(mess),\(groupName)"
                            msg["message"] =  tostMsg.toBase64()
                            msg["messageType"] = "0"
                            
                        }
                        
                    case "1":
                        
                        if let num1 = message["initiatorIdentifier"] as? String , let num2 = message["memberIdentifier"] as? String{
                            let tostMsg = "\(num1),\(num2)"
                            msg["message"] =  tostMsg.toBase64()
                            msg["messageType"] = "0"
                        }
                        
                    case "2":
                        if let num1 = message["initiatorIdentifier"] as? String , let num2 = message["memberIdentifier"] as? String{
                            let tostMsg = "\(num1),\(num2)"
                            msg["message"] =  tostMsg.toBase64()
                            msg["messageType"] = "0"
                        }
                        
                    case "3":
                        
                        if let num1 = message["initiatorIdentifier"] as? String , let num2 = message["memberIdentifier"] as? String{
                            let tostMsg = "\(num1),\(num2)"
                            msg["message"] =  tostMsg.toBase64()
                            msg["messageType"] = "0"
                        }
                    case "4":
                        
                        if let num1 = message["initiatorIdentifier"] as? String , let name = message["groupSubject"] as? String{
                            let tostMsg = "\(num1),\(name)"
                            msg["message"] =  tostMsg.toBase64()
                            msg["messageType"] = "0"
                        }
                        
                    case "5":
                        
                        if let num1 = message["initiatorIdentifier"] as? String{
                            let tostMsg = "\(num1)"
                            msg["message"] =  tostMsg.toBase64()
                            msg["messageType"] = "0"
                        }
                        
                    case "6":
                        
                        if let num1 = message["initiatorIdentifier"] as? String{
                            let tostMsg = "\(num1)"
                            msg["message"] =  tostMsg.toBase64()
                            msg["messageType"] = "0"
                        }
                        
                    default:
                        print("dd")
                    }
                    
                    
                    
                }
            }
            
            formatedMessages.append(msg)
        }
        return formatedMessages
    }
    
    /// For updating the chats to couchbase
    ///
    /// - Parameters:
    ///   - data: passing the data with the message.
    ///   - isComingInitially: if the data is comming initially.
    fileprivate func updateChatsToCouchbase(withData data:[String :Any], isGroupChat : Bool) {
        var isGPChat = isGroupChat
        guard let chats = data["chats"] as? [Any] else { return }
        let individualChatDocVMObject = IndividualChatViewModel(couchbase: couchbase)
        for chatObj in chats {
            guard var chatObj = chatObj as? [String :Any] else { return }
            
            if let gpChat = chatObj["groupChat"] as? Bool {
                isGPChat = gpChat
            }
            
            if isGPChat {
                var type = 0
                if let gType = chatObj["type"] as? Int {
                    type = gType
                }
//                if let gType = chatObj["messageType"] as? String{
//                    type = Int(gType)!
//                }
                
                if type == AppConstants.groupType.addInGroup.rawValue {
                    guard let memID = chatObj["memberId"] as? String else {continue}
                    guard let userID = Utility.getUserid() else {continue}
                    if memID == userID {
                        var groupId: String!
                        if let groupID = chatObj["groupId"]  as? String {
                            groupId = groupID
                        }else if let groupID = chatObj["chatId"]  as? String{
                            groupId = groupID
                        }
                        if  checkgpDocIsthere(groupID: groupId!) {
                            chatObj["type"] = 1
                        }else {
                            chatObj["type"] = 0
                        }
                    }
                }
                guard let msgObj = self.getGroupMessageDetails(withData: chatObj) else { continue }
                _ = individualChatDocVMObject.updateIndividualChatDoc(withMsgObj: msgObj, toDocID: nil, isForCreatingChat : true)
                
            } else {
                guard let msgObj = self.getMessageObj(withData: chatObj) else { return }
                _ = individualChatDocVMObject.updateIndividualChatDoc(withMsgObj: msgObj, toDocID: nil, isForCreatingChat : true)
            }
        }
    }
    
    func checkgpDocIsthere(groupID:String) -> Bool {
        if let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument) {
            if  let document = self.couchbase.getDocumentObject(fromDocID: documentID as! String){
                let maindict = document.properties
                var dict = maindict!["GroupChatsDocument"] as! [String:Any]
                if  dict[groupID] != nil {
                    return true
                }else {
                    return false
                }
            }
        }
        return false
    }
    
    //Update GroupInfo Document hereee
    func updateGroupInfoDocument(data : [String :Any]) {
        
        guard let groupID = data["groupId"]  as? String else { return }
        guard let groupType = data["type"] as? Int else { return }
        guard let userID = Utility.getUserid() else {return}
        
        if let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument) {
            if  let document = self.couchbase.getDocumentObject(fromDocID: documentID as! String){
                let maindict = document.properties
                var dict = maindict!["GroupChatsDocument"] as! [String:Any]
                if  let id =  dict[groupID] {
                    let infoDoc = self.couchbase.getDocumentObject(fromDocID: id as! String)
                    let proprtDict = infoDoc?.properties
                    var infoDict = proprtDict!["groupMembersDocId"] as! [String:Any]
                    var tempDict = infoDict
                    
                    var groupmembers = [[String:Any]]()
                    if let groupInfoArr  = infoDict["groupMembersArray"] as? [[String:Any]] {
                        groupmembers = groupInfoArr
                    }else if let memArray = infoDict["groupMembersArray"] as? [Any]{
                        for member in memArray{
                            guard let memData = member as? [String : Any] else{continue}
                            groupmembers.append(memData)
                        }
                    }
                    
                    
                    //Group type - 3 make/remove from Admin
                    if groupType == AppConstants.groupType.makeGroupadmin.rawValue {
                        
                        let memberId = data["memberId"] as! String
                        let index = groupmembers.index(where: { (item) -> Bool in
                            item["memberId"] as! String == memberId
                        })
                        
                        var memDict = groupmembers[index!] as [String:Any]
                        let isAdmin = memDict["memberIsAdmin"] as! Bool
                        memDict["memberIsAdmin"] = !isAdmin
                        groupmembers[index!] = memDict
                        
                        
                        ///////////*Add Tost Messages for remove Mem in Group here*////////////////
                        guard let initiatorIdentifier = data["initiatorIdentifier"] as? String else {return}
                        guard let memberIdIdentifier =  data["memberIdentifier"]  as? String else {return}
                        var messageData = data
                        messageData["type"] = "0"
                        messageData["from"] = groupID
                        messageData["payload"] =  "\(initiatorIdentifier),\(memberIdIdentifier)".toBase64()
                        messageData["gpMessageType"] = "3"
                        self.updateDocumentForMessageReceived(withMessageData: messageData, atTopic: AppConstants.MQTT.groupChats)
                        
                    }
                    
                    //Group type - 1 add member in Group
                    if groupType == AppConstants.groupType.addInGroup.rawValue {
                        
                        let dict = ["memberId":data["memberId"] as! String,
                                    "memberIdentifier": data["memberIdentifier"] as! String,
                                    "memberImage": data["memberImage"] as! String,
                                    "memberIsAdmin": data["memberIsAdmin"] as! Bool,
                                    "memberStatus": data["memberStatus"] as! String,
                                    "userName": data["userName"] as? String ?? ""
                            ] as [String:Any]
                        
                        guard let memID = data["memberId"] as? String else {return}
                        
                        if memID == userID {
                            var tempArr = [[String:Any]]()
                            tempArr.append(dict)
                            //for i in groupmembers {  tempArr.append(i)}
                            
                            let dataArr = data["members"] as! NSArray
                            for i in dataArr {
                                let dict:[String:Any] = i as! [String:Any]
                                let ID = dict["memberId"] as! String
                                if ID == userID {}else {
                                    tempArr.append(dict)
                                }
                            }
                            
                            groupmembers = tempArr
                            tempDict["isActive"] = true
                        }else {
                            groupmembers.append(dict)
                        }
                        
                        ///////////*Add Tost Messages for Add Mem in Group here*////////////////
                        guard let initiatorIdentifier = data["initiatorIdentifier"] as? String else {return}
                        guard let memberIdIdentifier =  data["memberIdentifier"]  as? String else {return}
                        var messageData = data
                        messageData["type"] = "0"
                        messageData["from"] = groupID
                        messageData["payload"] =  "\(initiatorIdentifier),\(memberIdIdentifier)".toBase64()
                        messageData["gpMessageType"] = "1"
                        self.updateDocumentForMessageReceived(withMessageData: messageData, atTopic: AppConstants.MQTT.groupChats)
                        ///////////***************************************************////////////////
                    }
                    
                    
                    //Group type - 2 remove  member in Group
                    if groupType == AppConstants.groupType.removeFromGroup.rawValue {
                        let memberId = data["memberId"] as! String
                        let index = groupmembers.index(where: { (item) -> Bool in
                            item["memberId"] as! String == memberId
                        })
                        
                        if index != nil {groupmembers.remove(at: index!)}
                        
                        if memberId == userID {
                            tempDict["isActive"] = false
                        }
                        
                        ///////////*Add Tost Messages for remove Mem in Group here*////////////////
                        guard let initiatorIdentifier = data["initiatorIdentifier"] as? String else {return}
                        guard let memberIdIdentifier =  data["memberIdentifier"]  as? String else {return}
                        var messageData = data
                        messageData["type"] = "0"
                        messageData["from"] = groupID
                        messageData["payload"] =  "\(initiatorIdentifier),\(memberIdIdentifier)".toBase64()
                        messageData["gpMessageType"] = "2"
                        self.updateDocumentForMessageReceived(withMessageData: messageData, atTopic: AppConstants.MQTT.groupChats)
                        ///////////***************************************************////////////////
                    }
                    
                    //Group type -4 change Group name
                    if groupType == AppConstants.groupType.groupNameChange.rawValue {
                        
                        
                    }
                    
                    //Group type -5 change Group Image
                    if groupType == AppConstants.groupType.groupImagechange.rawValue {
                        
                        
                    }
                    
                    //Group type - 6
                    if groupType == AppConstants.groupType.leaveGroup.rawValue {
                        let memberId = data["initiatorId"] as! String
                        guard let index = groupmembers.index(where: { (item) -> Bool in
                            item["memberId"] as! String == memberId
                        }) else{return}
                        groupmembers.remove(at: index)
                        ///////////*Add Tost Messages for remove Mem in Group here*////////////////
                        guard let initiatorIdentifier = data["initiatorIdentifier"] as? String else {return}
                        var messageData = data
                        messageData["type"] = "0"
                        messageData["from"] = groupID
                        messageData["payload"] =  "\(initiatorIdentifier)".toBase64()
                        messageData["gpMessageType"] = "6"
                        self.updateDocumentForMessageReceived(withMessageData: messageData, atTopic: AppConstants.MQTT.groupChats)
                        ///////////***************************************************////////////////
                    }
                    
                    tempDict["groupMembersArray"] = groupmembers
                    infoDict = tempDict
                    updategroupMembersDocument(documentID: id as! String, newData: infoDict)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateGroupInfoScreen"), object: nil)
                }
            }
        }
    }
    
    func updategroupMembersDocument(documentID:String, newData:[String:Any]){
        if let document = self.couchbase.getDocumentObject(fromDocID: documentID){
            do{
                try document.update{ (newRev) -> Bool in
                    newRev["groupMembersDocId"] = newData
                    return true
                }
            } catch let error {
                print("cdkvndkv\(error)")
            }
        }else {
            print("failed to get documet from provided DocID")
            return
        }
    }
    
    fileprivate func getGroupMessageDetails(withData data : [String :Any]) -> [String : Any]? {
        var type = 0
        
        if let gType = data["type"] as? Int {
            type = gType
        }
        switch type {
        case 1, 2, 3, 6:
//        if (type != 0) && (type != 4) && (type != 5)  {
            updateGroupInfoDocument(data: data)
            return nil
//        } else {
        default:
            var params = data
            
            if let groupID = data["chatId"] as? String {
                params["chatId"] = groupID
            }else {
                params["chatId"] = data["groupId"]
            }
            
            if let groupSubject = data["groupSubject"] as? String{
                params["receiverName"] = groupSubject
            }
            
            if let createdByMemberId = data["createdByMemberId"] as? String {
                if createdByMemberId == selfID {
                    params["isSelf"] = true
                    params["initiated"] = true
                } else {
                    params["isSelf"] = false
                    params["initiated"] = false
                }
            }
            
            
            
            if data["groupImageUrl"] != nil {
                if let image =  data["groupImageUrl"] {
                    params["receiverImage"] = image
                    params["userImage"] = image
                }
            }else {
                if let img = data["profilePic"] {
                    params["receiverImage"] = img
                    params["userImage"] = img
                }
            }
            
            
            params["to"] = selfID
            if data["messageType"] != nil {
                params["messageType"] = 0
                params["type"] = 0
            }else {
                params["messageType"] = data["type"]
                params["type"] = data["type"]
                
            }
            
            if data["number"] != nil {
                params["number"] = data["number"]
            }else {
                params["number"] = data["initiatorIdentifier"]
            }
            
            params["deliveryStatus"] = "0"
            params["secretId"] = ""
            params["newMessage"] = ""
            params["payload"] = ""
            params["dTime"] = -1
            
            var tStamp = ""
            
            if data["createdAt"] != nil{
                if let timeStamp = data["createdAt"] as? intmax_t {
                    params["lastMessageDate"] = "\(timeStamp)"
                    tStamp = "\(timeStamp)"
                }
                else if let timeStamp = data["createdAt"] as? String {
                    params["lastMessageDate"] = timeStamp
                    tStamp = timeStamp
                }
            }
            
            
            if data["timestamp"] != nil{
                
                if let timeStamp = data["timestamp"] as? intmax_t {
                    params["lastMessageDate"] = "\(timeStamp)"
                    tStamp = "\(timeStamp)"
                }
                else if let timeStamp = data["timestamp"] as? String {
                    params["lastMessageDate"] = timeStamp
                    tStamp = timeStamp
                }
            }
            
            if data["id"] != nil {
                if let timeStamp = data["id"] as? intmax_t {
                    params["lastMessageDate"] = "\(timeStamp)"
                    tStamp = "\(timeStamp)"
                }
                else if let timeStamp = data["id"] as? String {
                    params["lastMessageDate"] = timeStamp
                    tStamp = timeStamp
                }
                
            }
            
            let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: tStamp)
            params["newMessageTime"] = DateExtension().lastMessageInHours(date: lastmsgDate)
            params["newMessageDateInString"] = DateExtension().getDateString(fromTimeStamp: tStamp)
            params["timestamp"] = tStamp
            params["totalUnread"] = 0

            params["hasNewMessage"] = false
            params["newMessageCount"] = "0"
            
            if let groupSub = data["groupSubject"] as? String {
                params["groupName"] = groupSub
            }
            
            ///for group chat
            if  let groupChatInitiatorId = data["initiatorId"] as? String, let groupChatInitiatorIdentifier = data["initiatorIdentifier"] as? String {
                params["isGroupChat"] = true
                params["initiatorId"] = groupChatInitiatorId
                params["initiatorIdentifier"] = groupChatInitiatorIdentifier
                
                if let groupID = data["chatId"] as? String {
                    params["from"] = groupID
                }else {
                    params["from"] = data["groupId"]
                }
                
                // params["from"] = data["groupId"]
                
            }else {
                
                params["isGroupChat"] = true
                params["initiatorId"] = data["receiverId"]
                params["initiatorIdentifier"] = params["number"]
                params["from"] = params["chatId"]
                
            }
            
            
            if type == 4 {
                ///////////*Change group Name here*////////////////
                if let num1 = data["initiatorIdentifier"] as? String , let name = data["groupSubject"] as? String{
                    let tostMsg = "\(num1),\(name)"
                    var messageData = data
                    messageData["type"] = "0"
                    messageData["from"] = data["groupId"]
                    messageData["payload"] = tostMsg.toBase64()
                    messageData["gpMessageType"] = "4"
                    self.updateDocumentForMessageReceived(withMessageData: messageData, atTopic: AppConstants.MQTT.groupChats)
                }
            }else if type == 5 {
                ///////////*Change group icon here*////////////////
                if let num1 = data["initiatorIdentifier"] as? String{
                    let tostMsg = "\(num1)"
                    var messageData = data
                    messageData["type"] = "0"
                    messageData["from"] = data["groupId"]
                    messageData["payload"] = tostMsg.toBase64()
                    messageData["gpMessageType"] = "5"
                    self.updateDocumentForMessageReceived(withMessageData: messageData, atTopic: AppConstants.MQTT.groupChats)
                }
            }
            
            
            return params
        }
    }
    
    /// Used for getting the message Object for storing into database
    ///
    /// - Parameter data: message object dictionary
    /// - Returns: modified message objcet dictionary
    fileprivate func getMessageObj(withData data : [String :Any]) -> [String : Any]? {
        if let isInitiated = data["initiated"] as? Bool {
            var params = [String : Any]()
            var unreadNum = 0
            params["chatId"] = data["chatId"]
            params["dataSize"] = "0"
            params["mediaState"] = 0
            params["from"] = data["recipientId"]
            params["initiated"] = data["initiated"]
            params["isSelf"] = isInitiated
            params["receiverName"] = data["userName"]
            params["receiverImage"] = data["profilePic"]
            params["receiverId"] = data["receiverId"]
            params["recipientId"] = data["recipientId"]
            params["senderId"] = data["senderId"]
            params["to"] = selfID
            params["type"] = data["messageType"]
            params["messageType"] = data["messageType"]
            params["userImage"] = data["profilePic"]
            params["number"] = data["number"]
            
            if let isStar = data["isStar"] as? Int{
                
                params["isStar"] = isStar
            }
            
            params["deliveryStatus"] = "0"
            if let status = data["status"] as? Int {
                params["deliveryStatus"] = "\(status)"
            } else if let status = data["status"] as? String {
                params["deliveryStatus"] = status
            }
            
            if let secretID = data["secretId"] as? String {
                params["secretId"] = secretID
            } else {
                params["secretId"] = ""
            }
            if let msg = data["payload"] as? String, let dTime = data["dTime"] { // For Group Chat
                if let decodedMsg = msg.fromBase64() {
                    params["newMessage"] = decodedMsg
                    params["payload"] = decodedMsg
                }
                params["dTime"] = dTime
            } else {
                params["newMessage"] = ""
                params["payload"] = ""
                params["dTime"] = -1
            }
            
            var tStamp = ""
            if let timeStamp = data["timestamp"] as? intmax_t {
                tStamp = "\(timeStamp)"
            }
            else if let timeStamp = data["timestamp"] as? String {
                tStamp = timeStamp
            }
            let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: tStamp)
            params["newMessageTime"] = DateExtension().lastMessageInHours(date: lastmsgDate)
            params["newMessageDateInString"] = DateExtension().getDateString(fromTimeStamp: tStamp)
            params["lastMessageDate"] = data["messageId"]
            params["timestamp"] = tStamp
            
            if let totalUnread = data["totalUnread"] as? String {
                unreadNum = Int(totalUnread)!
            }
            else if let totalUnread = data["totalUnread"] as? Int {
                unreadNum = totalUnread
            }
            if unreadNum > 0 {
                params["hasNewMessage"] = true
            } else {
                params["hasNewMessage"] = false
            }
            params["newMessageCount"] = "\(unreadNum)"
            
            ///for group chat
            if let isGroupChat = data["groupChat"] as? Bool, let groupSubject = data["groupSubject"] as? String, let groupChatInitiatorId = data["initiatorId"] as? String, let groupChatInitiatorIdentifier = data["initiatorIdentifier"] as? String {
                params["isGroupChat"] = isGroupChat
                params["groupName"] = groupSubject
                params["initiatorId"] = groupChatInitiatorId
                params["initiatorIdentifier"] = groupChatInitiatorIdentifier
                if isGroupChat {
                    params["from"] = data["chatId"]
                }
            }
            return params
        }
        return nil
    }
    
    func sendMessageDeliveredStatus(withData data : [String : Any], withDocID docID: String) {
        guard let params = self.getMessageObjectForUpdatingStatus(withData: data, andStatus: "2", toDocID: docID) as? [String:Any] else { return }
        let ackreceiverID = params["to"] as! String
        MQTTChatManager.sharedInstance.sendAcknowledgment(toChannel: "\(AppConstants.MQTT.acknowledgementTopicName)\(ackreceiverID)", withMessage: params, withQOS: .atMostOnce)
    }
    
    func updateDocumentForMessageReceived(withMessageData data: [String : Any], atTopic topic : String) {
            var messageObj = data
            messageObj["deliveryStatus"] = "1"
    //        guard let toID = data["to"] as? String else { return }
    //        messageObj["isSelf"] = selfID! == toID ? false : true
            let timeStamp = Int64(floor(Date().timeIntervalSince1970 * 1000))
            messageObj["timestamp"] = "\(timeStamp)"
        
        /*
         Bug Name :- show user payments in chat
         Fix Date :- 03/06/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Handled mqtt data
         */
        var type:String = ""
        if let typeObj = messageObj["type"] as? String {
            type = typeObj
        }
        if let msgType = messageObj["messageType"] as? String {
            type = msgType
        }
            if let msg =  messageObj["payload"] as? String{
                
                //commenting call logs for now
//                if let msgType = type, msgType != "15", msgType != "16", msgType != "17"{
                if let msgType = type as? String, msgType != "15", msgType != "16", msgType != "17"{
                    guard let message = msg.fromBase64() else {return}
                    /*
                     Bug Name :- Secret chat not showing when intiating
                     Fix Date :- 01/12/2021
                     Fixed By :- Jayaram G
                     Description Of Fix :- not returning when payload empty and is secret chat
                     */
                    if message.count == 0{
                        if let secretId = messageObj["secretId"] as? String, secretId != "" {

                        }else{
                            return
                        }
                        
                    }
                }else {
                    /*
                     Bug Name :- show user payments in chat
                     Fix Date :- 03/06/2021
                     Fixed By :- Jayaram G
                     Description Of Fix :- Handled mqtt data
                     */
                    if let msgType = type as? String {
                        if msgType == "16" {
                            MQTTManager.shared.newMessage(FromMQTT: (messageObj), onTopic: topic)
                        }
                    }
                }
            }else {
                return
            }
            
        /*
         Bug Name :- show user payments in chat
         Fix Date :- 03/06/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Handled mqtt data
         */
            //check if secrect Chat Msg Tag then add tag
        if ( messageObj["dTime"] != nil && messageObj["secretId"] != nil && type != "15"/* && type! != "16" && type! != "17"*/){
                guard let msg =  messageObj["payload"] as? String else { return }
                if messageObj["dTime"] as? Int == -1 {
                    messageObj["dTime"] = 0
                }
                guard let dTime = messageObj["dTime"] as? Int else {return}
                
                guard let secretId = messageObj["secretId"] as? String else {return}
                if msg == ""  {
                    messageObj["payload"] =  (messageObj["receiverIdentifier"] as! String).toBase64()
                    messageObj["gpMessageType"] = "7"
                    UserDefaults.standard.set(dTime, forKey: secretId)
                }
        }
            let individualChatDocVMObject = IndividualChatViewModel(couchbase: couchbase)
            if let chatDocID = individualChatDocVMObject.updateIndividualChatDoc(withMsgObj: messageObj, toDocID: nil, isForCreatingChat: false) {
                self.sendMessageDeliveredStatus(withData: messageObj, withDocID: chatDocID)
            }
            let name = NSNotification.Name(rawValue: "MessageNotification" + selfID!)
            NotificationCenter.default.post(name: name, object: self, userInfo: ["message": messageObj, "status":"0"])
        }
    
    /// Used to get message object array as respect to the passed data.
    ///
    /// - Parameter messageData: data for the current message.
    /// - Returns: Array of Object with containg all the data of messages.
    func getMessageObject(fromData data: [String:Any], withStatus status: String, isSelf : Bool,fileSize : Double, documentData : [String : Any]?, isReplying : Bool, replyingMsgObj : Message?) -> [String:Any]? {
        guard let messageType = data["type"] as? String, let payload = data["payload"], let from = data["from"], let timeStamp = data["timestamp"], let id = data["id"], let to = data["to"] else { return nil }
        var params = [String : Any]()
        if let docData = documentData {
            params = docData
        }
        params["message"] = payload as Any
        params["messageType"] = messageType as Any
        params["isSelf"] = isSelf as Any
        params["from"] = from as Any
        params["to"] = to as Any
        params["timestamp"] = timeStamp as Any
        params["deliveryStatus"] = status as Any
        params["id"] = id as Any
        params["mediaState"] = 0 as Any
        params["dataSize"] = fileSize as Any
        params["thumbnailPath"] = "" as Any
        params["thumbnail"] = data["thumbnail"]
        
        if data["secretId"] != nil{
            if let sectId = data["secretId"] as? String {
                params["secretId"] = sectId
            }
        }
        
        if data["dTime"] != nil{
            if let sectId = data["dTime"] as? Int {
                params["dTime"] = sectId
            }
        }

        if let postId = data["postId"] as? String{
            params["postId"] = postId
        }
        if let postTitle = data["postTitle"] as? String{
            params["postTitle"] = postTitle
        }
        if let post = data["postType"] as? Int{
            params["postType"] = post
        }
        
        
        if isReplying == true, let replyMsg = replyingMsgObj {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = data["previousType"] as? String, let replyType = data["replyType"] {
                params["previousPayload"] = pPload.toBase64() as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = replyType as Any
                params["messageType"] = "10" as Any
                params["previousReceiverIdentifier"] = prIdentifier as Any
                params["previousId"] = msgId as Any
                params["previousType"] = previousType
//                params["previousType"] = settingPreviousTypeParams(messageType: previousType)
                
                if previousType == "1"  || previousType == "2" || previousType == "7" || previousType == "13" {
                    if let tData = replyMsg.thumbnailData {
                        params["previousPayload"] = tData
                    }
                } else if previousType == "3" {
                    params["previousPayload"] = "Location"
                }
                else if previousType == "10" {
                    if let pType = replyMsg.repliedMessage?.replyMessageType {
//                        params["previousType"] = "\(pType.hashValue)" as Any
                    params["previousType"] = settingPreviousTypeParams(messageType: pType)
                    }
                    if let repliedMsg = replyingMsgObj?.repliedMessage {
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
        return params
    }
    
    func updateChatDoc(withMsgObj msgObject : Any,toDocID docID : String) {
        var chatData = couchbase.getData(fromDocID: docID)!
        var msgArray:[Any] = chatData["messageArray"] as! [Any]
        if checkMsgExistOrNot(withMessage: msgObject, andMessageArray: msgArray) {
            msgArray.append(msgObject)
            chatData["messageArray"] = msgArray
            DispatchQueue.main.async {
                self.couchbase.updateData(data: chatData, toDocID: docID)
            }
        }
    }
    
    func clearMessagesInChatDoc(toDocID docId: String?){
        guard let docID = docId  else {return}
        if docID.count == 0 {return}
        var chatData = couchbase.getData(fromDocID: docID)!
        
        chatData["messageArray"] = []
        chatData["newMessage"] = ""
        chatData["newMessageTime"] = ""
        chatData["deliveryStatus"] = "0"
        chatData["newMessageCount"] = "0"
        self.couchbase.updateData(data: chatData, toDocID: docID)
    }
    
    func updateUserBlockStatus(toDocID docId: String , isBlock : Bool){
        var chatData = couchbase.getData(fromDocID: docId)!
        chatData["isUserBlocked"]  = isBlock
        self.couchbase.updateData(data: chatData, toDocID: docId)
    }
    
    func updateGroupDoc(withName name : String, toDocID docID : String) {
        var chatData = couchbase.getData(fromDocID: docID)!
        chatData["groupName"]  = name
        //  DispatchQueue.main.async {
        self.couchbase.updateData(data: chatData, toDocID: docID)
        // }
    }
    
    
    func removeMessageFromDatabaseWithIndexId(index : Int ,docID: String) {
        var chatData = couchbase.getData(fromDocID: docID)
        if var  msgArray = chatData!["messageArray"] as? [Any] {
            msgArray.remove(at: index)
            chatData!["messageArray"] = msgArray
            // DispatchQueue.main.async {
            self.couchbase.updateData(data: chatData!, toDocID: docID)
            //}
        }
    }
    
    func updateGroupImage(withGpimage image: String , toDocID docID: String ){
        var chatData = couchbase.getData(fromDocID: docID)!
        chatData["receiverImage"]  = image
        chatData["userImage"]  = image
        
        // DispatchQueue.main.async {
        self.couchbase.updateData(data: chatData, toDocID: docID)
        // }
    }
    
    
    private func checkMsgExistOrNot(withMessage message : Any, andMessageArray msgArray : [Any]) -> Bool{
        guard let currentMsgObj = message as? [String : Any] else { return false }
        for msgObj in msgArray {
            guard let msg  = msgObj as? [String : Any] else { return false }
            if currentMsgObj["id"] as? String == msg["id"] as? String {
                return false
            }
        }
        return true
    }
    
    func updateDocumentForMessageDelivered(withMessageData data: [String : Any])  {
        self.updateDoc(withData: data)
        guard let userId = self.selfID else{return}
        var name = NSNotification.Name(rawValue: "MessageNotification" + userId)
        NotificationCenter.default.post(name: name, object: self, userInfo: ["message": data, "status":"2"])
        name = NSNotification.Name(rawValue: "ChatUpdatedNotification")
        NotificationCenter.default.post(name: name, object: self, userInfo: nil)
    }
    
    func updateDocumentForMessageRead(withMessageData data: [String : Any])  {
        self.updateDoc(withData: data)
        guard let userId = self.selfID else{return}
        var name = NSNotification.Name(rawValue: "MessageNotification" + userId)
        NotificationCenter.default.post(name: name, object: self, userInfo: ["message": data, "status":"3"])
        name = NSNotification.Name(rawValue: "ChatUpdatedNotification")
        NotificationCenter.default.post(name: name, object: self, userInfo: nil)
    }
    
    func updateDoc(withData data : Any) { //update chat doc with data
        guard let ackObj = data as? [String:Any] else { return }
        var msgData = ackObj
        let deliveryStatus = ackObj["status"] as! String
        msgData["deliveryStatus"] = deliveryStatus
        if deliveryStatus == "2", let delTime = ackObj["deliveryTime"] as? Double{
            msgData["deliveryTime"] = delTime
        }else if let readTm = ackObj["readTime"] as? Double{
            msgData["readTime"] = readTm
        }
        msgData["isSelf"] = false
        self.updateMessageStatus(withMessageObj: msgData)
    }
    
    // Used for updating messages for acknowladgment received from server
    func updateMessageStatus(withMessageObj messageObj : [String:Any]) {
        guard let docID = messageObj["doc_id"] as? String else { return }
        if docID == ""{
            return
        }
        guard let chatDta = couchbase.getData(fromDocID: docID) else { return }
        var chatData = chatDta
        guard var msgArray = chatData["messageArray"] as? [[String:Any]] else {return}
        
        guard let msgIDArray = messageObj["msgIds"] as? [String] else { return }
        guard let index:Int = msgArray.index(where: {($0["id"] as? String) == msgIDArray[0]}) else { return }
        
        var msgObj = msgArray[index]
        var status = "0"
        var readTime: Double = 0.0
        var deliveryTime: Double = 0.0
        if let sta = msgObj["deliveryStatus"] as? String{
            status = sta
        }else if let sta = msgObj["deliveryStatus"] as? Int{
            status = "\(sta)"
        }
        if let time = messageObj["readTime"] as? Double{
            readTime = time
        }else if let time = msgObj["readTime"] as? Double{
            readTime = time
        }
        if let time = messageObj["deliveryTime"] as? Double{
            deliveryTime = time
        }else if let time = msgObj["deliveryTime"] as? Double{
            deliveryTime = time
        }
        msgObj["deliveryStatus"] = messageObj["deliveryStatus"]
        if status == "3" {
            msgObj["deliveryStatus"] = "3"
        }
        msgObj["readTime"] = readTime
        msgObj["deliveryTime"] = deliveryTime
        msgArray[index] = msgObj
        chatData["messageArray"] = msgArray
        
        
        ////do Recursion here ..for tick check last tick read or not if not update it
        if msgArray.count > 0 {
            if msgArray.last!["id"] as? String == msgObj["id"] as? String {
                if let lastStatus = msgArray.last!["deliveryStatus"] as? String {
                    if lastStatus == "3" {
                        let newMSgArrr = msgArray.map({ msg -> [String:Any] in
                            var  msg1 = msg
                            if msg["deliveryStatus"] as? String != "3" {
                                msg1["deliveryStatus"] = "3"
                                //check Read status if not then start timer for privious messages
                                if msg1["secretId"] != nil && msg1["dTime"] != nil {
                                    if ((msg1["secretId"]  as? String) != "" ) && (msg1["deliveryStatus"] as? String == "3") && ((msg1["dTime"] as? Int) !=  0 && (msg1["gpMessageType"] as? String == ""  || msg1["gpMessageType"] == nil ) ) {
                                        print("hello im secret chat message read status do stuff for me")
                                        var dTimee = 0
                                        if let dTime = msg1["dTime"] as? Int {
                                            dTimee = dTime
                                        }
                                        secretChatTimer(docID:docID , messageID: msg["id"] as! String, dTime:dTimee)
                                    }
                                }
                                return msg1
                            }
                            return msg1
                        })
                        chatData["messageArray"] = newMSgArrr
                    }
                }
            }
        }
        
        //Do Stuff For SecretChat
        if msgObj["secretId"] != nil && msgObj["dTime"] != nil {
            if ((msgObj["secretId"]  as? String) != "" ) && (msgObj["deliveryStatus"] as? String == "3") && ((msgObj["dTime"] as? Int) !=  0 && (msgObj["gpMessageType"] as? String == ""  || msgObj["gpMessageType"] == nil ) ) {
                print("hello im secret chat message read status do stuff for me")
                var dTimee = 0
                if let dTime = msgObj["dTime"] as? Int {
                    dTimee = dTime
                }
                secretChatTimer(docID:docID , messageID: msgIDArray[0], dTime:dTimee)
            }
        }
        
        
        DispatchQueue.main.async {
            self.couchbase.updateData(data: chatData, toDocID: docID)
        }
        
    }
    
    
    func secretChatTimer(docID: String , messageID: String, dTime : Int){
        
        /*
         Bug Name:- secret chat messages are deleting
         Fix Date:- 23nd Feb 2022
         Fixed By:- Jayram G
         Description of Fix:- delete message if dTime more than 0 time
         */
        
        if dTime > 0 {
            let addTime:DispatchTimeInterval = .seconds(dTime)
            let dispatchQue = DispatchQueue(label: messageID + " " + docID )
            dispatchQue.asyncAfter(deadline: DispatchTime.now() + addTime , execute: {
                print("helloooo frds chai pee lo \(addTime) message Time = \(dispatchQue.label)")
                DispatchQueue.main.async {
                    
                    let arr = dispatchQue.label.components(separatedBy: " ")
                    let docID = arr[1]
                    let messID = arr[0]
                    self.deletePerticularMessageInDataBase(messageID: messID, docID: docID)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MessageNotification" + self.selfID!), object: self, userInfo: ["messID": messID,"docID": docID , "isDelete":true])
                }
                
            })
        }
    }
    
    
    func deletePerticularMessageInDataBase (messageID: String ,docID : String){
        
        
        guard let chatDta = couchbase.getData(fromDocID: docID) else { return }
        var chatData = chatDta
        var msgArray = chatData["messageArray"] as! [[String:Any]]
        
        
        let mediaMessages = msgArray.filter({
            if  $0["id"] as? String == messageID {
                
                if let index:Int = msgArray.index(where: {($0["id"] as? String) == messageID}) {
                    print("im in filter methode  delete this   index \(String(describing: index))")
                    msgArray.remove(at: index)
                    chatData["messageArray"] = msgArray
                    // DispatchQueue.main.async {
                    
                    self.couchbase.updateData(data: chatData, toDocID: docID)
                    // }
                }
            }
            return true
        })
    }
    
    
    
    func updateMessageForDeletion(withMessageObj messageObj : [String:Any], andDocID docID: String?) {
        guard let docID = docID else { return }
        guard let chatDta = couchbase.getData(fromDocID: docID) else { return }
        var chatData = chatDta
        guard let id = messageObj["id"] as? String else { return }
        guard var msgArray = chatData["messageArray"] as? [[String:Any]] else { return }
        guard let index:Int = msgArray.index(where: {
            ($0["id"] as? String) == id
        }) else { return }
        var msgObj = msgArray[index]
        msgObj["type"] = "11"
        msgArray[index] = msgObj
        chatData["messageArray"] = msgArray
        couchbase.updateData(data: chatData, toDocID: docID)
    }
    
    func getChats() -> [Chat]? {
        var chats : [Chat]?
        guard let chatsObj = self.getChatsFromCouchbase() else { return nil }
        let chatObj = chatsObj.uniq()
        chats = chatObj.sorted {
            let uniqueID1 = $0.lastMessageDate, uniqueID2 = $1.lastMessageDate
            return uniqueID1 < uniqueID2
        }
        return chats
    }
    
    func getChatsFromCouchbase() -> [Chat]? {
        let indexDocVMObj = IndexDocumentViewModel(couchbase: couchbase)
        guard let userID = Utility.getUserid() else { return [] }
        guard let indexID = indexDocVMObj.getIndexValue(withUserSignedIn: true) else { return [] }
        guard let indexData = couchbase.getData(fromDocID: indexID) else { return []  }
        guard let userIDArray = indexData["userIDArray"] as? [String] else { return []  }
        if userIDArray.contains(userID) {
            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return []  }
            if let index = userIDArray.index(of: userID) {
                let userDocID = userDocArray[index]
                guard let userDocData = couchbase.getData(fromDocID: userDocID) else { return []  }
                if let chatDocID = userDocData["chatDocument"] as? String {
                    guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return []  }
                    guard let chatUserIDArray = chatData["receiverUidArray"] as? [String] else { return []  }
                    guard let chatDocIDArray = chatData["receiverDocIdArray"] as? [String] else { return []  }
                    guard let chatSecretIDArray = chatData["secretIdArray"] as? [String] else { return []  }
                    if chatUserIDArray.count>0 {
                        let chatObjArray = self.getChatObjects(fromreceiverDocIDArray: chatDocIDArray, withreceiverUIDArray: chatUserIDArray, secretIDArray: chatSecretIDArray)
                        return chatObjArray
                    } else {
                        return []
                    }
                }
            }
        }
        return []
    }
    
    fileprivate func getChatObject(fromreceiverDocID docID: String, withchatUserID chatUserID : String, secretID : String ) -> Chat? {
        guard let chatData = couchbase.getData(fromDocID: docID) else { return nil }
        var groupName = "", initiatorIdentifier = "", number = "", isSelfChat = false, isGroupChat = false, secretInviteVisibility = false, initiatorId = ""
        if let gName = chatData["groupName"] as? String, let initatorIdentifier = chatData["initiatorIdentifier"] as? String, let usrNumber = chatData["number"] as? String, let isSelf = chatData["isSelf"] as? Bool, let isGroupchat = chatData["isGroupChat"] as? Bool, let isSecretVisible =  chatData["secretInviteVisibility"] as? Bool, let initiatorID = chatData["initiatorId"] as? String {
            groupName = gName
            initiatorIdentifier = initatorIdentifier
            number = usrNumber
            isSelfChat = isSelf
            isGroupChat = isGroupchat
            secretInviteVisibility = isSecretVisible
            initiatorId = initiatorID
        }
        
        var secretId = secretID
        if secretID == (chatData["secretId"] as? String) {
            secretId = secretID
        } else if (chatData["secretId"] as? String) != nil {
            print("Secret ID mismatched please debug here : ChatsDocumentViewModel line 546")
        }
        
        var name = "", image = ""
        if let receiverName = chatData["receiverName"] as? String {
            name = receiverName
        }
        if let userImage = chatData["receiverImage"] as? String {
            image = userImage
        }
        
        var isUserBlocked = false
        if let isUserBlock = chatData["isUserBlocked"] as? Bool {
            isUserBlocked = isUserBlock
        }
        var gpMessageType = ""
        if let gpMessageTypeObj = chatData["gpMessageType"] as? String {
            gpMessageType = gpMessageTypeObj
        }
        if let contactObj = FavoriteViewModel.sharedInstance.getContactObject(forUserID: chatUserID) {
//            if let contactName = contactObj.fullName {
//                name = contactName
//            } else {
//                name = number
//            }
            if let userImage = contactObj.profilePic {
                image = userImage
            }
        } else {
            
            if name.count == 0 && number != "" {
                name = number
            }
        }
            var isStar = 0
            if let starStatus = chatData["isStar"] as? Int {
                isStar = starStatus
            }
        
        if let lastMsg = chatData["newMessage"] as? String, let lastMsgTime = chatData["newMessageTime"] as? String, let newMessageDateInString = chatData["newMessageDateInString"] as? String, let lastMessageDate = chatData["lastMessageDate"] as? String, let msgCount = chatData["newMessageCount"] as? String, let hasNewMessage = chatData["hasNewMessage"] as? Bool, var chatID = chatData["chatId"] as? String, let destructionTime = chatData["dTime"] as? Int, let wasInvited = chatData["wasInvited"] as? Bool ,let msgType = chatData["messageType"] as? String {
            
            if isGroupChat == true {
                if let chtId = chatData["chatId"] as? String {
                    chatID = chtId
                }
            }
            print("receiverName \(name)")
            let chat = Chat(messageArray: [], hasNewMessage: hasNewMessage, newMessage: lastMsg, newMessageTime: lastMsgTime, newMessageDateInString: newMessageDateInString, newMessageCount: msgCount, lastMessageDate: lastMessageDate, receiverUIDArray: [], receiverDocIDArray: [], name: name, image: image, secretID: secretId, userID: chatUserID, docID: docID, wasInvited: wasInvited, destructionTime: destructionTime, isSecretInviteVisible: secretInviteVisibility, chatID: chatID, groupName : groupName, initiatorIdentifier: initiatorIdentifier, number : number, isSelfChat : isSelfChat, isGroupChat: isGroupChat, initiatorId : initiatorId, lastMessageType: msgType, isUserblock: isUserBlocked, gpMessagetype: gpMessageType, isStar: isStar)
            return chat
        }
        return nil
    }
    
    func getChatObj(fromChatDocID chatDocID : String) -> Chat? {
        guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return nil }
        guard let chatUserID = chatData["receiverID"] as? String, let secretID = chatData["secretId"] as? String else { return nil }
        guard let chatObj = self.getChatObject(fromreceiverDocID: chatDocID, withchatUserID: chatUserID, secretID: secretID) else { return nil }
        return chatObj
    }
    
    fileprivate func getChatObjects(fromreceiverDocIDArray docIDArray: [String], withreceiverUIDArray receiverUIDArray : [String],secretIDArray : [String] ) -> [Chat] {
        var chats = [Chat]()
        for chatDocID in docIDArray {
            let chatDocID = chatDocID
            guard let index = docIDArray.index(of: chatDocID) else { return [] }
            let chatUserID = receiverUIDArray[index]
            let secretID = secretIDArray[index]
            if let chatObj = self.getChatObject(fromreceiverDocID: chatDocID, withchatUserID: chatUserID, secretID: secretID) {
                chats.append(chatObj)
            }
        }
        return chats
    }
    
    func getMessageObjectForUpdatingStatus(withData data : [String : Any], andStatus status: String, toDocID : String) -> Any? {
        guard var toID = data["from"] as? String, let msgIDs = data["id"] as? String, var fromID = data["to"] as? String, let selfID =  self.selfID else { return nil }
        
        if toID == selfID {
            toID = fromID
            fromID = selfID
        }
        
        var docId = ""
        if let docID = data["toDocId"] as? String {
            docId = docID
        } else {
            docId = toDocID
        }
        var params =
            ["from":fromID, //user ID of the sender
                "msgIds":[msgIDs], //array containing the individual message ids to be acknowladged in string.
                "doc_id":docId, // sender's docID which is received in the message
                "to":toID, // userID of the sender for whom the acknowledgement is to be sent.
                "status":status] //2 or 3 for message delivered and read respectively.
                as [String : Any]
        if status == "2"{
            params["deliveryTime"] = (NSDate().timeIntervalSince1970 * 1000).rounded()
        }else if status == "3"{
            params["readTime"] = (NSDate().timeIntervalSince1970 * 1000).rounded()
        }
        return params as Any
    }
    
    /// get messages from chatdocID
    ///
    /// - Parameter chatDocID: chatDocID
    /// - Returns: Array of message models
    func getMessagesFromChatDoc(withChatDocID chatDocID: String) -> [Message]{
        var messages = [Message]()
        if let docData = couchbase.getData(fromDocID: chatDocID) {
            if let msgArray = docData["messageArray"] as? [Any] {
                for msgObj in msgArray {
                    if let messageObj = msgObj as? [String: Any] {
                        var mediaState:MediaStates = .notApplicable
                        if let mState = messageObj["mediaState"] as? Int {
                            if let currentState = MediaStates(rawValue: mState) {
                                mediaState = currentState
                            }
                        }
                        
                        var thumbnailData:String!
                        if let tData = messageObj["thumbnail"] as? String {
                            thumbnailData = tData
                        }
                        
                        var secretID  = ""
                        if let secretId = messageObj["secretId"] as? String {
                            secretID = secretId
                        }
                        
                        var msgtype = "", message = ""
                        if let msg = messageObj["payload"] as? String {
                            message = msg
                        }
                        if let type = messageObj["type"] as? String{
                            msgtype = type
                            
                        } else if let type = messageObj["messageType"] as? String, let msg = messageObj["message"] as? String {
                            msgtype = type
                            message = msg
                        }
                        
                        var mediaURL = ""
                        if let mURL =  messageObj["mediaURL"] as? String {
                            mediaURL = mURL
                        }
                        
                        var rIdentifier = ""
                        if let recieverIdentifier = messageObj["receiverIdentifier"] as? String {
                            rIdentifier = recieverIdentifier
                        }
                        
                        var isReplying = false
                        if msgtype == "10" {
                            isReplying = true
                        }
                        
                        var dTime = 0
                        if let ddtime = messageObj["dTime"] as? Int {
                            dTime = ddtime
                        }
                        
                        var gpMessageType = ""
                        if let gpMessageTyp = messageObj["gpMessageType"] as? String{
                            gpMessageType = gpMessageTyp
                        }
                        var readTime = 0.0
                        var deliveryTime = 0.0
                        if let readTm = messageObj["readTime"] as? Double{
                            readTime = readTm
                        }
                        if let deliveryTm = messageObj["deliveryTime"] as? Double{
                            deliveryTime = deliveryTm
                        }
                        if (message.count == 0 && gpMessageType == "0") {
                        }
                        else {
                            if let isSelf = messageObj["isSelf"] as? Bool {
                                let mesageObj = Message(forData: messageObj, withDocID: chatDocID, andMessageobj: messageObj, isSelfMessage: isSelf, mediaStates: mediaState, mediaURL: mediaURL, thumbnailData: thumbnailData, secretID: secretID, receiverIdentifier: rIdentifier, messageData: messageObj, isReplied: isReplying ,gpMessageType: gpMessageType,dTime:dTime, readTime: readTime, deliveryTime: deliveryTime)
                                messages.append(mesageObj)
                            }
                        }
                    }
                }
            }
        }
        return self.removeDuplicates(messages)
    }
    
    
    func getMdccddvvdvChatDoc(withChatDocID docData: [String:Any],chatDocID : String) -> [Message]{
        var messages = [Message]()
        
        if let msgArray = docData["messageArray"] as? [Any] {
            for msgObj in msgArray {
                if let messageObj = msgObj as? [String: Any] {
                    var mediaState:MediaStates = .notApplicable
                    if let mState = messageObj["mediaState"] as? Int {
                        if let currentState = MediaStates(rawValue: mState) {
                            mediaState = currentState
                        }
                    }
                    
                    var thumbnailData:String!
                    if let tData = messageObj["thumbnail"] as? String {
                        thumbnailData = tData
                    }
                    
                    var secretID  = ""
                    if let secretId = messageObj["secretId"] as? String {
                        secretID = secretId
                    }
                    
                    var msgtype = "", message = ""
                    if let type = messageObj["type"] as? String, let msg = messageObj["payload"] as? String {
                        msgtype = type
                        message = msg
                    } else if let type = messageObj["messageType"] as? String, let msg = messageObj["message"] as? String {
                        msgtype = type
                        message = msg
                    }
                    
                    var mediaURL = ""
                    if let mURL =  messageObj["mediaURL"] as? String {
                        mediaURL = mURL
                    }
                    
                    var rIdentifier = ""
                    if let recieverIdentifier = messageObj["receiverIdentifier"] as? String {
                        rIdentifier = recieverIdentifier
                    }
                    
                    var isReplying = false
                    if msgtype == "10" {
                        isReplying = true
                    }
                    
                    var gpMessageType = ""
                    if let gpMessageTyp = messageObj["gpMessageType"] as? String{
                        gpMessageType = gpMessageTyp
                    }
                    var readTime = 0.0
                    var deliveryTime = 0.0
                    if let readTm = messageObj["readTime"] as? Double{
                        readTime = readTm
                    }
                    if let deliveryTm = messageObj["deliveryTime"] as? Double{
                        deliveryTime = deliveryTm
                    }
                    
                    if (message.count == 0 && msgtype == "0") {
                    } else {
                        if let isSelf = messageObj["isSelf"] as? Bool {
                            let mesageObj = Message(forData: messageObj, withDocID: chatDocID, andMessageobj: messageObj, isSelfMessage: isSelf, mediaStates: mediaState, mediaURL: mediaURL, thumbnailData: thumbnailData, secretID: secretID, receiverIdentifier: rIdentifier, messageData: messageObj, isReplied: isReplying,gpMessageType:gpMessageType, readTime: readTime, deliveryTime: deliveryTime)
                            messages.append(mesageObj)
                        }
                    }
                }
            }
        }
        return messages
    }
    
    
    
    
    func removeDuplicates(_ arrayOfDicts: [Message]) -> [Message] {
        var removeDuplicates = [Message]()
        var arrOfDict = [String]()
        print("duplicates Count \(arrayOfDicts.count)")
        for dict in arrayOfDicts {
            if let name = dict.messageIdObj, !arrOfDict.contains(name) {
            removeDuplicates.append(dict)
            arrOfDict.append(name)
        }
        }
        return removeDuplicates
        }

    
    
    
    
    
    
    
    /// For Updating the status for the perticular message.
    ///
    /// - Parameters:
    ///   - inChatDocID: Chat document ID where you want to update the data.
    ///   - message: Message object with all the data.
    func updateMediaStatesForMessage(inChatDocID chatDocID: String, withMessage message: Message) {
        guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return }
        let messageID = message.uniquemessageId
        var chatDta = chatData
        var msgArray = chatDta["messageArray"] as! [[String:Any]]
        for (idx, dic) in msgArray.enumerated() {
            var tStamp : Int64 = 0
            if let msgID = dic["timestamp"] as? String {
                tStamp = Int64(msgID)!
            } else if let msgID = dic["timestamp"] as? Int64 {
                tStamp = msgID
            }
            if tStamp != 0 {
                if (tStamp == messageID) {
                    var msgData = dic
                    msgData["mediaState"] = message.mediaStates.rawValue
                    if let mediaURL = message.mediaURL {
                        if mediaURL.count>0 {
                            msgData["mediaURL"] = mediaURL
                        }
                    }
                    if let payload = message.messagePayload {
                        if payload.count>0 {
                            msgData["payload"] = payload.toBase64()
                        }
                    }
                    msgArray[idx] = msgData
                }
            }
        }
        chatDta["messageArray"] = msgArray
        self.couchbase.updateData(data: chatDta, toDocID: chatDocID)
    }
    
    /// Update the status for chat messages.
    ///
    /// - Parameters:
    ///   - status: Current message status recevied from server.
    ///   - chatDocID: Chat document ID where you want to update the data.
    func updateStatusForChatMessages(withStatus status : String, chatDocID : String?, content: [String : Any]) {
        guard let chatDocID = chatDocID else { return }
        guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return }
        var chatDta = chatData
        var msgArray = chatDta["messageArray"] as! [[String:Any]]
        
        for (idx, dic) in msgArray.enumerated() {
            if ((dic["deliveryStatus"] as? String) != "3") && ((dic["isSelf"] as? Bool) == true) {
                var msgData = dic
                msgData["deliveryStatus"] = status
                let currentMsgId = msgData["id"] as? String
                if let msgIds = content["msgIds"] as? [Any], msgIds.count > 0{
                    let msgID = msgIds[0] as? String
                    if currentMsgId == msgID{
                        if status == "2", let delTime = content["deliveryTime"] as? Double{
                            msgData["deliveryTime"] = delTime
                        }else if status == "3", let readTm = content["readTime"] as? Double{
                            msgData["readTime"] = readTm
                        }
                    }
                }
                msgArray[idx] = msgData
                
                
                
                //print("message status threee change msgData\(msgData) status\(status)")
                //add secret Chat Timerrrrrr
                //                if ((dic["secretId"]  as? String) != "" ) && (status == "3") && ((dic["dTime"] as? Int) !=  0 ) {
                //
                //                    if let dTime = dic["dTime"] as? Int , let timeStamp = dic["timestamp"] as? String {
                //
                //                        let addTime:DispatchTimeInterval = .seconds(dTime)
                //                        let dispatchQue = DispatchQueue(label: timeStamp)
                //                        dispatchQue.asyncAfter(deadline: DispatchTime.now() + addTime , execute: {
                //                            print("helloooo frds chai pee lo \(addTime) message Time = \(dispatchQue.label)")
                //                        })
                //                    }
                //                }
                
                
            }
        }
        
        chatDta["messageArray"] = msgArray
        
        self.couchbase.updateData(data: chatDta, toDocID: chatDocID)
        
        
        //        OperationQueue.main.addOperation {
        //            self.couchbase.updateChatStatus(data:chatDta , toDocID: chatDocID)
        //        }
        
    }
    
    
    func updateGetPefectDictID(messageID : String? ,chatDocID: String?) -> Int {
        
        guard let chatDocID = chatDocID else { return 0}
        guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return 0}
        var chatDta = chatData
        var msgArray = chatDta["messageArray"] as! [[String:Any]]
        
        guard let msgIDArray = messageID as? [String] else { return  0 }
        guard let index:Int = msgArray.index(where: {($0["id"] as? String) == msgIDArray[0]}) else { return 0  }
        
        return index
    }
    
    
    func updateDDDDDDDDDDDMessages(withStatus status : String, chatDocID : String?) -> [String:Any] {
        guard let chatDocID = chatDocID else { return ["":""]}
        guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return ["":""]}
        var chatDta = chatData
        var msgArray = chatDta["messageArray"] as! [[String:Any]]
        
        for (idx, dic) in msgArray.enumerated() {
            if ((dic["deliveryStatus"] as? String) != "3") && ((dic["isSelf"] as? Bool) == true) {
                var msgData = dic
                msgData["deliveryStatus"] = status
                msgArray[idx] = msgData
            }
        }
        
        chatDta["messageArray"] = msgArray
        
        return chatDta
        
        //self.couchbase.updateData(data: chatDta, toDocID: chatDocID)
        //     OperationQueue.main.addOperation {
        //        self.couchbase.updateChatStatus(data:chatDta , toDocID: chatDocID)
        //    }
        
    }
    
    
    
    func getMessages(withChatDocID chatDocId : String) -> [Message] {
        let unsortedMessages = self.getMessagesFromChatDoc(withChatDocID: chatDocId)
        let sortedMessages = unsortedMessages.uniq()
        let messags = sortedMessages.sorted {
            guard let uniqueID1 = $0.uniquemessageId, let uniqueID2 = $1.uniquemessageId else { return false }
            return uniqueID1 < uniqueID2
        }
        return messags
    }
    
    func getMediaMessages(withChatDocID chatDocId : String) -> [Message]? {
        let msgArray = self.getMessages(withChatDocID : chatDocId)
        let mediaMessages = msgArray.filter({
            if  $0.messageType == MessageTypes.image || $0.messageType == MessageTypes.gif || $0.messageType == MessageTypes.video || $0.messageType == MessageTypes.doodle || $0.messageType == MessageTypes.document{
                return true
            }
            if let rMsg = $0.repliedMessage {
                if rMsg.replyMessageType  == MessageTypes.image || rMsg.replyMessageType == MessageTypes.gif || rMsg.replyMessageType == MessageTypes.video || rMsg.replyMessageType == MessageTypes.doodle || $0.messageType == MessageTypes.document {
                    return true
                }
            }
            return false
        })
        return mediaMessages
    }
    
    // Used for updating existing message to chat DB.
    func updateMessageObjectToDB(withMessageObj msgObj: Message, andChatDocID chatDocID : String) {
        
    }
    
    /// For creating the text message which is going to be send between users.
    ///
    /// - Parameters:
    ///   - text: Current text message.
    ///   - type: Message Type
    /// - Returns: Dictionary of the message.
    func makeMessageForSendingBetweenServers(withText text : String, andType type: String, isReplying : Bool, replyingMsgObj : Message?, senderID : String, receiverId : String, chatDocId : String, isStar: Int = 0) -> [String:Any]? {
        let userDocVMObject = UsersDocumentViewModel(couchbase: self.couchbase)
        guard let userData = userDocVMObject.getUserData() else {
            return nil }
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        var params = [String :Any]()
        params["from"] = senderID as Any
        params["to"] = receiverId as Any
        params["payload"] = text.toBase64() as Any
        params["toDocId"] = chatDocId as Any
        params["timestamp"] = "\(timeStamp)" as Any
        params["id"] = "\(timeStamp)" as Any
        params["type"] = type as Any
        params["userImage"] = userData["userImageUrl"]! as Any
//        params["isStar"] = userData["isStar"]! as Any
        if let name = userData["publicName"] {
            params["name"] = name as Any
        }
        
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        
        if isReplying == true, let replyMsg = replyingMsgObj {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = replyMsg.messageType {
                params["previousPayload"] = pPload as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = type as Any
                params["type"] = "10" as Any
                params["previousReceiverIdentifier"] = prIdentifier as Any
                params["previousId"] = msgId as Any
                var preType = previousType.hashValue
                //                if preType < 0 || preType > 13{
                //                    preType = Int(previousType.rawValue)
                //                }
               params["previousType"] = settingPreviousTypeParams(messageType: previousType)
                
                if previousType == .replied {
                    if let pType = replyMsg.repliedMessage?.replyMessageType {
                        //                        params["previousType"] = "\(pType.hashValue)" as Any
                      params["previousType"] =  settingPreviousTypeParams(messageType: pType)
                        
                        if previousType == .image || previousType == .doodle || previousType == .video ||  previousType == .post {
                            if let tData = replyMsg.thumbnailData {
                                params["previousPayload"] = tData
                            }
                        } else if previousType == .location {
                            params["previousPayload"] = "Location"
                        }
                        else if previousType == .replied {
                            if let repliedMsg = replyingMsgObj?.repliedMessage {
                                if repliedMsg.replyMessageType == .image || repliedMsg.replyMessageType == .doodle || repliedMsg.replyMessageType == .video ||
                                    repliedMsg.replyMessageType == .post{
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
                
            }
        }
        return params
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
    
    /// Create a Media message for transfer it between clients.
    ///
    /// - Parameters:
    ///   - mediaData: thumbnail media data
    ///   - dataSize: Media size
    ///   - mediaUrl: Media URL after uploading it remotely
    ///   - timestamp: timestamp of the message.
    /// - Returns: Dictionary of the message.
    func makeMessageForSendingBetweenServers(withData mediaData : String?, withMediaSize dataSize:Int, andMediaURL mediaUrl: String, withtimeStamp timestamp : String?, andType type : String, documentData : [String : Any]?, isReplying : Bool, replyingMsgObj : Message?, senderID : String, receiverId : String, chatDocId : String) -> [String:Any]? {
        let userDocVMObject = UsersDocumentViewModel(couchbase: couchbase)
        guard let userData = userDocVMObject.getUserData(), let timeStamp = timestamp else { return nil }
        guard let dateString = DateExtension().getDateString(fromDate: Date()) else { return nil }
        var params = [String :Any]()
        if let documentData = documentData {
            params = documentData
        }
        params["from"] = senderID as Any
        params["to"] = receiverId as Any
        params["payload"] = mediaUrl.toBase64() as Any
        params["toDocId"] = chatDocId as Any
        params["timestamp"] = timeStamp as Any
        params["id"] = timeStamp as Any
        params["type"] = type as Any
        params["dataSize"] = dataSize as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["publicName"]! as Any
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        params["sentDate"] = dateString as Any
        if let thumbnailData = mediaData {
            params["thumbnail"] = thumbnailData as Any
        }
        
        if isReplying == true, let replyMsg = replyingMsgObj {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = replyMsg.messageType {
                params["previousPayload"] = pPload as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = type as Any
                params["type"] = "10" as Any
                params["previousReceiverIdentifier"] = prIdentifier as Any
                params["previousId"] = msgId as Any
                var preType = previousType.hashValue
                if preType < 0 || preType > 13{
                    preType = Int(previousType.rawValue)
                }
//                params["previousType"] = "\(preType)" as Any
                params["previousType"] = settingPreviousTypeParams(messageType: previousType)
                if previousType == .replied {
                    if let pType = replyMsg.repliedMessage?.replyMessageType {
//                        params["previousType"] = "\(pType.hashValue)" as Any
                    params["previousType"] = settingPreviousTypeParams(messageType: pType)
                    }
                }
                if previousType == .image || previousType == .doodle || previousType == .video || previousType == .post{
                    if let tData = replyMsg.thumbnailData {
                        params["previousPayload"] = tData
                    }
                } else if previousType == .location {
                    params["previousPayload"] = "Location"
                }
                else if previousType == .replied {
                    if let repliedMsg = replyingMsgObj?.repliedMessage {
                        if repliedMsg.replyMessageType == .image || repliedMsg.replyMessageType == .doodle || repliedMsg.replyMessageType == .video ||
                            repliedMsg.replyMessageType == .post{
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
        
        return params
    }
    
    /// Create a Media message for transfer it between clients for post.
    ///
    /// - Parameters:
    ///   - mediaData: thumbnail media data
    ///   - dataSize: Media size
    ///   - mediaUrl: Media URL after uploading it remotely
    ///   - timestamp: timestamp of the message.
    /// - Returns: Dictionary of the message.
    func makeMessageForSendingBetweenServersForPost(withData mediaData : String?, withMediaSize dataSize:Int, andMediaURL mediaUrl: String, withtimeStamp timestamp : String?, andType type : String, documentData : [String : Any]?, isReplying : Bool, replyingMsgObj : Message?, senderID : String, receiverId : String, chatDocId : String, postId: String, postTitle: String, postType: Int) -> [String:Any]? {
        let userDocVMObject = UsersDocumentViewModel(couchbase: couchbase)
        guard let userData = userDocVMObject.getUserData(), let timeStamp = timestamp else { return nil }
        guard let dateString = DateExtension().getDateString(fromDate: Date()) else { return nil }
        var params = [String :Any]()
        if let documentData = documentData {
            params = documentData
        }
        params["from"] = senderID as Any
        params["to"] = receiverId as Any
        params["payload"] = mediaUrl.toBase64() as Any
        params["toDocId"] = chatDocId as Any
        params["timestamp"] = timeStamp as Any
        params["id"] = timeStamp as Any
        params["type"] = type as Any
        params["dataSize"] = dataSize as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["publicName"]! as Any
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        params["sentDate"] = dateString as Any
        if let thumbnailData = mediaData {
            params["thumbnail"] = thumbnailData as Any
        }
        
        //extra keys for post sharing
        params["postId"] = postId
        params["postTitle"] = postTitle
        params["postType"] = postType
        
        if isReplying == true, let replyMsg = replyingMsgObj {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = replyMsg.messageType {
                params["previousPayload"] = pPload as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = type as Any
                params["type"] = "10" as Any
                params["previousReceiverIdentifier"] = prIdentifier as Any
                params["previousId"] = msgId as Any
                var preType = previousType.hashValue
                if preType < 0 || preType > 13{
                    preType = Int((previousType.rawValue))
                }
//                params["previousType"] = "\(preType)" as Any
                params["previousType"] = settingPreviousTypeParams(messageType: previousType)
                if previousType == .replied {
                    if let pType = replyMsg.repliedMessage?.replyMessageType {
//                        params["previousType"] = "\(pType.hashValue)" as Any
                    params["previousType"] = settingPreviousTypeParams(messageType: pType)
                    }
                }
                if previousType == .image || previousType == .doodle || previousType == .video || previousType == .post{
                    if let tData = replyMsg.thumbnailData {
                        params["previousPayload"] = tData
                    }
                } else if previousType == .location {
                    params["previousPayload"] = "Location"
                }
                else if previousType == .replied {
                    if let repliedMsg = replyingMsgObj?.repliedMessage {
                        if repliedMsg.replyMessageType == .image || repliedMsg.replyMessageType == .doodle || repliedMsg.replyMessageType == .video ||
                            repliedMsg.replyMessageType == .post{
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
        
        return params
    }
    
}

func == (lhs: Chat, rhs: Chat) -> Bool {
    let lhsTimeStamp = lhs.lastMessageDate, rhsTimeStamp = rhs.lastMessageDate
    return (lhsTimeStamp == rhsTimeStamp)
}
