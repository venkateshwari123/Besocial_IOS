//
//  SearchLocationTableViewCell.swift
//  LiveM
//
//  Created by Apple on 28/08/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import GooglePlaces


class SearchLocationTableViewCell:UITableViewCell {
    
    @IBOutlet weak var addressLabel1: UILabel!
    @IBOutlet weak var addressLabel2: UILabel!
    @IBOutlet weak var removeAddressButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var addressImageButton: UIButton!
    @IBOutlet weak var addressLabel1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var removeAddressButtonWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCellData(placeData: LocationModel){
        self.addressLabel1?.text = placeData.primarytext
        self.addressLabel2?.text = placeData.secondaryText
        
        self.removeAddressButton.isHidden = true
        self.removeAddressButtonWidthConstraint.constant = 0
        
        let height1:CGFloat =  Helper.measureHeightLabel(label: self.addressLabel1, width: self.frame.size.width - 67)
        
        self.addressLabel1HeightConstraint.constant = height1 + 4
    }
    
}
