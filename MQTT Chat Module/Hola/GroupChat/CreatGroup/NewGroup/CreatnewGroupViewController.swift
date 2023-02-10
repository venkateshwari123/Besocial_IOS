//
//  CreatnewGroupViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 07/02/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import Locksmith
import CocoaLumberjack
import Alamofire
class CreatnewGroupViewController: UIViewController {
    
    var selectedGpList = [Contacts]()
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var numberOfMemCount: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var membersCollectionView: UICollectionView!
    @IBOutlet weak var grouoNameText: UITextField!
    @IBOutlet weak var groupNameCount: UILabel!
    @IBOutlet weak var createBtnOutlet: UIBarButtonItem!
    @IBOutlet weak var descriptionLbl: UILabel!
    var imageUrl = ""
    var couchbase = Couchbase.sharedInstance
    let mqttChatManager = MQTTChatManager.sharedInstance
    let mqttModel = MQTT.sharedInstance
    
    //CreatGroupCell
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    func setupView(){
        membersCollectionView.delegate = self
        membersCollectionView.dataSource = self
        grouoNameText.delegate = self
        groupImageView.isUserInteractionEnabled = true
        groupImageView.layer.cornerRadius = groupImageView.frame.size.width/2
        groupImageView.clipsToBounds = true
        groupNameCount.text = "24"
        self.navigationItem.title = "New Group".localized
        createBtnOutlet.title = "Create".localized
        grouoNameText.placeholder = "Enter Group Name".localized
        editButton.setTitle("edit".localized, for: .normal)
        descriptionLbl.text = "Please provide a group subject and optional group icon".localized
        numberOfMemCount.text = "PARTICIPANTS".localized + ": \(selectedGpList.count)/256"
        grouoNameText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(groupimageTapped(tapGestureRecognizer:)))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        self.groupImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        tapGestureRecognizer1.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        grouoNameText.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func viewTapped(tapGestureRecognizer:UITapGestureRecognizer){
        grouoNameText.resignFirstResponder()
    }
    
    
    //MARK: - ImageTapped Cliked..
    @objc func  groupimageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        grouoNameText.resignFirstResponder()
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        if self.groupImageView.image != #imageLiteral(resourceName: "edit_profile_add_photo_icon_off")  && self.groupImageView.image != nil {
            alert.addAction(UIAlertAction(title: "Delete Photo".localized, style: .destructive, handler: { (action) in
                self.deletePhoto()
            }))
        }
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
    
    @IBAction func editButtonCliked(_ sender: Any) {
        
        grouoNameText.resignFirstResponder()
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        if self.groupImageView.image != #imageLiteral(resourceName: "edit_profile_add_photo_icon_off")  && self.groupImageView.image != nil {
            alert.addAction(UIAlertAction(title: "Delete Photo".localized, style: .destructive, handler: { (action) in
                self.deletePhoto()
            }))
        }
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
    
    
    
    @IBAction func creatBtnCliked(_ sender: Any) {
        self.view.endEditing(true)
        if self.grouoNameText.text?.count == 0 {
            let alert = UIAlertController.init(title: "Oops".localized, message: "Enter Group Name".localized, preferredStyle: .alert)
            let alerAction = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
            alert.addAction(alerAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Helper.showPI(_message: "Creating".localized + "...")
        let strURL = AppConstants.creatgroupChat
        var membersArr = [String]()
        
        for i in selectedGpList{
            membersArr.append(i.userID!)
        }
        
        let params = ["members":membersArr ,
                      "subject": self.grouoNameText.text!,
                      "image":self.imageUrl] as [String:Any]
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.creatGroupAPI.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.creatGroupAPI.rawValue {
                    guard  let data = dict["data"] as? [String:Any] else {return}
                    let groupId: String = data["chatId"] as! String
                    
                    
                    let groupDocID = self.couchbase.createDocument(withProperties: ["groupMembersDocId":""] as [String : Any])
                    
                    //Add groupId and groupDocID in GroupChatsDocument
                    /*
                     Bug Name:- Crash
                     Fix Date:- 10/01/22
                     Fix By  :- Jayaram G
                     Description of Fix:- Crashing due to force unwrap , handle optional value with if let.
                     */
                    if let groupDocIdObj = groupDocID {
                        self.updateGroupChatsDocument(groupID: groupId, groupDocId: groupDocIdObj)
                    }
                    
                    var image :String
                    var status: String
                    var userName: String = ""
                    
                    guard let userID = Utility.getUserid() else {return}
                    guard let num = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else {return}
                    if let img = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImageForChats) as? String{image = img } else { image = ""}
                    if let stus = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userStatus)as? String{status = stus } else {status = "" }
                    if let name = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String{
                        userName = name
                    }
                    
                    var groupMembersArrays = [[String:Any]]()
                    let ownDict =  ["memberId":userID,
                                    "memberIdentifier":num,
                                    "memberImage":image,
                                    "memberStatus":status,
                                    "memberIsAdmin":true,
                                    "userName":userName
                        ] as [String:Any]
                    groupMembersArrays.append(ownDict)
                    
                    
                    for i in self.selectedGpList {
                        var detailDict =  [String:Any]()
                        detailDict["memberId"] = i.userID
                        detailDict["memberIdentifier"] = i.fullName
                        detailDict["memberImage"] = i.profilePic
                        detailDict["memberStatus"] = i.status
                        detailDict["memberIsAdmin"] = false as Bool
                        detailDict["userName"] = i.fullName
                        groupMembersArrays.append(detailDict)
                    }
                    
                    
                    
                    ///To inform the members of the group creation
                    let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
                    
                    let storedict = ["groupMembersArray":groupMembersArrays ,
                                     "createdByMemberId":userID,
                                     "createdByMemberIdentifier":num,
                                     "createdAt":"\(timeStamp)" as Any,
                                     "isActive":true as Bool
                        ] as [String:Any]
                    
                    self.updategroupMembersDocument(documentID: groupDocID!, newData: storedict)
                    let createdAt = DateExtension().sendTimeStamp(fromDate: Date())
                    //sendTimeStamp
//                    let date = NSDate() // current date
//                    let unixtime = date.timeIntervalSince1970 * 10000000

                    
                    let mqttDict:[String:Any] = ["memberId":userID,
                                                 "memberIdentifier":num,
                                                 "memberImage":self.imageUrl,
                                                 "groupImageUrl":self.imageUrl,
                                                 "memberStatus":status,
                                                 "memberIsAdmin":true,
                                                 "groupSubject":self.grouoNameText.text!,
                                                 "initiatorId":userID,
                                                 "initiatorIdentifier":num,
                                                 "members":groupMembersArrays,
                                                 "groupId":groupId,
                                                 "type":0,
                                                 "createdByMemberId":userID,
                                                 "createdByMemberIdentifier":num,
                                                 "createdAt": timeStamp,
                        "timestamp":"\(createdAt!)" ,
                        "id":"\(timeStamp)"
                    ]
                    print(mqttDict)
                    
                    
                    let docID = self.createGroupChatDoc(withGroupID: groupId, andGroupDetails: mqttDict)
                    //****************
                    //Add Group message Tag
                    let chatsDocVMObject = ChatsDocumentViewModel(couchbase:self.couchbase)
                    var replyingMessage : Message?
                    guard let message = chatsDocVMObject.makeMessageForSendingBetweenServers(withText: "\(num),\(self.grouoNameText.text!)", andType: "0", isReplying: false, replyingMsgObj: replyingMessage, senderID: userID, receiverId: groupId, chatDocId: docID ?? "") else { return }
                    
                    
                    guard let MsgObjForDB = chatsDocVMObject.getMessageObject(fromData: message, withStatus: "0", isSelf: true, fileSize: 0, documentData: nil, isReplying: false, replyingMsgObj: replyingMessage) else {return}
                    
                    var msgObj = MsgObjForDB
                    guard let dateString = DateExtension().getDateString(fromDate: Date()) else { return }
                    msgObj["sentDate"] = dateString as Any
                    msgObj["gpMessageType"] = "0"
                    if let chatDta = self.couchbase.getData(fromDocID: docID!) {
                        chatsDocVMObject.updateChatData(withData: chatDta, msgObject : msgObj as Any, inDocID  : docID!, isCreatingChat: false)
                    }
                    //******************************
                    
                    let storKey = ["isCreated":true,
                                   "docId": docID ?? ""] as [String : Any]
                    UserDefaults.standard.set(storKey, forKey: "isCreatingNewGroupPress")
                    
//                    if  let tabbar =   UIApplication.shared.windows[0].rootViewController as? UITabBarController{
//                        tabbar.selectedIndex = 1}
//                    self.dismiss(animated: true, completion:nil)
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    for i in groupMembersArrays {
                        //dont send data to self
                        if i["memberId"] as! String  == userID{}
                        else {
                            let groupChannel = "\(AppConstants.MQTT.groupChats)\(i["memberId"] as! String)"
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject:mqttDict , options: .prettyPrinted)
                                self.mqttModel.publishData(wthData: jsonData, onTopic: groupChannel, retain: false, withDelivering:  .atLeastOnce)
                                
                            } catch {
                                DDLogDebug("\(error.localizedDescription)")
                            }
                        }
                    }
                    
                    //Send creatGroup message to All
                    
                }
            }, onError: {error in
                Helper.hidePI()
            })
    }
    
    func createGroupChatDoc(withGroupID groupID: String, andGroupDetails groupDetails: [String : Any]?) -> String? {
        let individualChatDocVMObject = IndividualChatViewModel(couchbase: couchbase)
        
        guard let chatDocID = individualChatDocVMObject.getChatDocID(withreceiverID: groupID, andSecretID: "", withContactObj: nil, messageData: groupDetails, destructionTime: nil, isCreatingChat: true) else {
            DDLogDebug("error in creating chatdoc \(self)")
            return nil
        }
        return chatDocID
    }
    
    //update groupId and groupId in GroupChatsDocument
    func updateGroupChatsDocument(groupID: String ,groupDocId:String){
        guard let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument) as? String else {return}
        if  let document = self.couchbase.getDocumentObject(fromDocID: documentID){
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
            return            
        }
    }
    
    
    
    func updategroupMembersDocument(documentID:String,newData:[String:Any]){
        
        if let document = self.couchbase.getDocumentObject(fromDocID: documentID){
            do{
                try document.update{ (newRev) -> Bool in
                    newRev["groupMembersDocId"] = newData
                    return true
                }
            } catch let error {
                DDLogDebug("cdkvndkv\(error)")
            }
        }else {
            DDLogDebug("failed to get documet from provided DocID")
            return}
    }
    
}

