//
//  FollowListViewModel.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 11/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class FollowListViewModel: NSObject {

    let sharePostApi = SocialAPI()
    var followersFolloweeModelArray = [FollowersFolloweeModel]()
//    var searchFolloweeModelArray = [FollowersFolloweeModel]()
//    var isSearchActive: Bool = false
//    var searchString: String = ""
    var offset: Int = 0
    let limit: Int = 20
    var selectedMember = [FollowersFolloweeModel]()
    var selectedMemberId = [String]()
    var groupMemberList = [[String : Any]]()
    
    let couchbase = Couchbase.sharedInstance
    
    let selfID = Utility.getUserid()
    var documentId: String?
    let mqttChatManager = MQTTChatManager.sharedInstance
    
    
    /// To get follow user list stored in database
    ///
    /// - Returns: list of following user
    func getFollowUserListFromDatabase() -> Bool{
        let followUserList = Utility.getFollowListFromDatabase(couchbase: couchbase)
        self.followersFolloweeModelArray = followUserList.map({
            FollowersFolloweeModel(modelData: $0 as! [String : Any])
        })
        return self.followersFolloweeModelArray.count >= 20 ? true : false
    }
    
    
    /// To get follow user list from server
    ///
    /// - Parameters:
    ///   - strUrl: string url
    ///   - complitation: complication block after compliting request
    func getFollowAndFollowesService(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        
        let url = strUrl + "offset=\(offset)&limit=\(limit)"
        sharePostApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                self.setDataInModel(modelArray: result)
//                self.offset = self.offset + 20
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                if error.code == 204{
                    if self.offset == 0{
                        self.followersFolloweeModelArray.removeAll()
                    }
                    complitation(true, error, false)
                }else{
//                    print(error.localizedDescription)
                    complitation(false, error, true)
                }
            }
            Helper.hidePI()
        }
    }
    
    
    /// to set set follow user list in array and database
    ///
    /// - Parameter modelArray: follow user list
    func setDataInModel(modelArray: [Any]){
//        Utility.updateFollowListInDatabase(couchbase: couchbase, modelArray: modelArray)
        if self.offset == 0{
            self.followersFolloweeModelArray.removeAll()
        }
        for data in modelArray{
            guard let dict = data as? [String : Any] else{continue}
            let followModel = FollowersFolloweeModel(modelData: dict)
            self.followersFolloweeModelArray.append(followModel)
        }
//        if self.isSearchActive{
//            self.getArrayForSearchedString()
//        }
    }
    
