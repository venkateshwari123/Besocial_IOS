
//
//  BusinessAddressCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 28/05/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
import TextFieldEffects
class BusinessAddressCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var addressTextField: HoshiTextField!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        // Initialization code
       // addressTextField.font = Utility.Font.Regular.ofSize(15)
        self.addressTextField.placeholderColor = UIColor.setColor(lightMode: AppColourStr.lightGray, darkMode: AppColourStr.whiteColor)
        self.addressTextField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.addressTextField.placeholderLabel.font = Utility.Font.Regular.ofSize(17)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.addressTextField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.addressTextField.placeholderColor = UIColor.setColor(lightMode: AppColourStr.lightGray, darkMode: AppColourStr.whiteColor)
//        self.addressTextField.placeholderLabel.font = Utility.Font.Regular.ofSize(16)
        let frame = self.addressTextField.frame
        self.addressTextField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
    }
    
}
