//
//  FollowListViewController.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 11/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//
import UIKit
import DGElasticPullToRefresh


enum ControllerPurpose {
    case createSecretChat
    case createGroup
    case addInGroup
    case createSingleChat
    case forwardMessage
}

protocol FollowListViewControllerDelegate {
    func selecteGroupMember(contact: Contacts)
}

class FollowListViewController: BaseViewController {

    //Outlets
    
    @IBOutlet weak var searchShadowView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var selectedUserCollectionView: UICollectionView!
    @IBOutlet weak var collectioViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var followListTableview: UITableView!
    @IBOutlet weak var noPeopleView: UIView!
    @IBOutlet weak var noPeopleLbl: UILabel!
    @IBOutlet weak var nextBtnOutlet: UIBarButtonItem!
    
    //Class variable
    let followListViewModel = FollowListViewModel()
    var canServiceCall: Bool = false
    
    var controllerPurpose: ControllerPurpose = .createSingleChat
    var groupMembers = [[String:Any]]()
    
    var message: Message?
    var documentId: String?
    
    var favmodelView : FavoriteViewModel?  = nil
    var couchbase = Couchbase.sharedInstance
//    var isSearchActive: Bool = false
    var searchText: String?
    
    var delegate: FollowListViewControllerDelegate?
    

    
    //Identifiers
    struct cellIdentifier {
        static let FollowListTableViewCell = "FollowListTableViewCell"
        static let SelectedUserCollectionViewCell = "SelectedUserCollectionViewCell"
    }
    struct segueIdentifier{
        static let followToChatSegue = "followToChatSegue"
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.showPI()
        
        self.followFolloweServiceCall(strUrl: AppConstants.followersFollowee + "?")

        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        followListTableview.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            self?.followListViewModel.offset = 0
            self?.followFolloweServiceCall(strUrl: AppConstants.followersFollowee + "?")
            }, loadingView: loadingView)
        followListTableview.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        followListTableview.dg_setPullToRefreshBackgroundColor(followListTableview.backgroundColor!)
    
        //To set tile and navigation bar
        self.setViewTitleAndUI()
        //To set search view UI
