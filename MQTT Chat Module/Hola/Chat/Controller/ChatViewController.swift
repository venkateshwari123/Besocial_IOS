//
//  ChatViewController.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 10/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import Kingfisher
import CocoaLumberjack
import RxCocoa
import RxSwift
import Reachability
import RxReachability
import Contacts
import AVKit
import Locksmith
import QuickLook
import Alamofire

enum chatActionSheet : String {
    case camera = "Camera"
    case camerandVideo = "Photo and Video Library"
    case giphy = "Giphy"
    case sticker  = "Sticker"
    case doodle  =  "Doodle"
    case location = "Location"
    case contact = "Contact"
    case document = "Documents"
    case payment = "Payment"
}



class ChatViewController: JSQMessagesViewController {
    
    
    /// Used Constants for default values.
    struct Constants {
        
        /// Default message size.
        static let messagePageSize = "100"
        
        /// To Counter Offer Controller Segue
        static let toCounterOfferSegue = "toCounterOfferSegue"
        
        /// To Location Picker Controller Segue
        static let toLocationPicker = "toLocationPicker"
        
        /// To Paypal View Controller Segue.
        static let toPaypalViewcontroller = "toPaypalViewcontroller"
        
        /// To Paypal Web View Controller Segue.
        static let paypalWebViewSegue = "paypalWebViewSegue"
        
        /// To image controller segue.
        static let imageControllerSegue = "imageControllerSegue"
        
        /// To Showing Location Segue.
        static let showLocationSegue = "showLocationSegue"
        static let toContactDetailsSegue = "toContactDetailsSegue"
        static let chatTogroupInfoSegue = "chatToGroupInfoView"
        static let documentViewerSegue = "documentViewerSegue"
    }
    
    struct DeleteConstants {
        static let deleteForEveryone = "Delete for Everyone".localized
        static let deleteForMe = "Delete for Me".localized
    }
    
    struct StoryboardId {
        static let PostDetailsViewController = "PostDetailsViewController"
        static let GroupInfoTableViewController = "GroupInfoTableViewController"
    }
    
    @IBOutlet weak var starIndicationImage: UIImageView!
    @IBOutlet var chatBackgroundView: UIView!
    @IBOutlet weak var userImageOutlet: UIImageView!
    @IBOutlet weak var TitleLabelOutlet: UILabel!
    @IBOutlet weak var currentChatStatusLabelOutlet: UILabel!
    @IBOutlet var titleView: UIView!
    @IBOutlet weak var audiobutton: UIBarButtonItem!
    @IBOutlet weak var videoButton: UIBarButtonItem!
    @IBOutlet weak var backGroudImageView: UIImageView!
    
    let couchbaseObj = Couchbase.sharedInstance
    let selfID = Utility.getUserid()
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.white)
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: Utility.appColor())
    let userDefault = UserDefaults.standard
    let mqttChatManager = MQTTChatManager.sharedInstance
    let favoriteViewModel = FavoriteViewModel.sharedInstance
    let disposebag = DisposeBag()
    let recordingView = SKRecordView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width , height: 200))
    var isSentMessage: Bool = false
    var refresher : UIRefreshControl!
    var changedFrame : CGRect? // For replied message.
    var chatsDocVMObject : ChatsDocumentViewModel! {
        return ChatsDocumentViewModel(couchbase: couchbaseObj)
    }
    var isNotFromChatList:Bool = false
    var chatViewModelObj : ChatViewModel?
    var chatDocID : String!
    var messages = [Message]()
    var receiverID :String!
    var registerNum : String!
    var userName : String!
    var isTypingVisible = false
    var userStatus : String!
    var favoriteObj  :Contacts?
    var contactModel : ContactchatViewModel?
    var locationViewModel : LocationPickerViewModel?
    var doodleViewModel: DoodleViewModel?
    var documentViewModel:DocumentViewModel?
    let socialViewModel = SocialViewModel()
    var profileVM = ProfileViewModel()
    var camerabtn:UIButton?
    var contactobj:CNContact?
    var isGroup:Bool = false
    var isuserBlock:Bool = false
    var groupInfo:[String:Any]?
    var groupDocumentID:String?
    var groupImage:String?
    var groupMembers: [[String:Any]]?
    var isActiveGroup:Bool = true
    var isReplying : Bool = false
    var replyingMessage : Message?
    var footerView:UIView?
    var currentPlayingAudioPlayer : AudioPlayerManager?
    var currentPlayingButton: UIButton?
    var userID : String?
    var selfUserImageUrl: String?
    var selectedTimerIndex = 0
    var blockedTextLabel = UILabel()
    static var iii = 1
    var keyBoardUpdatedHeight:CGFloat = 0.0
    var isLoadedOnce: Bool = false
    var chatListIndexPath = IndexPath()
    var isStar = false
    var timeAndDataLabel = UILabel()
    
    //MARK: View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerXIBs()
        let appdele = UIApplication.shared.delegate as! AppDelegate
        appdele.chatVcObject = self
        if let secretId = self.chatViewModelObj?.secretID ,secretId != ""{
            self.currentChatStatusLabelOutlet.text = "                                                                             "
        }else {
        self.currentChatStatusLabelOutlet.text = "                                                           "
        }
        
        
        let backgroundSize: CGSize = (self.collectionView?.frame.size)!
        chatBackgroundView.frame = CGRect(x: 0, y: 0,width:backgroundSize.width, height: backgroundSize.height)
        self.collectionView?.backgroundView = self.chatBackgroundView
 
        self.initialSetup()
        self.setTitleName()
        self.removeReplyView()
        if !self.isGroup {
        getblockUserStatusApicall(reciverID: self.receiverID)
        }
        self.userImageOutlet.makeCornerRadious(readious: self.userImageOutlet.frame.size.width / 2)
    }
    
    func setTitleName() {
        self.userName = self.getReceiverName()
        self.TitleLabelOutlet.text = self.userName
//        self.currentChatStatusLabelOutlet.text = "                                                                                                                                                                       "
        /*
         Bug Name:- default initial based pic does not show on chat
         Fix Date:- 31/05/21
         Fix By  :- Jayaram G
         Description of Fix:- assigning initials pic
         */
        let profilePic = self.getProfilePic()
        let defailtImage = isGroup ? #imageLiteral(resourceName: "group_defaultImage") : #imageLiteral(resourceName: "defaultImage")
        if isGroup {
            self.userImageOutlet.setImageOn(imageUrl: profilePic, defaultImage: defailtImage)
        }else{
            Helper.addedUserImage(profilePic: profilePic, imageView: userImageOutlet, fullName: self.getReceiverName() ?? "D")
        }

        
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            self.TitleLabelOutlet.attributedText = String.addImageToString(text: self.userName, image: #imageLiteral(resourceName: "contact_lock_icon"))
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        blockedTextLabel.frame = CGRect(x: 0, y: self.view.frame.size.height - 40, width: self.view.frame.size.width, height: 40)
        blockedTextLabel.backgroundColor = Utility.appColor()
        blockedTextLabel.font = Utility.Font.Regular.ofSize(12)
        blockedTextLabel.numberOfLines = 2
        blockedTextLabel.textAlignment = .center
        blockedTextLabel.text = "Your not allowed to share message with".localized + " \(self.getReceiverName() ?? "")."
        self.view.addSubview(blockedTextLabel)
        blockedTextLabel.isHidden = true
        
        timeAndDataLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 22)
              timeAndDataLabel.font = Utility.Font.Regular.ofSize(13)
              timeAndDataLabel.textAlignment = .center
              timeAndDataLabel.textColor = .black
              timeAndDataLabel.alpha = 0.5
              self.timeAndDataLabel.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.7694212148)
              self.view.addSubview(timeAndDataLabel)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
        /*
         Bug Name:- Reply view not aligned properly
         Fix Date:- 21/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Handling reply view frame
         */
        if Utility.getDeviceHasSafeAreaStatus() {
            self.changedFrame = CGRect(x: 0, y: self.view.frame.size.height - 80, width: UIScreen.main.bounds.width, height: 60)
        }else{
            self.changedFrame = CGRect(x: 0, y: self.view.frame.size.height - 60, width: UIScreen.main.bounds.width, height: 60)
        }
        
        self.receiverID = self.getReceiverID()
        guard let revID = self.receiverID else { return }
        self.disablePushNotificaation(forUser: self.receiverID)
        mqttChatManager.subscribeTypingChannel(withUserID: self.receiverID)
        mqttChatManager.subscibeToLastSeenChannel(withUserID: self.receiverID)
        self.isuserBlock = self.getIsUserBlock()
        if self.isGroup {
            if !isActiveGroup  {addFooterView()
//                self.enableCalls(isEnable: isuserBlock)
            }
        }else {
            if isuserBlock {
                addFooterView()
                
                
                self.enableCalls(isEnable: isuserBlock)
            }
        }
        
        if self.isGroup {
            if isActiveGroup {self.inputToolbar.isHidden = false}
        }else {
            if isuserBlock{
                
                self.inputToolbar.isHidden = true
                self.blockedTextLabel.isHidden = false
            }
        }
        self.hideToolBarr()
        
        //send ReadAck to other User
        checkAndsendReadAck()
        self.addCameraBtn()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardFrameWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func checkAndsendReadAck(){
        //Send ReadAck to other User
        if let chatDocID = self.chatDocID {
            if let chatData = couchbaseObj.getData(fromDocID: chatDocID) {
                self.messages = self.chatsDocVMObject.getMessages(withChatDocID: self.chatDocID)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    self.finishSendingMessage(animated: true)
                }
                DispatchQueue.global().async {
                    self.fetchLastMessageFromSenderAndSendAcknowledgment(withChatData: chatData)
                }
            }
        }
    }
    
     
    
    
    override func viewWillAppear(_ animated: Bool) {
        /*
         Bug Name:- User able to send chat even blocked
         Fix Date:- 23/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Handling block status
         */
        loadData()
        if let blockStatus = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isUserBlockStatusChanged) as? Bool , blockStatus {
            if !self.isGroup {
            getblockUserStatusApicall(reciverID: self.receiverID)
            }
        }
        
        /*
         Bug Name:- Chat->Single Chat->Once we click single chat there for star users star icon is not showing.
         Fix Date:- 23/08/21
         Fix By  :- Jayaram G
         Description of Fix:- Showing indication image for star profile
         */
        if let isStarStatus = self.chatViewModelObj?.isStar as? Int {
            if !self.getIsGroup(){
                if isStarStatus == 1 {
                    self.starIndicationImage.isHidden = false
                    self.enableCalls(isEnable: false)
                }else{
                    self.starIndicationImage.isHidden = true
                }
            }else{
                self.starIndicationImage.isHidden = true
            }
            
            
        }else if self.isStar {
            if !self.getIsGroup(){
                self.enableCalls(isEnable: false)
              self.starIndicationImage.isHidden = false
            }else{
                self.starIndicationImage.isHidden = true
            }
        }else{
            self.starIndicationImage.isHidden = true
        }
         if !self.isLoadedOnce{
            self.isLoadedOnce = true
            super.viewWillAppear(animated)
            self.automaticallyScrollsToMostRecentMessage = true
        }
        
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
        if #available(iOS 13.0, *) {
            self.inputToolbar.backgroundColor = .systemBackground
            self.inputToolbar.contentView?.leftBarButtonItem?.tintColor = .label
            self.inputToolbar.contentView?.rightBarButtonItem?.tintColor = .label
        }
        self.collectionView?.backgroundColor = UIColor.clear
        self.addRefresher()
        registerObservers()
        if let isNetwork = (UIApplication.shared.delegate as? AppDelegate)?.isNetworkThere {
            if isNetwork {
//                if self.audiobutton != nil {
//                    self.audiobutton.isEnabled  = true
//                    self.videoButton.isEnabled = true
//                }
                if  !isuserBlock  {
                    self.currentChatStatusLabelOutlet.isHidden = false
                    
                }
            } else {
//                if self.audiobutton != nil {
//                    self.audiobutton.isEnabled = false
//                    self.videoButton.isEnabled = false}
                if  !isuserBlock  {
//                    self.currentChatStatusLabelOutlet.isHidden = true
                    self.currentChatStatusLabelOutlet.text = "                                                       "
                }
            }
        }
        Reachability.rx.isReachable
            .subscribe(onNext: { isReachable in
                if isReachable == true {
//                    if self.audiobutton != nil {
//                        self.audiobutton.isEnabled  = true
//                        self.videoButton.isEnabled = true
//                    }
                    if  !self.isuserBlock  {
                        self.currentChatStatusLabelOutlet.isHidden = false
                    }
                } else {
//                    if self.audiobutton != nil {
//                        self.audiobutton.isEnabled = false
//                        self.videoButton.isEnabled = false}
                    if  !self.isuserBlock  {
//                        self.currentChatStatusLabelOutlet.isHidden = true
                        self.currentChatStatusLabelOutlet.text = "                                                       "
                    }
                }
            }).disposed(by: disposebag)
        
        if !isGroup {
            self.setTitleName()
        }
        self.tabBarController?.tabBar.isHidden = true
        self.setupVoiceRecordUI()
        if self.isGroup {
            if isActiveGroup {
                self.inputToolbar.isHidden = false
            }
        } else {
            if isuserBlock{
                self.inputToolbar.isHidden = true
                self.blockedTextLabel.isHidden = false
            }
        }
        
        
        
