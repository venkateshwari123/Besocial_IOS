
//
//  GroupInfoTableViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 16/02/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import Locksmith
import MessageUI
import Alamofire

protocol ChatViewControllerDelegate {
    func updateGroupMemArray(groupmembers: [[String:Any]])
}

class GroupInfoTableViewController: UITableViewController {
    weak var headerImageView: UIView?
    var headImgView:UIImageView?
    var chatTitle = ["Export Chat".localized,"Clear Chat".localized]
    @IBOutlet weak var createdbyLbl: UILabel!
    @IBOutlet weak var createdAtlbl: UILabel!
    
    var groupInfo:[String:Any]?
    var groupImage:String?
    var groupName:String?
    var groupID:String?
    var groupmembers = [[String:Any]]()
    var isyouAdmin:Bool = false
    var isAdmin:Bool = false
    var groupDocumentID:String?
    var chatDocID:String?
     var chatVMObj : ChatViewModel?
    var indexPAth:IndexPath?
    var cameraBtn:UIButton?
    var isActiveGroup:Bool?
    let couchbaseObj = Couchbase.sharedInstance
    let mqttModel = MQTT.sharedInstance
    let createdAt:String = DateExtension().sendTimeStamp(fromDate: Date())!
    var chatsDocVMObject : ChatsDocumentViewModel?
    var gpNameBlock:((String) -> ())?
    var gpImageBlock:((String) -> ())?
    var gpActiveBlock:((Bool) -> ())?
    var gpMemeberBlock:(([[String:Any]]) -> ())?
    var clearChatBlock:((Bool) -> ())?
    var chatviewControllerDelegateObj:ChatViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
        setupParallaxHeader()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshScreen), name: NSNotification.Name(rawValue: "updateGroupInfoScreen"), object: nil)
        self.navigationItem.title = "Group Info".localized
        guard let info = groupInfo else {return}
        
        if let groupInfoArr  = info["groupMembersArray"] as? [Any] {
            self.groupmembers = groupInfoArr.filter({ (members) -> Bool in
                guard let _ = members as? [String :Any] else{return false}
                return true
            }) as! [[String : Any]]
        }
        self.setfooter()
        
        if let isActive = info["isActive"] as? Bool{
            isActiveGroup  = isActive
        }
        //CheckyouAdmin or not
        self.checkForAdmin()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc  func refreshScreen(_ : Notification){
        
        let mainDoc = self.couchbaseObj.getDocumentObject(fromDocID:self.groupDocumentID!)
        let gpData = mainDoc?.properties!
        let gpInfoDict = gpData!["groupMembersDocId"] as! [String:Any]
        groupInfo = gpInfoDict
        

        if let groupInfoArr  = groupInfo?["groupMembersArray"] as? [[String:Any]] {
            groupmembers = groupInfoArr
            gpMemeberBlock!(groupmembers)
        }
        
        if let isActive = groupInfo?["isActive"] as? Bool{
            isActiveGroup  = isActive
            gpActiveBlock!(isActiveGroup!)
        }
        
        //CheckyouAdmin or not
        self.checkForAdmin()
        
        self.tableView.reloadData()
    }

    
    func checkForAdmin(){
        if groupmembers.count > 0 {
            guard let userId = Utility.getUserid() else{return}
            let memArr = self.groupmembers.filter { (member) -> Bool in
                if let id = member["memberId"] as? String, id == userId{
                    return true
                }else{
                    return false
                }
            }
            if memArr.count > 0{
                let dict = memArr[0]
                if let isAdmin = dict["memberIsAdmin"] as? Bool{
                    self.isAdmin = isAdmin
                }
            }
        }
    }
    
    
    func setfooter(){
        if  let createdBymemNum = groupInfo!["createdByMemberIdentifier"] as? String {
//            let favDatabase:[Contacts] =  Helper.getFavoriteDataFromDatabase1()
//            let predicate = NSPredicate.init(format:"registerNum == %@", createdBymemNum)
//            let favArr =  favDatabase.filter({predicate.evaluate(with: $0)})
            let favArr = self.groupmembers.filter { (member) -> Bool in
                if let id = member["memberIdentifier"] as? String, id == createdBymemNum{
                    return true
                }else{
                    return false
                }
            }
            if favArr.count ==  0 {
                createdbyLbl.text = "Created by".localized + " \(createdBymemNum)"
            }else{
                let contact = favArr[0]
//                createdbyLbl.text = "Created by \(contact.fullName!)"
                createdbyLbl.text = "Created by".localized + " \(contact["userName"] as? String ?? "")"
            }
            
            guard let userID = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else {return}
            if createdBymemNum == userID {
                createdbyLbl.text = "Created by You".localized
            }
        }
        
        var tStamp = ""
        if let timeStamp = groupInfo!["createdAt"] as? String {
            tStamp = timeStamp
        }
        
        let lastmsgDate = DateExtension().getDate(forLastSeenTimeString: tStamp) ?? DateExtension().getDateObj(fromTimeStamp: tStamp)
        createdAtlbl.text = "Created".localized + " \(timeTodateconvert(date: lastmsgDate))"
    }
    
    
    func timeTodateconvert(date: Date)->String {
        let dateFormatter = DateFormatter()
        let today = NSCalendar.current.isDateInToday(date)
        if(today) {
            return "Today".localized
        }
        else if(NSCalendar.current.isDateInYesterday(date)){
            return "Yesterday".localized
        }
        else{
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
    }
    
    
    private func setupParallaxHeader() {
        headImgView = UIImageView()
        headImgView?.image = #imageLiteral(resourceName: "group_defaultImage")
        headImgView?.isUserInteractionEnabled = true
        if  groupImage != nil {
            headImgView?.kf.setImage(with: URL(string: groupImage!), placeholder: #imageLiteral(resourceName: "group_defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
        })
        }
        headImgView?.contentMode = .scaleAspectFill
        headerImageView = headImgView
        tableView.parallaxHeader.view = headImgView!
        tableView.parallaxHeader.height = 400
        tableView.parallaxHeader.minimumHeight = 0
        tableView.parallaxHeader.mode = .fill
        tableView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
        }
        
        if cameraBtn == nil {
            cameraBtn = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width - 60, y: 350, width:40, height: 40))
            cameraBtn?.setImage(#imageLiteral(resourceName: "group_info_camera_icon_off"), for: .normal)
//            cameraBtn?.setImage(#imageLiteral(resourceName: "group_info_camera_icon_on"), for: .highlighted)
            cameraBtn?.addTarget(self, action: #selector(cameraCliked(btn:)), for: .touchUpInside)
            tableView.parallaxHeader.view.addSubview(cameraBtn!)
        }
    }
    
    
    @objc func cameraCliked(btn:UIButton){
        
        if isActiveGroup == false {return}
        
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take Photo".localized, style: .default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose Photo".localized, style: .default, handler: { (action) in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:- Buttons Action
    
    @IBAction func backButtonAction(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 1:
            return 2
        case 2:
            return groupmembers.count
        case 3:
             return chatTitle.count
        default:
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 60
        }else{
            return 44
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 46
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 2 {
            
            let view = UIView.init(frame: CGRect.init(x:0, y: 0, width: self.view.frame.width, height: 40))
            
            if isActiveGroup == false {
                view.backgroundColor = UIColor.yellow
                let lbl  = UILabel.init(frame: CGRect.init(x: 5, y: 5, width: self.view.frame.size.width - 5, height:35))
                lbl.text = "you are no longer participant in this group".localized + "."
                lbl.adjustsFontSizeToFitWidth = true;
                lbl.minimumScaleFactor=0.7;
                view.addSubview(lbl)
                return view
            }
           
            if self.isAdmin == false {return nil}
            
            view.backgroundColor = .systemBackground
            let imagVie = UIImageView.init(frame: CGRect.init(x:10, y: 5, width:38, height: 38))
            imagVie.image = #imageLiteral(resourceName: "addMoreImg")
            imagVie.layer.cornerRadius = imagVie.frame.size.width/2
            imagVie.clipsToBounds = true
            view.addSubview(imagVie)
            
            let lbltext  = UILabel.init(frame: CGRect.init(x: imagVie.frame.origin.x + imagVie.frame.size.width + 10 , y: 5, width: self.view.frame.size.width, height: 35))
            lbltext.text = "Add Participants".localized
            view.addSubview(lbltext)
            
            let btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 46))
            btn.backgroundColor  = UIColor.clear
            btn.addTarget(self , action: #selector(addpartiCliked), for: .touchUpInside)
            view.addSubview(btn)
            return view
        }
        return nil
    }
    
    
    @objc func addpartiCliked(){
//        let favDatabase:[Contacts] =  Helper.getFavoriteDataFromDatabase1()
//        let story = UIStoryboard.init(name:AppConstants.StoryBoardIds.chat, bundle: nil)
//        let controller = story.instantiateViewController(withIdentifier: "SelectGroupMemNav") as! UINavigationController
//        let selectGpmem = controller.topViewController as! SelectGroupMemTableViewController
//        selectGpmem.allFavoriteList =  favDatabase
//        selectGpmem.selectedGPMemList = groupmembers
//        selectGpmem.isSelectOne = true
//        selectGpmem.delegate = self
//        self.present(controller, animated: true, completion: nil)
        
        let storyboard = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
        guard let favouritVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.FollowListViewController) as? FollowListViewController else {return}
//        favouritVC.isAddingInGroup = true
        favouritVC.controllerPurpose = .addInGroup
        favouritVC.groupMembers = groupmembers
        favouritVC.delegate = self
        self.navigationController?.pushViewController(favouritVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
            cell.textLabel?.text = self.groupName
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mediaCell", for: indexPath) as! MediaCellTableViewCell
            cell.setUpmediaCell(index: indexPath, withChatDocId: self.chatDocID)
            cell.switchh.addTarget(self, action: #selector(muteNotificationAction(_:)), for: .valueChanged)
            
            if indexPath.row == 1 {
                cell.switchh.isHidden = false
                cell.accessoryType = .none
                cell.media_count.isHidden = true
                if (UserDefaults.standard.object(forKey:"\(self.groupID!))+isMute") as? Bool) != nil{
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
        }else if indexPath.section == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "gpMembersCell", for: indexPath) as! gpmembersTableViewCell
            cell.gpImageView.layer.cornerRadius = cell.gpImageView.frame.width/2
            cell.gpImageView.clipsToBounds = true
            
            let dict = groupmembers[indexPath.row] as [String:Any]
            cell.setgroupMembersinfoIncell(info: dict)
            
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneTitleCell", for: indexPath)
            if indexPath.section == 3 {
                cell.textLabel?.text = chatTitle[indexPath.row]
                if indexPath.row == 0 { if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = UIColor.label
                } else {
                    cell.textLabel?.textColor = UIColor.black
                } }else {cell.textLabel?.textColor = UIColor.red}
            }else{
                
                cell.textLabel?.text =  self.isActiveGroup! ? "Exit Group".localized : "Delete Group".localized
                cell.textLabel?.textColor = UIColor.red
            }
            return cell
        }

    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        indexPAth = indexPath
        
        if indexPath.section == 0 {
            if isActiveGroup == false {return}
            self.performSegue(withIdentifier:"groupInfoToSubject", sender: self)
        }else if indexPath.section == 1{
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "gpInfoTomedia", sender: self)}
        }else if indexPath.section == 4 {
            
            //EXIT group API call HERE
             if isActiveGroup == nil {return}
            self.openExitGroupActionsheet()
        }else if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                //ExportChat
                self.openExportChatActionsheet()
            }else{//Clear Chat
                self.openClearChatActionsheet()
            }
        }else if indexPath.section == 2 {
             if isActiveGroup == false {return}
            if  self.checkifITSYou(info:groupmembers[indexPath.row]){return}
            
            if isAdmin {
            self.opengpMemberinofSheet(memberInfo:groupmembers[indexPath.row])
            }
        }
    }
    
}



