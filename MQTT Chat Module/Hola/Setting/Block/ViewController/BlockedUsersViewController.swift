//
//  BlockedUsersViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 19/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
class BlockedUsersViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var blockUserTableView: UITableView!
    @IBOutlet weak var noBlockView: UIView!
    @IBOutlet weak var noBLockUserLabel: UILabel!
    
    //MARK:- Variables&Declarations
    var canServiceCall: Bool = false
    let blockedUserViewModel = BlockedUsersViewModel()
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getBlockedUsers()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Blocked Users".localized
        self.noBLockUserLabel.text = "You have not blocked any users yet".localized + "."
        NotificationCenter.default.addObserver(self, selector: #selector(self.getBlockedUsers), name: NSNotification.Name(rawValue: "updatingBlockedUsers"), object: nil)
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
    
    fileprivate func updateUIForNoBlockUsers(){
        if self.blockedUserViewModel.blockedModelArray.count >= 0 || self.blockedUserViewModel.blockedModelArray == nil{
            self.noBlockView.isHidden = true
        }else{
            self.noBlockView.isHidden = false
        }
    }
    
    @objc func unblockAction(sender: UIButton){
        let alert = UIAlertController(title: Strings.alert.localized, message: Strings.areYouWantToUnBlockThisUser.localized, preferredStyle: UIAlertController.Style.alert)
        let unblockAction = UIAlertAction(title: Strings.unBlock.localized, style: UIAlertAction.Style.default) { (action) in
            let index = sender.tag
            self.unbloackUserAtIndex(index: index)
        }
        let cancel = UIAlertAction(title: "Cancel".localized.localized, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(unblockAction)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// To unblock user at particular index(service call and deleting from array and updating UI)
    ///
    /// - Parameter index: index of user to unblock
    func unbloackUserAtIndex(index: Int){
        let data = self.blockedUserViewModel.blockedModelArray[index]
        self.unblockServiceCall(userId: data.userId!)
        self.blockedUserViewModel.blockedModelArray.remove(at: index)
        DispatchQueue.main.async {
            self.blockUserTableView.beginUpdates()
            self.blockUserTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.blockUserTableView.endUpdates()
            self.updateUIForNoBlockUsers()
        }
    }
    
    //MARK:- Service call
    @objc func getBlockedUsers(){
        Helper.showPI()
        let strUrl = AppConstants.block
        blockedUserViewModel.getBlockedUsersServiceCall(strUrl: strUrl) { (success, error, canServiceCall) in
            if success{
                self.updateUIForNoBlockUsers()
                self.blockUserTableView.reloadData()
            }else if let error = error{
           
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                if error.code == 204{
                     self.noBlockView.isHidden = false
                }
                self.blockedUserViewModel.offset = self.blockedUserViewModel.offset - 20
            }
            self.canServiceCall = canServiceCall
            Helper.hidePI()
        }
    }
    
    
    /// To Unblock the User
    ///
    /// - Parameter userId: userId string
    func unblockServiceCall(userId: String){
        let strURL = AppConstants.blockPersonAPI
        let params = ["opponentId" : userId,
                      "type": "unblock"]
        self.blockedUserViewModel.postUnblockUser(strUrl: strURL,params: params)
        
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension BlockedUsersViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockedUserViewModel.blockedModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.BlockedUserTableViewCell) as? BlockedUserTableViewCell else {fatalError()}
        let data = self.blockedUserViewModel.blockedModelArray[indexPath.row]
        cell.blockButtonOutlet.tag = indexPath.row
        cell.blockButtonOutlet.addTarget(self, action: #selector(BlockedUsersViewController.unblockAction(sender:)), for: .touchUpInside)
        cell.setCellData(modelData: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let indexPassed: Bool = indexPath.row >= self.blockedUserViewModel.blockedModelArray.count - 5
        if self.canServiceCall && indexPassed{
            self.canServiceCall = false
            getBlockedUsers()
        }
    }
}

