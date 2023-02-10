//
//  SwitchToBusinessAccountCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 4/23/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
protocol EditProfileSwitchToBusinessTableViewCellDelegate: class{
    func moveToSwitchVc()
}
class SwitchToBusinessAccountCell: UITableViewCell {

    var delegate1: EditProfileSwitchToBusinessTableViewCellDelegate?
    
    @IBOutlet weak var switchToBusinessBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.switchToBusinessBtn.titleLabel?.font = Utility.Font.Bold.ofSize(17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func moveToSwitchBusinessAction(_ sender: UIButton) {
        print("something")
        delegate1?.moveToSwitchVc()
    }
}