extension GroupInfoTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "groupInfoToSubject" {
            let controller = segue.destination as? UINavigationController
            let editSub = controller?.viewControllers[0] as! EditSubjectTableViewController
            editSub.gpName = self.groupName
            editSub.delegate = self
            editSub.groupID = self.groupID
            
        }else if segue.identifier == "gpInfoTomedia" {
            if let controller = segue.destination as? MediaHistoryViewController {
                 if let chatVmObj = self.chatVMObj {
                    controller.chatdocID = chatVmObj.docID
                }
            }
        }
    }
    
}




//MARK: - All ActionSheet Collections
extension GroupInfoTableViewController{
    
    
    func initActionSheet(title:String? , message:String?) -> UIAlertController{
       let actionController = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        
        let action2 = UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: { (action) in
        })
        
        actionController.addAction(action2)
        self.present(actionController, animated: true, completion: nil)
        return actionController
    }
    
    
    //EXIT group API call HERE
    func openExitGroupActionsheet() {
       
        guard let name = self.groupName  else {return}
        let actionSheet = initActionSheet(title: nil, message: "Exit \(name)?")
        let action1 = UIAlertAction.init(title: self.isActiveGroup! ? "Exit Group".localized : "Delete Group".localized, style: .destructive, handler: { (action) in
            if let isActive = self.isActiveGroup, isActive == true{
                self.leaveGroupApiCall()
            }else{
                self.deleteGroupChat()
            }
        })
        
        actionSheet.addAction(action1)
    }
    
    
    ////Clear Chat
    func openClearChatActionsheet(){
        let actionSheet = initActionSheet(title: nil, message: "Delete messages".localized)
        let action1 = UIAlertAction.init(title: "Delete all messages".localized, style: .destructive, handler: {action in
            self.chatsDocVMObject?.clearMessagesInChatDoc(toDocID: self.chatDocID!)
            self.clearChatBlock?(true)
            self.navigationController?.popViewController(animated: true)
            
        })
        actionSheet.addAction(action1)
    }
    
    
    
    //Export Chat
    func openExportChatActionsheet(){
        
        let actionSheet = initActionSheet(title: nil, message: "Export Chat".localized)
        let action1 = UIAlertAction.init(title: "Without Media".localized, style: .default, handler: {action in
            if let chatId = self.chatDocID as? String {
                self.filterMessagesAndExportChat(chatDocID: chatId )
            }
        })
        actionSheet.addAction(action1)
        
    }
    
    
    func opengpMemberinofSheet(memberInfo:[String:Any]){
        
        let actionSheet = initActionSheet(title: nil, message: "Group member info".localized)
        let action1 = UIAlertAction.init(title: "Remove from Group".localized, style: .destructive, handler: {action in
            self.removeFromGroup(info: memberInfo)
        })
        
        var AdminTitle = ""
        var isAdmin:Bool = false
        if  (memberInfo["memberIsAdmin"] as? Bool)! {
            AdminTitle = "Remove From Admin".localized
            isAdmin = true
        }else {
            AdminTitle = "Make an Admin".localized
        }
        
        let action2 = UIAlertAction.init(title: AdminTitle, style: .default, handler: {action in
            self.makeMemberAnAdmin(isadmin:isAdmin ,memberInfo: memberInfo)
        })
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
    }
    
    
    
    func checkifITSYou(info:[String:Any]) -> Bool{
        //check for Own number heree
        if  let userNum  = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.userName) as? String{
            guard let num = info["memberIdentifier"] as? String else {return false}
            if userNum == num {
                return true
            }
        }
        return false
    }
    
}


