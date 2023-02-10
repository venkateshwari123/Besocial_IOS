
//
//  ActivityViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import DGElasticPullToRefresh


class ActivityViewController: UIViewController {
    
   // @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var youButtonOutlet: UIButton!
    @IBOutlet weak var followingButtonOutlet: UIButton!
    @IBOutlet weak var scrollingViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var followingTableView: UITableView!
    @IBOutlet weak var youTableView: UITableView!
    
    @IBOutlet weak var noFollowingActivity: UIView!
    @IBOutlet weak var noFollowingActivityLbl: UILabel!
    @IBOutlet weak var noFollowActivityLbl: UILabel!
    @IBOutlet weak var noFollowActivity: UIView!
    let bottomEdge: CGFloat = 20.0
    
    var canFollowingServiceCall: Bool = false
    var canFollowServiceCall: Bool = false
    
    var isAppeareFirstFollowing: Bool = true
    var isAppeareFirstFollow: Bool = true
    var isAppeareFirstRequest: Bool = true
    
    var isFollowingActive: Bool = true
    let activityViewModel = ActivityViewModel()
    
    struct CellIdentifiers {
        static let ActivityHeaderTableViewCell = "ActivityHeaderTableViewCell"
        static let ActivityTableViewCell = "ActivityTableViewCell"
        static let FollowActivityTableViewCell = "FollowActivityTableViewCell"
    }
    
    struct SegueName {
        static let acceptOrDeleteSegue = "acceptOrDeleteSegue"
    }
    
    struct storyboardId {
        static let postedByController = "postedByController"
        static let profileViewController = "ProfileViewController"
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewUI()
//        getFollowingActvity()
//        getFollowService()
//        getRequestService()
       // self.addObserVerForCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false

//        if let userImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String{
//            self.profileImageView.setImageOn(imageUrl: userImage, defaultImage:#imageLiteral(resourceName: "defaultImage"))
//        }else{
//            self.profileImageView.image = #imageLiteral(resourceName: "defaultImage")
//        }
        
//        if self.activityViewModel.followArray.count == 0{
        self.activityViewModel.followingOffset = -20
            getFollowingActvity()
        self.activityViewModel.youOffset = -20
            getFollowService()
//        }
//        if self.activityViewModel.followingArray.count == 0{
        
//        }
//        if self.activityViewModel.followRequestArray.count == 0 || self.activityViewModel.channelRequestArray.count == 0{
            getRequestService()
//        }
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
    
    /// To set view UI on view did load
    func setViewUI(){
        self.tabBarController?.tabBar.isHidden = true
        self.followingButtonOutlet.isSelected = true
     //   self.profileImageView.makeCornerRadious(readious: self.profileImageView.frame.size.width / 2)
        
        self.navigationItem.title = "Notifications".localized
        self.followingButtonOutlet.setTitle("Following".localized, for: .normal)
        self.youButtonOutlet.setTitle("You".localized, for: .normal)
        self.followingButtonOutlet.setTitle("Following".localized, for: .selected)
        self.youButtonOutlet.setTitleColor(UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF"), for: .selected)
        self.youButtonOutlet.setTitle("You".localized, for: .selected)
        self.followingButtonOutlet.setTitleColor(UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF"), for: .selected)

        self.noFollowingActivityLbl.text = "There is no following activity".localized + "."
        self.noFollowActivityLbl.text = "There is no follow activity".localized + "."
        self.followingTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: bottomEdge, right: 0)
        self.youTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: bottomEdge, right: 0)
        self.noFollowingActivity.isHidden = true
        self.noFollowActivity.isHidden = true
        
        // Initialize TrendingCollectionView for refresh
        let followingLoadingView = DGElasticPullToRefreshLoadingViewCircle()
        self.followingTableView.tintColor = UIColor.white
        followingTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            self?.activityViewModel.followingOffset = -20
            self?.getFollowingActvity()
            }, loadingView: followingLoadingView)
        followingTableView.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        followingTableView.dg_setPullToRefreshBackgroundColor(followingTableView.backgroundColor!)
        
