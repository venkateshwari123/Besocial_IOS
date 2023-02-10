//
//  InvitaContactTableViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 20/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class InvitaContactTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setInviteCellData(contact: Contacts){
        if let name = contact.fullName, name != "", name != " "{
            self.userName.text = name
        }else if let name = contact.registerNum{
            self.userName.text = name
        }
    }

}
