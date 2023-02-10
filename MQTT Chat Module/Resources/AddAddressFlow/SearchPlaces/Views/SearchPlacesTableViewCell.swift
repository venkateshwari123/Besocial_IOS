//
//  SearchPlacesTableViewCell.swift
//  AddAddress
//
//  Created by Rahul Sharma on 15/04/21.
//

import UIKit

class SearchPlacesTableViewCell: UITableViewCell {
    @IBOutlet weak var  placeName: UIView!
    @IBOutlet weak var namelabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var  locationIcon: UIImageView!
    @IBOutlet weak var  arrowIcon: UIImageView!
    @IBOutlet weak var  separator: UIView!
    @IBOutlet weak var  locationNameLabel: UILabel!
    @IBOutlet weak var  locationtitleLabel: UILabel!
    @IBOutlet weak var  noLocationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        if self.noLocationLabel != nil{
            self.noLocationLabel.text = "No Results Found".localized
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setHeaderData()
    {
        locationIcon.isHidden = true
        arrowIcon.isHidden = true
        separator.isHidden = true
        Fonts.setFont(locationNameLabel, fontFamiy: .primary(.Bold), size: .standard(.h16), color: UIColor.setColor(lightMode: AppColourStr.blackColor, darkMode: AppColourStr.whiteColor))
        namelabelConstraint.constant = -20
    }
    
    func setPlaceHolder()
    {
        locationIcon?.isHidden = true
        arrowIcon?.isHidden = true
    }

}
