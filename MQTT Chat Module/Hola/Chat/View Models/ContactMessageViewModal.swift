//
//  ContactMessageViewModal.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 14/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

protocol PresentControllerDelegate {
    func presentController(withController : UIViewController)
    func dismissController()
}
class ContactMessageViewModal: NSObject {
    
    enum alertPopUpTitles : String {
        case createNew = "Create New Contact"
        case addExisting = "Add to Existing Contact"
        case cancel = "Cancel"
    }
    
    /// Message Instance for storing image Object.
    let message : Message
    let userDefault = UserDefaults.standard
    let favoriteViewModel = FavoriteViewModel.sharedInstance
    var presentControllerDelegate : PresentControllerDelegate?
    
    /// Initiaizing the message object with the Message object.
    ///
    /// - Parameter message: Message Object
    init(withMessage message: Message) {
        self.message = message
    }
    
    func getContactName() -> String? {
        if let contactsData = self.message.messagePayload {
            let getNumbers = self.getArray(withString: contactsData, saperatedBy: "@@")
            if getNumbers.count>0 {
                return getNumbers[0]
            }
        }
        return nil
    }
    
    private func getContactObject() -> Contacts? {
        if let contactsData = self.message.messagePayload {
            let getNumbers = self.getArray(withString: contactsData, saperatedBy: "@@")
            let getRegisterUsers = self.getRegisterNumbers(withNumbers: getNumbers, andAtIndex : 1)
            if getRegisterUsers.count>0 {
                let contactObj = favoriteViewModel.getContactObject(forUserID: getRegisterUsers[0])
                return contactObj
            }
        }
        return nil
    }
    
    func saveContactAction() {
        let saveButtonOptions = [alertPopUpTitles.createNew.rawValue.localized,alertPopUpTitles.addExisting.rawValue.localized]
        self.opencontrollerForOptions(withOptions: saveButtonOptions)
    }
    
    func getContactImage() -> URL? {
        if let contactObj = self.getContactObject() {
            if let userImage = contactObj.profilePic {
                return URL(string : userImage)
            }
        }
        return nil
    }
    
    func getRegisteredUserID() -> [String] {
        if let contactsData = self.message.messagePayload {
            let getNumbers = self.getArray(withString: contactsData, saperatedBy: "@@")
            let getRegisterUsers = self.getRegisterNumbers(withNumbers: getNumbers, andAtIndex : 1)
            return getRegisterUsers
        }
        return []
    }
    
    func getNumbers() -> [String] {
        if let contactsData = self.message.messagePayload {
            let getNumbers = self.getArray(withString: contactsData, saperatedBy: "@@")
            let numbers = self.getNumberArray(withStringArray: getNumbers)
            return numbers
        }
        return []
    }
    
    func getNumberWithRegisteredIDs() -> [String : String]? {
        if let contactsData = self.message.messagePayload {
            let getNumbers = self.getArray(withString: contactsData, saperatedBy: "@@")
            return self.getNumberDict(withNumbers: getNumbers)
        }
        return nil
    }
    
    private func getNumberArray(withStringArray numbersArray : [String]) -> [String] {
        var registerNumbers = [String]()
        for number in numbersArray {
            let regNums = self.getArray(withString: number, saperatedBy: "{")
            if regNums.count>0 {
                if let num = self.getnumber(withString: regNums[0], andSaperator : "/"){
                    registerNumbers.append(num)
                }
            }
        }
        return registerNumbers
    }
    
    private func getNumberDict(withNumbers numbersArray: [String]) -> [String : String] {
        var numDict = [String : String]()
        for (index,number) in numbersArray.enumerated() {
            if index != 0 {
                let regNums = self.getArray(withString: number, saperatedBy: "{")
                numDict[regNums[0]] = ""
                if regNums.count>1 {
                    numDict[regNums[0]] = regNums[1]
                }
            }
        }
        return numDict
    }
    
    private func getRegisterNumbers(withNumbers numbersArray: [String], andAtIndex index:Int) -> [String] {
        var registerNumbers = [String]()
        for number in numbersArray {
            let regNums = self.getArray(withString: number, saperatedBy: "{")
            if regNums.count>1 {
                
                
                //Check here if number is in Fav list
                
                let documentID = UserDefaults.standard.object(forKey: "contactDocumentID") as? String
                var dbContactsArr = NSArray()
                if documentID !=  nil{dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray}
                let userId = regNums[index]
                let predicate = NSPredicate.init(format: "userID == %@",userId)
                let arr =  dbContactsArr.filtered(using: predicate)
                if arr.count > 0 {
                    registerNumbers.append(regNums[index])
                }
                
            }
        }
        return registerNumbers
    }
    
