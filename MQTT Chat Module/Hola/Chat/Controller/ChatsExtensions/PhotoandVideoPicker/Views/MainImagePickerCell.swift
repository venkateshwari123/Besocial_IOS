//
//  MainImagePickerCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 13/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Photos

class MainImagePickerCell: UICollectionViewCell {
    
    lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
   
    @IBOutlet weak var mainImageView: UIImageView!
    
    
    func setMainImage(image:Any){
        let  options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false
        
        
        if let img = image as? TLPHAsset {
        _  = self.imageManager.requestImage(for: img .phAsset!, targetSize: CGSize.init(width: self.frame.size.width, height: self.frame.size.height), contentMode: .aspectFill, options: options) { image, info in
            if let image = image {
                self.mainImageView.image = image
            }
          }
        }else {
            
            if let img = image as? UIImage{
            self.mainImageView.image = img            }
        }
        
    }
    
    
}
