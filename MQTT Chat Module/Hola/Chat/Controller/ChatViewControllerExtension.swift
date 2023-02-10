//
//  ChatViewControllerExtension.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 11/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation
import TLPhotoPicker
import UIKit
import AVFoundation
import ContactsUI
import Contacts
import JSQMessagesViewController
import Photos
import MessageUI
import SafariServices
import MobileCoreServices
import Locksmith
import Alamofire


//MARK:- Image Cell Tapped Delegate
extension ChatViewController : ImageCellTappedDelegate {
    func imageCellTapped(withImageMVModal imageMVModalObect: ImageMessageViewModal) {
        self.inputToolbar.contentView?.textView?.resignFirstResponder()
        self.openMediaController(withMsgObj: imageMVModalObect.message)
    }
    
    
    func imageForwardActionCliked(_ cell: ImageSentCollectionViewCell) {
        
        self.tappedOnForward(cell)
    }
    
    func receivedImageForwardActionCliked(_ cell: ImageReceivedCollectionViewCell) {
        self.tappedOnForward(cell)
    }
}

//MARK:- Post Cell Tapped Delegate
extension ChatViewController : PostCellTappedDelegate {
    func postCellTapped(withPostMVModal postMVModalObect: PostMessageViewModel) {
        self.inputToolbar.contentView?.textView?.resignFirstResponder()
        if AppConstants.appType == .picoadda {
            Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: nil, needToCallApi: true, postId: postMVModalObect.message.postId!)
        }else{
            Route.navigateToAllPostsVertically(navigationController: self.navigationController,postId:  postMVModalObect.message.postId!,isCommingFromChat:true)
        }
        
    }
    
    func postForwardActionCliked(_ cell: PostSentCollectionViewCell) {
        self.tappedOnForward(cell)
    }
}

//MARK:- sticker Cell forward Delegate
extension ChatViewController : StickerCollectionViewCellDelegate {
    
    func sentStickerForwardAction(_ cell: StickerSentCollectionViewCell) {
        self.tappedOnForward(cell)
    }
    
    func receivedStickerForwardAction(_ cell: StickerReceivedCollectionViewCell) {
        self.tappedOnForward(cell)
    }
}

//MARK:- Video Cell Tapped Delegate
extension ChatViewController : VideoCellTappedDelegate {
    func videoCellTapped(withVideoMVModal videoMVModalObect: VideoMessageViewModal) {
        self.inputToolbar.contentView?.textView?.resignFirstResponder()
        self.openMediaController(withMsgObj: videoMVModalObect.message)
    }
    
    func videoForwardActionCliked(_ cell: VideoSentCollectionViewCell) {
        self.tappedOnForward(cell)
    }
    
    func receivedVideoForwardClicked(_ cell: VideoReceivedCollectionViewCell) {
        self.tappedOnForward(cell)
    }
}

// MARK: - Media Controller with Media
extension ChatViewController {
    /// Used for opening media controller with current media
    func openMediaController(withMsgObj msgObj : Message) {
        let showMediaViewCntroller = ShowMediaViewController(nibName: "ShowMediaViewController", bundle: nil)
        guard let msgs = self.chatsDocVMObject.getMediaMessages(withChatDocID: self.chatDocID) else { return }
        showMediaViewCntroller.messages = msgs
        showMediaViewCntroller.selectedMessageUrl = msgObj.getVideoFileName()
        showMediaViewCntroller.modalPresentationStyle = .fullScreen
        self.present(showMediaViewCntroller, animated: false, completion: nil)
    }
}

// MARK: - Location Cell Delegate
extension ChatViewController : LocationCellDelegate {
    func locationForwardActionCliked(_ cell: SentLocationCell) {
        self.tappedOnForward(cell)
    }
    
    func receivedForwardActionClicked(_ cell: ReceivedLocationCell) {
        self.tappedOnForward(cell)
    }
    
    func tapOnLocationDelegate(messageObj: Message) {
        self.inputToolbar.contentView?.textView?.resignFirstResponder()
        self.goToShowLocationViewController(message: messageObj)
    }
    
    func goToShowLocationViewController(message: Message) {
        if let messageType = message.messageType {
            if messageType == MessageTypes.location {
                if (message.messagePayload != nil) {
                    self.performSegue(withIdentifier: Constants.showLocationSegue, sender: message.messagePayload)
                }
            }
        }
    }
}

//MARK:- Document Delegate
extension ChatViewController:documentDelegate {
    
    func didPickDocument(docUrl: URL) {
        self.sendDocMessage(withDocLocalURL: docUrl as NSURL, andMediaTypes: "9")
    }
    
    func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    func sendDocMessage(withDocLocalURL docURL: NSURL, andMediaTypes type: String) {
        if self.chatDocID != nil {
            UserDefaults.standard.setValue("", forKey:self.chatDocID)
        }
        // Creating image message with thumbnail Image.
        self.chatDocID = self.getChatDocID()
        let docData = NSData(contentsOf: docURL as URL)
        guard let docSize = docData?.length else { return }
        var docDict = [String : Any]()
        let fileTYpe = self.mimeTypeForPath(path: docURL.absoluteString!)
        docDict["fileName"]
            = docURL.lastPathComponent
        docDict["mimeType"] = fileTYpe
        docDict["extension"] = docURL.pathExtension
        guard let docMsgObj = self.getMediaMessageObj(withMediaURL: docURL, isSelf: true, withMediaType: type, withMessageData: docDict) else { return }
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        self.updateChatDocIDIntoContactDB()
        guard var msgObj = chatsDocVMObject.makeMessageForSendingBetweenServers(withData: nil, withMediaSize: Int(docSize), andMediaURL: docURL.absoluteString!, withtimeStamp: docMsgObj.timeStamp, andType: type, documentData: docDict, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage, senderID: self.senderId(), receiverId: self.receiverID, chatDocId: self.chatDocID) else { return }
        
        
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            msgObj["secretId"] = chatViewModelObj?.secretID
            var timer = 0
            if  let time = UserDefaults.standard.object(forKey:(chatViewModelObj?.secretID)!) as? Int{
                timer = time
            }
            msgObj["dTime"] = timer
        }
        
        
        self.messages.append(docMsgObj)
        if let chatDta = couchbaseObj.getData(fromDocID: chatDocID) {
            chatsDocVMObject.updateChatData(withData: chatDta, msgObject : docMsgObj as Any, inDocID  : chatDocID, isCreatingChat: false)
        }
        guard let MsgObjForDB = chatsDocVMObject.getMessageObject(fromData: msgObj, withStatus: "0", isSelf: true, fileSize: Double(docSize), documentData: docDict, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage) else { return }
        self.chatsDocVMObject.updateChatDoc(withMsgObj: MsgObjForDB, toDocID: chatDocID)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.finishSendingMessage(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.removeReplyView()
            }
        }
    }
}

// MARK: - Media Message creation
extension ChatViewController {
    
    func getMediaMessageObj(withMediaURL mediaURL : NSURL, isSelf : Bool, withMediaType type: String, withMessageData messageData: [String : Any]?) -> Message? {
        guard var msgData = self.getMediaMessageParams(withMediaURL:  mediaURL, isSelf: isSelf, mediaURL: nil, withMediaType: type, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage) else { return nil }
        
        
        var timer = 0
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            if  let time = UserDefaults.standard.object(forKey:(chatViewModelObj?.secretID)!) as? Int{
                timer = time
            }
            msgData["secretId"] = chatViewModelObj?.secretID
            msgData["dTime"] = timer
        }
        
