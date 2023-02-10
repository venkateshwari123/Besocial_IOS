//
//  SwitchToBusinessDescriptionCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 4/24/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class SwitchToBusinessDescriptionCell: UITableViewCell {

    @IBOutlet weak var descriptionLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLbl.text = "People Will be able to email".localized + ". " + "call and get direction to your business from contact button and links on your profile".localized + "."
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
