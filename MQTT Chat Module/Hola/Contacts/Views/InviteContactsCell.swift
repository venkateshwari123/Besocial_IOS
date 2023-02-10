//
//  InviteContactsCell.swift
//  Crowwe
//
//  Created by Rahul Sharma on 05/03/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
class InviteContactsCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
        self.inviteButton.layer.borderColor = UIColor.lightGray.cgColor
        self.inviteButton.layer.borderWidth = 1.0
        self.inviteButton.layer.cornerRadius = 4.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setCellData(contact: UserProfile){
        let fullName = contact.firstName +  " " + contact.lastName
        if let name = fullName as? String, name != "", name != " "{
            self.userName.text = name
        }else if let name = contact.userName as? String{
            self.userName.text = name
        }

        
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: contact.profilePic, imageView: self.userImageView, fullName: contact.fullNameWithSpace ?? "D")
    }
    
}
