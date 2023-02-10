//
//  ImagePickerCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 12/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import TLPhotoPicker

class ThumbImagePickerCell: UICollectionViewCell {
    
    
    @IBOutlet weak var thumbImage: UIImageView!
    
        func setThumbImage(image: Any){
            
            if let img =  image as? TLPHAsset{
             thumbImage.image = img.fullResolutionImage
            }else {
                if let img = image as? UIImage{
                    thumbImage.image = img
                }
            }
        }
}
