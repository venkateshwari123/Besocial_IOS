//
//  RequestStarProfileTextCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/2/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit
import TextFieldEffects

/// RequestStarProfileTextCellDelegate To  manage the actions in Cell
protocol RequestStarProfileTextCellDelegate: class{
    func movingToCountryVc()
}
class RequestStarProfileTextCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var detailsTextField: HoshiTextField!
    @IBOutlet weak var countryNameOutlet: UIButton!
    @IBOutlet weak var countryPickerView: UIView!
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var countryCodeNumberOutlet: UILabel!
    
    
    @IBOutlet weak var countryCodeLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropDownImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var countryButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var countryImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var countryPickerViewWidthConstraints: NSLayoutConstraint!
    
    //MARK:- Variables&Declarations
    var currentCountryCode = "US"  // Used To Store current country code
    var textCellDelegate: RequestStarProfileTextCellDelegate?  // Used To get referance of RequestStarProfileTextCellDelegate Protocol
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        /// Getting current Country Details
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            countryCodeNumberOutlet.text = VNHCountryPicker.dialCode(code: countryCode).dialCode
            currentCountryCode = VNHCountryPicker.dialCode(code: countryCode).code
            countryImageView.image = VNHCountryPicker.getCountryImage(code: countryCode)
        }
        
        
        
//        self.detailsTextField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
//        self.detailsTextField.placeholderColor = UIColor.lightGray
        self.detailsTextField.placeholderLabel.font = Utility.Font.Regular.ofSize(22.0)
        let frame = self.detailsTextField.frame
        self.detailsTextField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    /// Moving To Country Picker ViewController
    ///
    /// - Parameter sender: Country Button
    @IBAction func moveToCountryPickerVc(_ sender: UIButton) {
        textCellDelegate?.movingToCountryVc()
    }
    
    
    
    
    
    
}
