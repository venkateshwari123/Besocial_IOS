//
//  PaymentMethodAddButtonTVCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 26/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class PaymentMethodAddButtonTVCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.cornerRadius = 2
        button.layer.borderColor = Colors.attributeBorderColor.cgColor
        button.layer.borderWidth = 0.8
        button.setTitleColor(Colors.attributeBorderColor, for: .normal)
        button.titleLabel?.font = Theme.getInstance().followCountStyle.getFont()
    }
    
    func configureCell(text: String){
        self.button.setTitle(text, for: .normal)
    }

}
