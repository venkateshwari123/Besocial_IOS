//
//  CallHistoryTableViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 15/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import RxAlamofire
import RxCocoa
import RxSwift
import CocoaLumberjack
import Kingfisher



class CallHistoryTableViewController: UIViewController {
    
    
    //IBOutlet
    @IBOutlet weak var defaultScreenView: UIView!
    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var defaultLbl: UILabel!
    
    @IBOutlet weak var callSegment: UISegmentedControl!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchShadowView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    var isSearchActive: Bool = false
    var callLogArr = [Any]()
    var searchArr = [Any]()
    var favArr = [Contacts]()
    var missedCalls = [Any]()
    
    let disposeBag = DisposeBag()
    var callHistoryViewModel : CallHistoryViewModel!
    var chatTabVC: ChatTabViewController?
    
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.refreshCallScreeen()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCallScreeen), name:NSNotification.Name(rawValue: AppConstants.refreshHistoryNotification), object: nil)
        self.userImageView.makeCornerRadious(readious: self.self.userImageView.frame.width / 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
        if let userImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImageForChats) as? String{
            self.userImageView.setImageOn(imageUrl: userImage, defaultImage:#imageLiteral(resourceName: "defaultImage"))
        }else{
            self.userImageView.image = #imageLiteral(resourceName: "defaultImage")
        }
        
    }
    
    
    
    func displayError(_ error: NSError?) {
        if let e = error {
            let alertController = UIAlertController(title: Strings.error.localized, message: e.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK".localized, style: .default) { (action) in
                // do nothing.....
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshCallScreeen()
        self.setViewUI()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCallScreeen), name:NSNotification.Name(rawValue: AppConstants.refreshHistoryNotification), object: nil)
        tableView.layoutIfNeeded()
        
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    /// To set the search UI
    func setViewUI(){
        self.searchContainerView.makeCornerRadious(readious: 5)
        if !Utility.isDarkModeEnable(){
            self.searchShadowView.makeShadowForSearchView()
        }
    }
    
    //    override func viewDidDisappear(_ animated: Bool) {
    //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(AppConstants.refreshHistoryNotification) , object: nil)
    //    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(AppConstants.refreshHistoryNotification) , object: nil)
    }
    
    @objc func refreshCallScreeen(){
        
        callHistoryViewModel = CallHistoryViewModel()
        self.favArr  = Helper.getFavoriteDataFromDatabase1()
        callHistoryViewModel.callArrObserval.subscribe(onNext: { (arr) in
            self.callLogArr = []
            if let arr1 = arr as? [Any]{
                self.callLogArr = arr1  //as! [Any]
            }
            
            if self.callLogArr.count == 0{
                self.showEmptyCallview()
            }
            else{
                self.hideEmptyCallview()
//                let predicate = NSPredicate.init(format:"callDuration == 0")
//                let filtetArr = self.callLogArr.filter({predicate.evaluate(with: $0)})
//                if filtetArr.count > 0{
//
//                    let predit = NSPredicate.init(format:"callInitiated == 0")
//                    let moreFilter = filtetArr.filter({predit.evaluate(with: $0)})
//                    if moreFilter.count > 0 {
//                        self.missedCalls = []
//                        self.missedCalls = moreFilter
//                    }
//                }
            }
            self.tableView.reloadData()
        }).addDisposableTo(disposeBag)
        callHistoryViewModel.getCallHistoryApi()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideEmptyCallview(){

        self.defaultScreenView.isHidden = true
        self.defaultImageView.isHidden = true
        self.defaultLbl.isHidden = true
    }
    
    func showEmptyCallview(){

        self.defaultScreenView.isHidden = false
        self.defaultImageView.isHidden = false
        self.defaultLbl.isHidden = false
    }
    
    
    //navigtion bar button ACTIONS
    
    
    @IBAction func callSegmentAction(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "callHistoryTouserdetails"{
            let contactINfo = segue.destination as? ContactInfoTableViewController
            let couchbaseObj = Couchbase.sharedInstance
            contactINfo?.isComingFromHistory = true
            contactINfo?.chatsDocVMObject = ChatsDocumentViewModel.init(couchbase: couchbaseObj)
            
            let data = sender as! [String:Any]
            guard  let  otherUserNum =  data["opponentNumber"] as? String else { return }
//            let predicate = NSPredicate.init(format:"registerNum == %@", otherUserNum)
//            let favAr =  favArr.filter({predicate.evaluate(with: $0)})
            let favAr = favArr.filter { (member) -> Bool in
                if let id = member.registerNum, id == otherUserNum{
                    return true
                }else{
                    return false
                }
            }
            if favAr.count ==  0 {
                contactINfo?.userRegisterNum = otherUserNum
                contactINfo?.userName   = otherUserNum
                if let userIMage = data["opponentProfilePic"] as? String {contactINfo?.userImage = userIMage}else{contactINfo?.userImage = ""}
                guard  let  otheruserID =  data["opponentUid"] as? String else { return }
                contactINfo?.userID = otheruserID
                contactINfo?.userStatus = AppConstants.defaultStatus
                if let chatDocID =  self.getChatdocIdforunsavedUser(reciverID:otheruserID ,receiverNumber: otherUserNum ){
                    guard let chatObj =  contactINfo?.chatsDocVMObject?.getChatObj(fromChatDocID: chatDocID) else { return }
                    contactINfo?.chatVMObj = ChatViewModel(withChatData: chatObj)
                }
                
            }else{
                let contact = favAr[0]
                if let registerNum = contact.registerNum {contactINfo?.userRegisterNum = registerNum}else {contactINfo?.userRegisterNum = ""}
                if let userName = contact.fullName {contactINfo?.userName = userName}else {contactINfo?.userName = ""}
                if let userImage = contact.profilePic {contactINfo?.userImage = userImage}else {contactINfo?.userImage = ""}
                if let userID = contact.userID {contactINfo?.userID = userID}else {contactINfo?.userID = ""}
                if let userStatus = contact.status {contactINfo?.userStatus = userStatus}else {contactINfo?.userStatus = AppConstants.defaultStatus}
                contactINfo?.favoriteObj = contact
                if let chatDocID = contact.chatDocID {
                    guard let chatObj =  contactINfo?.chatsDocVMObject?.getChatObj(fromChatDocID: chatDocID) else { return }
                    contactINfo?.chatVMObj = ChatViewModel(withChatData: chatObj)
                }
                //if let chatdocID = contact.chatDocID{contactINfo?.chatDocID = chatdocID} else {contactINfo?.chatDocID = "j"}
            }
            
            
        }
    }
    
    func getChatdocIdforunsavedUser(reciverID: String ,receiverNumber : String) -> String?{
        let individualChatDocVMObject = IndividualChatViewModel(couchbase: Couchbase.sharedInstance)
        guard let chatDocID = individualChatDocVMObject.getChatDocID(withreceiverID: reciverID, andSecretID: "", withContactObj: nil, messageData: nil, destructionTime: nil, isCreatingChat: false,recieverNumber: receiverNumber) else {
            DDLogDebug("error in creating chatdoc \(self)")
            return nil
        }
        return chatDocID
    }
    
}