//    /// For getting chat doc on respected to receiver ID and secret ID.
//    ///
//    /// - Parameters:
//    ///   - receiverID: receiver ID provided by the contact.
//    ///   - secretID: secret ID related to the contact.
//    /// - Returns: this will return the chat doc ID respected to receiver ID and secret ID.
//    func fetchIndividualChatDoc(withReceiverID receiverID:String, andSecretID secretID : String) -> String? {
//        guard let userID = Utility.getUserid() else { return nil }
//        guard let indexID = getIndexValue(withUserSignedIn: true) else { return  nil }
//        guard let indexData = couchbase.getData(fromDocID: indexID) else { return  nil }
//        guard let userIDArray = indexData["userIDArray"] as? [String] else { return  nil }
//        if userIDArray.contains(userID) {
//            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return nil }
//            if let index = userIDArray.index(of: userID) {
//                let userDocID = userDocArray[index]
//                guard let userDocData = couchbase.getData(fromDocID: userDocID) else { return nil  }
//                if let chatDocID = userDocData["chatDocument"] as? String {
//                    guard let chatData = couchbase.getData(fromDocID: chatDocID) else { return nil  }
//                    guard let receiverUIDArray = chatData["receiverUidArray"] as? [String] else { return nil  }
//                    guard let scretIDArray = chatData["secretIdArray"] as? [String] else { return  nil }
//                    guard let receiverChatDocIdArray = chatData["receiverDocIdArray"] as? [String] else { return nil  }
//                    if !scretIDArray.isEmpty { // For searching the chat doc id.
//                        for index in 0 ..< receiverUIDArray.count {
//                            let reciverIDL = receiverUIDArray[index]
//                            if (receiverID == reciverIDL ) {
//                                if scretIDArray[index] == secretID {
//                                    return receiverChatDocIdArray[index]
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        return nil
//    }
//
//    /// Used for getting the index DocID. If its there then return the existing one or else create a new one.
//    ///
//    /// - Returns: String value of index document ID.
//    private func getIndexValue(withUserSignedIn isUserSignedIn : Bool) -> String? {
//        if let indexDocID = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.indexDocID) as? String {
//            if indexDocID.count>1 {
//                return indexDocID
//            } else {
//                return nil
//            }
//        } else {
//            return nil
//        }
//    }
    
    
    /// To check member is already in group or not
    ///
    /// - Parameter data: user to check
    /// - Returns: if already there return true otherwise false
    func checkIfAlreadyInGroup(data: FollowersFolloweeModel)-> Bool{
        print(groupMemberList)
        let predicate = NSPredicate.init(format:"memberIdentifier == %@", data.number!)
        let fArr =  self.groupMemberList.filter({predicate.evaluate(with: $0)})
        if fArr.count ==  0 {
            return false
        } else {
            return true
        }
    }
    
    
    /// To convert followfollowe model to contact object
    ///
    /// - Parameter index: index of model
    /// - Returns: contact object
    func getContactObjectForUserAtIndex(index: Int) ->Contacts{
        let data = self.followersFolloweeModelArray[index]
        let docId = Utility.fetchIndividualChatDoc(withReceiverID: data.id, andSecretID: "")
        return Contacts(followModel: data, docId: docId)
    }
    
}


// MARK: - To save message in user database and send message to server
extension FollowListViewModel{
    
    func forwardMessageToAllSelectedUsers(message: Message?){
        for user in self.selectedMember {
            let userId = user.id
            if  let message = message {
                // Adding message to the DB first
                guard let docId = self.addMessageToDB(withMessage: message, followModel: user) else{continue}
                // Used for sending message to receiver.
                self.sendMessageToReceiver(withMsgObj: message, withReceiverId: userId, andChatDocID: docId)
            }
        }
    }
    
    
    private func sendMessageToReceiver(withMsgObj msgObj: Message, withReceiverId receiverID: String, andChatDocID  userChatDocID: String?) {
        msgObj.isSelfMessage = true
        if let msgData = self.getMessageData(fromMsgObj: msgObj, isForCouchBase: false), let chatDocID =  userChatDocID {
            guard let type = msgObj.messageType else{return}
            switch type{
            case .text:
                self.sendTextLocationContactMessage(type: "0", msgObj: msgObj, chatDocID: chatDocID, receiverID: receiverID)
                break
            case .image, .doodle, .sticker, .video, .audio, .document, .post:
                print(msgData)
                let forwardMessageModel = ForwardMessageModel(couchbase: Couchbase.sharedInstance)
                guard let msgToSend = forwardMessageModel.getImageMessageObject(message: msgData, senderId: selfID!, receiverId: receiverID, chatDocId: chatDocID) else {return}
                mqttChatManager.sendMessage(toChannel: "\(receiverID)", withMessage: msgToSend, withQOS: .atLeastOnce)
                break
            case .location:
                self.sendTextLocationContactMessage(type: "3", msgObj: msgObj, chatDocID: chatDocID, receiverID: receiverID)
                break
            case .contact:
                self.sendTextLocationContactMessage(type: "4", msgObj: msgObj, chatDocID: chatDocID, receiverID: receiverID)
                break
            case .gif:
                self.sendTextLocationContactMessage(type: "8", msgObj: msgObj, chatDocID: chatDocID, receiverID: receiverID)
                break
            case .replied, .deleted:
                break
            case .transfer:
                break
            case .missedCallMessage:
                break
            case .callMessage:
                break
            }
        }
    }
    