        let message = Message(forData: msgData, withDocID: self.chatDocID, andMessageobj: msgData, isSelfMessage: isSelf, mediaStates : .notUploaded, mediaURL : mediaURL.absoluteString!, thumbnailData: nil, secretID: nil,receiverIdentifier : "", messageData : messageData, isReplied: self.isReplying,gpMessageType: "",dTime : timer, readTime: 0.0, deliveryTime: 0.0)
        return message
    }
    
    func getMediaMessageParams(withMediaURL resourceURL : NSURL, isSelf : Bool, mediaURL : String?, withMediaType type: String, isReplying: Bool, replyingMsgObj: Message?) -> [String : Any]? {
        let timeStamp : String = "\(UInt64(floor(Date().timeIntervalSince1970 * 1000)))"
        var params = [String :Any]()
        let userDocVMObject = UsersDocumentViewModel(couchbase: couchbaseObj)
        guard let userData = userDocVMObject.getUserData() else { return nil }
        guard let mediaSize = NSData(contentsOf: resourceURL as URL)?.length else { return nil }
        if isSelf {
            params["from"] = userData["userID"]! as Any
            params["to"] = self.receiverID! as Any
        } else {
            params["from"] = self.receiverID! as Any
            params["to"] = userData["userID"]! as Any
        }
        if let url = mediaURL {
            params["payload"] = url as Any
            let encodedUrl = url.replace(target: "\n", withString: "")
            if let decodedUrl = encodedUrl.fromBase64() {
                params["mediaURL"] = decodedUrl as Any
            }
        }
        params["toDocId"] = self.chatDocID! as Any
        params["timestamp"] = timeStamp as Any
        params["id"] = timeStamp as Any
        params["type"] = type as Any
        params["dataSize"] = mediaSize as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["userName"]! as Any
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        
        
        if isReplying == true, let replyMsg = replyingMsgObj {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = replyMsg.messageType {
                params["previousPayload"] = pPload as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = type as Any
                params["type"] = "10" as Any
                params["previousReceiverIdentifier"] = prIdentifier as Any
                params["previousId"] = msgId as Any
             //   params["previousType"] = "\(previousType.hashValue)" as Any
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
                    if let repliedMsg = self.replyingMessage?.repliedMessage {
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
    
    
    
}

//MARK:- VoiceRecorder delegate
extension ChatViewController : SKRecordViewDelegate {
    func SKRecordViewDidCancelRecord(_ sender: SKRecordView, button: UIView) {
        sender.state = .none
        var imageName = "voiceRecorderImg"
        if Utility.isDarkModeEnable(){
            imageName = "voiceRecorderImgwhite"
        }else{
            imageName = "voiceRecorderImg"
        }

        sender.setupRecordButton(UIImage.init(named:imageName)!)
        recordingView.audioRecorder?.stop()
        self.inputToolbar.contentView?.alpha = 1.0
        recordingView.recordButton.imageView?.stopAnimating()
    }
    
    func SKRecordViewDidSelectRecord(_ sender: SKRecordView, button: UIView) {
        if let player = self.currentPlayingAudioPlayer {
            player.stop(clearQueue: true)
        }
        let cameraMediaType = convertFromAVMediaType(AVMediaType.audio)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
        } catch let error {
            print(error.localizedDescription)
        }
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: cameraMediaType))
        switch cameraAuthorizationStatus {
        case .denied:
            self.showdefaultAlert(title: "Oops".localized, message: AppConstants.audioPermissionMsg)
            return
        case .authorized: break
        case .restricted: break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for:AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.audio)), completionHandler: { isGranted in
                if !isGranted {
                    OperationQueue.main.addOperation({
                        self.showdefaultAlert(title: "Oops".localized, message: AppConstants.audioPermissionMsg)
                    })
                    return
                }
            })
        }
        sender.state = .recording
        sender.setupRecordButton(UIImage(named: "rec1")!)
        sender.setupRecorder()
        self.stopRunningAudioIfAny()
        sender.audioRecorder?.record()
        recordingView.recordButton.imageView?.startAnimating()
        self.inputToolbar.contentView?.alpha = 0.0
    }
    
    func SKRecordViewDidStopRecord(_ sender: SKRecordView, button: UIView) {
        self.inputToolbar.contentView?.alpha = 1.0
        recordingView.audioRecorder?.stop()
        sender.state = .none
        var imageName = "voiceRecorderImg"
        if Utility.isDarkModeEnable(){
            imageName = "voiceRecorderImgwhite"
        }else{
            imageName = "voiceRecorderImg"
        }
        
        sender.setupRecordButton(UIImage(named: imageName)!)
        //Get url from here
        self.sendAudioMessage(withAudioLocalURL: recordingView.getFileURL() as NSURL, andMediaTypes: "5")
    }
    
    
    /// To stop current running audio player if any
    func stopRunningAudioIfAny(){
        if let player = self.currentPlayingAudioPlayer {
            player.stop(clearQueue: true)
            if let curPlayButton = self.currentPlayingButton{
                curPlayButton.isSelected = false
            }
        }
    }
}

// MARK:-  LocationPicker delegate
extension ChatViewController:locationPickDelegate, SearchAddressDelegate {
    func searchAddressDelegateMethod(_ addressModel: AddressModel) {
        let msgStr = "(\(addressModel.latitude),\(addressModel.longitude))@@\(addressModel.addressLine1)@@ "
        sendMessageObjForLocation(withAddress : msgStr)
        if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)
        }
    }
    
    func didSendselectedlocation(address name: String, location latLog: [String : Any]) {
        if let lat = latLog["lat"] as? String, let log = latLog["log"] as? String {
            let msgStr = "(\(lat),\(log))@@\(name)@@ "
            sendMessageObjForLocation(withAddress : msgStr)
            if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
        }
    }
    
    private func sendMessageObjForLocation(withAddress address: String) {
        if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
        self.updateMessageUIAfterSendingMessage(withText: address, andType: "3", withData: nil)
    }
}

//MARK:- ShareConactPicker delegate
extension ChatViewController:shareContactDelegate,ShowContactScreenDelegate {
    
    func selectedContact(_ contact: CNContact) {
        let story = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
        let navigation = story.instantiateViewController(withIdentifier: "ShowContactScreenTableView") as? UINavigationController
        let shareView =   navigation?.topViewController as! ShowContactScreenTableViewController
        var numbers = [String]() , types = [String]()
        
        for kk in contact.phoneNumbers {
            let num = Helper.removeSpecialCharsFromString(text: kk.value.stringValue)
            let  type = kk.label ?? ""
            if num.count > 0 {
                numbers.append(num)
                types.append(CNLabeledValue<NSString>.localizedString(forLabel: type))
            }
        }
        shareView.name = contact.givenName + contact.familyName
        shareView.typeLable = types
        shareView.mobileNumber = numbers
        shareView.delegate = self
        contactobj = contact
        self.present(navigation!, animated: true, completion: nil)
    }
    
    func didSendCliked() {
        //send this selected Contact here
        let contactStr = self.createSharingContact(withContactObj: contactobj!)!
        self.updateMessageUIAfterSendingMessage(withText: contactStr, andType: "4", withData: nil)
        if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
    }
    
