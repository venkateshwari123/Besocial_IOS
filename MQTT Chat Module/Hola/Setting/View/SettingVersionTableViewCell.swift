//
//  SettingVersionTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 17/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
class SettingVersionTableViewCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var versionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "v " + version
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
