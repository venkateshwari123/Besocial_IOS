//
//  EditProfileHeaderTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 15/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class EditProfileHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPrivateInfo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblPrivateInfo.font = Utility.Font.Bold.ofSize(17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