//MARK: - All API Calls
extension GroupInfoTableViewController{
    
    func removeFromGroup(info:[String:Any]){
        
        Helper.showPI(_message: "Removing".localized + "...")
        let strURL = AppConstants.removeFromGroupByMember + "?chatId=\(self.groupID!)" + "&memberId=\(info["memberId"] as! String)"
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
         let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .delete, parameters: nil,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.removeFromGroupAPI.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.removeFromGroupAPI.rawValue {
                    guard let ownnum = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String  else {return}
                    let row = self.indexPAth?.row
                    let dict = self.groupmembers[row!]
                    self.sendRemoveMemeberSignalOnMqtt(dict: dict)
                    self.groupmembers.remove(at: row!)
                    self.updateGroupMembersArrInDataBase()
                    self.addGroupTostMsgOnchat(otherUserNum: "\(ownnum),\(dict["memberIdentifier"] as! String)", gpMessageType: "2")
                    self.gpMemeberBlock!(self.groupmembers)
                    self.tableView.reloadSections(IndexSet.init(integer: (self.indexPAth?.section)!) ,with: .automatic)
                }
            }, onError: {error in
                Helper.hidePI()
            })
        
    }
    
    
    func makeMemberAnAdmin(isadmin:Bool,memberInfo:[String:Any]){
        
        var admin = AppConstants.removeFromadmin
        if isadmin {admin = AppConstants.removeFromadmin
        }else {admin = AppConstants.makeAdmin}
        
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.makeAdminOfGropChat
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
         let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let params = ["type": admin,
                      "chatId": self.groupID!,
                      "memberId": memberInfo["memberId"] as! String
            ] as [String : Any]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .put, parameters:params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.makeAnAdminAPI.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.makeAnAdminAPI.rawValue {
                    
                    let row = self.indexPAth?.row
                    var dict = self.groupmembers[row!]
                    dict["memberIsAdmin"] = !isadmin
                    self.groupmembers[row!] = dict
                    self.updateGroupMembersArrInDataBase()
                    self.tableView.reloadRows(at: [self.indexPAth!], with: .automatic)
                    //send makeAdmin on MQTT
                    self.sendMakeAdminSignalOnMqtt(dict: dict)
                }
            }, onError: {error in
                Helper.hidePI()
            })
    }
    
    
    func leaveGroupApiCall(){
        
        
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.leaveGroupChat  + "?chatId=\(self.groupID!)"
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
         let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .delete, parameters:nil,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.leaveGroupAPI.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                guard let ownnum = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String  else {return}
                if responseKey == AppConstants.resposeType.leaveGroupAPI.rawValue {
                    if let code = dict["code"] as? Int, code == 403{
                        Helper.showAlertViewOnWindow(Strings.message.localized, message: dict["message"] as? String ?? "" )
                        return
                    }
                   
                    self.isActiveGroup  = false
                    self.addGroupTostMsgOnchat(otherUserNum:"\(ownnum)", gpMessageType: "6")
                    self.gpActiveBlock?(self.isActiveGroup!)
                    self.groupmembers.remove(at: 0)
                    self.updateisActiveGroupInDataBase()
                    self.tableView.reloadSections(IndexSet.init(integer: 2) ,with: .automatic)
                    self.tableView.reloadSections(IndexSet.init(integer: 4) ,with: .automatic)
                    self.chatviewControllerDelegateObj?.updateGroupMemArray(groupmembers: self.groupmembers)
                    self.sendLeaveGroupSignalOnMqtt()
                }
            }, onError: {error in
                
                Helper.hidePI()
            })
        
    }
    
    
    /// To delete group chat from servre and local database
    fileprivate func deleteGroupChat(){
//        Helper.showPI(_message: "Loading".localized + "...")
        self.chatVMObj?.deleteChatLocally()
        self.chatVMObj?.deleteChat(success: { (response) in
            DispatchQueue.main.async{
                Helper.hidePI()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }, failure: { (error) in
            DispatchQueue.main.async{
                Helper.hidePI()
                Helper.showAlertViewOnWindow("\(error.localizedTitle)".localized, message: "\(error.localizedDescription)")
            }
        })
    }
    
    func addOnegroupMember(memDit:Contacts){
        
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.addMemberToGroupChat
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let params = ["chatId":self.groupID!,
                      "members": [memDit.userID!]] as [String : Any]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters:params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.addGroupmemberAPI.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                guard let ownnum = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String  else {return}
                if responseKey == AppConstants.resposeType.addGroupmemberAPI.rawValue {
                    
                    let dict = ["memberId":memDit.userID! ,
                                "memberIdentifier":memDit.fullName! ,
                                "memberImage":memDit.profilePic as Any,
                                "memberIsAdmin":false,
                                "memberStatus":memDit.status ?? AppConstants.defaultStatus,
                                "userName": memDit.fullName!] as [String:Any]

                    self.groupmembers.append(dict)
                    self.updateGroupMembersArrInDataBase()
                    self.sendAddmemeberInGroupSignalOnMqtt(dict: dict)
                    self.addGroupTostMsgOnchat(otherUserNum: "\(ownnum),\(memDit.fullName!)", gpMessageType: "1")
                    self.gpMemeberBlock!(self.groupmembers)
                    self.tableView.reloadSections(IndexSet.init(integer: 2) ,with: .automatic)
                    
                }
            }, onError: {error in
                
                Helper.hidePI()
            })
    }
    
    
    
    @objc func muteNotificationAction(_ ischage:UISwitch){
        if ischage.isOn{
            muteNotificationAPI(isOn: false)
        }else{
            muteNotificationAPI(isOn: true)
        }
    }
    
    
    
    func muteNotificationAPI(isOn:Bool){
        Helper.showPI(_message: "Loading".localized + "...")
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let url = AppConstants.muteNotificationAPI
        let apiCall = RxAlmofireClass()
        guard let oppUserID = self.groupID else {return}
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .post, parameters:["targetUserId":oppUserID,"isMuteNotification":isOn],headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.muteNotification.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.muteNotification.rawValue{
                    //Show Alerttttt
                    UserDefaults.standard.set(!isOn, forKey:"\(self.groupID!)+isMute")
                    if !isOn == false{
                        UserDefaults.standard.removeObject(forKey:"\(self.groupID!)+isMute")
                    }
                }
            }, onError: {error in
                Helper.hidePI()
            })
    }
    
    
}




