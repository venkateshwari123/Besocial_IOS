//
//  FavoriteFriendsCell.swift
//  Starchat
//
//  Created by 3Embed on 01/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class FavoriteFriendsCell: UITableViewCell {

    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var starUserIndicator: UIImageView!
    @IBOutlet weak var friendRequestCountLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        friendRequestCountLabel.makeCornerRadious(readious: 15)
        imgProfilePic.makeImageCornerRadius(self.imgProfilePic.frame.width / 2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
