//
//  AcceptOrDeleteViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 12/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol AcceptOrDeleteViewControllerDelegate: class {
    func updateDataOfYouActivity()
}

class AcceptOrDeleteViewController: UIViewController {

    
    @IBOutlet weak var acceptOrDeleteTableview: UITableView!
    @IBOutlet weak var noFollowingLbl: UILabel!
    
    @IBOutlet weak var noRequestView: UIView!
//    var requestedChannleArray = [RequestedChannelModel]()
//    var followRequestArray = [FollowRequestModel]()
    var isChannel: Bool = false
    var isCommingFromPush: Bool = false
    
    var isChanged: Bool = false
    weak var delegate: AcceptOrDeleteViewControllerDelegate?
    var acceptOrDeleteViewModel = AcceptOrDeleteViewModel()
    
    struct cellIdentifier {
        static let acceptOrDeleteTableViewCell = "acceptOrDeleteTableViewCell"
    }
    
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if isChannel{
            self.title = "Channel Request".localized
        }else{
            self.title = "Follow Request".localized
        }
        self.noFollowingLbl.text = "There is no following activity".localized + "."
        if self.isCommingFromPush{
            self.getRequestServiceCall()
        }
        
        self.setNoRequestUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    /// to set no request view according to object in request array
    func setNoRequestUI(){
        if isChannel && self.acceptOrDeleteViewModel.requestedChannleArray.count > 0{
            self.noRequestView.isHidden = true
        }else if self.acceptOrDeleteViewModel.followRequestArray.count > 0{
            self.noRequestView.isHidden = true
        }else{
            self.noRequestView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isChanged && (delegate != nil){
            delegate?.updateDataOfYouActivity()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button Action
    
    @IBAction func backButtonAction(_ sender: Any) {
        if self.isCommingFromPush{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK:- Service call
    func getRequestServiceCall(){
        Helper.showPI()
        if isChannel{
            ///to get subscribe request
             let strUrl = AppConstants.RequestedChannels
            self.acceptOrDeleteViewModel.getRequestServiceCall(strUrl: strUrl, requestType: .channel) { (success, error) in
                if success{
                    self.setNoRequestUI()
                    self.acceptOrDeleteTableview.reloadData()
                }else if let error = error{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                Helper.hidePI()
            }
        }else{
            ///to get follow request
            let strUrl = AppConstants.followRequest
            self.acceptOrDeleteViewModel.getRequestServiceCall(strUrl: strUrl, requestType: .user) { (success, error) in
                if success{
                    self.setNoRequestUI()
                    self.acceptOrDeleteTableview.reloadData()
                }else if let error = error{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                Helper.hidePI()
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AcceptOrDeleteViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isChannel{
            return acceptOrDeleteViewModel.requestedChannleArray.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isChannel{
            return acceptOrDeleteViewModel.requestedChannleArray[section].requestedUserList.count
        }
        return self.acceptOrDeleteViewModel.followRequestArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.acceptOrDeleteTableViewCell) as? AcceptOrDeleteTableViewCell else {fatalError()}
        if isChannel{
            let model = acceptOrDeleteViewModel.requestedChannleArray[indexPath.section]
            let channelName = model.channleName
            cell.setCellForRequestedChannel(channelName: channelName!, modelData: model.requestedUserList[indexPath.row])
        }else{
            cell.setCellDataForFollowRequest(modelData: self.acceptOrDeleteViewModel.followRequestArray[indexPath.row])
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}

//MAKR:- AcceptOrDeleteViewController delegate
extension AcceptOrDeleteViewController: AcceptOrDeleteTableViewCellDelegate{
  
    func didAcceptButtonSelected(cell: AcceptOrDeleteTableViewCell) {
        if isChannel{
            requestChannelService(isAccept: true, cell: cell)
        }else{
            requestUserService(isAccepted: true, cell: cell)
        }
    }
    
    func didDeleteButtonSelected(cell: AcceptOrDeleteTableViewCell) {
        if isChannel{
            requestChannelService(isAccept: false, cell: cell)
        }else{
            requestUserService(isAccepted: false, cell: cell)
        }
    }
    
    ///service call to accept and delete channel request
    func requestChannelService(isAccept: Bool, cell: AcceptOrDeleteTableViewCell){
        
        guard let indexPath = acceptOrDeleteTableview.indexPath(for: cell) else{return}
        let channelData = acceptOrDeleteViewModel.requestedChannleArray[indexPath.section]
        acceptOrDeleteViewModel.acceptOrDeleteChannelRequest(channelData: channelData, isAccepted: isAccept, row: indexPath.row){ (success, error) in
            if success{
                
                self.acceptOrDeleteViewModel.requestedChannleArray[indexPath.section].requestedUserList.remove(at: indexPath.row)
                self.acceptOrDeleteTableview.deleteRows(at: [indexPath], with: .automatic)
                self.isChanged = true
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
            self.setNoRequestUI()
        }
    }
    
    ///service call to accept and delete user request
    func requestUserService(isAccepted: Bool, cell: AcceptOrDeleteTableViewCell){
        
        guard let indexPath = acceptOrDeleteTableview.indexPath(for: cell) else{return}
        let channelData = self.acceptOrDeleteViewModel.followRequestArray[indexPath.row]
        let targetId = channelData.followId!
        acceptOrDeleteViewModel.acceptOrDeleteUserRequest(status: isAccepted, targetId: targetId) { (success, error) in
            if success{
                if self.acceptOrDeleteViewModel.followRequestArray.count > indexPath.row{
                    self.acceptOrDeleteViewModel.followRequestArray.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.acceptOrDeleteTableview.deleteRows(at: [indexPath], with: .automatic)
                        self.isChanged = true
                    }
                }
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
            self.setNoRequestUI()
        }
    }
    
    
}