        let youLoadingView = DGElasticPullToRefreshLoadingViewCircle()
        self.youTableView.tintColor = UIColor.white
        youTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            self?.activityViewModel.youOffset = -20
            self?.getFollowService()
            self?.getRequestService()
            }, loadingView: youLoadingView)
        youTableView.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        youTableView.dg_setPullToRefreshBackgroundColor(youTableView.backgroundColor!)
        
        if #available(iOS 15.0, *) {
            followingTableView.sectionHeaderTopPadding = 0
            youTableView.sectionHeaderTopPadding = 0
        }
        
        
    }
    
    private func setNoFollowingActivityView(){
        if self.activityViewModel.followingArray.count > 0{
            self.noFollowingActivity.isHidden = true
            self.followingTableView.isHidden = false
        }else{
            self.noFollowingActivity.isHidden = false
            self.followingTableView.isHidden = true
        }
    }
    
    private func setNoFollowActivityView(){
        /*
         Bug Name:- following details are not show sometime
         Fix Date:- 03/04/21
         Fixed By:- Nikunj C
         Description of Fix:- hide youtabel instead of following tabel if count of follow array , channelRequestArray or followRequest array is 0
         */
        
        
        if self.activityViewModel.followArray.count > 0 || self.activityViewModel.channelRequestArray.count > 0 || self.activityViewModel.followRequestArray.count > 0 {
            self.noFollowActivity.isHidden = true
              self.youTableView.isHidden = false
        }else{
            self.noFollowActivity.isHidden = false
              self.youTableView.isHidden = true
        }
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        followingTableView.dg_removePullToRefresh()
//        youTableView.dg_removePullToRefresh()
//    }
    
    deinit {
        if followingTableView != nil{
            followingTableView.dg_removePullToRefresh()
        }
        if youTableView != nil{
            youTableView.dg_removePullToRefresh()
        }
    }
    
    
    //MARK:- Buttons Action
    
    @IBAction func followingAction(_ sender: Any) {
        self.setSelectedButton(index: 0)
    }
    
    @IBAction func youAction(_ sender: Any) {
        self.setSelectedButton(index: 1)
    }
    
    
    @IBAction func moveToProfileVc(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Get all following service
    ///to get following service
    func getFollowingActvity(){
        if self.isAppeareFirstFollowing{
            self.isAppeareFirstFollowing = false
            Helper.showPI()
        }
        activityViewModel.getFollowingService(activityType: .Following) { (success, error, canServiceCall) in
            self.followingTableView.dg_stopLoading()
            if success{
                self.setNoFollowingActivityView()
                self.followingTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                if error.code == 204 {
                    self.setNoFollowingActivityView()
                    self.followingTableView.reloadData()
                }
                self.activityViewModel.followingOffset = self.activityViewModel.followingOffset - 20
            }
            Helper.hidePI()
            self.canFollowingServiceCall = canServiceCall
        }
    }
    
    //To get follow service
    func getFollowService(){
        if self.isAppeareFirstFollow{
            self.isAppeareFirstFollow = false
            Helper.showPI()
        }
        activityViewModel.getFollowingService(activityType: .Follow) { (success, error, canServiceCall) in
            self.youTableView.dg_stopLoading()
            if success{
                self.setNoFollowActivityView()
                self.youTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.activityViewModel.youOffset = self.activityViewModel.youOffset - 20
            }
            self.canFollowServiceCall = canServiceCall
        }
    }
    
    ///To get requested data from server
    func getRequestService(){
        
        if self.isAppeareFirstRequest{
            self.isAppeareFirstRequest = false
            Helper.showPI()
        }
        ///to get follow request
        let strUrl = AppConstants.followRequest
        activityViewModel.getRequestServiceCall(strUrl: strUrl, requestType: .user) { (success, error) in
            if success{
                self.setNoFollowActivityView()
                self.youTableView.reloadData()
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
        
//        ///to get subscribe request
//        strUrl = AppConstants.RequestedChannels
//        activityViewModel.getRequestServiceCall(strUrl: strUrl, requestType: .channel) { (success, error) in
//            if success{
//                self.youTableView.reloadData()
//            }else if let error = error{
//                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
//            }
//        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueName.acceptOrDeleteSegue{
            guard let acceptOrDeleteVC = segue.destination as? AcceptOrDeleteViewController else {return}
            if let id = sender as? Int, id == 1{
                acceptOrDeleteVC.isChannel = true
                acceptOrDeleteVC.acceptOrDeleteViewModel.requestedChannleArray = activityViewModel.channelRequestArray
            }else{
                acceptOrDeleteVC.isChannel = false
                acceptOrDeleteVC.acceptOrDeleteViewModel.followRequestArray = activityViewModel.followRequestArray
            }
            acceptOrDeleteVC.delegate = self
        }
    }
}

//MARK:- Table view data source
extension ActivityViewController: UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == youTableView{
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.followingTableView{
//            if self.activityViewModel.followingArray.count == 0 {
//                self.setNoFollowingActivityView()
//            }
            return self.activityViewModel.followingArray.count
        }else{
            if section == 0{
                let model = self.activityViewModel
                return model.followUserCount + model.followChannelCount
            }else{
                return self.activityViewModel.followArray.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.ActivityTableViewCell) as? ActivityTableViewCell else{fatalError()}
        activityCell.delegate = self
        if tableView == self.followingTableView{
            let modelData = self.activityViewModel.followingArray[indexPath.row]
            activityCell.setCellDataFor(data: modelData)
            activityCell.postImageButtonOutlet.tag = indexPath.row
            activityCell.postImageButtonOutlet.addTarget(self, action: #selector(handleRegister(sender:)), for: UIControl.Event.touchUpInside)
            activityCell.activityType = .Following
            activityCell.Index = indexPath.row
            return activityCell
        }else{
            if indexPath.section == 0{
                if indexPath.row == 0{
                    if activityViewModel.followUserCount >= 1{
                        activityCell.setCellDataForUserRequest(modelData: activityViewModel.followRequestArray[0], count: activityViewModel.followRequestArray.count)
                    }else{
                        activityCell.setCellDataForChannleRequest(modelData: activityViewModel.channelRequestArray[0], count: activityViewModel.channelRequestArray.count)
                    }
                }else{
                    activityCell.setCellDataForChannleRequest(modelData: activityViewModel.channelRequestArray[0], count: activityViewModel.channelRequestArray.count)
                }
                return activityCell
            }else{
                guard let followCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FollowActivityTableViewCell) as? FollowActivityTableViewCell else { fatalError()}
                let modelData = self.activityViewModel.followArray[indexPath.row]
                if let data = modelData as? ActivityCommentModel{
                    activityCell.setCommentAndLikeModel(modelData: data)
                    activityCell.postImageButtonOutlet.tag = indexPath.row
                    activityCell.postImageButtonOutlet.addTarget(self, action: #selector(handleRegister(sender:)), for: UIControl.Event.touchUpInside)
                    activityCell.activityType = .Follow
                    activityCell.Index = indexPath.row
                    return activityCell
                }else if let data = modelData as? ActivityFollowModel{
                    followCell.setFollowData(modelData: data, index: indexPath.row)
                    activityCell.activityType = .Follow
                    followCell.delegate = self
                }
                return followCell
            }
        }
    }
    
    @objc private func handleRegister(sender: UIButton){
        let index = sender.tag
        var postId: String?
        if self.isFollowingActive{
            guard let data = self.activityViewModel.followingArray[index] as? ActivityCommentModel else{return}
            postId = data.postData?.postId
        }else{
            guard let data = self.activityViewModel.followArray[index] as? ActivityCommentModel else{return}
            postId = data.postData?.postId
        }
        if AppConstants.appType == .picoadda {
            Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: nil, needToCallApi: true, postId: postId)
        }else{
            Route.navigateToAllPostsVertically(navigationController: self.navigationController,postId: postId,isCommingFromChat:true,isFromProfilePage:true)
        }
    }
}

//MARK:- Table view delegate
extension ActivityViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.ActivityHeaderTableViewCell) else {fatalError()}
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else if activityViewModel.followChannelCount != 1 && activityViewModel.followUserCount != 1{
            return 0
        }
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.followingTableView{
            let indexPassed: Bool = indexPath.row >= self.activityViewModel.followingArray.count - 10
            if self.canFollowingServiceCall && indexPassed{
                self.canFollowingServiceCall = false
                getFollowingActvity()
            }
        }else{
            let indexPassed: Bool = indexPath.row >= self.activityViewModel.followArray.count - 10
            if self.canFollowServiceCall && indexPassed{
                self.canFollowServiceCall = false
                getFollowService()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == youTableView && indexPath.section == 0{
            if indexPath.row == 0{
                if activityViewModel.followUserCount == 1{
                    self.performSegue(withIdentifier: SegueName.acceptOrDeleteSegue, sender: 0)
                }else{
                    self.performSegue(withIdentifier: SegueName.acceptOrDeleteSegue, sender: 1)
                }
            }else{
                self.performSegue(withIdentifier: SegueName.acceptOrDeleteSegue, sender: 1)
            }
        }
    }
}

//MARK:- Scroll view delegate
extension ActivityViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.mainScrollView{
            let offset = scrollView.contentOffset
            self.scrollingViewLeadingConstraint.constant = scrollView.contentOffset.x / 2
            if offset.x <= self.view.frame.size.width / 2{
                ///select contact selected and facebook deselect
                self.followingButtonOutlet.isSelected = true
                self.youButtonOutlet.isSelected = false
            }else{
                ///select facebook selected and contact deselect
                self.youButtonOutlet.isSelected = true
                self.followingButtonOutlet.isSelected = false
            }
            scrollView.contentOffset = offset
        }
    }
    
    /// To move frame according to selected button (0 for contact and 1 for facebook)
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
        default: break
        }
        self.mainScrollView.scrollRectToVisible(frame, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.mainScrollView{
            self.checkActiveTableView()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == self.mainScrollView{
            self.checkActiveTableView()
        }
    }
    
    private func checkActiveTableView(){
        let xPosition = self.mainScrollView.bounds.origin.x
        let width = self.view.frame.size.width
        switch xPosition{
        case 0:
            self.isFollowingActive = true
            break
        case width:
            self.isFollowingActive = false
            break
        default:
            self.isFollowingActive = true
            break
        }
    }
}


