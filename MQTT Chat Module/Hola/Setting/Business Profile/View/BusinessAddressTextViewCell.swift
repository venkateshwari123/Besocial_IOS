//
//  BusinessAddressTextViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 01/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
class BusinessAddressTextViewCell: UITableViewCell{

    @IBOutlet weak var businessAddressTextView: GrowingTextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib(){
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
