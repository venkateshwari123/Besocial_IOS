//
//  NameHeaderTableViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 09/02/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class NameHeaderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabelOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
