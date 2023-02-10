//
//  SharePostViewController.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 24/11/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol storyDelegate {
    func deleteStoryTapped()
    func dismissedViewScreen()
}


class SharePostViewController: UIViewController{

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var shareHeaderView: UIView!
    @IBOutlet weak var noUserImageView: UIImageView!
    @IBOutlet weak var noUserLabel: UILabel!
    
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var storyDeleteBtn: UIButton!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sharePostTableView: UITableView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var peopleSearchBar: UISearchBar!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    
    var isSearchActive: Bool = false
    var searchText: String?
    
    var isForStory = false
    var storyDelga:storyDelegate?
    var selectedStory:StoryModel?
    
    @IBOutlet weak var noViewsView: UIView!
    var canServiceCall: Bool = false
    var postDetails: SocialModel?
    var storyViewModel = StoryViewModel()
    var canServiceCallForStory: Bool = false

    var sharePostViewModel = SharePostViewModel()
    
    let couchbaseObj = Couchbase.sharedInstance
    let favoriteViewModel = FavoriteViewModel.sharedInstance
    let mqttChatManager = MQTTChatManager.sharedInstance
    var chatViewModelObj : ChatViewModel?
    
    var chatsDocVMObject : ChatsDocumentViewModel! {
        return ChatsDocumentViewModel(couchbase: couchbaseObj)
    }
    
    struct cellIdentifier{
        static let sharePostTableViewCell = "sharePostTableViewCell"
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocalization()
        if isForStory {
            self.headerLabel.text = ""
            getStoryViewersList()
            self.shareHeaderView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
          
            self.storyDeleteBtn.isHidden = false
            self.btnDone.isHidden = true
            self.searchBarHeightConstraint.constant = 0
            self.peopleSearchBar.isHidden = true
        } else {
            self.headerLabel.text = "Share".localized
            self.btnDone.isHidden = false
//            if sharePostViewModel.followersFolloweeModelArray.count == 20{
//                self.canServiceCall = true
//            }
            
            self.followFolloweServiceCall(strUrl: AppConstants.followersFollowee + "?")
            self.clearMessageStatusKey()
        }

        //Setup
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(pan))
        self.shareHeaderView.addGestureRecognizer(panGR)
    }
    
    func setLocalization(){
        cancelBtn.setTitle("Cancel".localized, for: .normal)
        btnDone.setTitle("Done".localized, for: .normal)
        peopleSearchBar.placeholder = "Search".localized + " " + "people".localized + " " + "to".localized + " " + "share post".localized
    }
    
    @IBAction func btnDone_Tapped(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.storyDelga?.dismissedViewScreen()
        })
    }
    
    
    @objc func pan(recognizer : UIPanGestureRecognizer){
        if recognizer.direction == .up{
            self.makeTopConstraintZero()
        }else if recognizer.direction == .down{
            self.dismiss(animated: true, completion: {
                self.storyDelga?.dismissedViewScreen()
            })
        }
    }
    
    func makeTopConstraintZero(){
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.viewTopConstraint.constant = 0.0
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if selectedStory?.allViewers.count == 0 {
            self.noViewsView.isHidden = false
            self.sharePostTableView.isHidden = true
            self.peopleSearchBar.isHidden = true
            
        }
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
    
    /// To clear message status key for all data in array for first time only
    private func clearMessageStatusKey(){
        for data in sharePostViewModel.followersFolloweeModelArray{
            data.messageStatus = 0
        }
    }
    
    //MARK:- Button Action
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion:{
            self.storyDelga?.dismissedViewScreen()
        })
    }
    
    
    @IBAction func storyDeleteBtnAction(_ sender: Any) {
        if isForStory {
            self.dismiss(animated: true, completion: {
                self.storyDelga?.deleteStoryTapped()
            })
        }
    }
    
    
    //MARK:- Service call
    func getStoryViewersList() {
        self.storyViewModel.getStoryViewersList(storyId: self.selectedStory?.storyID ?? "", strUrl: AppConstants.storyViewersList) { (success, error, canServiceCall) in
            if success{
                var numberOfViews = String(self.storyViewModel.storyViewersListArray.count)

                if numberOfViews == "1" {
                    numberOfViews = numberOfViews + " " + "view".localized
                } else {
                    numberOfViews = numberOfViews + " " + "views".localized
                }
                if self.storyViewModel.storyViewersListArray.count == 0 {
                    self.noViewsView.isHidden = false
                    self.sharePostTableView.isHidden = true
                    self.peopleSearchBar.isHidden = true
                }else{
                    self.noViewsView.isHidden = true
                    self.sharePostTableView.isHidden = false
                    self.peopleSearchBar.isHidden = false

                }
                self.cancelBtn.setTitle(numberOfViews, for: .normal)

                self.sharePostTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            self.canServiceCallForStory = canServiceCall
        }
    }
    
    func followFolloweServiceCall(strUrl: String){
//        let strUrl = AppConstants.followersFollowee
        Helper.showPI()
        sharePostViewModel.getFollowAndFollowesService(strUrl: strUrl) { (success, error, canServiceCall) in
            if success{
                print("success")
                self.noViewsView.isHidden = true
                DispatchQueue.main.async {
                    self.sharePostTableView.reloadData()
                }
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.noViewsView.isHidden = false
                self.noUserImageView.image =  #imageLiteral(resourceName: "contacts")
                self.noUserLabel.text = "No users found".localized
                self.sharePostViewModel.offset = self.sharePostViewModel.offset - 20
            }
            Helper.hidePI()
            self.canServiceCall = canServiceCall
        }
    }

}

