//
//  BusinessContactInfoDetailsTextCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/24/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit

class BusinessContactInfoDetailsTextCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.descriptionLbl.text = "People will be able to email".localized + ", " + "call and get directions to your Business from new button and links on your profile".localized
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
