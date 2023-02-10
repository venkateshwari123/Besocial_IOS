//
//  VNHCountryPickerCell.swift
//  Trustpals
//
//  Created by Rahul Sharma on 02/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

import UIKit

class VNHCountryPickerCell: UITableViewCell {

    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var countryCode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
