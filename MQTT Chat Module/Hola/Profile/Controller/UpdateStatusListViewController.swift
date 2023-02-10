//
//  UpdateStatusListViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 15/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol UpdateStatusListViewControllerDelegate: class{
    func updatedStatusString(status: String)
}

class UpdateStatusListViewController: UIViewController {
    
    
    /// All Outlets
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var currentStatusView: UIView!
    @IBOutlet weak var currentStatusViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentStatuslabel: UILabel!
    @IBOutlet weak var statusListView: UIView!
    @IBOutlet weak var updateStatusTableView: UITableView!
    
    
    /// Variables and Declarations
    var isRemoveStatus:Bool = false
    var statusArray = [AppConstants.defaultStatus, "Available", "Busy", "At school", "At the movie", "At work", "Battery about to die"]
    var isNewStatus: Bool = false
    var userDetails: UserProfileModel?
    var changedStatus: String?
    var delegate: UpdateStatusListViewControllerDelegate?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let data = userDetails else{return}
        self.changedStatus = data.status
        setViewUI()
        updateStatusTableView.estimatedRowHeight = 100
        updateStatusTableView.rowHeight = UITableView.automaticDimension
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
    
    override func viewDidLayoutSubviews() {
        
        if !Utility.isDarkModeEnable(){
            self.navView.makeShadowEffect(color: UIColor.lightGray)
            self.currentStatusView.makeShadowEffect(color: UIColor.lightGray)
            //        self.currentStatusView.makeCornerRadious(readious: 5.0)
            self.statusListView.makeShadowEffect(color: UIColor.lightGray)
            //        self.statusListView.makeCornerRadious(readious: 5.0)
        }
    }
    
    
    /// All UI Design
    func setViewUI(){
        //        self.currentStatuslabel.text = self.changedStatus
        self.setCurrentStatusAndItsUI()
        if !self.statusArray.contains(self.changedStatus!){
            //            self.statusArray.append(self.changedStatus!)
            self.statusArray.insert(self.changedStatus!, at: 0)
            self.isNewStatus = true
            self.updateStatusTableView.reloadData()
        }else{
            //            if let index = self.statusArray.index(of: self.changedStatus!){
            //                self.statusArray.remove(at: index)
            //            }
        }
    }
    
    func setCurrentStatusAndItsUI(){
        self.currentStatuslabel.text = self.changedStatus
        guard let status = self.changedStatus else{return}
        var height = status.height(withConstrainedWidth: self.currentStatuslabel.frame.size.width, font: self.currentStatuslabel.font) + 55.0
        if Float(height) < 100.0 {
            height = 100
        }
        if Float(height) > 200{
            height = 200
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.currentStatusViewHeightConstraint.constant = height
            self.view.updateConstraintsIfNeeded()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    //MARK:- Button Action
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        if delegate != nil{
            delegate?.updatedStatusString(status: self.changedStatus!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editStatusButtonAction(_ sender: Any) {
        guard let updateStatusVC = self.storyboard?.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.UpdateStatusViewController) as? UpdateStatusViewController else {return}
        updateStatusVC.userProfileData = self.userDetails
        updateStatusVC.delegate = self
        self.present(updateStatusVC, animated: true, completion: nil)
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

extension UpdateStatusListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statusArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.StatusTextTableViewCell) as? StatusTextTableViewCell else{fatalError()}
        cell.statusDelegate = self
        
        if isNewStatus && indexPath.row == 0{
            cell.removeStatusButtonWidthConstraint.constant = 30.0
            cell.removeStatusButton.isHidden = false
        }else{
            cell.removeStatusButtonWidthConstraint.constant = 0.0
            cell.removeStatusButton.isHidden = true
        }
        if isRemoveStatus && indexPath.row == 0 && isNewStatus{
            cell.statusLabel.text = AppConstants.defaultStatus
        }else {
            cell.statusLabel.text = self.statusArray[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.changedStatus = self.statusArray[indexPath.row]
        //        self.currentStatuslabel.text = self.changedStatus
        self.setCurrentStatusAndItsUI()
    }
    
}

// MARK: - UpdateStatusViewControllerDelegate
extension UpdateStatusListViewController: UpdateStatusViewControllerDelegate{
    func removeStatus() {
        self.changedStatus = AppConstants.defaultStatus
        isRemoveStatus = true
        self.updateStatusTableView.reloadData()
        self.setViewUI()
    }
    
    
    func updatedStatus(status: String){
        self.changedStatus = status
        self.setViewUI()
        //        self.updateStatusTableView.reloadData()
    }
}
