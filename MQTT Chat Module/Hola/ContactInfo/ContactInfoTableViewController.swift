//
//  ContactInfoTableViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 29/11/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import ParallaxHeader
import Kingfisher
import Locksmith
import ContactsUI
import Contacts
import Alamofire
class ContactInfoTableViewController: UITableViewController {
    weak var headerImageView: UIView?
    var headImgView:UIImageView?
    var othercellArr = ["Delete Chat".localized,"Block Contact".localized,"Report Spam".localized]
    var newContactArr : [String]?
    
    var userName: String?
    var userImage: String?
    var userRegisterNum : String?
    var userID : String?
    var userStatus: String?
    var chatDocID: String?
    var favoriteObj : Contacts?
    var chatVMObj : ChatViewModel?
    var isBlockUser =  false
    var chatsDocVMObject : ChatsDocumentViewModel?
    var isComingFromHistory = false
    var clearChatBlock:((Bool) -> ())?
    var blockUser:((Bool) -> ())?
    var chatIndexPath = IndexPath()
    let contactInfoTableViewModel = ContactInfoTableViewModel()
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userName == userRegisterNum {
            newContactArr = ["Create New Contact".localized,"View Profile".localized,"Last Seen".localized]
        }else {newContactArr = ["View Profile".localized,"Last Seen".localized] }
        
        self.navigationItem.title = "Contact Info".localized
        setupParallaxHeader()
        
        if  isComingFromHistory {
            isBlockUser = getIsUserBlock()
        }else {
            userStatus = getStatusFromDB(num: userRegisterNum)
        }
        
