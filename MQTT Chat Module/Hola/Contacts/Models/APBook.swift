//
//  APaddressBook.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 16/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import APAddressBook
import Reachability
import CocoaLumberjack
import RxReachability
import RxSwift
import RxCocoa



class APBook: NSObject {
    
    static let sharedInstance = APBook()
    let addressBook = APAddressBook()
    var contacts = [APContact]()
    var isFirstTime : Bool
    var dbContactsArr = NSArray()
    
    var couchbase = Couchbase.sharedInstance
    let reachability = Reachability()!
    let disposeBag = DisposeBag()
    
    var contactArrayToSendToServer = [[String:Any]]()
   
    
    //init self object
    override init() {
        
        addressBook.fieldsMask  = [APContactField.default,APContactField.recordDate,APContactField.phonesWithLabels]
        addressBook.sortDescriptors = [NSSortDescriptor(key: "name.firstName", ascending: true),
                                       NSSortDescriptor(key: "name.lastName", ascending: true)]
        
        isFirstTime  = false
       
        switch  APAddressBook.access(){
            
        case APAddressBookAccess.granted:
            DDLogDebug("permission granted...")
            
        case APAddressBookAccess.denied:
            
            Helper.hidePI()
            Helper.showAlertViewOnWindow("Oops".localized, message: AppConstants.permissionMsg)
            DDLogDebug("permission denied")
            
        case APAddressBookAccess.unknown:
            Helper.hidePI()
            DDLogDebug("permission not defined")
            
        }
        
        
    }

    
    //load contacts
    //params :
    //isFirstTime : Bool type
    func loadContacts(isFirstTime : Bool) {
        
        self.isFirstTime = isFirstTime
        addressBook.startObserveChanges
            {
                UserDefaults.standard.set(false, forKey: "callMethodeFirstTimeOnly")
                DDLogDebug("once again it came here changed contact come here")
                //self.checkContacisChanged()
        }
        self.getContacts()
    }
    
    
    
    
    
