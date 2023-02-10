//
//  PostDetailsTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 22/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol PostDetailsTableViewCellDelegate: class {
    func likeButtonTap(index: Int, isSelected: Bool)
    func commentButtonTap(index: Int)
    func shareButtonTap(index: Int)
    func profileImageViewTap(index: Int)
    func singleTapOnCell(index: Int)
    func categoryButtonTap(index: Int)
    func musicButtonTap(index: Int)
    func locationButtonTap(index: Int)
}

class PostDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountLable: UILabel!
    
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentCountLable: UILabel!
    
    @IBOutlet weak var viewImageView: UIImageView!
    @IBOutlet weak var viewsCountlabel: UILabel!
    
    @IBOutlet weak var shareImageView: UIImageView!
    
    @IBOutlet weak var userDetailsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var postLocationButtonOutlet: UIButton!
    @IBOutlet weak var postDetailsLabel: UILabel!
//    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryButtonOutlet: UIButton!
    @IBOutlet weak var musicViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var musicNameLabel: UILabel!
    
    @IBOutlet weak var bigLikeImageView: UIImageView!
    
    
    var videoUrl: URL?
    var index: Int = 0
    var delegate: PostDetailsTableViewCellDelegate?
    var socialModel: SocialModel?{
        didSet{
            self.setCellData()
        }
    }
    
    //MARK:- View life cycel
    override func awakeFromNib() {
        super.awakeFromNib()
        //make corner radious for user and music image view
        self.userImageView.makeCornerRadious(readious: userImageView.frame.size.width / 2)
        self.musicImageView.makeCornerRadious(readious: musicImageView.frame.size.width / 2)
        
        //Tap gesture setup
        //Double tap gesture
        let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(PostDetailsTableViewCell.doubleTapHandle(_:)))
