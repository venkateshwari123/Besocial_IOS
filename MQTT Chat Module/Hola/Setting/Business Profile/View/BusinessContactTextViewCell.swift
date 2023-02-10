//
//  BusinessContactTextViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 30/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import TextFieldEffects
class BusinessContactTextViewCell: UITableViewCell {

    
    @IBOutlet weak var contactInfoTextField: HoshiTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contactInfoTextField.placeholderColor = UIColor.setColor(lightMode: AppColourStr.lightGray, darkMode: AppColourStr.whiteColor)
        self.contactInfoTextField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.contactInfoTextField.font = Utility.Font.Regular.ofSize(16)
        let frame = self.contactInfoTextField.frame
        self.contactInfoTextField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
