//
//  ChangeCurrencyCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 4/17/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class ChangeCurrencyCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var selectionImage: UIImageView!
    @IBOutlet weak var currencyLbl: UILabel!
    
     override func awakeFromNib() {
        super.awakeFromNib()
        currencyLbl.font = Utility.Font.Regular.ofSize(15)
        selectionImage.makeImageCornerRadius(10)
        selectionImage.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