//MARK:- Search bar delegate
extension SharePostViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let searchString = searchBar.text
        print("searchString ",searchString)
        if (searchBar.text?.count ?? 0) > 0 {
            self.sharePostViewModel.getArrayForSearchedString(searchText: searchString ?? "" )
            self.sharePostViewModel.isSearchActive = true
            self.setNoUserView()
            self.sharePostTableView.reloadData()
        }else{
            self.sharePostViewModel.offset = -20
            self.followFolloweServiceCall(strUrl: AppConstants.followersFollowee + "?")
            self.sharePostViewModel.getArrayForSearchedString(searchText: searchString ?? "" )
            self.setNoUserView()
            self.sharePostViewModel.isSearchActive = false
        
        }

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.sharePostViewModel.isSearchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.makeTopConstraintZero()
//        self.sharePostViewModel.isSearchActive = true
//        self.sharePostViewModel.getArrayForSearchedString()
//        self.sharePostTableView.reloadData()
    }
    
    func setNoUserView(){
        if self.sharePostViewModel.searchFolloweeModelArray.count > 0 {
            self.noViewsView.isHidden = true
        }else{
            self.noViewsView.isHidden = false
            self.noUserImageView.image =  #imageLiteral(resourceName: "contacts")
            self.noUserLabel.text = "No users found".localized
        }
    }
    
}

//MARK:- Table view delegate and datasource
extension SharePostViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isForStory {
            return self.storyViewModel.storyViewersListArray.count
        } else {
            if self.sharePostViewModel.isSearchActive{
                return self.sharePostViewModel.searchFolloweeModelArray.count
            }
            return sharePostViewModel.followersFolloweeModelArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !isForStory {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.sharePostTableViewCell) as? SharePostTableViewCell else {fatalError()}
            if self.sharePostViewModel.isSearchActive{
                cell.index = indexPath.row
                cell.followModel = sharePostViewModel.searchFolloweeModelArray[indexPath.row]
            }else{
                cell.index = indexPath.row
                cell.followModel = sharePostViewModel.followersFolloweeModelArray[indexPath.row]
            }
            cell.delegate = self
            return cell
        } else {
           let userCell =  tableView.dequeueReusableCell(withIdentifier: "StoryUserTableViewCell", for: indexPath) as! StoryUserTableViewCell
            userCell.setupUserDetails(viewedUser: self.storyViewModel.storyViewersListArray[indexPath.row])
            return userCell
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        var indexPassed: Bool = false
//        if self.sharePostViewModel.isSearchActive{
//            indexPassed = indexPath.row >= self.sharePostViewModel.searchFolloweeModelArray.count - 10
//        }else{
//            indexPassed = indexPath.row >= self.sharePostViewModel.followersFolloweeModelArray.count - 10
//        }
        let indexPassed = indexPath.row >= self.sharePostViewModel.followersFolloweeModelArray.count - 5
        if canServiceCall && indexPassed{
            self.canServiceCall = false
            followFolloweServiceCall(strUrl: AppConstants.followersFollowee + "?")
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if isForStory {
            let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
            profileVC.isNotFromTabBar = true
            profileVC.hidesBottomBarWhenPushed = true
            let navigateProfileVc = UINavigationController.init(rootViewController: profileVC)
            profileVC.isPresented = true
            profileVC.memberId = self.storyViewModel.storyViewersListArray[indexPath.row].userId
            self.present(navigateProfileVc, animated: true)
        }
    }
}

//MARK:- Post share delegate
extension SharePostViewController: SharePostTableViewCellDelegate{
    
