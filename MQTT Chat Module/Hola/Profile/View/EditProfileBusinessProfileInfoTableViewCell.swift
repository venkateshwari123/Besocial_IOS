//
//  EditProfileBusinessProfileInfoTableViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 04/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

protocol EditProfileBusinessProfileInfoTableViewCellDelegate {
    func changeBusinessCategoryAction()
    func changeBusinessConatactOptionsAction()

}

class EditProfileBusinessProfileInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var businessCategoryBtnOutlet: UIButton!
    @IBOutlet weak var changeBusinessConatactOptionsOutlet: UIButton!
    
    var editProfileBusinessProfileInfoCellDelegate:EditProfileBusinessProfileInfoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func changeBusinessConatactOptionsAction(_ sender: UIButton) {
        editProfileBusinessProfileInfoCellDelegate?.changeBusinessConatactOptionsAction()
    }
    
    
    @IBAction func businessCategoryAction(_ sender: UIButton) {
        editProfileBusinessProfileInfoCellDelegate?.changeBusinessCategoryAction()
    }
}
