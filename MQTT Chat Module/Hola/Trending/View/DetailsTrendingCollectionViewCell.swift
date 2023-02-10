//
//  DetailsTrendingCollectionViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 19/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
class DetailsTrendingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var treadingImageView: AnimatedImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    
 
    override func awakeFromNib() {
        super.awakeFromNib()
        self.makeCornerRadious(readious: 2.0)
    }
    
    func setCellDataFrom(modelData: SocialModel, isPlaying: Bool){
        if modelData.mediaType == 1{
            if let url = modelData.imageUrl{
                if isPlaying{
                    let gifString = url.makeGifUrl()
                    self.treadingImageView.setImageOn(imageUrl: gifString, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    //                self.treadingImageView.setGifOnImage(imageUrl: gifString, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    //                self.treadingImageView.startAnimating()
                }else{
                    let imageUrl = url.makeThumbnailUrl()
                    self.treadingImageView.stopAnimating()
                    self.treadingImageView.setImageOn(imageUrl: imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                }
            }
            self.videoImageView.isHidden = false
        }else{
            self.videoImageView.isHidden = true
            self.treadingImageView.stopAnimating()
            
            self.treadingImageView.setImageOn(imageUrl: modelData.imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        }
    }
    
    
    //
    //    func setStoryCellDataFrom(modelData: StoriesModel, isPlaying: Bool,indexPath: Int){
    //        if modelData.postModelArray[indexPath].mediaType == 2{
    //            if let url = modelData.postModelArray[indexPath].thumbnail{
    //                if isPlaying{
    //                    let gifString = url.makeGifUrl()
    //                    self.treadingImageView.setImageOn(imageUrl: gifString, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
    //                    //                self.treadingImageView.setGifOnImage(imageUrl: gifString, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
    //                    //                self.treadingImageView.startAnimating()
    //                }else{
    //                    let imageUrl = url.makeThumbnailUrl()
    //                    self.treadingImageView.setImageOn(imageUrl: imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
    //                }
    //            }
    //            self.videoImageView.isHidden = false
    //        }else{
    //            self.videoImageView.isHidden = true
    //            self.treadingImageView.setImageOn(imageUrl: modelData.postModelArray[indexPath].thumbnail, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
    //        }
    //    }
    func setStoryCellDataFrom(modelData: StoryModel, isPlaying: Bool){
        
        if modelData.storyType == 1{
            if let url = modelData.thumbNailUrl{
                if isPlaying{
                    let gifString = url.makeGifUrl()
                    self.treadingImageView.setImageOn(imageUrl: gifString, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    //                self.treadingImageView.setGifOnImage(imageUrl: gifString, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    //                self.treadingImageView.startAnimating()
                }else{
                    let imageUrl = url.makeThumbnailUrl()
                    
                    self.treadingImageView.setImageOn(imageUrl: imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                }
            }
            self.videoImageView.isHidden = false
        }else{
            self.videoImageView.isHidden = true
            self.treadingImageView.stopAnimating()
            self.treadingImageView.setImageOn(imageUrl: modelData.thumbNailUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        }
    }
    
    func setCellData(modelData: ProfilePostModel){
        if modelData.mediaType == 1{
            if let url = modelData.imageUrl{
                //                let endIndex = url.index(url.endIndex, offsetBy: -3)
                //                var truncated = url.substring(to: endIndex)
                //                truncated = truncated + "gif"
                let gifString = url.makeGifUrl()
                self.treadingImageView.setImageOn(imageUrl: gifString, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }else{
                self.treadingImageView.image = #imageLiteral(resourceName: "defaultPicture")
            }
            self.videoImageView.isHidden = false
        }else{
            self.videoImageView.isHidden = true
            self.treadingImageView.stopAnimating()
            self.treadingImageView.setImageOn(imageUrl: modelData.imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        }
    }
    
    deinit{
        self.treadingImageView = nil
    }
}
