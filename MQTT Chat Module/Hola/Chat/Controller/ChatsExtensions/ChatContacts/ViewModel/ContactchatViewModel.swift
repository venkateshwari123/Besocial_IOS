//
//  ContactchatViewModel.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 14/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts

protocol shareContactDelegate{
    
    func selectedContact(_ contact:CNContact)
    
}

class ContactchatViewModel:NSObject,CNContactPickerDelegate{

    var chatObj:ChatViewController?
    var delegate:shareContactDelegate?
    
     init(_ chatObject:ChatViewController) {
        chatObj = chatObject
    }
    
    func openContectView(){
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.view.backgroundColor = .setColor(lightMode: AppColourStr.whiteColor, darkMode: AppColourStr.blackColor)
        if #available(iOS 13.0, *) {
            UINavigationBar.appearance().tintColor = .systemBackground
            UINavigationBar.appearance().barTintColor = . systemBackground
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
            UINavigationBar.appearance().barStyle = .default
            
        }
        chatObj?.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        chatObj?.dismiss(animated: true, completion: nil)
    }
   
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact){
        chatObj?.dismiss(animated: true, completion: nil)
        delegate?.selectedContact(contact)
    }
    
}
