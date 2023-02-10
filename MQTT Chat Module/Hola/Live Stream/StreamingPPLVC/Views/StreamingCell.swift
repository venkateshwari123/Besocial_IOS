//
//  StreamingCell.swift
//  Stream
//
//  Created by Vengababu Maparthi on 15/11/18.
//  Copyright © 2018 Vengababu Maparthi. All rights reserved.
//

import UIKit
import Kingfisher

class StreamingCell: UICollectionViewCell {
    
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var countViews: UILabel!
    @IBOutlet weak var streamLabel: UILabel!
    @IBOutlet weak var streamImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var liveLbl: UILabel!
    var img = ""
    
    override func awakeFromNib() {
        self.liveLbl.text = "Live".localized
    }
    var data:StreamData! {
        didSet{
            
            self.streamLabel.text = data.userName
            self.countViews.text =  data.viewers
            self.topView.makeShadowOf(width: (UIScreen.main.bounds.size.width - 48)/2, height: (UIScreen.main.bounds.size.width - 32)/2 + 22)
            img = data.userImage
            Helper.addedUserImage(profilePic: data.thumbnail, imageView: self.streamImage, fullName: data.userName)
            Helper.addedUserImage(profilePic: data.userImage, imageView: self.userImage, fullName: data.userName)
            if data.following == 0{
                self.btnFollow.isSelected = false
            }else{
                self.btnFollow.isSelected = true
            }
            
        }
    }
    
//    func downLoadTheImg(url:String) {
//        self.streamImage.kf.setImage(with: URL(string: img),
//                                     placeholder:UIImage.init(named: "Group 302"),
//                                     options: [.transition(ImageTransition.fade(1))],
//                                     progressBlock: { receivedSize, totalSize in
//        },
//                                     completionHandler: { image, error, cacheType, imageURL in
//                                        if error == nil{
//                                            self.activityIndicator.stopAnimating()
//                                        }else{
//                                            self.downLoadTheImg(url: self.img)
//                                        }
//
//        })
//    }
}
