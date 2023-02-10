//
//  NoDataPlaceHolderTableViewCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 09/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class NoDataPlaceHolderTableViewCell: UITableViewCell {

    @IBOutlet weak var placeHolderImage: UIImageView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func configureCell(image: UIImage, noDataText: String) {
        placeHolderImage.image = image
        noDataLabel.text = noDataText
    }
    
    func setup(){
        noDataLabel.font = Theme.getInstance().noLabelStyle.getFont()
        noDataLabel.textColor = Theme.getInstance().noLabelStyle.getTextColor()
    }
}
