//
//  TrendingCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 06/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class TrendingCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var postsCount: UILabel!
    @IBOutlet weak var collectionNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionName: UILabel!
    @IBOutlet weak var treadingImageView: AnimatedImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.makeCornerRadious(readious: 2.0)
    }
    
    func setCellDataFrom(modelData: SocialModel, isPlaying: Bool){
        for view in treadingImageView.subviews{
            view.removeFromSuperview()
        }
        if modelData.userId != Utility.getUserid() {
                    if modelData.isPurchased == 1 {
                        //don't add blur
                        loadImage(modelData: modelData,isPlaying: isPlaying)
                    }else {
                        // add blur
                        var blurredUrl = modelData.thumbnailUrl
                        blurredUrl = blurredUrl?.replace(target: "upload/", withString: "upload/")
                        Helper.setBlurrEffect(imageView: treadingImageView,imageUrl: blurredUrl ?? "")
                        
                      /*Bug Name :- video image icon apear for image in trending view controller
                        Fix Date :- 23/03/2021
                        Fixed By :- Nikunj C
                        Description Of fix :- add loadImage function */
                        
                        loadImage(modelData: modelData, isPlaying: isPlaying)
                    }
        }else{
            loadImage(modelData: modelData,isPlaying: isPlaying)
        }
    }
    
    func loadImage(modelData: SocialModel,isPlaying: Bool) {
        if modelData.mediaType == 1{
            if let url = modelData.imageUrl{
                if isPlaying{
                 //  let gifString = url.makeGifUrl()
                   self.treadingImageView.setImageOn(imageUrl: modelData.thumbnailUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
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
    
    
    
    
    
    func setLiveVideoDataFrom(modelData: LiveVideosModel, isPlaying: Bool){
        self.treadingImageView.setImageOn(imageUrl: modelData.thumbnail, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
      }
    
    
    
    func setCellDataFromExplore(modelData: SocialModel, isPlaying: Bool){
        for view in treadingImageView.subviews{
            view.removeFromSuperview()
        }
        if modelData.userId != Utility.getUserid() {
     
                    if modelData.isPurchased == 1 {
                        //don't add blur
                        loadImage(modelData: modelData,isPlaying: isPlaying)
                    }else {
                        // add blur
                        DispatchQueue.main.async {
                            var blurredUrl = modelData.thumbnailUrl
                            blurredUrl = blurredUrl?.replace(target: "upload/", withString: "upload/")
                            Helper.setBlurrEffect(imageView: self.treadingImageView,imageUrl: blurredUrl ?? "")
                            
                            /*Bug Name :- video image icon apear for image in trending view controller
                              Fix Date :- 23/03/2021
                              Fixed By :- Nikunj C
                              Description Of Fix :- add loadImage function */
                            
                            self.loadImage(modelData: modelData,isPlaying: isPlaying)
                        }
                    }
        }else{
            loadImage(modelData: modelData,isPlaying: isPlaying)
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
    
    func setBookMarkCellData(modelData: SavedCollectionModel,index: Int){
        self.postsCount.font = Utility.Font.SemiBold.ofSize(14)
        self.collectionName.font = Utility.Font.SemiBold.ofSize(14)
        self.treadingImageView.makeCornerRadious(readious: 10)
        if !Utility.isDarkModeEnable(){
            self.treadingImageView.makeShadowEffect(color: UIColor.lightGray)
        }
        
            self.postsCount.text = "(\(modelData.posts.count))"
            self.collectionName.text = modelData.collectionName
            self.videoImageView.isHidden = true
            self.treadingImageView.stopAnimating()
        /*
         Bug Name:- Cover image not showing for allposts in profile collections
         Fix Date:- 16/04/2021
         Fixed By:- Jayaram G
         Description of Fix:- Handling response for allposts coverimage , showing first array coverimage
         */
        if index == 0 {
            if modelData.images.count > 0 {
                self.treadingImageView.setImageOn(imageUrl: modelData.images[0], defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }
        }else{
            self.treadingImageView.setImageOn(imageUrl: modelData.coverImage, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        }    }
    
    
    
    deinit{
        self.treadingImageView = nil
    }
}
