//
//  AddContactsViewController.swift
//  Starchat
//
//  Created by 3Embed on 14/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Contacts
import Kingfisher
import APAddressBook
import MessageUI
class AddContactsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {

    @IBOutlet weak var lblNoRecords: UILabel!
    @IBOutlet weak var tblContacts: UITableView!
    @IBOutlet weak var tfSearchContacts: UITextField!
    @IBOutlet weak var noPostview: UIView!
    @IBOutlet weak var findFriendsBtnOutlet: UIButton!
    
    var isFromNewFriendsVc:Bool = false
    var addContactsViewModel : AddContactsViewModel = AddContactsViewModel.init(api: AddContactsAPI())
    var contactStore : CNContactStore = CNContactStore.init()
    var arrContacts : [[String : Any]] = []
    var arrContactsToFollow : [UserProfile] = []
    var arrContactList : [[UserProfile]] = []
    var isFromProfile : Bool = false
    var dictGroupedContacts = Dictionary<AnyHashable, Any>()
    var isSearching : Bool = false
    var searchedContacts : [UserProfile] = []
    var rightButtonitem = UIBarButtonItem()

    var pullToRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblContacts.tableFooterView = UIView.init()
        getContactsFromDevice()
        
        creatDocforGroupChat()
        findFriendsBtnOutlet.makeCornerRadious(readious: 5.0)
        lblNoRecords.text = "None of your contacts are on".localized + " \(AppConstants.AppName)" + ". " + "Invite them to".localized + " \(AppConstants.AppName)" + "."
        tfSearchContacts.placeholder = "Search".localized
        NotificationCenter.default.addObserver(self, selector: #selector(self.getContactsFromDevice), name: NSNotification.Name(rawValue: "RefreshAddContacts"), object: nil)
        
        // Do any additional setup after loading the view.
        self.createMQTTConnection()
        
        self.pullToRefreshControl.addTarget(self, action: #selector(refershContacts), for: .valueChanged)
        self.tblContacts.addSubview(pullToRefreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.isNavigationBarHidden = false
         self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isHidden = false
        if  isFromNewFriendsVc || isFromProfile {
            let rightRefreshButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "reload-icon"), style: .plain, target: self, action: #selector(refershContacts))
            Utility.navigationBarWithLeftRight("Add Contacts".localized, inViewController: self, rightButton: rightRefreshButton, action: #selector(self.btnBack_Tapped(_:)) )
        }else{
            self.navigationController?.isNavigationBarHidden = false
            rightButtonitem = UIBarButtonItem.init(title: "Skip".localized, style: .plain, target: self, action: #selector(btnSkip_Tapped(_:)))
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            rightButtonitem.tintColor = .label
            self.navigationController?.navigationBar.tintColor = .black
            self.navigationItem.rightBarButtonItem = rightButtonitem
            self.navigationItem.title = "Add Contacts".localized
        }
        self.tabBarController?.tabBar.isHidden = true
        tblContacts.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
      //  self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        self.pullToRefreshControl.didMoveToSuperview()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func creatDocforGroupChat(){
        //Creat FirstTime GroupChatsDocument here
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument) as? String
        if documentID ==  nil{
            //            let contactDocID = favObj?.couchbase.createDocument(withProperties: ["GroupChatsDocument":["i":"i"]] as [String : Any])
            let contactDocID =   Couchbase.sharedInstance.createDocument(withProperties: ["GroupChatsDocument":["i":"i"]] as [String : Any])
            UserDefaults.standard.set(contactDocID, forKey: AppConstants.UserDefaults.GroupChatsDocument)
        }
    }
    
    
    
    
    
    func createMQTTConnection() {
                let mqttModel = MQTT.sharedInstance
                mqttModel.createConnection()
                //        self.subscribeAllMQTTTopics()
           }
    
    //MARK:- Button Actions
    
    @objc func refershContacts() {
        self.pullToRefreshControl.endRefreshing()
        self.pullToRefreshControl.isHidden = true
        getContactsFromDevice()
    }
    
    @IBAction func findFriends_Action(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.Trending, bundle: nil)
        guard let searchViewController = storyBoard.instantiateViewController(withIdentifier: controllerIdentifierName.searchViewController) as? SearchViewController else {return}
        searchViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchViewController, animated: false)
    }
    
    @IBAction func btnSkip_Tapped(_ sender: Any) {
        if isFromProfile {
            self.dismiss(animated: true, completion: nil)
        }else {
            Route.setRootController()
        }
    }
    
