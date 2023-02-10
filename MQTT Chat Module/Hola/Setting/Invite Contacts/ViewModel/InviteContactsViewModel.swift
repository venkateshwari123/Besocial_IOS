//
//  InviteContactsViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import Foundation
import ContactsUI
import APAddressBook
class InviteContactsViewModel: NSObject {
    
    // MARK:- Declarations&Constants
  var favouriteContacts = [Contacts]()
    var searchedContactsList = [Contacts]()
    
    
    /// To make contact list of users who are not using this app
    ///
    /// - Parameter reloadData: after getting all user list
    func makeSortedArrayOfFavouritedList(reloadData:@escaping()->Void) {
        
        var temp =  self.getFavouriteContact()
//        var temp = self.favouriteContacts
        temp =  temp.sorted { (a, b) -> Bool in
            a.fullName?.localizedCaseInsensitiveCompare(b.fullName!) == ComparisonResult.orderedAscending
        }
        
//        self.favouriteContacts  = temp  //as! [Contacts]
        //        searchList = favoriteList
        //        DispatchQueue.global(qos: .userInitiated).async {
        self.getUnregisterContact(favContact: temp) {
            reloadData()
        }
        //        }
    }
    
    /// To get all user list who are using this app from database
    ///
    /// - Returns: list of user
    private func getFavouriteContact() -> [Contacts]{
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        if documentID !=  nil{
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        
        let predicate = NSPredicate.init(format: "isFavorite == %@","isFavorite")
        let favArr =  dbContactsArr.filtered(using: predicate)
        if favArr.count > 0  {
            // print("fav database =\(favArr)")
            return Contacts.getAllUserDetail(withuserData: favArr )
        }
        return []
    }
    
    
    /// To filtering users who are not using this app
    ///
    /// - Parameter complitationHandler: after doing filtering
    private func getUnregisterContact(favContact: [Contacts],  complitationHandler:@escaping()->Void){
        APAddressBook().loadContacts { [unowned self](contacts: [APContact]?, error : Error?) in
            if contacts == nil || contacts?.count == 0 {
                return
            }
            let favouritContactList = favContact
            let unregisteredContacts = contacts!.filter { (contact) -> Bool in
                if favouritContactList.contains(where: {$0.contactID! == "\(contact.recordID)"}) {
                    return false
                } else {
                    return true
                }
            }
            
            /*
             Bug Name:- Invite contacts list in the profile page is not according to the alphabetical order
             Fix Date:- 26th May 2021
             Fixed By:- Nikunj C
             Description of Fix:- add required sorting
             */
            
            let contactsToAdd = unregisteredContacts.map { Contacts(contact: $0) }.sorted{ (a,b) -> Bool in
                a.fullName?.localizedCaseInsensitiveCompare(b.fullName!) == ComparisonResult.orderedAscending
            }

            /*
             Bug Name:- invite contacts are repeated and should only phone number contacts come
             Fix Date:- 27th Jan 2022
             Fixed By:- Nikunj C
             Description of Fix:- filter array that not contain duplicate number and registernum must only phone numbers not any other string 
             */
            
            var tempNumArr = [String]()
            var tempNameArr = [String]()
            let phoneNumContacts = contactsToAdd.filter{ (contact) -> Bool in
                if let registeredNum = contact.registerNum{
                    
                    guard let fullName = contact.fullName else {return false}
                    if registeredNum.isNumeric && !tempNumArr.contains(registeredNum) && !tempNameArr.contains(fullName){
                        tempNumArr.append(registeredNum)
                        tempNameArr.append(fullName)
                        return true
                    }else{
                        return false
                    }
                }else{
                    return false
                }

            }
            
            self.favouriteContacts = phoneNumContacts
            complitationHandler()
        }
    }
    
    func searchPeopleInList(searchText: String?){
        guard let text = searchText else {
            self.searchedContactsList = self.favouriteContacts
            return
        }
        if text == ""{
            self.searchedContactsList = self.favouriteContacts
            return
        }
        let filteredArr = self.favouriteContacts.filter { (contact) -> Bool in
            if let name = contact.fullName, name.containsIgnoringCase(find: text){
                return true
            }else if let number = contact.registerNum{
               return number.containsIgnoringCase(find: text)
            }else{
                return false
            }
        }
        if filteredArr.count > 0{
            
            /*
                                 Bug Name :  ADD CONTACTS-- MOBILE CONTACTS check whether users are shown in the alphabetical order.
                                 Fix Date : 12-apr-2021
                                 Fixed By : Vishal D
                                 Description Of Fix : added filter sorting
                               */


            self.searchedContactsList = filteredArr.sorted(by: {$0.fullName ?? "" < $1.fullName ?? ""})
        }else{
            self.searchedContactsList.removeAll()
        }
    }
}