//        self.addCameraBtn()
        self.addBackgroundImage()
        self.jsq_register(forNotifications: true)
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /*
         Bug Name:- User able to send chat even blocked
         Fix Date:- 23/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Handling block status
         */
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isUserBlockStatusChanged)
        if let chatDocID = self.chatDocID {
            self.updateChatForReadMessage(toDocID: chatDocID, isControllerAppearing: false)
        }
        if let receiverID = self.receiverID {
            mqttChatManager.unsubscribeTypingChannel(withUserID: receiverID)
            mqttChatManager.unsubscibeToLastSeenChannel(withUserID: receiverID)
        }
        self.removeObservers()
        self.automaticallyScrollsToMostRecentMessage = false
        
        if let player = self.currentPlayingAudioPlayer {
            player.stop(clearQueue: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.standard.set("", forKey: AppConstants.UserDefaults.isUserOnchatscreen)
        UserDefaults.standard.synchronize()
//        removeObservers()
        if let tabbar = self.tabBarController as? TabbarController {
            tabbar.enablePushNotification()
        }
        
        //For seceret Chat Only
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            //save last Time visited screen & delete it when Chat is deleted..
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "\(String(describing: chatViewModelObj?.secretID))+chatCloseTime")
        }
    }
    
    
    
    @objc func keyboardFrameWillChange(notification: NSNotification) {
        let keyboardEndFrame = ((notification.userInfo! as NSDictionary).object(forKey: UIResponder.keyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue
        let animationCurve = UIView.AnimationCurve(rawValue: ((notification.userInfo! as NSDictionary).object(forKey:UIResponder.keyboardAnimationCurveUserInfoKey)! as AnyObject).integerValue)
        let animationDuration: TimeInterval = ((notification.userInfo! as NSDictionary).object(forKey:UIResponder.keyboardAnimationDurationUserInfoKey)! as AnyObject).doubleValue
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve!)
        
        var newFrame = self.view.frame
//        let keyboardFrameEnd = self.view.convert(keyboardEndFrame!, to: nil)
        let keyboardFrameEnd = keyboardEndFrame!
        /*
         Bug Name:- Reply view not aligned properly
         Fix Date:- 21/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Handling reply view frame
         */
        if Utility.getDeviceHasSafeAreaStatus() {
            if keyboardFrameEnd.size.height > 54 {
                newFrame.origin.y = self.view.frame.size.height - (keyboardFrameEnd.size.height + 60)
            }else{
                newFrame.origin.y = self.view.frame.size.height - (keyboardFrameEnd.size.height + 93)
            }
        }else{
            newFrame.origin.y = self.view.frame.size.height - (keyboardFrameEnd.size.height + 60)
        }
        newFrame.size.height = 60
        changedFrame = newFrame
        self.updateReplyViewFrame()
        self.automaticallyScrollsToMostRecentMessage = true
        UIView.commitAnimations()
    }
    
    
    func checkWalletRegistration() {
        guard let reciverid = self.getReceiverID() else {return}
        guard let receiverName = self.getReceiverName() else {return}
                Helper.showPI(_message: "Loading".localized + "...")
                let strURL = AppConstants.walletCheck + "?userId=\(reciverid)&userName=\(receiverName)&userType=user"
                 guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
                guard  let token = keyDict["token"] as? String  else {return}
                
                let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
                let apiCall = RxAlmofireClass()
                apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters:nil,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.walletCheck.rawValue)
                apiCall.subject_response
                    .subscribe(onNext: {dict in
                        Helper.hidePI()
                        guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                        if responseKey == AppConstants.resposeType.walletCheck.rawValue {
                            self.performSegue(withIdentifier: "sendPaymentSegue", sender: nil)
                        }else {
                            Helper.showAlertViewOnWindow("", message: "Sorry you cannot send any payment to this user as this user has not completed".localized + " " + "his".localized + "/" + "her".localized + " " + "kyc and does not have an active wallet".localized + ".")
                        }
                    }, onError: {error in
                        Helper.hidePI()
                        Helper.showAlertViewOnWindow("", message: "Sorry you cannot send any payment to this user as this user has not completed".localized + " " + "his".localized + "/" + "her".localized + " " + "kyc and does not have an active wallet".localized + ".")
                    })
            }
    
    
    //MARK: - ADD Chat background Wallpaper
    func addBackgroundImage() {
        if let dict = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.colourKey) as? [String:Any] {
            if dict["index"] as! String == "0" {
                self.view.backgroundColor = UIColor.init(patternImage: UIImage.init(named: dict["colour"] as! String )!)
            } else if dict["index"] as! String == "1" {
                self.view.backgroundColor =  Helper.hexStringToUIColor(hex: dict["colour"] as! String )
            } else if dict["index"] as! String == "2" {
                let image = UIImage.init(data: dict["colour"] as! Data)
                backGroudImageView.image = image!
            } else {
                backGroudImageView.image = #imageLiteral(resourceName: "defaultBackground")
            }
        } else {
            backGroudImageView.image = #imageLiteral(resourceName: "defaultBackground")
        }
    }
    
    @objc func inputToolbarCameraCliked() {
        
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            self.seceretChatTimerSheet()
        }else {
            self.openLivecamera()
        }
        
    }
    
    func registerObservers() {
        var name = NSNotification.Name(rawValue: "LastSeen")
        NotificationCenter.default.setObserver(self, selector: #selector(ChatViewController.receivedLastSeenStatus(notification:)), name: name, object: nil)
        name = NSNotification.Name(rawValue: "toolBarHideAndShow")
        NotificationCenter.default.setObserver(self, selector: #selector(ChatViewController.toolBarHideAndShow(notification:)), name: name, object: nil)
        
        name = NSNotification.Name(rawValue: "Typing")
        NotificationCenter.default.setObserver(self, selector: #selector(ChatViewController.receivedTypingStatus(notification:)), name: name, object: nil)
        
        NotificationCenter.default.setObserver(self, selector: #selector(textViewTextDidChangeNotification), name: UITextView.textDidChangeNotification, object: self.inputToolbar.contentView?.textView)
        
        name = NSNotification.Name(rawValue: "MessageNotification" + selfID!)
        NotificationCenter.default.setObserver(self, selector: #selector(ChatViewController.receivedMessage(notification:)), name: name, object: nil)
        
//        name = NSNotification.Name(rawValue: "PullToRefresh")
//        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.stopRefresher(notification:)), name: name, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupInfo), name: NSNotification.Name(rawValue: "updateGroupInfoScreen"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(blockUserRefresher(notification:)), name: NSNotification.Name(rawValue: "updateBlockUser"), object: nil)
        self.textViewTextDidChangeNotification()
    }
    
    
    @objc func blockUserRefresher(notification: NSNotification){
        guard let userInfo = notification.userInfo as? [String: Any] else {return}
        guard let chatDocID = userInfo["chatDocID"] as? String  else {return}
        
        if chatDocID == self.chatDocID{
            self.isuserBlock =  userInfo["isBlock"] as! Bool   // self.getIsUserBlock()
            if isuserBlock {
                addFooterView()
                self.enableCalls(isEnable: isuserBlock)
            }else {
                self.removeFooterView()
                self.enableCalls(isEnable: isuserBlock)
            }
        }
    }
    
    func removeObservers() {
        let name = NSNotification.Name(rawValue: "MessageNotification" + selfID!)
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerXIBs() {
        super.collectionView?.register(UINib(nibName: "SentLocationCell", bundle: nil), forCellWithReuseIdentifier: "SentLocationCell")
        super.collectionView?.register(UINib(nibName: "CallMessageTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CallMessageTypeCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "SentContactMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SentContactMessageCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "ReceivedContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReceivedContactCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "ReceivedLocationCell", bundle: nil), forCellWithReuseIdentifier: "ReceivedLocationCell")
        self.collectionView?.register(UINib(nibName: "SNTextMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SNTextMessageCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "ImageReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageReceivedCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "ImageSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "PostReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostReceivedCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "PostSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "StickerReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StickerReceivedCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "StickerSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StickerSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "VideoReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoReceivedCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "VideoSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "AudioReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AudioReceivedCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "AudioSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AudioSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "AudioSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AudioSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "DocumentSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DocumentSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "DocumentReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DocumentReceivedCollectionViewCell")
        
        
        super.collectionView?.register(UINib(nibName: "TransferSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TransferSentCollectionViewCell")
        super.collectionView?.register(UINib(nibName: "TransferReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TransferReceivedCollectionViewCell")
        
        // Registering Replied Cells
        
        //Replied Received Text
        super.collectionView?.register(UINib(nibName: "ReceivedTextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReceivedTextCollectionViewCell")
        
        //Replied Sent Text
        super.collectionView?.register(UINib(nibName: "SentTextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SentTextCollectionViewCell")
        
        //Replied Audio Received
        super.collectionView?.register(UINib(nibName: "RepliedAudioReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedAudioReceivedCollectionViewCell")
        
        // Replied Audio Sent
        super.collectionView?.register(UINib(nibName: "RepliedAudioSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedAudioSentCollectionViewCell")
        
        // Replied Received Contact
        super.collectionView?.register(UINib(nibName: "RepliedReceivedContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedReceivedContactCollectionViewCell")
        
        // Replied Sent Contact
        super.collectionView?.register(UINib(nibName: "RepliedSentContactMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedSentContactMessageCollectionViewCell")
        
        // Replied Document Received
        super.collectionView?.register(UINib(nibName: "RepliedDocumentReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedDocumentReceivedCollectionViewCell")
        
        // Replied Document Sent
        super.collectionView?.register(UINib(nibName: "RepliedDocumentSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedDocumentSentCollectionViewCell")
        
        // Replied Image Received
        super.collectionView?.register(UINib(nibName: "RepliedImageReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedImageReceivedCollectionViewCell")
        
        //Replied Image Sent
        super.collectionView?.register(UINib(nibName: "RepliedImageSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedImageSentCollectionViewCell")
        
        //Replied Received Location
        super.collectionView?.register(UINib(nibName: "RepliedReceivedLocationCell", bundle: nil), forCellWithReuseIdentifier: "RepliedReceivedLocationCell")
        
        //Replied Sent Location
        super.collectionView?.register(UINib(nibName: "RepliedSentLocationCell", bundle: nil), forCellWithReuseIdentifier: "RepliedSentLocationCell")
        
        //Replied Sticker Received
        super.collectionView?.register(UINib(nibName: "RepliedStickerReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedStickerReceivedCollectionViewCell")
        
        //Replied Sticker Sent
        super.collectionView?.register(UINib(nibName: "RepliedStickerSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedStickerSentCollectionViewCell")
        
        // Replied Video Sent
        super.collectionView?.register(UINib(nibName: "RepliedVideoSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedVideoSentCollectionViewCell")
        
        //Replied Video Received
        super.collectionView?.register(UINib(nibName: "RepliedVideoReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RepliedVideoReceivedCollectionViewCell")
        
        //Deleted Received
        super.collectionView?.register(UINib(nibName: "DeletedReceivedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DeletedReceivedCollectionViewCell")
        
        //Deleted Sent
        super.collectionView?.register(UINib(nibName: "DeletedSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DeletedSentCollectionViewCell")
        
        //GpMessage Type
        super.collectionView?.register(UINib(nibName: "GpMessageTypeCell", bundle: nil), forCellWithReuseIdentifier: "GpMessageTypeCell")
    }
    
    /// Used for showing a pull to refresh for refreshing/pulling the chat.
    func addRefresher() {
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
    }
    
    @objc func loadData() {
        
        
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            //for secret chat
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                       self.refresher.endRefreshing()
                   }
            
//            return
        }
        
        var timeStamp = Int64(floor(Date().timeIntervalSince1970 * 1000))
        if let ts = self.messages.first?.messageId {
            if let tStamp = Int64(ts) {
                timeStamp = tStamp
            }
        }
        
        mqttChatManager.subscribeToGetMessageTopic(withUserID: self.selfID!)
        self.fetchMessages(withTimeStamp: "\(timeStamp)")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            self.refresher.endRefreshing()
        }
    }
    
    private func setupInvitedFlag() {
        
    }
    
    private func isUserInitallyComing() -> Bool {
        if let chatid = self.chatViewModelObj?.chatID {
            if chatid.count == 24 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    /// Calls when the notification received for getting chats.
    ///
    /// - Parameter notification: Notification with the chat details.
    @objc func stopRefresher(notification: NSNotification) {
        self.refresher.endRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            Helper.hidePI()
        }
        let userInfo = notification.userInfo as! [String: Any]
        if ((userInfo["chatId"] as? String) == (self.chatViewModelObj?.chatID)) {
            self.setUpCollectionView(withChatDocID: self.chatDocID)
        }
        DispatchQueue.main.async {
            self.scrollToBottom(animated: true)
        }
    }
    
    fileprivate func fetchMessages(withTimeStamp timeStamp: String) {
        if isUserInitallyComing() {
            self.chatViewModelObj?.receiverID = self.getReceiverID()
            self.chatViewModelObj?.getMessages(withTimeStamp: timeStamp, andPageSize: Constants.messagePageSize)
            self.collectionView?.reloadData()
        }
    }
    
    //TextView did Changed text here
    @objc func textViewTextDidChangeNotification() {
        if (self.inputToolbar.contentView?.textView?.text.count == 0 ) {
            recordingView.isHidden = false
            self.inputToolbar.contentView?.rightBarButtonItem?.isEnabled = false
            camerabtn?.isHidden = false
        }else{
            recordingView.isHidden = true
            camerabtn?.isHidden = true
            recordingView.backgroundColor = UIColor.clear
            self.inputToolbar.contentView?.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func setupVoiceRecordUI() {
//        recordingView.delegate = self
        /*
         Bug Name:- Crash
         Fix Date:- 01/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Added image lateral
         */
        recordingView.recordingImages = [#imageLiteral(resourceName: "rec1") ,#imageLiteral(resourceName: "rec2"),#imageLiteral(resourceName: "rec3"),#imageLiteral(resourceName: "rec4"),#imageLiteral(resourceName: "rec5"),#imageLiteral(resourceName: "rec6")]
        
        self.inputToolbar.addSubview(recordingView)
        
        /*
         Bug Name:- Increase toolbar height
         Fix Date:- 21/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Tool bar height increased and handled record button ui
         */
        
        let vConsts = NSLayoutConstraint(item:self.recordingView , attribute: .bottom, relatedBy: .equal, toItem: self.inputToolbar, attribute: .bottom, multiplier: 1.0, constant: -9)
        
        /*
         Bug Name:- change chat send button UI
         Fix Date:- 10/05/21
         Fix By  :- Jayaram G
         Description of Fix:- changed right button constraints
         */
        let hConsts = NSLayoutConstraint(item: self.recordingView, attribute: .trailing, relatedBy: .equal, toItem: self.inputToolbar, attribute: .trailing, multiplier: 1.0, constant: -16)
        
        self.inputToolbar.addConstraints([hConsts])
        self.inputToolbar.addConstraints([vConsts])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
 //       self.setupVoiceRecordUI()
    }
    
    
    
    fileprivate func initialSetup() {
        self.inputToolbar.contentView?.leftBarButtonItem?.tintColor = .white
        self.inputToolbar.contentView?.textView?.placeHolder = "New Message".localized
        self.inputToolbar.contentView?.textView?.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        self.inputToolbar.contentView?.textView?.backgroundColor = UIColor.setColor(lightMode: AppColourStr.whiteColor, darkMode: AppColourStr.descriptionLabel)
        if let userID = Utility.getUserid() {self.userID  = userID} else {self.userID = ""}
        if let imageUrl = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImageForChats) as? String{
            self.selfUserImageUrl = imageUrl
        }
        self.receiverID = self.getReceiverID()
        self.registerNum = self.getRegisterNum()
        self.isGroup = self.getIsGroup()
        if self.isGroup == true {
            self.navigationItem.rightBarButtonItems = []
            self.getgpDocIdfromgroupDatabase(groupID:self.receiverID)
        }
        
//        if let secretId = self.chatViewModelObj?.secretID ,secretId != ""{
//            self.navigationItem.rightBarButtonItems = []
//        }
        /*
         Bug Name:- messaged from profile page ,creates a blank space on top
         Fix Date:- 18/09/2021
         Fixed By:- Jayaram G
         Discription of Fix:- Making headerReferenceSize to Zero
         */
        self.collectionView?.collectionViewLayout.headerReferenceSize = CGSize.zero
        
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width:35.0, height:35.0)
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width:35.0, height:35.0)
        self.collectionView?.collectionViewLayout.springinessEnabled = false
        self.automaticallyScrollsToMostRecentMessage = true
        if let favoriteObj = favoriteObj {
            guard let chatDocId = favoriteObj.chatDocID else { return }
            if chatDocId.count>0 {
                self.chatDocID = chatDocId
                self.setUpCollectionView(withChatDocID: chatDocId)
                self.updateChatForReadMessage(toDocID: chatDocId, isControllerAppearing: true)
                self.chatViewModelObj = self.getChatViewModalObj(fromChatDocID: chatDocId)
                UserDefaults.standard.set(chatDocId, forKey: AppConstants.UserDefaults.isUserOnchatscreen)
                UserDefaults.standard.synchronize()
            }
        } else {
            guard let chatDocID = self.getChatDocID() else { return }
            self.chatDocID = chatDocID
            UserDefaults.standard.set(chatDocID, forKey: AppConstants.UserDefaults.isUserOnchatscreen)
            UserDefaults.standard.synchronize()
            self.setUpCollectionView(withChatDocID: self.chatDocID)
            self.updateChatForReadMessage(toDocID: self.chatDocID, isControllerAppearing: true)
        }
        
        self.isuserBlock = self.getIsUserBlock()
        if self.isGroup {
            if !isActiveGroup  {
                addFooterView()
//                self.enableCalls(isEnable: isuserBlock)
            }
        }else {
            if isuserBlock {
                addFooterView()
                
                self.enableCalls(isEnable: isuserBlock)
            }
        }
        
        
        //Show unsend text Message in TextView
        if self.chatDocID != nil {
            if let text =  UserDefaults.standard.object(forKey: self.chatDocID)  as? String {
                if text != "" {
                    self.inputToolbar.contentView?.textView?.text = text
                    self.inputToolbar.contentView?.rightBarButtonItem?.isEnabled = true
                    self.inputToolbar.contentView?.rightBarButtonItem?.setImage(#imageLiteral(resourceName: "send_btn"), for: .normal)
                }
            }
        }
    }
    
    private func enableCalls(isEnable:Bool) {
        
        if isEnable {
            if self.chatViewModelObj?.secretID == nil || self.chatViewModelObj?.secretID == ""{
//                self.audiobutton.isEnabled = false
//                self.videoButton.isEnabled = false
                self.navigationItem.rightBarButtonItems = []
            }
            //
            
            self.currentChatStatusLabelOutlet.isHidden = true
            self.currentChatStatusLabelOutlet.text = "                                                           "
        }else{
            
            if self.chatViewModelObj?.secretID == nil || self.chatViewModelObj?.secretID == ""{
                if self.audiobutton != nil && self.videoButton != nil {
                    if let isStarStatus = self.chatViewModelObj?.isStar as? Int  {
                        guard let isSelfStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool else{ return}
                        if isStarStatus == 1 && !isSelfStarVerified {
//                            self.audiobutton.isEnabled = false
//                            self.videoButton.isEnabled = false
                            self.navigationItem.rightBarButtonItems = []
                        }else{
                            self.audiobutton.isEnabled = true
                            self.videoButton.isEnabled = true
                        }
                    }else if self.isStar {
                        guard let isSelfStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool else{ return}
                        if !isSelfStarVerified{
                            self.navigationItem.rightBarButtonItems = []
                        }else{
                            self.audiobutton.isEnabled = true
                            self.videoButton.isEnabled = true
                        }
                                                
                    }else{
                        self.audiobutton.isEnabled = true
                        self.videoButton.isEnabled = true
                    }
                }
            }else{
                if let isStarStatus = self.chatViewModelObj?.isStar as? Int  {
                    guard let isSelfStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool else{ return}
                    if isStarStatus == 1 && !isSelfStarVerified {
//                            self.audiobutton.isEnabled = false
//                            self.videoButton.isEnabled = false
                        self.navigationItem.rightBarButtonItems = []
                    }else{
                        self.audiobutton.isEnabled = true
                        self.videoButton.isEnabled = true
                    }
                }else if self.isStar {
                    guard let isSelfStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool else{ return}
                    if !isSelfStarVerified{
                        self.navigationItem.rightBarButtonItems = []
                    }else{
                        self.audiobutton.isEnabled = true
                        self.videoButton.isEnabled = true
                    }
                                            
                }else{
                    self.audiobutton.isEnabled = true
                    self.videoButton.isEnabled = true
                }
            }
            
            
            self.currentChatStatusLabelOutlet.isHidden = false
        }
    }
    
    
    /// Disable notifications whenever you are in the same chat controller.
    ///
    /// - Parameter user: current user id.
    private func disablePushNotificaation(forUser user : String) {
        userDefault.set(user, forKey: "currentUserId")
        userDefault.synchronize()
    }
    
    
    
    @IBAction func titlebuttonCliked(_ sender: Any) {
        if self.isGroup  == true{
//            self.performSegue(withIdentifier: Constants.chatTogroupInfoSegue, sender: self)
            self.nevigateToGroupInfoScreen()
        }else {
            self.performSegue(withIdentifier: "chatTouserDetails", sender: self)
        }
    }
    
    
    fileprivate func nevigateToGroupInfoScreen(){
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.chat, bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.GroupInfoTableViewController) as? GroupInfoTableViewController else{return}
        
        guard let groupDocId = self.groupDocumentID else {return}
        let mainDoc = self.couchbaseObj.getDocumentObject(fromDocID:self.groupDocumentID!)
        guard let chatDocID = self.chatDocID else { return }
        let gpData = mainDoc?.properties!
        let gpInfoDict = gpData!["groupMembersDocId"] as! [String:Any]
        groupInfo = gpInfoDict
        controller.chatviewControllerDelegateObj = self
        controller.chatVMObj = chatViewModelObj
        controller.groupInfo = self.groupInfo
        controller.groupName = self.userName
        controller.groupImage = self.getProfilePic()
        controller.groupID = self.receiverID
        controller.groupDocumentID = groupDocId
        controller.chatDocID = chatDocID
        controller.chatsDocVMObject = self.chatsDocVMObject
        controller.clearChatBlock = { isClear in
            self.messages = self.chatsDocVMObject.getMessages(withChatDocID: self.chatDocID)
            DispatchQueue.main.async{
                self.collectionView?.reloadData()
            }
        }
        controller.gpNameBlock = { groupName in
            self.userName = groupName
            self.TitleLabelOutlet.text = self.userName
            self.updateChatStatus()
        }
        controller.gpImageBlock = { gpImage in
            self.groupImage = gpImage
            self.updateChatStatus()
        }
        controller.gpActiveBlock = { gpActive in
            if gpActive == true {
                self.removeFooterView()
                self.isActiveGroup = gpActive
            }
            else {self.addFooterView()
                
                self.isActiveGroup = gpActive
            }
            self.updateChatStatus()
        }
        controller.gpMemeberBlock = {gpMemebers in
            self.currentChatStatusLabelOutlet.text = "                                                           "
            self.showGroupMembersOnNavigation(memArr:gpMemebers)
            self.updateChatStatus()
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func sendTypingStatus() {
        if let selfID = self.receiverID {
            mqttChatManager.sendTyping(toUser: selfID)
        }
    }
    
    override func senderId() -> String {
        guard let selfID = selfID else { return ""}
        return selfID
    }
    
    func getReceiverID() -> String? {
        if  let favoriteObj = favoriteObj {
            return  favoriteObj.userID
        } else if let chatViewModelObj = chatViewModelObj {
            return chatViewModelObj.userID
        }
        return nil
    }
    
    func getReceiverName() -> String? {
        if isGroup == true {
            return chatViewModelObj?.groupName
        }
        
        if  let favoriteObj = favoriteObj {
            /*
             Bug Name:- Show full name in chats instead of username
             Fix Date:- 12/05/2021
             Fixed By:- Jayaram G
             Discription of Fix:- Replaced username with fullname
             */
            return "\(favoriteObj.firstName ?? "")" + " " + "\(favoriteObj.lastName ?? "")"
        } else if let chatViewModelObj = chatViewModelObj {
            return chatViewModelObj.name
        }
        return nil
    }
    
    func getUserStatus() -> String? {
        if  let favoriteObj = favoriteObj {
            return  favoriteObj.status
        } else if chatViewModelObj != nil {
            return AppConstants.defaultStatus
        }
        return nil
    }
    
    func getRegisterNum() -> String? {
        if  let favoriteObj = favoriteObj {
            return  favoriteObj.registerNum
        } else if let chatViewModelObj = chatViewModelObj {
            return chatViewModelObj.number
        }
        return nil
    }
    
    func getIsGroup() -> Bool {
        if let chatViewModelObj = chatViewModelObj {
            return chatViewModelObj.isGroupChat
        }
        return false
    }
    
    func getIsUserBlock() -> Bool {
        if let chatViewModelObj = chatViewModelObj {
            return chatViewModelObj.isUserBlock
        }
        return false
    }
    
    
    func getProfilePic() -> String? {
        
        if self.groupImage != nil{
            return self.groupImage
        }
        
        if let favoriteObj = favoriteObj{
            return  favoriteObj.profilePic
        }else if let chatViewModelObj = chatViewModelObj{
            if chatViewModelObj.chat.image == ""{
                return " "
            }
            if chatViewModelObj.isUserBlock {
                return nil
            }else {
            return  chatViewModelObj.chat.image
            }
          }
        return nil
    }
    
    func getChatViewModalObj(fromChatDocID chatDocID : String) -> ChatViewModel? {
        guard let chatObj = chatsDocVMObject.getChatObj(fromChatDocID: chatDocID) else { return nil }
        return ChatViewModel(withChatData: chatObj)
    }
    
    
    /// This method is for getting/creating the chat without having any message.
    ///
    /// - Returns: chat document ID
    func getChatDocID() -> String? {
        if let chatViewModelObj = chatViewModelObj {
            return chatViewModelObj.docID
        } else if let favoriteObj = favoriteObj {
            let individualChatDocVMObject = IndividualChatViewModel(couchbase: couchbaseObj)
            guard let chatDocID = individualChatDocVMObject.getChatDocID(withreceiverID: favoriteObj.userID!, andSecretID: "", withContactObj: favoriteObj, messageData: nil, destructionTime: nil, isCreatingChat: false) else {
                DDLogDebug("error in creating chatdoc \(self)")
                return nil
            }
            if let chatObj = chatsDocVMObject.getChatObj(fromChatDocID: chatDocID) {
                self.chatViewModelObj = ChatViewModel(withChatData: chatObj)
            }
            return chatDocID
        } else if let receiverID = self.getReceiverID(){
            let individualChatDocVMObject = IndividualChatViewModel(couchbase: couchbaseObj)
            guard let chatDocID = individualChatDocVMObject.getChatDocID(withreceiverID: receiverID, andSecretID: "", withContactObj: nil, messageData: nil, destructionTime: nil, isCreatingChat: false) else {
                DDLogDebug("error in creating chatdoc \(self)")
                return nil
            }
            if let chatObj = chatsDocVMObject.getChatObj(fromChatDocID: chatDocID) {
                self.chatViewModelObj = ChatViewModel(withChatData: chatObj)
            }
            return chatDocID
        }
        return nil
    }
    
    
    
    func getTimedifference() -> TimeInterval{
        if let appCloseTime = UserDefaults.standard.object(forKey: "appCloseTime") as? TimeInterval {
            let currentTime = Date().timeIntervalSince1970
            let diff = currentTime - appCloseTime
            return diff
        }
        return 0
    }
    
    func getScreenTimediffrence() -> TimeInterval {
        
        if let screenCloseTime = UserDefaults.standard.object(forKey: "\(String(describing: chatViewModelObj?.secretID))+chatCloseTime") as? TimeInterval {
            let currentTime = Date().timeIntervalSince1970
            let diff = currentTime - screenCloseTime
            return diff
        }
        return 0
        
    }
    
    func setUpCollectionView(withChatDocID chatDocID: String) {
        self.messages = self.chatsDocVMObject.getMessages(withChatDocID: self.chatDocID)
        
        //First time load messages check for secert Chat and dTime For Messages
        //check for dtime for each message
        
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            var tempArr = self.messages
            for  msg  in tempArr {
                if msg.dTime != 0 && msg.isSelfMessage == true && (msg.gpMessageType == "") && msg.messageStatus == "3"{
                    //if message is seen then delete it from db and ChatUI For send Messagess
                    
                    if getTimedifference() > TimeInterval(msg.dTime) {
                        print("dTime is less so delete me")
                        if self.messages.contains(msg) {
                            let index = self.messages.index(of: msg)
                            self.messages.remove(at: index!)
                            self.chatsDocVMObject.deletePerticularMessageInDataBase(messageID: msg.messageId, docID: self.chatDocID)
                        }
                    }else  if getTimedifference() < TimeInterval(msg.dTime){
                        
                        print("hey change my dTime ..because my time is not over")
                        let newdTime  = msg.dTime - Int(getTimedifference())
                        self.chatsDocVMObject.secretChatTimer(docID:self.chatDocID , messageID: msg.messageId, dTime:newdTime)
                    }
                }else if msg.isSelfMessage == false && msg.dTime != 0 && (msg.gpMessageType == "") {
                    //delete recived Message
                    //if getScreenTimediffrence() < TimeInterval(msg.dTime){
                    if msg.dTime > 0 {
                        print("hey change my dTime ..because my time is not over")
                        let newdTime  = msg.dTime - Int(getTimedifference())
                        self.chatsDocVMObject.secretChatTimer(docID:self.chatDocID , messageID: msg.messageId, dTime:newdTime)
                    }
                    //}
                }
                
            }
            
        }
        
        //Get Old chats through API Call here
        if self.messages.count == 0 {
            self.loadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
                Helper.hidePI()
            }
        }
        DispatchQueue.main.async{
            self.collectionView?.reloadData()
        }
    }
    
    override func senderDisplayName() -> String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
    
    func showdefaultAlert(title : String ,message : String){
        let alert =  UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Navigtion items Button action
    @IBAction func audioBtnAction(_ sender: Any) {
        
        let audioMediaType = convertFromAVMediaType(AVMediaType.audio)
        let audioAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: audioMediaType))
        switch audioAuthorizationStatus {
        case .authorized: self.startAudioCall()
        case .denied : self.showdefaultAlert(title: "Oops".localized.localized, message: AppConstants.audioPermissionMsg)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for:AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.audio)), completionHandler: { isGranted in
                if isGranted == true {
                    OperationQueue.main.addOperation({
                        self.startAudioCall()
                    })
                }else{
                    self.showdefaultAlert(title: "Oops".localized.localized, message: AppConstants.audioPermissionMsg)
                }})
        case .restricted: break
            
        }
        
        //        let cameraMediaType = AVMediaTypeVideo
        //        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
        //        switch cameraAuthorizationStatus {
        //        case .denied:
        //            self.showdefaultAlert(title: "Oops".localized, message: AppConstants.cameraPermissionMsg)
        //            return
        //        case .authorized:
        //
        //            let audioMediaType = AVMediaTypeAudio
        //            let audioAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: audioMediaType)
        //            switch audioAuthorizationStatus {
        //            case .authorized: self.startAudioCall()
        //            case .denied : self.showdefaultAlert(title: "Oops".localized, message: AppConstants.audioPermissionMsg)
        //            case .notDetermined:
        //                        AVCaptureDevice.requestAccess(forMediaType:AVMediaTypeAudio, completionHandler: { isGranted in
        //                        if isGranted == true {
        //                            OperationQueue.main.addOperation({
        //                                self.startAudioCall()
        //                            })
        //                        }else{
        //                            self.showdefaultAlert(title: "Oops".localized, message: AppConstants.audioPermissionMsg)
        //                            }})
        //            case .restricted: break
        //
        //           }
        //        case .restricted: break
        //        case .notDetermined:
        //
        //            AVCaptureDevice.requestAccess(forMediaType: cameraMediaType) { granted in
        //                if granted {
        //                    AVCaptureDevice.requestAccess(forMediaType:AVMediaTypeAudio, completionHandler: { isGranted in
        //                        if isGranted == true {
        //                            OperationQueue.main.addOperation({
        //                                self.startAudioCall()
        //                            })
        //                        } else {
        //                            OperationQueue.main.addOperation({
        //                                self.showdefaultAlert(title: "Oops".localized, message: AppConstants.audioPermissionMsg)
        //                            })
        //                        }
        //                    })
        //                } else {
        //                    OperationQueue.main.addOperation({
        //                        self.showdefaultAlert(title: "Oops".localized, message: AppConstants.cameraPermissionMsg)
        //                    })
        //                    return
        //                }
        //            }
        //
        //        }
    }
    
    @IBAction func videoBtnAction(_ sender: Any) {
        let cameraMediaType = convertFromAVMediaType(AVMediaType.video)
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: cameraMediaType))
        switch cameraAuthorizationStatus {
        case .denied:
            self.showdefaultAlert(title: "Oops".localized, message: AppConstants.cameraPermissionMsg)
            return
        case .authorized:   let audioMediaType = convertFromAVMediaType(AVMediaType.audio)
        let audioAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: audioMediaType))
        switch audioAuthorizationStatus {
        case .authorized:  self.startVideoCall()
        case .denied : self.showdefaultAlert(title: "Oops".localized, message: AppConstants.audioPermissionMsg)
        case .notDetermined: AVCaptureDevice.requestAccess(for:AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.audio)), completionHandler: { isGranted in
            if isGranted == true {
                OperationQueue.main.addOperation({
                    self.startVideoCall()
                })
            } else {
                self.showdefaultAlert(title: "Oops".localized, message: AppConstants.audioPermissionMsg)
            }
        })
        case .restricted: break
            }
        case .restricted: break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: cameraMediaType)) { granted in
                if granted {
                    AVCaptureDevice.requestAccess(for:AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.audio)), completionHandler: { isGranted in
                        if isGranted == true {
                            OperationQueue.main.addOperation({
                                self.startVideoCall()
                            })
                        }else{
                            OperationQueue.main.addOperation({
                                self.showdefaultAlert(title: "Oops".localized, message: AppConstants.audioPermissionMsg)
                            })
                            return
                        }
                    })
                } else {
                    OperationQueue.main.addOperation({
                        self.showdefaultAlert(title: "Oops".localized, message: AppConstants.cameraPermissionMsg)
                    })
                    return
                }
            }
        }
    }
    
    func startAudioCall(){
//        if Helper.checkCallGoingOn() == true{
//            return
//        }
//        MQTTCallManager.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + ownID)
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        let storyboard = UIStoryboard(name: "CallKit", bundle: nil)
        guard let callVC = storyboard.instantiateViewController(withIdentifier: String(describing:CallViewController.self)) as? CallViewController else { return }
        let userdata = ["userName" : (chatViewModelObj?.chat.name) ?? "", "userImage" : (chatViewModelObj?.chat.image) ?? ""]
        callVC.userData = userdata
        UserDefaults.standard.set(true, forKey: "iscallgoingOn")
        callVC.viewModel.createRoom()
        if chatViewModelObj == nil {
            callVC.viewModel.addNewUserId((favoriteObj?.userID) ?? "")
        }else{
            callVC.viewModel.addNewUserId((chatViewModelObj?.chat.userID) ?? "")
        }
        self.resignFirstResponder()
//        self.inputToolbar.alpha = 0.0
        callVC.callType = .Audio
//        self.navigationController?.pushViewController(callVC, animated: true)
        let appdel = UIApplication.shared.delegate as! AppDelegate
//        let transition = CATransition()
//        transition.duration = 0.5
//        callVC.modalPresentationStyle = .fullScreen
//        transition.type = CATransitionType.fade
//        transition.subtype = CATransitionSubtype.fromBottom
//        callVC.view.layer.add(transition, forKey: kCATransition)
//        appdel.window!.rootViewController!.present(callVC, animated: false, completion: nil)
        appdel.window!.addSubview(callVC.view)

    }
    
    func startVideoCall(){
//        if Helper.checkCallGoingOn() == true{
//            return
//        }
//        MQTTCallManager.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + ownID)
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        let storyboard = UIStoryboard(name: "CallKit", bundle: nil)
        guard let callVC = storyboard.instantiateViewController(withIdentifier: String(describing:CallViewController.self)) as? CallViewController else { return }
        let userdata = ["userName" : (chatViewModelObj?.chat.name) ?? "", "userImage" : (chatViewModelObj?.chat.image) ?? ""]
        callVC.userData = userdata
        UserDefaults.standard.set(true, forKey: "iscallgoingOn")
        callVC.viewModel.createRoom()
        if chatViewModelObj == nil {
            callVC.viewModel.addNewUserId((favoriteObj?.userID) ?? "")
        }else{
            callVC.viewModel.addNewUserId((chatViewModelObj?.chat.userID) ?? "")
        }
        callVC.callType = .Video
        self.resignFirstResponder()
        let appdel = UIApplication.shared.delegate as! AppDelegate
        appdel.window!.addSubview(callVC.view)

    }
    
    //MARK: Preperfor segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatTouserDetails" {
            let contactINfo = segue.destination as? ContactInfoTableViewController
            contactINfo?.chatIndexPath = self.chatListIndexPath
            contactINfo?.hidesBottomBarWhenPushed = true
            if let registerNum = self.registerNum {contactINfo?.userRegisterNum = registerNum}else {contactINfo?.userRegisterNum = "" }
            if let userID = self.receiverID { contactINfo?.userID = userID }else { contactINfo?.userID = "" }
            if let userName = self.userName {contactINfo?.userName = userName } else {contactINfo?.userName = "" }
            if let userImage = self.getProfilePic() {contactINfo?.userImage = userImage } else {contactINfo?.userImage = "" }
            if let userStatus = self.getUserStatus() {contactINfo?.userStatus = userStatus } else {contactINfo?.userStatus = AppConstants.defaultStatus }
            contactINfo?.chatVMObj = chatViewModelObj
            contactINfo?.chatsDocVMObject = self.chatsDocVMObject
            contactINfo?.isBlockUser = isuserBlock
            contactINfo?.clearChatBlock = { isClear in
                if self.chatDocID == nil {return}
                self.messages = self.chatsDocVMObject.getMessages(withChatDocID: self.chatDocID)
                DispatchQueue.main.async{
                    self.collectionView?.reloadData()
                }
            }
            contactINfo?.blockUser = {isBlock in
                if isBlock == true {
                    self.addFooterView()
                    
                    self.isuserBlock  = isBlock
                    self.enableCalls(isEnable:  self.isuserBlock)
                }
                else {
                    self.removeFooterView()
                    if self.chatViewModelObj?.secretID == nil || self.chatViewModelObj?.secretID == ""{
                        self.enableCalls(isEnable: false)
                    }
                    
                    
                    
                    self.isuserBlock  = isBlock
                }
                
            }
            
        }
        else if segue.identifier == "chatTogifsegue" {
            let gifstickerView  = segue.destination as? GifStickerCollectionViewController
            gifstickerView?.isGiphy = sender as? Bool
            gifstickerView?.delegate = self
        }
        else if segue.identifier == Constants.showLocationSegue {
            if let controller = segue.destination as? LocationViewerViewController, let latLongStr = sender as? String {
                controller.currentLatLong = latLongStr
            }
        } else if segue.identifier == Constants.toContactDetailsSegue {
            
            if let controller = segue.destination as? ContactDetailsViewController, let contactVMObj = sender as? ContactMessageViewModal {
                controller.contactVMObj = contactVMObj
            }
        } else if segue.identifier == Constants.documentViewerSegue {
            if let controller = segue.destination as? DocumentViewerViewController, let documentVMObj = sender as? DocumentMessageViewModal {
                controller.docMVMObj = documentVMObj
            }
        }
        else if segue.identifier == Constants.chatTogroupInfoSegue {
            if let controller = segue.destination as? GroupInfoTableViewController {
                if self.groupDocumentID != nil && self.receiverID != nil {
                    let mainDoc = self.couchbaseObj.getDocumentObject(fromDocID:self.groupDocumentID!)
                    guard let chatDocID = self.chatDocID else { return }
                    let gpData = mainDoc?.properties!
                    let gpInfoDict = gpData!["groupMembersDocId"] as! [String:Any]
                    groupInfo = gpInfoDict
                    controller.chatviewControllerDelegateObj = self
                    controller.chatVMObj = chatViewModelObj
                    controller.groupInfo = self.groupInfo
                    controller.groupName = self.userName
                    controller.groupImage = self.getProfilePic()
                    controller.groupID = self.receiverID
                    controller.groupDocumentID = self.groupDocumentID
                    controller.chatDocID = chatDocID
                    controller.chatsDocVMObject = self.chatsDocVMObject
                    controller.clearChatBlock = { isClear in
                        self.messages = self.chatsDocVMObject.getMessages(withChatDocID: self.chatDocID)
                        DispatchQueue.main.async{
                            self.collectionView?.reloadData()
                        }
                    }
                    controller.gpNameBlock = { groupName in
                        self.userName = groupName
                        self.TitleLabelOutlet.text = self.userName
                        self.updateChatStatus()
                    }
                    controller.gpImageBlock = { gpImage in
                        self.groupImage = gpImage
                        self.updateChatStatus()
                    }
                    controller.gpActiveBlock = { gpActive in
                        if gpActive == true {
                            self.removeFooterView()
                            self.isActiveGroup = gpActive
                        }
                        else {self.addFooterView()
                            
                            self.isActiveGroup = gpActive
                        }
                        self.updateChatStatus()
                    }
                    controller.gpMemeberBlock = {gpMemebers in
                        self.currentChatStatusLabelOutlet.text = "                                                           "
                        self.showGroupMembersOnNavigation(memArr:gpMemebers)
                        self.updateChatStatus()
                    }
                }
            }
        }else if segue.identifier == "messageInfoSegue"{
            guard let messageInfoVC = segue.destination as? MessageInfoViewController else{return}
            guard let msg = sender as? Message else{return}
            messageInfoVC.message = msg
            messageInfoVC.chatDocID = self.chatDocID
            if self.isGroup{
                messageInfoVC.isGroup = self.isGroup
                messageInfoVC.chatId = self.chatViewModelObj?.chatID
                if let groupMemCount = self.groupMembers?.count {
                    messageInfoVC.memberCount = groupMemCount
                }
             }
        }
    }
    
    //Hide inputToolbar if callView coming
    func hideToolBarr() {
//        self.inputToolbar.isHidden = false
        if let videoView = appDelegetConstant.window.viewWithTag(17) as? IncomingVideocallView{
            videoView.chatViewObj = self
         //   self.inputToolbar.isHidden = true
            self.blockedTextLabel.isHidden = false
            self.inputToolbar.contentView?.textView?.resignFirstResponder()
        }
    }
    
    
    //ADD CameraButton
    func addCameraBtn() {
        if camerabtn == nil {
        camerabtn = UIButton.init(frame:CGRect.init(x: (self.inputToolbar.contentView?.textView?.frame.size.width)! - 40  , y: -2, width: 35, height: 35))
            if Utility.isDarkModeEnable(){
                camerabtn?.tintColor = .white
                camerabtn?.setImage(#imageLiteral(resourceName: "cameraOffWhite"), for: .normal)
            }else{
                camerabtn?.setImage(#imageLiteral(resourceName: "cameraOff"), for: .normal)
            }
            
            camerabtn?.setImage(#imageLiteral(resourceName: "cameraOn"), for: .highlighted)
            if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
                camerabtn?.setImage(#imageLiteral(resourceName: "timer_Icon"), for: .normal)
                camerabtn?.setImage(#imageLiteral(resourceName: "timer_Icon"), for: .highlighted)
            }
            
            camerabtn?.addTarget(self, action: #selector(inputToolbarCameraCliked), for: .touchUpInside)
            self.inputToolbar.contentView?.textView?.addSubview(camerabtn!)
        }
    }
    
    
    
    //MARK: - ADD FooterView
    //ADD FooterView
    func addFooterView(){
        if footerView == nil {
            footerView = UIView.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 40, width: UIScreen.main.bounds.size.width, height: 50))
            footerView?.backgroundColor = UIColor.white
            let lbl = UILabel.init(frame: CGRect.init(x: 10, y: 0, width:UIScreen.main.bounds.size.width - 10 , height: 40))
            lbl.text = self.isGroup ? "you are no longer participant in this group".localized + "." : "you can't send message".localized
            lbl.adjustsFontSizeToFitWidth = true;
            lbl.minimumScaleFactor=0.5;
            lbl.textAlignment = .center
            footerView?.addSubview(lbl)
            self.inputToolbar.isHidden = true
            self.blockedTextLabel.isHidden = false
            self.view.addSubview(footerView!)
        }else {
            
        }
    }
    
    //Remove FooterView
    func removeFooterView(){
        if self.chatViewModelObj?.secretID == nil || self.chatViewModelObj?.secretID == ""{
            self.enableCalls(isEnable: false)
        }

        self.inputToolbar.isHidden = false
        self.blockedTextLabel.isHidden = true
        footerView?.removeFromSuperview()
        footerView = nil
    }
  
}


extension ChatViewController: ChatViewControllerDelegate {
    func updateGroupMemArray(groupmembers: [[String : Any]]) {
        self.showGroupMembersOnNavigation(memArr: groupmembers)
    }
    
  
    
    
}



// MARK: - Collection View Delegate
extension ChatViewController
{
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let msg = self.messages[indexPath.item]
        if msg.gpMessageType! != "" || msg.messageType! == .transfer{
            return false
        }
//        if action.description == "copy:" || action.description == "delete:"{
//            return true
//        }else if msg.isSelfMessage && action.description == "Info:"{
//            return true
//        }
        self.openingMessageInfoAlert(msg, index: indexPath)
        return false
    }
    
    //MARK: Number of items in view
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("*************\(self.messages.count)")
        return self.messages.count
        
    }
    
    func openingMessageInfoAlert(_ msgObj: Message,index: IndexPath) {
            self.inputToolbar.contentView!.textView!.resignFirstResponder()
            let sheet = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
            sheet.view.tintColor = .black
        let  reply = UIAlertAction(title: "Reply".localized, style: .default) { (action : UIAlertAction) in
                self.collectionView?.reloadItems(at: [index])
                self.addViewOnTopOfKeyboard(withMsgObj: msgObj)
            }
        
        let  copy = UIAlertAction(title: "Copy".localized, style: .default) { (action : UIAlertAction) in
            UIPasteboard.general.string = msgObj.text
        }
        
        let  forward = UIAlertAction(title: "Forward".localized, style: .default) { (action : UIAlertAction) in
            self.addpartiCliked(withMsgObj : msgObj)
        }
        let  deleteMessage = UIAlertAction(title: "Delete messsage".localized, style: .destructive) { (action : UIAlertAction) in
                var deleteOptions = [DeleteConstants.deleteForMe]
                          if msgObj.isSelfMessage {
                              if msgObj.messageType != .deleted {
                                if self.chatViewModelObj?.secretID != "" && self.chatViewModelObj != nil{
                                      deleteOptions = [DeleteConstants.deleteForMe]
                                  }else {
                                      deleteOptions = [DeleteConstants.deleteForEveryone, DeleteConstants.deleteForMe]
                                  }
                              }
                          }
                self.opencontrollerForOptions(withOptions: deleteOptions, withIndexPath: index)
            }
        
          
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
            cancelAction.setValue(Helper.hexStringToUIColor(hex: "#5360F7"), forKey: "titleTextColor")
        if msgObj.messageType == .text {
            sheet.addAction(copy)
        }
        
            sheet.addAction(reply)
            sheet.addAction(forward)
            sheet.addAction(deleteMessage)
            
            sheet.addAction(cancelAction)
            self.present(sheet, animated: true, completion: nil)
        }
    
    //MARK: Data on cell
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return self.messages[indexPath.row]
        }

    
    //MARK: After deletion of message at index path
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didDeleteMessageAt indexPath: IndexPath) {
        // self.toDeleteMessageWith(indexPath:indexPath)
    }
    
    //MARK: To configure outgong or incomming bubble
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
        let message:Message = messages[indexPath.item]
        return (self.senderId() == message.senderId) ? outgoingBubble : incomingBubble
    }
    
    //MARK: For Avatar Images
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
//        if self.isGroup{
            return nil
//        }else{
//            let message:Message = messages[indexPath.item]
//            if self.senderId() == message.senderId{
////                let userImage =
//                return JSQMessagesAvatarImageFactory().avatarImage(withPlaceholder: #imageLiteral(resourceName: "defaultPicture"))
//            }else{
//                return JSQMessagesAvatarImageFactory().avatarImage(withPlaceholder: #imageLiteral(resourceName: "defaultPicture"))
//            }
//        }
    }
    
    //MARK: To show name above message
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        // Displaying names above messages
        //Mark: Removing Sender Display Name
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         */
        
        if isGroup == false {return nil}
        let msg = self.messages[indexPath.item]
        if msg.isSelfMessage {
            return nil
        }
        if indexPath.item - 1 > 0 {
            let prevMsg = self.messages[indexPath.item - 1]
            if prevMsg.senderId == msg.senderId {
                return nil
            }
        }
        return NSAttributedString.init(string: Helper.getNameFormDatabase(num:msg.receiverIdentifier!))
    }
    
    //MARK: Setting up collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let jsqcell = (super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell)
        jsqcell.backgroundColor = Color.clear
        jsqcell.accessoryButton?.isHidden = false
        jsqcell.accessoryButton?.setImage(#imageLiteral(resourceName: "forward_icon"), for: .normal)
        jsqcell.delegate = self
        
        let msg = self.messages[indexPath.item]
        print("name \(msg.messangerName)")
        if let messageMediaType:MessageTypes = msg.messageType {
            switch messageMediaType {
            case .image:
                if msg.isSelfMessage {
                    var cell : ImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageSentCollectionViewCell", for: indexPath) as! ImageSentCollectionViewCell
                    
                    //Creating View Modal from Image Message
                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                    if self.isGroup == true{
                        imageMsgVMobj.isGroup = self.isGroup
                        imageMsgVMobj.groupMembers = self.groupMembers
                        imageMsgVMobj.gpName = self.getReceiverName()
                        imageMsgVMobj.gpImage  = getProfilePic()
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.isReplying = self.isReplying
                    cell.replyMsg = self.replyingMessage
                    cell.index = indexPath
                    cell.imageDeleteDelegate = self
                    cell.imageMsgType = messageMediaType
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    cell.chatDocID = self.chatDocID
                    cell.msgVMObj = imageMsgVMobj
                    cell.panGestureRecognizer?.delegate = self
                    //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! ImageSentCollectionViewCell
                    cell.imageTappedDelegate = self
                    return cell
                } else {
                    var cell : ImageReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageReceivedCollectionViewCell", for: indexPath) as! ImageReceivedCollectionViewCell
                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.chatDocID = self.chatDocID
                    cell.deleteDelegate = self
                    cell.index = indexPath
                    cell.msgVMObj = imageMsgVMobj
                    cell.imageMsgType = messageMediaType
               
                    var imageUrl: String?
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: imageMsgVMobj.message.messangerName ?? "P")
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! ImageReceivedCollectionViewCell
                    cell.imageTappedDelegate = self
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .location:
                if msg.isSelfMessage {
                    var cell : SentLocationCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "SentLocationCell", for: indexPath) as! SentLocationCell
                    cell.deleteDelegate = self
                    cell.index = indexPath
                    cell.backgroundColor = UIColor.clear
                    cell.msgObj = msg
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    cell.locationDelegate = self
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! SentLocationCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                } else {
                    //2 case for !isSelf and Offer = 2, is Accepted
                    var cell : ReceivedLocationCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ReceivedLocationCell", for: indexPath) as! ReceivedLocationCell
                    cell.backgroundColor = UIColor.clear
                    cell.msgObj = msg
                  
                    cell.deleteDelegate = self
                    cell.index = indexPath
                    var imageUrl: String?
                   
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    cell.locationDelegate = self
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: messageVMObj.message.messangerName ?? "P")
                    }
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! ReceivedLocationCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .contact:
                if msg.isSelfMessage {
                    var cell : SentContactMessageCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "SentContactMessageCollectionViewCell", for: indexPath) as! SentContactMessageCollectionViewCell
                    let contactMVMObj = ContactMessageViewModal(withMessage: msg)
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell.index = indexPath
                    cell.deleteDelegate = self
                    cell.msgObj = contactMVMObj
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    //                    cell.senderImageView.setImageOn(imageUrl: self.selfUserImageUrl, defaultImage: #imageLiteral(resourceName: "defaultImage"))
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    cell.contactMessageDelegates = self
                    cell.msgObj.presentControllerDelegate = self
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! SentContactMessageCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                } else {
                    var cell : ReceivedContactCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ReceivedContactCollectionViewCell", for: indexPath) as! ReceivedContactCollectionViewCell
                    let contactMVMObj = ContactMessageViewModal(withMessage: msg)
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell.msgObj = contactMVMObj
                    
                   
                    cell.index = indexPath
                    cell.deleteDelegate = self
                    var imageUrl: String?
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: messageVMObj.message.messangerName ?? "P")
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    cell.contactMessageDelegates = self
                    cell.msgObj.presentControllerDelegate = self
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! ReceivedContactCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .doodle:
                if msg.isSelfMessage {
                    var cell : ImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageSentCollectionViewCell", for: indexPath) as! ImageSentCollectionViewCell
                    
                    //Creating View Modal from Image Message
                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                    
                    if self.isGroup == true{
                        imageMsgVMobj.isGroup = self.isGroup
                        imageMsgVMobj.groupMembers = self.groupMembers
                        imageMsgVMobj.gpImage  = getProfilePic()
                        imageMsgVMobj.gpName = self.getReceiverName()
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    //                    cell.senderImageView.setImageOn(imageUrl: self.selfUserImageUrl, defaultImage: #imageLiteral(resourceName: "defaultImage"))
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.isReplying = self.isReplying
                    cell.replyMsg = self.replyingMessage
                    cell.chatDocID = self.chatDocID
                    cell.imageMsgType = messageMediaType
                    cell.msgVMObj = imageMsgVMobj
                    cell.imageDeleteDelegate = self
                    cell.index = indexPath
                    cell.imageTappedDelegate = self
                    //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! ImageSentCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                } else {
                    var cell : ImageReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageReceivedCollectionViewCell", for: indexPath) as! ImageReceivedCollectionViewCell
                     let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.chatDocID = self.chatDocID
                    cell.msgVMObj = imageMsgVMobj
                    cell.index = indexPath
                    cell.deleteDelegate = self

                    cell.imageMsgType = messageMediaType
                    var imageUrl: String?
                    
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: imageMsgVMobj.message.messangerName ?? "P")
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    //                    cell.senderImageView.setImageOn(imageUrl: imageUrl, defaultImage: #imageLiteral(resourceName: "defaultImage"))
                    cell.imageTappedDelegate = self
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! ImageReceivedCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .video:
                if msg.isSelfMessage {
                    var cell : VideoSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "VideoSentCollectionViewCell", for: indexPath) as! VideoSentCollectionViewCell
                    
                    //Creating View Modal from Video Message
                    let videoMsgVMobj = VideoMessageViewModal(withMessage: msg)
                    if self.isGroup == true{
                        videoMsgVMobj.isGroup = self.isGroup
                        videoMsgVMobj.groupMembers = self.groupMembers
                        videoMsgVMobj.gpImage  = getProfilePic()
                        videoMsgVMobj.groupName = self.getReceiverName()
                    }
                    cell.index = indexPath
                    cell.deleteDelegate = self

                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    cell.isReplying = self.isReplying
                    cell.replyMsg = self.replyingMessage
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell.chatDocID = self.chatDocID
                    cell.msgVMObj = videoMsgVMobj
                    //Uploading video by using Video View Modal. And checking that video is not uploaded already.
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! VideoSentCollectionViewCell
                    cell.videoTappedDelegate = self
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                } else {
                    var cell : VideoReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "VideoReceivedCollectionViewCell", for: indexPath) as! VideoReceivedCollectionViewCell
                    let videoMsgVMobj = VideoMessageViewModal(withMessage: msg)
                    cell.index = indexPath
                    cell.deleteDelegate = self

                     cell.chatDocID = self.chatDocID
                    cell.msgVMObj = videoMsgVMobj
                    var imageUrl: String?
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: videoMsgVMobj.message.messangerName ?? "P")
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! VideoReceivedCollectionViewCell
                    cell.videoTappedDelegate = self
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .sticker:
                if msg.isSelfMessage {
                    var cell : StickerSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "StickerSentCollectionViewCell", for: indexPath) as! StickerSentCollectionViewCell
                    
                    //Creating View Modal from Image Message
                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.isReplying = self.isReplying
                    cell.index = indexPath
                    cell.deleteDelegate = self

                    cell.replyMsg = self.replyingMessage
                    cell.chatDocID = self.chatDocID
                    cell.msgVMObj = imageMsgVMobj
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    cell.stickerCollectionViewCellDelegate = self
                    //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! StickerSentCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                } else {
                    var cell : StickerReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "StickerReceivedCollectionViewCell", for: indexPath) as! StickerReceivedCollectionViewCell
                    cell.index = indexPath
                    cell.deleteDelegate = self

                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.chatDocID = self.chatDocID
                    cell.msgVMObj = imageMsgVMobj
                    var imageUrl: String?
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: imageMsgVMobj.message.messangerName ?? "P")
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    cell.stickerCollectionViewCellDelegate = self
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! StickerReceivedCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .gif:
                if msg.isSelfMessage {
                    var cell : ImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageSentCollectionViewCell", for: indexPath) as! ImageSentCollectionViewCell
                    
                    //Creating View Modal from Image Message
                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                    if self.isGroup == true{
                        imageMsgVMobj.isGroup = self.isGroup
                        imageMsgVMobj.groupMembers = self.groupMembers
                        imageMsgVMobj.gpImage  = getProfilePic()
                    }
                    cell.index = indexPath
                    cell.imageDeleteDelegate = self
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.isReplying = self.isReplying
                    cell.replyMsg = self.replyingMessage
                    cell.chatDocID = self.chatDocID
                    cell.msgVMObj = imageMsgVMobj
                    cell.imageMsgType = messageMediaType
                    cell.imageTappedDelegate = self
                    //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! ImageSentCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                } else {
                    var cell : ImageReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageReceivedCollectionViewCell", for: indexPath) as! ImageReceivedCollectionViewCell
                    let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                    imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.chatDocID = self.chatDocID
                    cell.msgVMObj = imageMsgVMobj
                    cell.index = indexPath
                    cell.deleteDelegate = self

                    var imageUrl: String?
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: imageMsgVMobj.message.messangerName ?? "P")
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    cell.imageTappedDelegate = self
                    cell.imageMsgType = messageMediaType
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! ImageReceivedCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .document:
                if msg.isSelfMessage {
                    var cell : DocumentSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "DocumentSentCollectionViewCell", for: indexPath) as! DocumentSentCollectionViewCell
                    let docMVMObj = DocumentMessageViewModal(withMessage: msg)
                    cell.index = indexPath
                    cell.deleteDelegate = self

                    if self.isGroup == true{
                        docMVMObj.isGroup = self.isGroup
                        docMVMObj.groupMembers = self.groupMembers
                        docMVMObj.gpImage  = getProfilePic()
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    docMVMObj.isReplying = self.isReplying
                    docMVMObj.replyMsg = self.replyingMessage
                    cell.documentMVMObj = docMVMObj
                    docMVMObj.chatDocID = self.chatDocID
                    cell.documentMessageDelegate = self
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! DocumentSentCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                } else {
                    //2 case for !isSelf and Offer = 2, is Accepted
                    var cell : DocumentReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "DocumentReceivedCollectionViewCell", for: indexPath) as! DocumentReceivedCollectionViewCell
                    cell.index = indexPath
                    cell.deleteDelegate = self

                    let docMVMObj = DocumentMessageViewModal(withMessage: msg)
                    docMVMObj.isReplying = self.isReplying
                    docMVMObj.replyMsg = self.replyingMessage
                    cell.documentMVMObj = docMVMObj
                    docMVMObj.chatDocID = self.chatDocID
                    var imageUrl: String?
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    cell.documentMessageDelegate = self
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: messageVMObj.message.messangerName ?? "P")
                    }
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! DocumentReceivedCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .audio:
                //Creating View Modal from Image Message
                if msg.isSelfMessage {
                    var cell : AudioSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "AudioSentCollectionViewCell", for: indexPath) as! AudioSentCollectionViewCell
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell.index = indexPath
                    cell.deleteDelegate = self

                    cell.msgObj = msg
                    cell.audioPlayerDelegate = self
                    let audioMVMObj = AudioMessageViewModal(withMessage: msg)
                    if self.isGroup == true{
                        audioMVMObj.isGroup = self.isGroup
                        audioMVMObj.groupMembers = self.groupMembers
                        audioMVMObj.gpImage  = getProfilePic()
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    audioMVMObj.isReplying = self.isReplying
                    audioMVMObj.replyMsg = self.replyingMessage
                    audioMVMObj.chatDocID = self.chatDocID
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! AudioSentCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                } else {
                    var cell : AudioReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "AudioReceivedCollectionViewCell", for: indexPath) as! AudioReceivedCollectionViewCell
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell.audioPlayerDelegate = self
                    cell.index = indexPath
                    cell.deleteDelegate = self

                    cell.msgObj = msg
                    var imageUrl: String?
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: messageVMObj.message.messangerName ?? "P")
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! AudioReceivedCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .text:
 
                if  msg.gpMessageType != "" {
                    let cell: GpMessageTypeCell = super.collectionView?.dequeueReusableCell(withReuseIdentifier: "GpMessageTypeCell", for: indexPath) as! GpMessageTypeCell
                    
                 print("timer \(msg.dTime)")
                    ///*******
                    //Tag For secret Chat *******
                    if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
                        
                        if let messge = msg.messagePayload {
                            let dtime = Helper.timeInsecArr().firstIndex(of: msg.dTime) ?? 0
//                            cell.gpMessageTypeText.text = "\(Helper.getNameFormDatabase(num: messge)) set the destruct timer to  \(Helper.defaultTimerArr()[dtime])"
                            if dtime == 0 {
                                cell.gpMessageTypeText.text = " " + "Destruct timer set to".localized + "  \(Helper.defaultTimerArr()[dtime])"
                            }else{
                                cell.gpMessageTypeText.text = " " + "Destruct timer set to".localized + "  \(Helper.defaultTimerArr()[dtime])"
                            }
                            
                            
                            cell.backgroundColor = UIColor.clear
                            return cell
                        }
                    }else if msg.dTime == 0 {
                        if msg.gpMessageType == nil {
                            if let messge = msg.messagePayload {
                                let dtime = Helper.timeInsecArr().firstIndex(of: msg.dTime) ?? 0
                                cell.gpMessageTypeText.text = " " + "Destruct timer set to".localized + " off"
                                cell.backgroundColor = UIColor.clear
                                return cell
                            }
                        }
                     
                    }
                    
                    
                    
                    //Tag For Group Chat ****
                    
                    switch msg.gpMessageType! {
                    case "0" :
                        //Creat Group
                        if let message = msg.messagePayload{
                            let arr =  message.components(separatedBy: ",")
                            //                            let num = Helper.getNameFormDatabase(num: arr[0])
                            let num = Helper.getUserNameFromMemberList(num: arr[0], memberList: self.groupMembers)
                            cell.gpMessageTypeText.text =  "\(num) " + "created group".localized + " \(arr[1])"
                            cell.isUserInteractionEnabled = false
                        }
                    case "1":
                        
                        if let message = msg.messagePayload{
                            let arr =  message.components(separatedBy: ",")
                            //                            let num1 = Helper.getNameFormDatabase(num: arr[0])
                            let num1 = Helper.getUserNameFromMemberList(num: arr[0], memberList: self.groupMembers)
                            //                            let num2 = Helper.getNameFormDatabase(num: arr[1])
                            let num2 = Helper.getUserNameFromMemberList(num: arr[1], memberList: self.groupMembers)
                            cell.gpMessageTypeText.text =  "\(num1) " + "added".localized + " \(num2)"
                            cell.isUserInteractionEnabled = false
                        }
                    case "2":
                        if let message = msg.messagePayload{
                            let arr =  message.components(separatedBy: ",")
                            //                            let num1 = Helper.getNameFormDatabase(num: arr[0])
                            let num1 = Helper.getUserNameFromMemberList(num: arr[0], memberList: self.groupMembers)
                            //                            let num2 = Helper.getNameFormDatabase(num: arr[1])
                            let num2 = Helper.getUserNameFromMemberList(num: arr[1], memberList: self.groupMembers)
                            cell.gpMessageTypeText.text =  "\(num1) " + "removed".localized + " \(num2)"
                            cell.isUserInteractionEnabled = false
                        }
                    case "3":
                        if let message = msg.messagePayload{
                            let arr =  message.components(separatedBy: ",")
                            //                            let num1 = Helper.getNameFormDatabase(num: arr[0])
                            let num1 = Helper.getUserNameFromMemberList(num: arr[0], memberList: self.groupMembers)
                            //                            let num2 = Helper.getNameFormDatabase(num: arr[1])
                            let num2 = Helper.getUserNameFromMemberList(num: arr[1], memberList: self.groupMembers)
                            cell.gpMessageTypeText.text =  "\(num1) " + "made".localized + " \(num2) " + "group admin".localized + "."
                            cell.isUserInteractionEnabled = false
                        }
                    case "4" :
                        
                        if let message = msg.messagePayload{
                            let arr =  message.components(separatedBy: ",")
                            //                            let num = Helper.getNameFormDatabase(num: arr[0])
                            let num = Helper.getUserNameFromMemberList(num: arr[0], memberList: self.groupMembers)
                            cell.gpMessageTypeText.text =  "\(num) " + "changed the subject to".localized + " \(arr[1])"
                            cell.isUserInteractionEnabled = false
                        }
                    case "5":
                        
                        if let message = msg.messagePayload{
                            //                            let num = Helper.getNameFormDatabase(num: message)
                            let num = Helper.getUserNameFromMemberList(num: message, memberList: self.groupMembers)
                            cell.gpMessageTypeText.text =  "\(num) " + "changed this group's icon".localized
                            cell.isUserInteractionEnabled = false
                        }
                        
                    case "6":
                        
                        if let message = msg.messagePayload{
                            //                            let num = Helper.getNameFormDatabase(num: message)
                            let num = Helper.getUserNameFromMemberList(num: message, memberList: self.groupMembers)
                            cell.gpMessageTypeText.text =  "\(num) " + "left".localized
                            cell.isUserInteractionEnabled = false
                        }
                        
                    default:
                        print("dd")
                    }
                    
                    ///*******
                    cell.backgroundColor = UIColor.clear
                    return cell
                } else  if chatViewModelObj?.secretID != "" && msg.messagePayload == "" {
                     let cell: GpMessageTypeCell = super.collectionView?.dequeueReusableCell(withReuseIdentifier: "GpMessageTypeCell", for: indexPath) as! GpMessageTypeCell
                    //Tag For secret Chat *******
                    if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{

                        if let messge = msg.messagePayload {
                            let dtime = Helper.timeInsecArr().firstIndex(of: msg.dTime) ?? 0
                            cell.gpMessageTypeText.text = " " + "Destruct timer set to".localized + " off"

                            cell.backgroundColor = UIColor.clear
                            return cell
                        }
                    }
                }
                else {
                    
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    
                    
                    jsqcell.timeLabelOutlet?.attributedText = messageVMObj.setDateTime(isSelf: msg.isSelfMessage)
                    jsqcell.currentStatusOutlet?.attributedText = messageVMObj.setReadStatus()
                    
                    var userImage: String?
                    if self.senderId() == msg.senderId{
                        if jsqcell.avatarImageView != nil {
                            Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: jsqcell.avatarImageView!, fullName: Utility.getUserFullName() ?? "P")
                        }
                        jsqcell.textView?.textColor = UIColor.white
                    }else{
                        if jsqcell.avatarImageView != nil {
                            if self.isGroup{
                                Helper.addedUserImage(profilePic: Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers), imageView: jsqcell.avatarImageView!, fullName: msg.receiverIdentifier ?? "P")
                            }else{
                                Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: jsqcell.avatarImageView!, fullName: messageVMObj.message.messangerName ?? "P")
                            }
                        }
                        jsqcell.textView?.textColor = UIColor.black
                    }
                    
                    jsqcell.avatarImageView?.setImageOn(imageUrl: userImage, defaultImage: #imageLiteral(resourceName: "defaultImage"))
                    jsqcell.avatarImageView?.contentMode = .scaleAspectFill
                    jsqcell.avatarImageView?.makeCornerRadious(readious: 17.5)
                    //                    jsqcell.avatarImageView?.isHidden = false
                    
                    jsqcell.panGestureRecognizer?.delegate = self
                    return jsqcell
                }
                
            case .replied:
                if let repliedMsg = msg.repliedMessage {
                    if let messageMediaType =  repliedMsg.replyMessageType {
                        switch messageMediaType {
                        case .text:
                            if msg.isSelfMessage {
                                var cell : SentTextCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "SentTextCollectionViewCell", for: indexPath) as! SentTextCollectionViewCell
                                cell.msgObj = msg
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! SentTextCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                var cell : ReceivedTextCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "ReceivedTextCollectionViewCell", for: indexPath) as! ReceivedTextCollectionViewCell
                                cell.msgObj = msg
                                var imageUrl: String?
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: messageVMObj.message.messangerName ?? "P")
                                }
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! ReceivedTextCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                            
                        case .image:
                            if msg.isSelfMessage {
                                var cell : RepliedImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedImageSentCollectionViewCell", for: indexPath) as! RepliedImageSentCollectionViewCell
                                cell.index = indexPath
                                cell.deleteDelegate = self

                                //Creating View Modal from Image Message
                                let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                cell.isReplying = self.isReplying
                                cell.replyMsg = self.replyingMessage
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell.chatDocID = self.chatDocID
                                cell.msgVMObj = imageMsgVMobj
                                cell.imageMsgType = messageMediaType
                                cell.repliedButtonPressedDelegate = self
                                //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedImageSentCollectionViewCell
                                cell.imageTappedDelegate = self
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                var cell : RepliedImageReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedImageReceivedCollectionViewCell", for: indexPath) as! RepliedImageReceivedCollectionViewCell
                                let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                cell.chatDocID = self.chatDocID
                                cell.index = indexPath
                                cell.deleteDelegate = self

                                cell.msgVMObj = imageMsgVMobj
                                cell.imageMsgType = messageMediaType
                                var imageUrl: String?
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: imageMsgVMobj.message.messangerName ?? "P")
                                }
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! RepliedImageReceivedCollectionViewCell
                                cell.imageTappedDelegate = self
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                            
                        case .location:
                            if msg.isSelfMessage {
                                var cell : RepliedSentLocationCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedSentLocationCell", for: indexPath) as! RepliedSentLocationCell
                                cell.backgroundColor = UIColor.clear
                                cell.msgObj = msg
                                cell.index = indexPath
                                cell.deleteDelegate = self

                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                cell.locationDelegate = self
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedSentLocationCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                //2 case for !isSelf and Offer = 2, is Accepted
                                var cell : RepliedReceivedLocationCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedReceivedLocationCell", for: indexPath) as! RepliedReceivedLocationCell
                                cell.index = indexPath
                                cell.deleteDelegate = self

                                cell.backgroundColor = UIColor.clear
                                cell.msgObj = msg
                                var imageUrl: String?
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell.locationDelegate = self
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: messageVMObj.message.messangerName ?? "P")
                                }
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! RepliedReceivedLocationCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                            
                        case .contact:
                            if msg.isSelfMessage {
                                var cell : RepliedSentContactMessageCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedSentContactMessageCollectionViewCell", for: indexPath) as! RepliedSentContactMessageCollectionViewCell
                                let contactMVMObj = ContactMessageViewModal(withMessage: msg)
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell.msgObj = contactMVMObj
                                cell.index = indexPath
                                cell.deleteDelegate = self

                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                cell.contactMessageDelegates = self
                                cell.repliedButtonPressedDelegate = self
                                cell.msgObj.presentControllerDelegate = self
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedSentContactMessageCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                var cell : RepliedReceivedContactCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedReceivedContactCollectionViewCell", for: indexPath) as! RepliedReceivedContactCollectionViewCell
                                let contactMVMObj = ContactMessageViewModal(withMessage: msg)
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell.msgObj = contactMVMObj
                                cell.index = indexPath
                                cell.deleteDelegate = self

                                var imageUrl: String?
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: contactMVMObj.message.messangerName ?? "P")
                                }
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell.contactMessageDelegates = self
                                cell.repliedButtonPressedDelegate = self
                                cell.msgObj.presentControllerDelegate = self
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! RepliedReceivedContactCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                            
                        case .doodle:
                            if msg.isSelfMessage {
                                var cell : RepliedImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedImageSentCollectionViewCell", for: indexPath) as! RepliedImageSentCollectionViewCell
                                cell.index = indexPath
                                cell.deleteDelegate = self

                                //Creating View Modal from Image Message
                                let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                cell.isReplying = self.isReplying
                                cell.replyMsg = self.replyingMessage
                                cell.chatDocID = self.chatDocID
                                cell.msgVMObj = imageMsgVMobj
                                cell.imageMsgType = messageMediaType
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                cell.imageTappedDelegate = self
                                cell.repliedButtonPressedDelegate = self
                                //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedImageSentCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                var cell : RepliedImageReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedImageReceivedCollectionViewCell", for: indexPath) as! RepliedImageReceivedCollectionViewCell
                                let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                cell.index = indexPath
                                cell.deleteDelegate = self

                                imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                cell.chatDocID = self.chatDocID
                                cell.msgVMObj = imageMsgVMobj
                                var imageUrl: String?
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: imageMsgVMobj.message.messangerName ?? "P")
                                }
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell.imageTappedDelegate = self
                                cell.imageMsgType = messageMediaType
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! RepliedImageReceivedCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                            
                        case .video:
                            if msg.isSelfMessage {
                                var cell : RepliedVideoSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedVideoSentCollectionViewCell", for: indexPath) as! RepliedVideoSentCollectionViewCell
                                
                                //Creating View Modal from Video Message
                                let videoMsgVMobj = VideoMessageViewModal(withMessage: msg)
                                cell.isReplying = self.isReplying
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                cell.replyMsg = self.replyingMessage
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell.chatDocID = self.chatDocID
                                cell.msgVMObj = videoMsgVMobj
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                cell.repliedButtonPressedDelegate = self
                                //Uploading video by using Video View Modal. And checking that video is not uploaded already.
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedVideoSentCollectionViewCell
                                cell.videoTappedDelegate = self
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                var cell : RepliedVideoReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedVideoReceivedCollectionViewCell", for: indexPath) as! RepliedVideoReceivedCollectionViewCell
                                let videoMsgVMobj = VideoMessageViewModal(withMessage: msg)
                                cell.chatDocID = self.chatDocID
                                cell.msgVMObj = videoMsgVMobj
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                var imageUrl: String?
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: videoMsgVMobj.message.messangerName ?? "P")
                                }
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! RepliedVideoReceivedCollectionViewCell
                                cell.videoTappedDelegate = self
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                            
                        case .sticker:
                            if msg.isSelfMessage {
                                var cell : RepliedStickerSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedStickerSentCollectionViewCell", for: indexPath) as! RepliedStickerSentCollectionViewCell
                                
                                //Creating View Modal from Image Message
                                let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                cell.isReplying = self.isReplying
                                cell.replyMsg = self.replyingMessage
                                cell.chatDocID = self.chatDocID
                                cell.msgVMObj = imageMsgVMobj
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                cell.repliedButtonPressedDelegate = self
                                //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedStickerSentCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                var cell : RepliedStickerReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedStickerReceivedCollectionViewCell", for: indexPath) as! RepliedStickerReceivedCollectionViewCell
                                let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                cell.chatDocID = self.chatDocID
                                cell.msgVMObj = imageMsgVMobj
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                var imageUrl: String?
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: imageMsgVMobj.message.messangerName ?? "P")
                                }
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! RepliedStickerReceivedCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                            
                        case .gif:
                            if msg.isSelfMessage {
                                var cell : RepliedImageSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedImageSentCollectionViewCell", for: indexPath) as! RepliedImageSentCollectionViewCell
                                
                                //Creating View Modal from Image Message
                                let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                cell.isReplying = self.isReplying
                                cell.replyMsg = self.replyingMessage
                                cell.chatDocID = self.chatDocID
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                cell.msgVMObj = imageMsgVMobj
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                cell.imageTappedDelegate = self
                                cell.imageMsgType = messageMediaType
                                cell.repliedButtonPressedDelegate = self
                                //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedImageSentCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                var cell : RepliedImageReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedImageReceivedCollectionViewCell", for: indexPath) as! RepliedImageReceivedCollectionViewCell
                                let imageMsgVMobj = ImageMessageViewModal(withMessage: msg)
                                imageMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                                cell.chatDocID = self.chatDocID
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                cell.msgVMObj = imageMsgVMobj
                                cell.imageMsgType = messageMediaType
                                var imageUrl: String?
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: imageMsgVMobj.message.messangerName ?? "P")
                                }
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell.imageTappedDelegate = self
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! RepliedImageReceivedCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                            
                        case .document:
                            if msg.isSelfMessage {
                                var cell : RepliedDocumentSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedDocumentSentCollectionViewCell", for: indexPath) as! RepliedDocumentSentCollectionViewCell
                                let docMVMObj = DocumentMessageViewModal(withMessage: msg)
                                docMVMObj.isReplying = self.isReplying
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                docMVMObj.replyMsg = self.replyingMessage
                                cell.documentMVMObj = docMVMObj
                                docMVMObj.chatDocID = self.chatDocID
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                cell.documentMessageDelegate = self
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedDocumentSentCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                //2 case for !isSelf and Offer = 2, is Accepted
                                var cell : RepliedDocumentReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedDocumentReceivedCollectionViewCell", for: indexPath) as! RepliedDocumentReceivedCollectionViewCell
                                let docMVMObj = DocumentMessageViewModal(withMessage: msg)
                                cell.documentMVMObj = docMVMObj
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                docMVMObj.chatDocID = self.chatDocID
                                var imageUrl: String?
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: docMVMObj.message.messangerName ?? "P")
                                }
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell.documentMessageDelegate = self
                                cell.repliedButtonPressedDelegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! RepliedDocumentReceivedCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                            
                        case .audio:
                            //Creating View Modal from Image Message
                            if msg.isSelfMessage {
                                var cell : RepliedAudioSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedAudioSentCollectionViewCell", for: indexPath) as! RepliedAudioSentCollectionViewCell
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell.msgObj = msg
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                cell.audioPlayerDelegate = self
                                cell.repliedButtonPressedDelegate = self
                                let audioMVMObj = AudioMessageViewModal(withMessage: msg)
                                audioMVMObj.isReplying = self.isReplying
                                audioMVMObj.replyMsg = self.replyingMessage
                                audioMVMObj.chatDocID = self.chatDocID
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! RepliedAudioSentCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            } else {
                                var cell : RepliedAudioReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "RepliedAudioReceivedCollectionViewCell", for: indexPath) as! RepliedAudioReceivedCollectionViewCell
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell.audioPlayerDelegate = self
                                cell.repliedButtonPressedDelegate = self
                                cell.msgObj = msg
                                cell.index = indexPath
                                cell.deleteDelegate = self
                                var imageUrl: String?
                                
                                if self.isGroup{
                                    imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                                    Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                                }else{
                                    Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: messageVMObj.message.messangerName ?? "P")
                                }
                                cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                                cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! RepliedAudioReceivedCollectionViewCell
                                cell.panGestureRecognizer?.delegate = self
                                return cell
                            }
                        case .replied:
                            jsqcell.panGestureRecognizer?.delegate = self
                            return jsqcell
                            
                        case .deleted:
                            break
                        case .post:
                            break
                        case .transfer:
                            break
                         case .callMessage:
                                let cell : CallMessageTypeCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "CallMessageTypeCollectionViewCell", for: indexPath) as! CallMessageTypeCollectionViewCell
                                                  cell.delegate = self
                                let messageVMObj = MessageViewModal(withMessage: msg)
                                cell.isUserInteractionEnabled = false
                                let timestamp = messageVMObj.message.timeStamp!
                                let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: timestamp)
                                let date = DateExtension().lastMessageInHours(date: lastmsgDate)
                                cell.callImageView.image = #imageLiteral(resourceName: "incoming_call_icon")
                                let duration = timeString(time:  messageVMObj.message.callDuration!)
                                
                                   if msg.callType == 0 {
                                    cell.callMessageLabelOutlet.text = "Audio call at".localized + " \(date)," + "Duration".localized + " \(duration)"
                                   }else {
                                    cell.callMessageLabelOutlet.text = "Video call at".localized + " \(date)," + "Duration" + " \(duration)"
                                   }
                                   return cell
                                   case .missedCallMessage:
                                       let cell : CallMessageTypeCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "CallMessageTypeCollectionViewCell", for: indexPath) as! CallMessageTypeCollectionViewCell
                                       cell.delegate = self
                                       let messageVMObj = MessageViewModal(withMessage: msg)
                                       cell.isUserInteractionEnabled = false
                                       let timestamp = messageVMObj.message.timeStamp!
                                       let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: timestamp)
                                       let date = DateExtension().lastMessageInHours(date: lastmsgDate)
                                       cell.callImageView.image =  #imageLiteral(resourceName: "missed_call_icon")
                                       if msg.callType == 0 {
                                        cell.callMessageLabelOutlet.text = "Missed Audio call at".localized + " \(date)"
                                       }else {
                                        cell.callMessageLabelOutlet.text = "Missed video call at".localized + " \(date)"
                                       }
                                       return cell
                        }
                    }
                }
                jsqcell.panGestureRecognizer?.delegate = self
                return jsqcell
                
            case .deleted:
                if msg.isSelfMessage {
                    var cell : DeletedSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "DeletedSentCollectionViewCell", for: indexPath) as! DeletedSentCollectionViewCell
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! DeletedSentCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                } else {
                    var cell : DeletedReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "DeletedReceivedCollectionViewCell", for: indexPath) as! DeletedReceivedCollectionViewCell
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! DeletedReceivedCollectionViewCell
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
            case .post:
                if msg.isSelfMessage {
                    var cell : PostSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "PostSentCollectionViewCell", for: indexPath) as! PostSentCollectionViewCell
                    
                    //Creating View Modal from Post Message
                    let postMsgVMobj = PostMessageViewModel(withMessage: msg)
                    if self.isGroup == true{
                        postMsgVMobj.isGroup = self.isGroup
                        postMsgVMobj.groupMembers = self.groupMembers
                        postMsgVMobj.gpImage  = getProfilePic()
                    }
                    cell.index = indexPath
                    cell.deleteDelegate = self
                    postMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.isReplying = self.isReplying
                    cell.replyMsg = self.replyingMessage
                    cell.imageMsgType = messageMediaType
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell.chatDocID = self.chatDocID
                    cell.msgVMObj = postMsgVMobj
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    cell.panGestureRecognizer?.delegate = self
                    //Uploading image by using Image View Modal. And checking that image is not uploaded already.
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: true) as! PostSentCollectionViewCell
                    cell.postNameLabel.text = msg.postTitle
                    cell.postType = msg.postType
                    cell.postTappedDelegate = self
                    return cell
                } else {
                    var cell : PostReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "PostReceivedCollectionViewCell", for: indexPath) as! PostReceivedCollectionViewCell
                    let postMsgVMobj = PostMessageViewModel(withMessage: msg)
                    postMsgVMobj.msgType = "\(messageMediaType.rawValue)"
                    cell.chatDocID = self.chatDocID
                    cell.msgVMObj = postMsgVMobj
                    cell.index = indexPath
                    cell.deleteDelegate = self
                    cell.imageMsgType = messageMediaType
                    let messageVMObj = MessageViewModal(withMessage: msg)
                    cell = messageVMObj.addLastDateAndTime(toCell: cell, isSelf: false) as! PostReceivedCollectionViewCell
                    cell.postNameLabel.text = msg.postTitle
                    cell.postType = msg.postType
                    var imageUrl: String?
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: messageVMObj.message.messangerName ?? "P")
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    cell.postTappedDelegate = self
                    cell.panGestureRecognizer?.delegate = self
                    return cell
                }
                
            case .transfer:
                if msg.isSelfMessage {
                    let cell : TransferSentCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "TransferSentCollectionViewCell", for: indexPath) as! TransferSentCollectionViewCell
                    
                    //Creating View Modal from Post Message
                    let transferMsgVMobj = TransferMessageViewModel(withMessage: msg)
                    cell.msgObj = transferMsgVMobj
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    Helper.addedUserImage(profilePic: self.selfUserImageUrl, imageView: cell.senderImageView, fullName: Utility.getUserFullName() ?? "P")
                    cell.delegate = self
                    return cell
                } else {
                    let cell : TransferReceivedCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "TransferReceivedCollectionViewCell", for: indexPath) as! TransferReceivedCollectionViewCell
                    let transferMsgVMobj = TransferMessageViewModel(withMessage: msg)
                    cell.msgObj = transferMsgVMobj
                    var imageUrl: String?
                    if self.isGroup{
                        imageUrl = Helper.getUserImage(userNumber: msg.receiverIdentifier, memberList: self.groupMembers)
                        Helper.addedUserImage(profilePic: imageUrl, imageView: cell.senderImageView, fullName: msg.receiverIdentifier ?? "P")
                    }else{
                        Helper.addedUserImage(profilePic: self.getProfilePic(), imageView: cell.senderImageView, fullName: transferMsgVMobj.message.messangerName ?? "P")
                    }
                    cell.senderImageView.makeCornerRadious(readious: cell.senderImageView.frame.size.width / 2)
                    cell.delegate = self
                    return cell
                }
                
            case .callMessage:
            let cell : CallMessageTypeCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "CallMessageTypeCollectionViewCell", for: indexPath) as! CallMessageTypeCollectionViewCell
                           cell.delegate = self
                           let messageVMObj = MessageViewModal(withMessage: msg)
                           cell.isUserInteractionEnabled = false
                           let timestamp = messageVMObj.message.timeStamp!
                           let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: timestamp)
                           let date = DateExtension().lastMessageInHours(date: lastmsgDate)
            
            let duration  =  timeString(time:  messageVMObj.message.callDuration!/1000)
            cell.callImageView.image = #imageLiteral(resourceName: "incoming_call_icon")
            if msg.callType == 0 {
                cell.callMessageLabelOutlet.text = "Audio call at".localized + " \(date)," + "Duration".localized + " \(duration)"
            }else {
                cell.callMessageLabelOutlet.text = "Video call at".localized + " \(date)," + "Duration".localized + " \(duration)"
            }
            return cell
            case .missedCallMessage:
                let cell : CallMessageTypeCollectionViewCell =  super.collectionView?.dequeueReusableCell(withReuseIdentifier: "CallMessageTypeCollectionViewCell", for: indexPath) as! CallMessageTypeCollectionViewCell
                cell.delegate = self
                let messageVMObj = MessageViewModal(withMessage: msg)
                cell.isUserInteractionEnabled = false
                let timestamp = messageVMObj.message.timeStamp!
                let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: timestamp)
                let date = DateExtension().lastMessageInHours(date: lastmsgDate)
                
                cell.callImageView.image =  #imageLiteral(resourceName: "missed_call_icon")
                if msg.callType == 0 {
                    cell.callMessageLabelOutlet.text = "Missed audio call at".localized + " \(date)"
                }else {
                    cell.callMessageLabelOutlet.text = "Missed video call at".localized + " \(date)"
                }
                return cell
             }
        }
        jsqcell.panGestureRecognizer?.delegate = self
        return jsqcell
    }
    
    func timeString(time:TimeInterval) -> String {
         let minutes = Int(time) / 60 % 60
         let seconds = Int(time) % 60
         return String(format:"%02i:%02i", minutes, seconds)
     }
    
