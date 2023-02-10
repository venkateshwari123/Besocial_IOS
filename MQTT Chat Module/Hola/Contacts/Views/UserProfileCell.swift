//
//  UserProfileTableViewCell.swift
//  Starchat
//
//  Created by 3Embed on 01/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
protocol UserProfileDelegate {
    func pushingToProfileVc()
}

class UserProfileCell: UITableViewCell {

    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var imgProfilePicture: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var userProfileCellObject:UserProfileDelegate?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    

    @IBAction func profileImageAction(_ sender: UIButton) {
        userProfileCellObject?.pushingToProfileVc()
    }
}
