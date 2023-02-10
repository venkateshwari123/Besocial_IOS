//
//  BusinessEditContactOptionsCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 02/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//
import UIKit
import TextFieldEffects
protocol BusinessEditContactOptionsCellDelegate {
  
    func editBusinessContactOptionsAction(_ buttonTag: Int)
}
class BusinessEditContactOptionsCell: UITableViewCell {

    
    //MArk:- All Outlets
    @IBOutlet weak var editBusinessContactOptionsBtnOutlet: UIButton!
  
    @IBOutlet weak var placeHolderLabelText: UILabel!
    
    @IBOutlet weak var detailsLabelText: UILabel!
    
    /// variables and declarations
    var businessContactOptionsCellDelegate: BusinessEditContactOptionsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    @IBAction func editBusinessContactOptionsAction(_ sender: UIButton) {
        
        businessContactOptionsCellDelegate?.editBusinessContactOptionsAction(sender.tag)
    }
}
