//
//  EditProfileTextTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 15/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import TextFieldEffects

class EditProfileTextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textView: HoshiTextField!
    @IBOutlet weak var arrowImageView: UIImageView!
    
//    @IBOutlet weak var editButton: UIButton!
//    
//    @IBOutlet weak var editButtonWidthConstraint: NSLayoutConstraint!
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.placeholderColor = Helper.hexStringToUIColor(hex: AppColourStr.lightGrayColor)
        self.textView.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.textView.font = Utility.Font.Regular.ofSize(15)
        self.textView.placeholderLabel.font = Utility.Font.Regular.ofSize(15)
        let frame = self.textView.frame
        self.textView.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTextCellData(placeHolder: String, text:String){
        self.textView.placeholder = placeHolder
        self.textView.text = text
    }
}
