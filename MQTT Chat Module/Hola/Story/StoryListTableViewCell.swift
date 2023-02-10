//
//  StoryListTableViewCell.swift
//  dub.ly
//
//  Created by Shivansh on 1/9/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class StoryListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var watchStoriesBtn: UIButton!
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var statusTimeLabel: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
