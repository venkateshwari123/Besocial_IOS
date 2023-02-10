//
//  SettingViewController.swift
//  MQTT Chat Module
//  jayaram G
//  Created by 3Embed Software Tech Pvt Ltd on 17/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
import MessageUI
import Contacts
import ContactsUI
import Kingfisher
class SettingViewController: UIViewController {
    
    //MARK:- All Outlets
    @IBOutlet weak var settingTabelView: UITableView!
    
    //MARK:- Declarations&Constants
    var isChanged: Bool = false    // used to check Details changed or not
    var isVerifiedStarProfile:Bool = false    // used to check verified profile or not
    //    CBLQueryEnumerator *result;
    var result: CBLQueryEnumerator?     // Used for Database
    let profileViewModel = ProfileViewModel()
    var switchBusinessTitle:String = ""
    
    struct segueIdentifier {
        static let blockedUserSegue = "blockedUserSegue"
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.settingTabelView.tableFooterView = UIView()
        if #available(iOS 15.0, *) {
            self.settingTabelView.sectionHeaderTopPadding = 0
        }
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        DispatchQueue.main.async {
            self.settingTabelView.reloadData()
        }
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Settings".localized)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    /// Show alert for logout operation confiration from user
    func showAlertPopUpOfLogOut(){
        let alert = UIAlertController(title: nil, message: Strings.logOutMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok.localized, style: .default) { [weak self] (action) in
            self?.logOutServicecall()
        }
        let cancelAction = UIAlertAction(title: Strings.cancel.localized, style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /*feature Name :- add delete account option in setting viewcontroller
      Fix Date :- 22/03/2021
      Fixed By :- Nikunj C
      Description Of feature :- add alert popup for delete account */
    
    /// Show alert for delete  operation confiration from user
    func showAlertPopUpOfDeleteAccount(){
        let alert = UIAlertController(title: nil, message: Strings.deleteAccoutMessage.localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok.localized, style: .default) { [weak self] (action) in
            self?.deleteAccountServiceCall()
            
        }
        let cancelAction = UIAlertAction(title: Strings.cancel.localized, style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Service Call
    /// To make service call, remove data from database and unsubscribe topics
    func logOutServicecall(){
        let socialApi = SocialAPI()
        Helper.showPI(_message: Strings.logingOut.localized)
        socialApi.postSocialData(with: AppConstants.logout, params: [:]) { (success, error) in
            Utility.logOut()
            DispatchQueue.main.async{
                Helper.hidePI()
            }
        }
    }
    
    /*feature Name :- add delete account option in setting viewcontroller
      Fix Date :- 22/03/2021
      Fixed By :- Nikunj C
      Description Of feature :- service for delete account */
    
    func deleteAccountServiceCall(){
        let socialApi = SocialAPI()
        Helper.showPI(_message: Strings.deleteAccount.localized)
        socialApi.deleteSocialData(with: AppConstants.deleteAccount, params: [:]) { (success, error) in
            if success != nil{
               Utility.logOut()
            }else if let err = error{
                DispatchQueue.main.async{
                    Helper.showAlertViewOnWindow(err.localizedTitle, message: err.localizedDescription)
                }
            }
            DispatchQueue.main.async{
                           Helper.hidePI()
                       }
        }
        
    }
    
    func swithBusinessAccount() {
        var businessCategoryId: String = ""
      //   if self.profileViewModel.userProfileModel?.businessDetails != nil {
        if let busienssCategoryIdObj = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessCategoryID) as? String {
            businessCategoryId = busienssCategoryIdObj
        }
            let businessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool
            if businessProfile == true{
                let url = AppConstants.business
                self.profileViewModel.getBusinessStatus(strUrl: url, status: false, businessCategoryid: businessCategoryId) { (isFinishSuccessfully, error) in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                    if isFinishSuccessfully {
                        Utility.unsubscribeAllMQTTTopics()
                        URLCache.shared.removeAllCachedResponses()
                        let cache = ImageCache.default
                        cache.clearMemoryCache()
                        cache.clearDiskCache { print("Done") }
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
                        self.settingTabelView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
                           Helper.hidePI()
                    }
                }
            }else {
                
                if let privateAccount = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isPrivate) as? Bool {
                    if privateAccount {
                        Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.businessPublicAlertMessage.localized)
                    }else{
                        let url = AppConstants.business
                        self.profileViewModel.getBusinessStatus(strUrl: url, status: true, businessCategoryid: businessCategoryId) { (isFinishSuccessfully, error) in
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                            if isFinishSuccessfully {
                                  Utility.unsubscribeAllMQTTTopics()
                                 Helper.hidePI()
                                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
                       self.settingTabelView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
                            }
                            }
                        }
                    }
                }
            }
    }

//MARK:- Table view delegate and datasource
extension SettingViewController: UITableViewDataSource, UITableViewDelegate{
    
