//
//  PaymentMethodTableViewCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 26/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(isSelected: Bool, text: String, type:PaymentTypes){
        self.selectionImageView.image = isSelected ? #imageLiteral(resourceName: "radio_selected") : #imageLiteral(resourceName: "radio_empty")
    }
}
