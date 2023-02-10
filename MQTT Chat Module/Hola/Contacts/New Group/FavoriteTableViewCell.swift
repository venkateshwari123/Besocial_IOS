//
//  FavoriteTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 15/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userStatus: UILabel!
    
    @IBOutlet weak var numberType: UILabel!
   
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        userImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCellData(contact: Contacts){
        self.userName.text =  contact.fullName == "" ? contact.registerNum : contact.fullName
        self.userStatus.text = contact.status
        self.numberType.text = "mobile".localized
        
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: contact.profilePic, imageView: self.userImageView, fullName: contact.fullName ?? "D")
    }
    
}
