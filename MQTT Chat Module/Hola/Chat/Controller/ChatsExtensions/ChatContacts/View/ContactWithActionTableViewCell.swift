//
//  ContactWithActionTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 16/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ContactWithActionTableViewCell: UITableViewCell {

    @IBOutlet weak var actionTitleOutlet: UILabel!
    
    var msgVMObject : ContactMessageViewModal!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func createNewContacts() {
        msgVMObject.createNewContact()
    }
    
    func addToExistingContacts() {
        msgVMObject.addToExistingContact()
    }
}
