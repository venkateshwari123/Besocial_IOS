//
//  StatusTextTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 15/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class StatusTextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var removeStatusButton: UIButton!
    @IBOutlet weak var removeStatusButtonWidthConstraint: NSLayoutConstraint!
    
    var statusDelegate:UpdateStatusViewControllerDelegate?
    
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func removeStatusAction(_ sender: UIButton) {
        statusDelegate?.removeStatus()
        
    }
    
}
