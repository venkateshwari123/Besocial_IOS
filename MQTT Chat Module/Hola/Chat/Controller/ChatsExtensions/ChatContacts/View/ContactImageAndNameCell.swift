//
//  ContactImageAndNameCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 16/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ContactImageAndNameCell: UITableViewCell {

    @IBOutlet weak var contactImageOutlet: UIImageView!
    @IBOutlet weak var contactNameOutlet: UILabel!
    
    var msgVMObject : ContactMessageViewModal! {
        didSet {
            if let userImage =  msgVMObject.getContactImage() {
                self.contactImageOutlet.kf.setImage(with: userImage, placeholder: #imageLiteral(resourceName: "voice_call_profile_default_image"), options: nil, progressBlock: nil) { (result) in
                    print(result)
                }
            } else {
                self.contactImageOutlet.image = #imageLiteral(resourceName: "voice_call_profile_default_image")
            }
            if let name = msgVMObject.getContactName() {
                self.contactNameOutlet.text = name
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