//    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let msg = self.messages[indexPath.item]
//        if let messageMediaType:MessageTypes = msg.messageType {
//            switch messageMediaType {
//            case .callMessage:
//                return CGSize(width: 20 , height: 20)
//            default :
//                break
//            }
//        }
//        return CGSize(width: self.collectionView?.frame.size.width ?? 100, height: self.collectionView?.frame.size.height ?? 100)
//    }
    
    /// To set Image on a image view
    ///
    /// - Parameters:
    ///   - imageUrl: Url of image to assign on an image view
    ///   - defaultImage: default image view to set on it
    func setImageOn(imageView: UIImageView, imageUrl: String?, defaultImage: UIImage){
        if let url = imageUrl {
            imageView.kf.setImage(with: URL(string: url), placeholder: defaultImage, options: nil, progressBlock: nil) { (result) in
                print(result)
            }
        }else{
            DispatchQueue.main.async{
                imageView.image = defaultImage
            }
        }
    }
    
    //MARK: To show timestamp above message
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = self.messages[indexPath.item]
        let messageVMObj = MessageViewModal(withMessage: message)
        if(indexPath.item == 0) {
            return messageVMObj.setDay()
        } else {
            let currentMessage = self.messages[indexPath.item]
            let previousMessage = self.messages[indexPath.item - 1]
            if DateExtension().compareDates(currentDate: currentMessage.date, previousDate: previousMessage.date) {
                return nil
            } else {
                return messageVMObj.setDay()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
           /*
            Bug Name :- add date on top of chat screen
            Fix Date :- 06/05/2021
            Fixed By :- Jayaram G
            Description Of Fix :- Getting message timestamp from message data , and converting to human time and assging to label
            */
           self.timeAndDataLabel.isHidden = false
           let msg = self.messages[indexPath.item]
           print("****************\(DateExtension().getDateString(fromTimeStamp: msg.timeStamp ?? ""))")
           let date = DateExtension().getDateString(fromTimeStamp: msg.timeStamp ?? "")
           let time = DateExtension().lastMessageInHours(date: DateExtension().getDateObj(fromTimeStamp: msg.timeStamp ?? ""))
           print("****************\(date)")
           timeAndDataLabel.text = "\(date),\(time)"
           
           /* Bug Name :  chat message over lapping date banner
            Fix Date : 10-May-2021
            Fixed By : Jayaram G
            Description Of Fix : Added timer to hide date banner after scrolling
            */
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
               UIView.animate(withDuration: 1.0) {
                   self.timeAndDataLabel.isHidden = true
               }
           }
       }
    
    
    
    
    //MARK: Image Messages Methods
    func getimageMessageObj(withimage image : UIImage, isSelf : Bool, thumbnailData: String?, withMediaType type: String) -> Message? {
        guard let msgData = self.getImageMessageParams(withImage: image, isSelf: isSelf, imageURL: nil, withMediaType: type, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage) else { return nil }
        //create image cache URL here.
        var timeStamp: String = ""
        if let ts = msgData["timestamp"] as? String {
            timeStamp = ts
        } else if let ts = msgData["timestamp"] as? String {
            timeStamp = ts
        } else if let ts = msgData["timestamp"] as? Int64 {
            timeStamp = "\(ts)"
        }
        
        //Storing image into cache with the name of the image.
        let imageName = "Do_Chat"+timeStamp+".jpg"
        if !ImageCache.default.imageCachedType(forKey: imageName).cached {
            ImageCache.default.store(image, forKey: imageName)
        }
        
        var mediaURL = imageName
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
        
        let message = Message(forData: msgData, withDocID: chatDocID!, andMessageobj: msgData, isSelfMessage: isSelf, mediaStates: .notUploaded, mediaURL: mediaURL, thumbnailData: thumbnailData, secretID: nil, receiverIdentifier: "", messageData: nil, isReplied: self.isReplying,gpMessageType:gpMessageType, dTime: timer, readTime: 0.0, deliveryTime: 0.0)
        return message
    }
    
    func getImageMessageParams(withImage image : UIImage, isSelf : Bool, imageURL : String?, withMediaType type: String, isReplying: Bool, replyingMsgObj: Message?) -> [String : Any]? {
        let timeStamp : String = "\(UInt64(floor(Date().timeIntervalSince1970 * 1000)))"
        var params = [String :Any]()
        let userDocVMObject = UsersDocumentViewModel(couchbase: couchbaseObj)
        guard let userData = userDocVMObject.getUserData() else { return nil }
        guard let imageData = self.createThumbnail(forImage: image) else { return nil }
        let imgData: NSData = NSData(data: (image).jpegData(compressionQuality: 1)!)
        let imageSize: Int = imgData.length
        if isSelf {
            params["from"] = userData["userID"] as Any
            params["to"] = self.receiverID! as Any
        } else {
            params["from"] = self.receiverID! as Any
            params["to"] = userData["userID"]! as Any
        }
        if let url = imageURL {
            params["payload"] = url as Any
        }
        params["toDocId"] = self.chatDocID! as Any
        params["timestamp"] = timeStamp as Any
        params["id"] = timeStamp as Any
        params["type"] = type as Any
        params["thumbnail"] = imageData
        params["dataSize"] = imageSize as Any
        params["userImage"] = userData["userImageUrl"]! as Any
        params["name"] = userData["publicName"]! as Any
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
    
    //MARK: Height of cell to show timestamp
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        //set height for group Msg Tag
        if isGroup {
            let msg = self.messages[indexPath.item]
            if  msg.gpMessageType != "" {
                return 0.0
            }
            
        }
        let msg = self.messages[indexPath.item]
                     switch  msg.messageType {
                     case .missedCallMessage:
                         return 0.0
                     default:
                         return 0.0
                     }
      
        
        
        if(indexPath.item == 0){
            return 20.0
        } else {
            let currentMessage = self.messages[indexPath.item]
            let previousMessage = self.messages[indexPath.item - 1]
            if DateExtension().compareDates(currentDate: currentMessage.date, previousDate: previousMessage.date) {
                return 0.0
            } else {
                return 20.0
            }
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        //set height for group Msg Tag
        if isGroup {
            let msg = self.messages[indexPath.item]
            if  msg.gpMessageType != "" {
                return 0.0
            }
        }
        
        let msg = self.messages[indexPath.item]
//              switch  msg.messageType {
//              case .missedCallMessage:
//                  return 0.0
//              default:
//                  return 0.0
//              }
        
        if isGroup == false { return 0.0}
//        let msg = self.messages[indexPath.item]
        if indexPath.item - 1 > 0 {
            let prevMsg = self.messages[indexPath.item - 1]
            if prevMsg.senderId == msg.senderId {
                return 0.0
            }
        }
        
        return 20.0
    }
    
    //MARK: Responding to collection view tap events
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        collectionView.collectionViewLayout.invalidateLayout()
        self.inputToolbar.contentView?.textView?.resignFirstResponder()
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                //                guard let mediaURL = mediaItem.fileURL else { return }
                //                let player = AVPlayer(url: mediaURL)
                //                let playerViewController = AVPlayerViewController()
                //                playerViewController.player = player
                //                self.present(playerViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat {
        return 2.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapCellAt indexPath: IndexPath, touchLocation: CGPoint) {
        self.inputToolbar.contentView?.textView?.resignFirstResponder()
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        
        if self.isuserBlock{
            let actionSheet = UIAlertController(title: nil, message: "Blocked contacts will no longer be able to call you or send you messages".localized + ".", preferredStyle: UIAlertController.Style.actionSheet)
            let unblockAction = UIAlertAction(title: "Unblock".localized, style: UIAlertAction.Style.default) { (action) in
                self.blockUserApicall(reciverID: self.receiverID, text: text)
            }
            let cancel = UIAlertAction(title: "Cancel".localized, style: UIAlertAction.Style.cancel, handler: nil)
            actionSheet.addAction(unblockAction)
            actionSheet.addAction(cancel)
            self.present(actionSheet, animated: true, completion: nil)
        }else{
            self.didSendTextMessage(text: text)
        }
//        if (self.inputToolbar.contentView?.textView?.text.count == 0 ) {
//            //send Voice here
//        } else {
//            //send text here
//            self.updateMessageUIAfterSendingMessage(withText:text, andType: "0", withData: nil)
//            if self.chatDocID != nil {
//                UserDefaults.standard.setValue("", forKey:self.chatDocID)
//            }
//        }
    }
    
    func didSendTextMessage(text: String){
        if text.isEmpty {
            Helper.showAlert(head: "Message", message: "Type something to send.")
        }else{
            if (self.inputToolbar.contentView?.textView?.text.count == 0 ) {
                //send Voice here
            } else {
                //send text here
                self.updateMessageUIAfterSendingMessage(withText:text, andType: "0", withData: nil)
                if self.chatDocID != nil {
                    UserDefaults.standard.setValue("", forKey:self.chatDocID)
                }
            }
        }
    }
    
    /// For updating the chat doc inside the contact.
    func updateChatDocIDIntoContactDB() {
        //        if isSecretChat {
        self.chatDocID = self.getChatDocID()
        if let userID = favoriteObj?.userID {
            favoriteViewModel.updateContactDoc(withUserID: userID, andChatDocId: self.chatDocID)
        } else if let userID = self.chatViewModelObj?.userID {
            favoriteViewModel.updateContactDoc(withUserID: userID, andChatDocId: self.chatDocID)
        }
        //        }
    }
    
    func updateMessageUIAfterSendingMessage(withText text: String, andType type: String, withData messageData: [String : Any]?) {
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        self.updateChatDocIDIntoContactDB()
        
        var isStar = 0
        if let isVerified = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.isVerifiedUserProfile) as? Bool{
            isStar = isVerified ? 1 : 0
        }
        
        guard var message = chatsDocVMObject.makeMessageForSendingBetweenServers(withText: text, andType: type, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage, senderID: self.senderId(), receiverId: self.receiverID, chatDocId: self.chatDocID,isStar: isStar) else { return }
        
        var timer = 0
        
        if isGroup {
            DispatchQueue.global().async {
                guard let groupMems = self.groupMembers else {return}
                message["userImage"] = self.getProfilePic()
                message["name"] = self.getReceiverName()
                
                for member in  groupMems {
                    if member["memberId"] as? String   == self.userID{} else {
                        guard   let reciverID = member["memberId"] as? String else {return}
                        self.mqttChatManager.sendGroupMessage(toChannel: "\(reciverID)", withMessage: message, withQsos: .atLeastOnce)
                    }
                }
                self.mqttChatManager.sendGroupMessageToServer(toChannel: self.receiverID, withMessage: message, withQsos: .atLeastOnce)
                
            }
        }else {
            
            if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
                message["secretId"] = chatViewModelObj?.secretID
                //var timer = 0
                if  let time = UserDefaults.standard.object(forKey:(chatViewModelObj?.secretID)!) as? Int{
                    timer = time
                }
//                if timer == -1 {
//                message["dTime"] = 0
//                }else {
                    message["dTime"] = timer
//                }
                
                mqttChatManager.sendMessage(toChannel: "\(self.receiverID!)", withMessage: message, withQOS: .atLeastOnce)
            }else {
                mqttChatManager.sendMessage(toChannel: "\(self.receiverID!)", withMessage: message, withQOS: .atLeastOnce)
            }
        }
        guard let MsgObjForDB = chatsDocVMObject.getMessageObject(fromData: message , withStatus: "0", isSelf: true, fileSize: 0, documentData: nil, isReplying: self.isReplying, replyingMsgObj: self.replyingMessage) else { return }
        var msgObj = MsgObjForDB
        guard let dateString = DateExtension().getDateString(fromDate: Date()) else { return }
        msgObj["sentDate"] = dateString as Any
        guard let chatDocID = self.chatDocID else { return }
        if let chatDta = couchbaseObj.getData(fromDocID: chatDocID) {
            chatsDocVMObject.updateChatData(withData: chatDta, msgObject : msgObj as Any, inDocID  : chatDocID, isCreatingChat: false)
        }
        self.chatsDocVMObject.updateChatDoc(withMsgObj: msgObj, toDocID: chatDocID)
        let msgObject = Message(forData: msgObj, withDocID: chatDocID, andMessageobj: message, isSelfMessage: true, mediaStates: .notApplicable, mediaURL: nil, thumbnailData: nil, secretID: nil, receiverIdentifier: "", messageData: messageData, isReplied: self.isReplying,gpMessageType: "" ,dTime: timer, readTime: 0.0, deliveryTime: 0.0)
        messages.append(msgObject)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.finishSendingMessage(animated: true)
            let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
            let lastItemIndex = IndexPath.init(row: item, section: 0)
            self.collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionView.ScrollPosition.bottom, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.removeReplyView()
            }
        }
    }
    
    
    //MARK:- didPressAccessoryButton
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        self.inputToolbar.isHidden = true
        let sheet = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: chatActionSheet.camera.rawValue, style: .default) { (action : UIAlertAction) in
            self.openLivecamera()
        }
        
        let photolibAction = UIAlertAction(title: chatActionSheet.camerandVideo.rawValue.localized, style: .default) { (action : UIAlertAction) in
            
            let imagePicker = ImagePickerViewModel(self)
            imagePicker.openIphoneLibrery(complition: { imgArr in
                let story = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
                let preview =  story.instantiateViewController(withIdentifier: "ImagePickerPreview") as? ImagePickepreviewController
                preview?.imageArray = imgArr
                preview?.delegate = self
                preview?.isComingFromCamera = false
                preview?.modalPresentationStyle = .fullScreen
                imagePicker.pickerView?.present(preview!, animated: true, completion: nil)
            })
        }
        
        let giphyAction = UIAlertAction.init(title: chatActionSheet.giphy.rawValue.localized, style: .default) { action  in
            self.performSegue(withIdentifier: "chatTogifsegue", sender: true)
        }
        
        let stickerAction = UIAlertAction.init(title: chatActionSheet.sticker.rawValue.localized, style: .default) { action  in
            self.performSegue(withIdentifier: "chatTogifsegue", sender: false)
        }
        
        let doodleAction = UIAlertAction.init(title: chatActionSheet.doodle .rawValue.localized, style: .default) { action  in
            self.doodleViewModel = DoodleViewModel.init(self)
            self.doodleViewModel?.OpenDoodleView()
        }
        
        let document = UIAlertAction.init(title: chatActionSheet.document.rawValue.localized , style: .default) { action in
            self.documentViewModel = DocumentViewModel.init(self)
            self.documentViewModel?.delegate = self
            self.documentViewModel?.openDocumentView()
        }
        
        let locationAction = UIAlertAction(title: chatActionSheet.location.rawValue.localized, style: .default) { (action : UIAlertAction) in
            //            self.locationViewModel = LocationPickerViewModel.init(self)
            //            self.locationViewModel?.delegate = self
            //            self.locationViewModel?.openLocationPicker()
            let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
            let searchLocVc = storyboard.instantiateViewController(withIdentifier: "SearchLocationViewController") as! SearchLocationViewController
            searchLocVc.delegate = self;
            searchLocVc.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.pushViewController(searchLocVc, animated: true)
        }
        
        let contactAction = UIAlertAction(title: chatActionSheet.contact.rawValue.localized, style: .default) { (action : UIAlertAction) in
            self.contactModel = ContactchatViewModel(self)
            self.contactModel?.delegate = self
            self.contactModel?.openContectView()
        }
        
        let paymentAction = UIAlertAction(title: chatActionSheet.payment.rawValue.localized, style: .default) { (action) in
//            self.checkWalletRegistration()
            self.socialViewModel.getVerificationStatus { (success, error) in
                if success {
                    if self.socialViewModel.getStatus() == 1 {
                        self.validateOpponentUsersKYC()
                    } else {
                        Helper.showAlertViewOnWindow("", message: "Please complete your kyc to start sending payments".localized + ".")
                    }
                }else{
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        if !self.isGroup {
            if let isSecretChat = chatViewModelObj?.secretID , isSecretChat.count > 0 {
                //                return
            }else {
                sheet.addAction(paymentAction)
            }
        }
        sheet.addAction(photoAction)
        sheet.addAction(photolibAction)
        sheet.addAction(cancelAction)
        sheet.addAction(locationAction)
        sheet.addAction(contactAction)
        sheet.addAction(giphyAction)
//        sheet.addAction(doodleAction)
        sheet.addAction(stickerAction)
        sheet.addAction(document)
        
        self.present(sheet, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.inputToolbar.isHidden = false}
        }
        )
    }
    
    
    func validateOpponentUsersKYC() {
        DispatchQueue.main.async {
            Helper.showPI()
        }
        let url = AppConstants.memberProfile + "?memberId=\(self.getReceiverID() ?? "")"
            profileVM.isSelf = false
            
            profileVM.userDetailsService(strUrl: url, params: nil) { (success, error, serviceCall) in
                DispatchQueue.main.async {
                    Helper.hidePI()
                }
                if success {
                    if self.profileVM.userProfileModel?.kycStatus == true{
                        if #available(iOS 13.0, *) {
                            guard let transferToFriendVC = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil).instantiateViewController(identifier: String(describing: TransferToFriendViewController.self)) as? TransferToFriendViewController else {return}
                            transferToFriendVC.userModel = self.profileVM.userProfileModel
                            transferToFriendVC.isNotFromChatList = self.isNotFromChatList
                            self.navigationController?.pushViewController(transferToFriendVC, animated: true)
                        } else {
                            // Fallback on earlier versions
                        }
                    }else{
                        Helper.showAlertViewOnWindow("", message: "The receiver has to complete their kyc for you to send them money".localized + ".")
                    }
                }
                else if let error = error{
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
    }
    
    
    /// Open cameraView
    func openLivecamera() {
        if(!UIImagePickerController.isSourceTypeAvailable(.camera)){
            let alert = UIAlertController.init(title: "Message".localized, message: "Camera is not available in your device".localized, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "Ok".localized, style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image","public.movie"]
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension ChatViewController {
    @objc func receivedMessage(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: Any]
        
        if userInfo["isDelete"] != nil {
            if (userInfo["isDelete"] as? Bool == true) && (userInfo["docID"] as? String ==  self.chatDocID) , let megID = userInfo["messID"] as? String{
                self.deletePerticularMessageFromChat(messageID: megID)
            }
            return
        }else if let message = userInfo["message"] as? [String : Any]{
            if let gpMessageType = message["gpMessageType"] as? String, gpMessageType == "2"{
                DispatchQueue.main.async{
                    self.inputToolbar.contentView?.textView?.resignFirstResponder()
                }
                return
            }
        }
        
        
        let status = userInfo["status"] as! String
        guard let content = userInfo["message"] as? [String : Any] else { return }
        
        switch status {
        case "1","2", "3" :
            
            if let docID = content["doc_id"] as? String {
                if let chatdocId = self.chatDocID {
                    if docID == chatdocId {
                        self.chatsDocVMObject.updateStatusForChatMessages(withStatus: status, chatDocID: self.getChatDocID(), content: content)
                        self.updateChatStatus()
                    }
                }
            }
        default:
            self.updateCurrentChatMessages(withmessage: content)
        }
        self.updateChatDocIDIntoContactDB()
    }
    
    @objc func toolBarHideAndShow(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let isHide =  userInfo["hide"] as? Bool {
                if isHide {
                    /*
                     Bug Name:- Qwerty keypad overlaps when we minimize call>> goto chat>> open qwerty keypad>> maximize the call
                     Fix Date:- 29/06/21
                     Fix By  :- Jayaram G
                     Description of Fix:- Closing keyboard and added dispatch for resigning toolbar
                     */
                    self.inputToolbar.contentView?.textView?.resignFirstResponder()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        self.resignFirstResponder()
                    }
                }else {
                    self.becomeFirstResponder()
                }
            }
        }
    }
    
    
    @objc func receivedLastSeenStatus(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: Any]
        guard let message = userInfo["message"] as? [String : Any] else { return }
        if ((message["userId"] as? String) == self.receiverID) || ((message["_id"] as? String) == self.receiverID){
            if ((message["status"] as? Int) == 1) { // online
                self.currentChatStatusLabelOutlet.text = "Online".localized + "                                                      "
            } else if ((message["status"] as? Int) == 0) { //offline
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    if let lastSeen = message["lastSeenEnabled"] as? Bool, !lastSeen{
                        self.currentChatStatusLabelOutlet.text = "Offline".localized + "                                                      "
                        return
                    }
                    var tStamp = ""
                    if let timeStamp = message["timestamp"] as? String {
                        tStamp = timeStamp
                    } else if let timeStamp = message["timestamp"] as? Int {
                        tStamp = "\(timeStamp)"
                    }
                    guard let date = DateExtension().getDate(forLastSeenTimeString: tStamp) else { return }
                    let dateStr = DateExtension().lastSeenTime(date: date)
                    if dateStr.range(of:"Yesterday".localized) != nil {
                        let timeStampTime = "\(DateExtension().lastSeenTime(date: date))"
                        self.currentChatStatusLabelOutlet.text = "\(timeStampTime)                                                      "
                    } else {
                        let timeStampTime = "last seen".localized + " \(DateExtension().lastSeenTime(date: date))                                                      "
                        self.currentChatStatusLabelOutlet.text = "\(timeStampTime)                                                      "
                    }
                })
            }else{
                /*
                 Bug Name:- There is no offline text being displayed to any of the users in the chat.
                 Fix Date:- 29/07/21
                 Fix By  :- Jayaram G
                 Description of Fix:- Showing offline for different status
                 */
                self.currentChatStatusLabelOutlet.text = "Offline".localized + "                                                      "
            }
        }
    }
    
    @objc func receivedTypingStatus(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: Any]
        guard let message = userInfo["message"] as? [String : Any] else { return }
        if ((message["from"] as? String) == self.receiverID) {
            self.currentChatStatusLabelOutlet.text = "Typing".localized + "...                                                      "
            if !isTypingVisible {
                self.isTypingVisible = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.isTypingVisible = false
                    self.currentChatStatusLabelOutlet.text = "Online".localized + "                                                      "
                })
            }
        }
    }
    
    func didReceive(withMessage message: Any, inTopic topic: String) {
        guard let msgServerObj = message as? [String:Any] else { return }
        if let fromID = msgServerObj["from"] as? String {
            if fromID == selfID! {
            } else {
                self.messages = chatsDocVMObject.getMessagesFromChatDoc(withChatDocID: self.chatDocID)
                self.finishReceivingMessage()
            }
        }
    }
}