    func createSharingContact(withContactObj contactObj : CNContact) -> String? {
        var fullName = "", type = ""
        if contactObj.givenName.count>0 {
            fullName = contactObj.givenName
        }
        if contactObj.familyName.count>0 {
            fullName = fullName + " " + contactObj.familyName
        }
        if fullName.count == 0 {
            fullName = "Unknown".localized
        }
        let numbers = fullName + "@@"
        var fullNumbers = "No Number".localized
        for (index, number) in contactObj.phoneNumbers.enumerated() {
            let num = Helper.removeSpecialCharsFromString(text: number.value.stringValue)
            if num.count > 0 {
                if index == 0 {
                    type = CNLabeledValue<NSString>.localizedString(forLabel: number.label ?? "")
                    fullNumbers = num + "/" + type
                    if let userID = favoriteViewModel.getUserID(forContactNumber: num)?.userID {
                        fullNumbers = num + "/" + type + "{" + userID
                    }
                    
                } else {
                    type = CNLabeledValue<NSString>.localizedString(forLabel: number.label ?? "")
                    fullNumbers = fullNumbers + "@@" + num + "/" + type
                    if let userID = favoriteViewModel.getUserID(forContactNumber: num)?.userID {
                        fullNumbers = fullNumbers + "@@" + num + "/" + type + "{" + userID
                    }
                }
            }
        }
        let totalNum = numbers + fullNumbers
        return totalNum
    }
}

//MARK:- ImagePicker delegate
extension ChatViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        guard let mediaType = info["UIImagePickerControllerMediaType"] as? String else { return }
        if(mediaType == "public.image") {
            guard let imageToSend = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else { return }
            let name  = arc4random_uniform(900000) + 100000;
            let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
            AFWrapper.updloadPhoto(withPhoto: imageToSend, andName: "\(name)\(timeStamp)", progress: {_ in }, success: {_ in }, failure: {_ in })
            self.dismiss(animated: true, completion: nil)
            
            let story = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
            let preview =  story.instantiateViewController(withIdentifier: "ImagePickerPreview") as? ImagePickepreviewController
            preview?.imageArray = [imageToSend]
            preview?.delegate = self
            preview?.isComingFromCamera = true
            /* Bug Name :  SINGLE CHAT While sharing images , images can be edited
             the push the chat details page should open"
             Fix Date : 12-apr-2021
             Fixed By : Jayaram G
             Description Of Fix : Presenting the view in fullscreen
             */
            preview?.modalPresentationStyle = .fullScreen
            self.present(preview!, animated: true, completion: nil)
        }
        else {
            guard  let videoURL = info["UIImagePickerControllerMediaURL"] as? NSURL else { return }
            self.sendVideoMessage(withVideoLocalURL: videoURL, andMediaTypes: "2")
            if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ChatViewController:ImagepreviewDelegate {
    func didCancelCliked() {
        print("cancel")
    }
    
    private func uploadMedia(withMedia media: Any) {
        if let mediaObj = media as? TLPHAsset {
            if mediaObj.type == .photo {
                if let currentImage = mediaObj.fullResolutionImage {
                    self.addImageMessage(withImage: currentImage, andMediaType: "1")
                }
            } else if mediaObj.type == .video {
                /* Bug Name :  On sending a video more than 20 mb it is not playing——it takes time to load(Please add a loading pop up to notify the video is loading)
                 Fix Date : 24-Jul-2021
                 Fixed By : Jayaram G
                 Description Of Fix : chekcing video size and added loader
                 */
                mediaObj.videoSize { size in
                    print("selected video size \(size)")
                    let sizeMB = size / 1000000
                    if sizeMB > 50 {
                        Helper.toastViewForReachability(messsage: "Can't send video greater than 50MB".localized + "..!", view: self.view)
                        return
                    }else{
                        DispatchQueue.main.async {
                            Helper.addLoader()
                        }
                        self.getVideoPath(withPhAsset: mediaObj.phAsset!, completion: { (videoLocalURL) in
                            guard let videoUrl = videoLocalURL else {return}
                            let path = NSTemporaryDirectory() + UUID().uuidString + ".mov"
                            let outputURL = URL.init(fileURLWithPath: path)
                            self.compressVideo(inputURL: videoUrl as NSURL, outputURL: outputURL as NSURL, handler: { (handler) in
                                if handler.status == AVAssetExportSession.Status.completed {
                                    DispatchQueue.main.async {
                                        Helper.hideLoader()
                                    }
                                    
                                    self.sendVideoMessage(withVideoLocalURL: outputURL as NSURL, andMediaTypes: "2")
                                } else if handler.status == AVAssetExportSession.Status.failed {
                                    print("Error on compression")
                                }
                            })
                        })
                    }
                }
            }
        } else if let imageObj = media as? UIImage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.addImageMessage(withImage: imageObj, andMediaType: "1")
            }
        }
    }
    
    func didSendCliked(medias: [Any]) {
        if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
        for (index, media) in medias.enumerated() {
            if index == 0 {
                self.uploadMedia(withMedia : media)
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.uploadMedia(withMedia : media)
                }
            }
       }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func compressVideo(inputURL: NSURL, outputURL: NSURL, handler: @escaping (AVAssetExportSession)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL as URL, options: nil)
        let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality)
        exportSession?.outputURL = outputURL as URL
        exportSession?.outputFileType = AVFileType.mov
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.exportAsynchronously { () -> Void in
            handler(exportSession!)
        }
    }
    
    private func getVideoPath(withPhAsset mPhasset : PHAsset, completion : @escaping ((URL?) -> Void)) {
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            if let urlAsset = asset as? AVURLAsset {
                let localVideoUrl = urlAsset.url
                completion(localVideoUrl)
            } else {
                completion(nil)
            }
        })
        
        
//        mPhasset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
//
//            if let strURL = (contentEditingInput!.audiovisualAsset as? AVURLAsset)?.url.absoluteString
//            {
//                print("VIDEO URL: \(strURL)")
//            }
//        })
    }
    
    // Used for getting thumbnail image from encoded string
    func createImageMessage(withThumbnail thumbnail: Any) -> UIImage? {
        if let thumbnailImage = thumbnail as? UIImage {
            return thumbnailImage
        }
        else if let thumbnailData = thumbnail as? String {
            let image = Image.convertBase64ToImage(base64String: thumbnailData)
            return image
        }
        return nil
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
    
    func addImageMessage(withImage tImage: UIImage, andMediaType type: String) {
        // Creating image message with thumbnail Image.
        self.chatDocID = self.getChatDocID()
        
        let img = self.createImageMessage(withThumbnail: tImage)
        guard let imageData = self.createThumbnail(forImage: tImage) else { return }
        let imgData: NSData = NSData(data: (tImage).jpegData(compressionQuality: 0.5)!)
        let imageSize = imgData.length
        
        guard let imageMsgObj = self.getimageMessageObj(withimage: img!, isSelf: true, thumbnailData: imageData, withMediaType: type) else { return }
        
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        self.updateChatDocIDIntoContactDB()
        guard var msgObj = chatsDocVMObject.makeMessageForSendingBetweenServers(withData: imageData, withMediaSize: imageSize, andMediaURL: "", withtimeStamp: imageMsgObj.timeStamp, andType : type, documentData : nil, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage, senderID: self.senderId(), receiverId: self.receiverID, chatDocId: self.chatDocID) else { return }
        
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            msgObj["secretId"] = chatViewModelObj?.secretID
            var timer = 0
            if  let time = UserDefaults.standard.object(forKey:(chatViewModelObj?.secretID)!) as? Int{
                timer = time
            }
            msgObj["dTime"] = timer
        }
        
        
        
        self.messages.append(imageMsgObj)
        
        if let chatDta = couchbaseObj.getData(fromDocID: chatDocID) {
            chatsDocVMObject.updateChatData(withData: chatDta, msgObject : imageMsgObj as Any, inDocID  : chatDocID, isCreatingChat: false)
        }
        //Store message to DB.
        guard let MsgObjForDB = chatsDocVMObject.getMessageObject(fromData: msgObj, withStatus: "0", isSelf: true, fileSize: Double(imageSize), documentData: nil, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage) else { return }
        self.chatsDocVMObject.updateChatDoc(withMsgObj: MsgObjForDB, toDocID: chatDocID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.finishSendingMessage(animated: true)
            self.scrollToBottom(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.removeReplyView()
            }
        }
    }
}

