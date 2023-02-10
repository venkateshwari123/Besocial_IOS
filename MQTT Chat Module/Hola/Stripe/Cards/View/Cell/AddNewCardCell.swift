//
//  AddNewCardCell.swift
//  StripeDemo
//
//  Created by Rahul Sharma on 22/12/19.
//  Copyright © 2019 stripe. All rights reserved.
//

import UIKit

class AddNewCardCell: UITableViewCell {
    
    /// Add new card button to open Add Card ViewController
    @IBOutlet weak var addNewCardButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// Update Cell
    func updateCell() {
        // Update Add new card button tile for different button state
        addNewCardButton.setTitle("Add New Card", for: .normal)
        addNewCardButton.setTitle("Add New Card", for: .highlighted)
    }
}
