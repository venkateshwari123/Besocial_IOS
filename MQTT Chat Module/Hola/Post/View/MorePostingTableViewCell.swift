//
//  MorePostingTableViewCell.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 05/01/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class MorePostingTableViewCell: UITableViewCell {

    @IBOutlet weak var allowCommentsSwitch: UISwitch!
    @IBOutlet weak var allowDownloadsSwitch: UISwitch!
    @IBOutlet weak var allowCommentsLbl: UILabel!
    @IBOutlet weak var allowDownloadsLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        allowCommentsLbl.text = "Allow Comments".localized
        allowDownloadsLbl.text = "Allow Downloads".localized
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