extension GroupInfoTableViewController:editSubjectdelegate{
    func nameChanged(groupName: String?) {
        self.groupName = groupName
        sendchangeGroupNameSignalOnMqtt(isImageChnage: false)
        self.tableView.reloadSections(IndexSet.init(integer: (self.indexPAth?.section)!) ,with: .automatic)
    }
}


extension GroupInfoTableViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func deletePhoto() {
    }
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePickerObj = UIImagePickerController()
            imagePickerObj.delegate = self
            imagePickerObj.sourceType = UIImagePickerController.SourceType.camera;
            imagePickerObj.allowsEditing = false
            self.present(imagePickerObj, animated: true, completion: nil)
        }
        else {
            self.showAlert("Alert".localized, message: "Your device doesn't support Camera".localized + ". " + "Please choose".localized + " " + "other option".localized + ".")
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePickerObj = UIImagePickerController()
            imagePickerObj.delegate  = self  as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerObj.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imagePickerObj.allowsEditing = false
            self.present(imagePickerObj, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard var image = info[.originalImage] as? UIImage else {
            return
        }
        if picker.sourceType == UIImagePickerController.SourceType.camera && picker.cameraDevice == UIImagePickerController.CameraDevice.front{
            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation:.leftMirrored)
        }
        //        let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation:.leftMirrored)
        headImgView?.image = image
        headerImageView = headImgView
        Helper.showPI(_message: "Uploading".localized + "...")
        self.uploadPhotoToAPI(withImage: image)
        self.dismiss(animated: true, completion: nil)
    }
    
    
