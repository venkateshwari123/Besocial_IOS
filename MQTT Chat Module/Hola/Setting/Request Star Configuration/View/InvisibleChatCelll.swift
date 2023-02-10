//
//  InvisibleChatCelll.swift
//  Starchat
//
//  Created by Rahul Sharma on 03/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
protocol InvisibleChatCellDelegate {
    func switchingAction(state:Bool)
}
class InvisibleChatCelll: UITableViewCell {
    
 @IBOutlet weak var chatEnableDiableSwitchOutlet: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var invisibleChatCellDelegateObj:InvisibleChatCellDelegate?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      }
    
    
    @IBAction func chatEnableDisableAction(_ sender: UISwitch) {
        if chatEnableDiableSwitchOutlet.isOn {
           invisibleChatCellDelegateObj?.switchingAction(state: true)
        }else {
           invisibleChatCellDelegateObj?.switchingAction(state: false)
        }
     }
}
