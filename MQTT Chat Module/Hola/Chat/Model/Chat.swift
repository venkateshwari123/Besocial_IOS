//
//  Chat.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 22/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

class Chat: NSObject {
    
    var messageArray : [String]?
    var hasNewMessage : Bool
    var newMessage : String
    var newMessageTime : String
    var newMessageDateInString : String
    var newMessageCount : String
    var lastMessageDate :String
    var receiverUIDArray : [String]?
    var receiverDocIDArray : [String]?
    var name : String
    var image : String // group image // secret chat image // chat user image
    var secretID : String
    var userID : String // receiver ID
    var docID : String?
    var chatID : String
    var wasInvited : Bool
    var destructionTime : Int
    var msgDate : Date?
    var isSecretInviteVisible : Bool
    /// Newly added for secret chat and group chat.
    var groupName:String?
    var initiatorIdentifier:String? // Group admin number
    var number:String? // receiver number
    var isSelfChat:Bool // is Secret chat or not
    var isGroupChat:Bool // Is group chat or not
    var initiatorId : String? // Group admin id
    var lastMessageType : String // Type of the last message.
    var isUserBlock:Bool // Is user block or not
    var gpMessagetype:String?
    var isStar:Int?
    
    init(messageArray : [String]?,hasNewMessage : Bool, newMessage : String, newMessageTime : String, newMessageDateInString : String, newMessageCount : String, lastMessageDate : String, receiverUIDArray : [String]?, receiverDocIDArray : [String]?, name : String, image : String, secretID : String, userID : String,docID : String?,wasInvited : Bool,destructionTime : Int,isSecretInviteVisible : Bool, chatID: String, groupName : String?, initiatorIdentifier:String?,number : String?, isSelfChat : Bool, isGroupChat: Bool, initiatorId : String?, lastMessageType : String , isUserblock : Bool,gpMessagetype:String,isStar:Int) {
        self.messageArray = messageArray
        self.hasNewMessage = hasNewMessage
        self.newMessage = newMessage
        self.newMessageTime = newMessageTime
        self.newMessageDateInString = newMessageDateInString
        self.newMessageCount = newMessageCount
        self.lastMessageDate = lastMessageDate
        self.receiverUIDArray = receiverUIDArray
        self.receiverDocIDArray = receiverDocIDArray
        self.name = name
        self.image = image
        self.secretID = secretID
        self.userID = userID
        self.docID = docID
        self.wasInvited = wasInvited
        self.destructionTime = destructionTime
        self.isSecretInviteVisible = isSecretInviteVisible
        self.chatID = chatID
        self.groupName = groupName
        self.initiatorIdentifier = initiatorIdentifier
        self.number = number
        self.isSelfChat = isSelfChat
        self.isGroupChat = isGroupChat
        self.initiatorId = initiatorId
        self.lastMessageType = lastMessageType
        self.isUserBlock = isUserblock
        self.gpMessagetype = gpMessagetype
        self.isStar = isStar
    }
}
