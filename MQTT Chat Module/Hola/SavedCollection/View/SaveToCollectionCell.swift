//
//  SaveToCollectionCell.swift
//  Starchat
//
//  Created by 3Embed on 03/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class SaveToCollectionCell: UICollectionViewCell {
    @IBOutlet weak var collectionPosts: UICollectionView!
    @IBOutlet weak var saveToCollectionLbl: UILabel!
    @IBOutlet weak var cancelBtnOutlet: UIButton!
    
    override func awakeFromNib() {
        saveToCollectionLbl.text = "Save To".localized
        cancelBtnOutlet.setTitle("Cancel".localized, for: .normal)
    }
    
}

class collectionItemsCell : UICollectionViewCell{
    @IBOutlet weak var imgCover : UIImageView!
    @IBOutlet weak var lblCollectionName : UILabel!
}
