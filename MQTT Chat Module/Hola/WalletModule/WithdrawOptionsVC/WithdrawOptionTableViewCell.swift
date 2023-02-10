//
//  WithdrawOptionTableViewCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 18/07/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class WithdrawOptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView : UIImageView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        label.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = Theme.getInstance().rechargeSuccessDetailStyle.getTextColor()
        }
    }
    
    func configureCell(option: WithdrawOption){
        imgView.contentMode = .scaleAspectFit
        Helper.addedUserImage(profilePic: option.imageUrl, imageView: self.imgView, fullName: option.pgName)
        label.text = option.pgName
        
    }

}