    func sendButtonClicked(index: Int) {
         /// Post details
        let postDetails = self.postDetails!
        guard let postImageStrUrl = self.getImageUrl() else {return}
        guard let postImageUrl = URL(string: postImageStrUrl) else {return}
        
        //download image
        self.downloadImageData(from: postImageUrl) { data in
            
            let tImage = UIImage(data: data!)!
//            let img = self.createImageMessage(withThumbnail: tImage)
            guard let imageData = self.createThumbnail(forImage: tImage) else { return }
            let imgData: NSData = NSData(data: (tImage).jpegData(compressionQuality: 0.5)!)
            let imageSize = imgData.length
            
            //Create contact object to get document id
            let userDetails = self.sharePostViewModel.followersFolloweeModelArray[index]
            let contact = Contacts(fullName: userDetails.firstName + " " + userDetails.lastName, alternateNumbers: nil, contactID: nil, modificationDate: nil, isFavorite: nil, registerNum: userDetails.number, profilePic: userDetails.profilePic, status: userDetails.status, chatDocID: nil, userID: userDetails.id, follow: nil, followStatus: nil, privicy: nil, firstName: userDetails.firstName, lastName: userDetails.lastName, isStar: userDetails.isStar)
            
            //search doc id if it is not there then create
            let userId = userDetails.id
            if let chatDocId = self.getChatDocId(contactObj: contact){
                
                //update in favourite contact list
                self.favoriteViewModel.updateContactDoc(withUserID: userId, andChatDocId: chatDocId)
                let chatsDocVMObject = ChatsDocumentViewModel(couchbase: self.couchbaseObj)
                
                //create message object to sent it through MQTT
                let timeStamp : String = "\(UInt64(floor(Date().timeIntervalSince1970 * 1000)))"
                let senderId = Helper.getselfUserId()
                guard let msgObj = chatsDocVMObject.makeMessageForSendingBetweenServersForPost(withData: imageData, withMediaSize: imageSize, andMediaURL: postImageStrUrl, withtimeStamp: timeStamp, andType: "13", documentData: nil, isReplying: false, replyingMsgObj: nil, senderID: senderId, receiverId: userId, chatDocId: chatDocId, postId: postDetails.postId!, postTitle: postDetails.title!, postType: postDetails.mediaType!) else { return }
                //Send throught MQTT
                self.mqttChatManager.sendMessage(toChannel: "\(userId)", withMessage: msgObj, withQOS: .atLeastOnce)
                
                //Create message object to save in DB
                guard let MsgObjForDB = chatsDocVMObject.getMessageObject(fromData: msgObj , withStatus: "13", isSelf: true, fileSize: Double(imageSize), documentData: nil, isReplying: false, replyingMsgObj: nil) else { return }
                var msgObjDB = MsgObjForDB
                guard let dateString = DateExtension().getDateString(fromDate: Date()) else { return }
                msgObjDB["sentDate"] = dateString as Any
                //Get all user data from database
                if let chatDta = self.couchbaseObj.getData(fromDocID: chatDocId) {
                    chatsDocVMObject.updateChatData(withData: chatDta, msgObject : msgObjDB as Any, inDocID  : chatDocId, isCreatingChat: false)
                }
                //update message to database
                self.chatsDocVMObject.updateChatDoc(withMsgObj: msgObjDB, toDocID: chatDocId)
            }
        }
    }
    
    
    /// To get image url if it is video type
    ///
    /// - Returns: image url
    func getImageUrl() -> String?{
        
        let postDetails = self.postDetails!
        var postImageStrUrl = postDetails.imageUrl
        if postDetails.mediaType == 1{
            postImageStrUrl = Helper.getImageStringUrl(url: postDetails.imageUrl)
        }
        guard let imageUrl = postImageStrUrl else {return nil}
        return imageUrl
    }
    
  
    
    /// To get document of user and create it is not there
    ///
    /// - Parameter contactObj: contact object of user
    /// - Returns: document of user
    private func getChatDocId(contactObj: Contacts) -> String?{
        let individualChatDocVMObject = IndividualChatViewModel(couchbase: couchbaseObj)
        guard let chatDocID = individualChatDocVMObject.getChatDocID(withreceiverID: contactObj.userID!, andSecretID: "", withContactObj: contactObj, messageData: nil, destructionTime: nil, isCreatingChat: false) else {
            DDLogDebug("error in creating chatdoc \(self)")
            return nil
        }
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        if let chatObj = chatsDocVMObject.getChatObj(fromChatDocID: chatDocID) {
            self.chatViewModelObj = ChatViewModel(withChatData: chatObj)
        }
        return chatDocID
    }
    
    //MARK:- Download image data from URL
    func downloadImageData(from url: URL, completion: @escaping (Data?) -> ()) {
        print("Download Started")
        Helper.showPI()
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                Helper.hidePI()
                return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                Helper.hidePI()
                completion(data)
            }
        }.resume()
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    /// To create image thumbnail
    ///
    /// - Parameter image: image to create thumbnail
    /// - Returns: image thumbnail data in base64 encoded
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
    
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