    // No.of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    // no.of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            var number = 1
          if let isStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool {
                    if isStarVerified {
                        number = 2
                    }else {
                        number = 1
                    }
                }
            return number
        case 1:
            return 2
        case 2:
            return 8
        case 3:
            return 1
        case 4:
            // return 4
            return 3
        case 5:
            return 1
        default:
            return 0
        }
    }
    
    // cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        /*
         Bug Name:- setting page some strings are not localize
         Fix Date:- 4th Sep 2021
         Fixed By:- Nikunj C
         Description of Fix:- localize need some time to check userdefault value to translate
         */
        if indexPath.section == 3{
            let titleCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.settingAppModeTableViewCell) as! SettingAppModeTableViewCell
            switch indexPath.row{
            case 0:
                titleCell.settingTitleLabel.text = "Dark Mode".localized
                return titleCell
            default:
                return UITableViewCell()
            }
        }
        
        let titleViewCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.SettingsTitleViewCellId, for: indexPath) as! SettingsTitleViewCell
        
        switch indexPath.section {
        case 0:
            titleViewCell.settingcellImageView.isHidden = false
            switch indexPath.row {
            case 0:
                titleViewCell.settingTitleLabel.text = "Get Verified Profile".localized
                return titleViewCell
            case 1:
                titleViewCell.settingTitleLabel.text = "Subscription Settings".localized
                return titleViewCell
            case 2:
                titleViewCell.settingTitleLabel.text = "Verified Configuration".localized
                return titleViewCell
            default:
                return UITableViewCell()
            }
        case 1:
            titleViewCell.settingcellImageView.isHidden = false
            switch indexPath.row{
            case 0:
                if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
                    if businessProfileCreated {
                        titleViewCell.settingTitleLabel.text = "Switch To Personal Profile".localized
                    }else {
                        titleViewCell.settingTitleLabel.text = "Switch To Business Profile".localized
                    }
                }
                       return titleViewCell
            case 1:
                titleViewCell.settingTitleLabel.text = "Business Profile".localized
                
                return titleViewCell
            case 2:
                titleViewCell.settingTitleLabel.text = "Business Configuration".localized
                
                return titleViewCell
            default:
                return UITableViewCell()
            }
        case 2:
            titleViewCell.settingcellImageView.isHidden = false
            switch indexPath.row{
            case 0:
                titleViewCell.settingTitleLabel.text = "Invite Contacts".localized
                
                return titleViewCell
            case 1:
                titleViewCell.settingTitleLabel.text = "My Subscriptions".localized
                
                return titleViewCell
            case 2:
                titleViewCell.settingTitleLabel.text = "Blocked Users".localized
                
                return titleViewCell
            case 3:
                titleViewCell.settingTitleLabel.text = "Saved".localized
                
                return titleViewCell
            case 4:
                titleViewCell.settingTitleLabel.text = "Change Password".localized
                                
                return titleViewCell
            case 5:
                titleViewCell.settingTitleLabel.text = "Report A Problem".localized
                
                return titleViewCell
            case 6:
                titleViewCell.settingTitleLabel.text = "Delete Account".localized
                
                return titleViewCell
            case 7:
                titleViewCell.settingTitleLabel.text = "Change Language".localized
                return titleViewCell
            default:
                return UITableViewCell()
            }
        case 4:
            titleViewCell.settingcellImageView.isHidden = false
            switch indexPath.row{
            case 0:
                titleViewCell.settingTitleLabel.text = "About".localized
                return titleViewCell
            case 1:
                
                titleViewCell.settingTitleLabel.text = "Privacy Policy".localized
                return titleViewCell
            case 2:
                
                titleViewCell.settingTitleLabel.text = "Terms Of Service".localized
                return titleViewCell
            case 3:
                
                titleViewCell.settingTitleLabel.text = "General".localized
                return titleViewCell
            case 4:
                
                titleViewCell.settingTitleLabel.text = "Help".localized + " & " + "Feedback".localized
                return titleViewCell
//            case 4:
//                titleViewCell.settingTitleLabel.text = Strings.settingsTitles.services.localized
//                return titleViewCell
            default:
                return UITableViewCell()
            }
        case 5:
            switch indexPath.row{
            case 0:
                
                titleViewCell.settingTitleLabel.text = "Logout".localized
                titleViewCell.settingcellImageView.isHidden = true
                return titleViewCell
            default:
                return UITableViewCell()
            }
        default:
            switch indexPath.row{
            case 0:
                return UITableViewCell()
            default:
                return UITableViewCell()
            }
        }}
    
    
    // height for row at
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            var height:CGFloat = 0.0
            if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
                if businessProfileCreated {
                        height = 0
                }else {
                    if let isStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool {
                        if isStarVerified {
                            switch indexPath.row {
                            case 0,1:
                                return 50
                            default:
                                return 50
                            }
                            
                        }else {
                            switch indexPath.row{
                            case 0:
                                return 50
                            case 1:
                                return 0
                            default:
                                return 50
                            }
                        }
                    }
                }
                }
            return height
        }
        else if indexPath.section == 1 {
            switch indexPath.row{
            case 0,2:
                var height:CGFloat = 0.0
                if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isBusinessProfileApproved) as? Bool {
                    if businessProfileCreated {
                            height = 50.0
                        }
                    }else {
                        height = 0
                    }
                return height
             case 1:
                var height:CGFloat = 50.0
                if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isBusinessProfileApproved) as? Bool {
                    if businessProfileCreated {
                        height = 0.0
                        }
                    }else {
                        height = 50.0
                    }
                return height
            default:
                return 50
            }
        }
        
        /*
         Bug Name:- Settings->While using business profile my subscription button should not show
         Fix Date:- 21st Sep 2021
         Fixed By:- Nikunj C
         Description of Fix:- for business profile hide mysubscription
         */
        
        else if indexPath.section == 2{
            switch indexPath.row{
            case 1:
                var height:CGFloat = 50.0
                if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
                    if businessProfileCreated {
                            height = 0
                        }
                    }else {
                        height = 50.0
                    }
                return height
            default:
                return 50
            }
        }
        else if indexPath.section == 3{
            return 0
        }
      
        return 50
    }

    // heightForHeaderInSection
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
                if businessProfileCreated {
                        return 0
                }else {
                    return 45                }
                }
        }
        else if section == 3{
            return 0
        }
        return 45
    }
    
    // viewForHeaderInSection
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.SettingsHeaderViewCellId) as! SettingHeaderViewCell
        headerCell.titleLabel.isHidden = false
        headerCell.titleImage.isHidden = false
        switch section {
        case 0:
            headerCell.titleLabel.text = Strings.settingsHeaderTitles.starProfile.localized
            headerCell.titleImage.image = #imageLiteral(resourceName: "verified profile")
        case 1:
            headerCell.titleLabel.text = Strings.settingsHeaderTitles.businessProfile.localized
            headerCell.titleImage.image = #imageLiteral(resourceName: "Group 2817")
        case 2:
            headerCell.titleLabel.text = Strings.settingsHeaderTitles.account.localized
            headerCell.titleImage.image =  #imageLiteral(resourceName: "Group 2548")
        case 3:
            headerCell.titleLabel.text = Strings.settingsHeaderTitles.theme.localized
            headerCell.titleImage.image =  #imageLiteral(resourceName: "theme_icon")
        case 4:
            headerCell.titleLabel.text = Strings.settingsHeaderTitles.support.localized
            headerCell.titleImage.image = #imageLiteral(resourceName: "settings")
        case 5:
            headerCell.titleLabel.isHidden = true
            headerCell.titleImage.isHidden = true
        case 6:
            headerCell.titleLabel.isHidden = true
            headerCell.titleImage.isHidden = true
        default:
            break
        }
        return headerCell.contentView
        
    }
    
    
    // didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                /// Pushing To RequestStarProfileViewController
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let requestStarProfileVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.RequestStarProfileViewController) as! RequestStarProfileViewController
                self.navigationController?.pushViewController(requestStarProfileVc, animated: true)
            case 1:
                 guard let confirmationVC = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil).instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SubscriptionVC) as? SubscriptionPopup else {return}
                       confirmationVC.modalPresentationStyle = .overCurrentContext
                       self.navigationController?.present(confirmationVC, animated: true)
            case 2:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let businessConfigurationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessConfigurationCellId) as! StarConfigurationViewController
                self.navigationController?.pushViewController(businessConfigurationVc, animated: true)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                print("switch to business api call")
                swithBusinessAccount()