// MARK: - Video Player Extension

extension ChatViewController {
    
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
}

extension ChatViewController {
    
    func sendVideoMessage(withVideoLocalURL videoURL: NSURL, andMediaTypes type: String) {
        if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
        // Creating image message with thumbnail Image.
        DispatchQueue.main.async {
            guard let docID = self.getChatDocID() else { return }
            self.chatDocID = docID
            DispatchQueue.global(qos: .default).async {
                let thumbNailImage = self.thumbnail(sourceURL: videoURL)
                guard let thumbnailData = self.createThumbnail(forImage: thumbNailImage) else { return }
                guard let videoSize = self.getVideoSize(withURL: videoURL) else { return }
                guard let videoMsgObj = self.getVideoMessageObj(withVideoURL: videoURL, isSelf: true, thumbnailData: thumbnailData, withMediaType: type) else { return }
                let chatsDocVMObject = ChatsDocumentViewModel(couchbase: self.couchbaseObj)
                self.updateChatDocIDIntoContactDB()
                guard var msgObj = chatsDocVMObject.makeMessageForSendingBetweenServers(withData: thumbnailData, withMediaSize: Int(videoSize), andMediaURL: "", withtimeStamp: videoMsgObj.timeStamp, andType: type, documentData : nil, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage, senderID: self.senderId(), receiverId: self.receiverID, chatDocId: self.chatDocID) else { return }
                
                
                if self.chatViewModelObj?.secretID != "" && self.chatViewModelObj != nil{
                    msgObj["secretId"] = self.chatViewModelObj?.secretID
                    var timer = 0
                    if  let time = UserDefaults.standard.object(forKey:(self.chatViewModelObj?.secretID)!) as? Int{
                        timer = time
                    }
                    msgObj["dTime"] = timer
                }
                
                self.messages.append(videoMsgObj)
                if let chatDta = self.couchbaseObj.getData(fromDocID: self.chatDocID) {
                    chatsDocVMObject.updateChatData(withData: chatDta, msgObject : videoMsgObj as Any, inDocID  : self.chatDocID, isCreatingChat: false)
                }
                
                guard let MsgObjForDB = chatsDocVMObject.getMessageObject(fromData: msgObj, withStatus: "0", isSelf: true, fileSize: Double(videoSize), documentData: nil, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage) else { return }
                self.chatsDocVMObject.updateChatDoc(withMsgObj: MsgObjForDB, toDocID: self.chatDocID)
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.finishSendingMessage(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.removeReplyView()
                    }
                }
            }
        }
    }
    
    func getVideoSize(withURL resourceURL: NSURL) -> UInt64? {
        let asset = AVURLAsset(url: resourceURL as URL)
        print(asset.fileSize ?? 0)
        return UInt64(asset.fileSize!)
    }
    
    func getVideoMessageObj(withVideoURL videoURL : NSURL, isSelf : Bool, thumbnailData: String?, withMediaType type: String) -> Message? {
        guard let msgData = self.getVideoMessageParams(withVideoURL: videoURL, isSelf: isSelf, videoURL: nil, withMediaType: type, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage) else { return nil }
        
        //        creating image cache URL here.
        var timeStamp: String = ""
        if let ts = msgData["timestamp"] as? String {
            timeStamp = ts
        } else if let ts = msgData["timestamp"] as? Int64 {
            timeStamp = "\(ts)"
        }
        
        //1. Store Video To Cache here.
        //Storing image into cache with the name of the image.
        let videoName = "Do_Chat"+timeStamp+".mp4"
        var mediaURL = videoName
        do {
            let videoData = try Data(contentsOf: videoURL as URL)
            let videoURL = MediaDownloader().SaveMedia(withURL: videoName, andData: videoData)
            if let url = videoURL?.absoluteString {
                mediaURL = url
            }
        } catch let error {
            print(error)
        }
        
        //        2. After that link the media url to the message db.
        if let mURL = msgData["mediaURL"] as? String {
            mediaURL = mURL
        }
        
        var gpMessageType = ""
        if let gpMessageTyp = msgData["gpMessageType"] as? String{
            gpMessageType = gpMessageTyp
        }
        
        var timer = 0
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            if  let time = UserDefaults.standard.object(forKey:(chatViewModelObj?.secretID)!) as? Int{
                timer = time
            }
        }
        
        
        let message = Message(forData: msgData, withDocID: self.chatDocID!, andMessageobj: msgData, isSelfMessage: isSelf, mediaStates: .notUploaded, mediaURL: mediaURL, thumbnailData: thumbnailData, secretID: nil, receiverIdentifier: "", messageData: nil, isReplied: self.isReplying ,gpMessageType :gpMessageType, dTime: timer, readTime: 0.0, deliveryTime: 0.0)
        return message
    }
    
    func getVideoMessageParams(withVideoURL resourceURL : NSURL, isSelf : Bool, videoURL : String?, withMediaType type: String, isReplying: Bool, replyingMsgObj: Message?) -> [String : Any]? {
        let timeStamp : String = "\(UInt64(floor(Date().timeIntervalSince1970 * 1000)))"
        var params = [String :Any]()
        let userDocVMObject = UsersDocumentViewModel(couchbase: couchbaseObj)
        guard let userData = userDocVMObject.getUserData() else { return nil }
        let tImage = self.thumbnail(sourceURL: resourceURL)
        guard let imageData = self.createThumbnail(forImage: tImage) else { return nil }
        guard let VideoSize = self.getVideoSize(withURL: resourceURL) else { return nil }
        if isSelf {
            params["from"] = userData["userID"]! as Any
            params["to"] = self.receiverID! as Any
        } else {
            params["from"] = self.receiverID! as Any
            params["to"] = userData["userID"]! as Any
        }
        if let url = videoURL {
            params["payload"] = url as Any
        }
        params["toDocId"] = self.chatDocID! as Any
        params["timestamp"] = timeStamp as Any
        params["id"] = timeStamp as Any
        params["type"] = type as Any
        params["thumbnail"] = imageData
        params["dataSize"] = VideoSize as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["userName"]! as Any
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        
        
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            params["secretId"] = chatViewModelObj?.secretID
            var timer = 0
            if  let time = UserDefaults.standard.object(forKey:(chatViewModelObj?.secretID)!) as? Int{
                timer = time
            }
            params["dTime"] = timer
        }
        
        
        if isReplying == true, let replyMsg = replyingMsgObj {
            if let pPload = replyMsg.messagePayload, let pFrom = replyMsg.messageFromID, let prIdentifier = replyMsg.receiverIdentifier, let msgId = replyMsg.timeStamp, let previousType = replyMsg.messageType {
                params["previousPayload"] = pPload as Any
                params["previousFrom"] = pFrom as Any
                params["replyType"] = type as Any
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
                    if let repliedMsg = self.replyingMessage?.repliedMessage {
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
}

extension ChatViewController {
    func sendAudioMessage(withAudioLocalURL audioURL: NSURL, andMediaTypes type: String) {
        if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
        // Creating image message with thumbnail Image.
        let audioData = NSData(contentsOf: audioURL as URL)
        guard let audioSize = audioData?.length else { return }
        guard let audioMsgObj = self.getMediaMessageObj(withMediaURL: audioURL, isSelf: true, withMediaType: type, withMessageData: nil) else { return }
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        self.updateChatDocIDIntoContactDB()
        guard var msgObj = chatsDocVMObject.makeMessageForSendingBetweenServers(withData: nil, withMediaSize: Int(audioSize), andMediaURL: audioURL.absoluteString!, withtimeStamp: audioMsgObj.timeStamp, andType: type, documentData : nil, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage, senderID: self.senderId(), receiverId: self.receiverID, chatDocId: self.chatDocID) else { return }
        
        
        
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            msgObj["secretId"] = chatViewModelObj?.secretID
            var timer = 0
            if  let time = UserDefaults.standard.object(forKey:(chatViewModelObj?.secretID)!) as? Int{
                timer = time
            }
            msgObj["dTime"] = timer
        }
        
        
        
        if let chatDta = couchbaseObj.getData(fromDocID: chatDocID) {
            chatsDocVMObject.updateChatData(withData: chatDta, msgObject : audioMsgObj as Any, inDocID  : chatDocID, isCreatingChat: false)
        }
        self.messages.append(audioMsgObj)
        guard let MsgObjForDB = chatsDocVMObject.getMessageObject(fromData: msgObj, withStatus: "0", isSelf: true, fileSize: Double(audioSize), documentData: nil, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage) else { return }
        
        self.chatsDocVMObject.updateChatDoc(withMsgObj: MsgObjForDB, toDocID: chatDocID)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.finishSendingMessage(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.removeReplyView()
            }
        }
    }
}

