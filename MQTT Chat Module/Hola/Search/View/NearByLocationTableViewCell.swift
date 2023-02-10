//
//  NearByLocationTableViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 08/03/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class NearByLocationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
