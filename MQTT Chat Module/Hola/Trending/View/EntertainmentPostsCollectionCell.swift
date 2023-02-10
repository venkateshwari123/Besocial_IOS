//
//  EntertainmentPostsCollectionCell.swift
//  PicoAdda
//
//  Created by 3Embed on 11/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class EntertainmentPostsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /*
     Bug Name:- lock icon not appear on paid post
     Fix Date:- 27/03/21
     Fixed By:- Nikunj C
     Discription of Fix:- if post is not subscribed nor purchased then post blured with lock icon
     */
    
    func setCellDataFrom(modelData: SocialModel){
        for view in imageView.subviews{
            view.removeFromSuperview()
        }
        if modelData.userId != Utility.getUserid() {
            if modelData.isSubscribed == 1 {
                // don't add blur
                setPostedByData(modelData: modelData)
            }else {
                    if modelData.isPurchased == 1 {
                        //don't add blur
                        setPostedByData(modelData: modelData)
                    }else {
                        // add blur
                        DispatchQueue.main.async {
                            var blurredUrl = modelData.thumbnailUrl
                            blurredUrl = blurredUrl?.replace(target: "upload/", withString: "upload/")
                            Helper.setBlurrEffect(imageView: self.imageView,imageUrl: blurredUrl ?? "")
                            
                            /*Bug Name :- video image icon apear for image in trending view controller
                              Fix Date :- 23/03/2021
                              Fixed By :- Nikunj C
                              Description Of Fix :- add loadImage function */
                            
                            self.setPostedByData(modelData: modelData)
                        }
                    }
            }
        }else{
            setPostedByData(modelData: modelData)
        }
    }
    
    func setPostedByData(modelData: SocialModel){
        
        if modelData.mediaType == 1{
            if let url = modelData.thumbnailUrl{
                let endIndex = url.index(url.endIndex, offsetBy: -3)
                var truncated = url.substring(to: endIndex)
                truncated = truncated + "jpg"
                self.imageView.setImageOn(imageUrl: truncated, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }else{
                self.imageView.image = #imageLiteral(resourceName: "defaultPicture")
            }
            self.videoImageView.isHidden = false
        }else{
            if let url = modelData.imageUrl{
                self.imageView.setImageOn(imageUrl: url, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }else{
                self.imageView.image = #imageLiteral(resourceName: "defaultPicture")
            }
            self.videoImageView.isHidden = true
        }
    }
    
}
