//
//  ContactsDocumentManager.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 01/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
//import APAddressBook

class ContactsDocumentViewModel: NSObject {
    
    var couchbase = Couchbase.sharedInstance
    
    init(couchbase: Couchbase) {
        self.couchbase = couchbase
    }

    func createContactsDocument(withcontactData contactData: [Any]?) -> String? {
        guard let contactData = contactData else { return nil}
        var contacts = [Any]()
        for contact in contactData {
            let contactDict = self.getContactObject(fromData: contact as! [String : Any])
            contacts.append(contactDict)
        }
        let contactDocID = couchbase.createDocument(withProperties: ["contactsArray":contacts])
        return contactDocID
    }
    
    
    fileprivate func getContactObject(fromData data:[String:Any]) -> Any {
        var params = ["contactUID":data["_id"],
                      "contactUserName":data["email"],
                      "contactName":data["name"],
                      "contactStatus":"Hey There! I am using this app"]
        if let profilePic = data["profilePic"] {
            params["contactPicUrl"] = profilePic
        }
        return params as Any
    }
    
    
    
}
