//
//  SocialCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 27/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

protocol SocialCollectionViewCellDelegate: class {
    func hastagOrProfileSelected(byTag: String)
//    func channelSelected(id: String, name: String)
}

class SocialCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mainContainerView: UIView!
    
    @IBOutlet weak var postImageView: AnimatedImageView!
    
    @IBOutlet weak var userDetailsview: UIView!
    @IBOutlet weak var postDetailsview: UIView!
    @IBOutlet weak var postDetailsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var postDetailsLabel: KILabel!
    
    weak var delegate: SocialCollectionViewCellDelegate?
    var channelId: String?
    var isViewLoaded: Bool = true
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mainContainerView.makeCornerRadious(readious: 5)
//        self.backView.makeShadowEffect(color: UIColor.lightGray)
        let layer = self.backView.layer
        layer.shadowRadius = 3;
        layer.cornerRadius = 5;
        layer.masksToBounds = false;
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 1
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: 5).cgPath
        if !Utility.isDarkModeEnable(){
            self.mainContainerView.makeShadowEffect(color: UIColor.lightGray)
        }
        self.userImageView.makeCornerRadious(readious: userImageView.frame.size.width / 2)
        self.userImageView.makeBorderWidth(width: 1, color: UIColor.white)
        self.layoutIfNeeded()
    }
    
    func setDataInCell(social: SocialModel){
        
        self.userNameLabel.text = social.userName
        let time = Helper.getTimeStamp(timeStamp: social.timeStamp ?? 0.0)
        let timeArr = time.components(separatedBy: " ")
        var postTimeString = ""
        for item in timeArr{
            postTimeString.append(item.localized + " ")
        }
        self.postTimeLabel.text = postTimeString
        self.postDetailsLabel.text = social.title

        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: social.profilePic, imageView: self.userImageView, fullName: social.fullNameWithSpace ?? "")
        self.setPostDetailsHeight(social: social)
        self.linkHandler()
        if self.isViewLoaded{
            self.isViewLoaded = false
            self.setGradientColorToViews()
        }
    }
    
    
    /// To make set post details height according to title data
    ///
    /// - Parameter social: soial model
    private func setPostDetailsHeight(social: SocialModel){
        self.postDetailsview.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        var decStringHeight = social.title!.height(withConstrainedWidth: self.postDetailsLabel.frame.size.width, font: self.postDetailsLabel.font)
        if decStringHeight <= 13{
            decStringHeight = 13
        }else if decStringHeight >= 39{
            decStringHeight = 39 + 4
        }else{
            decStringHeight = decStringHeight + 4
        }
        self.postDetailsHeightConstraint.constant = 32 + decStringHeight
        self.layoutIfNeeded()
    }
    
    /// To make gradiant color to user details view and post details view
    private func setGradientColorToViews(){
        let colorTop =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0)
        let colorBottom = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        self.userDetailsview.makeGradiantColor(topColor: colorBottom, bottomColor: colorTop)
        let gradientView = PostGradientView(frame: self.postDetailsview.bounds)
        self.postDetailsview.insertSubview(gradientView, at: 0)
    }
    
    /// To handle link in description
    private func linkHandler(){
        postDetailsLabel.systemURLStyle = true;
        self.postDetailsLabel.userHandleLinkTapHandler = { (label, string, range) in
            print(string)
            self.delegate?.hastagOrProfileSelected(byTag: string)
        }
        
        postDetailsLabel.hashtagLinkTapHandler = { (label, string, range) in
            print(string)
            self.delegate?.hastagOrProfileSelected(byTag: string)
        }
    
    }
    
    func setImageInCell(social: SocialModel, isPlaying: Bool){
        if social.mediaType == 1{
            if let url = social.thumbnailUrl{
                if isPlaying{
//                    let gifString = url.makeGifUrl()
                    self.postImageView.setImageOn(imageUrl: url, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                }else{
                    self.postImageView.image = nil
                }
            }
            self.videoImage.isHidden = false
        }else{
            if let url = social.imageUrl{
                self.postImageView.setImageOn(imageUrl: url, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }
            self.videoImage.isHidden = true
        }
    }
    
    
    deinit {
        self.postImageView.image = nil
    }
}
