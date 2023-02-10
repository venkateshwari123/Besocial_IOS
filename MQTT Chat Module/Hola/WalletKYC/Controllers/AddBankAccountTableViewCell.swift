//
//  AddBankAccountTableViewCell.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/7/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import UIKit
import TextFieldEffects


class AddBankAccountTableViewCell: UITableViewCell {

    
    @IBOutlet weak var addressLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var topTextFieldOutlet: HoshiTextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textFieldUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setDataInCell(_ index: Int){
        switch index {
        case 0 :
            self.addressLabelHeightConstraint.constant = 30
            self.topTextFieldOutlet.placeholder = "IFSC Code".localized + "*"
           
        case 1:
            self.addressLabelHeightConstraint.constant = 0
            self.topTextFieldOutlet.placeholder = "Account Number".localized + "*"
            self.topTextFieldOutlet.isSecureTextEntry = true
            
        case 2:
            self.addressLabelHeightConstraint.constant = 0
            self.topTextFieldOutlet.placeholder = "Confirm".localized + " " + "Account Number".localized + "*"
            self.topTextFieldOutlet.isSecureTextEntry = true
      
        case 3:
            self.addressLabelHeightConstraint.constant = 0
            self.topTextFieldOutlet.placeholder = "Account Holder Name".localized + "*"
           
        case 4:
            self.addressLabelHeightConstraint.constant = 0
            self.topTextFieldOutlet.placeholder = "Nick Name".localized
          
        default:
            break
            
        }
    }
    
    func textFieldUI() {
        self.topTextFieldOutlet.textColor =  UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.topTextFieldOutlet.placeholderColor =  UIColor.lightGray
        self.topTextFieldOutlet.placeholderLabel.font = Utility.Font.Regular.ofSize(22)
        let frame = self.topTextFieldOutlet.frame
        self.topTextFieldOutlet.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
    }
  
}