    private func getMessageData(fromMsgObj msgObj: Message, isForCouchBase : Bool) -> [String : Any]? {
        let timeStamp = Int64(floor(Date().timeIntervalSince1970 * 1000))
        guard var msgDict = msgObj.messageData else { return nil }
        msgDict["timestamp"] = "\(timeStamp)"
        msgDict["id"] = "\(timeStamp)"
        if let to = msgDict["to"] as? String, let from = msgDict["from"] as? String {
            if to == selfID {
                msgDict["to"] = from
                msgDict["from"] = to
            }
        }
        if isForCouchBase {
            return msgDict
        } else {
            msgDict.removeValue(forKey: "isSelf")
            msgDict.removeValue(forKey: "deliveryStatus")
            msgDict.removeValue(forKey: "mediaState")
            msgDict.removeValue(forKey: "mediaURL")
            return msgDict
        }
    }
    
    private func getChatDocId(forReceivedID receiverID : String, contactObj: Contacts) -> String? {
        let individualChatDocVMObject = IndividualChatViewModel(couchbase: Couchbase.sharedInstance)
        guard let chatDocID = individualChatDocVMObject.getChatDocID(withreceiverID: receiverID, andSecretID: "", withContactObj: contactObj, messageData: nil, destructionTime: nil, isCreatingChat: false) else {
            return nil
        }
        return chatDocID
    }
    
    private func sendTextLocationContactMessage(type: String, msgObj: Message, chatDocID: String, receiverID: String){
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: Couchbase.sharedInstance)
        guard let message = chatsDocVMObject.makeMessageForSendingBetweenServers(withText: msgObj.messagePayload!, andType: type, isReplying: false, replyingMsgObj: nil, senderID: selfID!, receiverId: receiverID, chatDocId: chatDocID) else { return }
        mqttChatManager.sendMessage(toChannel: "\(receiverID)", withMessage: message, withQOS: .atLeastOnce)
    }
    
    private func addMessageToDB(withMessage msgObj: Message, followModel: FollowersFolloweeModel) -> String?{
        let cbObj = Couchbase.sharedInstance
        let chatsDocVMObj = ChatsDocumentViewModel(couchbase: cbObj)
        msgObj.isSelfMessage = true
        let receiverId = followModel.id
        let messDict =  self.getMessageDictFromDatabaseWithMessageId(message: msgObj, receiverID: receiverId, followModel: followModel)
        
        let contact = Contacts(followModel: followModel, docId: nil)
        if let chatDocID =  self.getChatDocId(forReceivedID: receiverId, contactObj: contact) {
            if let chatDta = cbObj.getData(fromDocID: chatDocID) {
                chatsDocVMObj.updateChatData(withData: chatDta, msgObject : messDict as Any, inDocID  : chatDocID, isCreatingChat: false)
            }
            return chatDocID
        }
        return nil
    }
    
    //Get perticular message from Database
    private func getMessageDictFromDatabaseWithMessageId(message:Message ,receiverID : String, followModel: FollowersFolloweeModel) -> [String:Any]{
        guard let documentID = self.documentId  else {return ["":""] }
        if let docData = Couchbase.sharedInstance.getData(fromDocID: documentID) {
            if let msgArray = docData["messageArray"] as? [[String:Any]] {
                /*
                 Bug Name:- Crashing while forwarding message
                 Fix Date:- 27/08/21
                 Fix By  :- Jayaram G
                 Description of Fix:- removed force unwrapping
                 */
                let index = msgArray.index(where: {$0["id"]  as? String  == message.messageId})
                var messDict:[String:Any] = msgArray[index!]
                let timeStamp = Int64(floor(Date().timeIntervalSince1970 * 1000))
                messDict["timestamp"] = "\(timeStamp)"
                messDict["id"] = "\(timeStamp)"
                messDict["deliveryStatus"] = "0"
                messDict["to"] = receiverID
                messDict["from"] = selfID
                messDict["mediaState"] = 13
                messDict["isSelf"] = message.isSelfMessage
                messDict["name"] = "\(followModel.firstName)" + " " + "\(followModel.lastName)"
                messDict["userImage"] = followModel.profilePic!
                messDict["isGroupChat"] = false
                return messDict
            }
        }
        return ["":""]
    }
    
}
