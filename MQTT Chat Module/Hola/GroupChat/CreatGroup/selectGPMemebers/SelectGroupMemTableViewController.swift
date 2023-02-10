//
//  SelectGroupMemTableViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 23/01/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

protocol selectGpdelegate {
    func groupMemeberselected(member:Contacts)
}

class SelectGroupMemTableViewController: UITableViewController {
    
    struct Constant {
        static let toNewGroupSegue = "toNewGroupSegue"
    }
    var allFavoriteList  = [Contacts]()
    var searchContactList = [Contacts]()
    var selectedList = [Contacts]()
    var isSearchActive: Bool = false
    var isSelectOne = false
    var delegate:selectGpdelegate?
    var selectedGPMemList = [[String:Any]]()
    var isGroupMemberPicker = true
    var message : Message?
    let mqttChatManager = MQTTChatManager.sharedInstance
    var isSecretChat = false
    let selfID = Utility.getUserid()
    var documentId: String?
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelBtnOutlet: UIBarButtonItem!
    @IBOutlet weak var nextBtnOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelBtnOutlet.title = "Cancel".localized
        if isSelectOne == false {
            self.tableView.isEditing = true
        } else { self.navigationItem.rightBarButtonItem = nil }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isGroupMemberPicker {
            self.headerView.isHidden = false
            self.headerView.frame.size.height = 44.0
            self.title = "Add Participants".localized
            self.searchBar.placeholder = "Search".localized + " " + "User Name".localized
            self.nextBtnOutlet.title = "Next".localized
        } else {
            self.headerView.isHidden = true
            self.headerView.frame.size.height = 0
            self.title = "Forward to".localized
            self.nextBtnOutlet.title = "Forward".localized
        }

        if isSecretChat {
            self.headerView.isHidden = true
            self.headerView.frame.size.height = 0
            self.title = "Select Participants".localized
        }
        self.view.layoutIfNeeded()
        self.view.updateConstraints()
    }
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- check connectivity and show popup for no internet
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.checkConnectionAvaibility(view: self.view)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Navigation Controls Actions
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if isGroupMemberPicker {
            self.performSegue(withIdentifier: Constant.toNewGroupSegue, sender: nil)
        } else {
            self.forwardMessage(toContacts: self.selectedList)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gpVC = segue.destination as? CreatnewGroupViewController
        gpVC?.selectedGpList = self.selectedList
    }
}

extension SelectGroupMemTableViewController{
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchActive{
            return self.searchContactList.count
        }
        return allFavoriteList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectGPmems", for: indexPath) as! SelectGpMemTableViewCell
        var contact: Contacts?
        if self.isSearchActive{
            contact = self.searchContactList[indexPath.row]
        }else{
            contact  = allFavoriteList[indexPath.row]
        }
        