//MARK:- Doodle delegate
extension ChatViewController : doodleDelegate {
    func didDoodleSendCliked(_ image: UIImage) {
        if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
        self.addImageMessage(withImage: image, andMediaType: "7")
    }
}

//MARK:- giphyDelegate  delegate
extension ChatViewController:giphyDelegate {
    func didSendStickerCliked(_ url: URL) {
        if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
        self.updateMessageUIAfterSendingMessage(withText: url.absoluteString, andType: "6", withData: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.finishSendingMessage(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.removeReplyView()
            }
        }
    }
    
    func didSendGiphyCliked(_ url: URL) {
        if self.chatDocID != nil {UserDefaults.standard.setValue("", forKey:self.chatDocID)}
        self.updateMessageUIAfterSendingMessage(withText: url.absoluteString, andType: "8", withData: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.finishSendingMessage(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.removeReplyView()
            }
        }
    }
}


// MARK: - Message View controller delegate
extension ChatViewController : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: {
            self.inputToolbar.contentView?.textView?.isHidden = false
            self.becomeFirstResponder()
        })
    }
    
    func sendTextMessage(withPhNumbers phNumbers : [String]) {
        let messageVC = MFMessageComposeViewController()
        if (messageVC != nil) {
            messageVC.body = "Check out".localized + " \(AppConstants.AppName) " + "Messenger for your smartphone".localized + ". " + "Download it today from App Store".localized
            messageVC.recipients = phNumbers
            
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Contact Message Action Delegate
extension ChatViewController : ContactMessageActionDelegate {
    
    func openContactDetail(withMsgVMObj contactVMObj : ContactMessageViewModal) {
        self.performSegue(withIdentifier: Constants.toContactDetailsSegue, sender: contactVMObj)
    }
    
    func sendMessageToUser(withUserIds userIDs: [String]) {
        for (index, userId) in userIDs.enumerated() {
            if index == 0 {
                self.popToChatListController(withuserID : userId)
            }
        }
    }
    
    func popToChatListController(withuserID userID: String) {
        if let controllers = self.navigationController?.children, let navController = self.navigationController {
            for controller in controllers {
                if let chatListController = controller as? ChatsListViewController {
                    navController.popToViewController(controller, animated: false)
                    chatListController.performSegue(withIdentifier: AppConstants.segueIdentifiers.chatController, sender: userID)
                }
            }
        }
    }
    
    func inviteToAppAction(withPhNumbers phNumbers: [String]) {
        self.sendTextMessage(withPhNumbers: phNumbers)
    }
    
    func contactForwardActionCliked(_ cell: SentContactMessageCollectionViewCell){
        self.tappedOnForward(cell)
    }
    
    func receivedContactForwardActionClicked(_ cell: ReceivedContactCollectionViewCell) {
        self.tappedOnForward(cell)
    }
    
}

// MARK: - Contact present controller Delegate
extension ChatViewController : PresentControllerDelegate {
    func presentController(withController controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Document present controller delegate
extension ChatViewController : DocumentMessageDelegate {
    func receivedDocumentForwardActionClicked(_ cell: DocumentReceivedCollectionViewCell) {
        self.tappedOnForward(cell)
    }
    
    func openDocumentDelegate(withDocumentVMObj docMVMObj: DocumentMessageViewModal) {
        self.performSegue(withIdentifier: Constants.documentViewerSegue, sender: docMVMObj)
    }
    
    func documentForwardActionCliked(_ cell: DocumentSentCollectionViewCell) {
        self.tappedOnForward(cell)
    }
    
}


// MARK: - Audio Player Cell Delegate
extension ChatViewController : AudioPlayerDelegate {
    func receiveAudioForwardActionClicked(_ cell: AudioReceivedCollectionViewCell) {
        self.tappedOnForward(cell)
    }
    
    func playing(withInstance audioPlayerInstance: AudioPlayerManager, playButton: UIButton) {
//        if let player = self.currentPlayingAudioPlayer {
//            player.stop(clearQueue: true)
//            if let curPlayButton = self.currentPlayingButton{
//                curPlayButton.isSelected = false
//            }
//        }
        self.stopRunningAudioIfAny()
        self.currentPlayingAudioPlayer = audioPlayerInstance
        self.currentPlayingButton = playButton
    }
    
    func audioForwardActionCliked(_ cell: AudioSentCollectionViewCell) {
        self.tappedOnForward(cell)
    }
    
}

// MARK: - Reply View Methods
extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        let msgObj = self.messages[indexPath.row]
        if action.description == "sn_handlePanGesture:" {
            self.collectionView?.reloadItems(at: [indexPath])
            self.addViewOnTopOfKeyboard(withMsgObj: msgObj)
        } else if action.description == "sn_reloadCell:" {
            DispatchQueue.main.async {
            self.collectionView?.reloadItems(at: [indexPath])
            }
            
        } else if action.description == "delete:" {
            var deleteOptions = [DeleteConstants.deleteForMe]
            if msgObj.isSelfMessage {
                if msgObj.messageType != .deleted {
                    if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
                        deleteOptions = [DeleteConstants.deleteForMe]
                    }else {
                        deleteOptions = [DeleteConstants.deleteForEveryone, DeleteConstants.deleteForMe]
                    }
                }
            }
            self.opencontrollerForOptions(withOptions: deleteOptions, withIndexPath: indexPath)
        }else if action.description == "Info:"{
            print("info: ",msgObj)
            self.performSegue(withIdentifier: "messageInfoSegue", sender: msgObj)
        }
    }
}


//MARK:- Transfer message action delegate
extension ChatViewController: TransferSentCollectionViewCellDelegate, TransferReceivedCollectionViewCellDelegate{
    func transferSentCellTapped(msgObj: TransferMessageViewModel) {
//        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.chat, bundle: nil)
//        guard let transferInfoVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.TransferInfoViewController) as? TransferInfoViewController else{return}
//        transferInfoVC.transferMessageObject = msgObj
//        transferInfoVC.userImageUrl = self.getProfilePic()
//        transferInfoVC.userName = self.getReceiverName()
//        self.navigationController?.pushViewController(transferInfoVC, animated: true)
//
        /* Bug Name : first time I message I see a space above message box
         Fix Date : 15-Nov-2021
         Fixed By : Jayaram G
         Description Of Fix : Presenting the view in fullscreen instead of push
         */
            guard let detailsVC = UIStoryboard(name: "RechargeSuccess", bundle: nil).instantiateViewController(withIdentifier: "RechargeSuccessViewController") as? TransactionDetailViewController else { return }
        let navVc = UINavigationController(rootViewController: detailsVC)
        navVc.modalPresentationStyle = .fullScreen
            detailsVC.txnId = msgObj.message.txnId
            detailsVC.trasactionType = .sent
            detailsVC.isFromChat = true
        self.present(navVc, animated: false, completion: nil)
//            self.navigationController?.pushViewController(detailsVC, animated: true)
        
        
    }
    
    func transferReceivedCellTapped(msgObj: TransferMessageViewModel) {
//        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.chat, bundle: nil)
//        guard let transferInfoVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.TransferInfoViewController) as? TransferInfoViewController else{return}
//        transferInfoVC.transferMessageObject = msgObj
//        transferInfoVC.userImageUrl = self.getProfilePic()
//        transferInfoVC.userName = self.getReceiverName()
//        self.navigationController?.pushViewController(transferInfoVC, animated: true)
        /* Bug Name : first time I message I see a space above message box
         Fix Date : 15-Nov-2021
         Fixed By : Jayaram G
         Description Of Fix : Presenting the view in fullscreen instead of push
         */
        guard let detailsVC = UIStoryboard(name: "RechargeSuccess", bundle: nil).instantiateViewController(withIdentifier: "RechargeSuccessViewController") as? TransactionDetailViewController else { return }
        let navVc = UINavigationController(rootViewController: detailsVC)
        navVc.modalPresentationStyle = .fullScreen
        detailsVC.txnId = msgObj.message.txnId
        detailsVC.trasactionType = .received
        detailsVC.isFromChat = true
        self.present(navVc, animated: false, completion: nil)

    }
    
    func paymentCancelSelected(msgObj: TransferMessageViewModel) {
//        self.chatViewModelObj?.cancelTransferMoney(msgId: msgObj.message.messageId)
        self.showConfirmationPopUpForCancel(msgObj: msgObj)
    }
    
    func paymentActionSelected(isAccept: Bool, msgObj: TransferMessageViewModel) {
//        self.chatViewModelObj?.updateTransferStatus(isAccepted: isAccept, msgId: msgObj.message.messageId)
        self.showConfirmationPopUp(isAccept: isAccept, msgObj: msgObj)
    }
    
    fileprivate func showConfirmationPopUp(isAccept: Bool, msgObj: TransferMessageViewModel){
        let message = isAccept ? Strings.TransferConfirmationMessage.accept.localized : Strings.TransferConfirmationMessage.decline.localized
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok.localized, style: .default) { (action) in
            self.chatViewModelObj?.updateTransferStatus(isAccepted: isAccept, msgId: msgObj.message.messageId)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showConfirmationPopUpForCancel(msgObj: TransferMessageViewModel){
        
        let alert = UIAlertController(title: nil, message: Strings.TransferConfirmationMessage.cancel.localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok.localized, style: .default) { (action) in
            self.chatViewModelObj?.cancelTransferMoney(msgId: msgObj.message.messageId)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: - Message Delete Methods
extension ChatViewController {
    private func deleteMessageLocally(withIndex indexPath: IndexPath) {
        if let cllectionView = collectionView {
            self.deleteMessage(winthIndex: indexPath)
            self.messages.remove(at: indexPath.row)
            cllectionView.deleteItems(at: [indexPath])
            cllectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func deleteMessage(winthIndex indexPath: IndexPath) {
        let msgObj = self.messages[indexPath.row]
        self.chatViewModelObj?.deleteMessage(withMessageObj: msgObj)
    }
    
    private func deleteMessageEveryone(withIndexPath indexPath  : IndexPath) {
        let msgObj = self.messages[indexPath.row]
        if let msg = self.chatViewModelObj?.updateMessageToDeletedState(withMsgObj: msgObj) {
            self.messages[indexPath.row] = msg
            
            if isGroup {
                DispatchQueue.global().async {
                    guard let groupMems = self.groupMembers else {return}
                    for member in  groupMems {
                        if member["memberId"] as? String   == self.userID{} else {
                            guard   let reciverID = member["memberId"] as? String else {return}
                            var params = [String : Any]()
                            let timeStamp : String = "\(UInt64(floor(Date().timeIntervalSince1970 * 1000)))"
                            let userDocVMObject = UsersDocumentViewModel(couchbase: self.couchbaseObj)
                            guard let userData = userDocVMObject.getUserData() else { return }
                            params["from"] = self.senderId() as Any
                            params["to"] = self.receiverID! as Any
                            params["toDocId"] = self.chatDocID! as Any
                            params["timestamp"] = msg.timeStamp! as Any
                            params["id"] = msg.timeStamp! as Any
                            params["userImage"] = self.getProfilePic()
                            params["name"] = self.getReceiverName()
                            params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
                            params["removedAt"] = timeStamp
                            params["payload"] = "This message has been removed".toBase64()
                            params["type"] = "11"
                            self.mqttChatManager.sendGroupMessage(toChannel: "\(reciverID)", withMessage: params, withQsos: .atLeastOnce)
                        }
                    }
                }
            }else {
                self.sendReceiver(deletedMsg: msg)
            }
            
        }
        collectionView?.performBatchUpdates({ () -> Void in
            let ctx = JSQMessagesCollectionViewFlowLayoutInvalidationContext()
            ctx.invalidateFlowLayoutDelegateMetrics = true
            self.collectionView?.collectionViewLayout.invalidateLayout(with: ctx)
        }) { (_: Bool) -> Void in
        }
        self.collectionView?.reloadItems(at: [indexPath])
    }
    
    private func sendReceiver(deletedMsg : Message) {
        var params = [String : Any]()
        let timeStamp : String = "\(UInt64(floor(Date().timeIntervalSince1970 * 1000)))"
        let userDocVMObject = UsersDocumentViewModel(couchbase: couchbaseObj)
        guard let userData = userDocVMObject.getUserData() else { return }
        
        params["from"] = self.senderId() as Any
        params["to"] = self.receiverID! as Any
        params["toDocId"] = self.chatDocID! as Any
        params["timestamp"] = deletedMsg.timeStamp! as Any
        params["id"] = deletedMsg.timeStamp! as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["userName"]! as Any
        params["receiverIdentifier"] = userData["receiverIdentifier"]! as Any
        params["removedAt"] = timeStamp
        params["payload"] = "This message has been removed".toBase64()
        params["type"] = "11"
        
        mqttChatManager.sendMessage(toChannel: "\(self.receiverID!)", withMessage: params, withQOS: .atLeastOnce)
    }
    
    func opencontrollerForOptions(withOptions options: [String], withIndexPath indexPath: IndexPath ) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for optionValue in options {
            let action = UIAlertAction(title: optionValue, style: .destructive, handler: { (action) in
                if action.title == DeleteConstants.deleteForEveryone {
                    self.deleteMessageEveryone(withIndexPath : indexPath)
                    controller.dismiss(animated: true, completion: nil)
                    
                } else if action.title == DeleteConstants.deleteForMe {
                    self.deleteMessageLocally(withIndex: indexPath)
                    controller.dismiss(animated: true, completion: nil)
                }
            })
            controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler:nil)
        controller.addAction(cancelAction)
        self.presentController(withController: controller)
    }
}

extension ChatViewController : ReplyViewDismissDelegate {
    
    func replyViewClosedButtonSelected(_ replyView: UIView) {
        removeReplyView()
    }
    
    func replyMessageSelected(withMessageId msgId: String) {
        if let filteredMsg = self.messages.first(where: {
            $0.timeStamp == msgId || $0.messageId == msgId
        }) {
            if let index = self.messages.index(of: filteredMsg) {
                let indexPath = IndexPath(item: index, section: 0)
                self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
        }
    }
    
    func addViewOnTopOfKeyboard(withMsgObj msgObj : Message) {
        removeReplyView()
        if let replyView = Bundle.main.loadNibNamed("ReplyView", owner: self, options: nil)?.first as? ReplyView {
            self.isReplying = true
            replyView.replyViewDismissDelegate = self
            replyView.frame = self.changedFrame!
            
            replyView.isReplyingView = true
            replyView.selectedMessage = msgObj
            self.replyingMessage = msgObj
            self.view.addSubview(replyView)
            self.view.bringSubviewToFront(replyView)
            self.scrollViewForReplyView()
        }
    }
    
    private func scrollViewForReplyView(){
        if var offset = self.collectionView?.contentOffset {
            if isReplying {
                 offset.y += 70
                self.collectionView?.setContentOffset(offset, animated: true)
             } else {
                offset.y -= 60
                self.collectionView?.setContentOffset(offset, animated: true)
            }
        }
    }
    
    func updateReplyViewFrame() {
        if let replyView = self.view.viewWithTag(100) {
//            if self.changedFrame!.origin.y == self.view.frame.size.height {
//                self.changedFrame!.origin.y = -70
//            }
            replyView.frame = self.changedFrame!
        }
    }
    
    func removeReplyView() {
        if let replyView = self.view.viewWithTag(100) {
            replyView.removeFromSuperview()
            self.isReplying = false
            self.replyingMessage = nil
            self.scrollViewForReplyView()
        }
    }
}

extension ChatViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pGesture.velocity(in: pGesture.view)
            if velocity.x>0 {
                if self.chatViewModelObj?.secretID == "" {
                    return true
                }else {
                    return false
                }
            }
        }
        return false
    }
}

extension UICollectionView {
    var centerPoint : CGPoint {
        get {
            return CGPoint(x: self.center.x + self.contentOffset.x, y: self.center.y + self.contentOffset.y);
        }
    }
}

extension ChatViewController: JSQMessagesCollectionViewCellDelegate{
    func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell) {
        
    }
    
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: JSQMessagesCollectionViewCell) {
        
    }
    
    func messagesCollectionViewCellDidTap(_ cell: JSQMessagesCollectionViewCell, atPosition position: CGPoint) {
        
    }
    
    func messagesCollectionViewCell(_ cell: JSQMessagesCollectionViewCell, didPerformAction action: Selector, withSender sender: Any) {
        
    }
    
    func messagesCollectionViewCellDidTapAccessoryButton(_ cell: JSQMessagesCollectionViewCell) {
        self.tappedOnForward(cell)
    }
    
    
    func messageAccesoryTapped(_ cell: JSQMessagesCollectionViewCell) {
        
    }
    
    func tappedOnForward(_ cell: JSQMessagesCollectionViewCell) {
        if let indexPath = collectionView?.indexPathForItem(at: cell.center) {
            let msg = self.messages[indexPath.row]
            self.addpartiCliked(withMsgObj : msg)
        }
    }
    
    func addpartiCliked(withMsgObj msgObj : Message){
//        var favDatabase:[Contacts] =  Helper.getFavoriteDataFromDatabase1()
//        let story = UIStoryboard.init(name:AppConstants.StoryBoardIds.chat, bundle: nil)
//        let controller = story.instantiateViewController(withIdentifier: "SelectGroupMemNav") as! UINavigationController
//        let selectGpmem = controller.topViewController as! SelectGroupMemTableViewController
//
//        if let registerNum = self.registerNum  {
//            let contact = favDatabase.filter({ $0.registerNum == registerNum})
//            if contact.count > 0 {
//                let index = favDatabase.index(where: {$0 == contact.first})
//                favDatabase.remove(at: index!)
//            }
//        }
//
//        selectGpmem.allFavoriteList =  favDatabase
//        selectGpmem.isGroupMemberPicker = false
//        selectGpmem.message = msgObj
//        selectGpmem.documentId = self.chatDocID
//        self.present(controller, animated: true, completion: nil)
        
        let storyboard = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
        guard let favouritVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.FollowListViewController) as? FollowListViewController else {return}
        favouritVC.controllerPurpose = .forwardMessage
        favouritVC.message = msgObj
        favouritVC.documentId = self.chatDocID
        self.navigationController?.pushViewController(favouritVC, animated: true)
        
    }
}



//MARK: - All Seceret Chat methods

extension ChatViewController{
    
    //ActionSheet
    func seceretChatTimerSheet(){
        
        let actionsheet = UIAlertController.init(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let margin:CGFloat = 10.0
        let rect = CGRect(x: margin, y: margin, width: actionsheet.view.bounds.size.width - margin * 4.0, height: 170)
        
        let cancelAction2 = UIAlertAction.init(title: "Done".localized, style: .default) { (action) in
            
            //selected Timer Time in Sec
            UserDefaults.standard.set(Helper.timeInsecArr()[self.selectedTimerIndex], forKey: (self.chatViewModelObj?.secretID)!)
            
            let chatsDocVMObject = ChatsDocumentViewModel(couchbase: self.couchbaseObj)
            self.updateChatDocIDIntoContactDB()
            
            var isStar = 0
            if let isVerified = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.isVerifiedUserProfile) as? Bool{
                isStar = isVerified ? 1 : 0
            }
            
            guard var message = chatsDocVMObject.makeMessageForSendingBetweenServers(withText: "secret msg Tag", andType: "0", isReplying: self.isReplying, replyingMsgObj: self.replyingMessage, senderID: self.senderId(), receiverId: self.receiverID, chatDocId: self.chatDocID, isStar: isStar) else { return }
            
            if self.chatViewModelObj?.secretID != "" && self.chatViewModelObj != nil{
                message["secretId"] = self.chatViewModelObj?.secretID
                message["dTime"] = Helper.timeInsecArr()[self.selectedTimerIndex]
                message["gpMessageType"] = "7"
                message["payload"] = ""
                self.mqttChatManager.sendMessage(toChannel: "\(self.receiverID!)", withMessage: message, withQOS: .atLeastOnce)
            }
            message["payload"] = "\(message["receiverIdentifier"] as! String)".toBase64()
            
            
            guard let MsgObjForDB = chatsDocVMObject.getMessageObject(fromData: message , withStatus: "0", isSelf: true, fileSize: 0, documentData: nil, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage) else { return }
            var msgObj = MsgObjForDB
            guard let dateString = DateExtension().getDateString(fromDate: Date()) else { return }
            msgObj["sentDate"] = dateString as Any
            msgObj["gpMessageType"] = "7"
            guard let chatDocID = self.chatDocID else { return }
            if let chatDta = self.couchbaseObj.getData(fromDocID: chatDocID) {
                chatsDocVMObject.updateChatData(withData: chatDta, msgObject : msgObj as Any, inDocID  : chatDocID, isCreatingChat: false)
            }
            
            self.chatsDocVMObject.updateChatDoc(withMsgObj: msgObj, toDocID: chatDocID)
            let msgObject = Message(forData: msgObj, withDocID: chatDocID, andMessageobj: message, isSelfMessage: true, mediaStates: .notApplicable, mediaURL: nil, thumbnailData: nil, secretID: self.chatViewModelObj?.secretID, receiverIdentifier: "", messageData: nil, isReplied: self.isReplying,gpMessageType: "7" ,dTime: Helper.timeInsecArr()[self.selectedTimerIndex], readTime: 0.0, deliveryTime: 0.0)
            self.messages.append(msgObject)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.finishSendingMessage(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.removeReplyView()
                }
            }
            actionsheet.dismiss(animated: true, completion: nil)
        }
        
        
        let cancelAction1 = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in }
        let view =  UIView(frame: rect)
        actionsheet.view.addSubview(view)
        
        let picker = UIPickerView.init(frame: CGRect.init(x: 0, y: 0, width: rect.width, height: rect.height))
        picker.delegate  = self
        picker.dataSource  = self
        view.addSubview(picker)
        actionsheet.addAction(cancelAction2)
        actionsheet.addAction(cancelAction1)
        self.presentController(withController: actionsheet)
        
        //Show selected time on picker
        if  let time = UserDefaults.standard.object(forKey:(chatViewModelObj?.secretID)!) as? Int{
            let row =    Helper.timeInsecArr().index(where: {$0 == time})
            if let rowIndex = row as? Int {
            picker.selectRow(rowIndex, inComponent: 0, animated: true)
            }
           
        }else{
            picker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    
}

extension ChatViewController:UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Helper.defaultTimerArr().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return Helper.defaultTimerArr()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        selectedTimerIndex = row
    }
    
}