extension ActivityViewController: AcceptOrDeleteViewControllerDelegate{
    
    func updateDataOfYouActivity(){
        self.activityViewModel.youOffset = -20
        getFollowService()
        getRequestService()
    }
}

//MARK:- Activity table view cell delegate
extension ActivityViewController: ActivityTableViewCellDelegate{
    func userImagetap(activityType: ActivityType, index: Int) {
        self.imageButtonClicked(activityType: activityType, index: index)
    }
    
    func imageButtonClicked(activityType: ActivityType, index: Int){
        var userName: String = ""
        switch activityType {
        case .Follow:
            let modelData = self.activityViewModel.followArray[index]
            if let data = modelData as? ActivityCommentModel{
                userName = userName + data.userName
            }else if let data = modelData as? ActivityFollowModel{
                userName = userName + data.userName
            }
            break
        case .Following:
            let modelData = self.activityViewModel.followingArray[index]
            if let data = modelData as? ActivityCommentModel{
                userName = userName + data.userName
            }else if let data = modelData as? ActivityFollowModel{
                userName = userName + data.userName
            }
            break
        }
        self.openUserProfileController(name: userName)
    }
    
    func userNameClicked(name: String) {
        self.openUserProfileController(name: name)
    }
    
    func openUserProfileController(name: String){
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        profileVC.userNameTag = name
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func hashTagClicked(tag: String) {
        self.openhashtagController(hashtag: tag)
    }
    
    func openhashtagController(hashtag: String){
        let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        postedbyController.hashTagName = hashtag
        self.navigationController?.pushViewController(postedbyController, animated: true)
    }
}

//MARK:- Follow Activity table view cell delegate
extension ActivityViewController: FollowActivityTableViewCellDelegate{
    func userImagetapAction(activityType: ActivityType, index: Int) {
        self.imageButtonClicked(activityType: activityType, index: index)
    }
    