extension ChatViewController {
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        if self.chatDocID != nil {
            UserDefaults.standard.setValue(textView.text, forKey:self.chatDocID)
        }
        self.sendTypingStatus()
    }
}

extension ChatViewController {
    func updateCurrentChatMessages(withmessage message: [String : Any]) {
        self.chatsDocVMObject.updateMessageStatus(withMessageObj: message)
        guard let chatdocId = self.chatDocID else {return}
        self.messages = self.chatsDocVMObject.getMessagesFromChatDoc(withChatDocID: chatdocId)
        self.finishReceivingMessage()
        let state = UIApplication.shared.applicationState
        if state == .background {
            return
        }
        self.sendReadAcknowledgment(withMessage: message)
    }
    
    func sendReadAcknowledgment(withMessage message : [String : Any]) {
        
        if message["isSelf"] as? Bool == true {
            guard let isSelf = message["isSelf"] as? Bool else{return}
                if isSelf  == true {
            return
        }
        }
        
        //Start Timer if secret Chat start Timerrr for read message
        if chatViewModelObj?.secretID != "" && chatViewModelObj != nil{
            if let secretId = chatViewModelObj?.secretID as? String {
                if message["dTime"] != nil && secretId == chatViewModelObj?.secretID && chatViewModelObj != nil{
                    
                    guard var params = self.chatsDocVMObject.getMessageObjectForUpdatingStatus(withData: message, andStatus: "3", toDocID: self.chatDocID) as? [String:Any] else { return }
                    params["secretId"] = secretId
                    mqttChatManager.sendAcknowledgment(toChannel: "\(AppConstants.MQTT.acknowledgementTopicName)\(self.receiverID!)", withMessage: params, withQOS: .exactlyOnce)
                    
                    if  chatViewModelObj != nil  && (message["gpMessageType"] as? String == "" || message["gpMessageType"] == nil){
                        print("sendReadAcknowledgment \(message)")
                        var dTimee = 0
                        if let dTime = message["dTime"] as? Int {
                            dTimee = dTime
                        }
                        guard let messageID = message["id"] as? String  else {return}
                        self.chatsDocVMObject.secretChatTimer(docID:self.chatDocID , messageID: messageID, dTime:dTimee)
                    }
                }
            }
            
        }else {
            
            if let secretId = message["secretId"] as? String {
                if message["secretId"] != nil && message["dTime"] != nil && secretId == chatViewModelObj?.secretID && chatViewModelObj != nil{}
            }else {
                guard let params = self.chatsDocVMObject.getMessageObjectForUpdatingStatus(withData: message, andStatus: "3", toDocID: self.chatDocID) as? [String:Any] else { return }
                mqttChatManager.sendAcknowledgment(toChannel: "\(AppConstants.MQTT.acknowledgementTopicName)\(self.receiverID!)", withMessage: params, withQOS: .exactlyOnce)
                
            }
        }
        
    }
    
