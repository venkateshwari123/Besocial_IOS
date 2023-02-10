//
//  FriendRequestCellTableViewCell.swift
//  PicoAdda
//
//  Created by 3Embed on 22/10/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class FriendRequestCellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var imgProfilePicture: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
