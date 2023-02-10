//
//  StoryTableViewCell.swift
//  dub.ly
//
//  Created by Shivansh on 1/8/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var viewForLastImage: UIView!
    
    @IBOutlet weak var lastStatusImage: UIImageView!
    
    @IBOutlet weak var addStatusButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var lastStatusTime: UILabel!
    
    
    @IBOutlet weak var moreButtonOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
