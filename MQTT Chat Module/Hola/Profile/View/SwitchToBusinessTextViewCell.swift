//
//  SwitchToBusinessTextViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 4/24/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import TextFieldEffects
class SwitchToBusinessTextViewCell: UITableViewCell {

    @IBOutlet weak var textField: HoshiTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code self.textView.placeholderColor = Helper.hexStringToUIColor(hex: AppColourStr.lightGrayColor)
        self.textField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.textField.placeholderLabel.font = Utility.Font.Regular.ofSize(14.0)
        let frame = self.textField.frame
        self.textField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setTextCellData(text: String ,placeHolder: String){
        self.textField.placeholder = placeHolder
        self.textField.text = text
//        switch textField.tag {
//        case 1:
//            self.textField.text = modelData.businessName
//        case 2:
//            self.textField.text = modelData.businessAddress
//        default:
//             break
//        }
        
    }
    
   
}
