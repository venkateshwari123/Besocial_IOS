//
//  BusinessContactInfoPrivateAccountCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/24/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit

/// BusinessContactInfoPrivate Account Cell Delegate To Handle the Cell Button Actions
protocol BusinessContactInfoPrivateAccountCellDelegate {
    func creatBusinessPostApiCalling()
    func privateAccountSwitching()
}

class BusinessContactInfoPrivateAccountCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var switchOutlet: UISwitch!
    
    //MARK:- Variables&Declarations
    var privateAccountCellDelegate: BusinessContactInfoPrivateAccountCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        switchOutlet.isOn = false
        switchOutlet.transform = CGAffineTransform(scaleX: 0.8 , y: 0.7)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    /// Calling Create Business API
    ///
    /// - Parameter sender: nextBtn
    @IBAction func nextBtnAction(_ sender: UIButton) {
        privateAccountCellDelegate?.creatBusinessPostApiCalling()
    }
    
    
    /// Switching into private/public Account
    ///
    /// - Parameter sender: switch Button
    @IBAction func privateAccountSwitchAction(_ sender: UISwitch) {
        privateAccountCellDelegate?.privateAccountSwitching()
    }
}
