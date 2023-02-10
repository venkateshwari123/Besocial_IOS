//
//  BusinessConfigurationViewController.swift
//  Starchat
//  jayaram G
//  Created by Rahul Sharma on 24/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
class BusinessConfigurationViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var configurationTableView: UITableView!
     @IBOutlet weak var chatEnableSwitchOutlet: UISwitch!
    
    
    let profileVmObject = ProfileViewModel() // Used for profileViewModel Object Reference
    let chatSwitchVmObject = ChatSwitchViewModel()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.businessConfiguration.localized)
       // configurationTableView.tableFooterView = UIView()
        if let businessDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessDetails) as? [[String:Any]]{
            if let isChatVisible = businessDetails.first?["isChatVisible"] as?  Int {
                if isChatVisible == 1 {
                self.chatEnableSwitchOutlet.isOn = true
                }else {
                    self.chatEnableSwitchOutlet.isOn = false
                }
             }
        }
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
  
    @IBAction func chatEnableSwitchAction(_ sender: UISwitch) {
        if chatEnableSwitchOutlet.isOn {
            chatSwitchApiCall(state: true)
        }else {
            chatSwitchApiCall(state: false)
        }
    }
 
    func chatSwitchApiCall(state:Bool) {
        let strUrl = AppConstants.businessChat
        chatSwitchVmObject.businessChatStatusChangingApiCall(strUrl: strUrl, status: state) { (finished, error) in
            if finished {
                print("updated successfully")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshHomeScreen), object: nil)
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
    
    
}

//MARK:- Tableview Delegate & Datasource Methods
extension BusinessConfigurationViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let businessConfigCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.BusinessConfigurationCellId, for: indexPath) as! BusinessConfigurationCell
        switch indexPath.row {
        case 0:
            businessConfigCell.lblConfigurationOptions.text = Strings.email.localized
        default:
            businessConfigCell.lblConfigurationOptions.text = Strings.phoneNumber.localized
        }
        
        return businessConfigCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            /// Pushing To BusinessEmailConfigurationViewController
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessEmailVcId = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessEmailConfigurationViewControllerId) as! BusinessEmailConfigurationViewController
            if let businessEmailDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessEmail) as? [String:Any]{
                if let isEmailVisible = businessEmailDetails["isVisible"] as? Bool{
                    businessEmailVcId.isEmailVisible = isEmailVisible
                }
            }
            self.navigationController?.pushViewController(businessEmailVcId, animated: true)
        default:
            /// Pushing To BusinessMobileConfigurationViewController
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessMobileVcId = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessMobileConfigurationViewControllerId) as! BusinessMobileConfigurationViewController
            if let businessPhoneDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessMobileNumber) as? [String:Any]{
                if let isNumberisVisible = businessPhoneDetails["isVisible"] as? Bool{
                    businessMobileVcId.visibleMobileNumberInteger = isNumberisVisible
                }
                /*
                 Bug Name:- bussiness phone show two time countrycode
                 Fix Date:- 20/04/21
                 Fixed By:- Nikunj C
                 Description of Fix:- add required field 
                 */
                
                if let businessNumber = businessPhoneDetails["number"] as? String{
                    businessMobileVcId.mobileNumber = businessNumber
                }
                if let countryCode = businessPhoneDetails["countryCode"] as? String{
                    businessMobileVcId.countryCode = countryCode
                }
                
            }
            businessMobileVcId.isFromEditBusniess = true
            self.navigationController?.pushViewController(businessMobileVcId, animated: true)
        }
    }
}