//    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
//        var flippedImage: UIImage = image
//        if picker.sourceType == UIImagePickerController.SourceType.camera && picker.cameraDevice == UIImagePickerController.CameraDevice.front{
//            flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation:.leftMirrored)
//        }
////        let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation:.leftMirrored)
//        headImgView?.image = flippedImage
//        headerImageView = headImgView
//        Helper.showPI(_message: "Uploading...")
//        self.uploadPhotoToAPI(withImage: image)
//        self.dismiss(animated: true, completion: nil)
//    }
//
    
    func uploadPhotoToAPI(withImage image: UIImage) {
        let name  = arc4random_uniform(900000) + 100000;
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        AFWrapper.updloadPhoto(withPhoto: image, andName: "\(name)\(timeStamp)", progress: {
            (progres) in
        }, success: { (response) in
            Helper.hidePI()
            let fileName = "\(name)\(timeStamp).jpeg"
            let url = AppConstants.uploadImageURLExtension + "/" + "\(fileName)"
            self.groupImage = url
            self.sendchangeGroupNameSignalOnMqtt(isImageChnage: true)
            //GroupImage URL Heree get
        }, failure: { (error) in
            Helper.hidePI()
        })
    }
    
}


extension GroupInfoTableViewController:selectGpdelegate{
    
