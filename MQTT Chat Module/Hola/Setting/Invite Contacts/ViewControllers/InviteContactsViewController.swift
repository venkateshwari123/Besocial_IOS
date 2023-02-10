//
//  InviteContactsViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
import ContactsUI
import MessageUI
class InviteContactsViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var inviteTableView: UITableView!
    
    @IBOutlet weak var searchShadowView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    //MARK:- Declarations&Constants
    let inviteContactVmObject = InviteContactsViewModel() // Used To get the referance of the InviteContactsViewModel Object
    var isSearchActive: Bool = false
    
    var selectedUser : Contacts?
    
    
    //MARK:- View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.showPI()
        
        self.searchContainerView.makeCornerRadious(readious: 5)
        if !Utility.isDarkModeEnable(){
            self.searchShadowView.makeShadowForSearchView()
        }
        self.navigationItem.title = Strings.settingsTitles.inviteContacts.localized
        self.searchBarOutlet.placeholder = "Search".localized + " " + "contact".localized
        self.inviteContactVmObject.makeSortedArrayOfFavouritedList {
            DispatchQueue.main.async {
                self.inviteTableView.reloadData()
                Helper.hidePI()
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
    
    //MARK:- Invite button action
    @objc func inviteAction(sender: UIButton){
        
        /*
         Bug Name:- when click on invite button it should share sms for selected user instead of send same invite link
         Fix Date:- 27th Jan 2022
         Fixed By:- Nikunj C
         Description of Fix:- send sms to particular user
         */
        if self.isSearchActive{
            self.selectedUser  = self.inviteContactVmObject.searchedContactsList[sender.tag]
        }else{
            self.selectedUser  = self.inviteContactVmObject.favouriteContacts[sender.tag]
        }
        
        sendSMStoUser(user: selectedUser!)
        
    }
    
     func sendSMStoUser(user:Contacts){
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Check out".localized + " \(AppConstants.AppName) " + "for your smartphone".localized + ". " + "Download it today from".localized + AppConstants.AppUrl
            var userName = ""
            if let number = user.registerNum, number != "", number != " " {
                userName = String(number)
            }
            
            controller.recipients = [userName]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }

}

//MARK:- Table view data source and delegate
extension InviteContactsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchActive{
            return self.inviteContactVmObject.searchedContactsList.count
        }else{
            return self.inviteContactVmObject.favouriteContacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvitaContactTableViewCell") as? InvitaContactTableViewCell else{fatalError()}
        var contact: Contacts?
        if self.isSearchActive{
            contact  = self.inviteContactVmObject.searchedContactsList[indexPath.row]
        }else{
            contact  = self.inviteContactVmObject.favouriteContacts[indexPath.row]
        }
        cell.setInviteCellData(contact: contact!)
        cell.inviteButton.setTitle("Invite".localized, for: .normal)
        cell.inviteButton.tag = indexPath.row
        cell.inviteButton.addTarget(self, action: #selector(InviteContactsViewController.inviteAction(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}


extension InviteContactsViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let searchString = searchBar.text?.lowercased()
        self.inviteContactVmObject.searchPeopleInList(searchText: searchString)
        self.isSearchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //        self.isSearchActive = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchText.lowercased()
        self.inviteContactVmObject.searchPeopleInList(searchText: searchString)
        self.inviteTableView.reloadData()
    }
    
   
}

extension InviteContactsViewController : MFMessageComposeViewControllerDelegate{
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