extension CallHistoryTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if callSegment.selectedSegmentIndex == 0 {
        if self.isSearchActive{
            return self.searchArr.count
        }else{
            return self.callLogArr.count
        }
//        }else{
//            return self.missedCalls.count
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallHistoryTableViewCell", for: indexPath) as! CallHistoryTableViewCell
        
        // Configure the cell...
        var  dict : [String:Any]?
//        if callSegment.selectedSegmentIndex == 0{
        if self.isSearchActive{
            dict =  self.searchArr[indexPath.row] as? [String:Any]
        }else{
            dict =  self.callLogArr[indexPath.row] as? [String:Any]
        }
//        }
//        else{
//            dict =  (self.missedCalls[indexPath.row] as? [String:Any])
//        }
        cell.showdataIncallHistorycell(data: dict!, favDatabase: favArr, segmentIndex: 0)
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var  data : [String:Any]?
//        if callSegment.selectedSegmentIndex == 0{
        if self.isSearchActive{
            data =  self.searchArr[indexPath.row] as? [String:Any]
        }else{
            data =  self.callLogArr[indexPath.row] as? [String:Any]
        }
//        }else{
//            data = (self.missedCalls[indexPath.row] as? [String:Any])
//        }
        
        let callType = data!["callType"] as! String
        if callType == AppConstants.CallTypes.audioCall{
            self.startaudioCall(data: data!)
        }
        else{
            self.startvideoCall(data: data!)
        }
    }
    
