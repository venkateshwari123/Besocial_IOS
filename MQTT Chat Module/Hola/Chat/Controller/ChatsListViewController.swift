
//  ChatsListViewController.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 22/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import SwiftyJSON
import CocoaLumberjack
import Firebase

class ChatsListViewController: UIViewController {
    
    struct  Constants {
        static let cellIdentifier = "ChatListTableViewCell"
        static let chatSegueIdentifier = "segueToChatViewController"
    }
    
    @IBOutlet weak var storiesBackView: UIView!
    
    @IBOutlet weak var searchShadowView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    @IBOutlet weak var storiesBackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatStoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var defaultScreenView: UIView!
    @IBOutlet weak var chatlbl: UILabel!
    @IBOutlet weak var chatIcon: UIImageView!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var refreshButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var chatFloatingButtonOutlet: UIButton!
    
      lazy var refreshControl: UIRefreshControl = {
              let refreshControl = UIRefreshControl()
              refreshControl.addTarget(self, action:
                           #selector(self.getChatInitially),
                                       for: UIControl.Event.valueChanged)
              refreshControl.tintColor = Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor)
              
              return refreshControl
          }()
    
    struct Controlleridentifier {
        static let postedByController = "postedByController"
        static let commentsViewController = "commentsViewController"
        static let profileViewController = "ProfileViewController"
        static let SharePostViewController = "SharePostViewController"
        static let ViewStoryID = "viewStoryID"
        static let CameraViewController = "CameraViewController"
    }
    
    struct cellIdentifier {
        static let PostStoryCollectionViewCell = "PostStoryCollectionViewCell"
    }
    
    var chatListViewModel: ChatListViewModel!
    let walletViewModelObject = WalletViewModel()
    let selfID = Utility.getUserid()
    let socialViewModel = SocialViewModel()
    var chatTabVC: ChatTabViewController?
    var floaty = Floaty()
    var selfIndexPath = IndexPath()
    var isSearchActive: Bool = false
    var isLoadedFirst: Bool = false
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        MQTT.sharedInstance.createConnection()
        guard let userId = Utility.getUserid() else {return}
        let topic = AppConstants.MQTT.userUpdates + userId
        MQTT.sharedInstance.subscribeTopic(withTopicName: topic, withDelivering: .atLeastOnce)
        if AppConstants.appType == .picoadda {
            self.storiesBackView.isHidden = true
            self.storiesBackViewHeightConstraint.constant = 0
        }
        
        var name = NSNotification.Name(rawValue: "ChatUpdatedNotification")
        NotificationCenter.default.setObserver(self, selector: #selector(ChatsListViewController.updateChatList), name: name, object: nil)
        
        var deleteName = NSNotification.Name(rawValue: "DeleteChatNotification")
        NotificationCenter.default.setObserver(self, selector: #selector(self.deleteChat(_:)), name: deleteName, object: nil)
        
        name = NSNotification.Name(rawValue: "notificationTapped")
        NotificationCenter.default.setObserver(self, selector: #selector(ChatsListViewController.notificationTapped(notification:)), name: name, object: nil)
        
        if !Utility.isDarkModeEnable(){
            self.storiesBackView.makeBorderWidth(width: 0.6, color: .lightGray)
        }
        self.updateChatList()
        if let userID = selfID {
            MQTTChatManager.sharedInstance.subscribeGetChatTopic(withUserID: userID)
            if (self.chatListViewModel != nil) {
                let count = self.chatListViewModel.unreadChatsCounts()
                if count==0 {
                    Helper.showPI(_message: "Fetching Chats".localized + "...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        Helper.hidePI()
                    }
                    ChatAPI().getChats(withPageNo:"0", withCompletion: { response in
                        print(response)
                        let couchbaseObj = Couchbase.sharedInstance
                        let chatdocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
                        if let selfID = Utility.getUserid() {
                            if topic.range(of:selfID) != nil {
                                guard let chatData = response as? [String:Any]else {return}
                                let chats = ["chats":chatData["response"]]
                                chatdocVMObject.updateDocumentForChatReceived(withChatData: chats, atTopic: AppConstants.MQTT.getChats, isGroupChat: false)
                            }
                        }
                        Helper.hidePI()
                    })
                }
            }
            self.tableViewOutlet.addSubview(self.refreshControl)
            self.chatListViewModel.getIceServerDetailsService {_,_ in }
        }
        self.setViewUI()
        tableViewOutlet.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MQTTManager.shared.delegate = self
        guard let userId = Utility.getUserid() else{ return}
        MQTTManager.shared.subscribeToTopic(topic: "\(userId)")
        self.showdefaultScreen()
        //        self.setViewUI()
        self.tableViewOutlet.reloadData()
        if let tabbar = self.tabBarController as? TabbarController {
            tabbar.enablePushNotification()
        }
        self.checkNewGroupCreated()
        addObserverForReload()
        // self.profileImageView.makeCornerRadious(readious: self.self.profileImageView.frame.width / 2)
        
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addObserverForReload()
         
        //        self.refresh()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("layout subview")
        if !self.isLoadedFirst{
            self.isLoadedFirst = true
            //   self.setFloatingButton()
        }
        //        self.updateChatList()
        //        self.getChatInitially()
        //
        //        self.showdefaultScreen()
        //        self.tableViewOutlet.reloadData()
        //        self.checkNewGroupCreated()
        //        self.setFloatingButton()
    }
    
    func updateChatCountWhenOpeningApp(){
        let couchbaseObj = Couchbase.sharedInstance
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        guard let chats = chatsDocVMObject.getChats() else { return }
        self.chatListViewModel = ChatListViewModel(withChatObjects: chats)
        self.updateChatListCount()
    }
    
    @objc func updateChatList() {
        let couchbaseObj = Couchbase.sharedInstance
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        guard let chats = chatsDocVMObject.getChats() else { return }
        self.chatListViewModel = ChatListViewModel(withChatObjects: chats)
        self.chatListViewModel.authCheckForNotification()
        self.updateChatListCount()
        showdefaultScreen()
        refreshControl.endRefreshing()
        self.tableViewOutlet.reloadData()
    }
    func addObserverForReload(){
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "RefreshChatStories"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMystories(notification:)), name:NSNotification.Name(rawValue:"updateMyChatStories"), object: nil)
    }
    
    @objc func refresh(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.socialViewModel.offset = -20
            //            self.socialViewModel.socialModelArray = []
            self.socialViewModel.myStoryOffset = -20
            self.socialViewModel.otherStoryOffset = -20
            self.getMyStoryService()
            self.getOtherStoryService()
            self.getUserProfile()
        }
    }
    
    
    @objc func updateMystories(notification: NSNotification) {
        if let updatedStories = notification.object as? userStory {
            //            self.myStories = updatedStories
            let model = self.socialViewModel
            model.myStories = updatedStories
            DispatchQueue.main.async {
                self.chatStoriesCollectionView.reloadData()
            }
            //            self.storyTableView.reloadData()
        }
    }
    
    
    func updateChatListCount() {
        let count = self.chatListViewModel.unreadChatsCounts()
        if count == 0 {
            self.tabBarController?.tabBar.items?[3].badgeValue = nil
        } else {
            self.tabBarController?.tabBar.items?[3].badgeValue = "\(count)"
        }
     }
    
    @objc func notificationTapped(notification: NSNotification) {
        let userInfo = notification.userInfo!
        guard let chatObj = userInfo[AnyHashable("chatObj")] as? [AnyHashable : Any] else { return }
        var senderID = ""
        /* Bug Name : "SINGLE CHAT if user 2 is offline and user 1 sends a message , user 2 should receive a push notification and on clicking
         the push the chat details page should open"
         Fix Date : 12-apr-2021
         Fixed By : Jayaram G
         Description Of Fix : Added another key "from" check for if message is from normal chat.
         */
        if let id = chatObj[AnyHashable("from")] as? String, id != "" {
            senderID = id
        } else if let id = chatObj[AnyHashable("GroupId")] as? String, id != "" {
            senderID = id
        }  ///from  senderID
        
        var secretId =  ""
        if let setretID = chatObj[AnyHashable("secretId")] as? String, setretID != "" {
            secretId = setretID
        }
        
        let individualCVMObj = IndividualChatViewModel(couchbase: Couchbase())
        if let toDocID = individualCVMObj.fetchIndividualChatDoc(withReceiverID: senderID, andSecretID: secretId) {
            
            let chatsDocVMObj = ChatsDocumentViewModel(couchbase: Couchbase())
            if let chat = chatsDocVMObj.getChatObj(fromChatDocID: toDocID) {
                if let chatDocID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.isUserOnchatscreen) as? String {
                    if chatDocID == toDocID {
                        return}
                }
                if (self.navigationController != nil){
                    self.performSegue(withIdentifier: Constants.chatSegueIdentifier, sender: chat)
                }else{
                    self.chatTabVC?.performSegue(withIdentifier: Constants.chatSegueIdentifier, sender: chat)
                }
            }
        }
    }
    
   @objc func getChatInitially() {
        //get chatList from api call
//    self.updateChatList()
        if let userID = selfID {
            MQTTChatManager.sharedInstance.subscribeGetChatTopic(withUserID: userID)
            if (self.chatListViewModel != nil) {
                refreshControl.endRefreshing()
                let count = self.chatListViewModel.getNumberOfRows(isSearchActive: self.isSearchActive)
//                if count==0 {
                    ChatAPI().getChats(withPageNo:"0", withCompletion: { response in
                        print(response)
                    })
//                }
            }
        }
    }
    
    /// To set the search UI
    func setViewUI(){
        
    }
    
    
    /// To set floating button and it's items
    func setFloatingButton(){
        
        //   self.addObserVerForCamera()
        floaty.hasShadow = true
        //        floaty.buttonColor = Utility.appColor()
        //        floaty.plusColor = UIColor.white
        floaty.itemButtonColor = UIColor.clear
        floaty.buttonImage = UIImage(named: "create_new_chat")
        
        let groupItem = FloatyItem()
        groupItem.title = "Create New Group".localized
        groupItem.icon = UIImage(named: "Group_chat_icon")
        groupItem.buttonColor = UIColor.clear
        groupItem.imageSize = CGSize(width: 50, height: 50)
        groupItem.handler = { item in
            //            let favDatabase:[Contacts] =  Helper.getFavoriteDataFromDatabase1()
            //            let story = UIStoryboard.init(name:AppConstants.StoryBoardIds.chat, bundle: nil)
            //            let controller = story.instantiateViewController(withIdentifier: "SelectGroupMemNav") as! UINavigationController
            //            let selectGpmem = controller.topViewController as! SelectGroupMemTableViewController
            //            selectGpmem.allFavoriteList =  favDatabase
            //            self.present(controller, animated: true, completion: nil)
            let storyboard = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
            guard let favouritVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.FollowListViewController) as? FollowListViewController else {return}
            //            favouritVC.isGroup = true
            favouritVC.controllerPurpose = .createGroup
            self.navigationController?.pushViewController(favouritVC, animated: true)
        }
        
        let contactItem = FloatyItem()
        contactItem.title = "Contacts".localized
        contactItem.icon = UIImage(named: "Contacts_icon")
        contactItem.buttonColor = UIColor.clear
        contactItem.imageSize = CGSize(width: 50, height: 50)
        contactItem.handler = { item in
            let storyboard = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
            guard let favouritVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.FollowListViewController) as? FollowListViewController else {return}
            favouritVC.controllerPurpose = .createSingleChat
            self.navigationController?.pushViewController(favouritVC, animated: true)
        }
        
        floaty.addItem(item: contactItem)
        floaty.addItem(item: groupItem)
        //        floaty.addItem(item: channelItem)
        let tableViewframe = self.tableViewOutlet.frame
        let frame = CGRect(x: tableViewframe.width - 80.0, y: tableViewframe.height - 80, width: 70, height: 70)
        floaty.frame = frame
        self.view.addSubview(floaty)
    }
    
    func  showdefaultScreen() {
        let count = self.chatListViewModel.getNumberOfRows(isSearchActive: self.isSearchActive)
        if count == 0 {
            //            self.defaultScreenView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.height - 50)
            //            self.view.layoutIfNeeded()
            self.defaultScreenView.isHidden = false
            self.chatlbl.isHidden = false
            self.chatIcon.isHidden = false
        } else {
            self.chatlbl.isHidden = true
            self.chatIcon.isHidden = true
            self.defaultScreenView.isHidden = true
            //            self.defaultScreenView.frame.size.height = 0
            //            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK:- Buttons Action
    
    
    @IBAction func liveAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.live, bundle: nil)
        guard let onGoingStreamVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.OnGoingStreamVC) as? OnGoingStreamVC else{return}
        onGoingStreamVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(onGoingStreamVC, animated: true)
    }
    
    
    @IBAction func walletVcAtion(_ sender: Any) {
        Route.navigateToCoinWallet(navigationController:self.navigationController)
    }
    
    @IBAction func AddChatAction(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let secretChat = UIAlertAction(title: "Secret Chat".localized, style: .default) { (action) in
            let storyboard = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
            guard let favouritVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.FollowListViewController) as? FollowListViewController else {return}
            favouritVC.controllerPurpose = .createSecretChat
            self.navigationController?.pushViewController(favouritVC, animated: true)
            
        }
        let contact = UIAlertAction(title: "Single".localized + " " + "Chat".localized, style: .default) { (action) in
            let storyboard = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
            guard let favouritVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.FollowListViewController) as? FollowListViewController else {return}
            favouritVC.controllerPurpose = .createSingleChat
            self.navigationController?.pushViewController(favouritVC, animated: true)
            
        }
        let groupChat = UIAlertAction(title: "Group".localized + " " + "Chat".localized, style: .default) { (action) in
            let storyboard = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil)
            guard let favouritVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.FollowListViewController) as? FollowListViewController else {return}
            //            favouritVC.isGroup = true
            favouritVC.controllerPurpose = .createGroup
            self.navigationController?.pushViewController(favouritVC, animated: true)
        }
        
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel){ (action) in
        }
        alert.addAction(cancel)
        alert.addAction(secretChat)
        alert.addAction(contact)
        alert.addAction(groupChat)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK:- Button action
    @IBAction func profileButtonAction(_ sender: Any) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isSelf = true
        profileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
      
      //MARK:- Button action
         @IBAction func activityButtonAction(_ sender: Any) {
            let activityVc = ActivityViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Activity) as ActivityViewController
                activityVc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(activityVc, animated: true)
         }
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        
        let isNetwork = (UIApplication.shared.delegate as! AppDelegate).isNetworkThere
        
        if isNetwork == true{
            ChatAPI().getChats(withPageNo:"0", withCompletion: { response in
                print(response)
            })
            refreshButtonOutlet.isEnabled = false
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when ){
                self.refreshButtonOutlet.isEnabled = true
            }
        }else{
//            Helper.showAlertViewOnWindow("Error!", message: "Check your Internet connection")
        }
    }
    
    
    @IBAction func newChatCliked(_ sender: Any) {
        DDLogDebug("new chat cliked")
        self.tabBarController?.selectedIndex = 2
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //        NotificationCenter.default.addObserver(self, selector: #selector(changeTab(_:)), name: NSNotification.Name(rawValue: "changeTabbar"), object: nil)
        super.viewWillAppear(animated)
        if Utility.isDarkModeEnable(){
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .darkContent
        }
        self.navigationController?.navigationBar.layer.zPosition = 0;
         self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
        if #available(iOS 13.0, *) {
            self.tabBarController?.tabBar.backgroundColor = UIColor.systemBackground
            self.tabBarController?.tabBar.backgroundImage = UIImage.init(color: UIColor.systemBackground)
        } else {
            self.tabBarController?.tabBar.backgroundColor = UIColor.white
            self.tabBarController?.tabBar.backgroundImage = UIImage.init(color: UIColor.white)
            // Fallback on earlier versions
        }
        self.navigationItem.title = "Chats".localized
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.barTintColor = .systemBackground
        }
        self.chatlbl.text = "You have no active chats".localized
        socialViewModel.getVerificationStatus { (success, error) in
            if success {
                print("verification status recieved")
            }else{
                print(error)
            }
        }
        super.viewWillAppear(animated)
        MQTT.sharedInstance.createConnection()
        guard let userID = Utility.getUserid() else { return }
        //subscribe UserUpdate
        let updateSunc = AppConstants.MQTT.userUpdates + userID
        MQTT.sharedInstance.subscribeTopic(withTopicName: updateSunc, withDelivering: .atLeastOnce)
