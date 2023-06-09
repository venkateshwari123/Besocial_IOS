//
//  FSAlbumView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia

final class FSAlbumView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageCropView: FSImageCropView!
    @IBOutlet weak var imageCropViewContainer: ImageCropViewContainer!
    
    @IBOutlet weak var collectionViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var imageCropViewConstraintTop: NSLayoutConstraint!
    
    let line = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sv(
            line
        )
        
        layout(
            imageCropViewContainer,
            |line| ~ 1
        )
        
        line.backgroundColor = .white
    }
}
