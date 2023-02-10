//
//  ContactDetailsTableViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 23/03/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

let usernameCellId = "usernameCell"
let numberDetailCellId = "numberDetailCell"



class ContactDetailsTableViewController: UITableViewController {
    
    
    var userName:String?
    var userNUmber:String?
    var userphType:String?
    var userID: String?
    var profilePic: String?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Contact Info".localized
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: usernameCellId, for: indexPath)
            cell.textLabel?.text =  userName == nil  || userName?.count == 0 ? userNUmber! : userName!
            return cell
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: numberDetailCellId , for: indexPath) as? ContactDetailsTableViewCell
            cell?.showData(mobileType: userphType ?? "mobile".localized , userNum: userNUmber ?? "" , perentobj: self, userID: userID!, profilePic: profilePic!)
            
            return cell!
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 60
        }
        return 44
    }
}