//        MQTT.sharedInstance.subscribeTopic(withTopicName: "call/\(self.callId!)", withDelivering: .atLeastOnce)
//
 
        self.isSearchActive = false
        self.searchBarOutlet.text = ""
        searchBarOutlet.placeholder = "Search".localized + " " + "people".localized + " " + "chat".localized
        self.getChatInitially()
        self.tabBarController?.tabBar.isHidden = false
        //        if let userImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String{
        //            self.profileImageView.setImageOn(imageUrl: userImage, defaultImage:#imageLiteral(resourceName: "defaultImage"))
        //        }else{
        //            self.profileImageView.image = #imageLiteral(resourceName: "defaultImage")
        //        }
        
        
        let isNetwork = (UIApplication.shared.delegate as? AppDelegate)?.isNetworkThere
        if isNetwork == true{
            if AppConstants.appType == .dubly {
                self.socialViewModel.myStoryOffset = -20
                self.socialViewModel.otherStoryOffset = -20
                self.getMyStoryService()
                self.getOtherStoryService()
            }
            self.getUserProfile()
        }
       
        
        
        
    }
    
  
    
    func getUserProfile(){
        let profileViewModel = ProfileViewModel()
        profileViewModel.isSelf = true
        let strUrl: String = AppConstants.userProfile
        profileViewModel.userDetailsService(strUrl: strUrl, params: [:]) { (success, error, canServiceCall) in
            if success{
                
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableViewOutlet.setEditing(editing, animated: animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.chatSegueIdentifier {
            let controller = segue.destination as! ChatViewController
            controller.chatListIndexPath = self.selfIndexPath
            if let chatObj = sender as? Chat {
                let chatVMObject = ChatViewModel(withChatData: chatObj)
                controller.chatViewModelObj = chatVMObject
            } else if let userID = sender as? String {
                if let favObj = FavoriteViewModel.sharedInstance.getContactObject(forUserID: userID) {
                    controller.favoriteObj = favObj
                }
            }
        }
    }
    
    
    //MARK: - Other Methodes
    func checkNewGroupCreated(){
        self.updateChatList()
        if let storeKey = UserDefaults.standard.object(forKey: "isCreatingNewGroupPress") as? [String:Any] {
            if  storeKey["isCreated"] as! Bool == true{
                var index:Int? = 0
                if let doccId = storeKey["docId"] as? String {
                    index =  self.chatListViewModel.chats.index(where: {
                        $0.docID == doccId
                    })
                }
                self.tableViewOutlet.selectRow(at: IndexPath.init(row: index ?? 0, section: 0), animated: false, scrollPosition: .none)
                self.tableView(self.tableViewOutlet, didSelectRowAt: IndexPath.init(row: 0, section: 0))
                UserDefaults.standard.removeObject(forKey: "isCreatingNewGroupPress")
            }
        }
    }
    
    
    
    
    func getMyStoryService(){
        let strUrl = AppConstants.myStory
        socialViewModel.storyServiceCall(strUrl: strUrl, storyType: .myStory) { [weak self] (success, error) in
            //            if success{
            DispatchQueue.main.async {
                self?.chatStoriesCollectionView.reloadData()
            }
        }
    }
    
    func getOtherStoryService(){
        let strUrl = AppConstants.story
        socialViewModel.storyServiceCall(strUrl: strUrl, storyType: .otherStory) { [weak self] (success, error) in
            //            print("success")
            DispatchQueue.main.async {
                self?.chatStoriesCollectionView.reloadData()
            }
        }
    }
    
    
    
}

extension ChatsListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.chatListViewModel.setUpTableViewCell(indexPath: indexPath, tableView: tableView, isSearchActive: self.isSearchActive)
        if  self.chatListViewModel.chats.count > indexPath.row {
            let dataObject = self.chatListViewModel.chats[indexPath.row]
            let chatVMObj = ChatViewModel(withChatData: dataObject)
            if !chatVMObj.isGroupChat {
//                if chatVMObj.name == "" {
//                    self.chatListViewModel.deleteRow(fromIndexPath: indexPath, isSearchActive: self.isSearchActive, success: { response in
//                        self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
//                        tableView.deleteRows(at: [indexPath], with:.none)
//                        tableView.endUpdates()
//                        self.showdefaultScreen()
//                        tableView.reloadData()
//                        Helper.hidePI()
//                    }, failure: { error in
//                        Helper.hidePI()
//                        self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
//                        tableView.deleteRows(at: [indexPath], with:.none)
//                        tableView.endUpdates()
//                    })
//                }
        }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.chatListViewModel else {return 0}
        return viewModel.getNumberOfRows(isSearchActive: self.isSearchActive)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 
//            if  self.chatListViewModel.chats.count > indexPath.row {
//            let dataObject = self.chatListViewModel.chats[indexPath.row]
//            let chatVMObj = ChatViewModel(withChatData: dataObject)
//            if !chatVMObj.isGroupChat {
//                if chatVMObj.name == "" {
//                    return 0
//                }else {
//                    return 80
//                }
//            }else {
//                    return 80
//            }
//        }
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var chatObj: Chat?
        selfIndexPath = indexPath
        if self.isSearchActive{
            if indexPath.row < self.chatListViewModel.searchedChats.count{
                chatObj = self.chatListViewModel.searchedChats[indexPath.row]
            }else{
                let data = self.chatListViewModel.searchedMessageArray[indexPath.row - self.chatListViewModel.searchedChats.count]
                chatObj = data["chatViewModel"] as? Chat
            }
        }else{
            chatObj = self.chatListViewModel.chats[indexPath.row]
        }
        self.performSegue(withIdentifier: Constants.chatSegueIdentifier, sender: chatObj!)
        //        self.chatTabVC?.performSegue(withIdentifier: Constants.chatSegueIdentifier, sender: chatObj)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var dataObject: Chat?
        if isSearchActive{
            if self.chatListViewModel.searchedChats.count > indexPath.row {
                dataObject = self.chatListViewModel.searchedChats[indexPath.row]
            }
            
        }else{
            dataObject = self.chatListViewModel.chats[indexPath.row]
        }
        if dataObject != nil {
            let chatVMObj = ChatViewModel(withChatData: dataObject!)
            if chatVMObj.isGroupChat{
                return true
            }
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            //1 delete locally
            tableView.beginUpdates()
            
            let dataObject = self.chatListViewModel.chats[indexPath.row]
            let chatVMObj = ChatViewModel(withChatData: dataObject)
            if chatVMObj.isGroupChat {
                if chatVMObj.gpMessageType == "6" {
                    Helper.showPI(_message: "Deleting".localized + "...")
                    self.chatListViewModel.deleteRow(fromIndexPath: indexPath, isSearchActive: self.isSearchActive, success: { response in
                        self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
                        tableView.deleteRows(at: [indexPath], with:.none)
                        tableView.endUpdates()
                        self.showdefaultScreen()
                        tableView.reloadData()
                        Helper.hidePI()
                    }, failure: { error in
                        Helper.hidePI()
                        self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
                        tableView.deleteRows(at: [indexPath], with:.none)
                        tableView.endUpdates()
                    })
                }else {
                    Helper.showAlertViewOnWindow("", message: "You cannot delete the group".localized + ".")
                    tableView.endUpdates()
                }
            } else {
                Helper.showPI(_message: "Deleting".localized + "...")
                self.chatListViewModel.deleteRow(fromIndexPath: indexPath, isSearchActive: self.isSearchActive, success: { response in
                    self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
                    tableView.deleteRows(at: [indexPath], with:.none)
                    tableView.endUpdates()
                    self.showdefaultScreen()
                    tableView.reloadData()
                    Helper.hidePI()
                }, failure: { error in
                    Helper.hidePI()
                    self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
                    tableView.deleteRows(at: [indexPath], with:.none)
                    tableView.endUpdates()
                })
            }

        }
    }
    
    @objc func deleteChat(_ notification: NSNotification) {
        if let indexPath =  notification.object as? IndexPath {
            let dataObject = self.chatListViewModel.chats[indexPath.row]
        let chatVMObj = ChatViewModel(withChatData: dataObject)
        if chatVMObj.isGroupChat {
            if chatVMObj.gpMessageType == "6" {
                Helper.showPI(_message: "Deleting".localized + "...")
                self.chatListViewModel.deleteRow(fromIndexPath: indexPath, isSearchActive: self.isSearchActive, success: { response in
                    self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
                    self.tableViewOutlet.deleteRows(at: [indexPath], with:.none)
                    self.tableViewOutlet.endUpdates()
                    self.showdefaultScreen()
                    self.tableViewOutlet.reloadData()
                    Helper.hidePI()
                }, failure: { error in
                    Helper.hidePI()
                    self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
                    self.tableViewOutlet.deleteRows(at: [indexPath], with:.none)
                    self.tableViewOutlet.endUpdates()
                })
            }else {
                Helper.showAlertViewOnWindow("", message: "You cannot delete the group".localized + ".")
                self.tableViewOutlet.endUpdates()
            }
        } else {
            Helper.showPI(_message: "Deleting".localized + "...")
            self.chatListViewModel.deleteRow(fromIndexPath: indexPath, isSearchActive: self.isSearchActive, success: { response in
                self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
                self.tableViewOutlet.deleteRows(at: [indexPath], with:.none)
                self.tableViewOutlet.endUpdates()
                self.showdefaultScreen()
                self.tableViewOutlet.reloadData()
                Helper.hidePI()
            }, failure: { error in
                Helper.hidePI()
                self.chatListViewModel.deleteChat(fromIndexPath: indexPath, isSearchActive: self.isSearchActive)
                self.tableViewOutlet.deleteRows(at: [indexPath], with:.none)
                self.tableViewOutlet.endUpdates()
            })
        }
    }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ChatsListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.socialViewModel.myStories.userStories.count > 0{
                return 2
            }else{
                return 1
            }
        case 1:
            return self.socialViewModel.recentStories.count
        case 2:
            return self.socialViewModel.viewedStories.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let storyCell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConstants.CellIds.ChatStoryListsCollectionViewCell, for: indexPath) as? ChatStoryListsCollectionViewCell else{fatalError()}
        if indexPath.section == 0{
            //check user has stores or not.
            if(indexPath.item == 0) {
                    if let userImageUrl = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String {
                        Helper.addedUserImage(profilePic: userImageUrl, imageView: storyCell.storyImageView, fullName: Utility.getUserFullName() ?? "P")
                    }else {
                        Helper.addedUserImage(profilePic: nil, imageView: storyCell.storyImageView, fullName: Utility.getUserFullName() ?? "P")
                    }
                
                storyCell.userNameLabel.text = "You".localized
            } else {
                //user has stories. so display last story image and time details.
                let allStories = self.socialViewModel.myStories.userStories
                let lastStory = allStories.last
                storyCell.storyImageView.setImageOn(imageUrl: lastStory?.thumbNailUrl, defaultImage:#imageLiteral(resourceName: "defaultPicture"))
                storyCell.userNameLabel.text = "My Story".localized
            }
        }else{
            let respStory:userStory
            if indexPath.section == 1 {
                respStory = self.socialViewModel.recentStories[indexPath.row]
            } else {
                respStory = self.socialViewModel.viewedStories[indexPath.row]
            }
            let recentStory = respStory.userStories.last
            storyCell.userNameLabel.text = respStory.userName
            storyCell.storyImageView.setImageOn(imageUrl: recentStory?.thumbNailUrl, defaultImage:#imageLiteral(resourceName: "defaultPicture"))
        }
        return storyCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 77 , height: 80)
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    //    }
    
    
}


//MARK:- Chat list Stories Collection View cell Delegate
extension ChatsListViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if(indexPath.item == 0) {
                //there is no stories avialble.
                if self.socialViewModel.myStories.userStories.count  == 0{
                    self.openCamera()
                }else{
                    self.openMyStories()
                }
            } else {
                self.openStoriesScreenWithStories(stories: [self.socialViewModel.myStories], isMystory: true, openAtIndex: 0)
            }
            break
        case 1:
            openOthersRecentStories(openAtIndex:indexPath.row)
            break
        default:
            openOthersVieWedStories(openAtIndex:indexPath.row)
            break
        }
    }
    
    func openStoryCamera(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Add to Your Story".localized, style: .default) { (action) in
            DispatchQueue.main.async {
                self.openCamera()
            }
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancel)
        DispatchQueue.main.async {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    
    func openCamera() {
        Route.navigateToCamera(navigationController:self.navigationController, isPresent:true,isForStory : true,color : UIColor.white)
    }
    
    func openMyStories() {
        //open stories.
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        guard let myStoriesVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.StoryListViewController) as? StoryListViewController else {return}
        myStoriesVC.myStories = self.socialViewModel.myStories
        self.navigationController?.pushViewController(myStoriesVC, animated: true)
        
    }
    
    func openOthersRecentStories(openAtIndex:Int) {
        //open stories.
        openStoriesScreenWithStories(stories:self.socialViewModel.recentStories,isMystory:false, openAtIndex:openAtIndex)
    }
    
    func openOthersVieWedStories(openAtIndex:Int) {
        //open stories.
        openStoriesScreenWithStories(stories:self.socialViewModel.viewedStories,isMystory:false, openAtIndex:openAtIndex)
    }
    
    func openStoriesScreenWithStories(stories:[userStory],isMystory:Bool,openAtIndex:Int) {
        let viewStoryVc = ViewStoryViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Main) as ViewStoryViewController
        viewStoryVc.allStories = stories
        viewStoryVc.jumpToIndex = openAtIndex
        viewStoryVc.isFromSocialView = true
        viewStoryVc.isMyStory = isMystory
        viewStoryVc.modalPresentationStyle = .overFullScreen
        self.present(viewStoryVc, animated: true, completion:nil)
    }
}

extension ChatsListViewController : MQTTManagerDelegate{
    func receivedMessage(_ message: [AnyHashable : Any], andChannel channel: String!) {
        print(message)
        let storyboard = UIStoryboard(name: "CallKit", bundle: nil)
        if let data = message["data"] as? [String : Any]{
            if let room = data["room"] as? String, let callId = data["callId"] as? String, let action = data["action"] as? Int, action == 1, let calltype = data["type"] as? String{
//                guard let callVC = storyboard.instantiateViewController(withIdentifier: String(describing:CallViewController.self)) as? CallViewController else { return }
//                callVC.viewModel.room = Int64(room)
//                callVC.viewModel.callId = callId
//                callVC.showIncomingCall = true
//                callVC.userData = data
//                callVC.callType = calltype == "audio" ? .Audio : .Video
//                callVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(callVC, animated: true)
            }
        }
    }
}