    func getnumber(withString string: String, andSaperator saperatorString: String) -> String? {
        if let range = string.range(of: saperatorString) {
            let pNumber = string[string.startIndex..<range.lowerBound]
            return String(pNumber)
        }
        return nil
    }
    
    private func getArray(withString string: String, saperatedBy saperator:String) -> [String] {
        return string.components(separatedBy: saperator)
            .flatMap { $0.trimmingCharacters(in: .whitespaces)
        }
    }
    
    private func getContactImage(withContactObj contactObj : CNContact) -> String? {
        for (index, number) in contactObj.phoneNumbers.enumerated() {
            let num = Helper.removeSpecialCharsFromString(text: number.value.stringValue)
            if num.count > 0 {
                if index == 0 {
                    return favoriteViewModel.getUserID(forContactNumber: num)?.profilePic
                }
            }
        }
        return nil
    }
}

let charactersSet = NSCharacterSet(charactersIn: "0123456789").inverted

extension String {
    func allCharacters() -> String {
        return self.components(separatedBy: charactersSet).joined()
    }
}

extension ContactMessageViewModal {
    
    func createContact(withContact contactObj: CNContact?, isCreatingContact : Bool) {
        var cnmutableContact = CNMutableContact.init()
        let numbers = self.getNumbers()
        if let contactObj = contactObj {
            cnmutableContact =  contactObj.mutableCopy() as! CNMutableContact
        }
        var phNumbers = cnmutableContact.phoneNumbers
        for number in numbers {
            let cnValue = CNLabeledValue(label: nil, value: CNPhoneNumber(stringValue:number))
            phNumbers.append(cnValue)
        }
        cnmutableContact.phoneNumbers = phNumbers
        if let cName = self.getContactName(), isCreatingContact == true {
            cnmutableContact.givenName = cName
        }
        let contactView  = CNContactViewController.init(forNewContact:cnmutableContact)
        contactView.delegate = self
        let navigation = UINavigationController.init(rootViewController: contactView)
        if (presentControllerDelegate != nil) {
            presentControllerDelegate?.presentController(withController : navigation)
        }
    }
    
    func addToExistingContact() {
        let isNetwork = (UIApplication.shared.delegate as! AppDelegate).isNetworkThere
        if isNetwork == true {
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            if (presentControllerDelegate != nil) {
                presentControllerDelegate?.presentController(withController : contactPicker)
            }
        } else {
            Helper.showAlertViewOnWindow("Oops".localized, message: "Check Internet Connection".localized)
        }
    }
    
    func createNewContact() {
        let isNetwork = (UIApplication.shared.delegate as! AppDelegate).isNetworkThere
        if isNetwork == true {
            self.createContact(withContact: nil, isCreatingContact: true)
        } else {
            Helper.showAlertViewOnWindow("Oops".localized, message: "Check Internet Connection".localized)
        }
    }
}

extension ContactMessageViewModal : CNContactPickerDelegate {
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        if (presentControllerDelegate != nil) {
            presentControllerDelegate?.dismissController()
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact){
        if (presentControllerDelegate != nil) {
            presentControllerDelegate?.dismissController()
            self.createContact(withContact: contact, isCreatingContact: false)
        }
    }
    
    func opencontrollerForOptions(withOptions options: [String]) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for optionValue in options {
            let action = UIAlertAction(title: optionValue, style: .default, handler: { (action) in
                if action.title == alertPopUpTitles.createNew.rawValue.localized {
                    self.createNewContact()
                    controller.dismiss(animated: true, completion: nil)
                } else if action.title == alertPopUpTitles.addExisting.rawValue.localized {
                    self.addToExistingContact()
                    controller.dismiss(animated: true, completion: nil)
                } else {
                    // have to handle for multiple numbers by using alert title
                }
            })
            controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler:nil)
        controller.addAction(cancelAction)
        if (presentControllerDelegate != nil) {
            presentControllerDelegate?.presentController(withController : controller)
        }
    }
}

// MARK: - Contact Save Delegate
extension ContactMessageViewModal : CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?){
        if (presentControllerDelegate != nil) {
            presentControllerDelegate?.dismissController()
        }
    }
}