//        doubleTapGR.delegate = self
        doubleTapGR.numberOfTapsRequired = 2
        doubleTapGR.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTapGR)
        
        //Single tap gesture
        let singleTapGR = UITapGestureRecognizer(target: self, action: #selector(PostDetailsTableViewCell.singleTapHandle(_:)))
        singleTapGR.cancelsTouchesInView = false
//        singleTapGR.delegate = self
        singleTapGR.numberOfTapsRequired = 1
        singleTapGR.numberOfTouchesRequired = 1
        self.addGestureRecognizer(singleTapGR)
        singleTapGR.require(toFail: doubleTapGR)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       // self.likeImageView.makeShadowEffect(color: UIColor.lightGray)
       // self.likeCountLable.makeShadowEffect(color: UIColor.lightGray)
      //  self.commentImageView.makeShadowEffect(color: UIColor.lightGray)
      //  self.commentCountLable.makeShadowEffect(color: UIColor.lightGray)
      //  self.viewImageView.makeShadowEffect(color: UIColor.lightGray)
     //   self.viewsCountlabel.makeShadowEffect(color: UIColor.lightGray)
      //  self.shareImageView.makeShadowEffect(color: UIColor.lightGray)
        self.userImageView.makeShadowEffect(color: UIColor.lightGray)
        self.userNamelabel.makeShadowEffect(color: UIColor.lightGray)
        self.postLocationButtonOutlet.makeShadowEffect(color: UIColor.lightGray)
        self.categoryButtonOutlet.makeShadowEffect(color: UIColor.lightGray)
        self.userNamelabel.makeShadowEffect(color: UIColor.lightGray)
        self.userNamelabel.makeShadowEffect(color: UIColor.lightGray)
        self.musicImageView.makeShadowEffect(color: UIColor.lightGray)
        self.musicNameLabel.makeShadowEffect(color: UIColor.lightGray)
    }
    
    
    /// To set all cell data according to media type
    func setCellData() {
        if socialModel?.mediaType == 1{
            if let url = socialModel?.thumbnailUrl{
                let endIndex = url.index(url.endIndex, offsetBy: -3)
                var truncated = url.substring(to: endIndex)
                self.videoUrl = URL(string: truncated + "mov")
                truncated = truncated + "jpg"
                self.postImageView.setImageOn(imageUrl: truncated, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }
        }else{
            self.postImageView.setImageOn(imageUrl: socialModel?.imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        }
        self.setFavouriteButtonsAndCounts()
        self.setUserDetails()
    }
    
    
    /// to set buttons and there counts
    private func setFavouriteButtonsAndCounts(){
        if let data = socialModel {
            if data.liked == 0{
                self.likeImageView.image = UIImage(named: "like_off")
            }else{
                self.likeImageView.image = UIImage(named: "like_on")
            }
            self.likeCountLable.text = "\(String(describing: data.likesCount))"
            self.commentCountLable.text = "\(String(describing: data.commentCount))"
            self.viewsCountlabel.text = "\(String(describing: data.distinctView))"
        }
    }
    
    /// To set user details
    private func setUserDetails(){
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 17/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: socialModel?.profilePic, imageView: self.userImageView, fullName: socialModel?.fullNameWithSpace ?? "D")
        self.userNamelabel.text = socialModel?.userName
        self.postLocationButtonOutlet.setTitle(socialModel?.place, for: .normal)
        self.postDetailsLabel.text = socialModel?.title
//        self.categoryLabel.text = socialModel?.categoryName
        self.categoryButtonOutlet.setTitle(socialModel?.categoryName, for: .normal)
        self.setUserDetailsView(mediaType: socialModel?.mediaType)
    }
    
    
    /// To set user details and there heights according media type
    ///
    /// - Parameter mediaType: media type 0 for image and 1 for video
    private func setUserDetailsView(mediaType: Int?){
        if mediaType == 1, let mediaModel = self.socialModel?.mediaData{
            self.musicNameLabel.text = mediaModel.name
            let image = UIImage(named: "music-symbol")!
            self.musicImageView.setImageOn(imageUrl: mediaModel.imageUrl, defaultImage: image)
            self.musicViewHeightConstraint.constant = 27.0
//            self.userDetailsHeightConstraint.constant = 135.0
        }else{
            self.musicNameLabel.text = ""
            self.musicImageView.image = nil
            self.musicViewHeightConstraint.constant = 0.0
//            self.userDetailsHeightConstraint.constant = 105.0
        }
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        self.postImageView.image = nil
    }
    
    //MARK:- Buttons Action
    
    @IBAction func likeButtonAction(_ sender: Any) {
        
        if socialModel?.liked == 1{
            delegate?.likeButtonTap(index: self.index, isSelected: true)
            socialModel?.liked = 0
            socialModel?.likesCount = (socialModel?.likesCount)! - 1
            self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "favourite_black"), view: self.likeImageView)
        }else{
            delegate?.likeButtonTap(index: self.index, isSelected: false)
            socialModel?.liked = 1
            socialModel?.likesCount = (socialModel?.likesCount)! + 1
            self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_on"), view: self.likeImageView)
        }
        if let data = socialModel{
            self.likeCountLable.text = "\(String(describing: data.likesCount))"
        }
    }
    
    @IBAction func commentButtonAction(_ sender: Any) {
        delegate?.commentButtonTap(index: index)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        delegate?.shareButtonTap(index: index)
    }
    
    
    @IBAction func profileButtonAction(_ sender: Any) {
        delegate?.profileImageViewTap(index: index)
    }
    
    
    @IBAction func categoryButtonAction(_ sender: Any) {
        delegate?.categoryButtonTap(index: index)
    }
    
    @IBAction func musicButtonaction(_ sender: Any) {
        delegate?.musicButtonTap(index: index)
    }
    
    @IBAction func postLocationAction(_ sender: Any) {
        guard let place = socialModel?.place else{return}
        if place != ""{
            delegate?.locationButtonTap(index: index)
        }
    }
    
    
    //MARK:- tap gesture delegate
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func doubleTapHandle(_ gesture: UITapGestureRecognizer){
        print("doubletapped")
        if let data = socialModel{
            if data.liked == 0{
                delegate?.likeButtonTap(index: self.index, isSelected: false)
                socialModel?.liked = 1
                socialModel?.likesCount = (socialModel?.likesCount)! + 1
                self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_on"), view: self.likeImageView)
                self.likeCountLable.text = "\(String(describing: data.likesCount))"
            }
//            self.bigLikeImageView.isHidden = false
            self.bigLikeImageView.popUpDoubletapFavouritAnimation()
        }
    }
    
    
    /// To handle single tap
    ///
    /// - Parameter gesture: tap gesture
    @objc func singleTapHandle(_ gesture: UITapGestureRecognizer){
        print("single tapped")
        if socialModel?.mediaType == 1{
            delegate?.singleTapOnCell(index: index)
        }
    }
}