//    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//
//        var  dict : [String:Any]?
////        if callSegment.selectedSegmentIndex == 0{
//            dict =  self.callLogArr[indexPath.row] as? [String:Any]
////        }else{
////            dict =  (self.missedCalls[indexPath.row] as? [String:Any])
////        }
////        self.performSegue(withIdentifier: "callHistoryTouserdetails", sender: dict)
//        self.chatTabVC?.performSegue(withIdentifier: "callHistoryTouserdetails", sender: dict)
//    }
    
    
    /// MARK:- startAudioCall
    func startaudioCall(data:[String:Any]){
        if Helper.checkCallGoingOn() == true{
            return
        }
        
        guard  let  otherUserNum =  data["opponentNumber"] as? String else { return }
//        let predicate = NSPredicate.init(format:"registerNum == %@", otherUserNum)
//        let favAr =  favArr.filter({predicate.evaluate(with: $0)})
        let favAr = favArr.filter { (member) -> Bool in
            if let id = member.registerNum, id == otherUserNum{
                return true
            }else{
                return false
            }
        }
        var dict: [String:Any]
        var userName:String = ""
        let registerNum = otherUserNum
        var userID = ""
        var profilePic = ""
        
        if favAr.count == 0 {
            userName = otherUserNum
            guard  let  otheruserID =  data["opponentUid"] as? String else { return }
            userID = otheruserID
            if let userIMage = data["opponentProfilePic"] as? String {profilePic = userIMage}else{profilePic = ""}
        }else {
            let favoriteObj = favAr[0]
            guard  let  otheruserID =  favoriteObj.userID else { return }
            userID = otheruserID
            if let userNaMe =  favoriteObj.fullName {userName  = userNaMe } else { userName = ""}
            if let userImg = favoriteObj.profilePic {profilePic = userImg}else{profilePic = ""}
        }
        
        guard let ownID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + ownID)
        UserDefaults.standard.set(true, forKey: "iscallBtnCliked")
        
        dict = ["callerId": userID,
                "callType" : AppConstants.CallTypes.audioCall,
                "registerNum": registerNum,
                "callId": randomString(length: 100),
                "callerIdentifier": ""] as [String:Any]
        
        UserDefaults.standard.set(dict, forKey: "storeIndexPath")
        MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.callsAvailability + userID , withDelivering: .atLeastOnce)
        
        let window = UIApplication.shared.keyWindow!
        window.endEditing(true)
        let audioView = AudioCallView(frame: CGRect(x:0, y:0, width: window.frame.width, height: window.frame.height))
        audioView.tag = 15
        audioView.userNameLbl.text = String(format:"%@",userName)
        audioView.callerID = userID
        audioView.setMessageData(messageData: dict)
        audioView.userImageView.kf.setImage(with: URL(string: profilePic), placeholder: #imageLiteral(resourceName: "defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
        })
        window.addSubview(audioView);
    }
    
    
    func startvideoCall(data:[String:Any]){
        
        if Helper.checkCallGoingOn() == true{
            return
        }
        
        guard  let  otherUserNum =  data["opponentNumber"] as? String else { return }
//        let predicate = NSPredicate.init(format:"registerNum == %@", otherUserNum)
//        let favAr =  favArr.filter({predicate.evaluate(with: $0)})
        let favAr = favArr.filter { (member) -> Bool in
            if let id = member.registerNum, id == otherUserNum{
                return true
            }else{
                return false
            }
        }
        var dict: [String:Any]
        var userName:String = ""
        let registerNum = otherUserNum
        var userID = ""
        var profilePic = ""
        
        if favAr.count == 0 {
            userName = otherUserNum
            guard  let  otheruserID =  data["opponentUid"] as? String else { return }
            userID = otheruserID
            if let userIMage = data["opponentProfilePic"] as? String {profilePic = userIMage}else{profilePic = ""}
        }else {
            let favoriteObj = favAr[0]
            guard  let  otheruserID =  favoriteObj.userID else { return }
            userID = otheruserID
            if let userNaMe =  favoriteObj.fullName {userName  = userNaMe } else { userName = ""}
            if let userImg = favoriteObj.profilePic {profilePic = userImg}else{profilePic = ""}
        }
        
        guard let ownID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + ownID)
        UserDefaults.standard.set(true, forKey: "iscallBtnCliked")
        
        dict = ["callerId": userID,
                "callType" : AppConstants.CallTypes.videoCall ,
                "registerNum": registerNum,
                "callId": randomString(length: 100),
                "callerIdentifier": ""] as [String:Any]
        
        UserDefaults.standard.set(dict, forKey: "storeIndexPath")
        MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.callsAvailability + userID , withDelivering: .atLeastOnce)
        
        //for VideoCall
        let window = UIApplication.shared.keyWindow!
        window.endEditing(true)
        let videoView = IncomingVideocallView(frame: CGRect(x: 0, y: 0 ,width : window.frame.width, height: window.frame.height))
        videoView.tag =  17
        videoView.setCallId()
        videoView.otherCallerId = userID
        videoView.calling_userName.text = String(format:"%@",userName)
        videoView.userImageView.kf.setImage(with: URL(string: profilePic), placeholder: #imageLiteral(resourceName: "defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
        })
        videoView.addCameraView()
        window.addSubview(videoView)
    }
    
}
