//
//  BusinessContactInfoTextCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/23/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit
import TextFieldEffects

/// Business ContactCell Protocol  Delegate
protocol BusinessContactCellDelegate {
    func pushingToDetailsVc(tag: Int)
}
class BusinessContactInfoTextCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var arrowImageOutlet: UIImageView!
    
    @IBOutlet weak var textFieldOutlet: HoshiTextField!
    
    @IBOutlet weak var contactInfoButtonOutlet: UIButton!
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    
    //MARK:-Variables&Declarations
    var businessContactInfoTextCellDelegate:BusinessContactCellDelegate?
    var currentCountryCode = "US"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textFieldOutlet.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.textFieldOutlet.placeholderColor = UIColor.setColor(lightMode: AppColourStr.lightGray, darkMode: AppColourStr.whiteColor)
        self.textFieldOutlet.font = Utility.Font.Regular.ofSize(16)
        let frame = self.textFieldOutlet.frame
        self.textFieldOutlet.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func contactInfoBtnAction(_ sender: UIButton) {
        businessContactInfoTextCellDelegate?.pushingToDetailsVc(tag: sender.tag)
        
    }
}
