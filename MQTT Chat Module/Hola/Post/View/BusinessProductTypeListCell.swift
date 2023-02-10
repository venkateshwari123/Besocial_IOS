//
//  BusinessProductTypeListCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 09/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class BusinessProductTypeListCell: UITableViewCell {

    @IBOutlet weak var indicationImageView: UIImageView!
    @IBOutlet weak var productTypeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
