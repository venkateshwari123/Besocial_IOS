//
//  ChatListTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 22/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class ChatListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageOutlet: UIImageView!
    
    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var starVerifiedImageView: UIImageView!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var lastMessageOutlet: UILabel!
    @IBOutlet weak var lasDateMessageOutlet: UILabel!
    @IBOutlet weak var unreadMessageCountOutlet: UILabel!
    @IBOutlet weak var unreadMsgbackgroundViewOutlet: CircleBackgroundView!
    @IBOutlet weak var lastTimeForMsgOutlet: UILabel!
    @IBOutlet weak var lastMessageDateContstraintOutlet: NSLayoutConstraint! // 28 and 7
    
    @IBOutlet weak var deleteiconOutlet: UIImageView!
    
    var isLodedOnce: Bool = false
    
    var chatVMObj : ChatViewModel! {
        didSet {
            self.deleteiconOutlet.isHidden = true
            if !self.chatVMObj.isGroupChat{
            if chatVMObj.isStar == 1 {
                self.starVerifiedImageView.isHidden = false
            }else{
                self.starVerifiedImageView.isHidden = true
            }
            }else{
                self.starVerifiedImageView.isHidden = true
            }
            /*
             Bug Name:- default initial based pic does not show on chat
             Fix Date:- 31/05/21
             Fix By  :- Jayaram G
             Description of Fix:- assigning initials pic
             */
            if chatVMObj.isUserBlock {
                Helper.addedUserImage(profilePic: nil, imageView: userImageOutlet, fullName: chatVMObj.name)
            }else {
                if chatVMObj.isGroupChat {
                    self.userImageOutlet.image = #imageLiteral(resourceName: "group_defaultImage")
                }else{
                    Helper.addedUserImage(profilePic: nil, imageView: userImageOutlet, fullName: chatVMObj.name)
                }
                 
            }
            
            
            if let docID = chatVMObj.docID {
                if let imageURL = chatVMObj.imageURL {
                    if chatVMObj.isGroupChat{
                        self.userImageOutlet.kf.setImage(with:  imageURL, placeholder: #imageLiteral(resourceName: "group_defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil) { (result) in
                            print(result)
                        }
                    }else{
                        if chatVMObj.isUserBlock {
                            Helper.addedUserImage(profilePic: nil, imageView: userImageOutlet, fullName: chatVMObj.name)
                        }else {
                            Helper.addedUserImage(profilePic: imageURL.absoluteString, imageView: userImageOutlet, fullName: chatVMObj.name)
                        }
                        
                    }
                }
                self.userNameOutlet.text = chatVMObj.name
                if  chatVMObj.isGroupChat {
                    self.userNameOutlet.text = chatVMObj.groupName
                }
                print("new message count ---\(chatVMObj.newMessageCount)")
                if chatVMObj.newMessageCount == "0" {
                    self.unreadMsgbackgroundViewOutlet.isHidden = true
                }else {
                    self.unreadMsgbackgroundViewOutlet.isHidden = false
                }
                
                if chatVMObj.secretID != "" {
                    self.userNameOutlet.attributedText = String.addImageToString(text:chatVMObj.name , image: #imageLiteral(resourceName: "contact_lock_icon"))
                    self.lastMessageOutlet.text = chatVMObj.newMessage
                }
                self.lastMessageOutlet.text = chatVMObj.newMessage
                print(chatVMObj.messageArray)
                self.unreadMessageCountOutlet.text = chatVMObj.newMessageCount
                self.lasDateMessageOutlet.text = chatVMObj.newMessageDateInString
                if !chatVMObj.hasNewMessage {
                    self.unreadMsgbackgroundViewOutlet.isHidden = true
                    self.lasDateMessageOutlet.textColor = Helper.hexStringToUIColor(hex: AppColourStr.lightColor)
//                    self.lastMessageDateContstraintOutlet.constant = 7
                } else { // Add check for if unread count is 0.
                    self.unreadMsgbackgroundViewOutlet.isHidden = false
                    self.lasDateMessageOutlet.textColor = UIColor(red: 0/255, green: 90/255, blue: 255/255, alpha: 1)
//                    self.lastMessageDateContstraintOutlet.constant = 27
                }
                self.getLastMessage(withDocID: docID, chatVMObject: chatVMObj)
                
            }
            DispatchQueue.main.async {
                self.layoutIfNeeded()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLodedOnce{
            self.imageContainerView.makeCornerRadious(readious: self.imageContainerView.frame.size.width / 2)
            self.userImageOutlet.makeCornerRadious(readious: self.userImageOutlet.frame.size.width / 2)
            let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
            let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
            self.imageContainerView.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
        }
    }
    
    func getLastMessage(withDocID docID : String, chatVMObject  : ChatViewModel) {
        var message = ""
        let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]
        guard let messageObj = chatVMObject.getlastMessage(fromChatDocID: docID) else {
            self.getLastMessageIfMessageArrayIsNotThere(chatVMObject: chatVMObject)
            return }
        guard let deliveryStatus = messageObj.messageStatus else { return }
        if let msg = messageObj.messagePayload {
            message = msg
        }
        var payload = message.replace(target: "\n", withString: "")
        if let lastMsg = payload.fromBase64() {
            if lastMsg.count==0 {
                var str = NSMutableAttributedString()
                if self.chatVMObj.secretID.count>0 { // For showing last message text
                    if self.chatVMObj.isSelfChat {
                        str = NSMutableAttributedString(string: "You created a secret chat".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                    } else {
                        str = NSMutableAttributedString(string: "You added to a secret chat".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                    }
                    self.lastMessageOutlet.attributedText = str
                }
                if self.chatVMObj.isGroupChat { // For showing group message initially.
                    if self.chatVMObj.isSelfChat {
                        str = NSMutableAttributedString(string: "You created a group".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                    } else {
                        str = NSMutableAttributedString(string: "You are added in a group".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                    }
                    self.lastMessageOutlet.attributedText = str
                }
            } else {
                if messageObj.isSelfMessage {
                    guard let str = chatVMObject.getAtributeString(withMessageStatus: deliveryStatus) else { return }
                    str.append(NSAttributedString(string: lastMsg, attributes: nil))
                    self.lastMessageOutlet.attributedText = str
                } else {
                    let str = NSAttributedString(string: lastMsg, attributes: nil)
                    self.lastMessageOutlet.attributedText = str
                }
            }
        }
        
        if let msg = messageObj.messageType {
            switch msg {
            case .missedCallMessage:
                payload = "You missed a call".localized
                print("______\(messageObj.callType)")
                if let callType = messageObj.callType , callType == 1{
                    payload = "You missed a video call".localized
                }else{
                    payload = "You missed an audio call".localized
                }
            case .callMessage:
                payload = "Call".localized
            default:
                print("dd")
            }
        }
        
        //chat group Tost messages
        if let msg = messageObj.gpMessageType  {
            if msg != "" {
                switch messageObj.gpMessageType! {
                case "0" :
                    //Creat Group
                    let message = payload
                    let arr =  message.components(separatedBy: ",")
                    var num = ""
                    /*
                     Bug Name:- Crash
                     Fix Date:- 10/01/22
                     Fix By  :- Jayaram G
                     Description of Fix:- Crashing due to index out of range , compare array count with index
                     */
                    if arr.count > 0  {
                        num = Helper.getNameFormDatabase(num: arr[0])
                    }
                    if num == Utility.getUserName() {
                        if arr.count > 1 {
                            payload =  "You created group".localized + " \(arr[1])"
                        }
                    }else {
                        if arr.count > 1 {
                        payload =  "\(num) " + "created group".localized + " \(arr[1])"
                        }
                    }
                case "1":
                    if let message = messageObj.messagePayload{
                        let arr =  message.components(separatedBy: ",")
                        let num1 = Helper.getNameFormDatabase(num: arr[0])
                        let num2 = Helper.getNameFormDatabase(num: arr[1])
                        if num1 == Utility.getUserName() {
                            payload =  "You added".localized + " \(num2)"
                        }else {
                            payload =  "\(num1) " + "added".localized + " \(num2)"
                        }
                     }
                case "2":
                    if let message = messageObj.messagePayload{
                        let arr =  message.components(separatedBy: ",")
                        let num1 = Helper.getNameFormDatabase(num: arr[0])
                        let num2 = Helper.getNameFormDatabase(num: arr[1])
                        if num1 == Utility.getUserName() {
                            payload =  "You removed".localized + " \(num2)"
                        }else {
                            payload =  "\(num1) " + "removed".localized + " \(num2)"
                        }
                    }
                case "3":
                    if let message = messageObj.messagePayload{
                        let arr =  message.components(separatedBy: ",")
                        let num1 = Helper.getNameFormDatabase(num: arr[0])
                        let num2 = Helper.getNameFormDatabase(num: arr[1])
                        if num1 == Utility.getUserName() {
                            payload =  "You made".localized + " \(num2) " + "group admin".localized + "."
                        }else {
                            payload =  "\(num1) " + "made".localized + " \(num2) " + "group admin".localized + "."
                        }
                    }
                case "4" :
                    if let message = messageObj.messagePayload{
                        let arr =  message.components(separatedBy: ",")
                        let num = Helper.getNameFormDatabase(num: arr[0])
                        if num == Utility.getUserName() {
                            payload =  "You changed the subject to".localized + " \(arr[1])"
                        }else {
                            payload =  "\(num) " + "changed the subject to".localized + " \(arr[1])"
                        }
                    }
                case "5":
                    if let message = messageObj.messagePayload{
                        let num = Helper.getNameFormDatabase(num: message)
                        if num == Utility.getUserName() {
                            payload =  "\(num) " + "changed this group's icon".localized
                        }else {
                            payload =  "\(num) " + "changed this group's icon".localized
                        }
                    }
                case "6":
                    if let message = messageObj.messagePayload{
                        let num = Helper.getNameFormDatabase(num: message)
                        if num == Utility.getUserName() {
                            payload =  "You left".localized
                        }else {
                            payload =  "\(num) " + "left".localized
                        }
                    }
                default:
                    print("dd")
                }
            }
        }
        
        if messageObj.secretID != "" || chatVMObj.secretID
         != ""{
            payload = "Secret chat message"
            print("dtime \(messageObj.dTime)")
            if messageObj.messagePayload?.isEmpty ?? true {
                if messageObj.dTime == 0  {
                    payload = "Destruct timer set to off"

                }else{
                    if message == "" {
                        payload = "Destruct timer set to \(messageObj.dTime)"
                    }else {
    //                    if message == Utility.getUserFullName() {
    //                        payload = "Destruct timer set to \(messageObj.dTime)"
    //                    }else {
    //                        if message == self.userNameOutlet.text! {
    //                            payload = "Destruct timer set to \(messageObj.dTime)"
    //                        }else{
    //                            payload = "Secret chat message"
    //                        }
    //                    }
                        payload = "Destruct timer set to \(messageObj.dTime)"

                    }
                }
            }else{
                payload = "Secret chat message"
            }

        }else if messageObj.messagePayload?.isEmpty == true && messageObj.dTime == 0 && messageObj.messageType != .callMessage && messageObj.messageType != .missedCallMessage {
            payload = "Destruct timer set to off"
        }
        
        self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: payload, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
        self.lastTimeForMsgOutlet.text = self.chatVMObj.newMessageTime
        if messageObj.isMediaMessage {
            self.setLastMediaMessage(withMessage : messageObj, isSelfMsg: messageObj.isSelfMessage)
        }
    }
    
    func getLastMessageIfMessageArrayIsNotThere(chatVMObject: ChatViewModel){
        let messageType = chatVMObject.chat.lastMessageType
        let isSelfMsg = chatVMObject.chat.isSelfChat
        let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]
        print("types********\(messageType)")
        switch messageType {
        case "0":
            break
        case "1":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got an image".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent an image".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "2":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a video".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a video".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "3":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a location".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a location".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "4":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a contact".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a contact".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "5":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got an audio".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent an audio".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "6":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a sticker".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a sticker".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "7":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a doodle".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a doodle".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "8":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a gif".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a gif".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "9":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a document".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a document".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "10":
            break
        case "11":
            self.deleteiconOutlet.isHidden = false
            self.lastMessageOutlet.attributedText = getDeleteString()
            break
        case "13":
            if isSelfMsg == false {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a post".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            } else {
                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a post".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            }
            break
        case "16":
            print("")
        case "17":
            print("")
        default:
            print("")
        }
    }
    
    
    func setLastMediaMessage(withMessage messageObj : Message, isSelfMsg : Bool) {
        let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]
        if let messageMediaType:MessageTypes = messageObj.messageType {
            switch messageMediaType {
                
            case .text:
                break;
                
            case .image:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got an image".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent an image".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
            case .video:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a video".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a video".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break;
                
            case .location:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a location".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a location".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
            case .contact:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a contact".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a contact".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break;
                
            case .audio:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got an audio".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent an audio".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break;
                
            case .sticker:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a sticker".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a sticker".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break;
                
            case .doodle:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a doodle".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a doodle".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break;
                
            case .gif:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a gif".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a gif".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break;
                
            case .document:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a document".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a document".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break;
                
            case .replied:
                if let repliedMsgObj = messageObj.repliedMessage {
                    if let messageMediaType:MessageTypes = repliedMsgObj.replyMessageType {
                        switch messageMediaType {
                            
                        case .text:
                            break;
                            
                        case .image:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got an image".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent an image".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                        case .video:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a video".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a video".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break;
                            
                        case .location:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a location".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a location".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                        case .contact:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a contact".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a contact".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break;
                            
                        case .audio:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got an audio".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent an audio".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break;
                            
                        case .sticker:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a sticker".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a sticker".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break;
                            
                        case .doodle:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a doodle".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a doodle".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break;
                            
                        case .gif:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a gif".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a gif".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break;
                            
                        case .document:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a document".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a document".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break;
                            
                        case .replied:
                            
                            break;
                        case .deleted:
                            self.lastMessageOutlet.attributedText = getDeleteString()
                            break
                        case .post:
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a post".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a post".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break
                        case .transfer:
                            break
                        case .missedCallMessage:
                            var message = "You missed a call".localized
                            if let callType = messageObj.callType , callType == 1{
                                message = "You missed a video call".localized
                            }else{
                                message = "You missed an audio call".localized
                            }
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: message, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: message, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break
                        case .callMessage:
                            var message = "You missed a call".localized
                            if let callType = messageObj.callType , callType == 1{
                                message = "You missed a video call".localized
                            }else{
                                message = "You missed an audio call".localized
                            }
                            if isSelfMsg == false {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: message, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            } else {
                                self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: message, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                            }
                            break
                        }
                    }
                }
                /////////
                break;
            case .deleted:
                self.deleteiconOutlet.isHidden = false
                self.lastMessageOutlet.attributedText = getDeleteString()
                break
            case .post:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a post".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a post".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break
            case .transfer:
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You have got a payment".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "You sent a payment".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break
            case .missedCallMessage:
                var message = "You missed a call".localized
                if let callType = messageObj.callType , callType == 1{
                    message = "You missed a video call".localized
                }else{
                    message = "You missed an audio call".localized
                }
                if isSelfMsg == false {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: message, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                } else {
                    self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: message, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                }
                break
            case .callMessage:
                 self.lastMessageOutlet.attributedText = NSMutableAttributedString(string: "Call".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                break
            }
        }
    }
    
    func getDeleteString() -> NSMutableAttributedString {
        let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.italicSystemFont(ofSize: 13)]
        let attributedString = NSMutableAttributedString(string: "    " + "This message was deleted".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
        return attributedString
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellDataForSearchedMessage(data: [String : Any]){
        let msg = data["message"] as! Message
        let chatObj = data["chatViewModel"] as! Chat
        let chatViewModelObj = ChatViewModel(withChatData: chatObj)
        self.userNameOutlet.text = chatViewModelObj.name
        if  chatViewModelObj.isGroupChat {
            self.userNameOutlet.text = chatViewModelObj.groupName
        }
        self.lastMessageOutlet.text = msg.messagePayload
        if chatViewModelObj.isGroupChat {
            self.userImageOutlet.image = #imageLiteral(resourceName: "group_defaultImage")
        }else {
            Helper.addedUserImage(profilePic: chatViewModelObj.imageURL?.absoluteString, imageView: self.userImageOutlet, fullName: chatViewModelObj.name)
        }
        if let imageURL = chatViewModelObj.imageURL {
            if chatViewModelObj.isGroupChat{
                self.userImageOutlet.kf.setImage(with:  imageURL, placeholder: #imageLiteral(resourceName: "group_defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil) { (result) in
                    print(result)
                }
            }else{
                if chatViewModelObj.isUserBlock {
                    Helper.addedUserImage(profilePic: nil, imageView: self.userImageOutlet, fullName: chatViewModelObj.name)
                }else {
                    Helper.addedUserImage(profilePic: imageURL.absoluteString, imageView: self.userImageOutlet, fullName: chatViewModelObj.name)
                }
               
            }
        }
        let date = self.getDateObj(fromTimeStamp: msg.timeStamp!)
        self.lasDateMessageOutlet.text = self.lastMessageTime(date: date)
        self.lastTimeForMsgOutlet.text = self.lastSeenTime(date: date)
//        self.lastMessageDateContstraintOutlet.constant = 7
    }
    
    
    func getDateObj(fromTimeStamp timeStamp: String) -> Date {
        let tStamp =  UInt64(timeStamp)!
        let timeStampInt = tStamp/1000
        let msgDate = Date(timeIntervalSince1970: TimeInterval(timeStampInt))
        return msgDate
    }
    
    func lastMessageTime(date: Date)->String {
        let dateFormatter = DateFormatter()
        let today = NSCalendar.current.isDateInToday(date)
        if(today) {
            return "Today".localized
        }
        else if(NSCalendar.current.isDateInYesterday(date)){
            return "Yesterday".localized
        }
        else{
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
    }
    
    func lastSeenTime(date : Date) -> String {
        let dateFormatter = DateFormatter()
        let today = NSCalendar.current.isDateInToday(date)
        dateFormatter.dateFormat = "hh:mm a"
        if(today){
            return dateFormatter.string(from: date)
        }
        else if(NSCalendar.current.isDateInYesterday(date)){
            return "Yesterday".localized + " \(dateFormatter.string(from: date))"
        }
        else{
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
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
