
//
//  SelectGpMemTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 23/01/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class SelectGpMemTableViewCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
