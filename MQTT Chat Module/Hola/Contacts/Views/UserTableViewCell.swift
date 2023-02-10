//
//  UserTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 10/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var userIdOutlet: UILabel!
    @IBOutlet weak var userImageOutlet: UIImageView!
    
    var userDetails : Contact? {
        didSet {
            if let name = userDetails?.name, let emailID = userDetails?.userName {
                self.userNameOutlet.text = name
                self.userIdOutlet.text = emailID
            } else {
                self.userNameOutlet.text = ""
                self.userIdOutlet.text = ""
            }
            /*
             Bug Name:- Show the intials for default profile pic
             Fix Date:- 12/05/21
             Fix By  :- Jayram G
             Description of Fix:- setting initials image when user not uploaded profile pic
             */
            if let userImage = userDetails?.profilePic {
                Helper.addedUserImage(profilePic: userImage, imageView: self.userImageOutlet, fullName: userDetails?.userName ?? "D")
            }
            else{
                self.userImageOutlet.image = nil
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
