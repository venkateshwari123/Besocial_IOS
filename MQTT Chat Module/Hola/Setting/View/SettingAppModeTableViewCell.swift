//
//  SettingAppModeTableViewCell.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 05/10/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class SettingAppModeTableViewCell: UITableViewCell {

    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var switchOutlet: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Utility.isDarkModeEnable(){
            switchOutlet.setOn(true, animated: false)
        }else{
            switchOutlet.setOn(false, animated: false)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchAction(_ sender: UISwitch){
        if #available(iOS 13.0, *) {
             let appDelegate = UIApplication.shared.windows.first
                 if sender.isOn {
                    appDelegate?.overrideUserInterfaceStyle = .dark
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isDarkModeEnable)
                      return
                 }
            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isDarkModeEnable)
             appDelegate?.overrideUserInterfaceStyle = .light
             return
        }
    }
    
}
