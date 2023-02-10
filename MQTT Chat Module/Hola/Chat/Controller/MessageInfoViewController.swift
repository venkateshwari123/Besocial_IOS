//
//  MessageInfoViewController.swift
//  Infra.Market Messenger
//
//  Created by 3Embed Software Tech Pvt Ltd on 24/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Kingfisher

class MessageInfoViewController: JSQMessagesViewController {
    
    var message: Message?
    var isGroup: Bool = false
    var isReplying: Bool = false
    var chatDocID: String!
    var chatId: String?
    var memberCount: Int = 1
    
    var messageInfoViewModel = MessageInfoViewModel()
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.lightGray)
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.darkGray)
    
    struct cellIdentifier {
        static let singleChatDeliveryStatusCVCell = "SingleChatDeliveryStatusCVCell"
    }
    //MARK:- View life cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCollectioViewCell()
        self.initialSetUp()
        if self.isGroup{
            self.messageInfoViewModel.totalMember = self.memberCount
            self.getGroupMessageStatusData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    /// To register all collection view cell
    func registerCollectioViewCell(){
        self.collectionView?.register(JSQMessagesCollectionViewCellOutgoing.nib(), forCellWithReuseIdentifier: JSQMessagesCollectionViewCellOutgoing.cellReuseIdentifier())
        super.collectionView?.register(UINib(nibName: "SentLocationCell", bundle: nil), forCellWithReuseIdentifier: "SentLocationCell")
        super.collectionView?.register(UINib(nibName: "SentContactMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SentContactMessageCollectionViewCell")
        self.collectionView?.register(UINib(nibName: "SNTextMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SNTextMessageCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "ImageSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "StickerSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StickerSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "VideoSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "AudioSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AudioSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "AudioSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AudioSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "DocumentSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DocumentSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "PostSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostSentCollectionViewCell")
        // Registering Replied Cells
        
        //Replied Sent Text
        super.collectionView?.register(UINib(nibName: "SentTextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SentTextCollectionViewCell")
        
        // Replied Audio Sent
        super.collectionView?.register(UINib(nibName: "RepliedAudioSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedAudioSentCollectionViewCell")
        
        // Replied Sent Contact
        super.collectionView?.register(UINib(nibName: "RepliedSentContactMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedSentContactMessageCollectionViewCell")
        
        // Replied Document Sent
        super.collectionView?.register(UINib(nibName: "RepliedDocumentSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedDocumentSentCollectionViewCell")
        
        //Replied Image Sent
        super.collectionView?.register(UINib(nibName: "RepliedImageSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedImageSentCollectionViewCell")
        
        //Replied Sent Location
        super.collectionView?.register(UINib(nibName: "RepliedSentLocationCell", bundle: nil), forCellWithReuseIdentifier: "RepliedSentLocationCell")
        
        //Replied Sticker Sent
        super.collectionView?.register(UINib(nibName: "RepliedStickerSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedStickerSentCollectionViewCell")
        
        // Replied Video Sent
        super.collectionView?.register(UINib(nibName: "RepliedVideoSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedVideoSentCollectionViewCell")
        
        //Deleted Sent
        super.collectionView?.register(UINib(nibName: "DeletedSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DeletedSentCollectionViewCell")
        
        //GpMessage Type
        super.collectionView?.register(UINib(nibName: "GpMessageTypeCell", bundle: nil), forCellWithReuseIdentifier: "GpMessageTypeCell")
        
        //message status type
        super.collectionView?.register(UINib(nibName: "SingleChatDeliveryStatusCVCell", bundle: nil), forCellWithReuseIdentifier: "SingleChatDeliveryStatusCVCell")
        super.collectionView?.register(UINib(nibName: "GroupChatDeliveryStatusCVCell", bundle: nil), forCellWithReuseIdentifier: "GroupChatDeliveryStatusCVCell")
    }
    
    func initialSetUp(){
        self.inputToolbar.isHidden = true
        self.navigationItem.title = "Message Info".localized
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width:0.0, height:0.0)
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width:0.0, height:0.0)
        self.collectionView?.collectionViewLayout.springinessEnabled = false
        self.automaticallyScrollsToMostRecentMessage = true
    }
    
    override func senderId() -> String {
        guard let selfID = Utility.getUserid() else{return ""}
        return selfID
    }
    
    override func senderDisplayName() -> String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
    
    
    
    //MARK:- Service call
    func getGroupMessageStatusData(){
        
        self.messageInfoViewModel.getMessageDetails(message: self.message!, chatId: self.chatId!) { (success, error) in
            if success{
                super.collectionView?.reloadData()
            }
        }
    }
}


// MARK: - Collection View Delegate
extension MessageInfoViewController
{
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    
    //MARK: Number of items in view
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isGroup{
            return self.messageInfoViewModel.numberOfRowInGroupMessageStatus()
        }
        return 2
    }
    
    //MARK: Data on cell
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return message!
    }
    
    //MARK: After deletion of message at index path
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didDeleteMessageAt indexPath: IndexPath) {
        // self.toDeleteMessageWith(indexPath:indexPath)
    }
    
    //MARK: To configure outgong or incomming bubble
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
         return outgoingBubble
    }
    
    //MARK: For Avatar Images
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    //MARK: To show name above message
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        return nil
    }
    
    //MARK: Setting up collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let jsqcell = (super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell)
            jsqcell.backgroundColor = Color.clear
            jsqcell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
            //        jsqcell.accessoryButton?.isHidden = false
            //        jsqcell.accessoryButton?.setImage(#imageLiteral(resourceName: "forward_icon"), for: .normal)
            //        jsqcell.snMessageDelegate = self
            guard let msg = self.message else {return jsqcell}
            if let messageMediaType:MessageTypes = msg.messageType {
                switch messageMediaType {
                case .image:
                    if msg.isSelfMessage {
                        var cell : ImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageSentCollectionViewCell", for: indexPath) as! ImageSentCollectionViewCell
                        
                        //Creating View Modal from Image Message
                        let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                        imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                        //                    cell.isReplying = self.isReplying
                        //                    cell.replyMsg = self.replyingMessage
                        cell.imageMsgType = messageMediaType
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell.chatDocID = self.chatDocID
                        cell.msgVMObj = imageMsgVMobj
                        //                    cell.panGestureRecognizer?.delegate = self
                        //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! ImageSentCollectionViewCell
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        //                    cell.imageTappedDelegate = self
                        return cell
                    }
                    
                case .location:
                    if msg.isSelfMessage {
                        var cell : SentLocationCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "SentLocationCell", for: indexPath) as! SentLocationCell
                        cell.backgroundColor = UIColor.clear
                        cell.msgObj = msg
                        //                    cell.locationDelegate = self
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! SentLocationCell
                        //                    cell.panGestureRecognizer?.delegate = self
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        return cell
                    }
                    
                case .contact:
                    if msg.isSelfMessage {
                        var cell : SentContactMessageCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "SentContactMessageCollectionViewCell", for: indexPath) as! SentContactMessageCollectionViewCell
                        let contactMVMObj = ContactMessageViewModal(withMessage: msg)
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell.msgObj = contactMVMObj
                        //                    cell.contactMessageDelegates = self
                        //                    cell.msgObj.presentControllerDelegate = self
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! SentContactMessageCollectionViewCell
                        //                    cell.panGestureRecognizer?.delegate = self
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        return cell
                    }
                    
                case .doodle:
                    if msg.isSelfMessage {
                        var cell : ImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageSentCollectionViewCell", for: indexPath) as! ImageSentCollectionViewCell
                        
                        //Creating View Modal from Image Message
                        let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                        
                        //                    if self.isGroup == true{
                        //                        imageMsgVMobj.isGroup = self.isGroup
                        //                        imageMsgVMobj.groupMembers = self.groupMembers
                        //                        imageMsgVMobj.gpImage  = getProfilePic()
                        //                    }
                        
                        imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                        //                    cell.isReplying = self.isReplying
                        //                    cell.replyMsg = self.replyingMessage
                        cell.chatDocID = self.chatDocID
                        cell.imageMsgType = messageMediaType
                        cell.msgVMObj = imageMsgVMobj
                        //                    cell.imageTappedDelegate = self
                        //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! ImageSentCollectionViewCell
                        //                    cell.panGestureRecognizer?.delegate = self
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        return cell
                    }
                    
                case .video:
                    if msg.isSelfMessage {
                        var cell : VideoSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "VideoSentCollectionViewCell", for: indexPath) as! VideoSentCollectionViewCell
                        
                        //Creating View Modal from Video Message
                        let videoMsgVMobj = VideoMessageViewModal(withMessage: msg)
                        //                    if self.isGroup == true{
                        //                        videoMsgVMobj.isGroup = self.isGroup
                        //                        videoMsgVMobj.groupMembers = self.groupMembers
                        //                        videoMsgVMobj.gpImage  = getProfilePic()
                        //                    }
                        //                    cell.isReplying = self.isReplying
                        //                    cell.replyMsg = self.replyingMessage
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell.chatDocID = self.chatDocID
                        cell.msgVMObj = videoMsgVMobj
                        //Uploading video by using Video View Modal. And checking that video is not uploaded already.
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! VideoSentCollectionViewCell
                        //                    cell.videoTappedDelegate = self
                        //                    cell.panGestureRecognizer?.delegate = self
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        return cell
                    }
                    
                case .sticker:
                    if msg.isSelfMessage {
                        var cell : StickerSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "StickerSentCollectionViewCell", for: indexPath) as! StickerSentCollectionViewCell
                        
                        //Creating View Modal from Image Message
                        let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                        imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                        //                    cell.isReplying = self.isReplying
                        //                    cell.replyMsg = self.replyingMessage
                        cell.chatDocID = self.chatDocID
                        cell.msgVMObj = imageMsgVMobj
                        
                        //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! StickerSentCollectionViewCell
                        //                    cell.panGestureRecognizer?.delegate = self
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        return cell
                    }
                    
                case .gif:
                    if msg.isSelfMessage {
                        var cell : ImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageSentCollectionViewCell", for: indexPath) as! ImageSentCollectionViewCell
                        
                        //Creating View Modal from Image Message
                        let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                        
                        imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                        //                    cell.isReplying = self.isReplying
                        //                    cell.replyMsg = self.replyingMessage
                        cell.chatDocID = self.chatDocID
                        cell.msgVMObj = imageMsgVMobj
                        cell.imageMsgType = messageMediaType
                        //                    cell.imageTappedDelegate = self
                        //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! ImageSentCollectionViewCell
                        //                    cell.panGestureRecognizer?.delegate = self
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        return cell
                    }
                    
                case .document:
                    if msg.isSelfMessage {
                        var cell : DocumentSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "DocumentSentCollectionViewCell", for: indexPath) as! DocumentSentCollectionViewCell
                        let docMVMObj = DocumentMessageViewModal(withMessage: msg)
                        cell.documentMVMObj = docMVMObj
                        docMVMObj.chatDocID = self.chatDocID
                        //                    cell.documentMessageDelegate = self
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! DocumentSentCollectionViewCell
                        //                    cell.panGestureRecognizer?.delegate = self
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        return cell
                    }
                    
                case .audio:
                    //Creating View Modal from Image Message
                    if msg.isSelfMessage {
                        var cell : AudioSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "AudioSentCollectionViewCell", for: indexPath) as! AudioSentCollectionViewCell
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        
                        cell.msgObj = msg
                        //                    cell.audioPlayerDelegate = self
                        //                    let audioMVMObj = AudioMessageViewModal(withMessage: msg)
                        //                    if self.isGroup == true{
                        //                        audioMVMObj.isGroup = self.isGroup
                        //                        audioMVMObj.groupMembers = self.groupMembers
                        //                        audioMVMObj.gpImage  = getProfilePic()
                        //                    }
                        //                    audioMVMObj.isReplying = self.isReplying
                        //                    audioMVMObj.replyMsg = self.replyingMessage
//                        audioMVMObj.chatDocID = self.chatDocID
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! AudioSentCollectionViewCell
                        //                    cell.panGestureRecognizer?.delegate = self
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        return cell
                    }
                    
                case .text:
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        jsqcell.timeLabelOutlet?.attributedText = messageVMObj.setDateTime(isSelf: true)
                        jsqcell.currentStatusOutlet?.attributedText = messageVMObj.setReadStatus()
                        //                    jsqcell.panGestureRecognizer?.delegate = self
                        return jsqcell
                    
                case .replied:
                    if let repliedMsg = msg.repliedMessage {
                        if let messageMediaType =  repliedMsg.replyMessageType {
                            switch messageMediaType {
                            case .text:
                                if msg.isSelfMessage {
                                    var cell : SentTextCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "SentTextCollectionViewCell", for: indexPath) as! SentTextCollectionViewCell
                                    cell.msgObj = msg
                                    //                                cell.repliedButtonPressedDelegate = self
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! SentTextCollectionViewCell
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                                
                            case .image:
                                if msg.isSelfMessage {
                                    var cell : RepliedImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedImageSentCollectionViewCell", for: indexPath) as! RepliedImageSentCollectionViewCell
                                    
                                    //Creating View Modal from Image Message
                                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                    //                                cell.isReplying = self.isReplying
                                    //                                cell.replyMsg = self.replyingMessage
                                    
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell.chatDocID = self.chatDocID
                                    cell.msgVMObj = imageMsgVMobj
                                    cell.imageMsgType = messageMediaType
                                    //                                cell.repliedButtonPressedDelegate = self
                                    //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedImageSentCollectionViewCell
                                    //                                cell.imageTappedDelegate = self
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                                
                            case .location:
                                if msg.isSelfMessage {
                                    var cell : RepliedSentLocationCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedSentLocationCell", for: indexPath) as! RepliedSentLocationCell
                                    cell.backgroundColor = UIColor.clear
                                    cell.msgObj = msg
                                    //                                cell.locationDelegate = self
                                    //                                cell.repliedButtonPressedDelegate = self
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedSentLocationCell
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                                
                            case .contact:
                                if msg.isSelfMessage {
                                    var cell : RepliedSentContactMessageCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedSentContactMessageCollectionViewCell", for: indexPath) as! RepliedSentContactMessageCollectionViewCell
                                    let contactMVMObj = ContactMessageViewModal(withMessage: msg)
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell.msgObj = contactMVMObj
                                    //                                cell.contactMessageDelegates = self
                                    //                                cell.repliedButtonPressedDelegate = self
                                    //                                cell.msgObj.presentControllerDelegate = self
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedSentContactMessageCollectionViewCell
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                                
                            case .doodle:
                                if msg.isSelfMessage {
                                    var cell : RepliedImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedImageSentCollectionViewCell", for: indexPath) as! RepliedImageSentCollectionViewCell
                                    
                                    //Creating View Modal from Image Message
                                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                    //                                cell.isReplying = self.isReplying
                                    //                                cell.replyMsg = self.replyingMessage
                                    cell.chatDocID = self.chatDocID
                                    cell.msgVMObj = imageMsgVMobj
                                    cell.imageMsgType = messageMediaType
                                    //                                cell.imageTappedDelegate = self
                                    //                                cell.repliedButtonPressedDelegate = self
                                    //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedImageSentCollectionViewCell
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                                
                            case .video:
                                if msg.isSelfMessage {
                                    var cell : RepliedVideoSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedVideoSentCollectionViewCell", for: indexPath) as! RepliedVideoSentCollectionViewCell
                                    
                                    //Creating View Modal from Video Message
                                    let videoMsgVMobj = VideoMessageViewModal(withMessage: msg)
                                    //                                cell.isReplying = self.isReplying
                                    //                                cell.replyMsg = self.replyingMessage
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell.chatDocID = self.chatDocID
                                    cell.msgVMObj = videoMsgVMobj
                                    //                                cell.repliedButtonPressedDelegate = self
                                    //Uploading video by using Video View Modal. And checking that video is not uploaded already.
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedVideoSentCollectionViewCell
                                    //                                cell.videoTappedDelegate = self
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                                
                            case .sticker:
                                if msg.isSelfMessage {
                                    var cell : RepliedStickerSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedStickerSentCollectionViewCell", for: indexPath) as! RepliedStickerSentCollectionViewCell
                                    
                                    //Creating View Modal from Image Message
                                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                    //                                cell.isReplying = self.isReplying
                                    //                                cell.replyMsg = self.replyingMessage
                                    cell.chatDocID = self.chatDocID
                                    cell.msgVMObj = imageMsgVMobj
                                    //                                cell.repliedButtonPressedDelegate = self
                                    //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedStickerSentCollectionViewCell
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                                
                            case .gif:
                                if msg.isSelfMessage {
                                    var cell : RepliedImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedImageSentCollectionViewCell", for: indexPath) as! RepliedImageSentCollectionViewCell
                                    
                                    //Creating View Modal from Image Message
                                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                    //                                cell.isReplying = self.isReplying
                                    //                                cell.replyMsg = self.replyingMessage
                                    cell.chatDocID = self.chatDocID
                                    cell.msgVMObj = imageMsgVMobj
                                    //                                cell.imageTappedDelegate = self
                                    cell.imageMsgType = messageMediaType
                                    //                                cell.repliedButtonPressedDelegate = self
                                    //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedImageSentCollectionViewCell
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                                
                            case .document:
                                if msg.isSelfMessage {
                                    var cell : RepliedDocumentSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedDocumentSentCollectionViewCell", for: indexPath) as! RepliedDocumentSentCollectionViewCell
                                    let docMVMObj = DocumentMessageViewModal(withMessage: msg)
                                    //                                docMVMObj.isReplying = self.isReplying
                                    //                                docMVMObj.replyMsg = self.replyingMessage
                                    cell.documentMVMObj = docMVMObj
                                    docMVMObj.chatDocID = self.chatDocID
                                    //                                cell.documentMessageDelegate = self
                                    //                                cell.repliedButtonPressedDelegate = self
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedDocumentSentCollectionViewCell
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                                
                            case .audio:
                                //Creating View Modal from Image Message
                                if msg.isSelfMessage {
                                    var cell : RepliedAudioSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedAudioSentCollectionViewCell", for: indexPath) as! RepliedAudioSentCollectionViewCell
                                    let messageVMObj = MessageViewModal(withMessage: msg)
                                    cell.msgObj = msg
                                    //                                cell.audioPlayerDelegate = self
                                    //                                cell.repliedButtonPressedDelegate = self
                                    let audioMVMObj = AudioMessageViewModal(withMessage: msg)
                                    //                                audioMVMObj.isReplying = self.isReplying
                                    //                                audioMVMObj.replyMsg = self.replyingMessage
                                    audioMVMObj.chatDocID = self.chatDocID
                                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedAudioSentCollectionViewCell
                                    //                                cell.panGestureRecognizer?.delegate = self
                                    cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                                    return cell
                                }
                            case .replied:
                                //                            jsqcell.panGestureRecognizer?.delegate = self
                                return jsqcell
                                
                            case .deleted:
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
                    //                jsqcell.panGestureRecognizer?.delegate = self
                    return jsqcell
                    
                case .deleted:
                    if msg.isSelfMessage {
                        var cell : DeletedSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "DeletedSentCollectionViewCell", for: indexPath) as! DeletedSentCollectionViewCell
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! DeletedSentCollectionViewCell
                        //                    cell.panGestureRecognizer?.delegate = self
                        return cell
                    }
                case .post:
                    if msg.isSelfMessage{
                        var cell : PostSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "PostSentCollectionViewCell", for: indexPath) as! PostSentCollectionViewCell
                        
                        //Creating View Modal from Post Message
                        let postMsgVMobj = PostMessageViewModel(withMessage: msg)

                        postMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                        cell.imageMsgType = messageMediaType
                        let messageVMObj = MessageViewModal(withMessage: msg)
                        cell.chatDocID = self.chatDocID
                        cell.msgVMObj = postMsgVMobj
                        cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! PostSentCollectionViewCell
                        cell.postNameLabel.text = msg.postTitle
                        cell.postType = msg.postType
                        cell.forwardButtonOutlet.isHidden = true
                        cell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "defaultBackground"))
                        return cell
                    }
                case .transfer:
                    break
                case .missedCallMessage:
                    break
                case .callMessage:
                    break
                }
            }
            //        jsqcell.panGestureRecognizer?.delegate = self
            return jsqcell
        }else{
            if self.isGroup{
                guard let cell : GroupChatDeliveryStatusCVCell = super.collectionView?.dequeueReusableCell(withReuseIdentifier: "GroupChatDeliveryStatusCVCell", for: indexPath) as? GroupChatDeliveryStatusCVCell else{fatalError()}
                let cellData = self.messageInfoViewModel.getDataToAssignInCell(index: indexPath.row)
                cell.setGroupChatStatusData(status: cellData.0, isRead: cellData.1, remaining: cellData.2)
                return cell
            }else{
                guard let cell : SingleChatDeliveryStatusCVCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "SingleChatDeliveryStatusCVCell", for: indexPath) as? SingleChatDeliveryStatusCVCell else{fatalError()}
                cell.setStatusCellData(message: self.message)
                return cell
            }
        }
    }
    
    //MARK: To show timestamp above message
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    //MARK: Height of cell to show timestamp
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        return 0.0
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        //set height for group Msg Tag
//        if isGroup {
//            let msg = self.messages[indexPath.item]
//            if  msg.gpMessageType != "" {
//                return 0.0
//            }
//        }
//
//        if isGroup == false { return 0.0}
//        let msg = self.messages[indexPath.item]
//        if indexPath.item - 1 > 0 {
//            let prevMsg = self.messages[indexPath.item - 1]
//            if prevMsg.senderId == msg.senderId {
//                return 0.0
//            }
//        }
        return 10.0
    }
    
    //MARK: Responding to collection view tap events
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat {
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapCellAt indexPath: IndexPath, touchLocation: CGPoint) {
        self.inputToolbar.contentView?.textView?.resignFirstResponder()
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0{
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }else{
            if self.isGroup{
                let height = self.messageInfoViewModel.heightOfRowAtIndex(index: indexPath.item)
                return CGSize(width: self.view.frame.size.width, height: height)
            }else{
                return CGSize(width: self.view.frame.size.width, height: 130)
            }
        }
    }
}