    func updateChatForReadMessage(toDocID docID : String,isControllerAppearing : Bool) {
        if var chatData = couchbaseObj.getData(fromDocID: docID) {
            if ((chatData["hasNewMessage"] as? Bool) == true) {
                // here we are sending the received acknowledgment for last message.
                if isControllerAppearing {
                    var timeStamp = Int64(floor(Date().timeIntervalSince1970 * 1000))
                    if let ts = self.messages.first?.messageId {
                        if let tStamp = Int64(ts) {
                            timeStamp = tStamp
                        }
                    }
                    self.chatViewModelObj?.getMessages(withTimeStamp: "\(timeStamp)", andPageSize: Constants.messagePageSize)
                    self.fetchLastMessageFromSenderAndSendAcknowledgment(withChatData: chatData)
                }
            }
            chatData["totalUnread"] = 0
            chatData["hasNewMessage"] = false
            chatData["newMessageCount"] = "0"
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            couchbaseObj.updateData(data: chatData, toDocID: docID)
        }
    }
    
    func fetchLastMessageFromSenderAndSendAcknowledgment(withChatData chatData: [String:Any]) {
        guard let msgArray = chatData["messageArray"] as? [[String:Any]] else {return}
        for (_, messageData) in msgArray.enumerated() {
            if ((messageData["timestamp"] as? String) == (chatData["lastMessageDate"] as? String)) {
                self.sendReadAcknowledgment(withMessage: messageData)
            } else if ((messageData["id"] as? String) == (chatData["lastMessageDate"] as? String)) {
                self.sendReadAcknowledgment(withMessage: messageData)
            } else if let tStamp = messageData["timestamp"] as? Int, let lMsgDate = chatData["lastMessageDate"] as? String {
                if tStamp == Int(lMsgDate) {
                    self.sendReadAcknowledgment(withMessage: messageData)
                }
            }
        }
    }
    
