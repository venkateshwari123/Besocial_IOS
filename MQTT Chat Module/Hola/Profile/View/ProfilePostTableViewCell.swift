//
//  ProfilePostTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 18/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class ProfilePostTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var postImageView: AnimatedImageView!
    @IBOutlet weak var playImageView: UIImageView!
    
    @IBOutlet weak var commentButtonOulet: UIButton!
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var deteLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCellData(modelData: ProfilePostModel){
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 17/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.userImageView, fullName: modelData.userName ?? "D")
        self.userNameLabel.text = modelData.userName
        if modelData.liked == 0{
            self.likeButtonOutlet.isSelected = false
           self.likeImageView.image = #imageLiteral(resourceName: "favourite_black")
        }else{
            self.likeImageView.image = #imageLiteral(resourceName: "like_on")
            self.likeButtonOutlet.isSelected = true
        }
        self.detailsLabel.text = modelData.title
        let time = Helper.getTimeStamp(timeStamp: modelData.timeStamp)
        let timeArr = time.components(separatedBy: " ")
        var timeString = ""
        for item in timeArr{
            timeString.append(item.localized + " ")
        }
        self.deteLabel.text = timeString
    }
    
    func setCellImageView(modelData: ProfilePostModel){
        if modelData.mediaType == 1{
            if let url = modelData.thumbnailUrl{
//                let endIndex = url.index(url.endIndex, offsetBy: -3)
//                var truncated = url.substring(to: endIndex)
//                truncated = truncated + "gif"
                let gifString = url.makeGifUrl()
                self.postImageView.setImageOn(imageUrl: gifString, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                self.postImageView.startAnimating()
            }
            playImageView.isHidden = false
        }else{
            if let url = modelData.imageUrl{
                self.postImageView.setImageOn(imageUrl: url, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }
            self.playImageView.isHidden = true
        }
    }
}
