//
//  PostShareTableViewCell.swift
//  dub.ly
//
//  Created by Shivansh on 1/31/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class PostShareTableViewCell: UITableViewCell {

    
    @IBOutlet weak var borderLineForShare: UIView!
    @IBOutlet weak var shareToLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shareToLbl.text = "Share to".localized
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         // Configure the view for the selected state
    }

}
