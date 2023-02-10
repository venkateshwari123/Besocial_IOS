
//
//  GitStickerCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 13/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit


class GitStickerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var stickerImageView: UIImageView!
    
    
    
    func setCell(){
        
        stickerImageView.layer.cornerRadius = 5.0
        stickerImageView.clipsToBounds = true
        stickerImageView.layer.borderWidth = 1.0
        stickerImageView.layer.borderColor = UIColor.lightGray.cgColor
       
    }
    
}