    @objc func btnBack_Tapped(_ sender: Any) {
        /*
         Bug Name:- back button not work in Add Contacts screen
         Fix Date:- 06/05/21
         Fixed By:- Nikunj C
         Description of Fix:- if its comming from profile page dismiss it
         */
        if self.isFromProfile{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    DispatchQueue.main.async {
                        self.pullToRefreshControl.endRefreshing()
                    }
                    
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        
                        self.pullToRefreshControl.endRefreshing()
                         self.pullToRefreshControl.isHidden = true
                        self.pullToRefreshControl.didMoveToSuperview()
                        let message = "Please allow the app to access your contacts through the Settings".localized + "."
                        print(message)
                        let alertController = UIAlertController.init(title: "", message: message, preferredStyle: .alert)
                        let cancel = UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: { (success) in
                            alertController.dismiss(animated: true, completion: nil)
                        })
                        let gotoSettings = UIAlertAction.init(title: "Settings".localized, style: .default, handler: { (settings) in
                            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                        })
                        alertController.addAction(cancel)
                        alertController.addAction(gotoSettings)
                        self.present(alertController, animated: true, completion: nil)
                        completionHandler(false)
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    
    //MARK:- Get Contacts from Device
    @objc func getContactsFromDevice() {
        requestForAccess { (allowed) in
            if allowed{
                let keysToFetch = [
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactPhoneNumbersKey,
                    CNContactEmailAddressesKey,
                    CNContactThumbnailImageDataKey] as [Any]
                let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])


                do {
                    try self.contactStore.enumerateContacts(with: request) {
                        (contact, stop) in
                        //self.contacts.append(contact)
                         
                        /*
                         Bug Name:- contacs saved with countrycode are not fetched
                         Fix Date:- 20th Dec 2021
                         Fixed By:- Nikunj C
                         Description of Fix:- remove contact from
                         */
                        
                        for ContctNumVar: CNLabeledValue in contact.phoneNumbers {
                            let fulMobNumVar  = ContctNumVar.value
                            let MccNamVar = fulMobNumVar.stringValue
                            var countryCode = ""
                            if let countryName = (contact.phoneNumbers[0].value ).value(forKey: "countryCode") as? String{
                                countryCode = Helper.GetCountryCallingCode(countryRegionCode: countryName)
                            }
                           
                            let phoneNumber = MccNamVar.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: countryCode, with: "")
                            self.arrContacts.append(["number":phoneNumber as String,"type":1])
                        }
                        DispatchQueue.main.async {
                        self.tblContacts.reloadData()
                        }
                    }
                }
                catch {
                    print("unable to fetch contacts")
                }
                if self.arrContacts.count > 0{
                    self.getContactsFromAPI()
                }
            }
        }
    }
    
    //MARK:- Get Contacts from API
    func getContactsFromAPI() {
        
        self.addContactsViewModel.fetchContactsToAdd(withuserName: self.arrContacts)
        self.addContactsViewModel.didUpdateContacts = { contacts in
            print(contacts.count)
            self.arrContactsToFollow = contacts
            self.getContactsAlphabeticalyDivided()
            self.tblContacts.reloadData()
            if contacts == [] {
                self.noPostview.isHidden = false
                self.tblContacts.isHidden = true
            }else {
                self.noPostview.isHidden = true
                self.tblContacts.isHidden = false
            }
         }
        self.addContactsViewModel.didError = { error in
            print(error)
        }
    }
    
    //MARK:- Get Contacts Separeted by Alpha
    func getContactsAlphabeticalyDivided(){
        self.arrContactList.removeAll()
        dictGroupedContacts = Dictionary(grouping: arrContactsToFollow) { $0.firstName.uppercased().first ?? "0"}
        for key in dictGroupedContacts.keys{ arrContactList.append(dictGroupedContacts[key] as! [UserProfile]) }
        arrContactList = arrContactList.sorted { $0.first!.firstName.uppercased() < $1.first!.firstName.uppercased() }
        tblContacts.reloadData()
    }
    
    
    //MARK:- TableView DataSource/Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 1 : arrContactList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchedContacts.count : arrContactList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : AddContactsCell = tableView.dequeueReusableCell(withIdentifier: "AddContactsCell") as! AddContactsCell
        let contact = isSearching ? searchedContacts[indexPath.row] : arrContactList[indexPath.section][indexPath.row]
        if contact.isStar {
            cell.starIndicationImage.isHidden = false
        }else {
            cell.starIndicationImage.isHidden = true
        }
        cell.lblUserFullName.text = contact.firstName +  " " + contact.lastName
        cell.lblUserName.text = "@\(contact.userName)"
        
        let userImageUrl = contact.profilePic
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: userImageUrl, imageView: cell.imgProfilePicture, fullName: contact.fullNameWithSpace ?? "")

            if !Utility.isDarkModeEnable(){
                cell.btnAddFollow.makeShadowEffect(color: UIColor.lightGray)
            }
            cell.btnAddFollow.makeCornerRadious(readious: 5.0)
            let borderColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
            cell.btnAddFollow.makeBorderWidth(width: 1, color: borderColor)
            if contact.followStatus == 0{
                var title: String = "Follow".localized
                if contact.isPrivate == 1{
                    title = "Request".localized
                }
                cell.btnAddFollow.setTitle(title, for: .normal)
                cell.btnAddFollow.setTitleColor(borderColor, for: .normal)
                cell.btnAddFollow.backgroundColor = UIColor.white
            }else{
                var title: String = "Following".localized
                if contact.followStatus == 2{
                    title = "Requested".localized
                }
                cell.btnAddFollow.setTitle(title, for: .normal)
                cell.btnAddFollow.setTitleColor(UIColor.white, for: .normal)
                cell.btnAddFollow.backgroundColor = borderColor
            }
        
        
        cell.btnAddFollow.makeBorderWidth(width: 1, color: .lightGray)
        
        cell.btnAddFollow.handleControlEvent(.touchUpInside) {
            self.rightButtonitem.title = "Done".localized
            let borderColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
            if contact.followStatus == 0{
                self.addContactsViewModel.FollowPeopleService(isFollow: true, peopleId: contact.userId, privicy: contact.isPrivate)
                if contact.isPrivate == 1{
                    contact.followStatus = 2
                    cell.btnAddFollow.setTitle("Requested".localized, for: .normal)
                }else {
                    contact.followStatus = 1
                    cell.btnAddFollow.setTitle("Following".localized, for: .normal)
                }
                cell.btnAddFollow.setTitleColor(UIColor.white, for: .normal)
                cell.btnAddFollow.backgroundColor = borderColor
            }
            else {
                self.addContactsViewModel.FollowPeopleService(isFollow: false, peopleId: contact.userId, privicy: contact.isPrivate)
                
                contact.followStatus = 0
                if contact.isPrivate == 1{
                    cell.btnAddFollow.setTitle("Request".localized, for: .normal)
                } else {
                    cell.btnAddFollow.setTitle("Follow".localized, for: .normal)
                }
                
                cell.btnAddFollow.setTitleColor(borderColor, for: .normal)
                cell.btnAddFollow.backgroundColor = UIColor.white
                
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vwHeader = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        vwHeader.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        let lblNameLetter = UILabel.init(frame: CGRect.init(x: 10, y: 0, width: vwHeader.frame.size.width-10, height: vwHeader.frame.size.height))
        if arrContactList.count > section {
            let fullName = arrContactList[section].first?.firstName.capitalized
            lblNameLetter.text = "\(fullName?.first ?? " ")"
        }
        vwHeader.addSubview(lblNameLetter)
        return isSearching ? nil : vwHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isSearching ? 0.1 : 40.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        let data = isSearching ? searchedContacts[indexPath.row] : arrContactList[indexPath.section][indexPath.row]
        /*
             Bug Name:- Handle profile tab for self profile and other profile
             Fix Date:- 22/04/21
             Fix By  :- Jayaram G
             Description of Fix:- Passing flag for to hide tabbar
             */
            profileVC.isNotFromTabBar = true
        profileVC.memberId = data.userId
        profileVC.userProfile = data
        profileVC.followedAction = {
            self.tblContacts.reloadData()
        }
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        if newString.count > 0 {
            isSearching = true
            filterData(string: newString)
        }else {
            isSearching = false

        }
        
        tblContacts.reloadData()
        return true
    }
    
    /*
    Bug Name :  NEW FRIENDS--SEARCH check whether the users in the conatcts are shown according to alphabetical order
    Fix Date : 08-apr-2021
    Fixed By : Vishal D
    Description Of Fix : chaned ignore case
  */

    func filterData(string:String){
        searchedContacts = arrContactsToFollow.filter({$0.firstName.lowercased().contains(string.lowercased())})
        searchedContacts.sort{
            $0.firstName.lowercased() < $1.firstName.lowercased()
        }
        if searchedContacts == [] {
            self.noPostview.isHidden = false
            self.tblContacts.isHidden = true
        }else {
            self.noPostview.isHidden = true
            self.tblContacts.isHidden = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