        self.imageRemoveForBlockUser()
    }
    
    
    private func getStatusFromDB(num: String?) -> String{
        guard let regiNum = num  else {return AppConstants.defaultStatus}
        let favArr  = Helper.getFavoriteDataFromDatabase1()
        let favmutable = favArr
//        let predicate = NSPredicate.init(format:"registerNum == %@", regiNum)
//        let fArr =  favmutable.filter({predicate.evaluate(with: $0)})
        let fArr = favmutable.filter { (contact) -> Bool in
            contact.registerNum == num
        }
        if fArr.count ==  0 {
            return AppConstants.defaultStatus
        }else{
            let contact = fArr[0]
            return contact.status!
        }
    }
    
    fileprivate func imageRemoveForBlockUser(){
        /*
         Bug Name:- characters not showing for example for vaibhav sharan, VS should show
         Fix Date:- 15/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Added initials image
         */
        if isBlockUser {
            if self.headImgView != nil {
                Helper.addedUserImage(profilePic: nil, imageView: self.headImgView!, fullName: self.userName ?? "P")
            }
            self.headerImageView = self.headImgView
        }else {
            if let userImageObj = userImage as? String {
                if self.headImgView != nil {
                    Helper.addedUserImage(profilePic: userImageObj, imageView: self.headImgView!, fullName: self.userName ?? "P")
                }
            }
            self.headerImageView = self.headImgView
        }
    }
    
    private func getIsUserBlock() -> Bool {
        if let chatViewModelObj = chatVMObj {
            return chatViewModelObj.isUserBlock
        }
        return false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
//        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.tabBarController?.tabBar.isHidden = false
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
    
    private func setupParallaxHeader() {
        
        headImgView = UIImageView()
        if headImgView != nil {
            Helper.addedUserImage(profilePic: userImage, imageView: headImgView!, fullName: self.userName ?? "P")
        }
        headImgView?.contentMode = .scaleAspectFill
        headerImageView = headImgView
        tableView.parallaxHeader.view = headImgView!
        tableView.parallaxHeader.height = 400
        tableView.parallaxHeader.minimumHeight = 0
        tableView.parallaxHeader.mode = .fill
        tableView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            
            //print("hello \(parallaxHeader)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ////Clear Chat
    func openClearChatActionsheet(){
        let actionSheet = Helper.initActionSheet(title: nil, message: "Delete messages".localized)
        let action1 = UIAlertAction.init(title: "Delete all messages".localized, style: .destructive, handler: {action in
            
            Helper.showPI()
//            self.chatsDocVMObject?.getMessages(withChatDocID: self.chatDocID)
            
            //call API for delete All Messages
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict["token"] as? String  else {return}
            
            let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
            let url = AppConstants.getMessages + "?" + "all=true&messageIds=\(self.userID!)"
           // let params: [String : Any] = ["all": true,
                       //   "messageIds": self.userID!]
            let apiCall = RxAlmofireClass()
            apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .delete, parameters:nil,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.deleteMessage.rawValue)
            apiCall.subject_response
                .subscribe(onNext: {dict in
                    guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                    if responseKey == AppConstants.resposeType.deleteMessage.rawValue{
                        let chatDocId = self.getChatDocumentID()
                        self.chatsDocVMObject?.clearMessagesInChatDoc(toDocID: chatDocId)
                        self.clearChatBlock?(true)
                        //go back after delete messages
                        DispatchQueue.main.async {
                            Helper.hidePI()
                            if self.isComingFromHistory == false {
                            self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }, onError: {error in
                    DispatchQueue.main.async {
                        Helper.hidePI()
                    }
                })
        })
        actionSheet.addAction(action1)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    //Report Spam
    func openReportSpamActionsheet(){
        let actionSheet = Helper.initActionSheet(title: nil, message: "Report spam this contact".localized + "?")
        let action1 = UIAlertAction.init(title: "Report Spam".localized, style: .destructive, handler: {action in
            
            self.getReportReasons()
        })
        actionSheet.addAction(action1)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    /// To get report reasones and showing popup view
    func getReportReasons(){
        contactInfoTableViewModel.getReportReasonsService { (success, error) in
            if success{
                DispatchQueue.main.async {
                    let reportView = ReportView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                    reportView.tag = 10
                    reportView.delegate  = self
                    reportView.reportReasonsArray = self.contactInfoTableViewModel.reportReasonArray
                    appDelegetConstant.window.addSubview(reportView)
                    reportView.popUpAnimation()
                }
            }else if let error = error{
                if error.code != 204{
                    DispatchQueue.main.async {
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    //block User
    func openBlockActionsheet(){
        let actionSheet = Helper.initActionSheet(title: nil, message: "Blocked contacts will no longer be able to call you or send you messages".localized + ".")
        let isBlockstr =  isBlockUser  ? "Unblock".localized : "Block".localized
        let action1 = UIAlertAction.init(title: isBlockstr, style: .destructive, handler: {action in
            self.blockUserApicall(reciverID: self.userID, strBlock:   self.isBlockUser  ? "unblock" : "block")
        })
        actionSheet.addAction(action1)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //last seen status change here
    fileprivate func openLastSeenActionsheet(){
        var lastStatus = true
        guard let selfID = Utility.getUserid() else { return }
        if (UserDefaults.standard.object(forKey:"\(selfID)+Last_Seen") as? Bool) != nil{
            lastStatus = false
        }
        
        let actionSheet = Helper.initActionSheet(title: nil, message: "Your Last Seen is".localized + " \(lastStatus ? "Enable".localized: "Disable".localized). " + "Do you want to".localized + " \(lastStatus ? "Disable".localized: "Enable".localized)?")
        let action1 = UIAlertAction.init(title: lastStatus ? "Disable".localized: "Enable".localized , style: .destructive, handler: {action in
            
            if lastStatus == true {
                UserDefaults.standard.set(!lastStatus, forKey: "\(selfID)+Last_Seen")
                MQTTChatManager.sharedInstance.sendOnlineStatus(withOfflineStatus: false , isLastSeenEnable: false)
            }else{
                UserDefaults.standard.removeObject(forKey: "\(selfID)+Last_Seen")
                MQTTChatManager.sharedInstance.sendOnlineStatus(withOfflineStatus: false , isLastSeenEnable: true)
            }
        })
        actionSheet.addAction(action1)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
}



//  ApiOnServer.BLOCK_USER + "/" + receiverUid + "/" + str

extension ContactInfoTableViewController {
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            return 70
        }else if indexPath.section == 2{
            return 50
        }  else{
            return 45
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 2
        }else if section == 3{
            return othercellArr.count
        }else if section == 1{
            return newContactArr!.count
        }else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactInfocell", for: indexPath) as! UserNameTableViewCell
            if indexPath.row == 0{
                cell.userContactNumber.isHidden = false
                cell.userName.isHidden = false
                cell.userName.isHidden = false
                cell.chatIconBtn.isHidden = false
                cell.callIconBtn.isHidden = false
                cell.videoIconBtn.isHidden = false
                cell.statusLbl.isHidden = true
                cell.setUpcontactInfo(regiNum: userRegisterNum!, userName: userName!, infoObj: self, userID: userID!, profilePic: userImage!, isBlock: isBlockUser)
            }else {
                cell.userContactNumber.isHidden = true
                cell.userName.isHidden = false
                cell.chatIconBtn.isHidden = true
                cell.callIconBtn.isHidden = true
                cell.videoIconBtn.isHidden = true
                cell.statusLbl.isHidden = false
                /*
                 Bug Name:- status should be bio here
                 Fix Date:- 21/04/21
                 Fix By  :- Jayaram G
                 Description of Fix:- Chaged status text to Bio
                 */
                cell.userName.text = "Bio".localized
                cell.statusLbl.text = userStatus
            }
            
            return cell}
        else if indexPath.section == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "newContactcell", for: indexPath)
            cell.textLabel?.text = newContactArr![indexPath.row] as String
            cell.accessoryType = .disclosureIndicator
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mediaCell", for: indexPath) as! MediaCellTableViewCell
            if let favObj = favoriteObj {
                cell.setUpmediaCell(index: indexPath, withChatDocId: favObj.chatDocID)
            } else if let chatVmObj = self.chatVMObj {
                cell.setUpmediaCell(index: indexPath, withChatDocId: chatVmObj.docID)
            }
            cell.setUpmediaCell(index: indexPath, withChatDocId: nil)
            cell.switchh.addTarget(self, action: #selector(muteNotificationAction(_:)), for: .valueChanged)
            
            if indexPath.row == 1 {
                cell.switchh.isHidden = false
                cell.accessoryType = .none
                cell.media_count.isHidden = true
                if (UserDefaults.standard.object(forKey:"\(self.userID!)+isMute") as? Bool) != nil{
                    cell.switchh.setOn(true, animated: true)
                }else {
                    cell.switchh.setOn(false, animated: true)
                }
            }else {
                cell.media_count.isHidden = false
                cell.switchh.isHidden = true
                cell.accessoryType =  .disclosureIndicator
            }
            return cell
            
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
            cell.textLabel?.text = othercellArr[indexPath.row] as String
            if isBlockUser {
                if indexPath.row == 1 {cell.textLabel?.text = "Unblock Contact".localized }
            }
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "goInfoTomedia", sender: self)
            }
        }else if indexPath.section == 3 {
            if indexPath.row == 0 {
//                self.openClearChatActionsheet()
                NotificationCenter.default.post(name: NSNotification.Name("DeleteChatNotification"), object: self.chatIndexPath)
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }else if indexPath.row == 1 {
                openBlockActionsheet()
            }else {
                openReportSpamActionsheet()
            }
        }else if indexPath.section == 1 {
            if newContactArr!.count == 3 {
                if indexPath.row == 0 {
                    let cnmutableContact = CNMutableContact.init()
                    cnmutableContact.givenName = ""
                    cnmutableContact.phoneNumbers = [CNLabeledValue.init(label: CNLabelHome, value:CNPhoneNumber.init(stringValue: userRegisterNum ?? "") )]
                    let contactView  = CNContactViewController.init(forNewContact:cnmutableContact)
                    contactView.delegate = self
                    let navigation = UINavigationController.init(rootViewController: contactView)
                    self.present(navigation, animated: true, completion: nil)
                }else if indexPath.row == 1{
//                    gotoConactDetailScreeen()
                    self.openProfile()
                }else {
                    //last seen clicked
                    openLastSeenActionsheet()
                }
            }else {
                if indexPath.row == 0{
//                    gotoConactDetailScreeen()
                    self.openProfile()
                }
                else {
                    //Last seen clicked
                    openLastSeenActionsheet()
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
    func gotoConactDetailScreeen() {
        let main = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
        if  let contctVC =  main.instantiateViewController(withIdentifier: "ContactDetailsTableViewController") as? ContactDetailsTableViewController{
            contctVC.userNUmber = userRegisterNum
            contctVC.userphType = "mobile"
            contctVC.userName = userName?.count == 0 ? userRegisterNum : userName
            contctVC.userID = userID
            contctVC.profilePic = userImage
            self.navigationController?.pushViewController(contctVC, animated: true)
        }
    }
    
    
    /// To open profile view
    func openProfile(){
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        guard let userId = self.userID else {return}
        profileVC.memberId = userId
        profileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "infoToChatView"{
            let controller = segue.destination as! ChatViewController
            
            if let favObj = favoriteObj {
                controller.favoriteObj = favObj
            } else if let chatVmObj = self.chatVMObj {
                controller.chatViewModelObj = chatVmObj
            }
            // controller.favoriteObj = favoriteObj
        }
        else if segue.identifier == "goInfoTomedia" {
            if let controller = segue.destination as? MediaHistoryViewController {
                if let favObj = favoriteObj {
                    controller.chatdocID = favObj.chatDocID
                } else if let chatVmObj = self.chatVMObj {
                    controller.chatdocID = chatVmObj.docID
                }
            }
        }
    }
}


//MARK - API calling Methods


extension ContactInfoTableViewController{
    
    
    func getChatDocumentID() -> String{
        
        var chatDocId = ""
        if let favObj = self.favoriteObj {
            chatDocId = favObj.chatDocID!
        } else if let chatVmObj = self.chatVMObj {
            chatDocId = chatVmObj.docID!
        }
        return chatDocId
    }
    
    
    //Block user
    func blockUserApicall(reciverID: String? ,strBlock : String){
        
        let chatDocId = getChatDocumentID()
        if chatDocId.count == 0 {return}
        guard let reciverid = reciverID else {return}
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.blockPersonAPI// + "?" + "opponentId=\(reciverid)" + "&" + "type=\(strBlock)"
        let params: [String : Any] = ["opponentId" : reciverid,
                                      "type" : strBlock
                                        ]
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
                    /*
                     Bug Name:- User able to send chat even blocked
                     Fix Date:- 23/06/21
                     Fix By  :- Jayaram G
                     Description of Fix:- Handling block status
                     */
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isUserBlockStatusChanged)
                    self.blockUser?(!self.isBlockUser)
                    self.isBlockUser = !self.isBlockUser
                    if let chatViewModelObj = self.chatVMObj {
                        chatViewModelObj.isUserBlock = self.isBlockUser
                    }
                    self.chatsDocVMObject?.updateUserBlockStatus(toDocID: chatDocId, isBlock:self.isBlockUser )
                    self.imageRemoveForBlockUser()
                    self.sendBlockOnmqtt(reciveID: reciverid)
                    self.tableView.reloadData()
                }
            }, onError: {error in
                
                Helper.hidePI()
            })
    }
    
    
    @objc func muteNotificationAction(_ ischage:UISwitch){
        if ischage.isOn{
            muteNotificationAPI(isOn: true)
        }else{
            muteNotificationAPI(isOn: false)
        }
    }
    
    
    func muteNotificationAPI(isOn:Bool){
        Helper.showPI(_message: "Loading".localized + "...")
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        
        guard let oppUserID = self.userID else {return}
        let params: [String : Any] = ["targetUserId":oppUserID,
                      "isMuteNotification":isOn
                    ]
        let url = AppConstants.muteNotificationAPI
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .post, parameters:params, headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.muteNotification.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.muteNotification.rawValue{
                    UserDefaults.standard.set(isOn, forKey:"\(self.userID!)+isMute")
                    if isOn == false{
                        UserDefaults.standard.removeObject(forKey:"\(self.userID!)+isMute")
                    }
                }
            }, onError: {error in
                Helper.hidePI()
            })
    }
    
    func  sendBlockOnmqtt(reciveID: String){
        
        guard let userID = Utility.getUserid() else {return}
        let mqttDict:[String:Any] = ["blocked":self.isBlockUser,
                                     "initiatorId":userID,
                                     "initiatorIdentifier": Utility.getUserName(),
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



//MARK:- CNContactViewControllerDelegate
extension ContactInfoTableViewController: CNContactViewControllerDelegate{
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?){
        if contact == nil{
        }else{
            APBook.sharedInstance.refreshContact()
            userName = contact?.givenName ?? userRegisterNum
        }
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK:- Report View delegate and posting selected report reason
extension ContactInfoTableViewController: ReportViewDelegate{
    
    func reportSelectedAtIndex(index: Int) {
        self.postReportReason(index: index)
    }
    
    func onDismissView(){
//        self.startVideoPlayer()
    }
    
    
    /// To post report with reason
    ///
    /// - Parameter index: selected report index
    func postReportReason(index: Int){
        Helper.showPI()
        guard let oppUserID = self.userID else {return}
        contactInfoTableViewModel.postReportReasonService(targetId: oppUserID, reasonIndex: index) { (success, error) in
            if success{
                DispatchQueue.main.async {
                    let reportView = appDelegetConstant.window.viewWithTag(10)
                    reportView?.popDownAnimation(animationDone: { (finished) in
                        self.showPopUpForSuccessResponse()
                    })
                }
            } else if let error = error{
                if error.code != 204{
                    DispatchQueue.main.async {
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    /// To show pop up and start playing video again
    func showPopUpForSuccessResponse(){
        let alert = UIAlertController(title: "Success".localized, message: Strings.ContactInfoStrings.reportSuccessMessage.localized, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok".localized, style: UIAlertAction.Style.default) { (action) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
