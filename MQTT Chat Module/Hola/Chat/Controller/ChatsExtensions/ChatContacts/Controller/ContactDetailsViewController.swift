//
//  ContactDetailsViewController.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 16/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UIViewController {
    
    struct Constants {
        static let contactImageAndNameCell = "ContactImageAndNameCell"
        static let contactWithActionTableViewCell = "ContactWithActionTableViewCell"
        static let contactsPhoneNumberCell = "ContactsPhoneNumberCell"
    }
    
    struct ActionTitleConstant {
        static let createNewContact = "Create New Contact".localized
        static let addToExistingContact = "Add to Existing Contact".localized
    }
    
    @IBOutlet var tableViewOutlet: UITableView!
    var contactVMObj : ContactMessageViewModal!
    var phNumbers : [String : String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact Details".localized
        if let numbers = contactVMObj.getNumberWithRegisteredIDs() {
            self.phNumbers = numbers
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- check connectivity and show popup for no internet
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.checkConnectionAvaibility(view: self.view)

    }
    
}
extension ContactDetailsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        switch indexPath.section {
        case 1:
            if let actionCell = cell as? ContactWithActionTableViewCell {
                if indexPath.row == 0 {
                    actionCell.createNewContacts()
                } else {
                    actionCell.addToExistingContacts()
                }
            }
        default:
            break
        }
    }
}

extension ContactDetailsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 64
        case 1  :
            return 44
        case 2:
            guard self.phNumbers != nil else { return 0 }
            return 64
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1  :
            return 2
        case 2:
            guard let numbers = self.phNumbers else { return 0 }
            return numbers.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.contactImageAndNameCell) as! ContactImageAndNameCell
            cell.msgVMObject = self.contactVMObj
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.contactWithActionTableViewCell) as! ContactWithActionTableViewCell
            cell.msgVMObject = self.contactVMObj
            cell.msgVMObject.presentControllerDelegate = self
            if indexPath.row == 0 {
                cell.actionTitleOutlet.text = ActionTitleConstant.createNewContact
            } else {
                cell.actionTitleOutlet.text = ActionTitleConstant.addToExistingContact
            }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.contactsPhoneNumberCell) as! ContactsPhoneNumberCell
            if let numbers = self.phNumbers {
                let num = Array(numbers.keys)[indexPath.row]
                cell.phoneNumberOutlet.text = num
                if let number = contactVMObj.getnumber(withString: num, andSaperator : "/"){
                    cell.phoneNumberOutlet.text = number
                }
                let userID = Array(numbers.values)[indexPath.row]
                if userID.count>0 {
                    cell.optionsViewOutlet.isHidden = false
                    
                } else {
                    cell.optionsViewOutlet.isHidden = true
                }
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

extension ContactDetailsViewController : PresentControllerDelegate {
    
    func presentController(withController controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}