//        self.setSearchViewUI()
        self.setCollectionViewHeight(duration: 0.0)
        //getting data from database
        self.canServiceCall = self.followListViewModel.getFollowUserListFromDatabase()
        self.followListTableview.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        setSearchViewUI()
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
    
    /// To set title and navigation of view according to purpose of view
    private func setViewTitleAndUI(){
        self.nextBtnOutlet.title = "Next".localized
        switch self.controllerPurpose {
        case .createSecretChat:
            self.title = Strings.FollowListStrings.secretChat.localized
            self.navigationItem.rightBarButtonItem = nil
            break
        case .createSingleChat:
            self.title = Strings.FollowListStrings.newMessage.localized
            self.navigationItem.rightBarButtonItem = nil
            break
        case .createGroup:
            self.title = Strings.FollowListStrings.addParticipants.localized
            /* Bug Name :  Chat Module: While adding a user to a group chat the green highlighted button for the added users is not being displayed appropriately
                                         Fix Date : 1-apr-2021
                                         Fixed By : Vishal D
                                         Description Of Fix : removed old scenario and added multi edit
                                       */
            self.followListTableview.isEditing = false
            self.followListTableview.allowsMultipleSelection = true
            break
        case .addInGroup:
            self.title = Strings.FollowListStrings.addParticipants.localized
            self.navigationItem.rightBarButtonItem = nil
            self.followListViewModel.groupMemberList = self.groupMembers
            break
        case .forwardMessage:
            /* Bug Name :  Chat: forward chat and delete message functionality is not working
             Fix Date : 15-apr-2021
             Fixed By : Jayaram G
             Description Of Fix : removed old scenario and added multi edit
             */
            self.title = Strings.FollowListStrings.forwardTo.localized
            self.followListTableview.isEditing = false
            self.followListTableview.allowsMultipleSelection = true
            self.followListViewModel.documentId = self.documentId
            break
        }
    }
    
    /// To set the search UI
    private func setSearchViewUI(){
        self.searchContainerView.makeCornerRadious(readious: 5)
//        self.searchContainerView.makeBorderWidth(width: 0.4, color: .lightGray)
        if !Utility.isDarkModeEnable(){
            self.searchShadowView.makeShadowForSearchView()
        }
        
        self.searchBarOutlet.placeholder = "Search".localized + " " + "people".localized
        self.noPeopleLbl.text = "No users found".localized + "."
    }
    
    /// To set collectio view height with animation
    ///
    /// - Parameter duration: duration of animation
    func setCollectionViewHeight(duration: TimeInterval){
        var height: CGFloat = 90.0
        if self.followListViewModel.selectedMember.count == 0{
            height = 0.0
        self.selectedUserCollectionView.collectionViewLayout.invalidateLayout()
        }
        self.collectioViewHeightConstraint.constant = height
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    /// To scroll to most right of the collection view
    func scrollToLast(){
        if self.followListViewModel.selectedMember.count == 0{
            return
        }
        let count = self.followListViewModel.selectedMember.count
        let lastItemIndex = IndexPath(item: count - 1, section: 0)
        self.selectedUserCollectionView.scrollToItem(at: lastItemIndex, at: .right, animated: true)
    }
    
    //MARK:- Button Action
    @IBAction func nextAction(_ sender: Any) {
        if self.followListViewModel.selectedMember.count == 0{
            return
        }
        switch self.controllerPurpose {
        case .createGroup:
            self.navigateToCreateGroupController()
            break
        case .forwardMessage:
            self.storeInDatabaseAndSendMessage()
            break
        default:
            break
        }
    }
    
    
    /// To navigate to create group chat controller
    private func navigateToCreateGroupController(){
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.chat, bundle: nil)
        guard let createNewGroupVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.CreatnewGroupViewController) as? CreatnewGroupViewController else {return}
        let seleMem = self.followListViewModel.selectedMember.map { ( Contacts(followModel: $0, docId: nil))}
        createNewGroupVC.selectedGpList = seleMem
        self.navigationController?.pushViewController(createNewGroupVC, animated: true)
    }
    
    
    /// To store message to users database and send through MQTT
    private func storeInDatabaseAndSendMessage(){
        self.followListViewModel.forwardMessageToAllSelectedUsers(message: self.message)
        if self.followListViewModel.selectedMember.count == 1{
            self.performSegue(withIdentifier: segueIdentifier.followToChatSegue, sender: 0)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    //MARK:- Service call
    func followFolloweServiceCall(strUrl: String){
        
        followListViewModel.getFollowAndFollowesService(strUrl: strUrl) { (success, error, canServiceCall) in
            if success{
                DispatchQueue.main.async {
                    self.followListTableview.dg_stopLoading()
                    self.followListTableview.reloadData()
                    /* Bug Name : not able to start chat as the users are not being displayed
                     Fix Date : 02/06/2021
                     Fixed By : Jayaram G
                     Description Of Fix : Added default placeholder
                     */
                    self.noPeopleView.isHidden = !(self.followListViewModel.followersFolloweeModelArray.count == 0)
                }
            }else if let error = error{
                /* Bug Name : not able to start chat as the users are not being displayed
                 Fix Date : 02/06/2021
                 Fixed By : Jayaram G
                 Description Of Fix : Added default placeholder
                 */
                self.noPeopleView.isHidden = !(self.followListViewModel.followersFolloweeModelArray.count == 0)
                if error.code != 204{
                    DispatchQueue.main.async {
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                    }
                }
                self.followListViewModel.offset = self.followListViewModel.offset - 20
            }
            self.canServiceCall = canServiceCall
        }
    }
    
    //MARK:- Navigate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier.followToChatSegue{
            switch self.controllerPurpose {
            case .createSecretChat:
                
                 break
            case .createSingleChat:
                guard let controller = segue.destination as? ChatViewController else { return }
                guard let rowNum = sender as? Int else { return }
                let data = self.followListViewModel.followersFolloweeModelArray[rowNum]
                let docId = Utility.fetchIndividualChatDoc(withReceiverID: data.id, andSecretID: "")
                let contact = Contacts(followModel: data, docId: docId)
                controller.favoriteObj = contact
                /* Bug Name : the normal users are being displayed as a star user and for a normal user the call and video call buttons are not being displayed
                 Fix Date : 21/06/2021
                 Fixed By : Jayaram G
                 Description Of Fix : Passing isStar status
                 */
                controller.isNotFromChatList = true
                if contact.isStar == 1 {
                    controller.isStar = true
                }else {
                    controller.isStar = false
                }
                break
            case .createGroup:
                break
            case .addInGroup:
                break
            case .forwardMessage:
                guard let controller = segue.destination as? ChatViewController else { return }
                guard let rowNum = sender as? Int else { return }
                let data = self.followListViewModel.selectedMember[rowNum]
                let docId = Utility.fetchIndividualChatDoc(withReceiverID: data.id, andSecretID: "")
                let contact = Contacts(followModel: data, docId: docId)
                controller.favoriteObj = contact

                break
            }
            
        }
    }
}