//                if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile) as? Bool, businessProfileCreated {
//                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
//                    let ProfileVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.profileViewControllerId) as! ProfileViewController
//                    self.navigationController?.pushViewController(ProfileVc, animated: true)
//                }else {
//                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
//                    let businessProfileVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.createBusinessProfileVcId) as! CreateBusinessProfileViewController
//                    self.navigationController?.pushViewController(businessProfileVc, animated: true)
//                }
            case 1:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let businessProfileVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.createBusinessProfileVcId) as! CreateBusinessProfileViewController
                self.navigationController?.pushViewController(businessProfileVc, animated: true)
            case 2:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let businessConfigurationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessConfigurationVcId) as! BusinessConfigurationViewController
                self.navigationController?.pushViewController(businessConfigurationVc, animated: true)
            default:
                break
            }
        case 2:
            switch indexPath.row{
            case 0:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let inviteContactVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.inviteContactsViewControllerId) as! InviteContactsViewController
                self.navigationController?.pushViewController(inviteContactVc, animated: true)
            case 1:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let subscriptionsVc = mainStoryboard.instantiateViewController(withIdentifier: "SubscriptionsViewController") as! SubscriptionsViewController
                self.navigationController?.pushViewController(subscriptionsVc, animated: true)
            case 2:
                self.performSegue(withIdentifier: segueIdentifier.blockedUserSegue, sender: nil)
            case 3:
                /*
                 Bug Name:- Saved button not clickable>>goto profile page>>click on settings>> click on saved button
                 Fix Date:- 24/07/21
                 Fix By  :- Jayaram G
                 Description of Fix:- Handled dubly and picoadda tabbar
                 */
                if AppConstants.appType == .picoadda {
                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                    let collectionVC = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SavedCollectionsViewController) as! SavedCollectionsViewController
                    collectionVC.hidesBottomBarWhenPushed = true
                    if let tabbarVC : TabbarController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? TabbarController{
                        print(tabbarVC.viewControllers as Any)
                        if let nav = (tabbarVC.viewControllers![tabbarVC.selectedIndex] as? SwipeNavigationController){
                            nav.pushViewController(collectionVC, animated: true)
                        }
                    }
                }else{
                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                    let collectionVC = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SavedCollectionsViewController) as! SavedCollectionsViewController
                    collectionVC.hidesBottomBarWhenPushed = true
                    if let tabbarVC : DublyTabbarViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? DublyTabbarViewController{
                        print(tabbarVC.viewControllers as Any)
                        if let nav = (tabbarVC.viewControllers![tabbarVC.selectedIndex] as? SwipeNavigationController){
                            nav.pushViewController(collectionVC, animated: true)
                        }
                    }
                }
                
            case 4:
                // change password
                guard  let resetPasswordVC =  UIStoryboard.init(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordViewController") as? ChangePasswordViewController else  { return }
              navigationController?.pushViewController(resetPasswordVC, animated: true)
                break
            case 5:
                openMailView()
                break
            case 6:
                self.showAlertPopUpOfDeleteAccount()
            case 7:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                let langVc = mainStoryboard.instantiateViewController(withIdentifier: "LanguageChooseViewController" ) as! LanguageChooseViewController
                self.navigationController?.pushViewController(langVc, animated: true)
            default:
                break
            }
        case 4:
            switch indexPath.row{
            case 0:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
                let aboutVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.aboutVcId) as! AboutViewController
                aboutVc.i = 1 // About
                self.navigationController?.pushViewController(aboutVc, animated: true)
            case 1:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
                let aboutVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.aboutVcId) as! AboutViewController
                aboutVc.i = 2 // pricvacy policy
                self.navigationController?.pushViewController(aboutVc, animated: true)
            case 2:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
                let aboutVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.aboutVcId) as! AboutViewController
                aboutVc.i = 3 // terms and confdtions
                self.navigationController?.pushViewController(aboutVc, animated: true)
            case 3:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
                let aboutVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.aboutVcId) as! AboutViewController
                aboutVc.i = 4 // general
                self.navigationController?.pushViewController(aboutVc, animated: true)
            case 4:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
                let aboutVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.aboutVcId) as! AboutViewController
                aboutVc.i = 5 // help and feedback
                self.navigationController?.pushViewController(aboutVc, animated: true)
            case 5:
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
                let aboutVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.aboutVcId) as! AboutViewController
                aboutVc.i = 6 // services
                self.navigationController?.pushViewController(aboutVc, animated: true)
                
            default:
                break
            }
        case 5:
            switch indexPath.row{
            case 0:
//                Utility.logOut()
                self.showAlertPopUpOfLogOut()
            default:
                break
            }
        default:
            switch indexPath.row{
            case 1:
                break
            default:
                break
            }
        }}
    
   
    
    
    //Share sheet
    func displayShareSheet() {
        let activityViewController = UIActivityViewController(activityItems: ["Hey".localized + "! " + "join me on".localized + " \(AppConstants.AppName)," + " " + "This cool new social app".localized + ".",AppConstants.AppUrl], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
  
    
    /// To invite people for app
    func inviteAction(){
        
        let activityController = UIActivityViewController.init(activityItems: ["Hey".localized + "! " + "join me on".localized + " \(AppConstants.AppName)," + " " + "This cool new social app".localized + ".",AppConstants.AppUrl], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
    }
    
    
    
    /// To open mail for report
    func openMailView(){
        if MFMailComposeViewController.canSendMail(){
            let mailView = MFMailComposeViewController()
            mailView.setToRecipients([AppConstants.AppMailId])
            mailView.setSubject("Report a problem".localized)
            let deviceId: String = UIDevice.current.identifierForVendor!.uuidString
            let deviceName = UIDevice.current.name
            let deviceOS = UIDevice.current.systemVersion
            let deviceModel = UIDevice.modelName
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            let msgBody = "</br> </br> </br> </br> </br> ------------------------------- </br>Device Id: \(deviceId)</br>Device Name: \(deviceName)</br>Device OS: \(deviceOS)</br>Model Number: \(deviceModel)</br>Device Type: iOS</br>App Version: \(appVersion)"
            mailView.setMessageBody(msgBody, isHTML: true)
            mailView.mailComposeDelegate = self
            self.present(mailView, animated: true, completion: nil)
        }else{
            Helper.showAlertViewOnWindow("Oops".localized, message: "Mail services are not available.".localized)
        }
    }
    
    //    func openWebView(index: Int){
    //        guard let documentVC = self.storyboard?.instantiateViewController(withIdentifier: storyboardId.DocumentViewerViewController) as? DocumentViewerViewController else {return}
    //        documentVC.isComingfromSetting = true
    //        switch index {
    //        case 0:
    //            documentVC.webURL = AppConstants.About
    //            documentVC.titleName = "About".localized
    //            break
    //        case 1:
    //            documentVC.webURL = AppConstants.PrivacyPolicy
    //            documentVC.titleName = "Privacy Policy".localized
    //            break
    //        case 2:
    //            documentVC.webURL = AppConstants.TermsConditions
    //            documentVC.titleName = "Terms of Srvices".localized
    //            break
    //        case 4:
    //            self.logOut()
    //            return
    //        default:
    //            return
    //        }
    //        self.navigationController?.pushViewController(documentVC, animated: true)
    //    }
    
    
    
    
}


// MARK: - MFMailComposeViewControllerDelegate
extension SettingViewController: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        
        switch result {
        case .cancelled:
            self.dismiss(animated: true, completion: nil)
            break
        case .failed:
            Helper.showAlertViewOnWindow(Strings.oops.localized, message: Strings.failedToSendMail.localized)
            self.dismiss(animated: true, completion: nil)
            break
        case .saved:
            Helper.showAlertViewOnWindow(Strings.oops.localized, message: Strings.failedToSendMail.localized)
            self.dismiss(animated: true, completion: nil)
            break
        case .sent:
            Helper.showAlertViewOnWindow(Strings.oops.localized, message: Strings.mailSent.localized)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

