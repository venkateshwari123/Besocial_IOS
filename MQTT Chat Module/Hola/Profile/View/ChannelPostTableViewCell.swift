
//
//  ChannelPostTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 18/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
protocol channelViewDelegate {
    func deleteChannelAction(_ tag: Int)
    func editChannelAction(_ tag: Int)
    func moveToChannelPostAction(_ tag:Int, sender : UIButton)
    func moveViewToChannelPostAction(_ tag: Int)
    func moveToPostedByChannel(_ tag: Int)
}

class ChannelPostTableViewCell: UITableViewCell {

    @IBOutlet weak var firstPostButtonOutlet: UIButton!
    @IBOutlet weak var secondPostButtonOutlet: UIButton!
    
    @IBOutlet weak var thirdPostButtonOutlet: UIButton!
    
    
    @IBOutlet weak var fourthPostButtonOutlet: UIButton!
    
    @IBOutlet weak var arrowImageOutlet: UIImageView!
    @IBOutlet weak var channelPostViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var deleteChannelBtnOutlet: UIButton!
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelStatusImageView: UIImageView!
    @IBOutlet weak var editButtonOutlet: UIButton!
    
    @IBOutlet weak var firstPostImageView: UIImageView!
    @IBOutlet weak var firstPlayImageView: UIImageView!
    @IBOutlet weak var secondPostImageView: UIImageView!
    @IBOutlet weak var secondPlayImageView: UIImageView!
    @IBOutlet weak var thirdPostImageView: UIImageView!
    @IBOutlet weak var thirdPlayImageView: UIImageView!
    
    @IBOutlet weak var firstPostThumbnail: UIImageView!
    @IBOutlet weak var secondPostThumbnail: UIImageView!
    @IBOutlet weak var thirdPostThumbnail: UIImageView!
    
//    @IBOutlet weak var fourthPostImageView: UIImageView!
//    @IBOutlet weak var fourthPlayImageView: UIImageView!
//    @IBOutlet weak var morePostView: UIView!
//    @IBOutlet weak var morePostCountLabel: UILabel!
    
    @IBOutlet weak var viewMoreOnChannlePostView: UIView!
    @IBOutlet weak var channelViewMoreButton: UIButton!

    
    var channelViewDelegate:channelViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewMoreOnChannlePostView.makeGradientToUserView()
        self.channelImageView.makeCornerRadious(readious: self.channelImageView.frame.size.width / 2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    
    func setCellData(modelData: ProfileChannelModel, isSelf: Bool){
       if modelData.dataArray.count > 3{
        viewMoreOnChannlePostView.isHidden = false
        }
        else {
        viewMoreOnChannlePostView.isHidden = true
        }
        self.channelImageView.setImageOn(imageUrl: modelData.channelImageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        self.channelNameLabel.text = modelData.channelName
        if isSelf {
            self.arrowImageOutlet.isHidden = true
        }else {
            self.arrowImageOutlet.isHidden = false
        }
//        if !isSelf {
//            if modelData.privicy == 1 {
//                if modelData.isSubscribed == 0{
//                    self.channelPostViewHeightConstraint.constant = 0
//                    self.contentView.heightAnchor.constraint(equalToConstant: 65).isActive = true
//                    }
//                }
//            }
        
        
        switch modelData.dataArray.count {
        case 1:
            self.firstPostButtonOutlet.isEnabled = true
            self.secondPostButtonOutlet.isEnabled = false
            self.thirdPostButtonOutlet.isEnabled = false
//            self.fourthPostButtonOutlet.isEnabled = false
        case 2:
            self.firstPostButtonOutlet.isEnabled = true
            self.secondPostButtonOutlet.isEnabled = true
            self.thirdPostButtonOutlet.isEnabled = false
//            self.fourthPostButtonOutlet.isEnabled = false
        case 3:
            self.firstPostButtonOutlet.isEnabled = true
            self.secondPostButtonOutlet.isEnabled = true
            self.thirdPostButtonOutlet.isEnabled = true
//            self.fourthPostButtonOutlet.isEnabled = false
        default:
//            self.firstPostButtonOutlet.isEnabled = true
//            self.secondPostButtonOutlet.isEnabled = true
//            self.thirdPostButtonOutlet.isEnabled = true
//            self.fourthPostButtonOutlet.isEnabled = true
            break
        }
        if modelData.privicy == 0{
            self.channelStatusImageView.image = #imageLiteral(resourceName: "public_channel")
        }else{
            self.channelStatusImageView.image = #imageLiteral(resourceName: "private_channel")
        }
        self.editButtonOutlet.isHidden = !isSelf
        self.deleteChannelBtnOutlet.isHidden = !isSelf
        
    
        if modelData.dataArray.count > 4{
//            self.morePostView.isHidden = false
//            self.morePostCountLabel.isHidden = false
//            self.morePostCountLabel.text = "+ \(modelData.dataArray.count - 4)"
        }else{
//            self.morePostView.isHidden = true
//            self.morePostCountLabel.isHidden = true
        }
        var index:Int = 0
        for postData in modelData.dataArray{
            if index < 3{
                switch index{
                case 0:
                    setImageViewOnImage(imageView: firstPostImageView, modelData: postData, playImageView: firstPlayImageView, thumnailImageView: firstPostThumbnail)
                    break
                case 1:
                    setImageViewOnImage(imageView: secondPostImageView, modelData: postData, playImageView: secondPlayImageView, thumnailImageView: secondPostThumbnail)
                    break
                case 2:
                    setImageViewOnImage(imageView: thirdPostImageView, modelData: postData, playImageView: thirdPlayImageView, thumnailImageView: thirdPostThumbnail)
                    break
                default:
                    break
                }
                index = index + 1
            }else{
                break
            }
        }
    }
    
    
    @IBAction func deleteChannelBtn_Action(_ sender: UIButton) {
        channelViewDelegate?.deleteChannelAction(sender.tag)
    }
    
    @IBAction func viewMoreBtn_Action(_ sender: UIButton) {
        channelViewDelegate?.moveViewToChannelPostAction(sender.tag)
    }
    
    
    func setImageViewOnImage(imageView: UIImageView, modelData: SocialModel, playImageView: UIImageView, thumnailImageView : UIImageView){
          thumnailImageView.setImageOn(imageUrl: modelData.thumbnailUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        if modelData.mediaType == 1{
            if let url = modelData.thumbnailUrl{
                let endIndex = url.index(url.endIndex, offsetBy: -3)
                var truncated = url.substring(to: endIndex)
                truncated = truncated + "jpg"
                imageView.setImageOn(imageUrl: modelData.imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }
            playImageView.isHidden = false
        }else{
            if let url = modelData.imageUrl{
                imageView.setImageOn(imageUrl: url, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }
            playImageView.isHidden = true
        }
        
    }
    
    @IBAction func editChannelButtonAction(_ sender: UIButton) {
        channelViewDelegate?.editChannelAction(sender.tag)
    }
    
    @IBAction func channelDetails(_ sender: UIButton) {
        channelViewDelegate?.moveToPostedByChannel(sender.tag)
    }
    
    @IBAction func postChannelDetailsAction(_ sender: UIButton) {
        channelViewDelegate?.moveToChannelPostAction(sender.tag, sender: sender)
    }
}
