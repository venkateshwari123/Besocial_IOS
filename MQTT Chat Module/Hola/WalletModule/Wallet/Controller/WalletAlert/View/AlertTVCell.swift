//
//  AlertTVCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 24/04/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class AlertTVCell: UITableViewCell {

    @IBOutlet weak var alertNameLabel: UILabel!
    @IBOutlet weak var selectedTypeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        alertNameLabel.font = Theme.getInstance().alertLabel.getFont()
        selectedTypeImage.contentMode = .scaleAspectFill
    }
    
    func configureCell(typeName: String,isSelected:Bool) {
        
        selectedTypeImage.image = isSelected ? #imageLiteral(resourceName: "radio_selected") :  #imageLiteral(resourceName: "radio_empty")
        alertNameLabel.text = typeName        
     }
}
