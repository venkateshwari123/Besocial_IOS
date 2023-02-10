//
//  StripeSignUpImageTableViewCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 04/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class StripeSignUpImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var proofImageView: UIImageView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var placeHolderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(image: UIImage){
        self.proofImageView.image = image
    }

}


class StripeNameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var fastNameTextField: UITextField!
    @IBOutlet weak var firstNamePlaceHolderLabel: UILabel!
    @IBOutlet weak var lastNamePlaceHolderLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(firstName: String, lastName: String){
        
        
    }

}
