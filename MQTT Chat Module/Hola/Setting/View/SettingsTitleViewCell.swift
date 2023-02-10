//
//  SettingsTitleViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/2/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
class SettingsTitleViewCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var settingcellImageView: UIImageView!
    @IBOutlet weak var settingTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
