//
//  FollowViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//
import UIKit
enum FollowListType {
    case followeesView
    case followersView
    case likeListView
    case viewListView
    case subscribersList
}
protocol FollowViewControllerDelegate: class {
    func followDataChanged()
}
class FollowViewController: UIViewController {
    
    /// All Outlets
    @IBOutlet weak var followTableView: UITableView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var viewTitleLabe: UILabel!
    @IBOutlet weak var noFollowView: UIView!
    @IBOutlet weak var noFollowLabel: UILabel!
    @IBOutlet weak var noFollowImageview: UIImageView!
    @IBOutlet weak var followSearchBar: UISearchBar!
    
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    
    /// variables and declarations
    var isSearchActive: Bool = false
    var searchText: String = ""
    let followViewModel = FollowViewModel()
    var canServiceCall: Bool = false
    var isSelf : Bool = false
    //    var isFollowers: Bool = false
    var viewTitle: String?
    var followListType: FollowListType = .followersView
    var postOrUserId: String?
    var isChanged: Bool = false
    var delegate: FollowViewControllerDelegate?
    var userId:String?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.setNoFollowView()
        self.tabBarController?.tabBar.isHidden = true
        
        self.viewTitleLabe.text = viewTitle != nil ? viewTitle! : ""
        self.setSearchBarPlaceholder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            if Utility.isDarkModeEnable(){
                UIApplication.shared.statusBarStyle = .lightContent
            }else{
                UIApplication.shared.statusBarStyle = .darkContent
            }
        self.followViewModel.offset = -40
        self.followViewModel.followModelArray.removeAll()
        followServiceCall("")
        
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: viewTitle ?? "")
    }
    
    
    /// setting no follow view
    private func setNoFollowView(){
        if self.followViewModel.followModelArray.count == 0 || self.followViewModel.followModelArray == nil {
            switch self.followListType{
            case .followersView:
                self.noFollowImageview.image = UIImage(named: Strings.ImageNames.followers.localized)
                self.noFollowLabel.text = Strings.noUserIsFollowing.localized
                break
            case .followeesView:
                self.noFollowImageview.image = UIImage(named: Strings.ImageNames.following.localized)
                self.noFollowLabel.text = Strings.yourNotFollowingAnyUser.localized
                break
                
             /*
             Bug Name:- need placeholder for no subscribers
             Fix Date:- 31/03/21
             Fixed By:- Nikunj C
             Description of Fix:- add subscribersList type
             */
                
            case .subscribersList:
                self.noFollowImageview.image = UIImage(named: "No_Subscribers")
                self.noFollowLabel.text = Strings.notHaveSubscriber.localized
                break
            default:
                break
            }
            self.noFollowView.isHidden = false
        }else{
            self.noFollowView.isHidden = true
        }
    }
    
    private func setSearchBarPlaceholder(){
        switch self.followListType {
        case .followeesView:
            self.followSearchBar.placeholder = Strings.searchFollowing.localized
            self.searchBarHeightConstraint.constant = 44
        case .followersView:
            self.followSearchBar.placeholder = Strings.searchFollowers.localized
            self.searchBarHeightConstraint.constant = 44
        case .likeListView:
            self.followSearchBar.placeholder = Strings.searchPeople.localized
            self.searchBarHeightConstraint.constant = 44
        case .viewListView:
            self.followSearchBar.placeholder = Strings.searchPeople.localized
            self.searchBarHeightConstraint.constant = 44
        case .subscribersList:
            self.followSearchBar.placeholder = "Search subscribers".localized
            self.searchBarHeightConstraint.constant = 44
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshHomeScreen), object: nil)
    }
    
    //MARK:- Service call
  @objc func followServiceCall(_ searchString: String?){
        
        let strUrl = self.getServiceUrl(searchString: searchString).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        Helper.showPI()
        
        let params = ["userId": userId ]
        followViewModel.followServiceCall(strUrl: strUrl!,params: params) { (success, error, canServiceCall) in
            if success{
                print("success")
                self.followTableView.reloadData()
                self.setNoFollowView()
            }else if let error = error{
                Helper.hidePI()
                if error.code != 204{
                    self.setNoFollowView()
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.noFollowView.isHidden = false
                self.followViewModel.offset = self.followViewModel.offset - 40
            }
            
            self.canServiceCall = canServiceCall
            Helper.hidePI()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshHomeScreen), object: nil)
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
            if  searchString != "" {
                return AppConstants.starUserssubscriberList + "?status=2&searchText=\(searchString ?? "")"
            }else {
                return AppConstants.starUserssubscriberList + "?status=2"
            }
        }
    }
}

extension FollowViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followViewModel.followModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.followTableViewCell) as? FollowTableViewCell else{fatalError()}
        if self.followViewModel.followModelArray.count > indexPath.row {
            let data = self.followViewModel.followModelArray[indexPath.row]
            cell.followButtonOutlet.tag = indexPath.row
            cell.followButtonOutlet.addTarget(self, action: #selector(FollowViewController.followAction(sender:)), for: .touchUpInside)
            cell.setCellData(modelData: data)
            if followListType == .subscribersList {
                cell.followView.isHidden = true
                cell.followButtonOutlet.isHidden = true
            }
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let indexPassed: Bool = indexPath.row >= self.followViewModel.followModelArray.count - 10
        if canServiceCall && indexPassed{
            self.canServiceCall = false
            followServiceCall(self.searchText)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        
        if self.followViewModel.followModelArray.count > indexPath.row {
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
                break
            }
            self.navigationController?.pushViewController(profileVC, animated: true)

        }
        }
}
