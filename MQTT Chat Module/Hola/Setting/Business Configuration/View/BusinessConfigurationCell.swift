//
//  BusinessConfigurationCell.swift
//  Starchat
//  jayaram G
//  Created by Rahul Sharma on 24/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
class BusinessConfigurationCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var lblConfigurationOptions: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblConfigurationOptions.font = Utility.Font.Regular.ofSize(16)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