    func groupMemeberselected(member: Contacts) {
        addOnegroupMember(memDit: member)
    }
}

extension GroupInfoTableViewController: FollowListViewControllerDelegate{
    func selecteGroupMember(contact: Contacts){
        addOnegroupMember(memDit: contact)
    }
}


//MARK: - Update in Database
extension GroupInfoTableViewController{
    
    
    func updateGroupMembersArrInDataBase(){
        var tempDict = self.groupInfo!
        tempDict["groupMembersArray"] = self.groupmembers
        self.groupInfo = tempDict
        updategroupMembersDocument(documentID: self.groupDocumentID!, newData: self.groupInfo!)
    }
    
    
    func updateisActiveGroupInDataBase(){
        var tempDict = self.groupInfo!
        tempDict["isActive"] = false
        tempDict["groupMembersArray"] = self.groupmembers
        self.groupInfo = tempDict
        updategroupMembersDocument(documentID: self.groupDocumentID!, newData: self.groupInfo!)
    }
    
    
    func updategroupMembersDocument(documentID:String,newData:[String:Any]){
        if let document = self.couchbaseObj.getDocumentObject(fromDocID: documentID){
            do{
                try document.update{ (newRev) -> Bool in
                    newRev["groupMembersDocId"] = newData
                    return true
                }
            } catch let error {
                print("cdkvndkv\(error)")
            }
        }else {
            print("failed to get documet from provided DocID")
            return}
    }
}

//MARK: - send On MQTT

extension GroupInfoTableViewController{
    
