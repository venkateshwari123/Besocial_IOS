//
//  ContactsPhoneNumberCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 16/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ContactsPhoneNumberCell: UITableViewCell {

    @IBOutlet weak var phoneNumberOutlet: UILabel!
    @IBOutlet weak var optionsViewOutlet: UIView!

    var userID : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func messageButtonAction(_ sender: UIButton) {
        print("Message user where user Id is = \(String(describing: userID))")
    }
    
    @IBAction func videoCallAction(_ sender: UIButton) {
        print("Video call user where user Id is = \(String(describing: userID))")
    }
    
    @IBAction func callButtonAction(_ sender: UIButton) {
        print("Audio call user where user Id is = \(String(describing: userID))")
    }

}
