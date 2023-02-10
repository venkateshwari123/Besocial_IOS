//
//  FollowViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//
import UIKit
import DGElasticPullToRefresh

enum DublyFollowListType {
    case followeesView
    case followersView
    case likeListView
    case viewListView
    case subscribersList
}
protocol DublyFollowViewControllerDelegate: class {
    func followDataChanged()
}
class DublyFollowViewController: UIViewController {
    
    /// All Outlets
    @IBOutlet weak var followTableView: UITableView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var viewTitleLabe: UILabel!
    @IBOutlet weak var noFollowView: UIView!
    @IBOutlet weak var noFollowLabel: UILabel!
    @IBOutlet weak var noFollowImageview: UIImageView!
    @IBOutlet weak var followSearchBar: UISearchBar!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var likesTabTitle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var viewsCount: UILabel!
    /// variables and declarations
    var removeSymbol = ""
    var isSearchActive: Bool = false
    var searchText: String = ""
    let followViewModel = FollowViewModel()
    var canServiceCall: Bool = false
    var isSelf : Bool = false
    //    var isFollowers: Bool = false
    var viewTitle: String?
    var followListType: DublyFollowListType = .followersView
    var postOrUserId: String?
    var isChanged: Bool = false
    var delegate: DublyFollowViewControllerDelegate?
    var userId:String?
    var isFromHome = false
    var isCommentsTabSelected = false
    var isLikesTabSelected = false
    var callBack : ((Bool)->())?

    
    //Comments
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var inputToolBar: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var emptyViewBottomContraint: NSLayoutConstraint!
      @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentsTabTitle: UILabel!
    @IBOutlet weak var SearcheViewHeightContraint: NSLayoutConstraint!
     @IBOutlet weak var searchTableView: UITableView!

    var commentsViewModel = CommentsViewModel()
    var postIndex : Int = 0
    var ipAddress:String = ""
    var city:String = ""
    var country: String = ""
    var checkingText:String = ""
    var isTextViewActive: Bool = false
    var data : SocialModel?
    var updateCommentsCount : ((Int)->())?
    var isSearchPeople = false
    var doneToolbar = UIToolbar()
    

    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtonOnKeyboard()
        