//MARK: - CollectionViewDelegate
extension CreatnewGroupViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedGpList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreatGroupCell", for: indexPath) as! CreatGroupCollectionViewCell
        let contact = selectedGpList[indexPath.row]
        Helper.addedUserImage(profilePic: contact.profilePic, imageView: cell.memImageView, fullName: contact.fullName ?? "P")
        cell.nameLbl.text = contact.fullName == "" ? contact.fullName : contact.fullName
        
        return cell
    }
}


//MARK: - Textfiled delegate
extension CreatnewGroupViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.grouoNameText.resignFirstResponder()
        return true
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // groupNameCount.text = String(describing: (textField.text?.count)!)
        //        if (textField.text?.count)! > 24 {
        //            self.grouoNameText.deleteBackward()
        //        }
        
        groupNameCount.text = String(describing: 24 - (textField.text?.count)!)
        if (textField.text?.count)! > 24 {
            self.grouoNameText.deleteBackward()
        }
        
    }
    
}


//MARK: - Image Upload,delete
extension CreatnewGroupViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func deletePhoto() {
        self.groupImageView.image = #imageLiteral(resourceName: "edit_profile_add_photo_icon_off")
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
            self.showAlert("Alert".localized, message: "Your device doesn't support Camera".localized + ". " + "Please choose other option".localized + ".")
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
    
    
    func uploadPhotoToAPI(withImage image: UIImage) {
        let name  = arc4random_uniform(900000) + 100000;
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        AFWrapper.updloadPhoto(withPhoto: image, andName: "\(name)\(timeStamp)", progress: {
            (progres) in
        }, success: { (response) in
            Helper.hidePI()
            let fileName = "\(name)\(timeStamp).jpeg"
            let url = AppConstants.uploadImageURLExtension + "/" + "\(fileName)"
            self.imageUrl = url
            
        }, failure: { (error) in
            Helper.hidePI()
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let flippedImage = info[.originalImage] as? UIImage else {return}
      //  let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation:.leftMirrored)
        self.groupImageView.image = flippedImage
        Helper.showPI(_message: "Uploading".localized + "...")
               self.uploadPhotoToAPI(withImage: flippedImage)
               self.dismiss(animated: true, completion: nil)
    }
     
}
