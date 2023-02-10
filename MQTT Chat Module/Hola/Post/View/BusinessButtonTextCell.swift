
//
//  BusinessButtonTextCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class BusinessButtonTextCell: UITableViewCell {

    @IBOutlet weak var businessTextBtnLbl: UILabel!
     @IBOutlet weak var indicationImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
     }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         // Configure the view for the selected state
    }

}
