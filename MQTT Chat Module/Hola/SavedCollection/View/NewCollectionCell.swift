//
//  NewCollectionCell.swift
//  Starchat
//
//  Created by 3Embed on 03/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class NewCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imgCollectionCover: UIImageView!
    @IBOutlet weak var tfCollectionName: UITextField!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var newCollectionLbl: UILabel!
    
    override func awakeFromNib() {
        newCollectionLbl.text = "New Collection".localized
    }
    
}