    //make/remove form Admin MQTT Data
    func sendMakeAdminSignalOnMqtt(dict:[String:Any]){
        guard let userID = Utility.getUserid() else {return}
        guard let num = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else {return}
        ///To inform the members of the group creation
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        
        
        let mqttDict:[String:Any] = ["initiatorId":userID,
                                     "initiatorIdentifier":num,
                                     "groupId":self.groupID!,
                                     "memberId":dict["memberId"] as! String,
                                     "type": 3,
                                     "memberIdentifier":dict["memberIdentifier"] as! String,
                                     "id":"\(timeStamp)" as Any,
                                     "timestamp":"\(String(describing: createdAt))" as Any
        ]
        
        for i in groupmembers{
            //dont send data to self
            if i["memberId"] as! String  == userID {}else {
            let groupChannel = "\(AppConstants.MQTT.groupChats)\(i["memberId"] as! String)"
            do {
                let jsonData = try JSONSerialization.data(withJSONObject:mqttDict , options: .prettyPrinted)
                self.mqttModel.publishData(wthData: jsonData, onTopic: groupChannel, retain: false, withDelivering:  .atLeastOnce)
            }catch  {
                print("\(error.localizedDescription)")
            }
            }
        }
        
    }
    
    
    func sendLeaveGroupSignalOnMqtt(){
        
        guard let userID = Utility.getUserid() else {return}
        guard let num = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else {return}
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
       
        
        let mqttDict:[String:Any] = ["initiatorId":userID,
                                     "initiatorIdentifier":num,
                                     "groupId":self.groupID!,
                                     "type":6,
                                     "id":"\(timeStamp)" as Any,
                                     "timestamp":"\(createdAt)" as Any
        ]
        
        
        for i in groupmembers{
            //dont send data to self
            if i["memberId"] as! String  == userID {}else {
                let groupChannel = "\(AppConstants.MQTT.groupChats)\(i["memberId"] as! String)"
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject:mqttDict , options: .prettyPrinted)
                    self.mqttModel.publishData(wthData: jsonData, onTopic: groupChannel, retain: false, withDelivering:  .atLeastOnce)
                }catch  {
                    print("\(error.localizedDescription)")
                }
            }
        }
        
    }
    
    
    
    func sendchangeGroupNameSignalOnMqtt(isImageChnage:Bool){
       
        guard let userID = Utility.getUserid() else {return}
        guard let num = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else {return}
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        
        
        
        
        var mqttDict:[String:Any]?
        
        if isImageChnage {
            
            mqttDict = ["initiatorId":userID,
                        "initiatorIdentifier":num,
                        "groupId":self.groupID!,
                        "type": 5,
                        "groupImageUrl": self.groupImage!,
                        "id":"\(timeStamp)" as Any,
                        "timestamp":"\(String(describing: createdAt) )" as Any
            ]
            
            chatsDocVMObject?.updateGroupImage(withGpimage: self.groupImage!, toDocID: chatDocID!)
            self.addGroupTostMsgOnchat(otherUserNum: "\(num)", gpMessageType: "5")
            self.gpImageBlock?(groupImage!)
        }else {
            
             mqttDict = ["initiatorId":userID,
                                         "initiatorIdentifier":num,
                                         "groupId":self.groupID!,
                                         "type": 4,
                                         "groupSubject": self.groupName!,
                                         "id":"\(timeStamp)" as Any,
                                         "timestamp":"\(String(describing: createdAt))" as Any
            ]
            
            chatsDocVMObject?.updateGroupDoc(withName: self.groupName!, toDocID: chatDocID!)
            
            self.addGroupTostMsgOnchat(otherUserNum: "\(num),\(self.groupName!)", gpMessageType: "4")
            self.gpNameBlock?(groupName!)
        }
        
    
        
        for i in groupmembers{
            //dont send data to self
            if i["memberId"] as! String  == userID {}else {
                let groupChannel = "\(AppConstants.MQTT.groupChats)\(i["memberId"] as! String)"
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject:mqttDict as Any , options: .prettyPrinted)
                    self.mqttModel.publishData(wthData: jsonData, onTopic: groupChannel, retain: false, withDelivering:  .atLeastOnce)
                }catch  {
                    print("\(error.localizedDescription)")
                }
            }
        }
        
        
    }
    
    
    func sendRemoveMemeberSignalOnMqtt(dict:[String:Any]){
        
        guard let userID = Utility.getUserid() else {return}
        guard let num = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else {return}
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        
        let mqttDict:[String:Any] = ["initiatorId":userID,
                                     "initiatorIdentifier":num,
                                     "groupId":self.groupID!,
                                     "type": 2,
                                     "memberId":dict["memberId"] as! String,
                                     "memberIdentifier":dict["memberIdentifier"] as! String,
                                     "id":"\(timeStamp)" as Any,
                                     "timestamp":"\(String(describing: createdAt))" as Any
        ]
        
        for i in groupmembers{
            //dont send data to self
            if i["memberId"] as! String  == userID {}else {
                let groupChannel = "\(AppConstants.MQTT.groupChats)\(i["memberId"] as! String)"
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject:mqttDict , options: .prettyPrinted)
                    self.mqttModel.publishData(wthData: jsonData, onTopic: groupChannel, retain: false, withDelivering:  .atLeastOnce)
                }catch  {
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func sendAddmemeberInGroupSignalOnMqtt(dict:[String:Any]){
        
        guard let userID = Utility.getUserid() else {return}
        guard let num = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else {return}
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        
        var mqttDict:[String:Any] = ["memberId":dict["memberId"] as! String,
                                     "memberIdentifier":dict["memberIdentifier"] as! String,
                                     "groupId":self.groupID!,
                                     "type": 1,
                                     "memberImage":dict["memberImage"] as! String,
                                     "memberStatus":dict["memberStatus"] as! String,
                                     "userName": dict["userName"] as! String,
                                     "id":"\(timeStamp)" as Any,
                                     "timestamp":"\(String(describing: createdAt))" as Any,
                                     "initiatorId" : userID,
                                     "initiatorIdentifier": num,
                                     "memberIsAdmin" : false
        ]
        
        
        for i in groupmembers{
            //dont send data to self
            if i["memberId"] as! String  == userID {}else {
                
                if dict["memberId"] as! String == i["memberId"] as! String{
                    mqttDict["groupSubject"] = self.groupName!
                    mqttDict["members"] = self.groupmembers
                    mqttDict["createdByMemberId"]  = self.groupInfo!["createdByMemberId"] as! String
                    mqttDict["createdByMemberIdentifier"]  = self.groupInfo!["createdByMemberIdentifier"] as! String
                    mqttDict["createdAt"]  = self.groupInfo!["createdAt"] as! String
                }
                
                let groupChannel = "\(AppConstants.MQTT.groupChats)\(i["memberId"] as! String)"
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject:mqttDict , options: .prettyPrinted)
                    self.mqttModel.publishData(wthData: jsonData, onTopic: groupChannel, retain: false, withDelivering:  .atLeastOnce)
                }catch  {
                    print("\(error.localizedDescription)")
                }
            }
        }
        
        
    }
    
}