        if isFromHome{
            if isLikesTabSelected{
                isLikesTabSelected = true
                isCommentsTabSelected = false
                self.setupLikesSection()
                self.commentServiceCall()
            }
            else{
                isLikesTabSelected = false
                isCommentsTabSelected = true
                self.setupCommentsSection()
                self.followViewModel.offset = -40
                self.followViewModel.followModelArray.removeAll()
                followServiceCall("")
                SearcheViewHeightContraint.constant = 0
            }
            if let postData = data{
                likesCount.text = "\(postData.likesCount)"
                commentsCount.text = "\(postData.commentCount)"
                 userName.text = postData.userName
                userName.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
                viewsCount.textColor = UIColor.setColor(lightMode: AppColourStr.lightGray, darkMode: AppColourStr.whiteColor)
                 /*
                 Bug Name :- view count on post and comment details page is different
                 Fix Date :- 23/05/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- Showing distinct count instead of total count
                 */
                if postData.distinctView == 1 {
                    viewsCount.text = "\(postData.distinctView) " + "View".localized
                }else{
                    viewsCount.text = "\(postData.distinctView) " + "Views".localized
                }
                
                if postData.isPaid{
                    self.inputToolBar.isHidden = true
                }
            }
            commentsTabTitle.text = "Comments".localized
            likesTabTitle.text = "Likes".localized
            textView.text = "Write a comment".localized + "..."
            if Utility.isDarkModeEnable(){
                textView.textColor = .white
            }else{
                textView.textColor = .lightGray
            }
            
            self.followSearchBar.placeholder = Strings.searchPeople.localized
            self.navigationController?.navigationBar.isHidden = true
            if let image = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String{
                     self.userImageView.setImageOn(imageUrl: image, defaultImage: #imageLiteral(resourceName: "defaultImage"))
                 }
            self.userImageView.makeCornerRadious(readious: userImageView.frame.size.width / 2)
            
//            let pullToClose = PullToDismiss.init(scrollView: self.followTableView, viewController: self)
//            pullToClose.delegate = self
        }
        else{
            
            self.setSearchBarPlaceholder()
        }
        
        
        
        
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        followTableView.tintColor = UIColor.white
        followTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            self?.followViewModel.offset = -40
            self?.followServiceCall("")
            }, loadingView: loadingView)
        followTableView.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        followTableView.dg_setPullToRefreshBackgroundColor(followTableView.backgroundColor!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /*
         Bug Name:- toast not appear sometime
         Fix Date:- 16/04/21
         Fix By  :- Nikunj C
         Description of Fix:- refactor extra code
         */
        Helper.checkConnectionAvaibility(view: self.view)
        
    }
    
    // Adding Done Button Function
    func addDoneButtonOnKeyboard(){
        doneToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: Strings.done.localized, style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        if followSearchBar != nil  {
            followSearchBar.inputAccessoryView = doneToolbar
        }
        if textView != nil {
            textView.inputAccessoryView = doneToolbar

        }
        
    }
    @objc func doneButtonAction(){
        followSearchBar.resignFirstResponder()
        textView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        if isFromHome{
            self.addObserver()
            self.followViewModel.offset = -40
            self.followViewModel.followModelArray.removeAll()
            followServiceCall("")
            self.navigationController?.navigationBar.isHidden = true
        }else{
//            self.viewTitleLabe.text = viewTitle != nil ? viewTitle! : ""
            self.followViewModel.offset = -40
            self.followViewModel.followModelArray.removeAll()
            followServiceCall("")
            self.navigationController?.navigationBar.layer.zPosition = 0;
            self.navigationController?.navigationBar.isHidden = false
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: viewTitle ?? "")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserver()
    }
    
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        if isFromHome, let closure = self.callBack{
            closure(true)
            }
         self.dismiss(animated: true, completion: nil)
     }
    

    
    
    
    /// setting no follow view
    private func setNoFollowView(){
        if self.followViewModel.followModelArray.count == 0  {
            switch self.followListType{
            case .followersView:
                self.noFollowImageview.image = UIImage(named: Strings.ImageNames.followers.localized)
                self.noFollowLabel.text = Strings.noUserIsFollowing.localized
                self.noFollowView.isHidden = false
                break
            case .followeesView:
                self.noFollowImageview.image = UIImage(named: Strings.ImageNames.following.localized)
                self.noFollowLabel.text = Strings.yourNotFollowingAnyUser.localized
                self.noFollowView.isHidden = false
                break
            case .likeListView:
                if isLikesTabSelected{
                self.setNoLikesView()
                }
            /*
            Bug Name:- need placeholder for no subscribers
            Fix Date:- 31/03/21
            Fixed By:- Nikunj C
            Description of Fix:- add subscribersList type
            */
                
            case .subscribersList:
                self.noFollowImageview.image = UIImage(named: "NoSubscription")
                self.noFollowLabel.text = Strings.notHaveSubscriber.localized
                self.noFollowView.isHidden = false
                break
            /*
            Bug Name:- no viewers UI issue
            Fix Date:- 05/05/21
            Fixed By:- Nikunj C
            Description of Fix:- add switch case
            */
            case .viewListView:
                self.noFollowImageview.image = UIImage(named: "NoViewers")
                self.noFollowLabel.text = Strings.notHaveViewer.localized
                self.noFollowView.isHidden = false
                break
            default:
                break
            }
        }else{
            self.noFollowView.isHidden = true
        }
    }
    private func setNoCommentsView(){
         if self.commentsViewModel.commentModelArray.count == 0 {
             self.noFollowView.isHidden = false
             self.noFollowImageview.image = UIImage(named: "comment_placeholder")
            self.noFollowLabel.text = "No Comments yet".localized + "!"
         }else{
             self.noFollowView.isHidden = true
         }
     }
    
    private func setNoLikesView(){
           if self.followViewModel.followModelArray.count == 0 {
               self.noFollowView.isHidden = false
               self.noFollowImageview.image = UIImage(named: "favorites")
            self.noFollowLabel.text = "No Likes yet".localized + "!"
           }else{
               self.noFollowView.isHidden = true
           }
       }
    
    private func setSearchBarPlaceholder(){
        switch self.followListType {
        case .followeesView:
            self.followSearchBar.placeholder = Strings.searchFollowing.localized
        case .followersView:
            self.followSearchBar.placeholder = Strings.searchFollowers.localized
        case .likeListView:
            self.followSearchBar.placeholder = Strings.searchPeople.localized
        case .viewListView:
            self.followSearchBar.placeholder = Strings.searchPeople.localized
        case .subscribersList:
            self.followSearchBar.placeholder = "Search".localized + " " + "subcribers".localized
        }
    }
    
    //MARK:- Button Action
    
    //    @IBAction func bakcButtonAction(_ sender: Any) {
    //        if isChanged && delegate != nil{
    //            delegate?.followDataChanged()
    //        }
    //        self.navigationController?.popViewController(animated: true)
    //    }
    
    @IBAction func dismissViewControllerAction(_ sender: Any) {
        if isChanged && delegate != nil{
            delegate?.followDataChanged()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func followAction(sender: UIButton){
        self.isChanged = true
        let index = sender.tag
        let indexPath = IndexPath(row: index, section: 0)
        let modelData = self.followViewModel.followModelArray[index]
        var peopleId: String
        switch self.followListType {
        case .followersView:
            peopleId = modelData.follower!
            break
        case .followeesView:
            peopleId = modelData.followee!
            break
        case .likeListView:
            peopleId = modelData.followee!
            break
        case .viewListView:
            peopleId = modelData.followee!
            break
        case .subscribersList:
            peopleId = modelData.followee!
            break
        }
        if modelData.status == 0{
            modelData.status = 1
            if modelData.privicy == 1{
                modelData.status = 2
            }
            //            self.followViewModel.FollowPeopleService(url: AppConstants.follow, peopleId: peopleId)
            self.followViewModel.FollowPeopleService(isFollow: true, peopleId: peopleId, privicy: modelData.privicy)
        }else{
            modelData.status = 0
            //            self.followViewModel.FollowPeopleService(url: AppConstants.unfollow, peopleId: peopleId)
            self.followViewModel.FollowPeopleService(isFollow: false, peopleId: peopleId, privicy: modelData.privicy)
        }
        self.followViewModel.followModelArray[index] = modelData
        self.followTableView.beginUpdates()
        self.followTableView.reloadRows(at: [indexPath], with: .none)
        self.followTableView.endUpdates()
    }
    
    //MARK:- Service call
    @objc func followServiceCall(_ searchString: String?){
        
        let strUrl = self.getServiceUrl(searchString: searchString).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        if !isCommentsTabSelected{
            Helper.showPI()
        }
        
        let params = ["userId": userId]
        followViewModel.followServiceCall(strUrl: strUrl!,params: params as [String : Any]) { (success, error, canServiceCall) in
            DispatchQueue.main.async {
                self.followTableView.dg_stopLoading()
            }
            if success{
                print("success")
                if !self.isCommentsTabSelected{
                    self.followTableView.reloadData()
                    self.setNoFollowView()
                }
            }else if let error = error{
                Helper.hidePI()
                if error.code != 204{
                    self.setNoFollowView()
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.setNoFollowView()
                self.followViewModel.offset = self.followViewModel.offset - 40
            }
            
            self.canServiceCall = canServiceCall
            Helper.hidePI()
        }
    }
    
    func getServiceUrl(searchString: String?)-> String{
        guard var id = self.postOrUserId else {return ""}
        //        var searchString:String?
        //        if let text = searchString, text.count > 0{
        //             searchString = text
        //        }
        switch self.followListType {
        case .followeesView:
            if  searchString != "" {
                return AppConstants.searchFollowees + "?userId=\(id)&searchText=\(searchString ?? "")"
            }else{
                
                return AppConstants.getFollowees + "?userId=\(id)"
            }
        case .followersView:
            if  searchString != "" {
                return AppConstants.searchFollowers + "?userId=\(id)&searchText=\(searchString ?? "")"
            }else{
                
                return AppConstants.getFollowers + "?userId=\(id)"
            }
        case .likeListView:
            if  searchString != "" {
                return AppConstants.getLikedUserList + "?postId=\(id)&searchText=\(searchString ?? "")"
            }else {
                return AppConstants.getLikedUserList + "?postId=\(id)"
            }
        case .viewListView:
            if  searchString != "" {
                return AppConstants.getPostViews + "?postId=\(id)&searchText=\(searchString ?? "")"
            }else {
                return AppConstants.getPostViews + "?postId=\(id)"
            }
            
        case .subscribersList:
            return AppConstants.starUserssubscriberList + "?status=2"
        }
    }
    
    func setupCommentsSection(){
        self.followListType = .likeListView
        self.likesTabTitle.textColor = #colorLiteral(red: 0.666914165, green: 0.7039037943, blue: 0.7576858997, alpha: 1)
        self.likesCount.textColor = #colorLiteral(red: 0.666914165, green: 0.7039037943, blue: 0.7576858997, alpha: 1)
        self.commentsTabTitle.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        self.commentsCount.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        self.commentServiceCall()
        self.sendButton.isEnabled = false
        textView.layer.cornerRadius = 4.0
        tableViewBottomContraint.constant = 56
        emptyViewBottomContraint.constant = 56
        
//        self.searchTableView.makeShadowEffect(color: UIColor.lightGray)
    }
    
    func setupLikesSection(){
        self.likesTabTitle.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        self.likesCount.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        self.commentsTabTitle.textColor = #colorLiteral(red: 0.666914165, green: 0.7039037943, blue: 0.7576858997, alpha: 1)
        self.commentsCount.textColor = #colorLiteral(red: 0.666914165, green: 0.7039037943, blue: 0.7576858997, alpha: 1)
        followListType = .likeListView
        self.followViewModel.offset = -40
        self.followViewModel.followModelArray.removeAll()
        followServiceCall("")
        tableViewBottomContraint.constant = 0
        emptyViewBottomContraint.constant = 0
        inputToolBar.isHidden = true
    }
    
    @IBAction func likesTabAction(_ sender: Any) {
        if isLikesTabSelected || !searchTableView.isHidden{
            return
        }
        self.textView.resignFirstResponder()
         SearcheViewHeightContraint.constant = 50
        self.likesTabTitle.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        self.likesCount.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        self.commentsTabTitle.textColor = #colorLiteral(red: 0.666914165, green: 0.7039037943, blue: 0.7576858997, alpha: 1)
        self.commentsCount.textColor = #colorLiteral(red: 0.666914165, green: 0.7039037943, blue: 0.7576858997, alpha: 1)
        tableViewBottomContraint.constant = 0
          emptyViewBottomContraint.constant = 0
        isLikesTabSelected = true
        isCommentsTabSelected = false
        inputToolBar.isHidden = true
        self.followTableView.reloadData()
        self.setNoLikesView()
    }
    
    @IBAction func commentsTabAction(_ sender: Any) {
        if isCommentsTabSelected{
            return
        }
        self.followSearchBar.resignFirstResponder()
         SearcheViewHeightContraint.constant = 0
        self.likesTabTitle.textColor = #colorLiteral(red: 0.666914165, green: 0.7039037943, blue: 0.7576858997, alpha: 1)
        self.likesCount.textColor = #colorLiteral(red: 0.666914165, green: 0.7039037943, blue: 0.7576858997, alpha: 1)
        self.commentsTabTitle.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        self.commentsCount.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
        isLikesTabSelected = false
        isCommentsTabSelected = true
        inputToolBar.isHidden = false
        tableViewBottomContraint.constant = 56
        emptyViewBottomContraint.constant = 56
        if  self.commentsViewModel.commentModelArray.count == 0{
        self.commentServiceCall()
        }
        else{
             self.followTableView.reloadData()
            self.setNoCommentsView()
        }
    //    self.searchTableView.makeShadowEffect(color: UIColor.lightGray)
    }
}

extension DublyFollowViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCommentsTabSelected{
            if tableView == followTableView{
            return self.commentsViewModel.commentModelArray.count
            }
            else if isSearchPeople {
              return self.commentsViewModel.peopleArray.count
                 } else {
                    return self.commentsViewModel.hashTagArray.count
                }
        }
        else{
            return self.followViewModel.followModelArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isCommentsTabSelected{
            if tableView == followTableView{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as? CommentTableViewCell else{fatalError()}
            let data = self.commentsViewModel.commentModelArray[indexPath.row]
            cell.userImageButton.tag = indexPath.row
            cell.userImageButton.addTarget(self, action: #selector(CommentsViewController.cellUserImageTap(sender:)), for: .touchUpInside)
            cell.setCellData(modelData: data)
            cell.delegate = self
            return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as? SearchTableViewCell else{fatalError()}
                if isSearchPeople {
                    cell.setPeopleData(modelData: self.commentsViewModel.peopleArray[indexPath.row])
                } else {
                    cell.setTagData(modelData: self.commentsViewModel.hashTagArray[indexPath.row])
                }
                return cell
            }
        }
        else if tableView == followTableView{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.followTableViewCell) as? FollowTableViewCell else{fatalError()}
            let data = self.followViewModel.followModelArray[indexPath.row]
            cell.followButtonOutlet.tag = indexPath.row
            cell.followButtonOutlet.addTarget(self, action: #selector(DublyFollowViewController.followAction(sender:)), for: .touchUpInside)
            cell.setCellData(modelData: data)
            if let userId = Utility.getUserid(), let follower = data.follower, let followee = data.followee {
                var id = ""
                if followListType == .followeesView {
                    id = followee
                }else {
                    id = follower
                }
                if followListType == .likeListView || followListType == .viewListView{
                    id = data.userId!
                }
                if userId == id {
                    cell.followView.isHidden = true
                    cell.followButtonOutlet.isHidden = true
                }else {
                    cell.followView.isHidden = false
                    cell.followButtonOutlet.isHidden = false
                }
            }
            return cell
        }
        else{
        fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isCommentsTabSelected{
              if tableView == followTableView{
            let data = self.commentsViewModel.commentModelArray[indexPath.row]
            let text = data.commentedBy! + "  " + data.comment!
            let font = Utility.Font.Regular.ofSize(14)
            let width = self.view.frame.size.width - 60
            let height = text.height(withConstrainedWidth: width, font: font)
            let cellHeight = height < 19 ? 19 : height
            return cellHeight + 40
            }
              else{
                return 55
            }
        }
        else{
            return 65.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isCommentsTabSelected, indexPath.row == commentsViewModel.commentModelArray.count - 1 && commentsViewModel.commentModelArray.count > (commentsViewModel.limit + commentsViewModel.offset - 1) {
            commentsViewModel.offset = commentsViewModel.offset + 50
            self.commentServiceCall()
        }
        else{
            let indexPassed: Bool = indexPath.row >= self.followViewModel.followModelArray.count - 10
            if canServiceCall && indexPassed{
                self.canServiceCall = false
                followServiceCall(self.searchText)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: AppConstants.viewControllerIds.profileViewControllerId) as? ProfileViewController else {return}
        /*
             Bug Name:- Handle profile tab for self profile and other profile
             Fix Date:- 22/04/21
             Fix By  :- Jayaram G
             Description of Fix:- Passing flag for to hide tabbar
             */
            profileVC.isNotFromTabBar = true
        if isCommentsTabSelected{
            if tableView == searchTableView {
                if isSearchPeople {
                    let stringArray = self.textView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                    let lastString = stringArray.last!
                    self.textView.text = self.textView.text.replacingLastOccurrenceOfString(lastString, with:"")
                    let nameWithSymbol = "@"+self.commentsViewModel.peopleArray[indexPath.row].userName! + " "
                    self.textView.text.append(nameWithSymbol)
                    
                } else {
                    let stringArray = self.textView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                    let lastString = stringArray.last!
                    self.textView.text = self.textView.text.replacingLastOccurrenceOfString(lastString, with:"")
                    let nameWithSymbol = self.commentsViewModel.hashTagArray[indexPath.row].hashTag + " "
                    self.textView.text.append(nameWithSymbol)
                }
                removeTableData()
            }
            return
        }
        let data = self.followViewModel.followModelArray[indexPath.row]
        
        switch self.followListType {
        case .followersView:
            if data.follower == Utility.getUserid(){
                profileVC.isSelf = true
            }
            profileVC.memberId = data.follower
            break
        case .followeesView:
            if data.userId == Utility.getUserid(){
                profileVC.isSelf = true
            }
            profileVC.memberId = data.userId
            break
        case .likeListView:
            if data.userId == Utility.getUserid(){
                profileVC.isSelf = true
            }
            profileVC.memberId = data.userId
            break
        case .viewListView:
            if data.userId == Utility.getUserid(){
                profileVC.isSelf = true
            }
            profileVC.memberId = data.userId
            break
        case .subscribersList:
            if data.userId == Utility.getUserid(){
                profileVC.isSelf = true
            }
            profileVC.memberId = data.subscriberId
        }
  
        self.navigationController?.pushViewController(profileVC, animated: true)
    }    
}

//Comments
extension DublyFollowViewController{
    
    //Mark:- Keyboard ANimation
    override  func keyboardWillShow(_ notification: Notification){
        let kbSize = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect
        self.noFollowView.isHidden = true
        mainViewTopConstraint.constant = 0
        var height : CGFloat
        var bottomHeight : CGFloat
        height = Utility.getDeviceHeight() > 736.0 ? kbSize.size.height - 35 : kbSize.size.height
       bottomHeight  = Utility.getDeviceHeight() > 736.0 ? kbSize.size.height + 20 : kbSize.size.height + 40
        self.searchTableViewBottomConstraint.constant = bottomHeight
        self.textViewBottomConstraint.constant = height
    }
    
    override  func keyboardWillHide(_ notification: Notification){
        mainViewTopConstraint.constant = 150
        self.searchTableViewBottomConstraint.constant = 56
        self.textViewBottomConstraint.constant =  0
        if isCommentsTabSelected{
            self.setNoCommentsView()
        }else{
            self.setNoLikesView()
        }
    }

    
    
    @IBAction func sendButtonAction(_ sender: Any) {
        if textView.text != "", let comment = self.textView.text{
            guard let id = postOrUserId else {return}
            guard let userId = Utility.getUserid() else{return}
            let strUrl = AppConstants.comment
            
            let stringArray = comment.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
            var hashTagsStrings = String()
            var arrayOfTaggedUsers = [String]()
            
            var index: Int = 0
            for eachString in stringArray.enumerated() {
                if eachString.element.first == "#" {
                    if eachString.element.count > 2 {
                        var hashtag = eachString.element
                        hashtag.removeFirst()
                        if index == 0{
                            index = 1
                            hashTagsStrings = hashtag
                        }else{
                            hashTagsStrings = "\(hashTagsStrings),\(hashtag)"
                        }
                    }
                }
                
                if eachString.element.first == "@" {
                    if eachString.element.count > 2 {
                        var userName = eachString.element
                        userName.removeFirst()
                        arrayOfTaggedUsers.append(userName)
                    }
                }
            }
            
            let params: [String : Any] = ["comment":comment,
                                          "hashTags":hashTagsStrings,
                                          "userTags":arrayOfTaggedUsers,
                                          "postedBy":userId,
                                          "postId":id]
            self.textView.text = ""
            
            commentsViewModel.postCommentServiceCall(strUrl: strUrl, params: params) { (success, error) in
                if success{
                    if let updatecallback = self.updateCommentsCount,self.data != nil{
                        self.data!.commentCount =  self.data!.commentCount + 1
                        self.commentsCount.text = "\(self.data!.commentCount)"
                        updatecallback(self.self.data!.commentCount)
                                     }
                                     DispatchQueue.main.async{
                                        self.setNoCommentsView()
                                         self.followTableView.reloadData()
                                         self.followTableView.scrollToRow(at:IndexPath.init(item: 0, section: 0) , at: .top, animated: true)
                                        self.dismissKeyboards()
                                     }
                                     
                }else{
                    Helper.showAlertViewOnWindow("Message".localized, message: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    //MARK:- Service call
    func commentServiceCall(){
        guard let id = postOrUserId else {return}
        let strURL: String = AppConstants.comment + "?postId=\(id)"
        if isCommentsTabSelected{
            Helper.showPI()
        }
        
        let params = ["ip":self.ipAddress,
                      "city": self.city,
                      "country":self.country]
        commentsViewModel.commentServiceCall(strUrl: strURL,params: params) { (success, error, canServiceCall) in
            if success{
                print("success")
                if self.isCommentsTabSelected{
                    self.setNoCommentsView()
                    self.followTableView.reloadData()
                }
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.commentsViewModel.offset = self.commentsViewModel.offset - 30
            }
            self.canServiceCall = canServiceCall
        }
    }
    @IBAction func userImageButtonAction(_ sender: Any) {
        guard let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: controllerIdentifierName.profileViewController) as? ProfileViewController else {return}
        profileVC.isSelf = true
        /*
             Bug Name:- Handle profile tab for self profile and other profile
             Fix Date:- 22/04/21
             Fix By  :- Jayaram G
             Description of Fix:- Passing flag for to hide tabbar
             */
            profileVC.isNotFromTabBar = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func cellUserImageTap(sender: UIButton){
        guard let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: controllerIdentifierName.profileViewController) as? ProfileViewController else {return}
        let index = sender.tag
        /*
             Bug Name:- Handle profile tab for self profile and other profile
             Fix Date:- 22/04/21
             Fix By  :- Jayaram G
             Description of Fix:- Passing flag for to hide tabbar
             */
            profileVC.isNotFromTabBar = true
        let data = self.commentsViewModel.commentModelArray[index]
        profileVC.memberId = data.commentedByUserId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func profileImageBtn_Action(_ sender: UIButton) {
        
        guard let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: controllerIdentifierName.profileViewController) as? ProfileViewController else {return}
        let index = sender.tag
        /*
             Bug Name:- Handle profile tab for self profile and other profile
             Fix Date:- 22/04/21
             Fix By  :- Jayaram G
             Description of Fix:- Passing flag for to hide tabbar
             */
            profileVC.isNotFromTabBar = true
        let data = self.commentsViewModel.commentModelArray[index]
        profileVC.memberId = data.commentedByUserId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension DublyFollowViewController: UITextViewDelegate {
    
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isTextViewActive = true
        if textView.textColor == UIColor.lightGray || textView.textColor == UIColor.white{
                textView.text = nil
            if textView.textColor == UIColor.lightGray{
                textView.textColor = #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1)
            }else{
                textView.textColor = UIColor.white
            }
                
            }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.isTextViewActive = false
        if textView.text.isEmpty {
            textView.text = "Write a comment".localized + "..."
            if Utility.isDarkModeEnable(){
                textView.textColor = .white
            }else{
                textView.textColor = .lightGray
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        let stringArray = textView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        
        checkingText = textView.text!
        
        if  !checkingText.replace(target: "\n", withString: " ").trimmingCharacters(in: .whitespaces).isEmpty{
            self.sendButton.isEnabled = true
        }else {
            self.sendButton.isEnabled = false
        }
        
        //let words = textView.text.byWords
        if stringArray.last == nil || textView.text == "" {
               NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callPeopleServiceAPI), object: nil)
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callTagServiceAPI), object: nil)
            
            removeTableData()
        } else {
            let lastString = stringArray.last!
            
            if lastString == "" {
                 NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callPeopleServiceAPI), object: nil)
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callTagServiceAPI), object: nil)
                
                removeTableData()
                return
            }
            
            if lastString.count > 0 {
                if lastString.first == "@",lastString.count > 1 {
                    isSearchPeople = true
                     removeSymbol = lastString
                    removeSymbol = String(removeSymbol.dropFirst())
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callPeopleServiceAPI), object: nil)
                    self.perform(#selector(callPeopleServiceAPI), with: nil, afterDelay: 0.5)
                } else if lastString.first == "#",lastString.count > 1 {
                    isSearchPeople = false
                    removeSymbol = lastString
                    removeSymbol = String(removeSymbol.dropFirst())
                 NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callTagServiceAPI), object: nil)
               self.perform(#selector(callTagServiceAPI), with: nil, afterDelay: 0.5)
                    
                } else {
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callPeopleServiceAPI), object: nil)
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callTagServiceAPI), object: nil)
                    removeTableData()
                }
            }
        }
    }
    
 @objc func callPeopleServiceAPI()
    {
      getPeopleService(searchString: removeSymbol)
    }
    
    @objc func callTagServiceAPI()
    {
      getTagsService(searchString: removeSymbol)
    }
    
    func removeTableData() {
          self.commentsViewModel.peopleArray.removeAll()
          self.commentsViewModel.hashTagArray.removeAll()
          self.searchTableView.reloadData()
          self.searchTableView.isHidden = true
      }
    
    func getPeopleService(searchString:String){
        self.commentsViewModel.peopleOffset = -30
        var strUrl: String = AppConstants.searchPeople + "?"
        strUrl = AppConstants.searchPeople + "?username=\(searchString)&"
        
        commentsViewModel.getSearchData(with: strUrl, type: .people) { (success, error, canServiceCall) in
            if success{
                self.searchTableView.reloadData()
            }else if let error = error{
                print(error.localizedDescription)
                //                if error.code != 204{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: (error.localizedDescription))
                //                }else if error.code == 204{
                //                    self.searchTableView.reloadData()
                //                }
                self.commentsViewModel.peopleOffset = self.commentsViewModel.peopleOffset - 30
            }
            self.showOrRemoveSearchTableView()
        }
    }
    
    
    func getTagsService(searchString:String){
        var strUrl: String = AppConstants.hashTagList + "?"
        strUrl = AppConstants.hashTagList + "?hashtag=\(searchString)&"
        commentsViewModel.getSearchData(with: strUrl, type: .tag) { (success, error, canServiceCall) in
            if success{
                self.searchTableView.reloadData()
            }else if let error = error{
                print(error.localizedDescription)
                //                if error.code != 204{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: (error.localizedDescription))
                //                }else if error.code == 204{
                //                    self.searchTableView.reloadData()
                //                }
                self.commentsViewModel.tagOffset = self.commentsViewModel.tagOffset - 30
            }
            self.showOrRemoveSearchTableView()
        }
    }
    
    
    /// To show or remove table view based on number of item in table view
    func showOrRemoveSearchTableView(){
        if self.isSearchPeople{
            if self.commentsViewModel.peopleArray.count == 0{
                self.searchTableView.isHidden = true
            }else{
                self.searchTableView.isHidden = false
            }
        } else if self.commentsViewModel.hashTagArray.count == 0{
            self.searchTableView.isHidden = true
        }else{
            self.searchTableView.isHidden = false
        }
    }

    
}


//MARK:- Comment table view cell delegate
extension DublyFollowViewController: CommentTableViewCellDelegate{
    
    
    func forYouviewmoreTapped(isViewed: Bool,index : Int){
        
    }
    
    func userNameGetClicked(name: String){
        guard let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: controllerIdentifierName.profileViewController) as? ProfileViewController else {return}
        let tag = name.replace(target: "@", withString: "")
        profileVC.userNameTag = tag
        /*
             Bug Name:- Handle profile tab for self profile and other profile
             Fix Date:- 22/04/21
             Fix By  :- Jayaram G
             Description of Fix:- Passing flag for to hide tabbar
             */
            profileVC.isNotFromTabBar = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func hasgtagGetClicked(hasgTag: String){
        let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        postedbyController.hashTagName = hasgTag
        postedbyController.isHashTag = true
        self.navigationController?.pushViewController(postedbyController, animated: true)
    }
}
