//
//  MediaVideoCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 07/03/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class MediaVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoThumbnailOutlet: UIImageView!
    @IBOutlet weak var chatVideoIconOutlet: UIImageView!
    
    var msgObject : Message! {
        didSet {
            if let tData = msgObject.thumbnailData {
                DispatchQueue.global(qos: .default).async {
                    let tdata = tData.replace(target: "\n", withString: "")
                    if let tImage = Image.convertBase64ToImage(base64String: tdata) {
                        DispatchQueue.main.async {
                            self.videoThumbnailOutlet.image = tImage
                        }
                    }
                }
            }
        }
    }
    
}
