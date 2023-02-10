//
//  ChannelCollectionCell.swift
//  Do Chat
//
//  Created by Yagnik Suthar on 15/06/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class ChannelCollectionCell: UICollectionViewCell {

    @IBOutlet weak var channelImageView: AnimatedImageView!
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.makeCornerRadious(readious: 2.0)
    }
    
    func setCellDataFrom(modelData: SocialModel, isPlaying: Bool){
        if modelData.mediaType == 1{
            if let url = modelData.imageUrl{
                if isPlaying{
                 //  let gifString = url.makeGifUrl()
                   self.channelImageView.setImageOn(imageUrl: modelData.thumbnailUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    //                self.treadingImageView.setGifOnImage(imageUrl: gifString, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    //                self.treadingImageView.startAnimating()
                }else{
                    let imageUrl = url.makeThumbnailUrl()
                    self.channelImageView.stopAnimating()
                    self.channelImageView.setImageOn(imageUrl: imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                }
            }
            self.videoImageView.isHidden = false
        }else{
            self.videoImageView.isHidden = true
            self.channelImageView.stopAnimating()

            self.channelImageView.setImageOn(imageUrl: modelData.imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        }
    }

}