//MARK:- Block Service call and operations
extension ChatViewController{
    
    //Block user
    func blockUserApicall(reciverID: String?, text: String){
        
//        let chatDocId = getChatDocumentID()
//        if chatDocId.count == 0 {return}
        guard let reciverid = reciverID else {return}
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.blockPersonAPI
        let params = ["opponentId" : reciverid,
                      "type": "unblock"]
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters:params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.blockUser.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.blockUser.rawValue {
                    self.isuserBlock = !self.isuserBlock
                    if let chatViewModelObj = self.chatViewModelObj {
                        chatViewModelObj.isUserBlock = self.isuserBlock
                    }
                    self.updateUserBlockStatus(toDocID: self.chatDocID, isBlock:self.isuserBlock )
//                    self.imageRemoveForBlockUser()
                    self.sendBlockOnmqtt(reciveID: reciverid)
                    self.didSendTextMessage(text: text)
                }
            }, onError: {error in
                
                Helper.hidePI()
            })
    }
    
    
     //Block user
        func getblockUserStatusApicall(reciverID: String?){
            
    //        let chatDocId = getChatDocumentID()
    //        if chatDocId.count == 0 {return}
            guard let reciverid = reciverID else {return}
            Helper.showPI(_message: "Loading".localized + "...")
            let strURL = AppConstants.blockPersonAPI + "?opponentId=\(reciverid)"
//            let params = ["opponentId" : reciverid]
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict["token"] as? String  else {return}
            
            let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
            let apiCall = RxAlmofireClass()
            apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters:nil,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.blockUser.rawValue)
            apiCall.subject_response
                .subscribe(onNext: {dict in
                    Helper.hidePI()
                    guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                    if responseKey == AppConstants.resposeType.blockUser.rawValue {
                        if  let response = dict["data"] as? [String:Any] {
                        print(response)
                            if response["blocked"] as? Int == 1 {
                                self.inputToolbar.isHidden = true
                                if self.audiobutton != nil || self.videoButton != nil{
                                    self.audiobutton.isEnabled = false
                                    self.videoButton.isEnabled = false
                                }
                                self.currentChatStatusLabelOutlet.isHidden  = true
                                self.currentChatStatusLabelOutlet.text  = "                                                       "
                            }else {
                                if self.audiobutton != nil || self.videoButton != nil{
                                    self.audiobutton.isEnabled = true
                                    self.videoButton.isEnabled = true
                                }
                                self.currentChatStatusLabelOutlet.isHidden = false
                                self.inputToolbar.isHidden = false
                            }
                        }
                        
                        
                        
//                        self.isuserBlock = !self.isuserBlock
//                        if let chatViewModelObj = self.chatViewModelObj {
//                            chatViewModelObj.isUserBlock = self.isuserBlock
//                        }
//                        self.updateUserBlockStatus(toDocID: self.chatDocID, isBlock:self.isuserBlock )
//    //                    self.imageRemoveForBlockUser()
//                        self.sendBlockOnmqtt(reciveID: reciverid)
//                        self.didSendTextMessage(text: text)
                    }
                }, onError: {error in
                    
                    Helper.hidePI()
                })
        }
    
    func updateUserBlockStatus(toDocID docId: String , isBlock : Bool){
        var chatData = couchbaseObj.getData(fromDocID: docId)!
        chatData["isUserBlocked"]  = isBlock
        self.couchbaseObj.updateData(data: chatData, toDocID: docId)
    }
    
    func  sendBlockOnmqtt(reciveID: String){
        
        guard let userID = Utility.getUserid() else {return}
        let mqttDict:[String:Any] = ["blocked":self.isuserBlock,
                                     "initiatorId":userID,
                                     "type": 6  as Any]
        
        let groupChannel = "\(AppConstants.MQTT.userUpdates)\(reciveID)"
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject:mqttDict , options: .prettyPrinted)
            MQTT.sharedInstance.publishData(wthData: jsonData, onTopic: groupChannel, retain: false, withDelivering:  .atLeastOnce)
        }catch  {
            print("\(error.localizedDescription)")
        }
    }
}
    
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
