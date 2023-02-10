//
//  SwitchToBusinessTitleCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 4/24/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class SwitchToBusinessTitleCell: UITableViewCell {

    @IBOutlet weak var setUPBALbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setUPBALbl.text = "Set up Your Business Account".localized
        descriptionLbl.text = "Edit or remove any information that you don't want to be displayed on City smart".localized + ". " + "You can always edit this at any time in setting".localized + "."
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
