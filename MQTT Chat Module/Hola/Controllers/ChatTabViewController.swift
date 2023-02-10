//
//  ChatTabViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 20/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher


class ChatTabViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var chatButtonOutlet: UIButton!
    @IBOutlet weak var storiesButtonOutlet: UIButton!
    @IBOutlet weak var callsButtonOutlet: UIButton!
    @IBOutlet weak var scrollableViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chatCountLabel: UILabel!
    @IBOutlet weak var chatCountHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var storyTableView: UITableView!
    
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    let storyAPIObj = StoryAPI()
    @IBOutlet weak var createChatButtonOutlet: UIButton!
    @IBOutlet weak var createStorieButtonOutlet: UIButton!
    @IBOutlet weak var createCallButtonOutlet: UIButton!
    
    var chatListVC: ChatsListViewController?
    var callVC: CallHistoryTableViewController?
    
    var isChatList: Bool = false
    var isStories: Bool = false
    var isCalls: Bool = false
    
    var myStories:userStory = userStory(storiesDetails:[:])
    var recentStories:[userStory] = []
    var viewedStories:[userStory] = []
    
    
    
    struct storyboardId {
        static let favouritViewController = "favouritViewController"
        static let callHistoryViewController = "callHistoryViewController"
        static let chatListViewController = "chatListViewController"
        static let chatSegueIdentifier = "segueToChatViewController"
        static let callHistoryTouserdetails = "callHistoryTouserdetails"
    }
    
    
    @IBAction func storyMoreButtonAction(_ sender: Any) {
        
        guard let myStoriesVC = self.storyboard?.instantiateViewController(withIdentifier:"StoryListViewController") as? StoryListViewController else {return}
        myStoriesVC.myStories = self.myStories
        self.navigationController?.pushViewController(myStoriesVC, animated: true)
    }
    
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        setViewUI()
        self.mainScrollView.touchesShouldCancel(in: (self.chatListVC?.tableViewOutlet)!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMystories(notification:)), name:NSNotification.Name(rawValue:"updateMyStories"), object: nil)
        let name = NSNotification.Name(rawValue: "ChatUpdatedNotification")
        NotificationCenter.default.setObserver(self, selector: #selector(ChatTabViewController.updateChatListCount), name: name, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateMystories(notification: NSNotification) {
        if let updatedStories = notification.object as? userStory {
            self.myStories = updatedStories
            self.storyTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let userImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImageForChats) as? String{
            self.profileImageView.setImageOn(imageUrl: userImage, defaultImage:#imageLiteral(resourceName: "defaultImage"))
        }else{
            self.profileImageView.image = #imageLiteral(resourceName: "defaultImage")
        }
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //refresh chat screen
        self.chatListVC?.updateChatList()
        self.chatListVC?.getChatInitially()
        
        self.chatListVC?.showdefaultScreen()
        self.chatListVC?.tableViewOutlet.reloadData()
        if let tabbar = self.tabBarController as? TabbarController {
            tabbar.enablePushNotification()
        }
        self.chatListVC?.checkNewGroupCreated()
        
        //refresh call screen
        self.callVC?.refreshCallScreeen()
        
        getAllStories()
        getMyStories()
        self.updateChatListCount()
    }

    @objc func updateChatListCount() {
        let count = self.chatListVC?.chatListViewModel.unreadChatsCounts()
        if count == 0 {
            self.chatCountLabel.text = ""
            self.chatCountHeightConstraint.constant = 0.0
        } else {
            guard let cnt = count else{return}
            self.chatCountLabel.text = "\(String(describing: cnt))"
            self.chatCountHeightConstraint.constant = 20.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setViewUI(){
        
//        guard let chatListVC = self.storyboard?.instantiateViewController(withIdentifier: storyboardId.chatListViewController) as? ChatsListViewController else {return}
//        self.chatListVC = chatListVC
//        self.chatListVC?.chatTabVC = self
//        let chatListView = self.view.viewWithTag(10)
//        chatListVC.view.frame = CGRect(x: 0, y: 0, width: (chatListView?.frame.size.width)!, height: (chatListView?.frame.size.height)!)
//        chatListView?.addSubview(chatListVC.view)
//        chatListView?.bringSubview(toFront: self.createChatButtonOutlet)
//        chatListVC.didMove(toParentViewController: self)

        
//        guard let callVC = self.storyboard?.instantiateViewController(withIdentifier: storyboardId.callHistoryViewController) as? CallHistoryTableViewController else {return}
//        self.callVC = callVC
//        self.callVC?.chatTabVC = self
//        let callView = self.view.viewWithTag(12)
//        callVC.view.frame = CGRect(x: 0, y: 0, width: (callView?.frame.size.width)!, height: (callView?.frame.size.height)!)
//        callView?.addSubview(callVC.view)
//        callView?.bringSubview(toFront: self.createCallButtonOutlet)
//        callVC.didMove(toParentViewController: self)
        
        
        self.profileImageView.makeCornerRadious(readious: self.profileImageView.frame.size.width / 2)
        self.chatCountLabel.makeCornerRadious(readious: 10.0)
    }

    //MARK:- Buttons Action
    @IBAction func chatButtonAction(_ sender: Any) {
        self.setSelectedButton(index: 0)
    }
    
    @IBAction func storiesButtonAction(_ sender: Any) {
        self.setSelectedButton(index: 1)
    }
    
    @IBAction func callButtonAction(_ sender: Any) {
        self.setSelectedButton(index: 2)
    }
    
    
    @IBAction func storyTextButtonAction(_ sender: Any) {
        let viewStoryVc = self.storyboard?.instantiateViewController(withIdentifier:"TextStoryViewController") as! TextStoryViewController
        self.present(viewStoryVc, animated: true, completion:nil)
    }
    
    
    @IBAction func createChatAction(_ sender: Any) {
        
    }
    
    @IBAction func createStorieAction(_ sender: Any) {
        openCamera()
    }
    
    func openMyStories() {
        //open stories.
        openStoriesScreenWithStories(stories:[myStories],isMystory:true, openAtIndex:0)
    }
    
    func openOthersRecentStories(openAtIndex:Int) {
        //open stories.
        openStoriesScreenWithStories(stories:recentStories,isMystory:false, openAtIndex:openAtIndex)
    }
    
    func openOthersVieWedStories(openAtIndex:Int) {
        //open stories.
        openStoriesScreenWithStories(stories:viewedStories,isMystory:false, openAtIndex:openAtIndex)
    }
    
    func openStoriesScreenWithStories(stories:[userStory],isMystory:Bool,openAtIndex:Int) {
        let viewStoryVc = ViewStoryViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Main) as ViewStoryViewController
        viewStoryVc.allStories = stories
        viewStoryVc.jumpToIndex = openAtIndex
        viewStoryVc.isMyStory = isMystory
        viewStoryVc.modalPresentationStyle = .fullScreen
        self.present(viewStoryVc, animated: true, completion:nil)
    }
    
    
    
    
    func getAllStories(){
        storyAPIObj.getAllStories(withURL: AppConstants.story) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.recentStories.removeAll()
                self.viewedStories.removeAll()
                if result.count > 0 {
                    for singleUserStory in result {
                        let user = userStory.init(storiesDetails:singleUserStory as! [String : Any])
                        if user.hasNewStroy {
                            self.recentStories.append(user)
                        } else {
                             self.viewedStories.append(user)
                        }
                    }
             
                    self.recentStories = self.recentStories.sorted(by: {$0.lastStoryTimeStamp > $1.lastStoryTimeStamp})
                    
                    self.viewedStories = self.viewedStories.sorted(by: {$0.lastStoryTimeStamp > $1.lastStoryTimeStamp})
                    
                }
                self.storyTableView.reloadData()
            }
            if error != nil{
                
            }
            Helper.hidePI()
        }
    }
    
    
    func getMyStories() {
        storyAPIObj.getAllStories(withURL: AppConstants.myStory) { (response, error) in
            if let result = response as? [Any] {
                if result.count > 0 {
                    if let dic = result[0] as? [String:Any] {
                        if let allStories = dic["posts"] as? [[String:Any]] {
                            print(allStories)
                            self.myStories = userStory.init(storiesDetails:dic)
                        }
                    }
                }
                self.storyTableView.reloadData()
            } else if let error = error{
                print(error)
            }
            Helper.hidePI()
        }
    }
    
    func openCamera() {
        Route.navigateToCamera(navigationController:self.navigationController, isPresent:true,isForStory : true,color : UIColor.white)
    }
    
    @IBAction func createCallAction(_ sender: Any) {
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == storyboardId.chatSegueIdentifier {
            let controller = segue.destination as! ChatViewController
            if let chatObj = sender as? Chat {
                let chatVMObject = ChatViewModel(withChatData: chatObj)
                controller.chatViewModelObj = chatVMObject
            } else if let userID = sender as? String {
                if let favObj = FavoriteViewModel.sharedInstance.getContactObject(forUserID: userID) {
                    controller.favoriteObj = favObj
                }
            }
        }else if segue.identifier == storyboardId.callHistoryTouserdetails{
            
            let contactINfo = segue.destination as? ContactInfoTableViewController
            let couchbaseObj = Couchbase.sharedInstance
            contactINfo?.isComingFromHistory = true
            contactINfo?.chatsDocVMObject = ChatsDocumentViewModel.init(couchbase: couchbaseObj)
            
            let data = sender as! [String:Any]
            guard  let  otherUserNum =  data["opponentNumber"] as? String else { return }
//            let predicate = NSPredicate.init(format:"registerNum == %@", otherUserNum)
//            guard let favAr =  self.callVC?.favArr.filter({predicate.evaluate(with: $0)}) else{return}
            guard let callViewController = self.callVC else{return}
            let favAr = callViewController.favArr.filter { (member) -> Bool in
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
                if let chatDocID =  self.callVC?.getChatdocIdforunsavedUser(reciverID:otheruserID ,receiverNumber: otherUserNum ){
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
 

}


extension ChatTabViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.mainScrollView{
            let offset = scrollView.contentOffset
            self.scrollableViewLeadingConstraint.constant = scrollView.contentOffset.x / 3
            if offset.x < (self.view.frame.size.width * 3) / 4{
                ///select chat selected and storie and call deselect
                self.chatButtonOutlet.isSelected = true
                self.storiesButtonOutlet.isSelected = false
                self.callsButtonOutlet.isSelected = false
            }else if offset.x >= (self.view.frame.size.width * 3) / 4 && offset.x < (self.view.frame.size.width * 5) / 4{
                ///select stories selected and chat and call deselect
                self.chatButtonOutlet.isSelected = false
                self.storiesButtonOutlet.isSelected = true
                self.callsButtonOutlet.isSelected = false
            }else{
                ///select call selected and chat and stories deselect
                self.chatButtonOutlet.isSelected = false
                self.storiesButtonOutlet.isSelected = false
                self.callsButtonOutlet.isSelected = true
            }
            scrollView.contentOffset = offset
        }
    }
    
    /// To move frame according to selected button (0 for chat, 1 for stories and 2 for call)
    ///
    /// - Parameter index: selected button number
    func setSelectedButton(index: Int8){
        var frame = self.mainScrollView.bounds
        switch index {
        case 0:
            frame.origin.x = 0.0
            break
        case 1:
            frame.origin.x = self.view.frame.size.width
            break
        case 2:
            frame.origin.x = self.view.frame.size.width * 2
            break
        default: break
        }
        self.mainScrollView.scrollRectToVisible(frame, animated: true)
    }
}


extension ChatTabViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 1
        } else if(section == 1) {
            return self.recentStories.count
        } else {
            return self.viewedStories.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 0
        } else {
            if section == 1 {
                if !recentStories.isEmpty {
                   return 40
                }
            } else {
                if !viewedStories.isEmpty {
                    return 40
                }
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return ""
        } else if(section == 1) {
            return "Recent updates"
        } else {
            return "Viewed updates"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let storyCell = tableView.dequeueReusableCell(withIdentifier:"StoryTableViewCell") as! StoryTableViewCell
        var numberOfStories = 0
        var userAllStories:[StoryModel]?
        if(indexPath.section == 0) {
            //check user has stores or not.
            storyCell.nameLabel.text = "My story"
            if(myStories.userStories.count == 0) {
                //user has no stories.
                //so display user profile picture and add status message.
                storyCell.addStatusButton.isHidden = false
                storyCell.moreButtonOutlet.isHidden = true
                storyCell.lastStatusTime.text = "Tap to add story update"
                storyCell.lastStatusImage.setImageOn(imageUrl: myStories.userProfilePicture, defaultImage:#imageLiteral(resourceName: "defaultImage"))
                
            } else {
                //user has stories. so display last story image and time details.
                storyCell.addStatusButton.isHidden = true
                storyCell.moreButtonOutlet.isHidden = false
                
                let allStories = myStories.userStories
                userAllStories = allStories
                let lastStory = allStories.last
                if let timeStamp = lastStory?.createdOn {
                    let date = Date(timeIntervalSince1970:timeStamp)
                    storyCell.lastStatusTime.text = Date().offsetFrom(date:date)
                }
                
                storyCell.lastStatusImage.setImageOn(imageUrl: lastStory?.thumbNailUrl, defaultImage:#imageLiteral(resourceName: "defaultImage"))
            }
            numberOfStories = myStories.userStories.count
        } else {
            storyCell.addStatusButton.isHidden = true
            storyCell.moreButtonOutlet.isHidden = true
            
            let respStory:userStory
            if indexPath.section == 1 {
                respStory = recentStories[indexPath.row]
            } else {
                respStory = viewedStories[indexPath.row]
            }
            
            let recentStory = respStory.userStories.last
            storyCell.nameLabel.text = respStory.userName
            storyCell.lastStatusImage.setImageOn(imageUrl: recentStory?.thumbNailUrl, defaultImage:#imageLiteral(resourceName: "defaultImage"))
            if let timeStamp = recentStory?.createdOn {
                let date = Date(timeIntervalSince1970:timeStamp)
                storyCell.lastStatusTime.text = Date().offsetFrom(date:date)
            }
            numberOfStories = respStory.userStories.count
            userAllStories = respStory.userStories
        }
 
        for eachSubLayer in (storyCell.viewForLastImage.layer.sublayers?.enumerated())! {
            if let type = eachSubLayer.element as? CAShapeLayer {
                type.removeFromSuperlayer()
            }
        }

        if numberOfStories != 0 {
            
            if numberOfStories == 1 {
                storyCell.viewForLastImage.layer.borderWidth = 2.0
                let isViewed = userAllStories![0].viewed
                if isViewed {
                    storyCell.viewForLastImage.layer.borderColor = UIColor.lightGray.cgColor
                } else {
                    if storyCell.nameLabel.text == "My story"  {
                        storyCell.viewForLastImage.layer.borderColor = UIColor.lightGray.cgColor
                    } else {
                        storyCell.viewForLastImage.layer.borderColor =
                            Helper.hexStringToUIColor(hex:"#9C4CFE").cgColor
                    }
                }
                
            } else {
                var frameForCircular = storyCell.viewForLastImage.frame
                frameForCircular.origin.x = 0
                frameForCircular.origin.y = 0
                frameForCircular.size.width = frameForCircular.size.width
                frameForCircular.size.height = frameForCircular.size.height
                
                let circlePath = UIBezierPath(ovalIn:frameForCircular)
                var segments: [CAShapeLayer] = []
                let numbDouble = Double(numberOfStories)
                let angle:Double = Double(1.0/numbDouble)
                
                let segmentAngle: CGFloat = CGFloat((360 * angle) / 360)
                
                 storyCell.viewForLastImage.layer.borderColor = UIColor.clear.cgColor
                
                for i in 0..<numberOfStories {
                    let circleLayer = CAShapeLayer()
                    circleLayer.path = circlePath.cgPath
                    
                    circleLayer.frame = CGRect(x: 0, y:0, width: storyCell.viewForLastImage.frame.size.width, height: storyCell.viewForLastImage.frame.size.width)
                    // start angle is number of segments * the segment angle
                    circleLayer.strokeStart = segmentAngle * CGFloat(i)
                    
                    // end angle is the start plus one segment, minus a little to make a gap
                    // you'll have to play with this value to get it to look right at the size you need
                    let gapSize: CGFloat = 0.01
                    circleLayer.strokeEnd =
                        circleLayer.strokeStart + segmentAngle - gapSize
                    
                    circleLayer.lineWidth = 4
                    
                    let isViewed = userAllStories![i].viewed
                    
                    if isViewed{
                        circleLayer.strokeColor = UIColor.lightGray.cgColor
                    } else {
                        if storyCell.nameLabel.text != "My story" {
                            circleLayer.strokeColor = Helper.hexStringToUIColor(hex:"#9C4CFE").cgColor
                        } else {
                            circleLayer.strokeColor = UIColor.lightGray.cgColor
                        }
                    }
                    
                    circleLayer.fillColor = UIColor.clear.cgColor
                    
                    // add the segment to the segments array and to the view
                    segments.insert(circleLayer, at: i)
                    storyCell.viewForLastImage.layer.addSublayer(segments[i])
                }
            }
        }
        return storyCell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0) {
            if(myStories.userStories.count == 0) {
                //there is no stories avialble.
                //so allow to add new story.
                self.openCamera()
            } else {
                self.openMyStories()
            }
        } else if(indexPath.section == 1) {
            openOthersRecentStories(openAtIndex:indexPath.row)
        } else {
            openOthersVieWedStories(openAtIndex:indexPath.row)
        }
    }
}
