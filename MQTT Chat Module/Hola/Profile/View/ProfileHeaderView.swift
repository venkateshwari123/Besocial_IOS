//
//  ProfileHeaderView.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 17/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol ProfileHeaderViewDelegate: class {
    func didFollowButtonTap()
    func didEditButtonTap()
}

class ProfileHeaderView: UIView {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    @IBOutlet weak var followContainerView: UIView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    @IBOutlet weak var followViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var editImageView: UIImageView!
    
    var isMine: Bool = false
    
    var delegate: ProfileHeaderViewDelegate?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
  
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 300)
        self.layoutIfNeeded()
        //make corner radious of top left and top right for detailsContainerView
        let maskPath = UIBezierPath.init(roundedRect: self.detailsContainerView.bounds, byRoundingCorners:[.topLeft, .topRight], cornerRadii: CGSize.init(width: 20.0, height: 20.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.detailsContainerView.bounds
        maskLayer.path = maskPath.cgPath
        self.detailsContainerView.layer.mask = maskLayer
        
        //make corner radious for profileImageView and border width
        self.profileImageView.makeCornerRadious(readious: profileImageView.frame.size.width / 2)
        self.profileImageView.makeBorderWidth(width: 1.0, color: UIColor.white)
        
        self.followContainerView.makeCornerRadious(readious: 5.0)
        self.followContainerView.makeBorderWidth(width: 1.0, color: UIColor.lightGray)
    }
    
    
    
    func setHeaderViewFromModel(modelData: UserProfileModel?, isSelf: Bool){
        isMine = isSelf
        if isMine{
            self.followViewHeightConstraint.constant = 0.0
            self.layoutIfNeeded()
        }else{
            self.followViewHeightConstraint.constant = 35.0
            self.layoutIfNeeded()
        }
        guard let data = modelData else {return}
        self.userName.text = data.userName
        self.userStatus.text = data.status
        let fullName = data.firstName + " " + data.lastName

       // self.coverImageView.setImageOn(imageUrl: data.profilePic, defaultImage: #imageLiteral(resourceName: "defaultImage"))
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 17/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: data.profilePic, imageView: self.profileImageView, fullName: fullName)
        
//        if let count = data.count{
//            self.postCountLabel.text = "\(count.post)"
//            self.followersCountLabel.text = "\(count.followers)"
//            self.followingCountLabel.text = "\(count.following)"
//        }
        self.postCountLabel.text = "\(data.postsCount)"
        self.followersCountLabel.text = "\(data.followersCount)"
        self.followingCountLabel.text = "\(data.followingCount)"
        self.setFollowButton(modelData: modelData!)
    }
    
    
    ///set follow button of cell
    func setFollowButton(modelData: UserProfileModel){
        self.followButtonOutlet.makeCornerRadious(readious: 5.0)
        if !Utility.isDarkModeEnable(){
            self.followContainerView.makeShadowEffect(color: UIColor.lightGray)
        }
        let borderColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
        self.followButtonOutlet.makeBorderWidth(width: 1, color: borderColor)
        if modelData.followStatus == 0{
            var title: String = "Follow".localized
            if modelData.privicy == 1{
                title = "Request".localized
            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(borderColor, for: .normal)
            self.followButtonOutlet.backgroundColor = UIColor.white
        }else{
            var title: String = "Following".localized
            if modelData.followStatus == 2{
                title = "Requested".localized
            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            self.followButtonOutlet.backgroundColor = borderColor
        }
    }
    
    //MARK:- Button Action
    @IBAction func followButtonAction(_ sender: Any) {
        delegate?.didFollowButtonTap()
    }
    
    @IBAction func editbuttonAction(_ sender: Any) {
        if delegate != nil && self.isMine{
            delegate?.didEditButtonTap()
        }
    }
    

}