extension GroupInfoTableViewController {
    
    func addGroupTostMsgOnchat(otherUserNum: String?,gpMessageType: String){
        
        
        //****************
        //Add Group message Tag
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase:self.couchbaseObj)
        var replyingMessage : Message?
        guard let userID = Utility.getUserid() else {return}
        guard let message = chatsDocVMObject.makeMessageForSendingBetweenServers(withText: otherUserNum!, andType: "0", isReplying: false, replyingMsgObj: replyingMessage, senderID: userID, receiverId: self.groupID!, chatDocId: self.chatDocID!) else { return }
        
        guard let MsgObjForDB = chatsDocVMObject.getMessageObject(fromData: message, withStatus: "0", isSelf: true, fileSize: 0, documentData: nil, isReplying: false, replyingMsgObj: replyingMessage) else {return}
        
        var msgObj = MsgObjForDB
        guard let dateString = DateExtension().getDateString(fromDate: Date()) else { return }
        msgObj["sentDate"] = dateString as Any
        msgObj["gpMessageType"] = gpMessageType
        if let chatDta = self.couchbaseObj.getData(fromDocID: self.chatDocID!) {
            chatsDocVMObject.updateChatData(withData: chatDta, msgObject : msgObj as Any, inDocID  : self.chatDocID!, isCreatingChat: false)
        }
        //******************************
        
    }
    
    
    
}



extension GroupInfoTableViewController{
    
    
    func filterMessagesAndExportChat(chatDocID : String){
        let messageArr = chatsDocVMObject?.getMessages(withChatDocID: chatDocID)
        let filterTextMsgArr = messageArr?.filter({
            $0.messageType == .text && $0.gpMessageType == ""
        })
        
        var textMessage = ""
        _ = filterTextMsgArr?.filter({
            if textMessage != ""{
                textMessage = textMessage + "," + "\n"
            }
            
            if $0.isSelfMessage == true {
                textMessage.append("You".localized + " : \($0.text!)")
            }else {
                textMessage.append("\(String(describing: $0.receiverIdentifier!)) : \($0.text!)")
            }
            return true
        })
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("\(String(describing: self.groupName!))textfile.txt")
            //writing
            do {
                try textMessage.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
            
            let dataaa = NSData.init(contentsOfFile: fileURL.path)
            if (MFMailComposeViewController.canSendMail()) {
                let mailCompose = MFMailComposeViewController()
                mailCompose.mailComposeDelegate = self
                mailCompose.setSubject("\(AppConstants.AppName) " + "Message Chat".localized)
                mailCompose.setMessageBody("here is message chat history please find Attachment".localized, isHTML: false)
                mailCompose.addAttachmentData(dataaa! as Data, mimeType:"application/scarybugs", fileName: "Do_Chat\(self.groupName!)textfile.txt")
                self.present(mailCompose, animated: true, completion: nil)
            }
        }
    }
}


extension GroupInfoTableViewController:MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
          self.dismiss(animated: true, completion: nil)
    }
    
}