    func followingButtonActionAt(index: Int) {
        let modelArray = self.activityViewModel.followArray
        if modelArray.count > index{
            if let modelData = modelArray[index] as? ActivityFollowModel{
                updatePeopleModelArray(modelData: modelData, index: index)
            }
        }
    }
    
    ///To update people table view according to selected or unselected follow button and put to server
    func updatePeopleModelArray(modelData: ActivityFollowModel, index: Int){
        if modelData.amIFollowing == 0{
            modelData.amIFollowing = 1
            //            if modelData.privicy == 1{
            //                modelData.followStatus = 2
            //            }
//            self.activityViewModel.FollowPeopleService(url: AppConstants.follow, peopleId: modelData.userId!)
            self.activityViewModel.FollowPeopleService(isFollow: true, peopleId: modelData.userId!, privicy: 0)
            
        }else{
            modelData.amIFollowing = 0
//            self.activityViewModel.FollowPeopleService(url: AppConstants.unfollow, peopleId: modelData.userId!)
            self.activityViewModel.FollowPeopleService(isFollow: false, peopleId: modelData.userId!, privicy: 0)
        }
        let indexPath = IndexPath(row: index, section: 1)
        self.activityViewModel.followArray[index] = modelData
        self.youTableView.beginUpdates()
        self.youTableView.reloadRows(at: [indexPath], with: .none)
        self.youTableView.endUpdates()
    }
    
    func followUserNameClicked(name: String){
        self.openUserProfileController(name: name)
    }
    
    func followHashTagClicked(hashtag: String){
        self.openhashtagController(hashtag: hashtag)
    }
}
