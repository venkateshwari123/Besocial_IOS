//
//  SavedPostsProfileCollectionViewCell.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 10/03/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
class SavedPostsProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionName: UILabel!
    @IBOutlet weak var treadingImageView: AnimatedImageView!

    func setBookMarkCellData(modelData: SavedCollectionModel){
            self.treadingImageView.stopAnimating()
            self.treadingImageView.setImageOn(imageUrl: modelData.coverImage, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        self.collectionName.text = modelData.collectionName
    }
}
