//
//  BusinessContactInfoAddressTextviewCell.swift
//  Do Chat
//
//  Created by Rahul Sharma on 15/05/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class BusinessContactInfoAddressTextviewCell: UITableViewCell, GrowingTextViewDelegate{

    @IBOutlet weak var addressTextView: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var contactInfoButtonOutlet: UIButton!
    
    var businessContactInfoTextCellDelegate:BusinessContactCellDelegate?
    var isBioChanged = false
    var isAddressChanged = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = UIColor.setColor(lightMode: AppColourStr.lightGray, darkMode: AppColourStr.whiteColor)
        self.addressTextView.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setPlaceholder(placeHolder:String){
        self.addressTextView.text = placeHolder
        self.addressTextView.font = Utility.Font.Regular.ofSize(13)
    }
    @IBAction func contactInfoBtnAction(_ sender: UIButton) {
        businessContactInfoTextCellDelegate?.pushingToDetailsVc(tag: sender.tag)
        
    }
    
    fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
        return input.rawValue
    }
}

