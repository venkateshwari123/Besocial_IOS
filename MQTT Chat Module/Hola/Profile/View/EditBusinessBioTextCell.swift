//
//  EditBusinessBioTextCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 10/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//
protocol editBusinessBioTextCellDelegate {
   func pushingToBusinessBioVc()
}
 import UIKit
 class EditBusinessBioTextCell: UITableViewCell {

    @IBOutlet weak var businessBioLabel: UILabel!
    
    var editBusinessBioDelegateObj:editBusinessBioTextCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func moveToBusinessBioAction(_ sender: UIButton) {
        editBusinessBioDelegateObj?.pushingToBusinessBioVc()
    }
}