        cell.userName.text = contact!.fullName
        cell.userStatus.text = contact!.status
        Helper.addedUserImage(profilePic: contact!.profilePic, imageView: cell.userImage, fullName: contact!.fullName ?? "P")
        if isSelectOne {
            if isAlreadyIngroup(num: contact!.fullName!) {
                cell.userName.textColor = UIColor.lightGray
                cell.userStatus.textColor = UIColor.lightGray
            } else {
                if #available(iOS 13.0, *) {
                    cell.userName.textColor = UIColor.label
                    cell.userStatus.textColor = UIColor.label
                } else {
                    cell.userName.textColor = UIColor.black
                    cell.userStatus.textColor = UIColor.black
                    // Fallback on earlier versions
                }
                
            }
        }
        
        if selectedList.contains(contact!){
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSecretChat {
            self.delegate?.groupMemeberselected(member:self.allFavoriteList[indexPath.row] )
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if isSelectOne == true {
            self.tableView(tableView, didDeselectRowAt: indexPath)
            if isAlreadyIngroup(num: self.allFavoriteList[indexPath.row].fullName!){ return }
            let actionSheet = UIAlertController.init(title: nil, message: "Add to existing Group".localized, preferredStyle:.actionSheet)
            let action1 = UIAlertAction.init(title: "Add".localized, style: .default, handler: { _ in
                self.delegate?.groupMemeberselected(member:self.allFavoriteList[indexPath.row] )
                self.dismiss(animated: true, completion: nil)
            })
            actionSheet.addAction(action1)
            let action2 = UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: { _ in })
            actionSheet.addAction(action2)
            self.present(actionSheet, animated: true, completion: nil)
        } else {
            if isSearchActive{
                selectedList.append(searchContactList[indexPath.row])
            }else{
                selectedList.append(allFavoriteList[indexPath.row])
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isSelectOne {return}
        var contact: Contacts?
        if self.isSearchActive{
            contact  = searchContactList[indexPath.row]
        }else{
            contact  = allFavoriteList[indexPath.row]
        }
        let index = selectedList.index(of: contact!)
        selectedList.remove(at: index!)
    }
    
    func isAlreadyIngroup(num:String) -> Bool {
        let favmutable  = selectedGPMemList
//        let predicate = NSPredicate.init(format:"memberIdentifier == %@", num)
//        let fArr =  favmutable.filter({predicate.evaluate(with: $0)})
        let fArr = favmutable.filter { (contact) -> Bool in
            if let memId = contact["memberIdentifier"] as? String{
             return memId == num
            }else{
                return false
            }
        }
        if fArr.count ==  0 {
            return false
        } else {
            return true
        }
    }
}

extension SelectGroupMemTableViewController {
    
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
    
    private func getChatDocId(forReceivedID receiverID : String, andChatDocId chatDocId: String?) -> String? {
        if let chatdocId = chatDocId {
            return chatdocId
        } else {
            let individualChatDocVMObject = IndividualChatViewModel(couchbase: Couchbase.sharedInstance)
            guard let chatDocID = individualChatDocVMObject.getChatDocID(withreceiverID: receiverID, andSecretID: "", withContactObj: nil, messageData: nil, destructionTime: nil, isCreatingChat: false) else {
                return nil
            }
            return chatDocID
        }
    }
    
    fileprivate func forwardMessage(toContacts contacts : [Contacts]) {
        for contact in contacts {
            if let contactId = contact.userID, let message = message {
                // Adding message to the DB first
                self.addMessageToDB(withMessage: message, andReceiverId: contactId, chatDocumentID: contact.chatDocID)
                // Used for sending message to receiver.
                self.sendMessageToReceiver(withMsgObj: message, withReceiverId: contactId, andChatDocID: contact.chatDocID)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func sendMessageToReceiver(withMsgObj msgObj: Message, withReceiverId receiverID: String, andChatDocID  chatDocID: String?) {
        msgObj.isSelfMessage = true
        if let msgData = self.getMessageData(fromMsgObj: msgObj, isForCouchBase: false), let chatDocID =  self.getChatDocId(forReceivedID: receiverID, andChatDocId: chatDocID) {
            guard let type = msgObj.messageType else{return}
            switch type{
            case .text:
                self.sendTextLocationContactMessage(type: "0", msgObj: msgObj, chatDocID: chatDocID, receiverID: receiverID)
                break
            case .image, .doodle, .sticker, .video, .audio, .document:
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
            case .post:
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
    
    private func sendTextLocationContactMessage(type: String, msgObj: Message, chatDocID: String, receiverID: String){
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: Couchbase.sharedInstance)
        guard let message = chatsDocVMObject.makeMessageForSendingBetweenServers(withText: msgObj.messagePayload!, andType: type, isReplying: false, replyingMsgObj: nil, senderID: selfID!, receiverId: receiverID, chatDocId: chatDocID) else { return }
        mqttChatManager.sendMessage(toChannel: "\(receiverID)", withMessage: message, withQOS: .atLeastOnce)
    }
    
    private func addMessageToDB(withMessage msgObj: Message, andReceiverId receiverID: String, chatDocumentID :String?) {
        let cbObj = Couchbase.sharedInstance
        let chatsDocVMObj = ChatsDocumentViewModel(couchbase: cbObj)
        msgObj.isSelfMessage = true
        let messDict =  getMessageDictFromDatabaseWithMessageId(message: msgObj, receiverID: receiverID)
        
        //let msgData = self.getMessageData(fromMsgObj: msgObj, isForCouchBase: true)
        if let chatDocID =  self.getChatDocId(forReceivedID: receiverID, andChatDocId: chatDocumentID) {
            if let chatDta = cbObj.getData(fromDocID: chatDocID) {
                chatsDocVMObj.updateChatData(withData: chatDta, msgObject : messDict as Any, inDocID  : chatDocID, isCreatingChat: false)
            }
        }
    }
    
    
    //Get perticular message from Database
    private func getMessageDictFromDatabaseWithMessageId(message:Message ,receiverID : String) -> [String:Any]{
        guard let documentID = self.documentId  else {return ["":""] }
        if let docData = Couchbase.sharedInstance.getData(fromDocID: documentID) {
            if let msgArray = docData["messageArray"] as? [[String:Any]] {
                let index = msgArray.index(where: {$0["id"]  as! String  == message.messageId})
                var messDict:[String:Any] = msgArray[index!]
                let timeStamp = Int64(floor(Date().timeIntervalSince1970 * 1000))
                messDict["timestamp"] = "\(timeStamp)"
                messDict["id"] = "\(timeStamp)"
                messDict["deliveryStatus"] = "0"
                messDict["to"] = receiverID
                messDict["from"] = selfID
                messDict["mediaState"] = 13
                messDict["isSelf"] = message.isSelfMessage
                //                //check if media then give url
                //                if messDict["thumbnail"] != nil {
                //                    if messDict["mediaURL"] != nil {
                //                        messDict["messagePayload"] = message.mediaURL! //.fromBase64()!
                //                    }
                //                }
                
                return messDict
            }
        }
        return ["":""]
    }
    
    
}

extension SelectGroupMemTableViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = true
        self.searchContactList = self.allFavoriteList
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            self.searchContactList = self.allFavoriteList
        }else{
            let predicate = NSPredicate.init(format:"fullName contains[c] %@", searchText)
            let favArr =  allFavoriteList.filter({predicate.evaluate(with: $0)})
            if favArr.count == 0{
                self.searchContactList.removeAll()
            }else{
                self.searchContactList = favArr
            }
        }
        self.tableView.reloadData()
    }
    
}
