//
//  ChatListViewModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 01/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import UserNotifications
import CocoaLumberjack

class ChatListViewModel: NSObject {
    
    public var chats: [Chat]
    var searchedChats = [Chat]()
    var searchedMessageArray = [[String : Any]]()
    
    struct  Constants {
        static let cellIdentifier = "ChatListTableViewCell"
        static let errorMsg = "Something went wrong".localized
        static let notificationNotAllowedError = "Notifications not allowed".localized
    }
    
    let couchbaseObj = Couchbase.sharedInstance
    
    var userName : String? {
        guard let userName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else { return nil }
        return userName
    }
    
    init(withChatObjects chats : [Chat]) {
        /// Sorting chat by their last message date timestamp.
        let shortedChats = chats.sorted { (chat1, chat2) -> Bool in
            guard let uniqueChatID1 = Int64(chat1.lastMessageDate), let uniqueChatID2 = Int64(chat2.lastMessageDate) else { return false }
            return  uniqueChatID1 > uniqueChatID2
        }
        self.chats = shortedChats
    }
    
    func setupNotificationSettings() {
        // Specify the notification types.
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                DDLogDebug(Constants.errorMsg)
            }
        }
    }
    
    func unreadChatsCounts() -> Int {
        var unreadChats = [Chat]()
        for chat in self.chats {
            if chat.hasNewMessage {
                unreadChats.append(chat)
            }
        }
        return unreadChats.count
    }
    
    func authCheckForNotification () {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
                DDLogDebug(Constants.notificationNotAllowedError)
            }
        }
    }
    
    func getNumberOfRows(isSearchActive: Bool) -> Int {
        if isSearchActive{
            return self.searchedChats.count + self.searchedMessageArray.count
        }else{
            return self.chats.count
        }
    }
    
    func deleteChat(fromIndexPath indexPath :IndexPath, isSearchActive: Bool) {
        if isSearchActive{
            self.searchedChats.remove(at: indexPath.row)
        }else{
            self.chats.remove(at: indexPath.row)
        }
    }
    
    func deleteRow(fromIndexPath indexPath :IndexPath, isSearchActive: Bool, success:@escaping ([String : Any]) -> Void, failure:@escaping (CustomErrorStruct) -> Void) {
        var dataObject: Chat?
        if isSearchActive{
            dataObject = self.searchedChats[indexPath.row]
        }else{
            dataObject = self.chats[indexPath.row]
        }
        let chatVMObj = ChatViewModel(withChatData: dataObject!)
        chatVMObj.deleteChat(success: { response in
            success(response)
        }) { error in
            failure(error)
        }
    }
    
    func  setUpTableViewCell(indexPath : IndexPath, tableView : UITableView, isSearchActive: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as! ChatListTableViewCell
        var dataObject: Chat?
        if isSearchActive{
            if indexPath.row < self.searchedChats.count{
                dataObject = self.searchedChats[indexPath.row]
                cell.chatVMObj = ChatViewModel(withChatData: dataObject!)
            }else{
                let data = self.searchedMessageArray[indexPath.row - self.searchedChats.count]
                cell.setCellDataForSearchedMessage(data: data)
            }
        }else{
            dataObject = self.chats[indexPath.row]
            cell.chatVMObj = ChatViewModel(withChatData: dataObject!)
        }
        return cell
    }
    
    
    /// To get search user or group list
    ///
    /// - Parameter name: user or gorup name
    func searchPeopleNameAndMessage(searchText: String?){
        guard let text = searchText else {
            self.searchedChats = self.chats
            self.searchedMessageArray.removeAll()
            return
        }
        if text == ""{
            self.searchedChats = self.chats
            self.searchedMessageArray.removeAll()
        }else{
            self.searchedChats.removeAll()
            self.searchedMessageArray.removeAll()
            for data in self.chats{
                self.searchPeopleName(chatData: data, name: text)
                self.searchMessageInDatabase(chatDataObj: data, message: text)
            }
        }
    }
    
    /// To search people and group from chat list
    ///
    /// - Parameters:
    ///   - chatData: chat data
    ///   - name: name to search
    private func searchPeopleName(chatData: Chat, name: String){
        
        if chatData.isGroupChat, let groupName = chatData.groupName{
            if groupName.lowercased().contains(name){
                self.searchedChats.append(chatData)
            }
        }else if chatData.name.lowercased().contains(name){
            self.searchedChats.append(chatData)
        }
    }
    
    
    
    /// To search message in user message database
    ///
    /// - Parameters:
    ///   - chatDataObj: chat obje
    ///   - message: text to search
    private func searchMessageInDatabase(chatDataObj: Chat, message: String){
        guard let docId = chatDataObj.docID else {return}
        guard let chatData = self.couchbaseObj.getData(fromDocID: docId) else {return}
        var isGroup = false
        if let isGr = chatData["isGroupChat"] as? Int, isGr == 1{
            isGroup = true
        }
        guard let messageArray = chatData["messageArray"] as? [[String : Any]] else {return}
        let textMessages = messageArray.filter { (dict) -> Bool in
            if isGroup, let gpMsgType = dict["gpMessageType"] as? String, gpMsgType == "0"{
                return false
            }
            if let type = dict["messageType"] as? String, type == "0"{
                return self.isTextFoundInSearchText(stringToSearch: dict["message"], searchText: message)
            }else if let type = dict["type"] as? String, type == "0"{
                return self.isTextFoundInSearchText(stringToSearch: dict["payload"], searchText: message)
            }
            else{
                return false
            }
        }
        if textMessages.count > 0{
            let searchedMsgArr = textMessages.map {
                self.makeMessageObject(messageObj: $0, docId: docId)
            }
            
            let dictArr = searchedMsgArr.map{
                ["chatViewModel": chatDataObj,
                 "message": $0]
            }
            self.searchedMessageArray.append(contentsOf: dictArr)
        }
    }
    
    
    /// To convert base64 data to string and search search text in message
    ///
    /// - Parameters:
    ///   - stringToSearch: message string in base64 formate
    ///   - searchText: string to search
    /// - Returns: if found return true
    private func isTextFoundInSearchText(stringToSearch: Any?, searchText: String) -> Bool{
        guard let msgToSearch = stringToSearch as? String else {return false}
        let decodedMsg = convertBase64ToString(stringToConvert: msgToSearch)
        if decodedMsg.lowercased().contains(searchText){
            return true
        }else{
            return false
        }
    }
    
    
    /// to convert base64 string to string
    ///
    /// - Parameter stringToConvert: string to convert
    /// - Returns: decoded string
    private func convertBase64ToString(stringToConvert: String) ->String{
        guard let decodedData = Data(base64Encoded: stringToConvert) else{return ""}
        return String(data: decodedData, encoding: .utf8)!
    }
    
    /// To make message object
    ///
    /// - Parameters:
    ///   - messageObj: dicto=ionary data
    ///   - docId: document id
    /// - Returns: message object
    private func makeMessageObject(messageObj: [String : Any], docId: String) -> Message{
        
        let mediaState:MediaStates = .notApplicable
        let thumbnailData = ""
        let mediaURL = ""
        
        var secretID  = ""
        if let secretId = messageObj["secretId"] as? String {
            secretID = secretId
        }
        
        var msgtype = ""
        //        , message = ""
        if let type = messageObj["type"] as? String/*, let msg = messageObj["payload"] as? String */{
            msgtype = type
            //            message = msg
        } else if let type = messageObj["messageType"] as? String/*, let msg = messageObj["message"] as? String */{
            msgtype = type
            //            message = msg
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
        var isSelf = false
        if let isMine = messageObj["isSelf"] as? Bool{
            isSelf = isMine
        }
        return Message(forData: messageObj, withDocID: docId, andMessageobj: messageObj, isSelfMessage: isSelf, mediaStates: mediaState, mediaURL: mediaURL, thumbnailData: thumbnailData, secretID: secretID, receiverIdentifier: rIdentifier, messageData: messageObj, isReplied: isReplying ,gpMessageType: gpMessageType,dTime:dTime, readTime: readTime, deliveryTime: deliveryTime)
    }
    
    
    /// To get, search is empty or not
    ///
    /// - Returns: return true if not empty
    func isNoSearchFound() -> Bool{
        if self.searchedChats.count > 0 || self.searchedMessageArray.count > 0{
            return true
        }else{
            return false
        }
    }
    
    /// To get iceServers response from
    ///   - complitation: complitation handler after getting response
    func getIceServerDetailsService(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let api = SocialAPI()
        let url: String = AppConstants.iceServer
        api.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [[String : Any]]{
                print(result)
                if let iceServers = result[0]["iceServers"] as? [[String:Any]]{
                    if let creds = iceServers[1] as? [String:Any]{
                        print(creds["urls"])
                        if let urls = creds["urls"] {
                        UserDefaults.standard.set(urls, forKey: AppConstants.UserDefaults.iceServers)
                        }
                        if let iceServerUsername = creds["username"] {
                        UserDefaults.standard.set(iceServerUsername, forKey: AppConstants.UserDefaults.iceServerUserName)
                        }
                        if let iceServerCreds = creds["credential"] {
                            UserDefaults.standard.set(iceServerCreds, forKey: AppConstants.UserDefaults.iceServerCreds)
                        }
                    }
                }
            
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error)
            }
            Helper.hidePI()
        }
    }

}
