//
//  LiveUsersTableViewCell.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 07/01/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class LiveUsersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var liveUserImageView: UIImageView!
    
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.makeCornerRadious(readious: backView.frame.width / 2)
        liveUserImageView.makeCornerRadious(readious: liveUserImageView.frame.width / 2)
        // Initialization code
    }
 
    func setModelDataInCell(data:StreamData) {
        Helper.addedUserImage(profilePic: data.userImage, imageView: self.liveUserImageView, fullName: data.userName)
        self.userNameLabel.text = data.userName
    }
}
