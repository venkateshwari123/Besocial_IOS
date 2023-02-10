//
//  AddContactsCell.swift
//  Starchat
//
//  Created by 3Embed on 28/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class AddContactsCell: UITableViewCell {

    @IBOutlet weak var imgProfilePicture: UIImageView!
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnAddFollow: UIButton!
    
    @IBOutlet weak var starIndicationImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
