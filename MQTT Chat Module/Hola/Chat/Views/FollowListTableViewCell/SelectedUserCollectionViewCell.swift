//
//  SelectedUserCollectionViewCell.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 23/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class SelectedUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!    
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
    }
}
