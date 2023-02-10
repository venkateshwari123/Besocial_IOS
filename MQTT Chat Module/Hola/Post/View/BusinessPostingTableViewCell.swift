//
//  BusinessPostingTableViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
protocol businessPostingCellDelegate {
    func buttonAction(btnTag: Int)
}
class BusinessPostingTableViewCell: UITableViewCell {

    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var lblTitleText: UILabel!
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    var delegateObj:businessPostingCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        delegateObj?.buttonAction(btnTag: sender.tag)
    }
}