    func updateChatStatus() {
        
        //        let downloadQueue = OperationQueue()
        //        let operation : BlockOperation = BlockOperation(block: {
        //            self.messages = self.chatsDocVMObject.getMessagesFromChatDoc(withChatDocID: self.chatDocID)
        //
        //            OperationQueue.main.addOperation({
        //                self.finishReceivingMessage(animated: false)
        //            })
        //        })
        //        downloadQueue.addOperation(operation)
        
        self.messages = self.chatsDocVMObject.getMessagesFromChatDoc(withChatDocID: self.chatDocID)
        self.finishReceivingMessage(animated: false)
    }
}

extension Sequence where Iterator.Element: Hashable {
    func uniq() -> [Iterator.Element] {
        var seen = Set<Iterator.Element>()
        return filter { seen.update(with: $0) == nil }
    }
}

func == (lhs: Message, rhs: Message) -> Bool {
    guard let lhsTimeStamp = lhs.uniquemessageId, let rhsTimeStamp = rhs.uniquemessageId else { return false }
    return (lhsTimeStamp == rhsTimeStamp)
}


//MARK:-  Group Methods

extension ChatViewController {
    
    //Group releted Api call
    func getGroupInfoFromServer(_ groupID: String?) {
        guard let groupid = groupID else { return }
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.getAllmembersofGroup + "?chatId=\(groupid)"
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getAllgpMembers.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.getAllgpMembers.rawValue {
                    
                    guard let responseDict = dict["data"] as? [String:Any] else {return}
                    guard let ownNum = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.userName) as? String else {return}
                    
                    let memArr = responseDict["members"] as? [[String:Any]]
                    var gpmemArr = [[String:Any]]()
                    var sortedmemArr = [[String:Any]] ()
                    for i:[String:Any] in memArr! {
                        
                        var dict = [String:Any]()
                        dict["memberId"] = i["userId"] as? String ?? ""
                        dict["memberIdentifier"] = i["userIdentifier"] as? String ?? ""
                        dict["memberImage"] = i["profilePic"] as? String ?? ""
                        dict["memberStatus"] = i["socialStatus"] as? String ?? ""
                        dict["memberIsAdmin"] = i["isAdmin"] as? Bool
                        dict["userName"] = i["userName"] as? String ?? ""
                        if i["userIdentifier"] as? String == ownNum{
                            sortedmemArr.append(dict)
                        }else {
                            gpmemArr.append(dict)
                        }
                    }
                    
                    sortedmemArr.append(contentsOf: gpmemArr)
                    
                    let storedict = ["groupMembersArray": sortedmemArr ,
                                     "createdByMemberId": responseDict["createdByMemberId"] as? String ?? "" ,
                                     "createdByMemberIdentifier": responseDict["createdByMemberIdentifier"] as? String ?? "" ,
                                     "createdAt": String(describing: responseDict["createdAt"]!) ,
                                     "isActive":true as Bool
                        ] as [String:Any]
                    
                    
                    let groupDocID = Couchbase.sharedInstance.createDocument(withProperties: ["groupMembersDocId":storedict] as [String : Any])
                    
                    //Add groupId and groupDocID in GroupChatsDocument
                    self.updateGroupChatsDocument(groupID: groupid, groupDocId: groupDocID!)
                    /*
                     Bug Name:- group members list not showing first time after login
                     Fix Date:- 25/11/21
                     Fix By  :- Jayaram G
                     Description of Fix:- Showing group members list from api response
                     */
                    self.showGroupMembersOnNavigation(memArr: sortedmemArr)
                    let mainDoc = self.couchbaseObj.getDocumentObject(fromDocID:groupDocID!)
                    let gpData = mainDoc?.properties!
                    let gpInfoDict = gpData!["groupMembersDocId"] as! [String:Any]
                    self.groupInfo = gpInfoDict
                    self.groupDocumentID = groupDocID!
                    self.isActiveGroup = gpInfoDict["isActive"] as! Bool
                }
            }, onError: {error in
                Helper.hidePI()
            })
    }
    
    
    //Update groupId and groupDocId in GroupChatsDocument
    func updateGroupChatsDocument(groupID: String ,groupDocId:String){
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument)
        if  let document = Couchbase.sharedInstance.getDocumentObject(fromDocID: documentID as! String){
            let maindict = document.properties
            var dict = maindict!["GroupChatsDocument"] as! [String:Any]
            dict[groupID] = groupDocId
            do{
                try document.update { (newRev) -> Bool in
                    newRev["GroupChatsDocument"] = dict
                    return true
                }
            }
            catch let error {
                DDLogDebug("cdkvndkv\(error)")
            }
        } else {
            DDLogDebug("failed to get documet from provided DocID")
            return}
    }
    
    
    
    
    //Get groupDocument ID from Group DataBase
    func getgpDocIdfromgroupDatabase(groupID:String){
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument)
        if  let document = self.couchbaseObj.getDocumentObject(fromDocID: documentID as? String ?? ""){
            let maindict = document.properties
            var dict = maindict!["GroupChatsDocument"] as! [String:Any]
            if dict[groupID] != nil {
                print("docuemtID is there \(String(describing: dict[groupID]))")
                let mainDoc = self.couchbaseObj.getDocumentObject(fromDocID:dict[groupID] as! String)
                let gpData = mainDoc?.properties!
                let gpInfoDict = gpData!["groupMembersDocId"] as! [String:Any]
                groupInfo = gpInfoDict
                groupDocumentID = dict[groupID] as? String
                isActiveGroup = gpInfoDict["isActive"] as! Bool
                if let groupInfoArr  = groupInfo!["groupMembersArray"] as? [Any] {
                    let memArr = groupInfoArr.filter({ (members) -> Bool in
                        guard let _ = members as? [String :Any] else{return false}
                        return true
                    }) as! [[String : Any]]
                    showGroupMembersOnNavigation(memArr: memArr)
                }
//                showGroupMembersOnNavigation(memArr: groupInfo!["groupMembersArray"] as? [[String : Any]])
                
            }else {
                // if you dont found groupDocument with groupId then get it from API
                self.getGroupInfoFromServer(groupID)
            }
        }
    }
    
    
    //Show Group Members On Navigation
    func showGroupMembersOnNavigation(memArr:[[String:Any]]?){
        
        guard let  groupMemArr  = memArr else { return }
        self.groupMembers = groupMemArr
        self.currentChatStatusLabelOutlet.text = ""
        for  mem in groupMemArr {
//            guard let num =  mem["memberIdentifier"] as? String  else {return}
            /*
             Bug Name:- In a group chat, the user names are not being displayed on the top in the chat
             Fix Date:- 09/08/21
             Fix By  :- Jayaram G
             Description of Fix:- Handling memberIdentifier value
             */
            var name = ""
            if let memberName = mem["userName"] as? String , memberName != ""{
                name = memberName
            }else if let nameObj = mem["memberIdentifier"] as? String {
                name = nameObj
            }
            if self.currentChatStatusLabelOutlet.text?.count == 0 {
//                self.currentChatStatusLabelOutlet.text  = Helper.getNameFormDatabase(num: num)
                self.currentChatStatusLabelOutlet.text = name
            }else {
//                self.currentChatStatusLabelOutlet.text  =  self.currentChatStatusLabelOutlet.text! + "," + " " + Helper.getNameFormDatabase(num: num)
                self.currentChatStatusLabelOutlet.text  =  self.currentChatStatusLabelOutlet.text! + "," + " " + name
            }
        }
        self.currentChatStatusLabelOutlet.text = "\(self.currentChatStatusLabelOutlet.text!)                                                                                                                                                                                                    "
    }
    
    
    //Update groupINfo RealTime
    @objc func updateGroupInfo(notification:Notification){
        let mainDoc = self.couchbaseObj.getDocumentObject(fromDocID:self.groupDocumentID ?? "")
        guard let gpData = mainDoc?.properties as? [String:Any] else {return}
        guard let gpInfoDict = gpData["groupMembersDocId"] as? [String:Any] else {return}
        groupInfo = gpInfoDict
//        if let groupInfoArr  = groupInfo?["groupMembersArray"] as? [[String:Any]] {
//            self.currentChatStatusLabelOutlet.text = "                                                      "
//            showGroupMembersOnNavigation(memArr: groupInfoArr)
//        }
        if let groupInfoArr  = groupInfo!["groupMembersArray"] as? [Any] {
            let memArr = groupInfoArr.filter({ (members) -> Bool in
                guard let _ = members as? [String :Any] else{return false}
                return true
            }) as! [[String : Any]]
            self.currentChatStatusLabelOutlet.text = "                                                           "
            showGroupMembersOnNavigation(memArr: memArr)
        }
        if let isActive = groupInfo?["isActive"] as? Bool{
            isActiveGroup  = isActive
            if isActive == true {self.removeFooterView()}
            else {self.addFooterView()
                
            }
        }
    }
}