    //load allcontacts form iphone here
    //
    func getContacts(){
        
        Reachability.rx.isReachable
            .subscribe(onNext: { isReachable in
                if isReachable == true {self.checkNetwork(isReachable)}
                else{self.checkNetwork(isReachable)}
            }).disposed(by: disposeBag)
        
        
        addressBook.loadContacts { [unowned self](contacts: [APContact]?, error : Error?) in
            
            if contacts == nil || contacts?.count == 0 {
                 Helper.hidePI()
                Helper.showAlertViewOnWindow("Oops".localized, message: "No Contact Found".localized + " :( ")
                return
            }
            self.contacts = [APContact]()
            if self.isFirstTime == true {
                
                if let contacts = contacts{
//                    Helper.hidePI()
                    self.contacts = contacts
                    self.saveContactsInDatabase(contacts: self.contacts)
                    self.sendContactToserver(contacts: self.contacts)
                }
                else if let error = error{
                    let alert = UIAlertController.init(title: Strings.error.localized, message: error.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction.init(title: "OK".localized, style: .default, handler: { (UIAlertAction) in
                    });   alert.addAction(alertAction)
                }
                
            } else {
                Helper.hidePI()
                DDLogDebug("This is run on the background queue")
                let isnetwork:Bool = (UIApplication.shared.delegate as! AppDelegate).isNetworkThere
                if isnetwork == true{
//                DispatchQueue.global().async {
                    DispatchQueue.global(qos: .background).async {
//                    guard let contact: [APContact] = contacts else {return}
                    self.checkmodificationinDatabase(contacts: contacts)
                    }
                }
            }
        }
    }
    
    func checkNetwork(_ isReached:Bool) {
        if isReached == true {
            DDLogDebug("network  there")
            //network came
//            self.getContacts()
        } else {
            DDLogDebug("network  nooooo")
        }
    }
    
    func subscribeContactSynchannnel() {
        //subscribe ContactSync
        
//        guard let userID1 = Utility.getUserid() else { return }
//        let contacSync = AppConstants.MQTT.contactSync+userID1
//        DDLogDebug("************subscribe to contact sync channel here \(contacSync) ")
//        MQTT.sharedInstance.subscribeTopic(withTopicName: contacSync, withDelivering: .atLeastOnce)
    }
    
    //refresh contact
    func refreshContact(){
        
//        self.subscribeContactSynchannnel()
        
        DispatchQueue.global().async {
            self.addressBook.loadContacts { [unowned self](contacts: [APContact]?, error : Error?) in
                if contacts == nil {
                    Helper.hidePI()
                    Helper.showAlertViewOnWindow("Oops".localized, message: "No Contact Found".localized + " :( ")
                    return
                }
                self.sendContactToserver(contacts: contacts!)
                
            }
        }
        
        
        
    }
    
    
    
    //saveContacts to couchDatabase
    //params::::
    //contacts : APContact array
    func saveContactsInDatabase(contacts:[APContact]){
        
        var contactList = [Dictionary<String,Any>]()
        for contact in contacts{
            
            let dict = self.modifyDataIndataBase(contact, oldContact: ["":""])
            // let dict = self.getDataInProperfromate(contact) as [String : Any]
            contactList.append(dict)
        }
        
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        if documentID ==  nil{
            let contactDocID = couchbase.createDocument(withProperties: ["contactList":contactList] as [String : Any])
            UserDefaults.standard.set(contactDocID, forKey: AppConstants.UserDefaults.contactDocumentID)
        }
        
    }
    
    
    
    
    //send Contact to server
    //params:::
    //contacts : APContact array
    func sendContactToserver(contacts:[APContact]){
        
//        var fullArray =  [Any]()
//
//        //let fullArray : NSMutableArray = NSMutableArray()
//
//        for  single in contacts{
//
//            let phoneNum  =  getPhonenumber(with: single)
//            for phone in phoneNum {
//                 fullArray.append(phone)
//            }
//
//           // fullArray.addObjects(from: phoneNum as! [Any])
//        }
        
        //print("send All Contacts to sertver =\(fullArray)")
        requestforServer(contactList: self.contactArrayToSendToServer)
    }
    
    //request send allContacts to server
    //ContactList  arrray of all phone number
    //params :
    //ContactList : NArray type
    func requestforServer(contactList:[Any]){
        
        let params =  ["contacts": contactList] as [String : Any]
        ContactAPI.sendAllContactsToserver(with: params)
    }
    
    func requestModificationforserver(contacts:[APContact]){
        let fullArray : NSMutableArray = NSMutableArray()
        
        for  single in contacts{
            
            let phoneNum  =  getPhonenumber(with: single)
            fullArray.addObjects(from: phoneNum as [Any])
            
        }
        
        
        let params =  ["contacts" : fullArray ] as [String : AnyObject]
        ContactAPI.sendmodifiedContactsToserver(with: params)
        
    }
    
    
    
    //filter only phoneNumber from APContact
    //params:
    //model - APContact
    //return -> NSArray
    func getPhonenumber(with model:APContact)-> [[String:Any]] {
        var phNumberArray = [[String:Any]]()
        if let phoneArr  = model.phones{
            for phone in phoneArr{
                if let number = phone.number
                {
                    if number.count < 4{
                        continue
                    }
                    var phoneStr : String  = number
                    let num = Helper.removeSpecialCharsFromString(text: phoneStr)
                    phoneStr = Helper.getValidPhoneNumber(number: num)
//                    phoneStr = number
                    
                    let dict = [
                        "number": phoneStr ,
                        "type" : "1",
                        ] as [String: Any]
                    
                    let contDict = [
                        "number": num ,
                        "type" : "1"
                    ] as [String: Any]
                    self.contactArrayToSendToServer.append(contDict)
                    phNumberArray.append(dict )
                }
            }
            return phNumberArray as [Any] as! [[String : Any]]
        }
        return [[:]]
    }
    
    
    func  getPhoneNum(contact: APContact)-> String {
        
        var phnumberStr = ""
        if let phoneArr = contact.phones{
            for phone in phoneArr{
                if let number = phone.number{
                    var phoneStr : String  = number
                    phoneStr = Helper.removeSpecialCharsFromString(text: phoneStr)
                    let number = Helper.getValidPhoneNumber(number: phoneStr)
                    phoneStr = "\(number),"
                    phnumberStr.append(phoneStr)
                }
            }
        }
        return phnumberStr
    }
    
    //checkmodification in Database or not
    //params : -
    //contacts : APContact type
    func checkmodificationinDatabase(contacts: [APContact]?)  {
        
        var indexArr = [Int]()
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        if documentID !=  nil{
            self.dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        
        let dbContacts = self.dbContactsArr
        
        let copyOfdbContacts = NSMutableArray.init(array: dbContacts)
        var newContactArr = [APContact]()
        var newContsaveArr = [[String:Any]]()
        var isneedTosave = false
        var isNewAdded  = false
        var isNeedUpdateui = false
        
        //print("contac print here \(dbContacts)")
        guard let contactList = contacts else{return}
        for contact in contactList{
            
            let namePredicate =  NSPredicate(format: "contactID == %@",String(format:"%@",contact.recordID))
            let arr =  dbContacts.filtered(using: namePredicate)
            var indexOfA :Int = 0
            
            
            //print("hello there  =\(arr)")
            
            var modificationDate  = ""
            
            if (arr.count>0){
                
                let dict: [String:Any] = arr[0] as! [String : Any]
                modificationDate = dict["modificationDate"] as! String
                
                indexOfA = copyOfdbContacts.index(of:dict)
                indexArr.append(indexOfA)
                
            }
            
            
            if arr.count == 0{
                //new contact added send to server
                let dict = self.modifyDataIndataBase(contact, oldContact: ["":""])
                newContsaveArr.append(dict)
                
                newContactArr.append(contact)
                isNewAdded = true
                isneedTosave = true
            }
            
            
            if modificationDate != String(describing: (contact.recordDate?.modificationDate)!){
                
                DDLogDebug("modification date changed ")
                if (arr.count>0){
                    
                    let modifyArr =  self.modifyidatabaseWithNewvalue(newApContact: contact, contactDict: arr[0] as! [String: Any])
                    copyOfdbContacts.replaceObject(at: indexOfA, with: modifyArr)
                    isneedTosave = true
                    isNeedUpdateui = true
                }
            }
            
        }
        
        
        let tempArr = copyOfdbContacts
        //let deleteIndexArr:NSMutableArray = []
        
        for (i ,elemant) in copyOfdbContacts.enumerated(){
            
            let isdeleted:Bool =   indexArr.contains(i)
            if !isdeleted  {
                isneedTosave = true
                isNeedUpdateui = true
                
                //delete api call here so that contact delete from server
                let dict = elemant as! [String:Any]
                let arr = dict["alternateNumbers"] as! NSArray
                
                let predicate = NSPredicate.init(format:"contactID == %@", dict["contactID"] as! String)
                let arr1 = tempArr.filtered(using: predicate)
            
                if arr1.count > 0{
                    let ind = tempArr.index(of: arr1[0])
                    DDLogDebug("temp arr deleted =\(tempArr[ind])")
                    tempArr.removeObject(at: ind)
                }
                
                ContactAPI.deleteContacts(with: ["contacts": arr])
                
            }
        }
   
        if isNewAdded == true {
            tempArr.addObjects(from:newContsaveArr)
        }
        
        
        
        if isneedTosave == true{
            
            DispatchQueue.main.async(execute: {
                Contacts.updateContactDataInDatabase(database: Couchbase.sharedInstance , contactList: tempArr as NSArray)
                if isNeedUpdateui == true{
                    FavoriteViewModel.sharedInstance.updateData()}
                
                if  isNewAdded == true {
                    self.requestModificationforserver(contacts: newContactArr)
                }
            })
        }        
        //print("here is latestet array =\(tempArr)")
        
    }
    
    
    //check for changed in contact
    func checkContacisChanged(){
        
        addressBook.loadContacts { [unowned self](contacts: [APContact]?, error : Error?) in
            
            // let ischnagedFirsttime = UserDefaults.standard.object(forKey: "callMethodeFirstTimeOnly") as! Bool
            // if ischnagedFirsttime == true{
            UserDefaults.standard.set(false, forKey: "callMethodeFirstTimeOnly")
            DDLogDebug("IM hereeeeeeeeeeee modificatation called here")
            
            let isnetwork:Bool = (UIApplication.shared.delegate as! AppDelegate).isNetworkThere
            if isnetwork == true{
            
//            DispatchQueue.global().async {
                self.checkmodificationinDatabase(contacts: contacts)
//            }
                
            }
         
        }
        
    }
    
    
    //modifyidatabase with new values
    //params:-
    //newApContact : APContact type
    //contactDict : dict of array
    //return -> [String: Any] type dict
    func  modifyidatabaseWithNewvalue(newApContact:APContact ,contactDict:[String:Any]) -> [String:Any]{
        
        let dict:[String:Any] = self.modifyDataIndataBase(newApContact, oldContact:contactDict)
        //let dict:[String:Any] = self.getDataInProperfromate(newApContact)
        
        //print("new dict here  =\(dict)")
        
        return dict
        
    }
    
    
    
    
    //Filter  contacts details from Apcontact class
    //params : -
    //contact : Apcontact type
    //return -> String
    func modifyDataIndataBase(_ contact: APContact, oldContact : [String:Any]) -> [String:Any] {
        
        var newDict = [String:Any]()
        var fullName : String? = ""
        
        if ((contact.name?.firstName) != nil) {
            newDict["firstName"] = contact.name?.firstName
            fullName = contact.name?.firstName!
        }
        
        if (contact.name?.lastName != nil) {
            newDict["lastName"] = contact.name?.lastName
            fullName = fullName! + " " + (contact.name?.lastName!)!
        }
        
        if ((fullName?.count)!>0) {
            newDict["fullName"] = fullName
            if fullName == " " {
                newDict["fullName"] = ""
            }
        } else {
            newDict["fullName"] = ""
        }
        let  phoneNumber =  self.getPhonenumber(with: contact)
        newDict["alternateNumbers"] = phoneNumber
        
        newDict["numbers_Str"] = getPhoneNum(contact: contact)
        
        newDict["contactID"] =  String(format :"%@",contact.recordID)
        newDict["modificationDate"] =  "\(String(describing: (contact.recordDate?.modificationDate)!))"
        
        
        if (oldContact["isFavorite"] != nil){
            newDict["isFavorite"] = oldContact["isFavorite"]
        }
        
        if(oldContact["registerNum"] != nil){
            newDict["registerNum"] = oldContact["registerNum"]
        }
        
        if(oldContact["profilePic"] != nil){
            newDict["profilePic"] = oldContact["profilePic"]
        }
        
        if (oldContact["Status"] != nil) {
            newDict["Status"] = oldContact["Status"]
        }
        if (oldContact["userID"] != nil){
            newDict["userID"] = oldContact["userID"]
        }
        if (oldContact["chatDocID"] != nil){
            newDict["chatDocID"] = oldContact["chatDocID"]
        }
        if (oldContact["follow"] != nil){
            newDict["follow"] = oldContact["follow"]
        }
        if (oldContact["followStatus"] != nil){
            newDict["followStatus"] = oldContact["followStatus"]
        }
        if (oldContact["private"] != nil){
            newDict["private"] = oldContact["private"]
        }        
        return newDict
    }
    
    
}
