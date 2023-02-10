//
//  StarConfigurationViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/6/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
class StarConfigurationViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var configurationTableView: UITableView!
   

    var isChatVisible:Bool = false
    
    var chatSwitchVmObject = ChatSwitchViewModel()
    
    //MARK:-ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.verifiedConfiguration.localized)
       self.configurationTableView.tableFooterView = UIView()
        

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
    
    //MARK:-button Actions
    
    /// popping ViewController
    ///
    /// - Parameter sender: sender description
    @IBAction func backToSettingsVc(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func chatSwitchApiCall(state:Bool) {
        let strUrl = AppConstants.starUserChat
        chatSwitchVmObject.chatStatusChangingApiCall(strUrl: strUrl, status: state) { (finished, error) in
            if finished {
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshUserDetails), object: nil)
            }else{
                print(error?.localizedDescription)
            }
        }
    }
}

//MARK:- Extensions
 // MARK: - UITableViewDelegate,UITableViewDataSource
extension StarConfigurationViewController:UITableViewDelegate,UITableViewDataSource,InvisibleChatCellDelegate{
    func switchingAction(state: Bool) {
        chatSwitchApiCall(state: state)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if indexPath.row == 2 {
             let inVisibleChatCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.invisibleChatCelllId, for: indexPath) as! InvisibleChatCelll
            inVisibleChatCell.invisibleChatCellDelegateObj = self
            
             if let verifiedDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.verifyProfileDetails) as? [String:Any]{
                if let isChatVisible = verifiedDetails["isChatVisible"] as? Int {
                    if isChatVisible == 0 {
                       inVisibleChatCell.chatEnableDiableSwitchOutlet.isOn = false
                    }else{
                       inVisibleChatCell.chatEnableDiableSwitchOutlet.isOn = true
                    }
                }
            }
             return inVisibleChatCell
        }
        let configurationCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.starConfigurationCellId, for: indexPath) as! StarConfigurationCell
        if indexPath.row == 0 {
            configurationCell.titleLabel.text = Strings.email.localized
        }else {
            configurationCell.titleLabel.text = Strings.phoneNumber.localized
        }
        return configurationCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let emailConfigVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.emailConfigurationViewControllerId) as! EmailConfigurationViewController
            if let verifiedDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.verifyProfileDetails) as? [String:Any] {
                emailConfigVc.visibleEmailInteger =  verifiedDetails["isEmailVisible"] as? Int
            }
            self.navigationController?.pushViewController(emailConfigVc, animated: true)
        }else if indexPath.row == 1{
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let mobileConfigVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.mobileConfigurationViewControllerId) as! MobileConfigurationViewController
            if let verifiedDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.verifyProfileDetails) as? [String:Any] {
                mobileConfigVc.visibleMobileNumberInteger =  verifiedDetails["isNumberVisible"] as? Int
            }
            self.navigationController?.pushViewController(mobileConfigVc, animated: true)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 100
        }
        return 50
    }
    
    
    
    
    
    
    
    
    
    
}