//MARK: - Secret Chat Methodss


extension ChatViewController {
    
    func updateStatusForSecretChat(withStatus status : String, chatDocID : String?) {
        guard let chatDocID = chatDocID else { return }
        guard let chatData = Couchbase.sharedInstance.getData(fromDocID: chatDocID) else { return }
        var chatDta = chatData
        var msgArray = chatDta["messageArray"] as! [[String:Any]]
        
        for (idx, dic) in msgArray.enumerated() {
            if ((dic["deliveryStatus"] as? String) != "3") && ((dic["isSelf"] as? Bool) == true) {
                var msgData = dic
                msgData["deliveryStatus"] = status
                msgArray[idx] = msgData
                
                //add secret Chat Timerrrrrr
                if ((dic["secretId"]  as? String) != "" ) && (status == "3") && ((dic["dTime"] as? Int) !=  0 ) {
                    
                    if let dTime = dic["dTime"] as? Int , let timeStamp = dic["timestamp"] as? String {
                        
                        let addTime:DispatchTimeInterval = .seconds(dTime)
                        let dispatchQue = DispatchQueue(label: timeStamp)
                        dispatchQue.asyncAfter(deadline: DispatchTime.now() + addTime , execute: {
                            print(" \(addTime) message Time = \(dispatchQue.label)")
                            DispatchQueue.main.async {
                                //self.deletePerticularMessage(messageID: dispatchQue.label)
                            }
                            
                            
                        })
                        
                    }
                    
                }
                
            }
        }
        chatDta["messageArray"] = msgArray
        Couchbase.sharedInstance.updateData(data: chatDta, toDocID: chatDocID)
    }
    
    
    
    
    func deletePerticularMessageFromChat(messageID : String){
        _ = self.messages.filter({
            
            if  $0.messageId == messageID {
                let index =  self.messages.index(of: $0)
                print("im in Chat Controller delete this   index \(String(describing: index))")
                DispatchQueue.main.async{
                    if self.messages.count > index! {
                        self.messages.remove(at: index!)
                    }
                    self.collectionView?.reloadData()
                }
            }
            return true
        })
    }
    
    
    func timerFinished(_ timer :Timer){
        
        guard let dict = timer.userInfo as? [String:String] else {return }
        
        
        // timer = nil
        print(" **********************************   finish timer called  hey my message ID \(String(describing: dict["timer"]) ?? "0") delete me ")
        
        
        //let msgArray = chatsDocVMObject.getMessages(withChatDocID : self.chatDocID)
        
        let mediaMessages = self.messages.filter({
            
            if  $0.timeStamp == dict["timer"]! {
                
                let index =  self.messages.index(of: $0)
                print("im in filter methode  delete this   index \(String(describing: index))")
                
                //if self.messages.count > 0{
                self.messages.remove(at: index!)
                self.chatsDocVMObject.removeMessageFromDatabaseWithIndexId(index: index!, docID: self.chatDocID)
                
                //self.finishReceivingMessage(animated: true)
                // self.finishSendingMessage()
                
                // self.collectionView?.collectionViewLayout.invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext)
                
                // [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
                
                //self.collectionView?.deleteItems(at: [IndexPath.init(row:  index!, section: 0)])
                DispatchQueue.main.async{
                    self.collectionView?.reloadData()
                }
                
                // }
                
                //                self.collectionView?.performBatchUpdates({
                //
                //                    if self.messages.count == 1 {
                //                        self.messages.remove(at: index!)
                //                        //self.chatsDocVMObject.removeMessageFromDatabaseWithIndexId(index: index!, docID: self.chatDocID)
                //
                //                            self.collectionView?.deleteItems(at: [IndexPath.init(row:  index!, section: 0)])
                //                            self.collectionView?.reloadData()
                //
                //                    }else {
                //
                //                         if self.messages.count > 0{
                //                           self.messages.remove(at: index!)
                //                         //self.chatsDocVMObject.removeMessageFromDatabaseWithIndexId(index: index!, docID: self.chatDocID)
                //                             print("im in performBatchUpdates methode......deleted from messageArr  and collectionView == index \(index)")
                //                         self.collectionView?.deleteItems(at: [IndexPath.init(row:  index!, section: 0)])
                //
                //                        }
                //                    }
                //                }, completion: { (finish) in
                //
                //
                //
                //                        if self.messages.count > 0{
                //                             print(" completion done reload Items called  **********************************  ")
                //                            self.collectionView?.reloadItems(at: (self.collectionView?.indexPathsForVisibleItems)!)
                //
                //                        }
                //
                //                })
                //
                
            }
            return true
        })
        
        
        
        //        var chatData = Couchbase.sharedInstance.getData(fromDocID: self.chatDocID)
        //        if var  msgArray = chatData!["messageArray"] as? [Any] {
        //
        //            msgArray.filter({
        //
        //                if $0.timeStamp == dict["timer"]! {
        //
        //
        //                }
        //
        //            })
        //
        //
        //        }
        
        //        if self.messages.count > 0 {
        //            print("timer init for indxPath \(indexPath.row)")
        //
        //            self.collectionView.performBatchUpdates({
        //
        //                print("delete done for indxPath \(indexPath.row)")
        //
        //                self.messages.remove(at:  indexPath.row)
        //               self.chatsDocVMObject.removeMessageFromDatabaseWithIndexId(index: indexPath.row, docID: self.chatDocID)
        //                self.collectionView?.deleteItems(at: [IndexPath.init(row:  indexPath.row, section: 0)])
        //                timer.invalidate()
        //
        //            }, completion: { (finish) in
        //                self.collectionView?.reloadItems(at: (self.collectionView?.indexPathsForVisibleItems)!)
        //            })
        //        }
        
    }
    
    
    
}

extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if self.window?.safeAreaLayoutGuide != nil {                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: (self.window?.safeAreaLayoutGuide.bottomAnchor)!, multiplier: 1.0).isActive = true
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}

extension UIView {
    var ParentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