//MARK:- Table view delegate and datasource
extension FollowListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followListViewModel.followersFolloweeModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.FollowListTableViewCell) as? FollowListTableViewCell else{fatalError()}
        let model = self.followListViewModel
        let data = model.followersFolloweeModelArray[indexPath.row]
       
    
        cell.setFollowListCellData(model: data)
        switch self.controllerPurpose {
        case .createGroup:
            let searchedArr = model.selectedMember.filter{
                $0.id == data.id
            }
            if searchedArr.count > 0{
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }else{
                tableView.deselectRow(at: indexPath, animated: false)
            }
            if self.followListViewModel.selectedMemberId.contains(data.id ){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            break
        case .addInGroup:
            for  group in self.groupMembers {
                if let memberId = group["memberId"] as? String {
                    print("*****Memebet Id \(memberId)")
                    print("*****Follower Id \(data.id )")
                    if memberId == data.id {
                        cell.selectionStyle = .none
                        cell.isUserInteractionEnabled = false
                        cell.userNameLabel.textColor = UIColor.lightGray
                        cell.userStatusLabel.textColor = UIColor.lightGray
                        break
                    }else{
                        cell.selectionStyle = .default
                        cell.isUserInteractionEnabled = true
                        if #available(iOS 13.0, *) {
                            cell.userNameLabel.textColor = UIColor.label
                            cell.userStatusLabel.textColor = UIColor.label
                        } else {
                            cell.userNameLabel.textColor = UIColor.black
                            cell.userStatusLabel.textColor = UIColor.black
                            // Fallback on earlier versions
                        }
                        
                    }
                }
            }
            break
        case .forwardMessage:
            let searchedArr = model.selectedMember.filter{
                $0.id == data.id
            }
            if self.followListViewModel.selectedMemberId.contains(data.id ){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            if searchedArr.count > 0{
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }else{
                tableView.deselectRow(at: indexPath, animated: false)
            }
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if self.followListViewModel.followersFolloweeModelArray[indexPath.row].isChatEnable !=  1 {
//            Helper.showAlert(head: "Message".localized, message: "You cannot message stars directly".localized + ".")
//            return
//        }
        
        switch controllerPurpose {
        case .createSecretChat:
            let data = self.followListViewModel.followersFolloweeModelArray[indexPath.row]
            self.groupMemeberselected(member: data, sender: indexPath.row)
            break
        case .createGroup:
            /* Bug Name :  Chat Module: While adding a user to a group chat the green highlighted button for the added users is not being displayed appropriately
                                         Fix Date : 1-apr-2021
                                         Fixed By : Vishal D
                                         Description Of Fix : added unique value conditions
                                       */
            let data = self.followListViewModel.followersFolloweeModelArray[indexPath.row]
            if self.followListViewModel.selectedMemberId.contains(data.id ){
                guard let index = self.followListViewModel.selectedMemberId.firstIndex(of: data.id ) else{return}
                self.followListTableview.cellForRow(at: indexPath)?.accessoryType = .none
                self.followListViewModel.selectedMember.remove(at: index)
                self.followListViewModel.selectedMemberId.remove(at: index)
            }else{
                self.followListTableview.cellForRow(at: indexPath)?.accessoryType = .checkmark
                self.followListViewModel.selectedMemberId.append(data.id )
                self.followListViewModel.selectedMember.append(data)
            }
            DispatchQueue.main.async {
//                self.followListTableview.cellForRow(at: indexPath)?.backgroundColor = .lightGray
                self.setCollectionViewHeight(duration: 0.2)
                let index = self.followListViewModel.selectedMember.count - 1
                let indexPathOfItem = IndexPath(item: index, section: 0)
                self.selectedUserCollectionView.insertItems(at: [indexPathOfItem])
                self.scrollToLast()
            }
            break
        case .createSingleChat:
            self.view.endEditing(true)
            self.performSegue(withIdentifier: segueIdentifier.followToChatSegue, sender: indexPath.row)
            tableView.deselectRow(at: indexPath, animated: false)
            break
        case .addInGroup:
            let data = self.followListViewModel.followersFolloweeModelArray[indexPath.row]
            if self.followListViewModel.checkIfAlreadyInGroup(data: data){
                self.followListTableview.deselectRow(at: indexPath, animated: true)
            }else{
                self.openActionSheetToAddParticiapent(index: indexPath)
            }
            
            break
        case .forwardMessage:
            /* Bug Name :  Chat: forward chat and delete message functionality is not working
             Fix Date : 15-apr-2021
             Fixed By : Jayaram G
             Description Of Fix : added unique value conditions
             */
//            let data = self.followListViewModel.followersFolloweeModelArray[indexPath.row]
//            self.followListViewModel.selectedMember.append(data)
            let data = self.followListViewModel.followersFolloweeModelArray[indexPath.row]
            if self.followListViewModel.selectedMemberId.contains(data.id ){
                guard let index = self.followListViewModel.selectedMemberId.firstIndex(of: data.id) else{return}
                self.followListTableview.cellForRow(at: indexPath)?.accessoryType = .none
                self.followListViewModel.selectedMember.remove(at: index)
                self.followListViewModel.selectedMemberId.remove(at: index)
            }else{
                self.followListTableview.cellForRow(at: indexPath)?.accessoryType = .checkmark
                self.followListViewModel.selectedMemberId.append(data.id )
                self.followListViewModel.selectedMember.append(data)
            }
            DispatchQueue.main.async {
//                self.followListTableview.cellForRow(at: indexPath)?.backgroundColor = .lightGray
                self.setCollectionViewHeight(duration: 0.2)
                let index = self.followListViewModel.selectedMember.count - 1
                let indexPathOfItem = IndexPath(item: index, section: 0)
                self.selectedUserCollectionView.insertItems(at: [indexPathOfItem])
                self.scrollToLast()
            }
            break
        
        }
    }
    
    
    /// To present action sheet to add user in group
    private func openActionSheetToAddParticiapent(index: IndexPath){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Add Participant".localized, style: .default) { (action) in
            let contact = self.followListViewModel.getContactObjectForUserAtIndex(index: index.row)
            self.delegate?.selecteGroupMember(contact: contact)
            DispatchQueue.main.async{
                self.navigationController?.popViewController(animated: true)
            }
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel){ (action) in
            DispatchQueue.main.async{
                self.followListTableview.deselectRow(at: index, animated: true)
            }
        }
        alert.addAction(addAction)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        switch self.controllerPurpose {
//
//        case .createGroup:
//            let data = self.followListViewModel.followersFolloweeModelArray[indexPath.row]
//            guard let index = self.followListViewModel.selectedMember.firstIndex(of: data) else{return}
//            self.followListViewModel.selectedMember.remove(at: index)
//            /* Bug Name :  Chat Module: While adding a user to a group chat the green highlighted button for the added users is not being displayed appropriately
//                                         Fix Date : 1-apr-2021
//                                         Fixed By : Vishal D
//                                         Description Of Fix : added background color and removed same selection
//                                       */
//            DispatchQueue.main.async{
//                self.followListTableview.cellForRow(at: indexPath)?.accessoryType = .none
//                self.followListTableview.cellForRow(at: indexPath)?.backgroundColor = .white
//                self.setCollectionViewHeight(duration: 0.2)
//                let indexPathOfItem = IndexPath(item: index, section: 0)
//                self.selectedUserCollectionView.deleteItems(at: [indexPathOfItem])
//                self.scrollToLast()
//            }
//            break
//        case .forwardMessage:
//            /* Bug Name :  Chat: forward chat and delete message functionality is not working
//             Fix Date : 15-apr-2021
//             Fixed By : Jayaram G
//             Description Of Fix : added background color and removed same selection
//             */
//            let data = self.followListViewModel.followersFolloweeModelArray[indexPath.row]
//            guard let index = self.followListViewModel.selectedMember.index(of: data) else{return}
//            self.followListViewModel.selectedMember.remove(at: index)
//            DispatchQueue.main.async{
//                self.followListTableview.cellForRow(at: indexPath)?.accessoryType = .none
//                self.followListTableview.cellForRow(at: indexPath)?.backgroundColor = .white
//                self.setCollectionViewHeight(duration: 0.2)
//                let indexPathOfItem = IndexPath(item: index, section: 0)
//                self.selectedUserCollectionView.deleteItems(at: [indexPathOfItem])
//                self.scrollToLast()
//            }
//            break
//        default:
//            break
//        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let indexPassed = indexPath.row >= self.followListViewModel.followersFolloweeModelArray.count - 5
        if canServiceCall && indexPassed{
            self.canServiceCall = false
            self.followFolloweServiceCall(strUrl: AppConstants.followersFollowee + "?")
        }
    }
    
    
    
    func groupMemeberselected(member: FollowersFolloweeModel,sender: Int) {
        let secretID = Helper.randomString(length: 100)
        let individualChatDocVMObject = IndividualChatViewModel(couchbase: couchbase)
        guard let rowNum = sender as? Int else { return }
        let data = self.followListViewModel.followersFolloweeModelArray[rowNum]
        let docId = Utility.fetchIndividualChatDoc(withReceiverID: data.id, andSecretID: "")
        let contact = Contacts(followModel: data, docId: docId)
        guard let chatDocID = individualChatDocVMObject.getChatDocID(withreceiverID: member.id, andSecretID: secretID , withContactObj: contact, messageData: nil, destructionTime: 0, isCreatingChat: false) else {
            return
        }
        
        //send Secrect Chat init to MQTT
        guard let userNumber = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String else {return}
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        var params = [String :Any]()
        params["from"] = Utility.getUserid() as Any
        params["to"] = member.id as Any
        params["payload"] = "".toBase64() as Any
        params["toDocId"] = chatDocID as Any
        params["timestamp"] = "\(timeStamp)" as Any
        params["id"] = "\(timeStamp)" as Any
        params["type"] = "0" as Any
        params["name"] = Utility.getUserName() as Any
        params["receiverIdentifier"] =  userNumber as Any
        params["secretId"] = secretID
        params["dTime"]  = 0
        
        UserDefaults.standard.set(0, forKey: secretID) //remove this timer while delete Secret Chat
        DispatchQueue.global().async {
            MQTTChatManager.sharedInstance.sendMessage(toChannel:member.id , withMessage: params, withQOS: .atLeastOnce)
        }
        
        let storKey = ["isCreated":true,
                       "docId": chatDocID] as [String : Any]
        UserDefaults.standard.set(storKey, forKey: "isCreatingNewGroupPress")
        
        //        if  let tabbar =   UIApplication.shared.windows[0].rootViewController as? UITabBarController{
        //            tabbar.selectedIndex = 1
        //        }
        self.navigationController?.popViewController(animated: true)
    }
    
}


